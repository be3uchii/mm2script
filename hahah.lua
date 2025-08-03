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
local menuWidth, menuHeight = 300, 200
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Config", "Visuals", "Misc"}
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local minimizedSize = UDim2.new(0, 80, 0, 20)
local minimizedPosition = UDim2.new(0.5, -40, 0.01, 0)
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
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Foreground = Color3.fromRGB(220, 220, 230),
        Text = Color3.fromRGB(40, 40, 50),
        Accent = Color3.fromRGB(80, 120, 220),
        Shadow = Color3.fromRGB(0, 0, 0, 0.1)
    }
}
local currentTheme = "Default"

setfpscap(900)

local colors = {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(255, 0, 255)
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
        },
        AutoClicker = {
            Enabled = false,
            CPS = 10
        }
    },
    ESP = {
        Enabled = false,
        ShowDistance = false,
        ShowHealth = false,
        ShowName = true,
        MaxDistance = 160,
        BoxColor = colors[1],
        TextColor = colors[1]
    },
    Visuals = {
        NoShadows = true,
        DepthOfField = false,
        Bloom = false,
        NeonEffect = false,
        Theme = "Default"
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
local neonModule = nil
local dofEffect = nil
local bloomEffect = nil
local keyAttempts = 0
local maxKeyAttempts = 5
local keyCooldown = false
local keyCooldownTime = 30

local function loadNeonModule()
    if neonModule then return end
    neonModule = {
        ApplyNeon = function(part, color, intensity)
            if not part or not part:IsA("BasePart") then return end
            
            local attachment = Instance.new("Attachment")
            attachment.Parent = part
            
            local pointLight = Instance.new("PointLight")
            pointLight.Parent = part
            pointLight.Color = color
            pointLight.Brightness = intensity
            pointLight.Range = 10
            pointLight.Shadows = false
            
            local beam = Instance.new("Beam")
            beam.Parent = part
            beam.Attachment0 = attachment
            beam.Attachment1 = attachment
            beam.Color = ColorSequence.new(color)
            beam.Width0 = 0.5
            beam.Width1 = 0.5
            beam.Brightness = intensity
            beam.LightEmission = 1
            beam.LightInfluence = 0
        end
    }
end

local function setupVisualEffects()
    if not Lighting:FindFirstChild("SilenceDOF") then
        dofEffect = Instance.new("DepthOfFieldEffect")
        dofEffect.Name = "SilenceDOF"
        dofEffect.FarIntensity = 0
        dofEffect.FocusDistance = 50
        dofEffect.InFocusRadius = 50
        dofEffect.NearIntensity = 0.5
        dofEffect.Enabled = settings.Visuals.DepthOfField
        dofEffect.Parent = Lighting
    end
    
    if not Lighting:FindFirstChild("SilenceBloom") then
        bloomEffect = Instance.new("BloomEffect")
        bloomEffect.Name = "SilenceBloom"
        bloomEffect.Intensity = 0.5
        bloomEffect.Size = 24
        bloomEffect.Threshold = 0.8
        bloomEffect.Enabled = settings.Visuals.Bloom
        bloomEffect.Parent = Lighting
    end
end

local function generatePassword(length)
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
    
    local password = ""
    for i = 1, length do
        password = password .. chars[math.random(1, #chars)]
    end
    
    return password
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
    if not soundCache[id] then
        soundCache[id] = Instance.new("Sound")
        soundCache[id].SoundId = "rbxassetid://" .. tostring(id)
        soundCache[id].Volume = volume or 0.25
        soundCache[id].Parent = workspace
    end
    soundCache[id]:Play()
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
        if espData and espData.healthText then
            pcall(function() espData.healthText:Remove() end)
        end
        if espData and espData.nameText then
            pcall(function() espData.nameText:Remove() end)
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
    
    if dofEffect then
        dofEffect:Destroy()
        dofEffect = nil
    end
    
    if bloomEffect then
        bloomEffect:Destroy()
        bloomEffect = nil
    end
end

local function disableShadows()
    if not settings.Visuals.NoShadows then return end
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
        box.AlwaysOnTop = false
        box.ZIndex = 0
        box.Transparency = settings.Combat.Hitbox.Transparency
        box.Color3 = settings.Combat.Hitbox.Color
        box.Parent = hrp
        
        hitboxCache[character] = box
        
        if settings.Visuals.NeonEffect then
            loadNeonModule()
            neonModule.ApplyNeon(hrp, settings.Combat.Hitbox.Color, 2)
        end
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
        if espCache[player].healthText then pcall(function() espCache[player].healthText:Remove() end) end
        if espCache[player].nameText then pcall(function() espCache[player].nameText:Remove() end) end
    end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = settings.ESP.BoxColor
    box.Thickness = 2
    box.Filled = false
    box.ZIndex = 1
    
    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Color = settings.ESP.TextColor
    distanceText.Size = 12
    distanceText.ZIndex = 1
    
    local healthText = Drawing.new("Text")
    healthText.Visible = false
    healthText.Color = settings.ESP.TextColor
    healthText.Size = 12
    healthText.ZIndex = 1
    
    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Color = settings.ESP.TextColor
    nameText.Size = 14
    nameText.ZIndex = 1
    
    espCache[player] = {
        box = box,
        distanceText = distanceText,
        healthText = healthText,
        nameText = nameText
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
                espCache[player].healthText.Visible = false
                espCache[player].nameText.Visible = false
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
    local healthText = espData.healthText
    local nameText = espData.nameText
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        box.Visible = false
        distanceText.Visible = false
        healthText.Visible = false
        nameText.Visible = false
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        box.Visible = false
        distanceText.Visible = false
        healthText.Visible = false
        nameText.Visible = false
        return
    end
    
    local head = character:FindFirstChild("Head")
    if not head then
        box.Visible = false
        distanceText.Visible = false
        healthText.Visible = false
        nameText.Visible = false
        return
    end
    
    local distance = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        box.Visible = false
        distanceText.Visible = false
        healthText.Visible = false
        nameText.Visible = false
        return
    end
    
    local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        box.Visible = false
        distanceText.Visible = false
        healthText.Visible = false
        nameText.Visible = false
        return
    end
    
    local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local feetPos = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
    
    local height = (headPos.Y - feetPos.Y)
    local width = height * 0.6
    
    box.Size = Vector2.new(width, height)
    box.Position = Vector2.new(rootPos.X - width/2, feetPos.Y)
    box.Visible = settings.ESP.Enabled
    box.Color = settings.ESP.BoxColor
    
    if settings.ESP.ShowDistance then
        distanceText.Text = tostring(math.floor(distance)) .. "m"
        distanceText.Position = Vector2.new(rootPos.X, headPos.Y - 15)
        distanceText.Visible = settings.ESP.Enabled
        distanceText.Color = settings.ESP.TextColor
    else
        distanceText.Visible = false
    end
    
    if settings.ESP.ShowHealth then
        healthText.Text = tostring(math.floor(character.Humanoid.Health)) .. "/" .. tostring(math.floor(character.Humanoid.MaxHealth))
        healthText.Position = Vector2.new(rootPos.X, headPos.Y - 30)
        healthText.Visible = settings.ESP.Enabled
        healthText.Color = settings.ESP.TextColor
    else
        healthText.Visible = false
    end
    
    if settings.ESP.ShowName then
        nameText.Text = player.Name
        nameText.Position = Vector2.new(rootPos.X, feetPos.Y - 15)
        nameText.Visible = settings.ESP.Enabled
        nameText.Color = settings.ESP.TextColor
    else
        nameText.Visible = false
    end
end

local function clearESP(player)
    if espCache[player] then
        if espCache[player].box then pcall(function() espCache[player].box:Remove() end) end
        if espCache[player].distanceText then pcall(function() espCache[player].distanceText:Remove() end) end
        if espCache[player].healthText then pcall(function() espCache[player].healthText:Remove() end) end
        if espCache[player].nameText then pcall(function() espCache[player].nameText:Remove() end) end
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
    
    local hoverTween = TweenService:Create(SwitchButton, TweenInfo.new(0.1), {BackgroundColor3 = value and Color3.fromRGB(86, 227, 110) or Color3.fromRGB(255, 78, 78)})
    
    SwitchButton.MouseEnter:Connect(function()
        hoverTween:Play()
    end)
    
    SwitchButton.MouseLeave:Connect(function()
        TweenService:Create(SwitchButton, TweenInfo.new(0.1), {BackgroundColor3 = value and Color3.fromRGB(76, 217, 100) or Color3.fromRGB(255, 58, 58)}):Play()
    end)
    
    SwitchButton.MouseButton1Click:Connect(function()
        playSound(6895079853)
        value = not value
        
        local circleGoalPos = value and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
        local bgGoalColor = value and Color3.fromRGB(76, 217, 100) or Color3.fromRGB(255, 58, 58)
        
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
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
    
    return toggleFrame, SwitchButton
end

local function createValueChanger(parent, text, values, value, callback, id)
    local changerFrame = Instance.new("Frame")
    changerFrame.Size = UDim2.new(1, -8, 0, 18)
    changerFrame.BackgroundTransparency = 1
    changerFrame.Position = UDim2.new(0, 4, 0, 0)
    changerFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = themes[currentTheme].Text
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = changerFrame
    
    local valueFrame = Instance.new("Frame")
    valueFrame.Size = UDim2.new(0.4, 0, 0.7, 0)
    valueFrame.Position = UDim2.new(0.55, 0, 0.15, 0)
    valueFrame.BackgroundColor3 = themes[currentTheme].Foreground
    valueFrame.Parent = changerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = valueFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.6, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.2, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = themes[currentTheme].Text
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = valueFrame
    
    local prevButton = Instance.new("ImageButton")
    prevButton.Size = UDim2.new(0.15, 0, 1, 0)
    prevButton.Position = UDim2.new(0, 0, 0, 0)
    prevButton.BackgroundTransparency = 1
    prevButton.Image = "rbxassetid://12338896667"
    prevButton.ImageColor3 = themes[currentTheme].Text
    prevButton.ImageTransparency = 0.3
    prevButton.Parent = valueFrame
    
    local nextButton = Instance.new("ImageButton")
    nextButton.Size = UDim2.new(0.15, 0, 1, 0)
    nextButton.Position = UDim2.new(0.85, 0, 0, 0)
    nextButton.BackgroundTransparency = 1
    nextButton.Image = "rbxassetid://12338895277"
    nextButton.ImageColor3 = themes[currentTheme].Text
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
        playSound(6895079853)
        currentIndex = currentIndex > 1 and currentIndex - 1 or #values
        updateValue()
    end)
    
    nextButton.MouseButton1Click:Connect(function()
        playSound(6895079853)
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

local function createSlider(parent, text, minValue, maxValue, currentValue, callback, id)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -8, 0, 30)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Position = UDim2.new(0, 4, 0, 0)
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = themes[currentTheme].Text
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 15)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(currentValue)
    valueLabel.TextColor3 = themes[currentTheme].Text
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 5)
    sliderTrack.Position = UDim2.new(0, 0, 0, 20)
    sliderTrack.BackgroundColor3 = themes[currentTheme].Foreground
    sliderTrack.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((currentValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = themes[currentTheme].Accent
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    local sliderThumb = Instance.new("Frame")
    sliderThumb.Size = UDim2.new(0, 10, 0, 15)
    sliderThumb.Position = UDim2.new((currentValue - minValue) / (maxValue - minValue), -5, 0, -5)
    sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderThumb.Parent = sliderTrack
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 3)
    thumbCorner.Parent = sliderThumb
    
    local dragging = false
    
    local function updateSlider(input)
        local relativeX = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
        relativeX = math.clamp(relativeX, 0, 1)
        local newValue = math.floor(minValue + (maxValue - minValue) * relativeX)
        
        if newValue ~= currentValue then
            currentValue = newValue
            valueLabel.Text = tostring(currentValue)
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            sliderThumb.Position = UDim2.new(relativeX, -5, 0, -5)
            callback(currentValue)
            saveSettings()
        end
    end
    
    sliderThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            playSound(6895079853)
        end
    end)
    
    sliderThumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            playSound(6895079853)
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
                currentValue = math.clamp(newValue, minValue, maxValue)
                valueLabel.Text = tostring(currentValue)
                local relativeX = (currentValue - minValue) / (maxValue - minValue)
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                sliderThumb.Position = UDim2.new(relativeX, -5, 0, -5)
            end
        }
    end
    
    return sliderFrame, valueLabel
end

local function createDropdown(parent, text, options, currentOption, callback, id)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, -8, 0, 18)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Position = UDim2.new(0, 4, 0, 0)
    dropdownFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = themes[currentTheme].Text
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdownFrame
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(0.45, 0, 1, 0)
    dropdownButton.Position = UDim2.new(0.5, 0, 0, 0)
    dropdownButton.BackgroundColor3 = themes[currentTheme].Foreground
    dropdownButton.Text = currentOption
    dropdownButton.TextColor3 = themes[currentTheme].Text
    dropdownButton.TextSize = 12
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.Parent = dropdownFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = dropdownButton
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Size = UDim2.new(0.45, 0, 0, 0)
    dropdownList.Position = UDim2.new(0.5, 0, 0, 18)
    dropdownList.BackgroundColor3 = themes[currentTheme].Foreground
    dropdownList.BorderSizePixel = 0
    dropdownList.ScrollBarThickness = 4
    dropdownList.ScrollBarImageColor3 = themes[currentTheme].Accent
    dropdownList.Visible = false
    dropdownList.Parent = dropdownFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = dropdownList
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = dropdownList
    
    local function updateListSize()
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
        dropdownList.Size = UDim2.new(0.45, 0, 0, math.min(100, listLayout.AbsoluteContentSize.Y))
    end
    
    for _, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, -4, 0, 18)
        optionButton.Position = UDim2.new(0, 2, 0, 0)
        optionButton.BackgroundColor3 = themes[currentTheme].Background
        optionButton.Text = option
        optionButton.TextColor3 = themes[currentTheme].Text
        optionButton.TextSize = 12
        optionButton.Font = Enum.Font.Gotham
        optionButton.Parent = dropdownList
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 2)
        optionCorner.Parent = optionButton
        
        optionButton.MouseButton1Click:Connect(function()
            playSound(6895079853)
            currentOption = option
            dropdownButton.Text = currentOption
            dropdownList.Visible = false
            callback(currentOption)
            saveSettings()
        end)
    end
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateListSize)
    updateListSize()
    
    dropdownButton.MouseButton1Click:Connect(function()
        playSound(6895079853)
        dropdownList.Visible = not dropdownList.Visible
    end)
    
    if id then
        uiElements[id] = {
            update = function(newOption)
                if table.find(options, newOption) then
                    currentOption = newOption
                    dropdownButton.Text = currentOption
                end
            end
        }
    end
    
    return dropdownFrame, dropdownButton
