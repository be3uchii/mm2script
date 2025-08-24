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
local menuWidth, menuHeight = 300, 180
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Config"}
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local minimizedSize = UDim2.new(0, 90, 0, 25)
local minimizedPosition = UDim2.new(0.5, -45, 0.01, 0)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)
local keyFileName = "silence_key.dat"
local configFolder = "SilenceConfig"
local configFile = "settings.cfg"
local backupFolder = "SilenceBackups"
local cacheFolder = "SilenceCache"

setfpscap(1000)

local colors = {
    Color3.fromRGB(0, 150, 255),
    Color3.fromRGB(0, 200, 255),
    Color3.fromRGB(50, 255, 255),
    Color3.fromRGB(255, 50, 50),
    Color3.fromRGB(50, 255, 50),
    Color3.fromRGB(255, 255, 50)
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
    Tracers = {
        Enabled = false
    },
    Configs = {},
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
local tracers = {}
local tracerConnections = {}
local backupInterval = 300
local lastBackupTime = 0
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
                soundCache.clickSound.Volume = volume or 0.2
                soundCache.clickSound.Parent = workspace
                table.insert(cleanupQueue, soundCache.clickSound)
            end
            soundCache.clickSound:Play()
        else
            if not soundCache[id] then
                soundCache[id] = Instance.new("Sound")
                soundCache[id].SoundId = "rbxassetid://"..tostring(id)
                soundCache[id].Volume = volume or 0.2
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
    
    for _, tracer in pairs(tracers) do
        pcall(function() tracer:Remove() end)
    end
    tracers = {}
    
    for _, conn in pairs(tracerConnections) do
        pcall(function() conn:Disconnect() end)
    end
    tracerConnections = {}
    
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

local function createTracer(player)
    if player == LocalPlayer or tracers[player] then return end
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(0, 150, 255)
    tracer.Thickness = 1.5
    tracer.Transparency = 0.8
    tracer.ZIndex = 1
    
    tracers[player] = tracer
    
    local function onCharacterAdded(character)
        if tracerConnections[player] then
            tracerConnections[player]:Disconnect()
        end
        
        local humanoid = character:WaitForChild("Humanoid")
        
        tracerConnections[player] = humanoid.Died:Connect(function()
            if tracers[player] then
                tracers[player].Visible = false
            end
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
end

local function updateTracers()
    if not settings.Tracers.Enabled then
        for _, tracer in pairs(tracers) do
            tracer.Visible = false
        end
        return
    end
    
    local camera = workspace.CurrentCamera
    local cameraPos = camera.CFrame.Position
    local viewportCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    
    for player, tracer in pairs(tracers) do
        if player and player ~= LocalPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if humanoidRootPart and humanoid and humanoid.Health > 0 then
                local distance = (humanoidRootPart.Position - cameraPos).Magnitude
                
                if distance <= settings.ESP.MaxDistance then
                    local position, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                    if onScreen then
                        tracer.From = viewportCenter
                        tracer.To = Vector2.new(position.X, position.Y)
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end
        else
            tracer.Visible = false
        end
    end
end

local function removeTracer(player)
    if tracers[player] then
        tracers[player]:Remove()
        tracers[player] = nil
    end
    if tracerConnections[player] then
        tracerConnections[player]:Disconnect()
        tracerConnections[player] = nil
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
    box.Color = colors[1]
    box.Thickness = 2
    box.Filled = false
    box.ZIndex = 1
    
    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Color = colors[1]
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
    
    createTracer(player)
    
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
            if tracers[player] then
                tracers[player].Visible = false
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
                if tracers[player] then
                    tracers[player].Visible = false
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
    removeTracer(player)
end

local function updateAllESP()
    for player, _ in pairs(espCache) do
        updateESP(player)
    end
    
    updateTracers()
    
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
    SwitchButton.BackgroundColor3 = value and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
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
    glow.Color = value and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    glow.Thickness = 1.5
    glow.Transparency = 0.7
    glow.Parent = SwitchButton
    
    SwitchButton.MouseButton1Click:Connect(function()
        playSound()
        value = not value
        
        local circleGoalPos = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        local bgGoalColor = value and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
        
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
                local bgGoalColor = value and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
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
    valueFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    valueFrame.Parent = changerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = valueFrame
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(0, 150, 255)
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
        currentIndex = currentIndex - 1
        if currentIndex < 1 then
            currentIndex = #values
        end
        updateValue()
    end)
    
    nextButton.MouseButton1Click:Connect(function()
        playSound()
        currentIndex = currentIndex + 1
        if currentIndex > #values then
            currentIndex = 1
        end
        updateValue()
    end)
    
    if id then
        uiElements[id] = {
            update = function(newValue)
                local index = table.find(values, newValue)
                if index then
                    currentIndex = index
                    value = newValue
                    valueLabel.Text = tostring(value)
                end
            end
        }
    end
    
    return changerFrame
end

local function createSlider(parent, text, min, max, value, callback, id)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -8, 0, 30)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Position = UDim2.new(0, 4, 0, 0)
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextTransparency = 0.1
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0.3, 0)
    track.Position = UDim2.new(0, 0, 0.7, 0)
    track.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    track.Parent = sliderFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = track
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(0, 150, 255)
    glow.Thickness = 1
    glow.Transparency = 0.7
    glow.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 12, 0, 12)
    handle.Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.Parent = track
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    local dragging = false
    
    local function updateSlider(input)
        local pos = UDim2.new(math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1), 0, 1, 0)
        local newValue = math.floor(min + (max - min) * pos.X.Scale)
        
        fill.Size = pos
        handle.Position = UDim2.new(pos.X.Scale, -6, 0.5, -6)
        valueLabel.Text = tostring(newValue)
        
        callback(newValue)
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            playSound()
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            saveSettings()
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
            playSound()
        end
    end)
    
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            saveSettings()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    if id then
        uiElements[id] = {
            update = function(newValue)
                newValue = math.clamp(newValue, min, max)
                local pos = (newValue - min) / (max - min)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                handle.Position = UDim2.new(pos, -6, 0.5, -6)
                valueLabel.Text = tostring(newValue)
            end
        }
    end
    
    return sliderFrame
