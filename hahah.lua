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
local backupFolder = "SilenceBackups"
local cacheFolder = "SilenceCache"

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
        MaxDistance = 200,
        ShowSkeleton = false
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
local skeletonParts = {
    "Head", "UpperTorso", "LowerTorso", 
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand", 
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", 
    "RightUpperLeg", "RightLowerLeg", "RightFoot"
}

local skeletonConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightUpperLeg", "RightFoot"}
}

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
        if espData and espData.skeleton then
            for _, line in pairs(espData.skeleton) do
                pcall(function() line:Remove() end)
            end
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
    tracer.Color = Color3.fromRGB(255, 255, 255)
    tracer.Thickness = 1
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

local function createSkeleton(character)
    local skeleton = {}
    for _, connection in ipairs(skeletonConnections) do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Thickness = 1
        line.Transparency = 0.8
        line.ZIndex = 1
        skeleton[connection[1]..connection[2]] = line
    end
    return skeleton
end

local function updateSkeleton(character, skeleton)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    for _, connection in ipairs(skeletonConnections) do
        local part1 = character:FindFirstChild(connection[1])
        local part2 = character:FindFirstChild(connection[2])
        local line = skeleton[connection[1]..connection[2]]
        
        if part1 and part2 then
            local pos1, onScreen1 = workspace.CurrentCamera:WorldToViewportPoint(part1.Position)
            local pos2, onScreen2 = workspace.CurrentCamera:WorldToViewportPoint(part2.Position)
            
            if onScreen1 and onScreen2 then
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
                line.Visible = settings.ESP.Enabled and settings.ESP.ShowSkeleton
                line.Color = Color3.fromRGB(255, 255, 255)
                line.Thickness = 1
                line.Transparency = 0.8
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

local function createESP(player)
    if not player or player == LocalPlayer then return end
    
    if espCache[player] then
        if espCache[player].box then pcall(function() espCache[player].box:Remove() end) end
        if espCache[player].distanceText then pcall(function() espCache[player].distanceText:Remove() end) end
        if espCache[player].skeleton then
            for _, line in pairs(espCache[player].skeleton) do
                pcall(function() line:Remove() end)
            end
        end
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
        distanceText = distanceText,
        skeleton = {}
    }
    
    if not playerConnections[player] then
        playerConnections[player] = {}
    end
    
    createTracer(player)
    
    local function onCharacterAdded(character)
        if not character or not character.Parent then return end
        
        espCache[player].skeleton = createSkeleton(character)
        
        local humanoid = character:WaitForChild("Humanoid")
        
        playerConnections[player].died = humanoid.Died:Connect(function()
            if espCache[player] then
                espCache[player].box.Visible = false
                espCache[player].distanceText.Visible = false
                if espCache[player].skeleton then
                    for _, line in pairs(espCache[player].skeleton) do
                        line.Visible = false
                    end
                end
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
                    if espCache[player].skeleton then
                        for _, line in pairs(espCache[player].skeleton) do
                            line.Visible = false
                        end
                    end
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
        if espData.skeleton then
            for _, line in pairs(espData.skeleton) do
                line.Visible = false
            end
        end
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        box.Visible = false
        distanceText.Visible = false
        if espData.skeleton then
            for _, line in pairs(espData.skeleton) do
                line.Visible = false
            end
        end
        return
    end
    
    local head = character:FindFirstChild("Head")
    if not head then
        box.Visible = false
        distanceText.Visible = false
        if espData.skeleton then
            for _, line in pairs(espData.skeleton) do
                line.Visible = false
            end
        end
        return
    end
    
    local distance = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        box.Visible = false
        distanceText.Visible = false
        if espData.skeleton then
            for _, line in pairs(espData.skeleton) do
                line.Visible = false
            end
        end
        return
    end
    
    local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        box.Visible = false
        distanceText.Visible = false
        if espData.skeleton then
            for _, line in pairs(espData.skeleton) do
                line.Visible = false
            end
        end
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
    
    if settings.ESP.ShowSkeleton and espData.skeleton then
        updateSkeleton(character, espData.skeleton)
    elseif espData.skeleton then
        for _, line in pairs(espData.skeleton) do
            line.Visible = false
        end
    end
end

local function clearESP(player)
    if espCache[player] then
        if espCache[player].box then pcall(function() espCache[player].box:Remove() end) end
        if espCache[player].distanceText then pcall(function() espCache[player].distanceText:Remove() end) end
        if espCache[player].skeleton then
            for _, line in pairs(espCache[player].skeleton) do
                pcall(function() line:Remove() end)
            end
        end
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
    
    uiElements[id] = {frame = toggleFrame, value = value}
    return toggleFrame
end

local function createSlider(parent, text, min, max, current, callback, id)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -8, 0, 40)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Position = UDim2.new(0, 4, 0, 0)
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
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
    valueLabel.Size = UDim2.new(0.3, 0, 0, 16)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(current)
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextTransparency = 0.2
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0.5, 0)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    track.BorderSizePixel = 0
    track.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((current - min) / (max - min), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(76, 217, 100)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local thumb = Instance.new("TextButton")
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.Position = UDim2.new((current - min) / (max - min), -6, 0.5, -6)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.Text = ""
    thumb.AutoButtonColor = false
    thumb.Parent = sliderFrame
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(76, 217, 100)
    glow.Thickness = 1.5
    glow.Transparency = 0.7
    glow.Parent = thumb
    
    local dragging = false
    
    local function updateValue(input)
        local pos = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        pos = math.clamp(pos, 0, 1)
        local value = math.floor(min + pos * (max - min))
        valueLabel.Text = tostring(value)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        thumb.Position = UDim2.new(pos, -6, 0.5, -6)
        callback(value)
    end
    
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            playSound()
            dragging = true
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    saveSettings()
                end
            end)
        end
    end)
    
    thumb.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateValue(input)
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            playSound()
            updateValue(input)
            dragging = true
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    saveSettings()
                end
            end)
        end
    end)
    
    uiElements[id] = {frame = sliderFrame, value = current}
    return sliderFrame
