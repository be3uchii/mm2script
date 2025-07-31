local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 300, 180
local menuX, menuY = (viewportSize.X - menuWidth)/2, (viewportSize.Y - menuHeight)/2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {
    {Name = "Combat", Icon = "⚔️"},
    {Name = "ESP", Icon = "👁️"},
    {Name = "Config", Icon = "⚙️"}
}
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local minimizedSize = UDim2.new(0, 80, 0, 25)
local minimizedPosition = UDim2.new(0.5, -40, 0, 10)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)
local configFolder = "SilenceConfig"
local configFile = "settings.txt"
local lastConfigFile = "last_config.txt"
local theme = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 30),
        TabActive = Color3.fromRGB(80, 80, 120),
        TabInactive = Color3.fromRGB(40, 40, 60),
        Text = Color3.fromRGB(230, 230, 230),
        ToggleOn = Color3.fromRGB(0, 200, 0),
        ToggleOff = Color3.fromRGB(200, 0, 0)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        TabActive = Color3.fromRGB(180, 180, 220),
        TabInactive = Color3.fromRGB(150, 150, 180),
        Text = Color3.fromRGB(30, 30, 30),
        ToggleOn = Color3.fromRGB(0, 180, 0),
        ToggleOff = Color3.fromRGB(180, 0, 0)
    }
}
local currentTheme = "Dark"
local colors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(255, 0, 255),
    Color3.fromRGB(0, 255, 255)
}
local transparencies = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9}
local defaultSettings = {
    PlayerInfo = {
        UserId = LocalPlayer.UserId,
        Name = LocalPlayer.Name,
        AccountAge = LocalPlayer.AccountAge
    },
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 4,
            Color = colors[1],
            Transparency = 0.7,
            Type = "Box",
            ThroughWalls = false,
            Universal = true
        }
    },
    ESP = {
        Enabled = false,
        ShowDistance = false,
        ShowTeam = true,
        TeamColor = Color3.fromRGB(0, 255, 0),
        EnemyColor = Color3.fromRGB(255, 0, 0),
        MaxDistance = 500
    },
    Configs = {},
    UI = {
        Theme = "Dark",
        Animations = true
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
local notifications = {}

local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then copy[k] = deepCopy(v) else copy[k] = v end
    end
    return copy
end

local function notify(text, duration)
    local notification = Instance.new("TextLabel")
    notification.Text = text
    notification.Size = UDim2.new(0, 200, 0, 30)
    notification.Position = UDim2.new(1, -210, 1, -40 - #notifications * 35)
    notification.BackgroundColor3 = currentTheme == "Dark" and Color3.fromRGB(40, 40, 50) or Color3.fromRGB(200, 200, 210)
    notification.TextColor3 = theme[currentTheme].Text
    notification.Parent = PlayerGui:WaitForChild("SilenceGui")
    table.insert(notifications, notification)
    task.delay(duration or 3, function()
        notification:Destroy()
        table.remove(notifications, table.find(notifications, notification))
    end)
end

local function ensureConfigFolder()
    if not isfolder(configFolder) then makefolder(configFolder) end
end

local function saveSettings()
    ensureConfigFolder()
    local tempPath = configFolder.."/temp_"..configFile
    local finalPath = configFolder.."/"..configFile
    local serializedSettings = {Configs = settings.Configs, PlayerInfo = settings.PlayerInfo}
    writefile(tempPath, HttpService:JSONEncode(serializedSettings))
    if isfile(finalPath) then delfile(finalPath) end
    writefile(finalPath, readfile(tempPath))
    delfile(tempPath)
end

local function loadSettings()
    ensureConfigFolder()
    local path = configFolder.."/"..configFile
    if isfile(path) then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if success and result and result.Configs then settings.Configs = result.Configs end
    end
end

local function saveConfig(configName)
    ensureConfigFolder()
    local configPath = configFolder.."/"..configName..".txt"
    writefile(configPath, HttpService:JSONEncode(deepCopy(settings)))
    if not table.find(settings.Configs, configName) then
        table.insert(settings.Configs, configName)
        saveSettings()
    end
    writefile(configFolder.."/"..lastConfigFile, configName)
end

local function loadConfig(configName)
    local configPath = configFolder.."/"..configName..".txt"
    if not isfile(configPath) then return false end
    local success, result = pcall(function() return HttpService:JSONDecode(readfile(configPath)) end)
    if success and result then
        settings = table.clone(defaultSettings)
        for category, data in pairs(result) do
            if settings[category] then
                for key, value in pairs(data) do
                    if settings[category][key] ~= nil then
                        if type(value) == "table" then
                            for subKey, subValue in pairs(value) do
                                if settings[category][key][subKey] ~= nil then
                                    settings[category][key][subKey] = subValue
                                end
                            end
                        else
                            settings[category][key] = value
                        end
                    end
                end
            end
        end
        currentTheme = settings.UI.Theme or "Dark"
        return true
    end
    return false
end

local function exportConfig(configName)
    local configPath = configFolder.."/"..configName..".txt"
    if not isfile(configPath) then return nil end
    local data = readfile(configPath)
    return HttpService:JSONEncode({name = configName, data = data})
end

local function importConfig(importString)
    local success, decoded = pcall(function() return HttpService:JSONDecode(importString) end)
    if not success or not decoded.name or not decoded.data then return false end
    ensureConfigFolder()
    local configPath = configFolder.."/"..decoded.name..".txt"
    writefile(configPath, decoded.data)
    if not table.find(settings.Configs, decoded.name) then
        table.insert(settings.Configs, decoded.name)
        saveSettings()
    end
    return true
end

local function scanConfigs()
    ensureConfigFolder()
    local files = listfiles(configFolder)
    local foundConfigs = {}
    for _, file in ipairs(files) do
        if file:sub(-4) == ".txt" and file ~= configFolder.."/"..configFile and file ~= configFolder.."/"..lastConfigFile then
            local configName = file:match(".*/(.*)%.txt")
            if configName then table.insert(foundConfigs, configName) end
        end
    end
    settings.Configs = foundConfigs
    saveSettings()
    return foundConfigs
end

local function clearAll()
    for _, conn in pairs(connections) do if conn then pcall(function() conn:Disconnect() end) end end
    connections = {}
    for player, _ in pairs(playerConnections) do
        if player and player.Parent then
            for _, conn in pairs(playerConnections[player]) do
                if conn then pcall(function() conn:Disconnect() end) end
            end
        end
    end
    playerConnections = {}
    for _, espData in pairs(espCache) do
        if espData and espData.box then pcall(function() espData.box:Remove() end) end
        if espData and espData.distanceText then pcall(function() espData.distanceText:Remove() end) end
    end
    espCache = {}
    for character, box in pairs(hitboxCache) do
        if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            character.HumanoidRootPart.Transparency = 1
            character.HumanoidRootPart.CanCollide = true
        end
        if box then pcall(function() box:Destroy() end) end
    end
    hitboxCache = {}
end

local function updateHitbox(character)
    if not settings.Combat.Hitbox.Enabled then
        if hitboxCache[character] then hitboxCache[character]:Destroy() hitboxCache[character] = nil end
        return 
    end
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
        if hitboxCache[character] then hitboxCache[character]:Destroy() hitboxCache[character] = nil end
        return 
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        if hitboxCache[character] then hitboxCache[character]:Destroy() hitboxCache[character] = nil end
        return 
    end
    if not settings.Combat.Hitbox.Universal and not hrp:FindFirstChild("HitboxAdornment") then return end
    if (hrp.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > settings.ESP.MaxDistance then
        if hitboxCache[character] then hitboxCache[character]:Destroy() hitboxCache[character] = nil end
        return
    end
    if not hitboxCache[character] then
        local box = settings.Combat.Hitbox.Type == "Sphere" and Instance.new("SphereHandleAdornment") or Instance.new("BoxHandleAdornment")
        box.Name = "HitboxAdornment"
        box.Adornee = hrp
        box.AlwaysOnTop = settings.Combat.Hitbox.ThroughWalls
        box.ZIndex = 0
        box.Transparency = settings.Combat.Hitbox.Transparency
        box.Color3 = settings.Combat.Hitbox.Color
        box.Parent = hrp
        hitboxCache[character] = box
    end
    local box = hitboxCache[character]
    if settings.Combat.Hitbox.Type == "Sphere" then
        box.Radius = settings.Combat.Hitbox.Size * 1.2
        hrp.Size = Vector3.new(box.Radius, box.Radius, box.Radius)
    else
        box.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
        hrp.Size = box.Size
    end
    hrp.Transparency = 1
    hrp.CanCollide = false
    box.Transparency = settings.Combat.Hitbox.Transparency
    box.Color3 = settings.Combat.Hitbox.Color
    box.AlwaysOnTop = settings.Combat.Hitbox.ThroughWalls
end

local function createESP(player)
    if not player or player == LocalPlayer then return end
    if espCache[player] then
        if espCache[player].box then pcall(function() espCache[player].box:Remove() end) end
        if espCache[player].distanceText then pcall(function() espCache[player].distanceText:Remove() end) end
    end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 2
    box.Filled = false
    box.ZIndex = 1
    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Size = 14
    distanceText.ZIndex = 1
    espCache[player] = {box = box, distanceText = distanceText}
    if not playerConnections[player] then playerConnections[player] = {} end
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        playerConnections[player].died = humanoid.Died:Connect(function()
            if espCache[player] then
                espCache[player].box.Visible = false
                espCache[player].distanceText.Visible = false
            end
            if hitboxCache[character] then hitboxCache[character]:Destroy() hitboxCache[character] = nil end
        end)
    end
    if player.Character then onCharacterAdded(player.Character) end
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
    local head = character:FindFirstChild("Head")
    if not humanoidRootPart or not head then
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
    box.Color = player.Team == LocalPlayer.Team and settings.ESP.TeamColor or settings.ESP.EnemyColor
    if settings.ESP.ShowDistance then
        distanceText.Text = tostring(math.floor(distance)) .. "m"
        distanceText.Position = Vector2.new(rootPos.X, headPos.Y - 20)
        distanceText.Visible = settings.ESP.Enabled
        distanceText.Color = box.Color
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
        for _, conn in pairs(playerConnections[player]) do if conn then pcall(function() conn:Disconnect() end) end end
        playerConnections[player] = nil
    end
end

local function updateAllESP()
    for player, _ in pairs(espCache) do updateESP(player) end
    if settings.Combat.Hitbox.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then updateHitbox(player.Character) end
        end
    else
        clearHitboxes()
    end
end

local function createToggle(parent, text, value, callback, id)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -8, 0, 20)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Position = UDim2.new(0, 4, 0, 0)
    toggleFrame.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme[currentTheme].Text
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.3, 0, 0.9, 0)
    toggle.Position = UDim2.new(0.7, 0, 0.05, 0)
    toggle.BackgroundColor3 = value and theme[currentTheme].ToggleOn or theme[currentTheme].ToggleOff
    toggle.Text = value and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 10
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = toggleFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = toggle
    toggle.MouseButton1Click:Connect(function()
        value = not value
        toggle.Text = value and "ON" or "OFF"
        toggle.BackgroundColor3 = value and theme[currentTheme].ToggleOn or theme[currentTheme].ToggleOff
        callback(value)
        saveSettings()
        notify(text.." "..(value and "enabled" or "disabled"))
    end)
    if id then
        uiElements[id] = {
            update = function(newValue)
                value = newValue
                toggle.Text = value and "ON" or "OFF"
                toggle.BackgroundColor3 = value and theme[currentTheme].ToggleOn or theme[currentTheme].ToggleOff
            end
        }
    end
    return toggleFrame, toggle
end

local function createValueChanger(parent, text, values, value, callback, id)
    local changerFrame = Instance.new("Frame")
    changerFrame.Size = UDim2.new(1, -8, 0, 20)
    changerFrame.BackgroundTransparency = 1
    changerFrame.Position = UDim2.new(0, 4, 0, 0)
    changerFrame.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme[currentTheme].Text
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = changerFrame
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = theme[currentTheme].Text
    valueLabel.TextTransparency = 0.1
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = changerFrame
    local prevButton = Instance.new("TextButton")
    prevButton.Size = UDim2.new(0.1, 0, 0.9, 0)
    prevButton.Position = UDim2.new(0.7, 0, 0.05, 0)
    prevButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    prevButton.Text = "<"
    prevButton.TextColor3 = theme[currentTheme].Text
    prevButton.TextSize = 10
    prevButton.Font = Enum.Font.GothamBold
    prevButton.Parent = changerFrame
    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.new(0.1, 0, 0.9, 0)
    nextButton.Position = UDim2.new(0.85, 0, 0.05, 0)
    nextButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    nextButton.Text = ">"
    nextButton.TextColor3 = theme[currentTheme].Text
    nextButton.TextSize = 10
    nextButton.Font = Enum.Font.GothamBold
    nextButton.Parent = changerFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = prevButton
    corner:Clone().Parent = nextButton
    local currentIndex = table.find(values, value) or 1
    local function updateValue()
        value = values[currentIndex]
        valueLabel.Text = tostring(value)
        callback(value)
        saveSettings()
        notify(text.." set to "..tostring(value))
    end
    prevButton.MouseButton1Click:Connect(function()
        currentIndex = currentIndex > 1 and currentIndex - 1 or #values
        updateValue()
    end)
    nextButton.MouseButton1Click:Connect(function()
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
    label.TextColor3 = theme[currentTheme].Text
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorFrame
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0.3, 0, 0.9, 0)
    colorButton.Position = UDim2.new(0.7, 0, 0.05, 0)
    colorButton.BackgroundColor3 = value
    colorButton.Text = ""
    colorButton.Parent = colorFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = colorButton
    colorButton.MouseButton1Click:Connect(function()
        local currentIndex = table.find(colors, value) or 1
        currentIndex = currentIndex % #colors + 1
        value = colors[currentIndex]
        colorButton.BackgroundColor3 = value
        callback(value)
        saveSettings()
        notify(text.." changed")
    end)
    if id then
        uiElements[id] = {
            update = function(newValue)
                value = newValue
                colorButton.BackgroundColor3 = value
            end
        }
    end
    return colorFrame, colorButton
end

local function refreshCombatUI()
    local combatScrollFrame = scrollFrames[1]
    if not combatScrollFrame then return end
    for _, child in ipairs(combatScrollFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    createToggle(combatScrollFrame, "Hitbox Enabled", settings.Combat.Hitbox.Enabled, function(value)
        settings.Combat.Hitbox.Enabled = value
        if not value then clearHitboxes() end
        updateAllESP()
    end, "hitboxEnabled")
    local sizeValues = {} for i = 1, 8 do table.insert(sizeValues, i) end
    createValueChanger(combatScrollFrame, "Hitbox Size", sizeValues, settings.Combat.Hitbox.Size, function(value)
        settings.Combat.Hitbox.Size = value
        updateAllESP()
    end, "hitboxSize")
    createToggle(combatScrollFrame, "Sphere Hitbox", settings.Combat.Hitbox.Type == "Sphere", function(value)
        settings.Combat.Hitbox.Type = value and "Sphere" or "Box"
        clearHitboxes()
        updateAllESP()
    end, "hitboxType")
    createToggle(combatScrollFrame, "Through Walls", settings.Combat.Hitbox.ThroughWalls, function(value)
        settings.Combat.Hitbox.ThroughWalls = value
        updateAllESP()
    end, "hitboxThroughWalls")
    createToggle(combatScrollFrame, "Universal Hitbox", settings.Combat.Hitbox.Universal, function(value)
        settings.Combat.Hitbox.Universal = value
        updateAllESP()
    end, "hitboxUniversal")
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
    for _, child in ipairs(espScrollFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    createToggle(espScrollFrame, "ESP Enabled", settings.ESP.Enabled, function(value)
        settings.ESP.Enabled = value
        updateAllESP()
    end, "espEnabled")
    createToggle(espScrollFrame, "Show Distance", settings.ESP.ShowDistance, function(value)
        settings.ESP.ShowDistance = value
        updateAllESP()
    end, "espShowDistance")
    createToggle(espScrollFrame, "Show Team", settings.ESP.ShowTeam, function(value)
        settings.ESP.ShowTeam = value
        updateAllESP()
    end, "espShowTeam")
    createColorButton(espScrollFrame, "Team Color", settings.ESP.TeamColor, function(value)
        settings.ESP.TeamColor = value
        updateAllESP()
    end, "espTeamColor")
    createColorButton(espScrollFrame, "Enemy Color", settings.ESP.EnemyColor, function(value)
        settings.ESP.EnemyColor = value
        updateAllESP()
    end, "espEnemyColor")
    local distanceValues = {100, 200, 300, 500, 1000}
    createValueChanger(espScrollFrame, "Max Distance", distanceValues, settings.ESP.MaxDistance, function(value)
        settings.ESP.MaxDistance = value
        updateAllESP()
    end, "espMaxDistance")
end

local function refreshConfigUI(scrollFrame)
    for _, button in pairs(configButtons) do button:Destroy() end
    configButtons = {}
    local yOffset = 0
    local createConfigFrame = Instance.new("Frame")
    createConfigFrame.Size = UDim2.new(1, -8, 0, 50)
    createConfigFrame.Position = UDim2.new(0, 4, 0, yOffset)
    createConfigFrame.BackgroundColor3 = theme[currentTheme].TabInactive
    createConfigFrame.BackgroundTransparency = 0.1
    createConfigFrame.Parent = scrollFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = createConfigFrame
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.7, 0, 0.6, 0)
    textBox.Position = UDim2.new(0.05, 0, 0.2, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    textBox.TextColor3 = theme[currentTheme].Text
    textBox.PlaceholderText = "Config name"
    textBox.Text = ""
    textBox.ClearTextOnFocus = false
    textBox.Parent = createConfigFrame
    local createButton = Instance.new("TextButton")
    createButton.Size = UDim2.new(0.2, 0, 0.6, 0)
    createButton.Position = UDim2.new(0.75, 0, 0.2, 0)
    createButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    createButton.Text = "Create"
    createButton.TextColor3 = theme[currentTheme].Text
    createButton.Parent = createConfigFrame
    corner:Clone().Parent = textBox
    corner:Clone().Parent = createButton
    createButton.MouseButton1Click:Connect(function()
        if textBox.Text ~= "" then
            saveConfig(textBox.Text)
            scanConfigs()
            refreshConfigUI(scrollFrame)
            textBox.Text = ""
            notify("Config saved: "..textBox.Text)
        end
    end)
    table.insert(configButtons, createConfigFrame)
    yOffset = yOffset + 55
    local exportFrame = Instance.new("Frame")
    exportFrame.Size = UDim2.new(1, -8, 0, 40)
    exportFrame.Position = UDim2.new(0, 4, 0, yOffset)
    exportFrame.BackgroundColor3 = theme[currentTheme].TabInactive
    exportFrame.BackgroundTransparency = 0.1
    exportFrame.Parent = scrollFrame
    corner:Clone().Parent = exportFrame
    local exportButton = Instance.new("TextButton")
    exportButton.Size = UDim2.new(0.45, 0, 0.8, 0)
    exportButton.Position = UDim2.new(0.025, 0, 0.1, 0)
    exportButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    exportButton.Text = "Export to Clipboard"
    exportButton.TextColor3 = theme[currentTheme].Text
    exportButton.Parent = exportFrame
    local importButton = Instance.new("TextButton")
    importButton.Size = UDim2.new(0.45, 0, 0.8, 0)
    importButton.Position = UDim2.new(0.525, 0, 0.1, 0)
    importButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    importButton.Text = "Import from Clipboard"
    importButton.TextColor3 = theme[currentTheme].Text
    importButton.Parent = exportFrame
    corner:Clone().Parent = exportButton
    corner:Clone().Parent = importButton
    exportButton.MouseButton1Click:Connect(function()
        local configName = getclipboard()
        if configName and table.find(settings.Configs, configName) then
            local exportStr = exportConfig(configName)
            if exportStr then
                setclipboard(exportStr)
                notify("Config exported to clipboard")
            end
        end
    end)
    importButton.MouseButton1Click:Connect(function()
        local importStr = getclipboard()
        if importStr and importConfig(importStr) then
            scanConfigs()
            refreshConfigUI(scrollFrame)
            notify("Config imported successfully")
        end
    end)
    table.insert(configButtons, exportFrame)
    yOffset = yOffset + 45
    local themeFrame = Instance.new("Frame")
    themeFrame.Size = UDim2.new(1, -8, 0, 40)
    themeFrame.Position = UDim2.new(0, 4, 0, yOffset)
    themeFrame.BackgroundColor3 = theme[currentTheme].TabInactive
    themeFrame.BackgroundTransparency = 0.1
    themeFrame.Parent = scrollFrame
    corner:Clone().Parent = themeFrame
    local darkButton = Instance.new("TextButton")
    darkButton.Size = UDim2.new(0.45, 0, 0.8, 0)
    darkButton.Position = UDim2.new(0.025, 0, 0.1, 0)
    darkButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    darkButton.Text = "Dark Theme"
    darkButton.TextColor3 = theme[currentTheme].Text
    darkButton.Parent = themeFrame
    local lightButton = Instance.new("TextButton")
    lightButton.Size = UDim2.new(0.45, 0, 0.8, 0)
    lightButton.Position = UDim2.new(0.525, 0, 0.1, 0)
    lightButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    lightButton.Text = "Light Theme"
    lightButton.TextColor3 = theme[currentTheme].Text
    lightButton.Parent = themeFrame
    corner:Clone().Parent = darkButton
    corner:Clone().Parent = lightButton
    darkButton.MouseButton1Click:Connect(function()
        settings.UI.Theme = "Dark"
        currentTheme = "Dark"
        saveSettings()
        createMainGUI()
        notify("Theme set to Dark")
    end)
    lightButton.MouseButton1Click:Connect(function()
        settings.UI.Theme = "Light"
        currentTheme = "Light"
        saveSettings()
        createMainGUI()
        notify("Theme set to Light")
    end)
    table.insert(configButtons, themeFrame)
    yOffset = yOffset + 45
    for _, configName in ipairs(scanConfigs()) do
        local configFrame = Instance.new("Frame")
        configFrame.Size = UDim2.new(1, -8, 0, 40)
        configFrame.Position = UDim2.new(0, 4, 0, yOffset)
        configFrame.BackgroundColor3 = theme[currentTheme].TabInactive
        configFrame.BackgroundTransparency = 0.1
        configFrame.Parent = scrollFrame
        corner:Clone().Parent = configFrame
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = configName
        nameLabel.TextColor3 = theme[currentTheme].Text
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = configFrame
        local loadButton = Instance.new("TextButton")
        loadButton.Size = UDim2.new(0.15, 0, 0.7, 0)
        loadButton.Position = UDim2.new(0.65, 0, 0.15, 0)
        loadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        loadButton.Text = "Load"
        loadButton.TextColor3 = theme[currentTheme].Text
        loadButton.Parent = configFrame
        local deleteButton = Instance.new("TextButton")
        deleteButton.Size = UDim2.new(0.15, 0, 0.7, 0)
        deleteButton.Position = UDim2.new(0.85, 0, 0.15, 0)
        deleteButton.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
        deleteButton.Text = "Delete"
        deleteButton.TextColor3 = theme[currentTheme].Text
        deleteButton.Parent = configFrame
        corner:Clone().Parent = loadButton
        corner:Clone().Parent = deleteButton
        loadButton.MouseButton1Click:Connect(function()
            if loadConfig(configName) then
                for id, element in pairs(uiElements) do
                    if id == "hitboxEnabled" then element.update(settings.Combat.Hitbox.Enabled)
                    elseif id == "hitboxSize" then element.update(settings.Combat.Hitbox.Size)
                    elseif id == "hitboxType" then element.update(settings.Combat.Hitbox.Type == "Sphere")
                    elseif id == "hitboxThroughWalls" then element.update(settings.Combat.Hitbox.ThroughWalls)
                    elseif id == "hitboxUniversal" then element.update(settings.Combat.Hitbox.Universal)
                    elseif id == "hitboxColor" then element.update(settings.Combat.Hitbox.Color)
                    elseif id == "hitboxTransparency" then element.update(settings.Combat.Hitbox.Transparency)
                    elseif id == "espEnabled" then element.update(settings.ESP.Enabled)
                    elseif id == "espShowDistance" then element.update(settings.ESP.ShowDistance)
                    elseif id == "espShowTeam" then element.update(settings.ESP.ShowTeam)
                    elseif id == "espTeamColor" then element.update(settings.ESP.TeamColor)
                    elseif id == "espEnemyColor" then element.update(settings.ESP.EnemyColor)
                    elseif id == "espMaxDistance" then element.update(settings.ESP.MaxDistance) end
                end
                updateAllESP()
                notify("Config loaded: "..configName)
            end
        end)
        deleteButton.MouseButton1Click:Connect(function()
            deleteConfig(configName)
            scanConfigs()
            refreshConfigUI(scrollFrame)
            notify("Config deleted: "..configName)
        end)
        table.insert(configButtons, configFrame)
        yOffset = yOffset + 45
    end
end

local function createMainGUI()
    clearAll()
    settings = table.clone(defaultSettings)
    loadSettings()
    scanConfigs()
    if PlayerGui:FindFirstChild("SilenceGui") then PlayerGui.SilenceGui:Destroy() wait(0.1) end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilenceGui"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Enabled = isVisible
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    mainFrame.Position = defaultPosition
    mainFrame.BackgroundColor3 = theme[currentTheme].Background
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(60, 60, 255)
    uiStroke.Thickness = 2
    uiStroke.Transparency = 0.1
    uiStroke.Parent = mainFrame
    local dragArea = Instance.new("TextButton")
    dragArea.Size = UDim2.new(1, 0, 0, 24)
    dragArea.BackgroundTransparency = 1
    dragArea.Text = "Silence 5.0 "..(isMinimized and "" or "| "..tabs[currentTab].Icon)
    dragArea.TextColor3 = theme[currentTheme].Text
    dragArea.TextTransparency = 0.1
    dragArea.TextSize = isMinimized and 12 or 14
    dragArea.Font = Enum.Font.GothamBold
    dragArea.TextXAlignment = Enum.TextXAlignment.Center
    dragArea.Parent = mainFrame
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 24)
    tabContainer.Position = UDim2.new(0, 0, 0, 24)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    for i, tab in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1 / #tabs, -4, 1, -4)
        tabButton.Position = UDim2.new((i - 1) / #tabs, 2, 0, 2)
        tabButton.BackgroundColor3 = i == currentTab and theme[currentTheme].TabActive or theme[currentTheme].TabInactive
        tabButton.BackgroundTransparency = 0.1
        tabButton.Text = isMinimized and tab.Icon or tab.Name
        tabButton.TextColor3 = theme[currentTheme].Text
        tabButton.TextTransparency = 0.1
        tabButton.TextSize = isMinimized and 14 or 12
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Parent = tabContainer
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        tabButtons[i] = tabButton
        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, -8, 1, -52)
        contentFrame.Position = UDim2.new(0, 4, 0, 52)
        contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        contentFrame.BackgroundTransparency = 0.1
        contentFrame.Visible = i == currentTab
        contentFrame.Parent = mainFrame
        local contentCorner = Instance.new("UICorner")
        contentCorner.CornerRadius = UDim.new(0, 6)
        contentCorner.Parent = contentFrame
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 255)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Parent = contentFrame
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 3)
        layout.Parent = scrollFrame
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
        end)
        contentFrames[i] = contentFrame
        scrollFrames[i] = scrollFrame
        if tab.Name == "Combat" then refreshCombatUI()
        elseif tab.Name == "ESP" then refreshESPUI()
        elseif tab.Name == "Config" then refreshConfigUI(scrollFrame) end
        tabButton.MouseButton1Click:Connect(function()
            currentTab = i
            for j, frame in ipairs(contentFrames) do frame.Visible = j == i end
            for j, btn in ipairs(tabButtons) do
                btn.BackgroundColor3 = j == currentTab and theme[currentTheme].TabActive or theme[currentTheme].TabInactive
                btn.Text = isMinimized and tabs[j].Icon or tabs[j].Name
            end
            dragArea.Text = "Silence 5.0 "..(isMinimized and "" or "| "..tabs[currentTab].Icon)
            if tab.Name == "Config" then refreshConfigUI(scrollFrame) end
        end)
    end
    local function tweenFrame(frame, size, position)
        if settings.UI.Animations then
            local sizeTween = TweenService:Create(frame, tweenInfo, {Size = size})
            local positionTween = TweenService:Create(frame, tweenInfo, {Position = position})
            sizeTween:Play()
            positionTween:Play()
        else
            frame.Size = size
            frame.Position = position
        end
    end
    dragArea.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and minimizedSize or UDim2.new(0, menuWidth, 0, menuHeight)
        local targetPosition = isMinimized and minimizedPosition or defaultPosition
        tweenFrame(mainFrame, targetSize, targetPosition)
        tabContainer.Visible = not isMinimized
        for _, frame in ipairs(contentFrames) do frame.Visible = not isMinimized and frame == contentFrames[currentTab] end
        for _, btn in ipairs(tabButtons) do
            btn.Text = isMinimized and tabs[btn].Icon or tabs[btn].Name
        end
        dragArea.Text = "Silence 5.0 "..(isMinimized and "" or "| "..tabs[currentTab].Icon)
        dragArea.TextSize = isMinimized and 12 or 14
    end)
    local dragging = false
    local dragStart, frameStart
    dragArea.MouseButton1Down:Connect(function()
        dragging = true
        dragStart = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        frameStart = mainFrame.Position
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - dragStart
            mainFrame.Position = UDim2.new(0, frameStart.X.Offset + delta.X, 0, frameStart.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    connections.InputBegan = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            isVisible = not isVisible
            screenGui.Enabled = isVisible
            if isVisible then updateAllESP() end
            notify("Menu "..(isVisible and "shown" or "hidden"))
        end
    end)
    local function handlePlayerAdded(player)
        if player ~= LocalPlayer then createESP(player) end
    end
    for _, player in ipairs(Players:GetPlayers()) do handlePlayerAdded(player) end
    connections.PlayerAdded = Players.PlayerAdded:Connect(handlePlayerAdded)
    connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player) clearESP(player) end)
    connections.RenderStep = RunService.RenderStepped:Connect(function()
        if isVisible then
            for player, _ in pairs(espCache) do if player ~= LocalPlayer then updateESP(player) end end
            if settings.Combat.Hitbox.Enabled then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then updateHitbox(player.Character) end
                end
            else clearHitboxes() end
        end
    end)
    return screenGui
end

local screenGui = createMainGUI()
game:BindToClose(function() clearAll() if screenGui then screenGui:Destroy() end end)