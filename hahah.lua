local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 320, 200
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Config"}
local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local minimizedSize = UDim2.new(0, 100, 0, 30)
local minimizedPosition = UDim2.new(0.5, -50, 0.01, 0)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)
local keyFileName = "silence_key.dat"
local configFolder = "SilenceConfig"
local configFile = "settings.cfg"

setfpscap(1000)

local colors = {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(0, 0, 0),
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 255, 0)
}

local transparencies = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9}

local defaultSettings = {
    PlayerInfo = {
        UserId = LocalPlayer.UserId,
        Name = LocalPlayer.Name,
        LastLogin = os.time()
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
        MaxDistance = 200
    },
    System = {
        PerformanceMode = true
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
local maxAttempts = 5
local remainingAttempts = maxAttempts
local attemptCooldown = 30
local lastAttemptTime = 0
local cooldownActive = false
local errorCount = 0
local maxErrors = 50
local initialized = false
local performanceMode = false
local cleanupQueue = {}
local cleanupInterval = 10
local lastCleanupTime = 0
local keyValidationAttempts = 0
local maxKeyAttempts = 3

local function ensureFolderStructure()
    local folders = {configFolder}
    for _, folder in ipairs(folders) do
        if not isfolder(folder) then
            makefolder(folder)
        end
    end
end

local function secureWrite(path, content)
    local tempPath = path .. ".tmp"
    writefile(tempPath, content)
    if isfile(path) then
        delfile(path)
    end
    writefile(path, readfile(tempPath))
    delfile(tempPath)
end

local function handleError(errorMsg, location)
    errorCount = errorCount + 1
    if errorCount >= maxErrors then
        clearAll()
    end
end

local function safeCall(func, errorLocation, ...)
    local success, result = pcall(func, ...)
    if not success then
        handleError(result, errorLocation)
        return nil
    end
    return result
end

local function cleanupObjects()
    local now = os.time()
    if now - lastCleanupTime < cleanupInterval then return end
    lastCleanupTime = now
    for i = #cleanupQueue, 1, -1 do
        local obj = cleanupQueue[i]
        if not obj or not obj.Parent then
            table.remove(cleanupQueue, i)
        end
    end
end

local function generateSecureKey(length)
    local chars = {}
    local charSets = {
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        "abcdefghijklmnopqrstuvwxyz",
        "0123456789",
        "!@#$%^&*()_+-=[]{}|;:,.<>?"
    }
    math.randomseed(os.time())
    for _, set in ipairs(charSets) do
        for i = 1, #set do
            table.insert(chars, set:sub(i, i))
        end
    end
    local key = ""
    for i = 1, length do
        key = key .. chars[math.random(1, #chars)]
    end
    return key
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

local function playSound(id, volume)
    local function play()
        if not id then
            if not soundCache.clickSound then
                soundCache.clickSound = Instance.new("Sound")
                soundCache.clickSound.SoundId = "rbxassetid://6895079853"
                soundCache.clickSound.Volume = volume or 0.25
                soundCache.clickSound.Parent = workspace
                table.insert(cleanupQueue, soundCache.clickSound)
            end
            soundCache.clickSound:Play()
        else
            if not soundCache[id] then
                soundCache[id] = Instance.new("Sound")
                soundCache[id].SoundId = "rbxassetid://"..tostring(id)
                soundCache[id].Volume = volume or 0.25
                soundCache[id].Parent = workspace
                table.insert(cleanupQueue, soundCache[id])
            end
            soundCache[id]:Play()
        end
    end
    safeCall(play, "playSound")
end

local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = deepCopy(v)
        elseif typeof(v) == "Color3" then
            v = {r = v.R, g = v.G, b = v.B}
        end
        copy[k] = v
    end
    return copy
end

local function restoreColor(data)
    if type(data) == "table" and data.r and data.g and data.b then
        return Color3.new(data.r, data.g, data.b)
    end
    return data
end

local function saveSettings()
    ensureFolderStructure()
    local serializedSettings = {
        Configs = settings.Configs,
        PlayerInfo = settings.PlayerInfo,
        System = settings.System
    }
    safeCall(function()
        secureWrite(configFolder.."/"..configFile, HttpService:JSONEncode(serializedSettings))
    end, "saveSettings")
end

local function loadSettings()
    ensureFolderStructure()
    local path = configFolder.."/"..configFile
    if isfile(path) then
        safeCall(function()
            local success, result = pcall(function()
                return HttpService:JSONDecode(readfile(path))
            end)
            if success and result then
                if result.Configs then
                    settings.Configs = result.Configs
                end
                if result.System then
                    settings.System = result.System
                    performanceMode = settings.System.PerformanceMode
                end
            end
        end, "loadSettings")
    end
end

local function saveConfig(configName)
    ensureFolderStructure()
    local configPath = configFolder.."/"..configName..".cfg"
    safeCall(function()
        local serializedSettings = deepCopy(settings)
        secureWrite(configPath, HttpService:JSONEncode(serializedSettings))
        if not table.find(settings.Configs, configName) then
            table.insert(settings.Configs, configName)
            saveSettings()
        end
    end, "saveConfig")
end

local function loadConfig(configName)
    local configPath = configFolder.."/"..configName..".cfg"
    if not isfile(configPath) then return false end
    return safeCall(function()
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(configPath))
        end)
        if success and result then
            settings = table.clone(defaultSettings)
            for category, data in pairs(result) do
                if settings[category] then
                    for key, value in pairs(data) do
                        if settings[category][key] ~= nil then
                            if type(value) == "table" then
                                for subKey, subValue in pairs(value) do
                                    if settings[category][key][subKey] ~= nil then
                                        settings[category][key][subKey] = restoreColor(subValue)
                                    end
                                end
                            else
                                settings[category][key] = restoreColor(value)
                            end
                        end
                    end
                end
            end
            return true
        end
        return false
    end, "loadConfig")
end

local function deleteConfig(configName)
    local configPath = configFolder.."/"..configName..".cfg"
    safeCall(function()
        if isfile(configPath) then
            delfile(configPath)
        end
        local index = table.find(settings.Configs, configName)
        if index then
            table.remove(settings.Configs, index)
            saveSettings()
        end
    end, "deleteConfig")
end

local function scanConfigs()
    ensureFolderStructure()
    local files = listfiles(configFolder)
    local foundConfigs = {}
    safeCall(function()
        for _, file in ipairs(files) do
            if file:sub(-4) == ".cfg" and file ~= configFolder.."/"..configFile then
                local configName = file:match(".*/(.*)%.cfg")
                if configName then
                    table.insert(foundConfigs, configName)
                end
            end
        end
        settings.Configs = foundConfigs
        saveSettings()
    end, "scanConfigs")
    return foundConfigs
end

local function clearAll()
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    connections = {}
    
    for player, _ in pairs(playerConnections) do
        if player and player.Parent then
            for _, conn in pairs(playerConnections[player]) do
                if conn then
                    pcall(function() conn:Disconnect() end)
                end
            end
        end
    end
    playerConnections = {}
    
    for _, espData in pairs(espCache) do
        if espData and espData.box then
            pcall(function() espData.box:Remove() end)
        end
        if espData and espData.distanceText then
            pcall(function() espData.distanceText:Remove() end)
        end
    end
    espCache = {}
    
    for character, box in pairs(hitboxCache) do
        if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                character.HumanoidRootPart.Transparency = 1
                character.HumanoidRootPart.CanCollide = true
            end)
        end
        if box then
            pcall(function() box:Destroy() end)
        end
    end
    hitboxCache = {}
    
    cleanupObjects()
end

local function disableShadows()
    if not settings.System.PerformanceMode then return end
    safeCall(function()
        Lighting.GlobalShadows = false
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CastShadow = false
            end
        end
    end, "disableShadows")
end

local function updateNoClip()
    if LocalPlayer.Character then
        safeCall(function()
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part ~= LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    part.CanCollide = false
                end
            end
        end, "updateNoClip")
    end
end

local function clearHitboxes()
    for character, box in pairs(hitboxCache) do
        if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                character.HumanoidRootPart.Transparency = 1
                character.HumanoidRootPart.CanCollide = true
            end)
        end
        if box then
            pcall(function() box:Destroy() end)
        end
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
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "HitboxAdornment"
        box.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
        box.Adornee = hrp
        box.AlwaysOnTop = false
        box.ZIndex = 0
        box.Transparency = settings.Combat.Hitbox.Transparency
        box.Color3 = settings.Combat.Hitbox.Color
        box.Parent = hrp
        
        hitboxCache[character] = box
        table.insert(cleanupQueue, box)
    end
    
    hrp.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
    hrp.Transparency = 1
    hrp.CanCollide = false
    
    local box = hitboxCache[character]
    if box then
        box.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
        box.Transparency = settings.Combat.Hitbox.Transparency
        box.Color3 = settings.Combat.Hitbox.Color
        box.AlwaysOnTop = false
    end