end

local function createColorPicker(parent, text, color, callback, id)
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(1, -8, 0, 22)
    pickerFrame.BackgroundTransparency = 1
    pickerFrame.Position = UDim2.new(0, 4, 0, 0)
    pickerFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextTransparency = 0.1
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = pickerFrame
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0.25, 0, 0.75, 0)
    colorButton.Position = UDim2.new(0.7, 0, 0.125, 0)
    colorButton.BackgroundColor3 = color
    colorButton.AutoButtonColor = false
    colorButton.Text = ""
    colorButton.Parent = pickerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = colorButton
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(0, 150, 255)
    glow.Thickness = 1
    glow.Transparency = 0.7
    glow.Parent = colorButton
    
    colorButton.MouseButton1Click:Connect(function()
        playSound()
        local newColor = Color3.fromHSV(math.random(), 1, 1)
        colorButton.BackgroundColor3 = newColor
        glow.Color = newColor
        callback(newColor)
        saveSettings()
    end)
    
    if id then
        uiElements[id] = {
            update = function(newColor)
                colorButton.BackgroundColor3 = newColor
                glow.Color = newColor
            end
        }
    end
    
    return pickerFrame
end

local function createDropdown(parent, text, options, selected, callback, id)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, -8, 0, 22)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Position = UDim2.new(0, 4, 0, 0)
    dropdownFrame.Parent = parent
    
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
    label.Parent = dropdownFrame
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(0.45, 0, 0.75, 0)
    dropdownButton.Position = UDim2.new(0.5, 0, 0.125, 0)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    dropdownButton.AutoButtonColor = false
    dropdownButton.Text = selected
    dropdownButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    dropdownButton.TextSize = 13
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.Parent = dropdownFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = dropdownButton
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(0, 150, 255)
    glow.Thickness = 1
    glow.Transparency = 0.7
    glow.Parent = dropdownButton
    
    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 12, 0, 12)
    arrow.Position = UDim2.new(1, -14, 0.5, -6)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://12338895277"
    arrow.ImageColor3 = Color3.fromRGB(200, 200, 200)
    arrow.ImageTransparency = 0.3
    arrow.Parent = dropdownButton
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Size = UDim2.new(0.45, 0, 0, 0)
    dropdownList.Position = UDim2.new(0.5, 0, 0.9, 0)
    dropdownList.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    dropdownList.BorderSizePixel = 0
    dropdownList.ScrollBarThickness = 4
    dropdownList.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
    dropdownList.Visible = false
    dropdownList.Parent = dropdownFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = dropdownList
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = dropdownList
    
    local listGlow = Instance.new("UIStroke")
    listGlow.Color = Color3.fromRGB(0, 150, 255)
    listGlow.Thickness = 1
    listGlow.Transparency = 0.7
    listGlow.Parent = dropdownList
    
    local isOpen = false
    
    local function updateDropdown()
        dropdownButton.Text = selected
        for _, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, -8, 0, 20)
            optionButton.Position = UDim2.new(0, 4, 0, 0)
            optionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            optionButton.AutoButtonColor = false
            optionButton.Text = option
            optionButton.TextColor3 = Color3.fromRGB(230, 230, 230)
            optionButton.TextSize = 13
            optionButton.Font = Enum.Font.Gotham
            optionButton.Parent = dropdownList
            
            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 4)
            optionCorner.Parent = optionButton
            
            optionButton.MouseButton1Click:Connect(function()
                playSound()
                selected = option
                dropdownButton.Text = selected
                dropdownList.Visible = false
                isOpen = false
                callback(selected)
                saveSettings()
            end)
        end
        
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 22)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        playSound()
        isOpen = not isOpen
        dropdownList.Visible = isOpen
        if isOpen then
            dropdownList.Size = UDim2.new(0.45, 0, 0, math.min(#options * 22, 100))
            updateDropdown()
        end
    end)
    
    if id then
        uiElements[id] = {
            update = function(newValue)
                if table.find(options, newValue) then
                    selected = newValue
                    dropdownButton.Text = selected
                end
            end
        }
    end
    
    return dropdownFrame
end

local function createConfigButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 25)
    button.Position = UDim2.new(0, 4, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    button.AutoButtonColor = false
    button.Text = text
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextSize = 13
    button.Font = Enum.Font.Gotham
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(0, 150, 255)
    glow.Thickness = 1
    glow.Transparency = 0.7
    glow.Parent = button
    
    button.MouseButton1Click:Connect(function()
        playSound()
        callback()
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
        TweenService:Create(glow, tweenInfo, {Transparency = 0.3}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        TweenService:Create(glow, tweenInfo, {Transparency = 0.7}):Play()
    end)
    
    return button
end

local function createInputField(parent, text, placeholder, callback, id)
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -8, 0, 22)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Position = UDim2.new(0, 4, 0, 0)
    inputFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextTransparency = 0.1
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = inputFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.55, 0, 0.75, 0)
    textBox.Position = UDim2.new(0.4, 0, 0.125, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    textBox.TextColor3 = Color3.fromRGB(230, 230, 230)
    textBox.PlaceholderText = placeholder
    textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    textBox.TextSize = 13
    textBox.Font = Enum.Font.Gotham
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = textBox
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(0, 150, 255)
    glow.Thickness = 1
    glow.Transparency = 0.7
    glow.Parent = textBox
    
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            playSound()
            callback(textBox.Text)
        end
    end)
    
    if id then
        uiElements[id] = {
            update = function(newValue)
                textBox.Text = newValue
            end
        }
    end
    
    return inputFrame
