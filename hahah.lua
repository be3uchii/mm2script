local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize

local menuWidth, menuHeight = 280, 180
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Config"}
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local minimizedSize = UDim2.new(0, 70, 0, 18)
local minimizedPosition = UDim2.new(0.5, -35, 0.01, 0)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)
local keyFileName = "silence_keys"
local configFolder = "SilenceConfig"
local configFile = "settings.txt"

local themes = {
    Default = {
        Background = Color3.fromRGB(20, 20, 30),
        Foreground = Color3.fromRGB(30, 30, 40),
        Text = Color3.fromRGB(230, 230, 230),
        Accent = Color3.fromRGB(100, 150, 255),
        Shadow = Color3.fromRGB(0, 0, 0, 0.5)
    }
}
local currentTheme = "Default"

local colors = {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(255, 0, 255)
}

local defaultSettings = {
    PlayerInfo = {
        UserId = LocalPlayer.UserId,
        Name = LocalPlayer.Name
    },
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 4,
            Color = colors[1],
            Transparency = 0.7,
            Type = "Box"
        }
    },
    ESP = {
        Enabled = false,
        ShowDistance = false,
        MaxDistance = 160
    },
    Configs = {},
    Keybinds = {
        ToggleUI = Enum.KeyCode.Insert,
        ToggleESP = Enum.KeyCode.F1,
        ToggleHitbox = Enum.KeyCode.F2
    }
}

local settings = table.clone(defaultSettings)
local espCache = {}
local hitboxCache = {}
local connections = {}
local tabButtons = {}
local contentFrames = {}
local scrollFrames = {}
local playerConnections = {}
local configButtons = {}
local uiElements = {}
local soundCache = {}
local startTime = os.time()
local elapsedTime = 0
local timerActive = true
local keyAttempts = 0
local maxKeyAttempts = 5
local keyCooldown = false
local keyCooldownTime = 10

local function playSound(id, volume)
    if not soundCache[id] then
        soundCache[id] = Instance.new("Sound")
        soundCache[id].SoundId = "rbxassetid://"..tostring(id)
        soundCache[id].Volume = volume or 0.25
        soundCache[id].Parent = workspace
    end
    soundCache[id]:Play()
end

local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function updateTimer()
    if timerActive then
        elapsedTime = os.time() - startTime
    end
end

local function generatePassword(length)
    local chars = {}
    for i = 48, 57 do table.insert(chars, string.char(i)) end
    for i = 65, 90 do table.insert(chars, string.char(i)) end
    for i = 97, 122 do table.insert(chars, string.char(i)) end
    
    local password = ""
    for i = 1, length do
        password = password .. chars[math.random(1, #chars)]
    end
    
    return password
end

local function ensureConfigFolder()
    if not isfolder(configFolder) then
        makefolder(configFolder)
    end
end

local function saveSettings()
    ensureConfigFolder()
    local tempPath = configFolder.."/temp_"..configFile
    local finalPath = configFolder.."/"..configFile
    
    local serializedSettings = {Configs = settings.Configs, PlayerInfo = settings.PlayerInfo}
    writefile(tempPath, HttpService:JSONEncode(serializedSettings))
    if isfile(finalPath) then
        delfile(finalPath)
    end
    writefile(finalPath, readfile(tempPath))
    delfile(tempPath)
end

local function loadSettings()
    ensureConfigFolder()
    local path = configFolder.."/"..configFile
    
    if isfile(path) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        
        if success and result and result.Configs then
            settings.Configs = result.Configs
        end
    end
end

local function saveConfig(configName)
    ensureConfigFolder()
    local configPath = configFolder.."/"..configName..".txt"
    writefile(configPath, HttpService:JSONEncode(settings))
    
    if not table.find(settings.Configs, configName) then
        table.insert(settings.Configs, configName)
        saveSettings()
    end
end

local function loadConfig(configName)
    local configPath = configFolder.."/"..configName..".txt"
    if not isfile(configPath) then return false end
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(configPath))
    end)
    
    if success and result then
        settings = table.clone(defaultSettings)
        for category, data in pairs(result) do
            if settings[category] then
                for key, value in pairs(data) do
                    if settings[category][key] ~= nil then
                        settings[category][key] = value
                    end
                end
            end
        end
        return true
    end
    return false
end

local function deleteConfig(configName)
    local configPath = configFolder.."/"..configName..".txt"
    if isfile(configPath) then
        delfile(configPath)
    end
    
    local index = table.find(settings.Configs, configName)
    if index then
        table.remove(settings.Configs, index)
        saveSettings()
    end
end

