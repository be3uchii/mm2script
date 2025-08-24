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
local menuWidth, menuHeight = 320, 180
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
local backupFolder = "SilenceBackups"
local cacheFolder = "SilenceCache"

setfpscap(1000)

local colors = {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(0, 0, 0),
    Color3.fromRGB(255, 0, 0)
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
        PerformanceMode = true,
        SafeMode = false,
        DebugMode = false
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
local debugMode = false
local errorCount = 0
local maxErrors = 50
local initialized = false
local safeMode = false
local performanceMode = false
local cleanupQueue = {}
local cleanupInterval = 10
local lastCleanupTime = 0
local keyValidationAttempts = 0
local maxKeyAttempts = 3

local function ensureFolderStructure()
    local folders = {configFolder, backupFolder, cacheFolder}
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
        safeMode = true
        settings.System.SafeMode = true
        clearAll()
    end
end

local function safeCall(func, errorLocation, ...)
    if safeMode then return nil end
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
    if safeMode then return end
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

local function createBackup()
    ensureFolderStructure()
    local backupName = os.date("%Y%m%d_%H%M%S").."_backup.cfg"
    local settingsPath = configFolder.."/"..configFile
    if isfile(settingsPath) then
        secureWrite(backupFolder.."/"..backupName, readfile(settingsPath))
    end
    for _, configName in ipairs(settings.Configs) do
        local configPath = configFolder.."/"..configName..".cfg"
        if isfile(configPath) then
            local configBackupName = backupName:gsub("_backup.cfg", "_"..configName..".cfg")
            secureWrite(backupFolder.."/"..configBackupName, readfile(configPath))
        end
    end
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
        if os.time() - lastBackupTime > backupInterval then
            createBackup()
            lastBackupTime = os.time()
        end
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
                    safeMode = settings.System.SafeMode
                    performanceMode = settings.System.PerformanceMode
                    debugMode = settings.System.DebugMode
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
        box.AlwaysOnTop = false
        box.ZIndex = 0
        box.Transparency = settings.Combat.Hitbox.Transparency
        box.Color3 = settings.Combat.Hitbox.Color
        box.Parent = hrp
        
        hitboxCache[character] = box
        table.insert(cleanupQueue, box)
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
    
    createCleanToggle(combatScrollFrame, "Sphere Hitbox", settings.Combat.Hitbox.Type == "Sphere", function(value)
        settings.Combat.Hitbox.Type = value and "Sphere" or "Box"
        updateAllESP()
    end, "hitboxType")
    
    createColorButton(combatScrollFrame, "Hitbox Color", settings.Combat.Hitbox.Color, function(value)
        settings.Combat.Hitbox.Color = value
        updateAllESP()
    end, "hitboxColor")
    
    local transparencyValues = {}
    for i = 1, 9 do table.insert(transparencyValues, i * 0.1) end
    
    createValueChanger(combatScrollFrame, "Hitbox Transparency", transparencyValues, settings.Combat.Hitbox.Transparency, function(value)
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
    end, "showDistance")
    
    local distanceValues = {50, 100, 150, 200, 250, 300, 500, 1000}
    createValueChanger(espScrollFrame, "Max Distance", distanceValues, settings.ESP.MaxDistance, function(value)
        settings.ESP.MaxDistance = value
        updateAllESP()
    end, "maxDistance")
end

local function refreshConfigUI()
    local configScrollFrame = scrollFrames[3]
    if not configScrollFrame then return end
    
    for _, child in ipairs(configScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    createCleanToggle(configScrollFrame, "Performance Mode", settings.System.PerformanceMode, function(value)
        settings.System.PerformanceMode = value
        performanceMode = value
        if value then
            disableShadows()
        end
    end, "performanceMode")
    
    createCleanToggle(configScrollFrame, "Safe Mode", settings.System.SafeMode, function(value)
        settings.System.SafeMode = value
        safeMode = value
        if value then
            clearAll()
        end
    end, "safeMode")
    
    createCleanToggle(configScrollFrame, "Debug Mode", settings.System.DebugMode, function(value)
        settings.System.DebugMode = value
        debugMode = value
    end, "debugMode")
    
    local configList = scanConfigs()
    local configNameInput = Instance.new("TextBox")
    configNameInput.Size = UDim2.new(0.6, -4, 0, 20)
    configNameInput.Position = UDim2.new(0, 4, 0, 80)
    configNameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    configNameInput.TextColor3 = Color3.fromRGB(230, 230, 230)
    configNameInput.PlaceholderText = "Config Name"
    configNameInput.Text = ""
    configNameInput.TextSize = 12
    configNameInput.Font = Enum.Font.Gotham
    configNameInput.Parent = configScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = configNameInput
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(60, 60, 255)
    glow.Thickness = 1
    glow.Transparency = 0.7
    glow.Parent = configNameInput
    
    local saveButton = Instance.new("TextButton")
    saveButton.Size = UDim2.new(0.35, -4, 0, 20)
    saveButton.Position = UDim2.new(0.65, 4, 0, 80)
    saveButton.BackgroundColor3 = Color3.fromRGB(76, 217, 100)
    saveButton.Text = "Save"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.TextSize = 12
    saveButton.Font = Enum.Font.GothamBold
    saveButton.Parent = configScrollFrame
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 4)
    saveCorner.Parent = saveButton
    
    local saveGlow = Instance.new("UIStroke")
    saveGlow.Color = Color3.fromRGB(76, 217, 100)
    saveGlow.Thickness = 1
    saveGlow.Transparency = 0.7
    saveGlow.Parent = saveButton
    
    saveButton.MouseButton1Click:Connect(function()
        playSound()
        local configName = configNameInput.Text:gsub("%s+", "_")
        if configName ~= "" then
            saveConfig(configName)
            configNameInput.Text = ""
            refreshConfigUI()
        end
    end)
    
    local yOffset = 105
    for _, configName in ipairs(configList) do
        local configFrame = Instance.new("Frame")
        configFrame.Size = UDim2.new(1, -8, 0, 25)
        configFrame.Position = UDim2.new(0, 4, 0, yOffset)
        configFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        configFrame.Parent = configScrollFrame
        
        local configCorner = Instance.new("UICorner")
        configCorner.CornerRadius = UDim.new(0, 4)
        configCorner.Parent = configFrame
        
        local configGlow = Instance.new("UIStroke")
        configGlow.Color = Color3.fromRGB(60, 60, 255)
        configGlow.Thickness = 1
        configGlow.Transparency = 0.7
        configGlow.Parent = configFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = configName
        nameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = configFrame
        
        local loadButton = Instance.new("TextButton")
        loadButton.Size = UDim2.new(0.15, -2, 0.6, 0)
        loadButton.Position = UDim2.new(0.65, 2, 0.2, 0)
        loadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 255)
        loadButton.Text = "Load"
        loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadButton.TextSize = 10
        loadButton.Font = Enum.Font.GothamBold
        loadButton.Parent = configFrame
        
        local loadCorner = Instance.new("UICorner")
        loadCorner.CornerRadius = UDim.new(0, 4)
        loadCorner.Parent = loadButton
        
        local deleteButton = Instance.new("TextButton")
        deleteButton.Size = UDim2.new(0.15, -2, 0.6, 0)
        deleteButton.Position = UDim2.new(0.85, 2, 0.2, 0)
        deleteButton.BackgroundColor3 = Color3.fromRGB(255, 58, 58)
        deleteButton.Text = "Delete"
        deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        deleteButton.TextSize = 10
        deleteButton.Font = Enum.Font.GothamBold
        deleteButton.Parent = configFrame
        
        local deleteCorner = Instance.new("UICorner")
        deleteCorner.CornerRadius = UDim.new(0, 4)
        deleteCorner.Parent = deleteButton
        
        loadButton.MouseButton1Click:Connect(function()
            playSound()
            if loadConfig(configName) then
                refreshCombatUI()
                refreshESPUI()
                refreshConfigUI()
            end
        end)
        
        deleteButton.MouseButton1Click:Connect(function()
            playSound()
            deleteConfig(configName)
            refreshConfigUI()
        end)
        
        yOffset = yOffset + 30
    end