end

local function createMenu()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SilenceMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    MainFrame.Position = defaultPosition
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local MainGlow = Instance.new("UIStroke")
    MainGlow.Color = Color3.fromRGB(0, 150, 255)
    MainGlow.Thickness = 1.5
    MainGlow.Transparency = 0.8
    MainGlow.Parent = MainFrame
    
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 25)
    Header.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header
    
    local HeaderGlow = Instance.new("UIStroke")
    HeaderGlow.Color = Color3.fromRGB(0, 150, 255)
    HeaderGlow.Thickness = 1
    HeaderGlow.Transparency = 0.8
    HeaderGlow.Parent = Header
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Position = UDim2.new(0.2, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "SILENCE"
    Title.TextColor3 = Color3.fromRGB(0, 150, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Header
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -25, 0, 0)
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeButton.TextSize = 16
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Parent = Header
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -50, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = Header
    
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Size = UDim2.new(1, 0, 0, 25)
    TabsContainer.Position = UDim2.new(0, 0, 0, 25)
    TabsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    TabsContainer.Parent = MainFrame
    
    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.FillDirection = Enum.FillDirection.Horizontal
    TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabsLayout.Parent = TabsContainer
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, 0, 1, -50)
    ContentContainer.Position = UDim2.new(0, 0, 0, 50)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    for i, tabName in ipairs(tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0.3, 0, 0.8, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = tabName
        TabButton.TextColor3 = i == 1 and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(150, 150, 150)
        TabButton.TextSize = 13
        TabButton.Font = Enum.Font.Gotham
        TabButton.Parent = TabsContainer
        
        local ContentFrame = Instance.new("ScrollingFrame")
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.Position = UDim2.new(0, 0, 0, 0)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Visible = i == 1
        ContentFrame.ScrollBarThickness = 4
        ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        ContentFrame.Parent = ContentContainer
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 5)
        ContentLayout.Parent = ContentFrame
        
        tabButtons[i] = TabButton
        contentFrames[i] = ContentFrame
        scrollFrames[i] = ContentFrame
        
        TabButton.MouseButton1Click:Connect(function()
            playSound()
            currentTab = i
            for j, frame in ipairs(contentFrames) do
                frame.Visible = j == i
            end
            for j, button in ipairs(tabButtons) do
                button.TextColor3 = j == i and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(150, 150, 150)
            end
        end)
    end
    
    local CombatFrame = contentFrames[1]
    local ESPFrame = contentFrames[2]
    local ConfigFrame = contentFrames[3]
    
    createCleanToggle(CombatFrame, "Hitbox ESP", settings.Combat.Hitbox.Enabled, function(value)
        settings.Combat.Hitbox.Enabled = value
        if not value then
            clearHitboxes()
        end
    end, "HitboxToggle")
    
    createSlider(CombatFrame, "Hitbox Size", 1, 10, settings.Combat.Hitbox.Size, function(value)
        settings.Combat.Hitbox.Size = value
    end, "HitboxSize")
    
    createColorPicker(CombatFrame, "Hitbox Color", settings.Combat.Hitbox.Color, function(value)
        settings.Combat.Hitbox.Color = value
    end, "HitboxColor")
    
    createSlider(CombatFrame, "Hitbox Transparency", 0.1, 0.9, settings.Combat.Hitbox.Transparency, function(value)
        settings.Combat.Hitbox.Transparency = value
    end, "HitboxTransparency")
    
    createDropdown(CombatFrame, "Hitbox Type", {"Box", "Sphere"}, settings.Combat.Hitbox.Type, function(value)
        settings.Combat.Hitbox.Type = value
        clearHitboxes()
    end, "HitboxType")
    
    createCleanToggle(ESPFrame, "ESP", settings.ESP.Enabled, function(value)
        settings.ESP.Enabled = value
        if not value then
            for _, espData in pairs(espCache) do
                if espData.box then
                    espData.box.Visible = false
                end
                if espData.distanceText then
                    espData.distanceText.Visible = false
                end
            end
        end
    end, "ESPToggle")
    
    createCleanToggle(ESPFrame, "Show Distance", settings.ESP.ShowDistance, function(value)
        settings.ESP.ShowDistance = value
    end, "DistanceToggle")
    
    createSlider(ESPFrame, "Max Distance", 50, 500, settings.ESP.MaxDistance, function(value)
        settings.ESP.MaxDistance = value
    end, "MaxDistance")
    
    createCleanToggle(ESPFrame, "Tracers", settings.Tracers.Enabled, function(value)
        settings.Tracers.Enabled = value
        if not value then
            for _, tracer in pairs(tracers) do
                tracer.Visible = false
            end
        end
    end, "TracersToggle")
    
    local ConfigInput = Instance.new("TextBox")
    ConfigInput.Size = UDim2.new(1, -8, 0, 25)
    ConfigInput.Position = UDim2.new(0, 4, 0, 0)
    ConfigInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ConfigInput.TextColor3 = Color3.fromRGB(230, 230, 230)
    ConfigInput.PlaceholderText = "Config Name"
    ConfigInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    ConfigInput.TextSize = 13
    ConfigInput.Font = Enum.Font.Gotham
    ConfigInput.TextXAlignment = Enum.TextXAlignment.Left
    ConfigInput.ClearTextOnFocus = false
    ConfigInput.Parent = ConfigFrame
    
    local ConfigCorner = Instance.new("UICorner")
    ConfigCorner.CornerRadius = UDim.new(0, 4)
    ConfigCorner.Parent = ConfigInput
    
    local ConfigGlow = Instance.new("UIStroke")
    ConfigGlow.Color = Color3.fromRGB(0, 150, 255)
    ConfigGlow.Thickness = 1
    ConfigGlow.Transparency = 0.7
    ConfigGlow.Parent = ConfigInput
    
    local ConfigButtonsFrame = Instance.new("Frame")
    ConfigButtonsFrame.Size = UDim2.new(1, 0, 0, 80)
    ConfigButtonsFrame.Position = UDim2.new(0, 0, 0, 30)
    ConfigButtonsFrame.BackgroundTransparency = 1
    ConfigButtonsFrame.Parent = ConfigFrame
    
    local ConfigLayout = Instance.new("UIListLayout")
    ConfigLayout.Padding = UDim.new(0, 5)
    ConfigLayout.Parent = ConfigButtonsFrame
    
    createConfigButton(ConfigButtonsFrame, "Save Config", function()
        local configName = ConfigInput.Text
        if configName and configName ~= "" then
            saveConfig(configName)
            ConfigInput.Text = ""
            scanConfigs()
        end
    end)
    
    createConfigButton(ConfigButtonsFrame, "Load Config", function()
        local configName = ConfigInput.Text
        if configName and configName ~= "" then
            if loadConfig(configName) then
                updateUIFromSettings()
                ConfigInput.Text = ""
            end
        end
    end)
    
    createConfigButton(ConfigButtonsFrame, "Delete Config", function()
        local configName = ConfigInput.Text
        if configName and configName ~= "" then
            deleteConfig(configName)
            ConfigInput.Text = ""
            scanConfigs()
        end
    end)
    
    createConfigButton(ConfigButtonsFrame, "Scan Configs", function()
        scanConfigs()
    end)
    
    local SystemButtonsFrame = Instance.new("Frame")
    SystemButtonsFrame.Size = UDim2.new(1, 0, 0, 50)
    SystemButtonsFrame.Position = UDim2.new(0, 0, 0, 115)
    SystemButtonsFrame.BackgroundTransparency = 1
    SystemButtonsFrame.Parent = ConfigFrame
    
    local SystemLayout = Instance.new("UIListLayout")
    SystemLayout.Padding = UDim.new(0, 5)
    SystemLayout.Parent = SystemButtonsFrame
    
    createConfigButton(SystemButtonsFrame, "Reset Settings", function()
        settings = table.clone(defaultSettings)
        updateUIFromSettings()
        saveSettings()
    end)
    
    createConfigButton(SystemButtonsFrame, "Clear All", function()
        clearAll()
    end)
    
    local InfoFrame = Instance.new("Frame")
    InfoFrame.Size = UDim2.new(1, 0, 0, 20)
    InfoFrame.Position = UDim2.new(0, 0, 1, -20)
    InfoFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    InfoFrame.Parent = MainFrame
    
    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 8)
    InfoCorner.Parent = InfoFrame
    
    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, 0, 1, 0)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = "Uptime: 00:00:00 | Players: 0 | FPS: 0"
    InfoText.TextColor3 = Color3.fromRGB(150, 150, 150)
    InfoText.TextSize = 12
    InfoText.Font = Enum.Font.Gotham
    InfoText.Parent = InfoFrame
    
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragStart then
            update(input)
        end
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        playSound()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(MainFrame, tweenInfo, {Size = minimizedSize, Position = minimizedPosition}):Play()
            for _, frame in ipairs(contentFrames) do
                frame.Visible = false
            end
            TabsContainer.Visible = false
            InfoFrame.Visible = false
        else
            TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, menuWidth, 0, menuHeight), Position = defaultPosition}):Play()
            contentFrames[currentTab].Visible = true
            TabsContainer.Visible = true
            InfoFrame.Visible = true
        end
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        playSound()
        isVisible = not isVisible
        MainFrame.Visible = isVisible
    end)
    
    for _, frame in ipairs(scrollFrames) do
        frame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            frame.CanvasSize = UDim2.new(0, 0, 0, frame.UIListLayout.AbsoluteContentSize.Y + 10)
        end)
    end
    
    uiElements.ScreenGui = ScreenGui
    uiElements.MainFrame = MainFrame
    uiElements.InfoText = InfoText
    
    return ScreenGui