end

local function createColorPicker(parent, text, currentColor, callback, id)
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(1, -8, 0, 18)
    pickerFrame.BackgroundTransparency = 1
    pickerFrame.Position = UDim2.new(0, 4, 0, 0)
    pickerFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = themes[currentTheme].Text
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = pickerFrame
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0.45, 0, 0.8, 0)
    colorButton.Position = UDim2.new(0.5, 0, 0.1, 0)
    colorButton.BackgroundColor3 = currentColor
    colorButton.Text = ""
    colorButton.Parent = pickerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = colorButton
    
    local pickerGui = Instance.new("ScreenGui")
    pickerGui.Name = "ColorPickerGui"
    pickerGui.Parent = PlayerGui
    pickerGui.ResetOnSpawn = false
    pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local pickerMain = Instance.new("Frame")
    pickerMain.Size = UDim2.new(0, 200, 0, 150)
    pickerMain.Position = UDim2.new(0.5, -100, 0.5, -75)
    pickerMain.BackgroundColor3 = themes[currentTheme].Background
    pickerMain.Visible = false
    pickerMain.Parent = pickerGui
    
    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 6)
    pickerCorner.Parent = pickerMain
    
    local pickerStroke = Instance.new("UIStroke")
    pickerStroke.Color = themes[currentTheme].Accent
    pickerStroke.Thickness = 1
    pickerStroke.Parent = pickerMain
    
    local hueSlider = Instance.new("Frame")
    hueSlider.Size = UDim2.new(0, 20, 0, 120)
    hueSlider.Position = UDim2.new(0, 10, 0, 15)
    hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueSlider.Parent = pickerMain
    
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
    hueCorner.Parent = hueSlider
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    hueGradient.Rotation = 90
    hueGradient.Parent = hueSlider
    
    local hueSelector = Instance.new("Frame")
    hueSelector.Size = UDim2.new(1, 0, 0, 2)
    hueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueSelector.BorderSizePixel = 0
    hueSelector.Parent = hueSlider
    
    local saturationValue = Instance.new("ImageLabel")
    saturationValue.Size = UDim2.new(0, 120, 0, 120)
    saturationValue.Position = UDim2.new(0, 40, 0, 15)
    saturationValue.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    saturationValue.Image = "rbxassetid://4155801252"
    saturationValue.Parent = pickerMain
    
    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(0, 4)
    svCorner.Parent = saturationValue
    
    local svSelector = Instance.new("Frame")
    svSelector.Size = UDim2.new(0, 6, 0, 6)
    svSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    svSelector.BorderSizePixel = 0
    svSelector.Parent = saturationValue
    
    local svCorner2 = Instance.new("UICorner")
    svCorner2.CornerRadius = UDim.new(1, 0)
    svCorner2.Parent = svSelector
    
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 30, 0, 30)
    preview.Position = UDim2.new(0, 170, 0, 15)
    preview.BackgroundColor3 = currentColor
    preview.Parent = pickerMain
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = preview
    
    local confirmButton = Instance.new("TextButton")
    confirmButton.Size = UDim2.new(0, 180, 0, 20)
    confirmButton.Position = UDim2.new(0, 10, 0, 120)
    confirmButton.BackgroundColor3 = themes[currentTheme].Accent
    confirmButton.Text = "CONFIRM"
    confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmButton.TextSize = 12
    confirmButton.Font = Enum.Font.GothamBold
    confirmButton.Parent = pickerMain
    
    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0, 4)
    confirmCorner.Parent = confirmButton
    
    local h, s, v = currentColor:ToHSV()
    hueSelector.Position = UDim2.new(0, 0, 0, 120 * (1 - h))
    svSelector.Position = UDim2.new(0, s * 120 - 3, 0, (1 - v) * 120 - 3)
    
    local function updateColor(newH, newS, newV)
        h = newH or h
        s = newS or s
        v = newV or v
        
        local newColor = Color3.fromHSV(h, s, v)
        saturationValue.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        preview.BackgroundColor3 = newColor
        colorButton.BackgroundColor3 = newColor
        callback(newColor)
    end
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local y = math.clamp((input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
            h = 1 - y
            hueSelector.Position = UDim2.new(0, 0, 0, y * 120)
            updateColor()
        end
    end)
    
    saturationValue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local x = math.clamp((input.Position.X - saturationValue.AbsolutePosition.X) / saturationValue.AbsoluteSize.X, 0, 1)
            local y = math.clamp((input.Position.Y - saturationValue.AbsolutePosition.Y) / saturationValue.AbsoluteSize.Y, 0, 1)
            s = x
            v = 1 - y
            svSelector.Position = UDim2.new(0, x * 120 - 3, 0, y * 120 - 3)
            updateColor()
        end
    end)
    
    colorButton.MouseButton1Click:Connect(function()
        playSound(6895079853)
        pickerMain.Visible = not pickerMain.Visible
        pickerMain.Position = UDim2.new(0, colorButton.AbsolutePosition.X - 100, 0, colorButton.AbsolutePosition.Y + 25)
    end)
    
    confirmButton.MouseButton1Click:Connect(function()
        playSound(6895079853)
        pickerMain.Visible = false
        saveSettings()
    end)
    
    if id then
        uiElements[id] = {
            update = function(newColor)
                currentColor = newColor
                colorButton.BackgroundColor3 = newColor
                preview.BackgroundColor3 = newColor
                h, s, v = newColor:ToHSV()
                hueSelector.Position = UDim2.new(0, 0, 0, 120 * (1 - h))
                svSelector.Position = UDim2.new(0, s * 120 - 3, 0, (1 - v) * 120 - 3)
                saturationValue.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            end
        }
    end
    
    return pickerFrame, colorButton
