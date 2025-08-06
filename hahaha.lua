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
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
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
local keyFileName = "silence_key.json"
local configFolder = "SilenceConfig"
local configFile = "settings.json"
local logFile = "silence_log.json"
local backupFile = "silence_backup.json"

setfpscap(900)

local colors = {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(0, 0, 0),
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255)
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

local function logError(message)
    local logData = {
        timestamp = os.time(),
        message = tostring(message)
    }
    if isfolder(configFolder) then
        local logs = isfile(configFolder.."/"..logFile) and HttpService:JSONDecode(readfile(configFolder.."/"..logFile)) or {}
        table.insert(logs, logData)
        writefile(configFolder.."/"..logFile, HttpService:JSONEncode(logs))
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
    local success, result = pcall(function()
        local sound
        if not id then
            sound = soundCache.clickSound or Instance.new("Sound")
            sound.SoundId = "rbxassetid://6895079853"
        else
            sound = soundCache[id] or Instance.new("Sound")
            sound.SoundId = "rbxassetid://"..tostring(id)
        end
        sound.Volume = volume or 0.25
        sound.Parent = SoundService
        soundCache[id or "clickSound"] = sound
        sound:Play()
    end)
    if not success then
        logError("Failed to play sound: "..tostring(result))
    end
end

local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = deepCopy(v)
        elseif typeof(v) == "Color3" then
            v = {r = v.R, g = v.G, b = v.B}
        elseif typeof(v) == "UDim2" then
            v = {xScale = v.X.Scale, xOffset = v.X.Offset, yScale = v.Y.Scale, yOffset = v.Y.Offset}
        end
        copy[k] = v
    end
    return copy
end

local function restoreColor(data)
    if type(data) == "table" and data.r and data.g and data.b then
        return Color3.new(data.r, data.g, data.b)
    elseif type(data) == "table" and data.xScale and data.xOffset and data.yScale and data.yOffset then
        return UDim2.new(data.xScale, data.xOffset, data.yScale, data.yOffset)
    end
    return data
end

local function ensureConfigFolder()
    local success, result = pcall(function()
        if not isfolder(configFolder) then
            makefolder(configFolder)
        end
    end)
    if not success then
        logError("Failed to ensure config folder: "..tostring(result))
    end
end

local function saveSettings()
    local success, result = pcall(function()
        ensureConfigFolder()
        local tempPath = configFolder.."/temp_"..configFile
        local finalPath = configFolder.."/"..configFile
        local backupPath = configFolder.."/"..backupFile
        local serializedSettings = {Configs = settings.Configs, PlayerInfo = settings.PlayerInfo, Music = settings.Music}
        writefile(tempPath, HttpService:JSONEncode(serializedSettings))
        if isfile(finalPath) then
            writefile(backupPath, readfile(finalPath))
        end
        writefile(finalPath, readfile(tempPath))
        delfile(tempPath)
    end)
    if not success then
        logError("Failed to save settings: "..tostring(result))
    end
end

