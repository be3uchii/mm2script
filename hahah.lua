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
local tabs = {"Combat", "ESP", "Config", "Music"}
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local minimizedSize = UDim2.new(0, 90, 0, 25)
local minimizedPosition = UDim2.new(0.5, -45, 0.01, 0)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)
local keyFileName = "silence_key"
local configFolder = "SilenceConfig"
local configFile = "settings.txt"
local backupFolder = "SilenceBackups"
local logFile = "silence_logs.txt"

setfpscap(900)

local colors = {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(0, 0, 0),
    Color3.fromRGB(255, 0, 0)
}

local transparencies = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9}

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
        MaxDistance = 200
    },
    Tracers = {
        Enabled = false
    },
    Configs = {},
    Music = {
        Volume = 0.5,
        CurrentTrack = 1
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
local musicTracks = {
    {id = "5409360995", name = "Dion Timmer"},
    {id = "129098116998483", name = "Toma funk"},
    {id = "120817494107898", name = "Backrooms"},
    {id = "106702966034033", name = "Squid game"},
    {id = "98364034458260", name = "i love you so"},
    {id = "81477881808390", name = "madkid - распять"},
    {id = "105663787518318", name = "Fuck Love"},
    {id = "123994197918972", name = "Roblox delete mom"},
    {id = "104787023663784", name = "Dark Killer"}
}

local currentTrack = settings.Music.CurrentTrack
local musicSoundInstance = nil
local isMusicPlaying = false
local musicSliderDragging = false
local musicUIElements = {}
local musicRenderConnection = nil
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

local function logMessage(message)
    ensureConfigFolder()
    if not isfolder(backupFolder) then
        makefolder(backupFolder)
    end
    
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logEntry = string.format("[%s] %s\n", timestamp, tostring(message))
    
    if isfile(configFolder.."/"..logFile) then
        local fileSize = readfile(configFolder.."/"..logFile):len()
        if fileSize > 1000000 then
            local backupName = os.date("%Y%m%d_%H%M%S").."_log_backup.txt"
            writefile(backupFolder.."/"..backupName, readfile(configFolder.."/"..logFile))
            writefile(configFolder.."/"..logFile, logEntry)
        else
            appendfile(configFolder.."/"..logFile, logEntry)
        end
    else
        writefile(configFolder.."/"..logFile, logEntry)
    end
end

local function handleError(errorMsg, location)
    errorCount = errorCount + 1
    logMessage(string.format("ERROR in %s: %s", location or "unknown", tostring(errorMsg)))
    
    if errorCount >= maxErrors then
        safeMode = true
        logMessage("ENTERED SAFE MODE DUE TO TOO MANY ERRORS")
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

local function generateKey(length)
    local chars = {}
    local charSets = {
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        "abcdefghijklmnopqrstuvwxyz",
        "0123456789",
        "!@#$%^&*()_+-=[]{}|;:,.<>?"
    }
    
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

local function ensureConfigFolder()
    if not isfolder(configFolder) then
        makefolder(configFolder)
    end
    if not isfolder(backupFolder) then
        makefolder(backupFolder)
    end
end

local function createBackup()
    ensureConfigFolder()
    local backupName = os.date("%Y%m%d_%H%M%S").."_backup.txt"
    local settingsPath = configFolder.."/"..configFile
    
    if isfile(settingsPath) then
        writefile(backupFolder.."/"..backupName, readfile(settingsPath))
    end
    
    for _, configName in ipairs(settings.Configs) do
        local configPath = configFolder.."/"..configName..".txt"
        if isfile(configPath) then
            local configBackupName = backupName:gsub("_backup.txt", "_"..configName..".txt")
            writefile(backupFolder.."/"..configBackupName, readfile(configPath))
        end
    end
end

local function saveSettings()
    ensureConfigFolder()
    local tempPath = configFolder.."/temp_"..configFile
    local finalPath = configFolder.."/"..configFile
    
    local serializedSettings = {Configs = settings.Configs, PlayerInfo = settings.PlayerInfo, Music = settings.Music}
    
    safeCall(function()
        writefile(tempPath, HttpService:JSONEncode(serializedSettings))
        if isfile(finalPath) then
            delfile(finalPath)
        end
        writefile(finalPath, readfile(tempPath))
        delfile(tempPath)
        
        if os.time() - lastBackupTime > backupInterval then
            createBackup()
            lastBackupTime = os.time()
        end
    end, "saveSettings")
end

local function loadSettings()
    ensureConfigFolder()
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
                if result.Music then
                    settings.Music.Volume = result.Music.Volume or 0.5
                    settings.Music.CurrentTrack = result.Music.CurrentTrack or 1
                    currentTrack = settings.Music.CurrentTrack
                end
            end
        end, "loadSettings")
    end