end

local function createESP(player)
    if not player or player == LocalPlayer then return end
    
    if espCache[player] then
        if espCache[player].box then pcall(function() espCache[player].box:Remove() end) end
        if espCache[player].distanceText then pcall(function() espCache[player].distanceText:Remove() end) end
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
    distanceText.Size = 14
    distanceText.ZIndex = 1
    distanceText.Font = Drawing.Fonts.UI
    distanceText.Outline = true
    
    espCache[player] = {
        box = box,
        distanceText = distanceText
    }
    
    if not playerConnections[player] then
        playerConnections[player] = {}
    end
    
    local function onCharacterAdded(character)
        if not character or not character.Parent then return end
        
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
        
        playerConnections[player].characterRemoving = character.AncestryChanged:Connect(function(_, parent)
            if not parent then
                if espCache[player] then
                    espCache[player].box.Visible = false
                    espCache[player].distanceText.Visible = false
                end
                if hitboxCache[character] then
                    hitboxCache[character]:Destroy()
                    hitboxCache[character] = nil
                end
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
    
    local box = espData.box
    local distanceText = espData.distanceText
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        box.Visible = false
        distanceText.Visible = false
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        box.Visible = false
        distanceText.Visible = false
        return
    end
    
    local head = character:FindFirstChild("Head")
    if not head then
        box.Visible = false
        distanceText.Visible = false
        return
    end
    
    local distance = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        box.Visible = false
        distanceText.Visible = false
        return
    end
    
    local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        box.Visible = false
        distanceText.Visible = false
        return
    end
    
    local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local feetPos = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
    
    local height = (headPos.Y - feetPos.Y)
    local width = height * 0.6
    
    box.Size = Vector2.new(width, height)
    box.Position = Vector2.new(rootPos.X - width/2, feetPos.Y)
    box.Visible = settings.ESP.Enabled
    
    if settings.ESP.ShowDistance then
        distanceText.Text = tostring(math.floor(distance)) .. "m"
        distanceText.Position = Vector2.new(rootPos.X, headPos.Y - 15)
        distanceText.Visible = settings.ESP.Enabled
    else
        distanceText.Visible = false
    end
end

local function clearESP(player)
    if espCache[player] then
        if espCache[player].box then pcall(function() espCache[player].box:Remove() end) end
        if espCache[player].distanceText then pcall(function() espCache[player].distanceText:Remove() end) end
        espCache[player] = nil
    end
    if playerConnections[player] then
        for _, conn in pairs(playerConnections[player]) do
            if conn then
                pcall(function() conn:Disconnect() end)
            end
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
    toggleFrame.Size = UDim2.new(1, -8, 0, 22)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Position = UDim2.new(0, 4, 0, 0)
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextTransparency = 0.1
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local SwitchButton = Instance.new("TextButton")
    SwitchButton.Size = UDim2.new(0.25, 0, 0.65, 0)
    SwitchButton.Position = UDim2.new(0.7, 0, 0.175, 0)
    SwitchButton.BackgroundColor3 = value and Color3.fromRGB(76, 217, 100) or Color3.fromRGB(255, 58, 58)
    SwitchButton.AutoButtonColor = false
    SwitchButton.Text = ""
    SwitchButton.Parent = toggleFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = SwitchButton
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 12, 0, 12)
    ToggleCircle.Position = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.Parent = SwitchButton
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = ToggleCircle
    
    local glow = Instance.new("UIStroke")
    glow.Color = value and Color3.fromRGB(76, 217, 100) or Color3.fromRGB(255, 58, 58)
    glow.Thickness = 1.5
    glow.Transparency = 0.7
    glow.Parent = SwitchButton
    
    SwitchButton.MouseButton1Click:Connect(function()
        playSound()
        value = not value
        
        local circleGoalPos = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        local bgGoalColor = value and Color3.fromRGB(76, 217, 100) or Color3.fromRGB(255, 58, 58)
        
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        TweenService:Create(ToggleCircle, tweenInfo, {Position = circleGoalPos}):Play()
        TweenService:Create(SwitchButton, tweenInfo, {BackgroundColor3 = bgGoalColor}):Play()
        TweenService:Create(glow, tweenInfo, {Color = bgGoalColor}):Play()
        
        callback(value)
        saveSettings()
    end)
    
    if id then
        uiElements[id] = {
            update = function(newValue)
                value = newValue
                local circleGoalPos = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                local bgGoalColor = value and Color3.fromRGB(76, 217, 100) or Color3.fromRGB(255, 58, 58)
                ToggleCircle.Position = circleGoalPos
                SwitchButton.BackgroundColor3 = bgGoalColor
                glow.Color = bgGoalColor
            end
        }
    end
    
    return toggleFrame, SwitchButton