local function loadSettings()
    local success, result = pcall(function()
        ensureConfigFolder()
        local path = configFolder.."/"..configFile
        if isfile(path) then
            local data = HttpService:JSONDecode(readfile(path))
            if data.Configs then
                settings.Configs = data.Configs
            end
            if data.Music then
                settings.Music.Volume = data.Music.Volume or 0.5
                settings.Music.CurrentTrack = math.clamp(data.Music.CurrentTrack or 1, 1, #musicTracks)
                currentTrack = settings.Music.CurrentTrack
            end
        end
    end)
    if not success then
        logError("Failed to load settings: "..tostring(result))
    end
end

local function saveConfig(configName)
    local success, result = pcall(function()
        ensureConfigFolder()
        local configPath = configFolder.."/"..configName..".json"
        local serializedSettings = deepCopy(settings)
        writefile(configPath, HttpService:JSONEncode(serializedSettings))
        if not table.find(settings.Configs, configName) then
            table.insert(settings.Configs, configName)
            saveSettings()
        end
    end)
    if not success then
        logError("Failed to save config: "..tostring(result))
    end
end

local function loadConfig(configName)
    local success, result = pcall(function()
        local configPath = configFolder.."/"..configName..".json"
        if not isfile(configPath) then return false end
        local data = HttpService:JSONDecode(readfile(configPath))
        settings = table.clone(defaultSettings)
        for category, categoryData in pairs(data) do
            if settings[category] then
                for key, value in pairs(categoryData) do
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
    end)
    if not success then
        logError("Failed to load config: "..tostring(result))
        return false
    end
    return result
end

local function deleteConfig(configName)
    local success, result = pcall(function()
        local configPath = configFolder.."/"..configName..".json"
        if isfile(configPath) then
            delfile(configPath)
        end
        local index = table.find(settings.Configs, configName)
        if index then
            table.remove(settings.Configs, index)
            saveSettings()
        end
    end)
    if not success then
        logError("Failed to delete config: "..tostring(result))
    end
end

local function scanConfigs()
    local success, result = pcall(function()
        ensureConfigFolder()
        local files = listfiles(configFolder)
        local foundConfigs = {}
        for _, file in ipairs(files) do
            if file:sub(-5) == ".json" and file ~= configFolder.."/"..configFile and file ~= configFolder.."/"..keyFileName and file ~= configFolder.."/"..logFile and file ~= configFolder.."/"..backupFile then
                local configName = file:match(".*/(.*)%.json")
                if configName then
                    table.insert(foundConfigs, configName)
                end
            end
        end
        settings.Configs = foundConfigs
        saveSettings()
        return foundConfigs
    end)
    if not success then
        logError("Failed to scan configs: "..tostring(result))
        return {}
    end
    return result
end

local function clearAll()
    local success, result = pcall(function()
        for _, conn in pairs(connections) do
            if conn then
                pcall(function() conn:Disconnect() end)
            end
        end
        connections = {}
        for player, conns in pairs(playerConnections) do
            if player and player.Parent then
                for _, conn in pairs(conns) do
                    if conn then
                        pcall(function() conn:Disconnect() end)
                    end
                end
            end
        end
        playerConnections = {}
        for _, espData in pairs(espCache) do
            if espData.box then pcall(function() espData.box:Remove() end) end
            if espData.distanceText then pcall(function() espData.distanceText:Remove() end) end
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
    end)
    if not success then
        logError("Failed to clear all: "..tostring(result))
    end
end

local function disableShadows()
    local success, result = pcall(function()
        Lighting.GlobalShadows = false
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CastShadow = false
            end
        end
    end)
    if not success then
        logError("Failed to disable shadows: "..tostring(result))
    end
end

local function updateNoClip()
    local success, result = pcall(function()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part ~= LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    if not success then
        logError("Failed to update noclip: "..tostring(result))
    end
end

local function clearHitboxes()
    local success, result = pcall(function()
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
    end)
    if not success then
        logError("Failed to clear hitboxes: "..tostring(result))
    end
end

local function updateHitbox(character)
    local success, result = pcall(function()
        if not settings.Combat.Hitbox.Enabled then
            if hitboxCache[character] then
                hitboxCache[character]:Destroy()
                hitboxCache[character] = nil
            end
            return
        end
        if not character or not character.Parent or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
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
    end)
    if not success then
        logError("Failed to update hitbox: "..tostring(result))
    end
end

local function createTracer(player)
    local success, result = pcall(function()
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
                pcall(function() tracerConnections[player]:Disconnect() end)
            end
            local humanoid = character:WaitForChild("Humanoid", 5)
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
    end)
    if not success then
        logError("Failed to create tracer: "..tostring(result))
    end
end

local function updateTracers()
    local success, result = pcall(function()
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
    end)
    if not success then
        logError("Failed to update tracers: "..tostring(result))
    end
end

local function removeTracer(player)
    local success, result = pcall(function()
        if tracers[player] then
            pcall(function() tracers[player]:Remove() end)
            tracers[player] = nil
        end
        if tracerConnections[player] then
            pcall(function() tracerConnections[player]:Disconnect() end)
            tracerConnections[player] = nil
        end
    end)
    if not success then
        logError("Failed to remove tracer: "..tostring(result))
    end
end

local function createESP(player)
    local success, result = pcall(function()
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
        espCache[player] = {box = box, distanceText = distanceText}
        if not playerConnections[player] then
            playerConnections[player] = {}
        end
        createTracer(player)
        local function onCharacterAdded(character)
            local humanoid = character:WaitForChild("Humanoid", 5)
            playerConnections[player].died = humanoid.Died:Connect(function()
                if espCache[player] then
                    espCache[player].box.Visible = false
                    espCache[player].distanceText.Visible = false
                end
                if hitboxCache[character] then
                    pcall(function() hitboxCache[character]:Destroy() end)
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
    end)
    if not success then
        logError("Failed to create ESP: "..tostring(result))
    end
end

local function updateESP(player)
    local success, result = pcall(function()
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
        local height = math.abs(headPos.Y - feetPos.Y)
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
    end)
    if not success then
        logError("Failed to update ESP: "..tostring(result))
    end
end

local function clearESP(player)
    local success, result = pcall(function()
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
    end)
    if not success then
        logError("Failed to clear ESP: "..tostring(result))
    end
end

local function updateAllESP()
    local success, result = pcall(function()
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
    end)
    if not success then
        logError("Failed to update all ESP: "..tostring(result))
    end
end

local function createCleanToggle(parent, text, value, callback, id)
    local success, result = pcall(function()
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
    end)
    if not success then
        logError("Failed to create toggle: "..tostring(result))
        return nil, nil
    end
    return result[1], result[2]
end

local function createValueChanger(parent, text, values, value, callback, id)
    local success, result = pcall(function()
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
    end)
    if not success then
        logError("Failed to create value changer: "..tostring(result))
        return nil, nil
    end
    return result[1], result[2]
end

local function createColorButton(parent, text, value, callback, id)
    local success, result = pcall(function()
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
    end)
    if not success then
        logError("Failed to create color button: "..tostring(result))
        return nil, nil
    end
    return result[1], result[2]
end

local function refreshCombatUI()
    local success, result = pcall(function()
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
    end)
    if not success then
        logError("Failed to refresh combat UI: "..tostring(result))
    end
end

local function refreshESPUI()
    local success, result = pcall(function()
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
    end)
    if not success then
        logError("Failed to refresh ESP UI: "..tostring(result))
    end
end

local function clearMusicUI()
    local success, result = pcall(function()
        if musicRenderConnection then
            pcall(function() musicRenderConnection:Disconnect() end)
            musicRenderConnection = nil
        end
        if musicSoundInstance then
            pcall(function()
                musicSoundInstance:Stop()
                musicSoundInstance:Destroy()
            end)
            musicSoundInstance = nil
        end
        for _, element in pairs(musicUIElements) do
            if element and element.Parent then
                pcall(function() element:Destroy() end)
            end
        end
        musicUIElements = {}
    end)
    if not success then
        logError("Failed to clear music UI: "..tostring(result))
    end
end

local function refreshMusicUI()
    local success, result = pcall(function()
        local musicScrollFrame = scrollFrames[4]
        if not musicScrollFrame then return end
        clearMusicUI()
        for _, child in ipairs(musicScrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
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
        prevButton.Position = UDim2.new(0.25, -15, 0, 5)
        prevButton.BackgroundTransparency = 1
        prevButton.Image = "rbxassetid://83289089183582"
        prevButton.Parent = controlsFrame
        local playPauseButton = Instance.new("ImageButton")
        playPauseButton.Name = "PlayPauseButton"
        playPauseButton.Size = UDim2.new(0, 30, 0, 30)
        playPauseButton.Position = UDim2.new(0.5, -15, 0, 5)
        playPauseButton.BackgroundTransparency = 1
        playPauseButton.Image = isMusicPlaying and "rbxassetid://14219414360" or "rbxassetid://8215093320"
        playPauseButton.Parent = controlsFrame
        local nextButton = Instance.new("ImageButton")
        nextButton.Name = "NextButton"
        nextButton.Size = UDim2.new(0, 29, 0, 29)
        nextButton.Position = UDim2.new(0.75, -15, 0, 5)
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
                pcall(function()
                    musicSoundInstance:Stop()
                    musicSoundInstance:Destroy()
                end)
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
                pcall(function() musicSoundInstance:Pause() end)
                playPauseButton.Image = "rbxassetid://8215093320"
            else
                pcall(function() musicSoundInstance:Play() end)
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
        if musicRenderConnection then
            pcall(function() musicRenderConnection:Disconnect() end)
        end
        musicRenderConnection = RunService.RenderStepped:Connect(function()
            if musicSoundInstance and isMusicPlaying then
                updateMusicSlider()
                if musicSoundInstance.IsPlaying and musicSoundInstance.TimePosition >= musicSoundInstance.TimeLength - 0.1 then
                    playTrack(currentTrack)
                end
            end
        end)
        if not musicSoundInstance then
            playTrack(currentTrack)
        else
            trackLabel.Text = musicTracks[currentTrack].name
            playPauseButton.Image = isMusicPlaying and "rbxassetid://14219414360" or "rbxassetid://8215093320"
        end
    end)
    if not success then
        logError("Failed to refresh music UI: "..tostring(result))
    end
end

local function refreshConfigUI(scrollFrame)
    local success, result = pcall(function()
        for _, button in pairs(configButtons) do
            if button and button.Parent then
                button:Destroy()
            end
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
            if textBox.Text ~= "" and textBox.Text:match("^[%w_]+$") then
                saveConfig(textBox.Text)
                scanConfigs()
                refreshConfigUI(scrollFrame)
                textBox.Text = ""
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Error",
                    Text = "Invalid config name! Use alphanumeric characters and underscores only.",
                    Duration = 3
                })
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
                    refreshCombatUI()
                    refreshESPUI()
                    refreshMusicUI()
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
    end)
    if not success then
        logError("Failed to refresh config UI: "..tostring(result))
    end
end

local function createKeyGUI()
    local success, result = pcall(function()
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
                pcall(function() timerConnection:Disconnect() end)
            end
            timerConnection = RunService.Heartbeat:Connect(function(delta)
                timer = timer - delta
                if timer <= 0 then
                    timer = 0
                    canGenerate = true
                    cooldown = false
                    timerLabel.Text = "Ready to generate"
                    pcall(function() timerConnection:Disconnect() end)
                else
                    updateTimerDisplay()
                end
            end)
        end
        local function updateAttempts()
            attemptsLabel.Text = "Attempts left: "..remainingAttempts
            attemptsLabel.TextColor3 = remainingAttempts <= 1 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(200, 200, 200)
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
    end)
    if not success then
        logError("Failed to create key GUI: "..tostring(result))
        return nil
    end
    return result
end

local function hasValidKey()
    local success, result = pcall(function()
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
    end)
    if not success then
        logError("Failed to check valid key: "..tostring(result))
        return false
    end
    return result
end

local function createMainGUI()
    local success, result = pcall(function()
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
dragArea.TextSize = 14
dragArea.Font = Enum.Font.GothamBold
dragArea.TextXAlignment = Enum.TextXAlignment.Left
dragArea.TextYAlignment = Enum.TextYAlignment.Center
dragArea.Parent = mainFrame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 20, 0, 20)
minimizeButton.Position = UDim2.new(1, -25, 0, 2.5)
minimizeButton.BackgroundTransparency = 1
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
minimizeButton.TextSize = 16
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = mainFrame

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 30)
tabFrame.Position = UDim2.new(0, 0, 0, 25)
tabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
tabFrame.BackgroundTransparency = 0.1
tabFrame.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabFrame

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -55)
contentFrame.Position = UDim2.new(0, 0, 0, 55)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true
contentFrame.Parent = mainFrame