end

local function createKeybind(parent, text, currentKey, callback, id)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Size = UDim2.new(1, -8, 0, 18)
    keybindFrame.BackgroundTransparency = 1
    keybindFrame.Position = UDim2.new(0, 4, 0, 0)
    keybindFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = themes[currentTheme].Text
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = keybindFrame
    
    local keybindButton = Instance.new("TextButton")
    keybindButton.Size = UDim2.new(0.45, 0, 1, 0)
    keybindButton.Position = UDim2.new(0.5, 0, 0, 0)
    keybindButton.BackgroundColor3 = themes[currentTheme].Foreground
    keybindButton.Text = tostring(currentKey.Name):gsub("Enum.KeyCode.", "")
    keybindButton.TextColor3 = themes[currentTheme].Text
    keybindButton.TextSize = 12
    keybindButton.Font = Enum.Font.Gotham
    keybindButton.Parent = keybindFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = keybindButton
    
    local listening = false
    
    keybindButton.MouseButton1Click:Connect(function()
        playSound(6895079853)
        listening = true
        keybindButton.Text = "..."
        keybindButton.BackgroundColor3 = themes[currentTheme].Accent
    end)
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, processed)
        if listening and not processed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keybindButton.Text = tostring(currentKey.Name):gsub("Enum.KeyCode.", "")
                callback(currentKey)
                saveSettings()
            end
            listening = false
            keybindButton.BackgroundColor3 = themes[currentTheme].Foreground
            connection:Disconnect()
        end
    end)
    
    if id then
        uiElements[id] = {
            update = function(newKey)
                currentKey = newKey
                keybindButton.Text = tostring(currentKey.Name):gsub("Enum.KeyCode.", "")
            end
        }
    end
    
    return keybindFrame, keybindButton
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
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    createSection(combatScrollFrame, "Hitbox")
    
    createCleanToggle(combatScrollFrame, "Hitbox Enabled", settings.Combat.Hitbox.Enabled, function(value)
        settings.Combat.Hitbox.Enabled = value
        if not value then
            clearHitboxes()
        end
        updateAllESP()
    end, "hitboxEnabled")
    
    local sizeValues = {}
    for i = 1, 8 do table.insert(sizeValues, i) end
    
    createSlider(combatScrollFrame, "Hitbox Size", 1, 8, settings.Combat.Hitbox.Size, function(value)
        settings.Combat.Hitbox.Size = value
        updateAllESP()
    end, "hitboxSize")
    
    createDropdown(combatScrollFrame, "Hitbox Type", {"Box", "Sphere"}, settings.Combat.Hitbox.Type, function(value)
        settings.Combat.Hitbox.Type = value
        clearHitboxes()
        updateAllESP()
    end, "hitboxType")
    
    createColorPicker(combatScrollFrame, "Hitbox Color", settings.Combat.Hitbox.Color, function(value)
        settings.Combat.Hitbox.Color = value
        updateAllESP()
    end, "hitboxColor")
    
    createSlider(combatScrollFrame, "Hitbox Transparency", 0.1, 0.9, settings.Combat.Hitbox.Transparency, function(value)
        settings.Combat.Hitbox.Transparency = value
        updateAllESP()
    end, "hitboxTransparency")
    
    createSection(combatScrollFrame, "Auto Clicker")
    
    createCleanToggle(combatScrollFrame, "Auto Clicker", settings.Combat.AutoClicker.Enabled, function(value)
        settings.Combat.AutoClicker.Enabled = value
    end, "autoClickerEnabled")
    
    createSlider(combatScrollFrame, "Clicks Per Second", 1, 20, settings.Combat.AutoClicker.CPS, function(value)
        settings.Combat.AutoClicker.CPS = value
    end, "autoClickerCPS")