end

local function createValueChanger(parent, text, values, value, callback, id)
    local changerFrame = Instance.new("Frame")
    changerFrame.Size = UDim2.new(1, -8, 0, 22)
    changerFrame.BackgroundTransparency = 1
    changerFrame.Position = UDim2.new(0, 4, 0, 0)
    changerFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextTransparency = 0.1
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = changerFrame
    
    local valueFrame = Instance.new("Frame")
    valueFrame.Size = UDim2.new(0.4, 0, 0.75, 0)
    valueFrame.Position = UDim2.new(0.55, 0, 0.125, 0)
    valueFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    valueFrame.Parent = changerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = valueFrame
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(60, 60, 255)
    glow.Thickness = 1
    glow.Transparency = 0.7
    glow.Parent = valueFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.6, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.2, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = valueFrame
    
    local prevButton = Instance.new("ImageButton")
    prevButton.Size = UDim2.new(0.15, 0, 1, 0)
    prevButton.Position = UDim2.new(0, 0, 0, 0)
    prevButton.BackgroundTransparency = 1
    prevButton.Image = "rbxassetid://12338896667"
    prevButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    prevButton.ImageTransparency = 0.3
    prevButton.Parent = valueFrame
    
    local nextButton = Instance.new("ImageButton")
    nextButton.Size = UDim2.new(0.15, 0, 1, 0)
    nextButton.Position = UDim2.new(0.85, 0, 0, 0)
    nextButton.BackgroundTransparency = 1
    nextButton.Image = "rbxassetid://12338895277"
    nextButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    nextButton.ImageTransparency = 0.3
    nextButton.Parent = valueFrame
    
    local currentIndex = table.find(values, value) or 1
    
    local function updateValue()
        value = values[currentIndex]
        valueLabel.Text = tostring(value)
        callback(value)
        saveSettings()
    end
    
    prevButton.MouseButton1Click:Connect(function()
        playSound()
        currentIndex = currentIndex > 1 and currentIndex - 1 or #values
        updateValue()
    end)
    
    nextButton.MouseButton1Click:Connect(function()
        playSound()
        currentIndex = currentIndex < #values and currentIndex + 1 or 1
        updateValue()
    end)
    
    if id then
        uiElements[id] = {
            update = function(newValue)
                currentIndex = table.find(values, newValue) or 1
                value = values[currentIndex]
                valueLabel.Text = tostring(value)
            end
        }
    end
    
    return changerFrame, valueLabel
