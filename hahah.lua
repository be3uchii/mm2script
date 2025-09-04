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
    {"RightLowerLeg", "RightFoot"}
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
    
    uiElements[id] = toggleFrame
    return toggleFrame
end

local function createCleanSlider(parent, text, min, max, current, callback, id)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -8, 0, 40)
    sliderFrame.BackgroundTransparency = 1
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
    valueLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    valueLabel.TextTransparency = 0.1
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 4)
    sliderTrack.Position = UDim2.new(0, 0, 0, 20)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderTrack.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((current - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(76, 217, 100)
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new((current - min) / (max - min), -8, 0.5, -8)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.AutoButtonColor = false
    sliderButton.Text = ""
    sliderButton.Parent = sliderTrack
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = sliderButton
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(76, 217, 100)
    glow.Thickness = 1.5
    glow.Transparency = 0.7
    glow.Parent = sliderButton
    
    local isSliding = false
    
    local function updateSlider(input)
        local position = UDim2.new(math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1), -8, 0.5, -8)
        local value = math.floor(min + (position.X.Scale * (max - min)))
        
        sliderButton.Position = position
        sliderFill.Size = UDim2.new(position.X.Scale, 0, 1, 0)
        valueLabel.Text = tostring(value)
        
        callback(value)
        saveSettings()
    end
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            playSound()
            isSliding = true
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isSliding = false
                end
            end)
        end
    end)
    
    sliderButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isSliding then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isSliding then
            updateSlider(input)
        end
    end)
    
    uiElements[id] = sliderFrame
    return sliderFrame
end

local function createCleanDropdown(parent, text, options, default, callback, id)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, -8, 0, 22)
    dropdownFrame.BackgroundTransparency = 1
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
    dropdownButton.Text = default
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
    dropdownList.ScrollBarThickness = 4
    dropdownList.Visible = false
    dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropdownList.Parent = dropdownFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 1)
    listLayout.Parent = dropdownList
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = dropdownList
    
    for _, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, -8, 0, 22)
        optionButton.Position = UDim2.new(0, 4, 0, 0)
        optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        optionButton.TextSize = 12
        optionButton.Font = Enum.Font.Gotham
        optionButton.Parent = dropdownList
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 4)
        optionCorner.Parent = optionButton
        
        optionButton.MouseButton1Click:Connect(function()
            playSound()
            dropdownButton.Text = option
            dropdownList.Visible = false
            callback(option)
            saveSettings()
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        playSound()
        dropdownList.Visible = not dropdownList.Visible
    end)
    
    uiElements[id] = dropdownFrame
    return dropdownFrame
end

local function createCleanButton(parent, text, callback, id)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 22)
    button.Position = UDim2.new(0, 4, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextSize = 13
    button.Font = Enum.Font.Gotham
    button.Parent = parent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(76, 217, 100)
    glow.Thickness = 1.5
    glow.Transparency = 0.7
    glow.Parent = button
    
    button.MouseButton1Click:Connect(function()
        playSound()
        callback()
    end)
    
    uiElements[id] = button
    return button
end

local function createCleanInput(parent, text, placeholder, callback, id)
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -8, 0, 22)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Parent = parent
    
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
    label.Parent = inputFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.3, 0, 1, 0)
    textBox.Position = UDim2.new(0.7, 0, 0, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    textBox.Text = ""
    textBox.PlaceholderText = placeholder
    textBox.TextColor3 = Color3.fromRGB(230, 230, 230)
    textBox.TextSize = 12
    textBox.Font = Enum.Font.Gotham
    textBox.Parent = inputFrame
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 4)
    textBoxCorner.Parent = textBox
    
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            playSound()
            callback(textBox.Text)
            textBox.Text = ""
        end
    end)
    
    uiElements[id] = inputFrame
    return inputFrame
end

local function createCleanColorPicker(parent, text, defaultColor, callback, id)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, -8, 0, 22)
    colorFrame.BackgroundTransparency = 1
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
    colorButton.BackgroundColor3 = defaultColor
    colorButton.Text = ""
    colorButton.Parent = colorFrame
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 4)
    colorCorner.Parent = colorButton
    
    local glow = Instance.new("UIStroke")
    glow.Color = defaultColor
    glow.Thickness = 1.5
    glow.Transparency = 0.7
    glow.Parent = colorButton
    
    colorButton.MouseButton1Click:Connect(function()
        playSound()
        local r, g, b = defaultColor.R, defaultColor.G, defaultColor.B
        local newColor = Color3.new(math.clamp(r + 0.1, 0, 1), math.clamp(g + 0.1, 0, 1), math.clamp(b + 0.1, 0, 1))
        colorButton.BackgroundColor3 = newColor
        glow.Color = newColor
        callback(newColor)
        saveSettings()
    end)
    
    uiElements[id] = colorFrame
    return colorFrame
end