end

local function createDropdown(parent, text, options, current, callback, id)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, -8, 0, 22)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Position = UDim2.new(0, 4, 0, 0)
    dropdownFrame.Parent = parent
    
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
    label.Parent = dropdownFrame
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(0.3, 0, 1, 0)
    dropdownButton.Position = UDim2.new(0.7, 0, 0, 0)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = options[current] or "Select"
    dropdownButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    dropdownButton.TextSize = 12
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.Parent = dropdownFrame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = dropdownButton
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Size = UDim2.new(0.3, 0, 0, 100)
    dropdownList.Position = UDim2.new(0.7, 0, 1, 2)
    dropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropdownList.ScrollBarThickness = 3
    dropdownList.ScrollBarImageColor3 = Color3.fromRGB(76, 217, 100)
    dropdownList.Parent = dropdownFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = dropdownList
    
    local isOpen = false
    
    local function updateList()
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 22)
        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 22)
            optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            optionButton.BorderSizePixel = 0
            optionButton.Text = option
            optionButton.TextColor3 = Color3.fromRGB(230, 230, 230)
            optionButton.TextSize = 12
            optionButton.Font = Enum.Font.Gotham
            optionButton.Parent = dropdownList
            
            optionButton.MouseButton1Click:Connect(function()
                playSound()
                dropdownButton.Text = option
                callback(i, option)
                dropdownList.Visible = false
                isOpen = false
                saveSettings()
            end)
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        playSound()
        isOpen = not isOpen
        dropdownList.Visible = isOpen
        if isOpen then
            updateList()
        end
    end)
    
    uiElements[id] = {frame = dropdownFrame, value = current}
    return dropdownFrame
end