end

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilenceUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    mainFrame.Position = defaultPosition
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame
    
    local mainGlow = Instance.new("UIStroke")
    mainGlow.Color = Color3.fromRGB(60, 60, 255)
    mainGlow.Thickness = 2
    mainGlow.Transparency = 0.8
    mainGlow.Parent = mainFrame
    
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 25)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.CornerRadius = UDim.new(0, 8, 0, 0)
    headerCorner.Parent = headerFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 8, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "SILENCE"
    titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = headerFrame
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 20, 0, 20)
    minimizeButton.Position = UDim2.new(1, -25, 0.5, -10)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Text = "-"
    minimizeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    minimizeButton.TextSize = 16
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = headerFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -5, 0.5, -10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = headerFrame
    
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Size = UDim2.new(1, -8, 0, 25)
    tabsFrame.Position = UDim2.new(0, 4, 0, 30)
    tabsFrame.BackgroundTransparency = 1
    tabsFrame.Parent = mainFrame
    
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1/#tabs, -2, 1, 0)
        tabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
        tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(40, 40, 50) or Color3.fromRGB(30, 30, 40)
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        tabButton.TextSize = 12
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = tabsFrame
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 4)
        tabCorner.Parent = tabButton
        
        local tabGlow = Instance.new("UIStroke")
        tabGlow.Color = i == currentTab and Color3.fromRGB(60, 60, 255) or Color3.fromRGB(50, 50, 60)
        tabGlow.Thickness = 1
        tabGlow.Transparency = 0.7
        tabGlow.Parent = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            playSound()
            currentTab = i
            for _, contentFrame in pairs(contentFrames) do
                contentFrame.Visible = false
            end
            contentFrames[i].Visible = true
            for _, tabBtn in ipairs(tabsFrame:GetChildren()) do
                if tabBtn:IsA("TextButton") then
                    tabBtn.BackgroundColor3 = tabBtn == tabButton and Color3.fromRGB(40, 40, 50) or Color3.fromRGB(30, 30, 40)
                    tabBtn.UIStroke.Color = tabBtn == tabButton and Color3.fromRGB(60, 60, 255) or Color3.fromRGB(50, 50, 60)
                end
            end
        end)
        
        tabButtons[i] = tabButton
    end
    
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -8, 1, -65)
    contentArea.Position = UDim2.new(0, 4, 0, 60)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame
    
    for i = 1, #tabs do
        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, 0, 1, 0)
        contentFrame.Position = UDim2.new(0, 0, 0, 0)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Visible = i == currentTab
        contentFrame.Parent = contentArea
        
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.Position = UDim2.new(0, 0, 0, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 255)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Parent = contentFrame
        
        contentFrames[i] = contentFrame
        scrollFrames[i] = scrollFrame
    end
    
    refreshCombatUI()
    refreshESPUI()
    refreshConfigUI()
    
    local footerFrame = Instance.new("Frame")
    footerFrame.Size = UDim2.new(1, 0, 0, 20)
    footerFrame.Position = UDim2.new(0, 0, 1, -20)
    footerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    footerFrame.BorderSizePixel = 0
    footerFrame.Parent = mainFrame
    
    local footerCorner = Instance.new("UICorner")
    footerCorner.CornerRadius = UDim.new(0, 0, 0, 8)
    footerCorner.Parent = footerFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -8, 1, 0)
    statusLabel.Position = UDim2.new(0, 4, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Ready"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = footerFrame
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0.3, 0, 1, 0)
    timeLabel.Position = UDim2.new(0.7, 0, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "00:00:00"
    timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    timeLabel.TextSize = 11
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = footerFrame
    
    minimizeButton.MouseButton1Click:Connect(function()
        playSound()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(mainFrame, tweenInfo, {Size = minimizedSize, Position = minimizedPosition}):Play()
            for _, contentFrame in pairs(contentFrames) do
                contentFrame.Visible = false
            end
            statusLabel.Visible = false
            timeLabel.Visible = false
        else
            TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, menuWidth, 0, menuHeight), Position = defaultPosition}):Play()
            contentFrames[currentTab].Visible = true
            statusLabel.Visible = true
            timeLabel.Visible = true
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        playSound()
        isVisible = not isVisible
        mainFrame.Visible = isVisible
    end)
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    headerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    headerFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    connections.updateTimer = RunService.RenderStepped:Connect(function(deltaTime)
        updateTimer()
        timeLabel.Text = formatTime(elapsedTime)
        if settings.System.PerformanceMode then
            disableShadows()
        end
        updateNoClip()
        cleanupObjects()
    end)
    
    connections.playerAdded = Players.PlayerAdded:Connect(function(player)
        createESP(player)
    end)
    
    connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        clearESP(player)
    end)
    
    connections.characterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        updateNoClip()
    end)
    
    connections.renderStepped = RunService.RenderStepped:Connect(function()
        updateAllESP()
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
        end
    end
    
    if LocalPlayer.Character then
        updateNoClip()
    end
    
    statusLabel.Text = "Initialized"
    initialized = true
end

local function initialize()
    ensureFolderStructure()
    loadSettings()
    createUI()
    disableShadows()
end

initialize()