local function createCleanTransparencySlider(parent, text, current, callback, id)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -8, 0, 40)
    sliderFrame.BackgroundTransparency = 1
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
    valueLabel.Text = string.format("%.1f", current)
    valueLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    valueLabel.TextTransparency = 0.1
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 4)
    sliderTrack.Position = UDim2.new(0, 0, 0, 20)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderTrack.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(current, 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(76, 217, 100)
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new(current, -8, 0.5, -8)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.AutoButtonColor = false
    sliderButton.Text = ""
    sliderButton.Parent = sliderTrack
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = sliderButton
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(76, 217, 100)
    glow.Thickness = 1.5
    glow.Transparency = 0.7
    glow.Parent = sliderButton
    
    local isSliding = false
    
    local function updateSlider(input)
        local position = UDim2.new(math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1), -8, 0.5, -8)
        local value = math.floor(position.X.Scale * 10) / 10
        
        sliderButton.Position = position
        sliderFill.Size = UDim2.new(position.X.Scale, 0, 1, 0)
        valueLabel.Text = string.format("%.1f", value)
        
        callback(value)
        saveSettings()
    end
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            playSound()
            isSliding = true
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isSliding = false
                end
            end)
        end
    end)
    
    sliderButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isSliding then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isSliding then
            updateSlider(input)
        end
    end)
    
    uiElements[id] = sliderFrame
    return sliderFrame
end