local function scanConfigs()
    ensureConfigFolder()
    local files = listfiles(configFolder)
    local foundConfigs = {}
    
    for _, file in ipairs(files) do
        if file:sub(-4) == ".txt" and file ~= configFolder.."/"..configFile then
            local configName = file:match(".*/(.*)%.txt")
            if configName then
                table.insert(foundConfigs, configName)
            end
        end
    end
    
    settings.Configs = foundConfigs
    saveSettings()
    return foundConfigs
end

local function clearAll()
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    connections = {}
    
    for player, _ in pairs(playerConnections) do
        if player and player.Parent then
            for _, conn in pairs(playerConnections[player]) do
                if conn then conn:Disconnect() end
            end
        end
    end
    playerConnections = {}
    
    for _, espData in pairs(espCache) do
        if espData.box then espData.box:Remove() end
        if espData.distanceText then espData.distanceText:Remove() end
    end
    espCache = {}
    
    for character, box in pairs(hitboxCache) do
        if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            character.HumanoidRootPart.Transparency = 1
            character.HumanoidRootPart.CanCollide = true
        end
        if box then box:Destroy() end
    end
    hitboxCache = {}
end

local function disableShadows()
    Lighting.GlobalShadows = false
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CastShadow = false
        end
    end
end

local function updateNoClip()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part ~= LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                part.CanCollide = false
            end
        end
    end
end

local function clearHitboxes()
    for character, box in pairs(hitboxCache) do
        if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            character.HumanoidRootPart.Transparency = 1
            character.HumanoidRootPart.CanCollide = true
        end
        if box then box:Destroy() end
    end
    hitboxCache = {}
end

local function updateHitbox(character)
    if not settings.Combat.Hitbox.Enabled then
        if hitboxCache[character] then
            hitboxCache[character]:Destroy()
            hitboxCache[character] = nil
        end
        return 
    end
    
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
        if hitboxCache[character] then
            hitboxCache[character]:Destroy()
            hitboxCache[character] = nil
        end
        return 
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        if hitboxCache[character] then
            hitboxCache[character]:Destroy()
            hitboxCache[character] = nil
        end
        return 
    end
    
    local distance = (hrp.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        if hitboxCache[character] then
            hitboxCache[character]:Destroy()
            hitboxCache[character] = nil
        end
        return
    end
    
    if not hitboxCache[character] then
        local box = Instance.new(settings.Combat.Hitbox.Type == "Sphere" and "SphereHandleAdornment" or "BoxHandleAdornment")
        if settings.Combat.Hitbox.Type == "Sphere" then
            box.Radius = settings.Combat.Hitbox.Size * 1.2
        else
            box.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
        end
        
        box.Name = "HitboxAdornment"
        box.Adornee = hrp
        box.AlwaysOnTop = false
        box.ZIndex = 0
        box.Transparency = settings.Combat.Hitbox.Transparency
        box.Color3 = settings.Combat.Hitbox.Color
        box.Parent = hrp
        
        hitboxCache[character] = box
    end
    
    if settings.Combat.Hitbox.Type == "Sphere" then
        hrp.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.2, settings.Combat.Hitbox.Size * 1.2, settings.Combat.Hitbox.Size * 1.2)
    else
        hrp.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
    end
    
    hrp.Transparency = 1
    hrp.CanCollide = false
end