end

local function refreshESPUI()
    local espScrollFrame = scrollFrames[2]
    if not espScrollFrame then return end
    
    for _, child in ipairs(espScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    createSection(espScrollFrame, "ESP Settings")
    
    createCleanToggle(espScrollFrame, "ESP Enabled", settings.ESP.Enabled, function(value)
        settings.ESP.Enabled = value
        updateAllESP()
    end, "espEnabled")
    
    createSlider(espScrollFrame, "Max Distance", 50, 500, settings.ESP.MaxDistance, function(value)
        settings.ESP.MaxDistance = value
        updateAllESP()
    end, "espMaxDistance")
    
    createSection(espScrollFrame, "ESP Elements")
    
    createCleanToggle(espScrollFrame, "Show Distance", settings.ESP.ShowDistance, function(value)
        settings.ESP.ShowDistance = value
        updateAllESP()
    end, "espShowDistance")
    
    createCleanToggle(espScrollFrame, "Show Health", settings.ESP.ShowHealth, function(value)
        settings.ESP.ShowHealth = value
        updateAllESP()
    end, "espShowHealth")
    
    createCleanToggle(espScrollFrame, "Show Name", settings.ESP.ShowName, function(value)
        settings.ESP.ShowName = value
        updateAllESP()
    end, "espShowName")
    
    createSection(espScrollFrame, "ESP Colors")
    
    createColorPicker(espScrollFrame, "Box Color", settings.ESP.BoxColor, function(value)
        settings.ESP.BoxColor = value
        updateAllESP()
    end, "espBoxColor")
    
    createColorPicker(espScrollFrame, "Text Color", settings.ESP.TextColor, function(value)
        settings.ESP.TextColor = value
        updateAllESP()
    end, "espTextColor")
end

local function refreshVisualsUI()
    local visualsScrollFrame = scrollFrames[4]
    if not visualsScrollFrame then return end
    
    for _, child in ipairs(visualsScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    createSection(visualsScrollFrame, "Visual Effects")
    
    createCleanToggle(visualsScrollFrame, "No Shadows", settings.Visuals.NoShadows, function(value)
        settings.Visuals.NoShadows = value
        disableShadows()
    end, "noShadows")
    
    createCleanToggle(visualsScrollFrame, "Depth of Field", settings.Visuals.DepthOfField, function(value)
        settings.Visuals.DepthOfField = value
        if dofEffect then
            dofEffect.Enabled = value
        end
    end, "depthOfField")
    
    createCleanToggle(visualsScrollFrame, "Bloom Effect", settings.Visuals.Bloom, function(value)
        settings.Visuals.Bloom = value
        if bloomEffect then
            bloomEffect.Enabled = value
        end
    end, "bloomEffect")
    
    createCleanToggle(visualsScrollFrame, "Neon Effect", settings.Visuals.NeonEffect, function(value)
        settings.Visuals.NeonEffect = value
        updateAllESP()
    end, "neonEffect")
    
    createSection(visualsScrollFrame, "UI Settings")
    
    createDropdown(visualsScrollFrame, "Theme", {"Default", "Light"}, settings.Visuals.Theme, function(value)
        settings.Visuals.Theme = value
        currentTheme = value
        saveSettings()
    end, "uiTheme")
end

local function refreshMiscUI()
    local miscScrollFrame = scrollFrames[5]
    if not miscScrollFrame then return end
    
    for _, child in ipairs(miscScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    createSection(miscScrollFrame, "Keybinds")
    
    createKeybind(miscScrollFrame, "Toggle UI", settings.Keybinds.ToggleUI, function(value)
        settings.Keybinds.ToggleUI = value
    end, "keybindToggleUI")
    
    createKeybind(miscScrollFrame, "Toggle ESP", settings.Keybinds.ToggleESP, function(value)
        settings.Keybinds.ToggleESP = value
    end, "keybindToggleESP")
    
    createKeybind(miscScrollFrame, "Toggle Hitbox", settings.Keybinds.ToggleHitbox, function(value)
        settings.Keybinds.ToggleHitbox = value
    end, "keybindToggleHitbox")
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
                    if id == "hitboxEnabled" then
                        element.update(settings.Combat.Hitbox.Enabled)
                    elseif id == "hitboxSize" then
                        element.update(settings.Combat.Hitbox.Size)
                    elseif id == "hitboxType" then
                        element.update(settings.Combat.Hitbox.Type)
                    elseif id == "hitboxColor" then
                        element.update(settings.Combat.Hitbox.Color)
                    elseif id == "hitboxTransparency" then
                        element.update(settings.Combat.Hitbox.Transparency)
                    elseif id == "espEnabled" then
                        element.update(settings.ESP.Enabled)
                    elseif id == "espShowDistance" then
                        element.update(settings.ESP.ShowDistance)
                    elseif id == "espShowHealth" then
                        element.update(settings.ESP.ShowHealth)
                    elseif id == "espShowName" then
                        element.update(settings.ESP.ShowName)
                    elseif id == "espBoxColor" then
                        element.update(settings.ESP.BoxColor)
                    elseif id == "espTextColor" then
                        element.update(settings.ESP.TextColor)
                    elseif id == "noShadows" then
                        element.update(settings.Visuals.NoShadows)
                    elseif id == "depthOfField" then
                        element.update(settings.Visuals.DepthOfField)
                    elseif id == "bloomEffect" then
                        element.update(settings.Visuals.Bloom)
                    elseif id == "neonEffect" then
                        element.update(settings.Visuals.NeonEffect)
                    elseif id == "uiTheme" then
                        element.update(settings.Visuals.Theme)
                    elseif id == "autoClickerEnabled" then
                        element.update(settings.Combat.AutoClicker.Enabled)
                    elseif id == "autoClickerCPS" then
                        element.update(settings.Combat.AutoClicker.CPS)
                    elseif id == "keybindToggleUI" then
                        element.update(settings.Keybinds.ToggleUI)
                    elseif id == "keybindToggleESP" then
                        element.update(settings.Keybinds.ToggleESP)
                    elseif id == "keybindToggleHitbox" then
                        element.update(settings.Keybinds.ToggleHitbox)
                    end
                end
                updateAllESP()
                setupVisualEffects()
                disableShadows()
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
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
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
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "ENTER PASSWORD"
    titleLabel.TextColor3 = themes[currentTheme].Text
    titleLabel.TextTransparency = 0.1
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = mainFrame

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(1, -20, 0, 20)
    timerLabel.Position = UDim2.new(0, 10, 0, 40)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "Next generation in: 01:00"
    timerLabel.TextColor3 = themes[currentTheme].Text
    timerLabel.TextTransparency = 0.2
    timerLabel.TextSize = 12
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.TextXAlignment = Enum.TextXAlignment.Center
    timerLabel.Parent = mainFrame

    local passwordBox = Instance.new("TextBox")
    passwordBox.Size = UDim2.new(0.8, 0, 0, 35)
    passwordBox.Position = UDim2.new(0.1, 0, 0, 70)
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

    local generateButton = Instance.new("TextButton")
    generateButton.Size = UDim2.new(0.35, 0, 0, 30)
    generateButton.Position = UDim2.new(0.1, 0, 0, 120)
    generateButton.BackgroundColor3 = themes[currentTheme].Accent
    generateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    generateButton.Text = "GENERATE"
    generateButton.TextSize = 14
    generateButton.Font = Enum.Font.GothamBold
    generateButton.Parent = mainFrame

    corner:Clone().Parent = generateButton

    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(0.35, 0, 0, 30)
    submitButton.Position = UDim2.new(0.55, 0, 0, 120)
    submitButton.BackgroundColor3 = themes[currentTheme].Accent
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.Text = "SUBMIT"
    submitButton.TextSize = 14
    submitButton.Font = Enum.Font.GothamBold
    submitButton.Parent = mainFrame

    corner:Clone().Parent = submitButton

    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, -20, 0, 20)
    errorLabel.Position = UDim2.new(0, 10, 0, 160)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    errorLabel.TextSize = 12
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.TextXAlignment = Enum.TextXAlignment.Center
    errorLabel.Visible = false
    errorLabel.Parent = mainFrame

    local attemptsLabel = Instance.new("TextLabel")
    attemptsLabel.Size = UDim2.new(1, -20, 0, 20)
    attemptsLabel.Position = UDim2.new(0, 10, 0, 180)
    attemptsLabel.BackgroundTransparency = 1
    attemptsLabel.Text = string.format("Attempts left: %d/%d", maxKeyAttempts - keyAttempts, maxKeyAttempts)
    attemptsLabel.TextColor3 = themes[currentTheme].Text
    attemptsLabel.TextTransparency = 0.3
    attemptsLabel.TextSize = 12
    attemptsLabel.Font = Enum.Font.Gotham
    attemptsLabel.TextXAlignment = Enum.TextXAlignment.Center
    attemptsLabel.Parent = mainFrame

    local canGenerate = false
    local generatedPassword = ""
    local timer = 60
    local timerConnection
    local cooldown = false

    local function updateTimerDisplay()
        local minutes = math.floor(timer / 60)
        local seconds = math.floor(timer % 60)
        timerLabel.Text = string.format("Next generation in: %02d:%02d", minutes, seconds)
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

    local function generateNewPassword()
        if cooldown then
            errorLabel.Text = "Please wait " .. math.ceil(timer) .. " seconds"
            errorLabel.Visible = true
            task.delay(2, function()
                errorLabel.Visible = false
            end)
            return
        end
        
        generatedPassword = generatePassword(16)
        passwordBox.Text = generatedPassword
        playSound(6895079853)
        startTimer()
    end

    local function checkPassword()
        if keyCooldown then
            errorLabel.Text = string.format("Please wait %d seconds before trying again", keyCooldownTime)
            errorLabel.Visible = true
            task.delay(2, function()
                errorLabel.Visible = false
            end)
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
            
            local tween = TweenService:Create(mainFrame, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -150, -1, 0)})
            tween:Play()
            tween.Completed:Wait()
            passwordGui:Destroy()
            return true
        else
            keyAttempts = keyAttempts + 1
            attemptsLabel.Text = string.format("Attempts left: %d/%d", maxKeyAttempts - keyAttempts, maxKeyAttempts)
            
            if keyAttempts >= maxKeyAttempts then
                keyCooldown = true
                errorLabel.Text = string.format("Too many attempts! Please wait %d seconds", keyCooldownTime)
                errorLabel.Visible = true
                
                task.delay(keyCooldownTime, function()
                    keyCooldown = false
                    keyAttempts = 0
                    attemptsLabel.Text = string.format("Attempts left: %d/%d", maxKeyAttempts - keyAttempts, maxKeyAttempts)
                    errorLabel.Visible = false
                end)
            else
                errorLabel.Text = "Invalid password!"
                errorLabel.Visible = true
                task.delay(2, function()
                    errorLabel.Visible = false
                end)
            end
            return false
        end
    end

    generateButton.MouseButton1Click:Connect(function()
        playSound(6895079853)
        generateNewPassword()
    end)

    submitButton.MouseButton1Click:Connect(function()
        playSound(6895079853)
        checkPassword()
    end)

    passwordBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            checkPassword()
        end
    end)

    startTimer()
    return passwordGui
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
    
    if not success or not data or type(data) ~= "table" then
        return false
    end
    
    local validKeys = {}
    for _, keyData in pairs(data) do
        if keyData.password and keyData.expireTime then
            if os.time() < keyData.expireTime then
                table.insert(validKeys, keyData)
            end
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
    setupVisualEffects()

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
    dragArea.Size = UDim2.new(1, 0, 0, 25)
    dragArea.BackgroundTransparency = 1
    dragArea.Text = "SILENCE"
    dragArea.TextColor3 = themes[currentTheme].Text
    dragArea.TextTransparency = 0.1
    label.TextSize = isMinimized and 12 or 14
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
    rightIcon.Size = UDim2.new(0, 18, 0, 18)
    rightIcon.Position = UDim2.new(0.5, 30, 0.5, -9)
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
        "rbxassetid://7059346373",
        "rbxassetid://7059346373"
    }

    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1 / #tabs, -2, 1, -2)
        tabButton.Position = UDim2.new((i - 1) / #tabs, 1, 0, 1)
        tabButton.BackgroundColor3 = i == currentTab and themes[currentTheme].Accent or themes[currentTheme].Foreground
        tabButton.BackgroundTransparency = 0.1
        tabButton.Text = ""
        tabButton.Selectable = false
        tabButton.Parent = tabContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 4)
        tabCorner.Parent = tabButton

        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Size = i == 1 and UDim2.new(0, 18, 0, 18) or UDim2.new(0, 14, 0, 14)
        tabIcon.Position = i == 1 and UDim2.new(0.5, -9, 0.5, -9) or UDim2.new(0.5, -7, 0.5, -7)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = tabIcons[i]
        tabIcon.ImageTransparency = 0.1
        tabIcon.Parent = tabButton

        tabButtons[i] = tabButton

        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, -8, 1, -54)
        contentFrame.Position = UDim2.new(0, 4, 0, 54)
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
        elseif tabName == "Visuals" then
            refreshVisualsUI()
        elseif tabName == "Misc" then
            refreshMiscUI()
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
            if isVisible then
                updateAllESP()
            end
        end
        
        if not processed and input.KeyCode == settings.Keybinds.ToggleESP then
            playSound(6895079853)
            settings.ESP.Enabled = not settings.ESP.Enabled
            if uiElements["espEnabled"] then
                uiElements["espEnabled"].update(settings.ESP.Enabled)
            end
            updateAllESP()
            saveSettings()
        end
        
        if not processed and input.KeyCode == settings.Keybinds.ToggleHitbox then
            playSound(6895079853)
            settings.Combat.Hitbox.Enabled = not settings.Combat.Hitbox.Enabled
            if uiElements["hitboxEnabled"] then
                uiElements["hitboxEnabled"].update(settings.Combat.Hitbox.Enabled)
            end
            updateAllESP()
            saveSettings()
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
    image.Size = UDim2.new(0, 60, 0, 60)
    image.AnchorPoint = Vector2.new(0.5, 0.5)
    image.BackgroundTransparency = 1
    image.ImageTransparency = 0.2
    image.Active = false
    image.Selectable = false
    image.Parent = followIconGui

    local blur = Instance.new("ImageLabel")
    blur.Name = "BlurEffect"
    blur.Image = "rbxassetid://10983765946"
    blur.Size = UDim2.new(1, 10, 1, 10)
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
end

init()