local function switchTab(index)
    currentTab = index
    for i, button in ipairs(tabButtons) do
        button.BackgroundColor3 = i == index and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
        button.TextColor3 = i == index and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(150, 150, 150)
        contentFrames[i].Visible = i == index
    end
end

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1/#tabs, 0, 1, 0)
    tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
    tabButton.Text = tabName
    tabButton.TextColor3 = i == currentTab and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(150, 150, 150)
    tabButton.TextSize = 12
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = tabFrame
    table.insert(tabButtons, tabButton)

    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = i == currentTab
    tabContent.Parent = contentFrame
    contentFrames[i] = tabContent

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 2
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = tabContent
    scrollFrames[i] = scrollFrame

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Padding = UDim.new(0, 5)
    scrollLayout.Parent = scrollFrame

    scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 10)
    end)

    tabButton.MouseButton1Click:Connect(function()
        playSound()
        switchTab(i)
    end)
end

local dragging = false
local dragStart = nil
local startPos = nil

dragArea.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

dragArea.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

dragArea.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

minimizeButton.MouseButton1Click:Connect(function()
    playSound()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame:TweenSizeAndPosition(minimizedSize, minimizedPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        contentFrame.Visible = false
        tabFrame.Visible = false
        minimizeButton.Text = "+"
    else
        mainFrame:TweenSizeAndPosition(UDim2.new(0, menuWidth, 0, menuHeight), defaultPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        contentFrame.Visible = true
        tabFrame.Visible = true
        minimizeButton.Text = "-"
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftAlt and not gameProcessed then
        isVisible = not isVisible
        screenGui.Enabled = isVisible
        playSound()
    end
end)

refreshCombatUI()
refreshESPUI()
refreshConfigUI(scrollFrames[3])
refreshMusicUI()

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

table.insert(connections, Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end))

table.insert(connections, Players.PlayerRemoving:Connect(function(player)
    clearESP(player)
end))

table.insert(connections, RunService.RenderStepped:Connect(function()
    updateAllESP()
    updateTimer()
end))

table.insert(connections, LocalPlayer.CharacterAdded:Connect(function(character)
    updateNoClip()
end))

if LocalPlayer.Character then
    updateNoClip()
end

disableShadows()

return screenGui
end)

if not hasValidKey() then
    createKeyGUI()
else
    createMainGUI()
    end