end

local function updateUIFromSettings()
    if uiElements.HitboxToggle then
        uiElements.HitboxToggle.update(settings.Combat.Hitbox.Enabled)
    end
    if uiElements.HitboxSize then
        uiElements.HitboxSize.update(settings.Combat.Hitbox.Size)
    end
    if uiElements.HitboxColor then
        uiElements.HitboxColor.update(settings.Combat.Hitbox.Color)
    end
    if uiElements.HitboxTransparency then
        uiElements.HitboxTransparency.update(settings.Combat.Hitbox.Transparency)
    end
    if uiElements.HitboxType then
        uiElements.HitboxType.update(settings.Combat.Hitbox.Type)
    end
    if uiElements.ESPToggle then
        uiElements.ESPToggle.update(settings.ESP.Enabled)
    end
    if uiElements.DistanceToggle then
        uiElements.DistanceToggle.update(settings.ESP.ShowDistance)
    end
    if uiElements.MaxDistance then
        uiElements.MaxDistance.update(settings.ESP.MaxDistance)
    end
    if uiElements.TracersToggle then
        uiElements.TracersToggle.update(settings.Tracers.Enabled)
    end
end

local function initialize()
    ensureFolderStructure()
    loadSettings()
    createMenu()
    updateUIFromSettings()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        createESP(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        clearESP(player)
        removeTracer(player)
        if hitboxCache[player.Character] then
            hitboxCache[player.Character]:Destroy()
            hitboxCache[player.Character] = nil
        end
    end)
    
    connections.renderStep = RunService.RenderStepped:Connect(function()
        updateAllESP()
        updateTimer()
        
        if uiElements.InfoText then
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            local playerCount = #Players:GetPlayers()
            uiElements.InfoText.Text = string.format("Uptime: %s | Players: %d | FPS: %d", formatTime(elapsedTime), playerCount, fps)
        end
        
        cleanupObjects()
    end)
    
    connections.heartbeat = RunService.Heartbeat:Connect(function()
        updateNoClip()
        disableShadows()
    end)
    
    initialized = true
end

local function cleanup()
    clearAll()
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    connections = {}
    
    if uiElements.ScreenGui then
        uiElements.ScreenGui:Destroy()
    end
    
    for _, sound in pairs(soundCache) do
        if sound then
            pcall(function() sound:Stop() end)
            pcall(function() sound:Destroy() end)
        end
    end
    soundCache = {}
end

local function restart()
    cleanup()
    task.wait(0.1)
    initialize()
end

local function toggleMenu()
    if uiElements.MainFrame then
        isVisible = not isVisible
        uiElements.MainFrame.Visible = isVisible
        playSound()
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleMenu()
    end
end)

initialize()

while true do
    task.wait(1)
    if not initialized then
        restart()
    end
end