local function createTabButton(parent, text, index)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.33, -2, 0, 25)
    button.Position = UDim2.new((index - 1) * 0.33, 0, 0, 0)
    button.BackgroundColor3 = index == 1 and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(30, 30, 30)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.Parent = parent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        playSound()
        currentTab = index
        for i, frame in ipairs(contentFrames) do
            frame.Visible = i == index
        end
        for i, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = i == index and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(30, 30, 30)
        end
    end)
    
    table.insert(tabButtons, button)
    return button
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
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 25)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.2, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SILENCE"
    title.TextColor3 = Color3.fromRGB(230, 230, 230)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 25, 0, 25)
    minimizeButton.Position = UDim2.new(1, -25, 0, 0)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    minimizeButton.TextSize = 16
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -50, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = header
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, -8, 0, 25)
    tabContainer.Position = UDim2.new(0, 4, 0, 30)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    for i, tabName in ipairs(tabs) do
        createTabButton(tabContainer, tabName, i)
    end
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -8, 1, -60)
    contentContainer.Position = UDim2.new(0, 4, 0, 60)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame
    
    for i = 1, #tabs do
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.Position = UDim2.new(0, 0, 0, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.Visible = i == 1
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Parent = contentContainer
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 4)
        listLayout.Parent = scrollFrame
        
        table.insert(contentFrames, scrollFrame)
        table.insert(scrollFrames, scrollFrame)
    end
    
    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, 0, 0, 20)
    footer.Position = UDim2.new(0, 0, 1, -20)
    footer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    footer.Parent = mainFrame
    
    local footerCorner = Instance.new("UICorner")
    footerCorner.CornerRadius = UDim.new(0, 8)
    footerCorner.Parent = footer
    
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(0.5, 0, 1, 0)
    timerLabel.Position = UDim2.new(0, 5, 0, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "00:00:00"
    timerLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    timerLabel.TextSize = 12
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.TextXAlignment = Enum.TextXAlignment.Left
    timerLabel.Parent = footer
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.5, 0, 1, 0)
    statusLabel.Position = UDim2.new(0.5, -5, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "ACTIVE"
    statusLabel.TextColor3 = Color3.fromRGB(76, 217, 100)
    statusLabel.TextSize = 12
    timerLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Right
    statusLabel.Parent = footer
    
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                end
            end)
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragStart then
            update(input)
        end
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        playSound()
        isMinimized = not isMinimized
        if isMinimized then
            mainFrame:TweenSize(minimizedSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            mainFrame:TweenPosition(minimizedPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            minimizeButton.Text = "+"
        else
            mainFrame:TweenSize(UDim2.new(0, menuWidth, 0, menuHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            mainFrame:TweenPosition(defaultPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            minimizeButton.Text = "_"
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        playSound()
        isVisible = false
        screenGui:Destroy()
        clearAll()
    end)
    
    connections.updateTimer = RunService.RenderStepped:Connect(function()
        updateTimer()
        timerLabel.Text = formatTime(elapsedTime)
    end)
    
    uiElements.main = screenGui
    return screenGui
end

local function createCombatTab()
    local combatFrame = scrollFrames[1]
    
    createCleanToggle(combatFrame, "Hitbox ESP", settings.Combat.Hitbox.Enabled, function(value)
        settings.Combat.Hitbox.Enabled = value
        if not value then
            clearHitboxes()
        end
    end, "hitboxToggle")
    
    createCleanSlider(combatFrame, "Hitbox Size", 1, 10, settings.Combat.Hitbox.Size, function(value)
        settings.Combat.Hitbox.Size = value
    end, "hitboxSize")
    
    createCleanDropdown(combatFrame, "Hitbox Type", {"Box", "Sphere"}, settings.Combat.Hitbox.Type, function(value)
        settings.Combat.Hitbox.Type = value
        clearHitboxes()
    end, "hitboxType")
    
    createCleanColorPicker(combatFrame, "Hitbox Color", settings.Combat.Hitbox.Color, function(value)
        settings.Combat.Hitbox.Color = value
    end, "hitboxColor")
    
    createCleanTransparencySlider(combatFrame, "Hitbox Transparency", settings.Combat.Hitbox.Transparency, function(value)
        settings.Combat.Hitbox.Transparency = value
    end, "hitboxTransparency")
end

local function createESPTab()
    local espFrame = scrollFrames[2]
    
    createCleanToggle(espFrame, "ESP Enabled", settings.ESP.Enabled, function(value)
        settings.ESP.Enabled = value
        if not value then
            for player, _ in pairs(espCache) do
                if espCache[player] then
                    espCache[player].box.Visible = false
                    espCache[player].distanceText.Visible = false
                    if espCache[player].skeleton then
                        for _, line in pairs(espCache[player].skeleton) do
                            line.Visible = false
                        end
                    end
                end
            end
        end
    end, "espToggle")
    
    createCleanToggle(espFrame, "Show Distance", settings.ESP.ShowDistance, function(value)
        settings.ESP.ShowDistance = value
    end, "distanceToggle")
    
    createCleanSlider(espFrame, "Max Distance", 50, 500, settings.ESP.MaxDistance, function(value)
        settings.ESP.MaxDistance = value
    end, "maxDistance")
    
    createCleanToggle(espFrame, "Show Skeleton", settings.ESP.ShowSkeleton, function(value)
        settings.ESP.ShowSkeleton = value
    end, "skeletonToggle")
    
    createCleanToggle(espFrame, "Tracers", settings.Tracers.Enabled, function(value)
        settings.Tracers.Enabled = value
        if not value then
            for _, tracer in pairs(tracers) do
                tracer.Visible = false
            end
        end
    end, "tracersToggle")
end

local function createConfigTab()
    local configFrame = scrollFrames[3]
    
    local configList = Instance.new("ScrollingFrame")
    configList.Size = UDim2.new(1, 0, 0.6, 0)
    configList.Position = UDim2.new(0, 0, 0, 0)
    configList.BackgroundTransparency = 1
    configList.ScrollBarThickness = 4
    configList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    configList.CanvasSize = UDim2.new(0, 0, 0, 0)
    configList.Parent = configFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = configList
    
    local function refreshConfigList()
        for _, button in ipairs(configButtons) do
            button:Destroy()
        end
        configButtons = {}
        
        local configs = scanConfigs()
        for _, configName in ipairs(configs) do
            local button = createCleanButton(configList, configName, function()
                loadConfig(configName)
            end, "config_"..configName)
            table.insert(configButtons, button)
        end
    end
    
    createCleanInput(configFrame, "Config Name", "Enter name...", function(text)
        if text and text ~= "" then
            saveConfig(text)
            refreshConfigList()
        end
    end, "configInput")
    
    createCleanButton(configFrame, "Refresh Configs", function()
        refreshConfigList()
    end, "refreshButton")
    
    createCleanButton(configFrame, "Delete Current", function()
        if #settings.Configs > 0 then
            deleteConfig(settings.Configs[#settings.Configs])
            refreshConfigList()
        end
    end, "deleteButton")
    
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
    
    refreshConfigList()
end

local function initialize()
    if initialized then return end
    
    ensureFolderStructure()
    loadSettings()
    
    local ui = createMainUI()
    createCombatTab()
    createESPTab()
    createConfigTab()
    
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
    end)
    
    connections.espUpdate = RunService.RenderStepped:Connect(function()
        if not safeMode then
            updateAllESP()
        end
        cleanupObjects()
    end)
    
    connections.characterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        updateNoClip()
    end)
    
    if LocalPlayer.Character then
        updateNoClip()
    end
    
    if settings.System.PerformanceMode then
        disableShadows()
    end
    
    initialized = true
end

local function checkKey()
    local keyPath = cacheFolder.."/"..keyFileName
    if not isfile(keyPath) then
        local generatedKey = generateSecureKey(32)
        secureWrite(keyPath, generatedKey)
        return true
    end
    
    local storedKey = readfile(keyPath)
    if #storedKey ~= 32 then
        delfile(keyPath)
        return false
    end
    
    return true
end

local function validateKey()
    if keyValidationAttempts >= maxKeyAttempts then
        safeMode = true
        return false
    end
    
    local success = safeCall(checkKey, "validateKey")
    if not success then
        keyValidationAttempts = keyValidationAttempts + 1
        return false
    end
    
    return true
end

if validateKey() then
    initialize()
else
    safeMode = true
end