local function createColorPicker(parent, text, currentColor, callback, id)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, -8, 0, 22)
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
    colorButton.Size = UDim2.new(0.3, 0, 1, 0)
    colorButton.Position = UDim2.new(0.7, 0, 0, 0)
    colorButton.BackgroundColor3 = currentColor
    colorButton.BorderSizePixel = 0
    colorButton.Text = ""
    colorButton.Parent = colorFrame
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 4)
    colorCorner.Parent = colorButton
    
    colorButton.MouseButton1Click:Connect(function()
        playSound()
        local colorPicker = Instance.new("Frame")
        colorPicker.Size = UDim2.new(0, 200, 0, 150)
        colorPicker.Position = UDim2.new(0, colorButton.AbsolutePosition.X, 0, colorButton.AbsolutePosition.Y + 25)
        colorPicker.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        colorPicker.BorderSizePixel = 0
        colorPicker.ZIndex = 10
        colorPicker.Parent = PlayerGui
        
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 4)
        colorCorner.Parent = colorPicker
        
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 20, 0, 20)
        closeButton.Position = UDim2.new(1, -20, 0, 0)
        closeButton.BackgroundTransparency = 1
        closeButton.Text = "X"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextSize = 14
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Parent = colorPicker
        
        closeButton.MouseButton1Click:Connect(function()
            playSound()
            colorPicker:Destroy()
        end)
        
        local colorGrid = Instance.new("Frame")
        colorGrid.Size = UDim2.new(0, 180, 0, 100)
        colorGrid.Position = UDim2.new(0, 10, 0, 30)
        colorGrid.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        colorGrid.BorderSizePixel = 0
        colorGrid.Parent = colorPicker
        
        local hueSlider = Instance.new("Frame")
        hueSlider.Size = UDim2.new(0, 20, 0, 100)
        hueSlider.Position = UDim2.new(1, -30, 0, 30)
        hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueSlider.BorderSizePixel = 0
        hueSlider.Parent = colorPicker
        
        local selectedColor = currentColor
        
        local function updateColor()
            colorButton.BackgroundColor3 = selectedColor
            callback(selectedColor)
            saveSettings()
        end
        
        colorPicker.Destroying:Connect(updateColor)
    end)
    
    uiElements[id] = {frame = colorFrame, value = currentColor}
    return colorFrame
end

local function createButton(parent, text, callback, id)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -8, 0, 22)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Position = UDim2.new(0, 4, 0, 0)
    buttonFrame.Parent = parent
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextSize = 13
    button.Font = Enum.Font.Gotham
    button.Parent = buttonFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        playSound()
        callback()
    end)
    
    uiElements[id] = {frame = buttonFrame}
    return buttonFrame
end

local function createLabel(parent, text, size, id)
    local labelFrame = Instance.new("Frame")
    labelFrame.Size = UDim2.new(1, -8, 0, size or 20)
    labelFrame.BackgroundTransparency = 1
    labelFrame.Position = UDim2.new(0, 4, 0, 0)
    labelFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextTransparency = 0.1
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = labelFrame
    
    uiElements[id] = {frame = labelFrame}
    return labelFrame
end

local function createSeparator(parent, height)
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, -8, 0, height or 1)
    separator.Position = UDim2.new(0, 4, 0, 0)
    separator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    separator.BorderSizePixel = 0
    separator.Parent = parent
    
    return separator
end

local function createTabButton(tabName, index)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0.3, 0, 0, 25)
    tabButton.Position = UDim2.new(0.05 + (index-1)*0.3, 0, 0, 0)
    tabButton.BackgroundColor3 = index == 1 and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(30, 30, 30)
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    tabButton.TextSize = 12
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = uiElements.tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = tabButton
    
    tabButton.MouseButton1Click:Connect(function()
        playSound()
        currentTab = index
        for i, frame in ipairs(contentFrames) do
            frame.Visible = i == index
        end
        for i, button in ipairs(tabButtons) do
            button.BackgroundColor3 = i == index and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(30, 30, 30)
        end
    end)
    
    table.insert(tabButtons, tabButton)
    return tabButton
end

