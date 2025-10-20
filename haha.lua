local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 300, 180
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP"}
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local minimizedSize = UDim2.new(0, 90, 0, 25)
local minimizedPosition = UDim2.new(0.5, -45, 0.01, 0)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)

setfpscap(900)

local colors = {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(0, 0, 0),
    Color3.fromRGB(255, 0, 0)
}

local transparencies = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9}

local defaultSettings = {
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 4,
            Color = colors[1],
            Transparency = 0.7
        }
    },
    ESP = {
        Enabled = false,
        MaxDistance = 200
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
local uiElements = {}
local startTime = os.time()
local elapsedTime = 0
local timerActive = true

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
end

local function disableShadows()
    pcall(function()
        Lighting.GlobalShadows = false
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CastShadow = false
            end
        end
    end)
end

local function updateNoClip()
    pcall(function()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part ~= LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    part.CanCollide = false
                end
            end
        end
    end)
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
            pcall(function() hitboxCache[character]:Destroy() end)
            hitboxCache[character] = nil
        end
        return 
    end
    
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
        if hitboxCache[character] then
            pcall(function() hitboxCache[character]:Destroy() end)
            hitboxCache[character] = nil
        end
        return 
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        if hitboxCache[character] then
            pcall(function() hitboxCache[character]:Destroy() end)
            hitboxCache[character] = nil
        end
        return 
    end
    
    local distance = (hrp.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        if hitboxCache[character] then
            pcall(function() hitboxCache[character]:Destroy() end)
            hitboxCache[character] = nil
        end
        return
    end
    
    if not hitboxCache[character] then
        pcall(function()
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "HitboxAdornment"
            box.Adornee = hrp
            box.AlwaysOnTop = false
            box.ZIndex = 0
            box.Transparency = settings.Combat.Hitbox.Transparency
            box.Color3 = settings.Combat.Hitbox.Color
            box.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
            box.Parent = hrp
            
            hitboxCache[character] = box
        end)
    end
    
    pcall(function()
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
    end)
end

local function createESP(player)
    if not player or player == LocalPlayer then return end
    if espCache[player] then
        if espCache[player].box then pcall(function() espCache[player].box:Remove() end) end
    end
    
    pcall(function()
        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = Color3.fromRGB(255, 255, 255)
        box.Thickness = 2
        box.Filled = false
        box.ZIndex = 1
        
        espCache[player] = {
            box = box
        }
        
        if not playerConnections[player] then
            playerConnections[player] = {}
        end
        
        local function onCharacterAdded(character)
            local humanoid = character:WaitForChild("Humanoid")
            playerConnections[player].died = humanoid.Died:Connect(function()
                if espCache[player] then
                    espCache[player].box.Visible = false
                end
                if hitboxCache[character] then
                    pcall(function() hitboxCache[character]:Destroy() end)
                    hitboxCache[character] = nil
                end
            end)
        end
        
        if player.Character then
            onCharacterAdded(player.Character)
        end
        
        playerConnections[player].characterAdded = player.CharacterAdded:Connect(onCharacterAdded)
    end)
end

local function updateESP(player)
    local espData = espCache[player]
    if not espData then return end
    
    local box = espData.box
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        box.Visible = false
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        box.Visible = false
        return
    end
    
    local head = character:FindFirstChild("Head")
    if not head then
        box.Visible = false
        return
    end
    
    local distance = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        box.Visible = false
        return
    end
    
    local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        box.Visible = false
        return
    end
    
    local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local feetPos = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
    
    local height = (headPos.Y - feetPos.Y)
    local width = height * 0.6
    
    box.Size = Vector2.new(width, height)
    box.Position = Vector2.new(rootPos.X - width/2, feetPos.Y)
    box.Visible = settings.ESP.Enabled
end

local function clearESP(player)
    if espCache[player] then
        if espCache[player].box then pcall(function() espCache[player].box:Remove() end) end
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
        value = not value
        
        local circleGoalPos = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        local bgGoalColor = value and Color3.fromRGB(76, 217, 100) or Color3.fromRGB(255, 58, 58)
        
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        TweenService:Create(ToggleCircle, tweenInfo, {Position = circleGoalPos}):Play()
        TweenService:Create(SwitchButton, tweenInfo, {BackgroundColor3 = bgGoalColor}):Play()
        TweenService:Create(glow, tweenInfo, {Color = bgGoalColor}):Play()
        
        callback(value)
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
    
    local prevButton = Instance.new("TextButton")
    prevButton.Size = UDim2.new(0.15, 0, 1, 0)
    prevButton.Position = UDim2.new(0, 0, 0, 0)
    prevButton.BackgroundTransparency = 1
    prevButton.Text = "<"
    prevButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    prevButton.TextSize = 12
    prevButton.Parent = valueFrame
    
    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.new(0.15, 0, 1, 0)
    nextButton.Position = UDim2.new(0.85, 0, 0, 0)
    nextButton.BackgroundTransparency = 1
    nextButton.Text = ">"
    nextButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    nextButton.TextSize = 12
    nextButton.Parent = valueFrame
    
    local currentIndex = table.find(values, value) or 1
    
    local function updateValue()
        value = values[currentIndex]
        valueLabel.Text = tostring(value)
        callback(value)
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
        local currentIndex = table.find(colors, value) or 1
        currentIndex = currentIndex % #colors + 1
        value = colors[currentIndex]
        colorButton.BackgroundColor3 = value
        glow.Color = value
        callback(value)
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
    
    local distanceValues = {50, 100, 150, 200, 250, 300, 500, 1000}
    createValueChanger(espScrollFrame, "Max Distance", distanceValues, settings.ESP.MaxDistance, function(value)
        settings.ESP.MaxDistance = value
        updateAllESP()
    end, "espMaxDistance")
end

local function createMainGUI()
    clearAll()
    settings = table.clone(defaultSettings)

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

    local rightIcon = Instance.new("TextLabel")
    rightIcon.Name = "RightIcon"
    rightIcon.Text = "≡"
    rightIcon.Size = UDim2.new(0, 20, 0, 20)
    rightIcon.Position = UDim2.new(0.5, 35, 0.5, -10)
    rightIcon.BackgroundTransparency = 1
    rightIcon.TextTransparency = 0.1
    rightIcon.TextColor3 = Color3.fromRGB(230, 230, 230)
    rightIcon.TextSize = 16
    rightIcon.Visible = not isMinimized
    rightIcon.Parent = dragArea

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 25)
    tabContainer.Position = UDim2.new(0, 0, 0, 25)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1 / #tabs, -2, 1, -2)
        tabButton.Position = UDim2.new((i - 1) / #tabs, 1, 0, 1)
        tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
        tabButton.BackgroundTransparency = 0.1
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        tabButton.TextSize = 12
        tabButton.Selectable = false
        tabButton.Parent = tabContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 4)
        tabCorner.Parent = tabButton

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

        if tabName == "Combat" then
            refreshCombatUI()
        elseif tabName == "ESP" then
            refreshESPUI()
        end

        tabButton.MouseButton1Click:Connect(function()
            currentTab = i
            for j, frame in ipairs(contentFrames) do
                frame.Visible = j == i
            end
            for j, btn in ipairs(tabButtons) do
                btn.BackgroundColor3 = j == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
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
            pcall(function() obj.CastShadow = false end)
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
            end
            updateTimer()
            if timerLabel.Visible then
                timerLabel.Text = formatTime(elapsedTime)
            end
        end
        updateNoClip()
    end)

    connections.Heartbeat = RunService.Heartbeat:Connect(function()
        updateNoClip()
    end)

    updateAllESP()
end

createMainGUI()