end

local function saveConfig(configName)
    ensureConfigFolder()
    local configPath = configFolder.."/"..configName..".txt"
    
    safeCall(function()
        local serializedSettings = deepCopy(settings)
        writefile(configPath, HttpService:JSONEncode(serializedSettings))
        
        if not table.find(settings.Configs, configName) then
            table.insert(settings.Configs, configName)
            saveSettings()
        end
    end, "saveConfig")
end

local function loadConfig(configName)
    local configPath = configFolder.."/"..configName..".txt"
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
    local configPath = configFolder.."/"..configName..".txt"
    
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
    ensureConfigFolder()
    local files = listfiles(configFolder)
    local foundConfigs = {}
    
    safeCall(function()
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
    
    if musicSoundInstance then
        pcall(function()
            musicSoundInstance:Stop()
            musicSoundInstance:Destroy()
        end)
        musicSoundInstance = nil
    end
    
    if musicRenderConnection then
        pcall(function() musicRenderConnection:Disconnect() end)
        musicRenderConnection = nil
    end
    
    cleanupObjects()
end

local function disableShadows()
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
    
    createTracer(player)
    
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
            if tracers[player] then
                tracers[player].Visible = false
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
    colorFrame.Size = UDim2.new(1, -8, 0, 18)
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
        clearHitboxes()
        updateAllESP()
    end, "hitboxType")
    
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
    
    createCleanToggle(espScrollFrame, "Show Tracers", settings.Tracers.Enabled, function(value)
        settings.Tracers.Enabled = value
        if not value then
            for _, tracer in pairs(tracers) do
                tracer.Visible = false
            end
        end
        updateAllESP()
    end, "tracersEnabled")
    
    local distanceValues = {50, 100, 150, 200, 250, 300, 500, 1000}
    createValueChanger(espScrollFrame, "Max Distance", distanceValues, settings.ESP.MaxDistance, function(value)
        settings.ESP.MaxDistance = value
        updateAllESP()
    end, "espMaxDistance")
end

local function clearMusicUI()
    if musicRenderConnection then
        musicRenderConnection:Disconnect()
        musicRenderConnection = nil
    end
    
    if musicSoundInstance then
        musicSoundInstance:Stop()
        musicSoundInstance:Destroy()
        musicSoundInstance = nil
    end
    
    for _, element in pairs(musicUIElements) do
        if element and element.Parent then
            element:Destroy()
        end
    end
    musicUIElements = {}
end