local function createESP(player)
    if not player or player == LocalPlayer then return end
    if espCache[player] then
        if espCache[player].box then espCache[player].box:Remove() end
        if espCache[player].distanceText then espCache[player].distanceText:Remove() end
    end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Thickness = 2
    box.Filled = false
    box.ZIndex = 1
    
    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Color = Color3.fromRGB(255, 255, 255)
    distanceText.Size = 12
    distanceText.ZIndex = 1
    
    espCache[player] = {box = box, distanceText = distanceText}
    
    if not playerConnections[player] then
        playerConnections[player] = {}
    end
    
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        playerConnections[player].died = humanoid.Died:Connect(function()
            if espCache[player] then
                espCache[player].box.Visible = false
                espCache[player].distanceText.Visible = false
            end
            if hitboxCache[character] then
                hitboxCache[character]:Destroy()
                hitboxCache[character] = nil
            end
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    playerConnections[player].characterAdded = player.CharacterAdded:Connect(onCharacterAdded)
end

local function updateESP(player)
    local espData = espCache[player]
    if not espData then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        espData.box.Visible = false
        espData.distanceText.Visible = false
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not humanoidRootPart or not head then
        espData.box.Visible = false
        espData.distanceText.Visible = false
        return
    end
    
    local distance = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        espData.box.Visible = false
        espData.distanceText.Visible = false
        return
    end
    
    local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        espData.box.Visible = false
        espData.distanceText.Visible = false
        return
    end
    
    local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local feetPos = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
    
    local height = (headPos.Y - feetPos.Y)
    local width = height * 0.6
    
    espData.box.Size = Vector2.new(width, height)
    espData.box.Position = Vector2.new(rootPos.X - width/2, feetPos.Y)
    espData.box.Visible = settings.ESP.Enabled
    
    if settings.ESP.ShowDistance then
        espData.distanceText.Text = tostring(math.floor(distance)) .. "m"
        espData.distanceText.Position = Vector2.new(rootPos.X, headPos.Y - 15)
        espData.distanceText.Visible = settings.ESP.Enabled
    else
        espData.distanceText.Visible = false
    end
end

local function clearESP(player)
    if espCache[player] then
        if espCache[player].box then espCache[player].box:Remove() end
        if espCache[player].distanceText then espCache[player].distanceText:Remove() end
        espCache[player] = nil
    end
    if playerConnections[player] then
        for _, conn in pairs(playerConnections[player]) do
            if conn then conn:Disconnect() end
        end
        playerConnections[player] = nil
    end
end

local function updateAllESP()
    for player, _ in pairs(espCache) do
        updateESP(player)
    end
    
    if settings.Combat.Hitbox.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                updateHitbox(player.Character)
            end
        end
    else
        clearHitboxes()
    end
end

local function createCleanToggle(parent, text, value, callback, id)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -8, 0, 18)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Position = UDim2.new(0, 4, 0, 0)
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = themes[currentTheme].Text
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local SwitchButton = Instance.new("TextButton")
    SwitchButton.Size = UDim2.new(0.25, 0, 0.6, 0)
    SwitchButton.Position = UDim2.new(0.7, 0, 0.2, 0)
    SwitchButton.BackgroundColor3 = value and Color3.fromRGB(76, 217, 100) or Color3.fromRGB(255, 58, 58)
    SwitchButton.AutoButtonColor = false
    SwitchButton.Text = ""
    SwitchButton.Parent = toggleFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = SwitchButton
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 10, 0, 10)
    ToggleCircle.Position = value and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.Parent = SwitchButton
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = ToggleCircle
    
    SwitchButton.MouseButton1Click:Connect(function()
        playSound(6895079853)
        value = not value
        
        local circleGoalPos = value and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
        local bgGoalColor = value and Color3.fromRGB(76, 217, 100) or Color3.fromRGB(255, 58, 58)
        
        TweenService:Create(ToggleCircle, tweenInfo, {Position = circleGoalPos}):Play()
        TweenService:Create(SwitchButton, tweenInfo, {BackgroundColor3 = bgGoalColor}):Play()
        
        callback(value)
        saveSettings()
    end)
    
    if id then
        uiElements[id] = {
            update = function(newValue)
                value = newValue
                local circleGoalPos = value and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
                local bgGoalColor = value and Color3.fromRGB(76, 217, 100) or Color3.fromRGB(255, 58, 58)
                ToggleCircle.Position = circleGoalPos
                SwitchButton.BackgroundColor3 = bgGoalColor
            end
        }
    end
    
    return toggleFrame
end

local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 20)
    button.Position = UDim2.new(0, 4, 0, 0)
    button.BackgroundColor3 = themes[currentTheme].Accent
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = text
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        playSound(6895079853)
        callback()
    end)
    
    return button
end

local function createSection(parent, text)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, -8, 0, 20)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Position = UDim2.new(0, 4, 0, 0)
    sectionFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = string.upper(text)
    label.TextColor3 = themes[currentTheme].Text
    label.TextTransparency = 0.3
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sectionFrame
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = themes[currentTheme].Text
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    line.Parent = sectionFrame
    
    return sectionFrame
end