end

local function createColorButton(parent, text, value, callback, id)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, -8, 0, 20)
    colorFrame.BackgroundTransparency = 1
    colorFrame.Position = UDim2.new(0, 4, 0, 0)
    colorFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextTransparency = 0.1
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorFrame
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0.25, 0, 0.8, 0)
    colorButton.Position = UDim2.new(0.7, 0, 0.1, 0)
    colorButton.BackgroundColor3 = value
    colorButton.Text = ""
    colorButton.Parent = colorFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = colorButton
    
    local glow = Instance.new("UIStroke")
    glow.Color = value
    glow.Thickness = 1.5
    glow.Transparency = 0.7
    glow.Parent = colorButton
    
    colorButton.MouseButton1Click:Connect(function()
        playSound()
        local currentIndex = table.find(colors, value) or 1
        currentIndex = currentIndex % #colors + 1
        value = colors[currentIndex]
        colorButton.BackgroundColor3 = value
        glow.Color = value
        callback(value)
        saveSettings()
    end)
    
    if id then
        uiElements[id] = {
            update = function(newValue)
                value = newValue
                colorButton.BackgroundColor3 = value
                glow.Color = value
            end
        }
    end
    
    return colorFrame, colorButton
end

local function refreshCombatUI()
    local combatScrollFrame = scrollFrames[1]
    if not combatScrollFrame then return end
    
    for _, child in ipairs(combatScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    createCleanToggle(combatScrollFrame, "Hitbox Enabled", settings.Combat.Hitbox.Enabled, function(value)
        settings.Combat.Hitbox.Enabled = value
        if not value then
            clearHitboxes()
        end
        updateAllESP()
    end, "hitboxEnabled")
    
    local sizeValues = {}
    for i = 1, 10 do table.insert(sizeValues, i) end
    
    createValueChanger(combatScrollFrame, "Hitbox Size", sizeValues, settings.Combat.Hitbox.Size, function(value)
        settings.Combat.Hitbox.Size = value
        updateAllESP()
    end, "hitboxSize")
    
    createColorButton(combatScrollFrame, "Hitbox Color", settings.Combat.Hitbox.Color, function(value)
        settings.Combat.Hitbox.Color = value
        updateAllESP()
    end, "hitboxColor")
    
    createValueChanger(combatScrollFrame, "Hitbox Transparency", transparencies, settings.Combat.Hitbox.Transparency, function(value)
        settings.Combat.Hitbox.Transparency = value
        updateAllESP()
    end, "hitboxTransparency")
end

local function refreshESPUI()
    local espScrollFrame = scrollFrames[2]
    if not espScrollFrame then return end
    
    for _, child in ipairs(espScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    createCleanToggle(espScrollFrame, "ESP Enabled", settings.ESP.Enabled, function(value)
        settings.ESP.Enabled = value
        updateAllESP()
    end, "espEnabled")
    
    createCleanToggle(espScrollFrame, "Show Distance", settings.ESP.ShowDistance, function(value)
        settings.ESP.ShowDistance = value
        updateAllESP()
    end, "espShowDistance")
    
    local distanceValues = {50, 100, 150, 200, 250, 300, 500, 1000}
    createValueChanger(espScrollFrame, "Max Distance", distanceValues, settings.ESP.MaxDistance, function(value)
        settings.ESP.MaxDistance = value
        updateAllESP()
    end, "espMaxDistance")
end

local function refreshConfigUI(scrollFrame)
    for _, button in pairs(configButtons) do
        button:Destroy()
    end
    configButtons = {}
    
    local yOffset = 0
    
    local createConfigFrame = Instance.new("Frame")
    createConfigFrame.Size = UDim2.new(1, -8, 0, 50)
    createConfigFrame.Position = UDim2.new(0, 4, 0, yOffset)
    createConfigFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    createConfigFrame.Parent = scrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = createConfigFrame
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(60, 60, 70)
    glow.Thickness = 1
    glow.Transparency = 0.7
    glow.Parent = createConfigFrame
    
    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(0.6, 0, 0.5, 0)
    nameBox.Position = UDim2.new(0.05, 0, 0.25, 0)
    nameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    nameBox.TextColor3 = Color3.fromRGB(230, 230, 230)
    nameBox.PlaceholderText = "Config Name"
    nameBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    nameBox.Text = ""
    nameBox.TextSize = 14
    nameBox.Font = Enum.Font.Gotham
    nameBox.Parent = createConfigFrame
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 4)
    corner2.Parent = nameBox
    
    local createButton = Instance.new("TextButton")
    createButton.Size = UDim2.new(0.3, 0, 0.5, 0)
    createButton.Position = UDim2.new(0.67, 0, 0.25, 0)
    createButton.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
    createButton.Text = "Save"
    createButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    createButton.TextSize = 14
    createButton.Font = Enum.Font.GothamBold
    createButton.Parent = createConfigFrame
    
    local corner3 = Instance.new("UICorner")
    corner3.CornerRadius = UDim.new(0, 4)
    corner3.Parent = createButton
    
    createButton.MouseButton1Click:Connect(function()
        playSound()
        local configName = nameBox.Text:gsub("%s+", "")
        if configName ~= "" then
            saveConfig(configName)
            nameBox.Text = ""
            refreshConfigUI(scrollFrame)
        end
    end)
    
    yOffset = yOffset + 55
    
    for _, configName in ipairs(settings.Configs) do
        local configFrame = Instance.new("Frame")
        configFrame.Size = UDim2.new(1, -8, 0, 40)
        configFrame.Position = UDim2.new(0, 4, 0, yOffset)
        configFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        configFrame.Parent = scrollFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = configFrame
        
        local glow = Instance.new("UIStroke")
        glow.Color = Color3.fromRGB(60, 60, 70)
        glow.Thickness = 1
        glow.Transparency = 0.7
        glow.Parent = configFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
        nameLabel.Position = UDim2.new(0.05, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = configName
        nameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = configFrame
        
        local loadButton = Instance.new("TextButton")
        loadButton.Size = UDim2.new(0.2, 0, 0.6, 0)
        loadButton.Position = UDim2.new(0.55, 0, 0.2, 0)
        loadButton.BackgroundColor3 = Color3.fromRGB(60, 100, 140)
        loadButton.Text = "Load"
        loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadButton.TextSize = 12
        loadButton.Font = Enum.Font.GothamBold
        loadButton.Parent = configFrame
        
        local corner2 = Instance.new("UICorner")
        corner2.CornerRadius = UDim.new(0, 4)
        corner2.Parent = loadButton
        
        local deleteButton = Instance.new("TextButton")
        deleteButton.Size = UDim2.new(0.2, 0, 0.6, 0)
        deleteButton.Position = UDim2.new(0.77, 0, 0.2, 0)
        deleteButton.BackgroundColor3 = Color3.fromRGB(140, 60, 60)
        deleteButton.Text = "Delete"
        deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        deleteButton.TextSize = 12
        deleteButton.Font = Enum.Font.GothamBold
        deleteButton.Parent = configFrame
        
        local corner3 = Instance.new("UICorner")
        corner3.CornerRadius = UDim.new(0, 4)
        corner3.Parent = deleteButton
        
        loadButton.MouseButton1Click:Connect(function()
            playSound()
            if loadConfig(configName) then
                refreshCombatUI()
                refreshESPUI()
                updateAllESP()
            end
        end)
        
        deleteButton.MouseButton1Click:Connect(function()
            playSound()
            deleteConfig(configName)
            refreshConfigUI(scrollFrame)
        end)
        
        table.insert(configButtons, configFrame)
        yOffset = yOffset + 45
    end
    
    local systemFrame = Instance.new("Frame")
    systemFrame.Size = UDim2.new(1, -8, 0, 40)
    systemFrame.Position = UDim2.new(0, 4, 0, yOffset)
    systemFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    systemFrame.Parent = scrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = systemFrame
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(60, 60, 70)
    glow.Thickness = 1
    glow.Transparency = 0.7
    glow.Parent = systemFrame
    
    createCleanToggle(systemFrame, "Performance Mode", settings.System.PerformanceMode, function(value)
        settings.System.PerformanceMode = value
        performanceMode = value
        if value then
            disableShadows()
        end
        saveSettings()
    end, "performanceMode")
    
    local clearButton = Instance.new("TextButton")
    clearButton.Size = UDim2.new(0.3, 0, 0.6, 0)
    clearButton.Position = UDim2.new(0.65, 0, 0.2, 0)
    clearButton.BackgroundColor3 = Color3.fromRGB(140, 60, 60)
    clearButton.Text = "Clear All"
    clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearButton.TextSize = 12
    clearButton.Font = Enum.Font.GothamBold
    clearButton.Parent = systemFrame
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 4)
    corner2.Parent = clearButton
    
    clearButton.MouseButton1Click:Connect(function()
        playSound()
        clearAll()
    end)
end

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilenceUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = PlayerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    mainFrame.Position = defaultPosition
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(40, 40, 45)
    glow.Thickness = 2
    glow.Transparency = 0.7
    glow.Parent = mainFrame
    
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 30)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 8)
    topCorner.Parent = topBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0.25, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Silence v2.1"
    title.TextColor3 = Color3.fromRGB(230, 230, 230)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = topBar
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -30, 0, 0)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    minimizeButton.TextSize = 16
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = topBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -60, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = topBar
    
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 30)
    tabBar.Position = UDim2.new(0, 0, 0, 30)
    tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -60)
    contentFrame.Position = UDim2.new(0, 0, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    for i = 1, #tabs do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1/#tabs, 0, 1, 0)
        tabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
        tabButton.BackgroundTransparency = 1
        tabButton.Text = tabs[i]
        tabButton.TextColor3 = i == currentTab and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(150, 150, 150)
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = tabBar
        
        tabButton.MouseButton1Click:Connect(function()
            playSound()
            currentTab = i
            for j, frame in ipairs(contentFrames) do
                frame.Visible = j == i
            end
            for j, button in ipairs(tabButtons) do
                button.TextColor3 = j == i and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(150, 150, 150)
            end
        end)
        
        table.insert(tabButtons, tabButton)
        
        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = i == currentTab
        tabContent.Parent = contentFrame
        
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.Position = UDim2.new(0, 0, 0, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Parent = tabContent
        
        table.insert(contentFrames, tabContent)
        table.insert(scrollFrames, scrollFrame)
    end
    
    refreshCombatUI()
    refreshESPUI()
    refreshConfigUI(scrollFrames[3])
    
    minimizeButton.MouseButton1Click:Connect(function()
        playSound()
        isMinimized = not isMinimized
        local goalSize = isMinimized and minimizedSize or UDim2.new(0, menuWidth, 0, menuHeight)
        local goalPosition = isMinimized and minimizedPosition or defaultPosition
        
        TweenService:Create(mainFrame, tweenInfo, {Size = goalSize}):Play()
        TweenService:Create(mainFrame, tweenInfo, {Position = goalPosition}):Play()
        
        for _, frame in ipairs(contentFrames) do
            frame.Visible = not isMinimized
        end
        tabBar.Visible = not isMinimized
        minimizeButton.Text = isMinimized and "+" or "_"
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        playSound()
        isVisible = false
        TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, 0, 0.01, 0)}):Play()
        task.wait(0.15)
        screenGui:Destroy()
        clearAll()
    end)
    
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragInput = nil
                end
            end)
        end
    end)
    
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput then
            update(input)
        end
    end)
    
    return screenGui
end

local function initialize()
    if initialized then return end
    
    ensureFolderStructure()
    loadSettings()
    
    settings.Configs = settings.Configs or {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
        end
    end
    
    connections.playerAdded = Players.PlayerAdded:Connect(function(player)
        createESP(player)
    end)
    
    connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        clearESP(player)
    end)
    
    connections.renderStepped = RunService.RenderStepped:Connect(function()
        updateAllESP()
        updateTimer()
        cleanupObjects()
    end)
    
    connections.heartbeat = RunService.Heartbeat:Connect(function()
        updateNoClip()
    end)
    
    createUI()
    initialized = true
end

local function checkKey()
    return true
end

local function main()
    if not checkKey() then
        return
    end
    
    local success, err = pcall(initialize)
    if not success then
        handleError(err, "main")
    end
end

main()