local function refreshMusicUI()
    local musicScrollFrame = scrollFrames[4]
    if not musicScrollFrame then return end
    
    for _, child in ipairs(musicScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    clearMusicUI()
    
    local function formatMusicTime(seconds)
        local minutes = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02d:%02d", minutes, secs)
    end
    
    local trackLabel = Instance.new("TextLabel")
    trackLabel.Name = "TrackLabel"
    trackLabel.Size = UDim2.new(1, -8, 0, 20)
    trackLabel.Position = UDim2.new(0, 4, 0, 0)
    trackLabel.BackgroundTransparency = 1
    trackLabel.Text = musicTracks[currentTrack].name
    trackLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    trackLabel.TextSize = 14
    trackLabel.Font = Enum.Font.GothamBold
    trackLabel.TextXAlignment = Enum.TextXAlignment.Center
    trackLabel.Parent = musicScrollFrame
    
    musicUIElements.trackLabel = trackLabel
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "SliderFrame"
    sliderFrame.Size = UDim2.new(1, -8, 0, 10)
    sliderFrame.Position = UDim2.new(0, 4, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    sliderFrame.Parent = musicScrollFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderFrame
    
    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    progressFill.Parent = sliderFrame
    sliderCorner:Clone().Parent = progressFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = "SliderButton"
    sliderButton.Size = UDim2.new(0, 12, 0, 12)
    sliderButton.Position = UDim2.new(0, -6, 0.5, -6)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.ZIndex = 2
    sliderButton.Parent = sliderFrame
    sliderCorner:Clone().Parent = sliderButton
    
    musicUIElements.sliderFrame = sliderFrame
    musicUIElements.progressFill = progressFill
    musicUIElements.sliderButton = sliderButton
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(1, -8, 0, 15)
    timeLabel.Position = UDim2.new(0, 4, 0, 40)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "00:00 / 00:00"
    timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    timeLabel.TextSize = 12
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextXAlignment = Enum.TextXAlignment.Center
    timeLabel.Parent = musicScrollFrame
    
    musicUIElements.timeLabel = timeLabel
    
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "ControlsFrame"
    controlsFrame.Size = UDim2.new(1, -8, 0, 40)
    controlsFrame.Position = UDim2.new(0, 4, 0, 60)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = musicScrollFrame
    
    local prevButton = Instance.new("ImageButton")
    prevButton.Name = "PrevButton"
    prevButton.Size = UDim2.new(0, 29, 0, 29)
    prevButton.Position = UDim2.new(0.25, -14.5, 0, 5)
    prevButton.BackgroundTransparency = 1
    prevButton.Image = "rbxassetid://83289089183582"
    prevButton.Parent = controlsFrame
    
    local playPauseButton = Instance.new("ImageButton")
    playPauseButton.Name = "PlayPauseButton"
    playPauseButton.Size = UDim2.new(0, 29, 0, 29)
    playPauseButton.Position = UDim2.new(0.5, -14.5, 0, 5)
    playPauseButton.BackgroundTransparency = 1
    playPauseButton.Image = isMusicPlaying and "rbxassetid://14219414360" or "rbxassetid://8215093320"
    playPauseButton.Parent = controlsFrame
    
    local nextButton = Instance.new("ImageButton")
    nextButton.Name = "NextButton"
    nextButton.Size = UDim2.new(0, 29, 0, 29)
    nextButton.Position = UDim2.new(0.75, -14.5, 0, 5)
    nextButton.BackgroundTransparency = 1
    nextButton.Image = "rbxassetid://83855484359543"
    nextButton.Parent = controlsFrame
    
    musicUIElements.playPauseButton = playPauseButton
    
    local volumeValues = {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0}
    local volumeChanger = createValueChanger(musicScrollFrame, "Volume", volumeValues, settings.Music.Volume, function(value)
        settings.Music.Volume = value
        if musicSoundInstance then
            musicSoundInstance.Volume = value
        end
        saveSettings()
    end, "musicVolume")
    volumeChanger.Position = UDim2.new(0, 4, 0, 105)
    
    local function updateMusicSlider()
        if not musicSoundInstance then return end
        
        local current = musicSoundInstance.TimePosition
        local total = musicSoundInstance.TimeLength
        local progress = total > 0 and current / total or 0
        
        progressFill.Size = UDim2.new(progress, 0, 1, 0)
        sliderButton.Position = UDim2.new(progress, -6, 0.5, -6)
        
        timeLabel.Text = formatMusicTime(current) .. " / " .. formatMusicTime(total)
    end
    
    local function playTrack(index)
        if index < 1 then index = #musicTracks end
        if index > #musicTracks then index = 1 end
        
        currentTrack = index
        settings.Music.CurrentTrack = index
        saveSettings()
        
        trackLabel.Text = musicTracks[index].name
        
        if musicSoundInstance then
            musicSoundInstance:Stop()
            musicSoundInstance:Destroy()
        end
        
        musicSoundInstance = Instance.new("Sound")
        musicSoundInstance.SoundId = "rbxassetid://" .. musicTracks[index].id
        musicSoundInstance.Volume = settings.Music.Volume
        musicSoundInstance.Looped = false
        musicSoundInstance.Parent = SoundService
        
        if isMusicPlaying then
            musicSoundInstance:Play()
            playPauseButton.Image = "rbxassetid://14219414360"
        end
        
        updateMusicSlider()
    end
    
    local function togglePlayPause()
        if not musicSoundInstance then return end
        
        if isMusicPlaying then
            musicSoundInstance:Pause()
            playPauseButton.Image = "rbxassetid://8215093320"
        else
            musicSoundInstance:Play()
            playPauseButton.Image = "rbxassetid://14219414360"
        end
        isMusicPlaying = not isMusicPlaying
    end
    
    playPauseButton.MouseButton1Click:Connect(function()
        playSound()
        togglePlayPause()
    end)
    
    nextButton.MouseButton1Click:Connect(function()
        playSound()
        playTrack(currentTrack + 1)
    end)
    
    prevButton.MouseButton1Click:Connect(function()
        playSound()
        playTrack(currentTrack - 1)
    end)
    
    sliderButton.MouseButton1Down:Connect(function()
        musicSliderDragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            musicSliderDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if musicSliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement and musicSoundInstance then
            local mousePos = input.Position.X
            local framePos = sliderFrame.AbsolutePosition.X
            local frameSize = sliderFrame.AbsoluteSize.X
            local relativePos = math.clamp((mousePos - framePos) / frameSize, 0, 1)
            
            musicSoundInstance.TimePosition = relativePos * musicSoundInstance.TimeLength
            updateMusicSlider()
        end
    end)
    
    musicRenderConnection = RunService.RenderStepped:Connect(function()
        if musicSoundInstance and isMusicPlaying then
            updateMusicSlider()
            
            if musicSoundInstance.IsPlaying and musicSoundInstance.TimePosition >= musicSoundInstance.TimeLength - 0.1 then
                playTrack(currentTrack)
            end
        end
    end)
    
    if not musicSoundInstance then
        musicSoundInstance = Instance.new("Sound")
        musicSoundInstance.Parent = SoundService
        playTrack(currentTrack)
    else
        trackLabel.Text = musicTracks[currentTrack].name
        playPauseButton.Image = isMusicPlaying and "rbxassetid://14219414360" or "rbxassetid://8215093320"
    end
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
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(60, 60, 255)
    glow.Thickness = 1
    glow.Transparency = 0.7
    glow.Parent = createConfigFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.7, 0, 0.6, 0)
    textBox.Position = UDim2.new(0.05, 0, 0.2, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    textBox.TextColor3 = Color3.fromRGB(230, 230, 230)
    textBox.PlaceholderText = "Config name"
    textBox.Text = ""
    textBox.ClearTextOnFocus = false
    textBox.TextSize = 12
    textBox.Parent = createConfigFrame
    
    corner:Clone().Parent = textBox
    
    local createButton = Instance.new("TextButton")
    createButton.Size = UDim2.new(0.2, 0, 0.6, 0)
    createButton.Position = UDim2.new(0.75, 0, 0.2, 0)
    createButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    createButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    createButton.Text = "Create"
    createButton.TextSize = 12
    createButton.Parent = createConfigFrame
    
    corner:Clone().Parent = createButton
    
    createButton.MouseButton1Click:Connect(function()
        playSound()
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
        glow:Clone().Parent = configFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = configName
        nameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = configFrame
        
        local loadButton = Instance.new("TextButton")
        loadButton.Size = UDim2.new(0.15, 0, 0.7, 0)
        loadButton.Position = UDim2.new(0.65, 0, 0.15, 0)
        loadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        loadButton.Text = "Load"
        loadButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        loadButton.TextSize = 12
        loadButton.Parent = configFrame
        
        local deleteButton = Instance.new("TextButton")
        deleteButton.Size = UDim2.new(0.15, 0, 0.7, 0)
        deleteButton.Position = UDim2.new(0.85, 0, 0.15, 0)
        deleteButton.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
        deleteButton.Text = "Delete"
        deleteButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        deleteButton.TextSize = 12
        deleteButton.Parent = configFrame
        
        corner:Clone().Parent = loadButton
        corner:Clone().Parent = deleteButton
        
        loadButton.MouseButton1Click:Connect(function()
            playSound()
            if loadConfig(configName) then
                for id, element in pairs(uiElements) do
                    if id == "hitboxEnabled" then
                        element.update(settings.Combat.Hitbox.Enabled)
                    elseif id == "hitboxSize" then
                        element.update(settings.Combat.Hitbox.Size)
                    elseif id == "hitboxType" then
                        element.update(settings.Combat.Hitbox.Type == "Sphere")
                    elseif id == "hitboxColor" then
                        element.update(settings.Combat.Hitbox.Color)
                    elseif id == "hitboxTransparency" then
                        element.update(settings.Combat.Hitbox.Transparency)
                    elseif id == "espEnabled" then
                        element.update(settings.ESP.Enabled)
                    elseif id == "espShowDistance" then
                        element.update(settings.ESP.ShowDistance)
                    elseif id == "tracersEnabled" then
                        element.update(settings.Tracers.Enabled)
                    elseif id == "espMaxDistance" then
                        element.update(settings.ESP.MaxDistance)
                    elseif id == "musicVolume" then
                        element.update(settings.Music.Volume)
                    end
                end
                updateAllESP()
            end
        end)
        
        deleteButton.MouseButton1Click:Connect(function()
            playSound()
            deleteConfig(configName)
            scanConfigs()
            refreshConfigUI(scrollFrame)
        end)
        
        table.insert(configButtons, configFrame)
        yOffset = yOffset + 45
    end
end

local function createKeyGUI()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "SilenceKeyGui"
    keyGui.Parent = PlayerGui
    keyGui.ResetOnSpawn = false
    keyGui.IgnoreGuiInset = true

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 260, 0, 170)
    mainFrame.Position = UDim2.new(0.5, -130, 0.5, -85)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = keyGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(60, 60, 255)
    uiStroke.Thickness = 2
    uiStroke.Transparency = 0.1
    uiStroke.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "ENTER KEY"
    titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLabel.TextTransparency = 0.1
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = mainFrame

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(1, -20, 0, 18)
    timerLabel.Position = UDim2.new(0, 10, 0, 40)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "Next generation: 01:00"
    timerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    timerLabel.TextTransparency = 0.2
    timerLabel.TextSize = 12
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.TextXAlignment = Enum.TextXAlignment.Center
    timerLabel.Parent = mainFrame

    local attemptsLabel = Instance.new("TextLabel")
    attemptsLabel.Size = UDim2.new(1, -20, 0, 18)
    attemptsLabel.Position = UDim2.new(0, 10, 0, 60)
    attemptsLabel.BackgroundTransparency = 1
    attemptsLabel.Text = "Attempts left: "..remainingAttempts
    attemptsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    attemptsLabel.TextTransparency = 0.2
    attemptsLabel.TextSize = 12
    attemptsLabel.Font = Enum.Font.Gotham
    attemptsLabel.TextXAlignment = Enum.TextXAlignment.Center
    attemptsLabel.Parent = mainFrame

    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.8, 0, 0, 30)
    keyBox.Position = UDim2.new(0.1, 0, 0, 80)
    keyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    keyBox.TextColor3 = Color3.fromRGB(230, 230, 230)
    keyBox.PlaceholderText = "Key"
    keyBox.Text = ""
    keyBox.ClearTextOnFocus = false
    keyBox.TextSize = 14
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextXAlignment = Enum.TextXAlignment.Center
    keyBox.Parent = mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = keyBox

    local generateButton = Instance.new("TextButton")
    generateButton.Size = UDim2.new(0.35, 0, 0, 30)
    generateButton.Position = UDim2.new(0.1, 0, 0, 120)
    generateButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    generateButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    generateButton.Text = "GENERATE"
    generateButton.TextSize = 14
    generateButton.Font = Enum.Font.GothamBold
    generateButton.Parent = mainFrame

    corner:Clone().Parent = generateButton

    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(0.35, 0, 0, 30)
    submitButton.Position = UDim2.new(0.55, 0, 0, 120)
    submitButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    submitButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    submitButton.Text = "SUBMIT"
    submitButton.TextSize = 14
    submitButton.Font = Enum.Font.GothamBold
    submitButton.Parent = mainFrame

    corner:Clone().Parent = submitButton

    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, -20, 0, 18)
    errorLabel.Position = UDim2.new(0, 10, 0, 150)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    errorLabel.TextSize = 12
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.TextXAlignment = Enum.TextXAlignment.Center
    errorLabel.Visible = false
    errorLabel.Parent = mainFrame

    local canGenerate = false
    local generatedKey = ""
    local timer = 60
    local timerConnection
    local cooldown = false

    local function updateTimerDisplay()
        local minutes = math.floor(timer / 60)
        local seconds = math.floor(timer % 60)
        timerLabel.Text = string.format("Next generation: %02d:%02d", minutes, seconds)
    end

    local function startTimer()
        timer = 60
        updateTimerDisplay()
        canGenerate = false
        cooldown = true
        
        if timerConnection then
            timerConnection:Disconnect()
        end
        
        timerConnection = RunService.Heartbeat:Connect(function(delta)
            timer = timer - delta
            if timer <= 0 then
                timer = 0
                canGenerate = true
                cooldown = false
                timerLabel.Text = "Ready to generate"
                timerConnection:Disconnect()
            else
                updateTimerDisplay()
            end
        end)
    end

    local function updateAttempts()
        attemptsLabel.Text = "Attempts left: "..remainingAttempts
        if remainingAttempts <= 1 then
            attemptsLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        else
            attemptsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end

    local function restoreAttempts()
        task.wait(attemptCooldown)
        remainingAttempts = maxAttempts
        updateAttempts()
        cooldownActive = false
    end

    local function generateNewKey()
        if cooldown then
            errorLabel.Text = "Please wait " .. math.ceil(timer) .. " seconds"
            errorLabel.Visible = true
            playSound(357129686, 0.5)
            task.delay(2, function()
                errorLabel.Visible = false
            end)
            return
        end
        
        generatedKey = generateKey(16)
        keyBox.Text = generatedKey
        playSound()
        startTimer()
    end

    local function checkKey()
        if remainingAttempts <= 0 then
            errorLabel.Text = "No attempts left! Wait "..attemptCooldown.." seconds"
            errorLabel.Visible = true
            playSound(357129686, 0.5)
            task.delay(2, function()
                errorLabel.Visible = false
            end)
            if not cooldownActive then
                cooldownActive = true
                spawn(restoreAttempts)
            end
            return false
        end
        
        local key = keyBox.Text
        local keyPath = configFolder.."/"..keyFileName
        
        if isfile(keyPath) then
            local fileContent = readfile(keyPath)
            local success, data = pcall(function()
                return HttpService:JSONDecode(fileContent)
            end)
            
            if success and data and data.key and data.expireTime then
                if key == data.key and os.time() < data.expireTime then
                    playSound()
                    keyGui:Destroy()
                    return true
                end
            end
        end
        
        if key == generatedKey and generatedKey ~= "" then
            playSound()
            ensureConfigFolder()
            local expireTime = os.time() + 86400
            local data = {
                key = generatedKey,
                expireTime = expireTime
            }
            writefile(keyPath, HttpService:JSONEncode(data))
            
            local tween = TweenService:Create(mainFrame, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -130, -1, 0)})
            tween:Play()
            tween.Completed:Wait()
            keyGui:Destroy()
            return true
        else
            remainingAttempts = remainingAttempts - 1
            updateAttempts()
            
            if remainingAttempts <= 0 and not cooldownActive then
                cooldownActive = true
                spawn(restoreAttempts)
            end
            
            errorLabel.Text = "Incorrect key!"
            errorLabel.Visible = true
            playSound(357129686, 0.5)
            task.delay(2, function()
                errorLabel.Visible = false
            end)
            return false
        end
    end

    generateButton.MouseButton1Click:Connect(function()
        playSound()
        generateNewKey()
    end)

    submitButton.MouseButton1Click:Connect(function()
        playSound()
        checkKey()
    end)

    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            checkKey()
        end
    end)

    updateAttempts()
    startTimer()
    return keyGui
