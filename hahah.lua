local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 270, 160
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Config", "Music"}
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local minimizedSize = UDim2.new(0, 80, 0, 25)
local minimizedPosition = UDim2.new(0.5, -40, 0, 10)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)

local configFolder = "SilenceConfig"
local configFile = "settings.txt"

local tabIcons = {
    ["Combat"] = "rbxassetid://126193793480527",
    ["ESP"] = "rbxassetid://6523858394",
    ["Config"] = "rbxassetid://7059346373",
    ["Music"] = "rbxassetid://7059338404"
}

local colors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(255, 0, 255),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(255, 128, 0),
    Color3.fromRGB(255, 0, 128),
    Color3.fromRGB(128, 0, 255),
    Color3.fromRGB(0, 255, 128),
    Color3.fromRGB(128, 255, 0),
    Color3.fromRGB(255, 128, 128),
    Color3.fromRGB(128, 255, 128),
    Color3.fromRGB(128, 128, 255),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(0, 0, 0),
    Color3.fromRGB(64, 64, 64),
    Color3.fromRGB(128, 128, 128),
    Color3.fromRGB(192, 192, 192),
    Color3.fromRGB(255, 64, 64),
    Color3.fromRGB(64, 255, 64),
    Color3.fromRGB(64, 64, 255),
    Color3.fromRGB(255, 128, 64),
    Color3.fromRGB(255, 64, 128),
    Color3.fromRGB(128, 64, 255),
    Color3.fromRGB(64, 255, 128),
    Color3.fromRGB(128, 255, 64),
    Color3.fromRGB(255, 192, 128),
    Color3.fromRGB(255, 128, 192),
    Color3.fromRGB(192, 128, 255)
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
            ThroughWalls = false
        }
    },
    ESP = {
        Enabled = false,
        ShowDistance = false,
        MaxDistance = 160
    },
    Configs = {},
    Music = {
        Volume = 1.0,
        CurrentTrack = 1,
        Enabled = false
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

-- Music player variables
local musicPlayer = {
    sounds = {
        "rbxassetid://142376088",
        "rbxassetid://118939739460633", 
        "rbxassetid://5409360995"
    },
    currentTrack = 1,
    sound = nil,
    soundLength = 0,
    isPlaying = false,
    connection = nil,
    clickSound = nil,
    playButton = nil,
    pauseButton = nil,
    prevButton = nil,
    nextButton = nil,
    timeText = nil,
    progressFill = nil
}

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

local function ensureConfigFolder()
    if not isfolder(configFolder) then
        makefolder(configFolder)
    end
end

local function saveSettings()
    ensureConfigFolder()
    local tempPath = configFolder.."/temp_"..configFile
    local finalPath = configFolder.."/"..configFile
    
    local serializedSettings = {Configs = settings.Configs, PlayerInfo = settings.PlayerInfo, Music = settings.Music}
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
        
        if success and result then
            if result.Configs then settings.Configs = result.Configs end
            if result.Music then
                settings.Music.Volume = result.Music.Volume or 1.0
                settings.Music.CurrentTrack = result.Music.CurrentTrack or 1
                settings.Music.Enabled = result.Music.Enabled or false
            end
        end
    end
end

local function saveConfig(configName)
    ensureConfigFolder()
    local configPath = configFolder.."/"..configName..".txt"
    local serializedSettings = deepCopy(settings)
    writefile(configPath, HttpService:JSONEncode(serializedSettings))
    
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
            character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            character.HumanoidRootPart.Transparency = 1
            character.HumanoidRootPart.CanCollide = true
        end
        if box then
            pcall(function() box:Destroy() end)
        end
    end
    hitboxCache = {}
    
    if musicPlayer.sound then
        musicPlayer.sound:Stop()
        musicPlayer.sound:Destroy()
    end
    if musicPlayer.clickSound then
        musicPlayer.clickSound:Stop()
        musicPlayer.clickSound:Destroy()
    end
    if musicPlayer.connection then
        musicPlayer.connection:Disconnect()
    end
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
        local box
        if settings.Combat.Hitbox.Type == "Sphere" then
            box = Instance.new("SphereHandleAdornment")
            box.Radius = settings.Combat.Hitbox.Size * 1.2
        else
            box = Instance.new("BoxHandleAdornment")
            box.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
        end
        
        box.Name = "HitboxAdornment"
        box.Adornee = hrp
        box.AlwaysOnTop = settings.Combat.Hitbox.ThroughWalls
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
    
    local box = hitboxCache[character]
    if box then
        if settings.Combat.Hitbox.Type == "Sphere" then
            box.Radius = settings.Combat.Hitbox.Size * 1.2
        else
            box.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
        end
        box.Transparency = settings.Combat.Hitbox.Transparency
        box.Color3 = settings.Combat.Hitbox.Color
        box.AlwaysOnTop = settings.Combat.Hitbox.ThroughWalls
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
    distanceText.Color = Color3.new(1, 1, 1)
    distanceText.Size = 14
    distanceText.ZIndex = 1
    
    espCache[player] = {
        box = box,
        distanceText = distanceText
    }
    
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
        distanceText.Position = Vector2.new(rootPos.X, headPos.Y - 20)
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
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.3, 0, 0.9, 0)
    toggle.Position = UDim2.new(0.7, 0, 0.05, 0)
    toggle.BackgroundColor3 = value and Color3.fromRGB(0, 230, 0) or Color3.fromRGB(230, 0, 0)
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
        toggle.BackgroundColor3 = value and Color3.fromRGB(0, 230, 0) or Color3.fromRGB(230, 0, 0)
        callback(value)
        saveSettings()
    end)
    
    if id then
        uiElements[id] = {
            update = function(newValue)
                value = newValue
                toggle.Text = value and "ON" or "OFF"
                toggle.BackgroundColor3 = value and Color3.fromRGB(0, 230, 0) or Color3.fromRGB(230, 0, 0)
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
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
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
    valueLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
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
    prevButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    prevButton.TextSize = 10
    prevButton.Font = Enum.Font.GothamBold
    prevButton.Parent = changerFrame
    
    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.new(0.1, 0, 0.9, 0)
    nextButton.Position = UDim2.new(0.85, 0, 0.05, 0)
    nextButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    nextButton.Text = ">"
    nextButton.TextColor3 = Color3.fromRGB(230, 230, 230)
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
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
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
    
    for _, child in ipairs(combatScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    createToggle(combatScrollFrame, "Hitbox Enabled", settings.Combat.Hitbox.Enabled, function(value)
        settings.Combat.Hitbox.Enabled = value
        if not value then
            clearHitboxes()
        end
        updateAllESP()
    end, "hitboxEnabled")
    
    local sizeValues = {}
    for i = 1, 8 do table.insert(sizeValues, i) end
    
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
    
    createToggle(espScrollFrame, "ESP Enabled", settings.ESP.Enabled, function(value)
        settings.ESP.Enabled = value
        updateAllESP()
    end, "espEnabled")
    
    createToggle(espScrollFrame, "Show Distance", settings.ESP.ShowDistance, function(value)
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
    createConfigFrame.Size = UDim2.new(1, -8, 0, 50)
    createConfigFrame.Position = UDim2.new(0, 4, 0, yOffset)
    createConfigFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    createConfigFrame.BackgroundTransparency = 0.1
    createConfigFrame.Parent = scrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = createConfigFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.7, 0, 0.6, 0)
    textBox.Position = UDim2.new(0.05, 0, 0.2, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    textBox.TextColor3 = Color3.fromRGB(230, 230, 230)
    textBox.PlaceholderText = "Config name"
    textBox.Text = ""
    textBox.ClearTextOnFocus = false
    textBox.Parent = createConfigFrame
    
    local createButton = Instance.new("TextButton")
    createButton.Size = UDim2.new(0.2, 0, 0.6, 0)
    createButton.Position = UDim2.new(0.75, 0, 0.2, 0)
    createButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    createButton.Text = "Create"
    createButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    createButton.Parent = createConfigFrame
    
    corner:Clone().Parent = textBox
    corner:Clone().Parent = createButton
    
    createButton.MouseButton1Click:Connect(function()
        if textBox.Text ~= "" then
            saveConfig(textBox.Text)
            scanConfigs()
            refreshConfigUI(scrollFrame)
            textBox.Text = ""
        end
    end)
    
    table.insert(configButtons, createConfigFrame)
    yOffset = yOffset + 55
    
    for _, configName in ipairs(scanConfigs()) do
        local configFrame = Instance.new("Frame")
        configFrame.Size = UDim2.new(1, -8, 0, 40)
        configFrame.Position = UDim2.new(0, 4, 0, yOffset)
        configFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        configFrame.BackgroundTransparency = 0.1
        configFrame.Parent = scrollFrame
        
        corner:Clone().Parent = configFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = configName
        nameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = configFrame
        
        local loadButton = Instance.new("TextButton")
        loadButton.Size = UDim2.new(0.15, 0, 0.7, 0)
        loadButton.Position = UDim2.new(0.65, 0, 0.15, 0)
        loadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        loadButton.Text = "Load"
        loadButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        loadButton.Parent = configFrame
        
        local deleteButton = Instance.new("TextButton")
        deleteButton.Size = UDim2.new(0.15, 0, 0.7, 0)
        deleteButton.Position = UDim2.new(0.85, 0, 0.15, 0)
        deleteButton.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
        deleteButton.Text = "Delete"
        deleteButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        deleteButton.Parent = configFrame
        
        corner:Clone().Parent = loadButton
        corner:Clone().Parent = deleteButton
        
        loadButton.MouseButton1Click:Connect(function()
            if loadConfig(configName) then
                for id, element in pairs(uiElements) do
                    if id == "hitboxEnabled" then
                        element.update(settings.Combat.Hitbox.Enabled)
                    elseif id == "hitboxSize" then
                        element.update(settings.Combat.Hitbox.Size)
                    elseif id == "hitboxType" then
                        element.update(settings.Combat.Hitbox.Type == "Sphere")
                    elseif id == "hitboxThroughWalls" then
                        element.update(settings.Combat.Hitbox.ThroughWalls)
                    elseif id == "hitboxColor" then
                        element.update(settings.Combat.Hitbox.Color)
                    elseif id == "hitboxTransparency" then
                        element.update(settings.Combat.Hitbox.Transparency)
                    elseif id == "espEnabled" then
                        element.update(settings.ESP.Enabled)
                    elseif id == "espShowDistance" then
                        element.update(settings.ESP.ShowDistance)
                    elseif id == "musicVolume" then
                        element.update(settings.Music.Volume)
                    elseif id == "musicEnabled" then
                        element.update(settings.Music.Enabled)
                    end
                end
                updateAllESP()
            end
        end)
        
        deleteButton.MouseButton1Click:Connect(function()
            deleteConfig(configName)
            scanConfigs()
            refreshConfigUI(scrollFrame)
        end)
        
        table.insert(configButtons, configFrame)
        yOffset = yOffset + 45
    end
end

local function initializeMusicPlayer()
    musicPlayer.clickSound = Instance.new("Sound")
    musicPlayer.clickSound.SoundId = "rbxassetid://6042053626"
    musicPlayer.clickSound.Volume = 0.2
    musicPlayer.clickSound.Parent = workspace
    
    musicPlayer.sound = Instance.new("Sound")
    musicPlayer.sound.SoundId = musicPlayer.sounds[settings.Music.CurrentTrack]
    musicPlayer.sound.Volume = settings.Music.Volume
    musicPlayer.sound.Parent = workspace
    musicPlayer.sound.Looped = false
    musicPlayer.sound.RollOffMaxDistance = 99999
    musicPlayer.sound.RollOffMinDistance = 1
    musicPlayer.sound.RollOffMode = Enum.RollOffMode.InverseTapered
    
    musicPlayer.connection = game:GetService("RunService").Heartbeat:Connect(function()
        if musicPlayer.isPlaying then
            local currentTime = musicPlayer.sound.TimePosition
            local progress = math.clamp(currentTime / musicPlayer.soundLength, 0, 1)
            if musicPlayer.progressFill then
                musicPlayer.progressFill.Size = UDim2.new(progress, 0, 1, 0)
            end
            if musicPlayer.timeText then
                musicPlayer.timeText.Text = string.format("%d:%02d", math.floor(currentTime/60), math.floor(currentTime%60)).." / "..string.format("%d:%02d", math.floor(musicPlayer.soundLength/60), math.floor(musicPlayer.soundLength%60)))
            end
            
            if currentTime >= musicPlayer.soundLength - 0.1 then
                musicPlayer.currentTrack = musicPlayer.currentTrack == #musicPlayer.sounds and 1 or musicPlayer.currentTrack + 1
                settings.Music.CurrentTrack = musicPlayer.currentTrack
                saveSettings()
                musicPlayer.sound:Stop()
                musicPlayer.sound.SoundId = musicPlayer.sounds[musicPlayer.currentTrack]
                musicPlayer.sound:Play()
            end
        end
    end)
    
    musicPlayer.sound.Loaded:Connect(function()
        musicPlayer.soundLength = musicPlayer.sound.TimeLength
        if musicPlayer.timeText then
            musicPlayer.timeText.Text = "0:00 / "..string.format("%d:%02d", math.floor(musicPlayer.soundLength/60), math.floor(musicPlayer.soundLength%60)))
        end
    end)
end

local function refreshMusicUI()
    local musicScrollFrame = scrollFrames[4]
    if not musicScrollFrame then return end
    
    for _, child in ipairs(musicScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(1, -8, 0, 80)
    controlsFrame.Position = UDim2.new(0, 4, 0, 0)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = musicScrollFrame
    
    musicPlayer.prevButton = Instance.new("ImageButton")
    musicPlayer.prevButton.Name = "PrevButton"
    musicPlayer.prevButton.Size = UDim2.new(0, 28, 0, 28)
    musicPlayer.prevButton.Position = UDim2.new(0.3, -14, 0.5, -14)
    musicPlayer.prevButton.Image = "rbxassetid://12662712394"
    musicPlayer.prevButton.BackgroundTransparency = 1
    musicPlayer.prevButton.Parent = controlsFrame
    
    musicPlayer.playButton = Instance.new("ImageButton")
    musicPlayer.playButton.Name = "PlayButton"
    musicPlayer.playButton.Size = UDim2.new(0, 32, 0, 32)
    musicPlayer.playButton.Position = UDim2.new(0.5, -16, 0.5, -16)
    musicPlayer.playButton.Image = "rbxassetid://12099513379"
    musicPlayer.playButton.BackgroundTransparency = 1
    musicPlayer.playButton.Parent = controlsFrame
    
    musicPlayer.pauseButton = Instance.new("ImageButton")
    musicPlayer.pauseButton.Name = "PauseButton"
    musicPlayer.pauseButton.Size = UDim2.new(0, 32, 0, 32)
    musicPlayer.pauseButton.Position = UDim2.new(0.5, -16, 0.5, -16)
    musicPlayer.pauseButton.Image = "rbxassetid://14219414360"
    musicPlayer.pauseButton.BackgroundTransparency = 1
    musicPlayer.pauseButton.Visible = false
    musicPlayer.pauseButton.Parent = controlsFrame
    
    musicPlayer.nextButton = Instance.new("ImageButton")
    musicPlayer.nextButton.Name = "NextButton"
    musicPlayer.nextButton.Size = UDim2.new(0, 28, 0, 28)
    musicPlayer.nextButton.Position = UDim2.new(0.7, -14, 0.5, -14)
    musicPlayer.nextButton.Image = "rbxassetid://12662720464"
    musicPlayer.nextButton.BackgroundTransparency = 1
    musicPlayer.nextButton.Parent = controlsFrame
    
    local progressContainer = Instance.new("Frame")
    progressContainer.Size = UDim2.new(1, -20, 0, 6)
    progressContainer.Position = UDim2.new(0, 10, 0, 70)
    progressContainer.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
    progressContainer.BackgroundTransparency = 0.5
    progressContainer.Parent = musicScrollFrame
    
    local progressUICorner = Instance.new("UICorner")
    progressUICorner.CornerRadius = UDim.new(1, 0)
    progressUICorner.Parent = progressContainer
    
    musicPlayer.progressFill = Instance.new("Frame")
    musicPlayer.progressFill.Name = "ProgressFill"
    musicPlayer.progressFill.Size = UDim2.new(0, 0, 1, 0)
    musicPlayer.progressFill.BackgroundColor3 = Color3.fromRGB(90, 170, 255)
    musicPlayer.progressFill.Parent = progressContainer
    
    local fillUICorner = Instance.new("UICorner")
    fillUICorner.CornerRadius = UDim.new(1, 0)
    fillUICorner.Parent = musicPlayer.progressFill
    
    local progressHandle = Instance.new("Frame")
    progressHandle.Size = UDim2.new(0, 6, 0, 6)
    progressHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    progressHandle.Position = UDim2.new(1, 0, 0.5, 0)
    progressHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    progressHandle.Parent = musicPlayer.progressFill
    
    local handleUICorner = Instance.new("UICorner")
    handleUICorner.CornerRadius = UDim.new(1, 0)
    handleUICorner.Parent = progressHandle
    
    musicPlayer.timeText = Instance.new("TextLabel")
    musicPlayer.timeText.Name = "TimeText"
    musicPlayer.timeText.Size = UDim2.new(1, -20, 0, 16)
    musicPlayer.timeText.Position = UDim2.new(0, 10, 0, 80)
    musicPlayer.timeText.BackgroundTransparency = 1
    musicPlayer.timeText.TextColor3 = Color3.fromRGB(230, 230, 230)
    musicPlayer.timeText.Text = "0:00 / 0:00"
    musicPlayer.timeText.Font = Enum.Font.GothamMedium
    musicPlayer.timeText.TextSize = 12
    musicPlayer.timeText.TextXAlignment = Enum.TextXAlignment.Center
    musicPlayer.timeText.Parent = musicScrollFrame
    
    local volumeValues = {}
    for i = 0, 30 do table.insert(volumeValues, i/10) end
    
    createValueChanger(musicScrollFrame, "Volume (0-3)", volumeValues, settings.Music.Volume, function(value)
        settings.Music.Volume = value
        if musicPlayer.sound then
            musicPlayer.sound.Volume = value
        end
        saveSettings()
    end, "musicVolume")
    
    createToggle(musicScrollFrame, "Music Enabled", settings.Music.Enabled, function(value)
        settings.Music.Enabled = value
        if value then
            musicPlayer.isPlaying = true
            musicPlayer.playButton.Visible = false
            musicPlayer.pauseButton.Visible = true
            if musicPlayer.sound.IsPaused then
                musicPlayer.sound:Resume()
            else
                musicPlayer.sound:Play()
            end
        else
            musicPlayer.isPlaying = false
            musicPlayer.playButton.Visible = true
            musicPlayer.pauseButton.Visible = false
            musicPlayer.sound:Pause()
        end
        saveSettings()
    end, "musicEnabled")
    
    local function playClick()
        musicPlayer.clickSound:Stop()
        musicPlayer.clickSound:Play()
    end
    
    local function updateTrack()
        musicPlayer.sound:Stop()
        musicPlayer.sound.SoundId = musicPlayer.sounds[musicPlayer.currentTrack]
        if settings.Music.Enabled then
            musicPlayer.sound:Play()
        end
        musicPlayer.isPlaying = settings.Music.Enabled
        musicPlayer.playButton.Visible = not settings.Music.Enabled
        musicPlayer.pauseButton.Visible = settings.Music.Enabled
        settings.Music.CurrentTrack = musicPlayer.currentTrack
        saveSettings()
    end
    
    musicPlayer.playButton.MouseButton1Click:Connect(function()
        playClick()
        settings.Music.Enabled = true
        musicPlayer.isPlaying = true
        musicPlayer.playButton.Visible = false
        musicPlayer.pauseButton.Visible = true
        if musicPlayer.sound.IsPaused then
            musicPlayer.sound:Resume()
        else
            musicPlayer.sound:Play()
        end
        saveSettings()
        if uiElements.musicEnabled then
            uiElements.musicEnabled.update(true)
        end
    end)
    
    musicPlayer.pauseButton.MouseButton1Click:Connect(function()
        playClick()
        settings.Music.Enabled = false
        musicPlayer.isPlaying = false
        musicPlayer.pauseButton.Visible = false
        musicPlayer.playButton.Visible = true
        musicPlayer.sound:Pause()
        saveSettings()
        if uiElements.musicEnabled then
            uiElements.musicEnabled.update(false)
        end
    end)
    
    musicPlayer.prevButton.MouseButton1Click:Connect(function()
        playClick()
        musicPlayer.currentTrack = musicPlayer.currentTrack == 1 and #musicPlayer.sounds or musicPlayer.currentTrack - 1
        updateTrack()
    end)
    
    musicPlayer.nextButton.MouseButton1Click:Connect(function()
        playClick()
        musicPlayer.currentTrack = musicPlayer.currentTrack == #musicPlayer.sounds and 1 or musicPlayer.currentTrack + 1
        updateTrack()
    end)
end

local function createMainGUI()
    clearAll()
    settings = table.clone(defaultSettings)
    loadSettings()
    scanConfigs()
    initializeMusicPlayer()

    if PlayerGui:FindFirstChild("SilenceGui") then
        PlayerGui.SilenceGui:Destroy()
        wait(0.1)
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
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
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
    dragArea.Text = "Silence 4.7"
    dragArea.TextColor3 = Color3.fromRGB(230, 230, 230)
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

    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1 / #tabs, -4, 1, -4)
        tabButton.Position = UDim2.new((i - 1) / #tabs, 2, 0, 2)
        tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
        tabButton.BackgroundTransparency = 0.1
        tabButton.Text = ""
        tabButton.Parent = tabContainer

        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
        tabIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = tabIcons[tabName]
        tabIcon.Parent = tabButton

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

        if tabName == "Combat" then
            refreshCombatUI()
        elseif tabName == "ESP" then
            refreshESPUI()
        elseif tabName == "Config" then
            refreshConfigUI(scrollFrame)
        elseif tabName == "Music" then
            refreshMusicUI()
        end

        tabButton.MouseButton1Click:Connect(function()
            currentTab = i
            for j, frame in ipairs(contentFrames) do
                frame.Visible = j == i
            end
            for j, btn in ipairs(tabButtons) do
                btn.BackgroundColor3 = j == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
            end
            if tabName == "Config" then
                refreshConfigUI(scrollFrame)
            elseif tabName == "Music" then
                refreshMusicUI()
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
        isMinimized = not isMinimized
        local targetSize = isMinimized and minimizedSize or UDim2.new(0, menuWidth, 0, menuHeight)
        local targetPosition = isMinimized and minimizedPosition or defaultPosition
        tweenFrame(mainFrame, targetSize, targetPosition)
        tabContainer.Visible = not isMinimized
        for _, frame in ipairs(contentFrames) do
            frame.Visible = not isMinimized and frame == contentFrames[currentTab]
        end
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    connections.InputBegan = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            isVisible = not isVisible
            screenGui.Enabled = isVisible
            if isVisible then
                updateAllESP()
            end
        end
    end)

    disableShadows()
    connections.DescendantAdded = game:GetService("Workspace").DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") then
            obj.CastShadow = false
        end
    end)

    local function handlePlayerAdded(player)
        if player ~= LocalPlayer then
            createESP(player)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        handlePlayerAdded(player)
    end

    connections.PlayerAdded = Players.PlayerAdded:Connect(handlePlayerAdded)

    connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        clearESP(player)
    end)

    connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        updateNoClip()
        disableShadows()
        character:WaitForChild("Humanoid").Died:Connect(function()
            disableShadows()
        end)
    end)

    if LocalPlayer.Character then
        updateNoClip()
        disableShadows()
    end

    setfpscap(1000)

    connections.RenderStep = RunService.RenderStepped:Connect(function()
        if isVisible then
            for player, _ in pairs(espCache) do
                if player ~= LocalPlayer then
                    updateESP(player)
                end
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
    end)

    return screenGui
end

local screenGui = createMainGUI()

game:BindToClose(function()
    clearAll()
    if screenGui then
        screenGui:Destroy()
    end
end)