local function refreshCombatUI()
    local combatScrollFrame = scrollFrames[1]
    if not combatScrollFrame then return end
    
    for _, child in ipairs(combatScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    createSection(combatScrollFrame, "Hitbox")
    
    createCleanToggle(combatScrollFrame, "Hitbox Enabled", settings.Combat.Hitbox.Enabled, function(value)
        settings.Combat.Hitbox.Enabled = value
        if not value then clearHitboxes() end
        updateAllESP()
    end, "hitboxEnabled")
    
    local sizeFrame = Instance.new("Frame")
    sizeFrame.Size = UDim2.new(1, -8, 0, 20)
    sizeFrame.BackgroundTransparency = 1
    sizeFrame.Position = UDim2.new(0, 4, 0, 0)
    sizeFrame.Parent = combatScrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Hitbox Size"
    label.TextColor3 = themes[currentTheme].Text
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sizeFrame
    
    local sizeButton = createButton(sizeFrame, tostring(settings.Combat.Hitbox.Size), function()
        settings.Combat.Hitbox.Size = settings.Combat.Hitbox.Size < 8 and settings.Combat.Hitbox.Size + 1 or 1
        sizeButton.Text = tostring(settings.Combat.Hitbox.Size)
        updateAllESP()
        saveSettings()
    end)
    sizeButton.Size = UDim2.new(0.45, 0, 1, 0)
    sizeButton.Position = UDim2.new(0.5, 0, 0, 0)
    
    local typeFrame = Instance.new("Frame")
    typeFrame.Size = UDim2.new(1, -8, 0, 20)
    typeFrame.BackgroundTransparency = 1
    typeFrame.Position = UDim2.new(0, 4, 0, 0)
    typeFrame.Parent = combatScrollFrame
    
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Size = UDim2.new(0.5, 0, 1, 0)
    typeLabel.Position = UDim2.new(0, 0, 0, 0)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Text = "Hitbox Type"
    typeLabel.TextColor3 = themes[currentTheme].Text
    typeLabel.TextTransparency = 0.1
    typeLabel.TextSize = 12
    typeLabel.Font = Enum.Font.Gotham
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
    typeLabel.Parent = typeFrame
    
    local typeButton = createButton(typeFrame, settings.Combat.Hitbox.Type, function()
        settings.Combat.Hitbox.Type = settings.Combat.Hitbox.Type == "Box" and "Sphere" or "Box"
        typeButton.Text = settings.Combat.Hitbox.Type
        clearHitboxes()
        updateAllESP()
        saveSettings()
    end)
    typeButton.Size = UDim2.new(0.45, 0, 1, 0)
    typeButton.Position = UDim2.new(0.5, 0, 0, 0)
end

local function refreshESPUI()
    local espScrollFrame = scrollFrames[2]
    if not espScrollFrame then return end
    
    for _, child in ipairs(espScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    createSection(espScrollFrame, "ESP Settings")
    
    createCleanToggle(espScrollFrame, "ESP Enabled", settings.ESP.Enabled, function(value)
        settings.ESP.Enabled = value
        updateAllESP()
    end, "espEnabled")
    
    local distanceFrame = Instance.new("Frame")
    distanceFrame.Size = UDim2.new(1, -8, 0, 20)
    distanceFrame.BackgroundTransparency = 1
    distanceFrame.Position = UDim2.new(0, 4, 0, 0)
    distanceFrame.Parent = espScrollFrame
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(0.5, 0, 1, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "Max Distance"
    distanceLabel.TextColor3 = themes[currentTheme].Text
    distanceLabel.TextTransparency = 0.1
    distanceLabel.TextSize = 12
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    distanceLabel.Parent = distanceFrame
    
    local distanceButton = createButton(distanceFrame, tostring(settings.ESP.MaxDistance), function()
        settings.ESP.MaxDistance = settings.ESP.MaxDistance < 500 and settings.ESP.MaxDistance + 50 or 50
        distanceButton.Text = tostring(settings.ESP.MaxDistance)
        updateAllESP()
        saveSettings()
    end)
    distanceButton.Size = UDim2.new(0.45, 0, 1, 0)
    distanceButton.Position = UDim2.new(0.5, 0, 0, 0)
    
    createSection(espScrollFrame, "ESP Elements")
    
    createCleanToggle(espScrollFrame, "Show Distance", settings.ESP.ShowDistance, function(value)
        settings.ESP.ShowDistance = value
        updateAllESP()
    end, "espShowDistance")
end

local function refreshConfigUI(scrollFrame)
    for _, button in pairs(configButtons) do
        button:Destroy()
    end
    configButtons = {}
    
    local yOffset = 0
    
    local createConfigFrame = Instance.new("Frame")
    createConfigFrame.Size = UDim2.new(1, -8, 0, 45)
    createConfigFrame.Position = UDim2.new(0, 4, 0, yOffset)
    createConfigFrame.BackgroundColor3 = themes[currentTheme].Foreground
    createConfigFrame.BackgroundTransparency = 0.1
    createConfigFrame.Parent = scrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = createConfigFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.7, 0, 0.6, 0)
    textBox.Position = UDim2.new(0.05, 0, 0.2, 0)
    textBox.BackgroundColor3 = themes[currentTheme].Background
    textBox.TextColor3 = themes[currentTheme].Text
    textBox.PlaceholderText = "Config name"
    textBox.Text = ""
    textBox.ClearTextOnFocus = false
    textBox.TextSize = 12
    textBox.Parent = createConfigFrame
    
    local createButton = Instance.new("TextButton")
    createButton.Size = UDim2.new(0.2, 0, 0.6, 0)
    createButton.Position = UDim2.new(0.75, 0, 0.2, 0)
    createButton.BackgroundColor3 = themes[currentTheme].Accent
    createButton.Text = "Create"
    createButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    createButton.TextSize = 12
    createButton.Parent = createConfigFrame
    
    corner:Clone().Parent = textBox
    corner:Clone().Parent = createButton
    
    createButton.MouseButton1Click:Connect(function()
        playSound(6895079853)
        if textBox.Text ~= "" then
            saveConfig(textBox.Text)
            scanConfigs()
            refreshConfigUI(scrollFrame)
            textBox.Text = ""
        end
    end)
    
    table.insert(configButtons, createConfigFrame)
    yOffset = yOffset + 50
    
    for _, configName in ipairs(scanConfigs()) do
        local configFrame = Instance.new("Frame")
        configFrame.Size = UDim2.new(1, -8, 0, 35)
        configFrame.Position = UDim2.new(0, 4, 0, yOffset)
        configFrame.BackgroundColor3 = themes[currentTheme].Foreground
        configFrame.BackgroundTransparency = 0.1
        configFrame.Parent = scrollFrame
        
        corner:Clone().Parent = configFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = configName
        nameLabel.TextColor3 = themes[currentTheme].Text
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = configFrame
        
        local loadButton = Instance.new("TextButton")
        loadButton.Size = UDim2.new(0.15, 0, 0.7, 0)
        loadButton.Position = UDim2.new(0.65, 0, 0.15, 0)
        loadButton.BackgroundColor3 = themes[currentTheme].Accent
        loadButton.Text = "Load"
        loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadButton.TextSize = 12
        loadButton.Parent = configFrame
        
        local deleteButton = Instance.new("TextButton")
        deleteButton.Size = UDim2.new(0.15, 0, 0.7, 0)
        deleteButton.Position = UDim2.new(0.85, 0, 0.15, 0)
        deleteButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        deleteButton.Text = "Delete"
        deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        deleteButton.TextSize = 12
        deleteButton.Parent = configFrame
        
        corner:Clone().Parent = loadButton
        corner:Clone().Parent = deleteButton
        
        loadButton.MouseButton1Click:Connect(function()
            playSound(6895079853)
            if loadConfig(configName) then
                for id, element in pairs(uiElements) do
                    if id == "hitboxEnabled" then element.update(settings.Combat.Hitbox.Enabled)
                    elseif id == "espEnabled" then element.update(settings.ESP.Enabled)
                    elseif id == "espShowDistance" then element.update(settings.ESP.ShowDistance) end
                end
                updateAllESP()
            end
        end)
        
        deleteButton.MouseButton1Click:Connect(function()
            playSound(6895079853)
            deleteConfig(configName)
            scanConfigs()
            refreshConfigUI(scrollFrame)
        end)
        
        table.insert(configButtons, configFrame)
        yOffset = yOffset + 40
    end
end

local function createPasswordGUI()
    local passwordGui = Instance.new("ScreenGui")
    passwordGui.Name = "SilencePasswordGui"
    passwordGui.Parent = PlayerGui
    passwordGui.ResetOnSpawn = false
    passwordGui.IgnoreGuiInset = true

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 180)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
    mainFrame.BackgroundColor3 = themes[currentTheme].Background
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = passwordGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = themes[currentTheme].Accent
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0.1
    uiStroke.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "ENTER PASSWORD"
    titleLabel.TextColor3 = themes[currentTheme].Text
    titleLabel.TextTransparency = 0.1
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = mainFrame

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(1, -20, 0, 18)
    timerLabel.Position = UDim2.new(0, 10, 0, 35)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "Next generation in: 01:00"
    timerLabel.TextColor3 = themes[currentTheme].Text
    timerLabel.TextTransparency = 0.2
    timerLabel.TextSize = 12
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.TextXAlignment = Enum.TextXAlignment.Center
    timerLabel.Parent = mainFrame

    local passwordBox = Instance.new("TextBox")
    passwordBox.Size = UDim2.new(0.8, 0, 0, 30)
    passwordBox.Position = UDim2.new(0.1, 0, 0, 60)
    passwordBox.BackgroundColor3 = themes[currentTheme].Foreground
    passwordBox.TextColor3 = themes[currentTheme].Text
    passwordBox.PlaceholderText = "Password"
    passwordBox.Text = ""
    passwordBox.ClearTextOnFocus = false
    passwordBox.TextSize = 14
    passwordBox.Font = Enum.Font.Gotham
    passwordBox.TextXAlignment = Enum.TextXAlignment.Center
    passwordBox.Parent = mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = passwordBox

    local generateButton = createButton(mainFrame, "GENERATE", function()
        if not cooldown then
            generatedPassword = generatePassword(16)
            passwordBox.Text = generatedPassword
            playSound(6895079853)
            startTimer()
        else
            showError("Please wait "..math.ceil(timer).." seconds")
        end
    end)
    generateButton.Size = UDim2.new(0.35, 0, 0, 25)
    generateButton.Position = UDim2.new(0.1, 0, 0, 100)

    local submitButton = createButton(mainFrame, "SUBMIT", function()
        checkPassword()
    end)
    submitButton.Size = UDim2.new(0.35, 0, 0, 25)
    submitButton.Position = UDim2.new(0.55, 0, 0, 100)

    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, -20, 0, 18)
    errorLabel.Position = UDim2.new(0, 10, 0, 135)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    errorLabel.TextSize = 12
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.TextXAlignment = Enum.TextXAlignment.Center
    errorLabel.Visible = false
    errorLabel.Parent = mainFrame

    local attemptsLabel = Instance.new("TextLabel")
    attemptsLabel.Size = UDim2.new(1, -20, 0, 18)
    attemptsLabel.Position = UDim2.new(0, 10, 0, 155)
    attemptsLabel.BackgroundTransparency = 1
    attemptsLabel.Text = string.format("Attempts left: %d/%d", maxKeyAttempts - keyAttempts, maxKeyAttempts)
    attemptsLabel.TextColor3 = themes[currentTheme].Text
    attemptsLabel.TextTransparency = 0.3
    attemptsLabel.TextSize = 12
    attemptsLabel.Font = Enum.Font.Gotham
    attemptsLabel.TextXAlignment = Enum.TextXAlignment.Center
    attemptsLabel.Parent = mainFrame

    local generatedPassword = ""
    local timer = 60
    local timerConnection
    local cooldown = false

    local function showError(text)
        errorLabel.Text = text
        errorLabel.Visible = true
        task.delay(3, function()
            if errorLabel.Text == text then
                errorLabel.Visible = false
            end
        end)
    end

    local function updateTimerDisplay()
        local minutes = math.floor(timer / 60)
        local seconds = math.floor(timer % 60)
        timerLabel.Text = string.format("Next generation in: %02d:%02d", minutes, seconds)
    end

    local function startTimer()
        timer = 60
        updateTimerDisplay()
        cooldown = true
        
        if timerConnection then timerConnection:Disconnect() end
        
        timerConnection = RunService.Heartbeat:Connect(function(delta)
            timer = timer - delta
            if timer <= 0 then
                timer = 0
                cooldown = false
                timerLabel.Text = "Ready to generate"
                timerConnection:Disconnect()
            else
                updateTimerDisplay()
            end
        end)
    end

    local function checkPassword()
        if keyCooldown then
            showError(string.format("Please wait %d seconds", keyCooldownTime - (os.time() - keyCooldownStart)))
            return false
        end
        
        local password = passwordBox.Text
        local keyPath = configFolder.."/"..keyFileName
        
        if isfile(keyPath) then
            local fileContent = readfile(keyPath)
            local success, data = pcall(function()
                return HttpService:JSONDecode(fileContent)
            end)
            
            if success and data and type(data) == "table" then
                for _, keyData in pairs(data) do
                    if keyData.password and keyData.expireTime then
                        if password == keyData.password and os.time() < keyData.expireTime then
                            playSound(6895079853)
                            passwordGui:Destroy()
                            return true
                        end
                    end
                end
            end
        end
        
        if password == generatedPassword and generatedPassword ~= "" then
            playSound(6895079853)
            ensureConfigFolder()
            local expireTime = os.time() + 86400
            local keyData = {
                password = generatedPassword,
                expireTime = expireTime
            }
            
            local existingKeys = {}
            if isfile(keyPath) then
                local fileContent = readfile(keyPath)
                local success, data = pcall(function()
                    return HttpService:JSONDecode(fileContent)
                end)
                if success and data and type(data) == "table" then
                    existingKeys = data
                end
            end
            
            table.insert(existingKeys, keyData)
            writefile(keyPath, HttpService:JSONEncode(existingKeys))
            
            local tween = TweenService:Create(mainFrame, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -140, -1, 0)})
            tween:Play()
            tween.Completed:Wait()
            passwordGui:Destroy()
            return true
        else
            keyAttempts = keyAttempts + 1
            attemptsLabel.Text = string.format("Attempts left: %d/%d", maxKeyAttempts - keyAttempts, maxKeyAttempts)
            
            if keyAttempts >= maxKeyAttempts then
                keyCooldown = true
                keyCooldownStart = os.time()
                showError(string.format("Too many attempts! Please wait %d seconds", keyCooldownTime))
                
                task.spawn(function()
                    while os.time() - keyCooldownStart < keyCooldownTime do
                        local remaining = keyCooldownTime - (os.time() - keyCooldownStart)
                        attemptsLabel.Text = string.format("Next try in: %d seconds", math.ceil(remaining))
                        wait(1)
                    end
                    
                    keyCooldown = false
                    keyAttempts = 0
                    attemptsLabel.Text = string.format("Attempts left: %d/%d", maxKeyAttempts - keyAttempts, maxKeyAttempts)
                end)
            else
                showError("Invalid password!")
            end
            return false
        end
    end

    passwordBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then checkPassword() end
    end)

    startTimer()
    return passwordGui