end

local function hasValidKey()
    ensureConfigFolder()
    local keyPath = configFolder.."/"..keyFileName
    
    if not isfile(keyPath) then
        return false
    end
    
    local fileContent = readfile(keyPath)
    local success, data = pcall(function()
        return HttpService:JSONDecode(fileContent)
    end)
    
    if not success or not data or not data.key or not data.expireTime then
        delfile(keyPath)
        return false
    end
    
    if os.time() >= data.expireTime then
        delfile(keyPath)
        return false
    end
    
    return true
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
    dragArea.Size = UDim2.new(1, 0, 0, 25)
    dragArea.BackgroundTransparency = 1
    dragArea.Text = "SILENCE"
    dragArea.TextColor3 = Color3.fromRGB(230, 230, 230)
    dragArea.TextTransparency = 0.1
    dragArea.TextSize = isMinimized and 14 or 16
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
    timerLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    timerLabel.TextTransparency = 0.3
    timerLabel.TextSize = 14
    timerLabel.Font = Enum.Font.GothamBold
    timerLabel.TextXAlignment = Enum.TextXAlignment.Center
    timerLabel.Visible = isMinimized
    timerLabel.Parent = dragArea

    local rightIcon = Instance.new("ImageLabel")
    rightIcon.Name = "RightIcon"
    rightIcon.Image = "rbxassetid://70459115196971"
    rightIcon.Size = UDim2.new(0, 20, 0, 20)
    rightIcon.Position = UDim2.new(0.5, 35, 0.5, -10)
    rightIcon.BackgroundTransparency = 1
    rightIcon.ImageTransparency = 0.1
    rightIcon.Visible = not isMinimized
    rightIcon.Parent = dragArea

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 25)
    tabContainer.Position = UDim2.new(0, 0, 0, 25)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    local tabIcons = {
        "rbxassetid://15571374043",
        "rbxassetid://6523858394",
        "rbxassetid://7059346373",
        "rbxassetid://7059338404"
    }

    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1 / #tabs, -2, 1, -2)
        tabButton.Position = UDim2.new((i - 1) / #tabs, 1, 0, 1)
        tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
        tabButton.BackgroundTransparency = 0.1
        tabButton.Text = ""
        tabButton.Selectable = false
        tabButton.Parent = tabContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 4)
        tabCorner.Parent = tabButton

        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Size = UDim2.new(0, i == 1 and 19 or 16, 0, i == 1 and 19 or 16)
        tabIcon.Position = UDim2.new(0.5, i == 1 and -9.5 or -8, 0.5, i == 1 and -9.5 or -8)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = tabIcons[i]
        tabIcon.ImageTransparency = 0.1
        tabIcon.Parent = tabButton

        tabButtons[i] = tabButton

        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, -8, 1, -54)
        contentFrame.Position = UDim2.new(0, 4, 0, 54)
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
        scrollFrame.ScrollBarThickness = 5
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 255)
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

        tabButton.MouseButton1Click:Connect(function()
            playSound()
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

    refreshCombatUI()
    refreshESPUI()
    refreshConfigUI(scrollFrames[3])
    refreshMusicUI()

    local function tweenFrame(frame, size, position)
        local sizeTween = TweenService:Create(frame, tweenInfo, {Size = size})
        local positionTween = TweenService:Create(frame, tweenInfo, {Position = position})
        sizeTween:Play()
        positionTween:Play()
    end

    dragArea.MouseButton1Click:Connect(function()
        playSound()
        isMinimized = not isMinimized
        timerActive = isMinimized
        local targetSize = isMinimized and minimizedSize or UDim2.new(0, menuWidth, 0, menuHeight)
        local targetPosition = isMinimized and minimizedPosition or defaultPosition
        tweenFrame(mainFrame, targetSize, targetPosition)
        tabContainer.Visible = not isMinimized
        for _, frame in ipairs(contentFrames) do
            frame.Visible = not isMinimized and frame == contentFrames[currentTab]
        end
        dragArea.TextSize = isMinimized and 14 or 16
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
        if not processed and input.KeyCode == Enum.KeyCode.Insert then
            playSound()
            isVisible = not isVisible
            screenGui.Enabled = isVisible
            if isVisible then
                updateAllESP()
            end
        end
    end)

    disableShadows()
    connections.DescendantAdded = workspace.DescendantAdded:Connect(function(obj)
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

    connections.RenderStep = RunService.RenderStepped:Connect(function()
        if isVisible then
            for player, _ in pairs(espCache) do
                if player ~= LocalPlayer then
                    updateESP(player)
                end
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
    end)

    connections.TimerUpdate = RunService.Heartbeat:Connect(function()
        updateTimer()
        if isMinimized then
            timerLabel.Text = formatTime(elapsedTime)
        end
    end)

    return screenGui
end

local function init()
    if not hasValidKey() then
        local keyGui = createKeyGUI()
        repeat task.wait() until not keyGui or not keyGui.Parent
    end
    
    if hasValidKey() then
        task.wait(0.5)
        createMainGUI()
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Error",
            Text = "Invalid key! Script will not work.",
            Duration = 5
        })
        return
    end

    local followIconGui = Instance.new("ScreenGui")
    followIconGui.Name = "UltimateFollowIcon"
    followIconGui.ResetOnSpawn = false
    followIconGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    followIconGui.DisplayOrder = 999999
    followIconGui.IgnoreGuiInset = true
    followIconGui.Parent = PlayerGui

    local image = Instance.new("ImageLabel")
    image.Name = "Icon"
    image.Image = "rbxassetid://10983765946"
    image.Size = UDim2.new(0, 70, 0, 70)
    image.AnchorPoint = Vector2.new(0.5, 0.5)
    image.BackgroundTransparency = 1
    image.ImageTransparency = 0.2
    image.Active = false
    image.Selectable = false
    image.Parent = followIconGui

    local blur = Instance.new("ImageLabel")
    blur.Name = "BlurEffect"
    blur.Image = "rbxassetid://10983765946"
    blur.Size = UDim2.new(1, 15, 1, 15)
    blur.AnchorPoint = Vector2.new(0.5, 0.5)
    blur.BackgroundTransparency = 1
    blur.ImageTransparency = 0.7
    blur.Position = UDim2.new(0.5, 0, 0.5, 0)
    blur.ZIndex = -1
    blur.Parent = image

    local activeTouch = nil
    local targetPosition = UDim2.new(0.5, 0, 0.5, 0)
    local currentPosition = targetPosition
    local lastInteraction = os.clock()
    local minTransparency = 0.2
    local maxTransparency = 0.6
    local smoothness = 0.35
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local yOffset = -0.02

    local function updatePosition(input)
        local pos = input.Position
        local x = math.clamp(pos.X / viewportSize.X, 0.02, 0.98)
        local y = math.clamp((pos.Y / viewportSize.Y) + yOffset, 0.02, 0.98)
        targetPosition = UDim2.new(x, 0, y, 0)
        lastInteraction = os.clock()
        image.ImageTransparency = minTransparency
        blur.ImageTransparency = 0.7
    end

    local function onViewportSizeChanged()
        viewportSize = workspace.CurrentCamera.ViewportSize
        local currentX = currentPosition.X.Scale
        local currentY = currentPosition.Y.Scale
        currentPosition = UDim2.new(currentX, 0, currentY, 0)
        targetPosition = currentPosition
    end

    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportSizeChanged)

    UserInputService.TouchStarted:Connect(function(input, processed)
        if not processed and not activeTouch then
            activeTouch = input
            updatePosition(input)
        end
    end)

    UserInputService.TouchMoved:Connect(function(input, processed)
        if not processed and activeTouch and input == activeTouch then
            updatePosition(input)
        end
    end)

    UserInputService.TouchEnded:Connect(function(input)
        if input == activeTouch then
            activeTouch = nil
        end
    end)

    RunService.RenderStepped:Connect(function()
        if activeTouch then
            currentPosition = targetPosition
            image.Position = currentPosition
            
            local velocity = (targetPosition.Y.Scale - currentPosition.Y.Scale) * 50
            blur.Size = UDim2.new(1, math.abs(velocity)*0.8, 1, math.abs(velocity)*0.8)
        else
            local delta = os.clock() - lastInteraction
            if delta > 0.5 then
                local newTransparency = math.min(maxTransparency, minTransparency + (delta - 0.5) * 0.25)
                image.ImageTransparency = newTransparency
                blur.ImageTransparency = newTransparency + 0.5
            end
            
            local x = currentPosition.X.Scale + (targetPosition.X.Scale - currentPosition.X.Scale) * smoothness
            local y = currentPosition.Y.Scale + (targetPosition.Y.Scale - currentPosition.Y.Scale) * smoothness
            currentPosition = UDim2.new(x, 0, y, 0)
            image.Position = currentPosition
            
            blur.Size = UDim2.new(1, 5, 1, 5)
        end
    end)

    GuiService:RegisterIsActiveCallback("IconBlocker", function(isActive)
        if not isActive then
            activeTouch = nil
        end
    end)

    game:BindToClose(function()
        clearAll()
        if screenGui then
            screenGui:Destroy()
        end
        if followIconGui then
            followIconGui:Destroy()
        end
        for _, sound in pairs(soundCache) do
            sound:Stop()
            sound:Destroy()
        end
    end)
    
    initialized = true
end

init()