local function createMainUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilenceUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    mainFrame.Position = defaultPosition
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.2, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SILENCE"
    title.TextColor3 = Color3.fromRGB(76, 217, 100)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = header
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 20, 0, 20)
    minimizeButton.Position = UDim2.new(1, -25, 0.5, -10)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    minimizeButton.TextSize = 16
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -5, 0.5, -10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 58, 58)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = header
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(0.9, 0, 0, 25)
    tabContainer.Position = UDim2.new(0.05, 0, 0, 35)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(0.9, 0, 0, menuHeight - 70)
    contentContainer.Position = UDim2.new(0.05, 0, 0, 65)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame
    
    uiElements.screenGui = screenGui
    uiElements.mainFrame = mainFrame
    uiElements.tabContainer = tabContainer
    uiElements.contentContainer = contentContainer
    
    for i, tabName in ipairs(tabs) do
        createTabButton(tabName, i)
        
        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Size = UDim2.new(1, 0, 1, 0)
        contentFrame.Position = UDim2.new(0, 0, 0, 0)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Visible = i == 1
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentFrame.ScrollBarThickness = 3
        contentFrame.ScrollBarImageColor3 = Color3.fromRGB(76, 217, 100)
        contentFrame.Parent = contentContainer
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 5)
        listLayout.Parent = contentFrame
        
        table.insert(contentFrames, contentFrame)
        table.insert(scrollFrames, contentFrame)
    end
    
    local combatFrame = contentFrames[1]
    local espFrame = contentFrames[2]
    local configFrame = contentFrames[3]
    
    createCleanToggle(combatFrame, "Hitbox ESP", settings.Combat.Hitbox.Enabled, function(value)
        settings.Combat.Hitbox.Enabled = value
        if not value then
            clearHitboxes()
        end
    end, "hitboxToggle")
    
    createSlider(combatFrame, "Hitbox Size", 1, 10, settings.Combat.Hitbox.Size, function(value)
        settings.Combat.Hitbox.Size = value
    end, "hitboxSize")
    
    createDropdown(combatFrame, "Hitbox Type", {"Box", "Sphere"}, settings.Combat.Hitbox.Type == "Sphere" and 2 or 1, function(index, value)
        settings.Combat.Hitbox.Type = value
    end, "hitboxType")
    
    createSlider(combatFrame, "Hitbox Transparency", 0, 1, settings.Combat.Hitbox.Transparency, function(value)
        settings.Combat.Hitbox.Transparency = value
    end, "hitboxTransparency")
    
    createCleanToggle(espFrame, "ESP", settings.ESP.Enabled, function(value)
        settings.ESP.Enabled = value
        if not value then
            for player, espData in pairs(espCache) do
                if espData.box then
                    espData.box.Visible = false
                end
                if espData.distanceText then
                    espData.distanceText.Visible = false
                end
                if espData.skeleton then
                    for _, line in pairs(espData.skeleton) do
                        line.Visible = false
                    end
                end
            end
        end
    end, "espToggle")
    
    createCleanToggle(espFrame, "Show Distance", settings.ESP.ShowDistance, function(value)
        settings.ESP.ShowDistance = value
    end, "distanceToggle")
    
    createCleanToggle(espFrame, "Show Skeleton", settings.ESP.ShowSkeleton, function(value)
        settings.ESP.ShowSkeleton = value
    end, "skeletonToggle")
    
    createSlider(espFrame, "Max Distance", 50, 1000, settings.ESP.MaxDistance, function(value)
        settings.ESP.MaxDistance = value
    end, "maxDistance")
    
    createCleanToggle(espFrame, "Tracers", settings.Tracers.Enabled, function(value)
        settings.Tracers.Enabled = value
        if not value then
            for _, tracer in pairs(tracers) do
                tracer.Visible = false
            end
        end
    end, "tracersToggle")
    
    local configList = scanConfigs()
    local configDropdown = createDropdown(configFrame, "Select Config", configList, 1, function(index, value)
        settings.selectedConfig = value
    end, "configSelect")
    
    createButton(configFrame, "Load Config", function()
        if settings.selectedConfig then
            loadConfig(settings.selectedConfig)
            updateUIFromSettings()
        end
    end, "loadConfig")
    
    createButton(configFrame, "Save Config", function()
        local configName = "config_"..os.date("%Y%m%d_%H%M%S")
        saveConfig(configName)
        scanConfigs()
    end, "saveConfig")
    
    createButton(configFrame, "Delete Config", function()
        if settings.selectedConfig then
            deleteConfig(settings.selectedConfig)
            scanConfigs()
        end
    end, "deleteConfig")
    
    createCleanToggle(configFrame, "Performance Mode", settings.System.PerformanceMode, function(value)
        settings.System.PerformanceMode = value
        performanceMode = value
        if value then
            disableShadows()
        end
    end, "performanceToggle")
    
    createCleanToggle(configFrame, "Safe Mode", settings.System.SafeMode, function(value)
        settings.System.SafeMode = value
        safeMode = value
        if value then
            clearAll()
        end
    end, "safeToggle")
    
    createCleanToggle(configFrame, "Debug Mode", settings.System.DebugMode, function(value)
        settings.System.DebugMode = value
        debugMode = value
    end, "debugToggle")
    
    local timerLabel = createLabel(configFrame, "Uptime: 00:00:00", 20, "timerLabel")
    
    minimizeButton.MouseButton1Click:Connect(function()
        playSound()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(mainFrame, tweenInfo, {Size = minimizedSize, Position = minimizedPosition}):Play()
            for _, frame in ipairs(contentFrames) do
                frame.Visible = false
            end
        else
            TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, menuWidth, 0, menuHeight), Position = defaultPosition}):Play()
            for i, frame in ipairs(contentFrames) do
                frame.Visible = i == currentTab
            end
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        playSound()
        isVisible = false
        TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.15)
        screenGui:Destroy()
        clearAll()
    end)
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    header.InputBegan:Connect(function(input)
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
    
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    return screenGui
end

local function updateUIFromSettings()
    for id, element in pairs(uiElements) do
        if id == "hitboxToggle" then
            element.value = settings.Combat.Hitbox.Enabled
        elseif id == "hitboxSize" then
            element.value = settings.Combat.Hitbox.Size
        elseif id == "hitboxType" then
            element.value = settings.Combat.Hitbox.Type == "Sphere" and 2 or 1
        elseif id == "hitboxTransparency" then
            element.value = settings.Combat.Hitbox.Transparency
        elseif id == "espToggle" then
            element.value = settings.ESP.Enabled
        elseif id == "distanceToggle" then
            element.value = settings.ESP.ShowDistance
        elseif id == "skeletonToggle" then
            element.value = settings.ESP.ShowSkeleton
        elseif id == "maxDistance" then
            element.value = settings.ESP.MaxDistance
        elseif id == "tracersToggle" then
            element.value = settings.Tracers.Enabled
        elseif id == "performanceToggle" then
            element.value = settings.System.PerformanceMode
        elseif id == "safeToggle" then
            element.value = settings.System.SafeMode
        elseif id == "debugToggle" then
            element.value = settings.System.DebugMode
        end
    end
end

local function initialize()
    if initialized then return end
    
    ensureFolderStructure()
    loadSettings()
    
    if settings.System.SafeMode then
        safeMode = true
        return
    end
    
    if settings.System.PerformanceMode then
        performanceMode = true
        disableShadows()
    end
    
    debugMode = settings.System.DebugMode
    
    createMainUI()
    updateUIFromSettings()
    
    connections.playerAdded = Players.PlayerAdded:Connect(function(player)
        createESP(player)
        createTracer(player)
    end)
    
    connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        clearESP(player)
        removeTracer(player)
        if hitboxCache[player.Character] then
            hitboxCache[player.Character]:Destroy()
            hitboxCache[player.Character] = nil
        end
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
            createTracer(player)
        end
    end
    
    connections.renderStep = RunService.RenderStepped:Connect(function()
        if safeMode then return end
        
        updateAllESP()
        updateTimer()
        
        if uiElements.timerLabel then
            uiElements.timerLabel.frame.TextLabel.Text = "Uptime: "..formatTime(elapsedTime)
        end
        
        cleanupObjects()
        
        if performanceMode then
            disableShadows()
        end
        
        if settings.System.DebugMode and debugMode then
            updateNoClip()
        end
    end)
    
    connections.characterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        if settings.System.DebugMode and debugMode then
            updateNoClip()
        end
    end)
    
    initialized = true
end

local function main()
    local success, err = pcall(function()
        initialize()
    end)
    
    if not success then
        safeMode = true
        settings.System.SafeMode = true
        saveSettings()
    end
end

main()