end

local function hasValidKey()
    ensureConfigFolder()
    local keyPath = configFolder.."/"..keyFileName
    
    if not isfile(keyPath) then return false end
    
    local fileContent = readfile(keyPath)
    local success, data = pcall(function()
        return HttpService:JSONDecode(fileContent)
    end)
    
    if not success or not data or type(data) ~= "table" then return false end
    
    local validKeys = {}
    for _, keyData in pairs(data) do
        if keyData.password and keyData.expireTime and os.time() < keyData.expireTime then
            table.insert(validKeys, keyData)
        end
    end
    
    if #validKeys > 0 then
        writefile(keyPath, HttpService:JSONEncode(validKeys))
        return true
    else
        delfile(keyPath)
        return false
    end
end

local function createMainGUI()
    clearAll()
    settings = table.clone(defaultSettings)
    loadSettings()
    scanConfigs()

    if PlayerGui:FindFirstChild("SilenceGui") then
        PlayerGui.SilenceGui:Destroy()
        task.wait(0.1)
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilenceGui"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Enabled = isVisible

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    mainFrame.Position = defaultPosition
    mainFrame.BackgroundColor3 = themes[currentTheme].Background
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 6)
    uiCorner.Parent = mainFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = themes[currentTheme].Accent
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0.1
    uiStroke.Parent = mainFrame

    local dragArea = Instance.new("TextButton")
    dragArea.Size = UDim2.new(1, 0, 0, 20)
    dragArea.BackgroundTransparency = 1
    dragArea.Text = "SILENCE"
    dragArea.TextColor3 = themes[currentTheme].Text
    dragArea.TextTransparency = 0.1
    dragArea.TextSize = isMinimized and 12 or 14
    dragArea.Font = Enum.Font.GothamBold
    dragArea.TextXAlignment = Enum.TextXAlignment.Center
    dragArea.Selectable = false
    dragArea.Parent = mainFrame

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "TimerLabel"
    timerLabel.Size = UDim2.new(1, 0, 1, 0)
    timerLabel.Position = UDim2.new(0, 0, 0, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = formatTime(0)
    timerLabel.TextColor3 = themes[currentTheme].Text
    timerLabel.TextTransparency = 0.3
    timerLabel.TextSize = 12
    timerLabel.Font = Enum.Font.GothamBold
    timerLabel.TextXAlignment = Enum.TextXAlignment.Center
    timerLabel.Visible = isMinimized
    timerLabel.Parent = dragArea

    local rightIcon = Instance.new("ImageLabel")
    rightIcon.Name = "RightIcon"
    rightIcon.Image = "rbxassetid://70459115196971"
    rightIcon.Size = UDim2.new(0, 16, 0, 16)
    rightIcon.Position = UDim2.new(0.5, 25, 0.5, -8)
    rightIcon.BackgroundTransparency = 1
    rightIcon.ImageTransparency = 0.1
    rightIcon.Visible = not isMinimized
    rightIcon.Parent = dragArea

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 20)
    tabContainer.Position = UDim2.new(0, 0, 0, 20)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1 / #tabs, -2, 1, -2)
        tabButton.Position = UDim2.new((i - 1) / #tabs, 1, 0, 1)
        tabButton.BackgroundColor3 = i == currentTab and themes[currentTheme].Accent or themes[currentTheme].Foreground
        tabButton.BackgroundTransparency = 0.1
        tabButton.Text = tabName
        tabButton.TextColor3 = themes[currentTheme].Text
        tabButton.TextSize = 12
        tabButton.Font = Enum.Font.Gotham
        tabButton.Selectable = false
        tabButton.Parent = tabContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 4)
        tabCorner.Parent = tabButton

        tabButtons[i] = tabButton

        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, -8, 1, -44)
        contentFrame.Position = UDim2.new(0, 4, 0, 44)
        contentFrame.BackgroundColor3 = themes[currentTheme].Foreground
        contentFrame.BackgroundTransparency = 0.1
        contentFrame.Visible = i == currentTab
        contentFrame.Parent = mainFrame

        local contentCorner = Instance.new("UICorner")
        contentCorner.CornerRadius = UDim.new(0, 4)
        contentCorner.Parent = contentFrame

        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.ScrollBarImageColor3 = themes[currentTheme].Accent
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Selectable = false
        scrollFrame.Parent = contentFrame

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 5)
        layout.Parent = scrollFrame

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
        end)

        contentFrames[i] = contentFrame
        scrollFrames[i] = scrollFrame

        if tabName == "Combat" then
            refreshCombatUI()
        elseif tabName == "ESP" then
            refreshESPUI()
        elseif tabName == "Config" then
            refreshConfigUI(scrollFrame)
        end

        tabButton.MouseButton1Click:Connect(function()
            playSound(6895079853)
            currentTab = i
            for j, frame in ipairs(contentFrames) do
                frame.Visible = j == i
            end
            for j, btn in ipairs(tabButtons) do
                btn.BackgroundColor3 = j == currentTab and themes[currentTheme].Accent or themes[currentTheme].Foreground
            end
            if tabName == "Config" then
                refreshConfigUI(scrollFrame)
            end
        end)
    end

    local function tweenFrame(frame, size, position)
        local sizeTween = TweenService:Create(frame, tweenInfo, {Size = size})
        local positionTween = TweenService:Create(frame, tweenInfo, {Position = position})
        sizeTween:Play()
        positionTween:Play()
    end

    dragArea.MouseButton1Click:Connect(function()
        playSound(6895079853)
        isMinimized = not isMinimized
        timerActive = isMinimized
        local targetSize = isMinimized and minimizedSize or UDim2.new(0, menuWidth, 0, menuHeight)
        local targetPosition = isMinimized and minimizedPosition or defaultPosition
        tweenFrame(mainFrame, targetSize, targetPosition)
        tabContainer.Visible = not isMinimized
        for _, frame in ipairs(contentFrames) do
            frame.Visible = not isMinimized and frame == contentFrames[currentTab]
        end
        dragArea.TextSize = isMinimized and 12 or 14
        mainFrame.BackgroundTransparency = isMinimized and 0.3 or 0.1
        rightIcon.Visible = not isMinimized
        timerLabel.Visible = isMinimized
        dragArea.Text = isMinimized and "" or "SILENCE"
    end)

    local dragging = false
    local dragStart, frameStart
    local minY = 0
    local maxY = viewportSize.Y * 0.7

    dragArea.MouseButton1Down:Connect(function()
        dragging = true
        dragStart = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        frameStart = mainFrame.Position
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(0, UserInputService:GetMouseLocation().Y - dragStart.Y)
            local newY = math.clamp(frameStart.Y.Offset + delta.Y, minY, maxY)
            mainFrame.Position = UDim2.new(0, frameStart.X.Offset, 0, newY)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            defaultPosition = mainFrame.Position
        end
    end)

    connections.InputBegan = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == settings.Keybinds.ToggleUI then
            playSound(6895079853)
            isVisible = not isVisible
            screenGui.Enabled = isVisible
            if isVisible then updateAllESP() end
        end
        
        if not processed and input.KeyCode == settings.Keybinds.ToggleESP then
            playSound(6895079853)
            settings.ESP.Enabled = not settings.ESP.Enabled
            if uiElements["espEnabled"] then uiElements["espEnabled"].update(settings.ESP.Enabled) end
            updateAllESP()
            saveSettings()
        end
        
        if not processed and input.KeyCode == settings.Keybinds.ToggleHitbox then
            playSound(6895079853)
            settings.Combat.Hitbox.Enabled = not settings.Combat.Hitbox.Enabled
            if uiElements["hitboxEnabled"] then uiElements["hitboxEnabled"].update(settings.Combat.Hitbox.Enabled) end
            updateAllESP()
            saveSettings()
        end
    end)

    disableShadows()
    connections.DescendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") then obj.CastShadow = false end
    end)

    local function handlePlayerAdded(player)
        if player ~= LocalPlayer then createESP(player) end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        handlePlayerAdded(player)
    end

    connections.PlayerAdded = Players.PlayerAdded:Connect(handlePlayerAdded)
    connections.PlayerRemoving = Players.PlayerRemoving:Connect(clearESP)

    connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        updateNoClip()
        disableShadows()
        character:WaitForChild("Humanoid").Died:Connect(disableShadows)
    end)

    if LocalPlayer.Character then
        updateNoClip()
        disableShadows()
    end

    connections.RenderStep = RunService.RenderStepped:Connect(function()
        if isVisible then updateAllESP() end
    end)

    connections.TimerUpdate = RunService.Heartbeat:Connect(function()
        updateTimer()
        if isMinimized then timerLabel.Text = formatTime(elapsedTime) end
    end)

    return screenGui
end

local function init()
    if not hasValidKey() then
        local passwordGui = createPasswordGUI()
        repeat task.wait() until not passwordGui or not passwordGui.Parent
    end
    
    if hasValidKey() then
        createMainGUI()
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Error",
            Text = "Invalid password! Script will not work.",
            Duration = 5
        })
        return
    end

    game:BindToClose(function()
        clearAll()
        if PlayerGui:FindFirstChild("SilenceGui") then
            PlayerGui.SilenceGui:Destroy()
        end
        for _, sound in pairs(soundCache) do
            sound:Stop()
            sound:Destroy()
        end
    end)
end

init()