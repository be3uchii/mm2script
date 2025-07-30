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
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local minimizedSize = UDim2.new(0, 90, 0, 30)
local minimizedPosition = UDim2.new(0.5, -45, 0, 10)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)

local settings = {
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 4,
            Color = Color3.fromRGB(255, 50, 50),
            Transparency = 0.6,
            Type = "Box",
            ThroughWalls = false
        },
        KillAll = {
            Enabled = false,
            Distance = 200,
            Duration = 5
        }
    },
    ESP = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.6,
        MaxDistance = 200,
        Highlight = false,
        HighlightColor = Color3.fromRGB(0, 255, 0)
    }
}

local espCache = {}
local hitboxCache = {}
local highlightCache = {}
local movingPlayers = {}
local connections = {}
local tabButtons = {}
local contentFrames = {}
local scrollFrames = {}
local playerConnections = {}

if PlayerGui:FindFirstChild("SilenceGui") then
    PlayerGui.SilenceGui:Destroy()
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
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(80, 80, 255)
uiStroke.Thickness = 2
uiStroke.Transparency = 0.05
uiStroke.Parent = mainFrame

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 80))
}
uiGradient.Rotation = 45
uiGradient.Parent = mainFrame

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, 0, 0, 26)
dragArea.BackgroundTransparency = 1
dragArea.Text = "Silence 4.4"
dragArea.TextColor3 = Color3.fromRGB(240, 240, 240)
dragArea.TextTransparency = 0.05
dragArea.TextSize = isMinimized and 12 or 16
dragArea.Font = Enum.Font.GothamBlack
dragArea.TextXAlignment = Enum.TextXAlignment.Center
dragArea.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 26)
tabContainer.Position = UDim2.new(0, 0, 0, 26)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local function createToggle(parent, text, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 22)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Position = UDim2.new(0, 5, 0, 0)
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.TextTransparency = 0.05
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.35, 0, 0.85, 0)
    toggle.Position = UDim2.new(0.65, 0, 0.075, 0)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    toggle.Text = defaultValue and "ВКЛ" or "ВЫКЛ"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 11
    toggle.Font = Enum.Font.GothamBlack
    toggle.Parent = toggleFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        toggle.Text = defaultValue and "ВКЛ" or "ВЫКЛ"
        local tween = TweenService:Create(toggle, tweenInfo, {BackgroundColor3 = defaultValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)})
        tween:Play()
        callback(defaultValue)
    end)
    
    return toggleFrame
end

local function createValueChanger(parent, text, values, defaultValueIndex, callback)
    local changerFrame = Instance.new("Frame")
    changerFrame.Size = UDim2.new(1, -10, 0, 22)
    changerFrame.BackgroundTransparency = 1
    changerFrame.Position = UDim2.new(0, 5, 0, 0)
    changerFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.TextTransparency = 0.05
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = changerFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.25, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(values[defaultValueIndex])
    valueLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    valueLabel.TextTransparency = 0.05
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBlack
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = changerFrame
    
    local prevButton = Instance.new("TextButton")
    prevButton.Size = UDim2.new(0.1, 0, 0.85, 0)
    prevButton.Position = UDim2.new(0.75, 0, 0.075, 0)
    prevButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    prevButton.Text = "<"
    prevButton.TextColor3 = Color3.fromRGB(240, 240, 240)
    prevButton.TextSize = 11
    prevButton.Font = Enum.Font.GothamBlack
    prevButton.Parent = changerFrame
    
    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.new(0.1, 0, 0.85, 0)
    nextButton.Position = UDim2.new(0.87, 0, 0.075, 0)
    nextButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    nextButton.Text = ">"
    nextButton.TextColor3 = Color3.fromRGB(240, 240, 240)
    nextButton.TextSize = 11
    nextButton.Font = Enum.Font.GothamBlack
    nextButton.Parent = changerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = prevButton
    corner:Clone().Parent = nextButton
    
    local currentIndex = defaultValueIndex
    
    local function updateValue()
        valueLabel.Text = tostring(values[currentIndex])
        callback(values[currentIndex])
    end
    
    prevButton.MouseButton1Click:Connect(function()
        currentIndex = currentIndex > 1 and currentIndex - 1 or #values
        updateValue()
    end)
    
    nextButton.MouseButton1Click:Connect(function()
        currentIndex = currentIndex < #values and currentIndex + 1 or 1
        updateValue()
    end)
    
    return changerFrame
end

local function createESP(player)
    if espCache[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = settings.ESP.Color
    box.Thickness = 2
    box.Transparency = settings.ESP.Transparency
    box.Filled = false
    box.ZIndex = 1
    espCache[player] = box
    
    if not playerConnections[player] then
        playerConnections[player] = {}
    end
    
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        playerConnections[player].died = humanoid.Died:Connect(function()
            if espCache[player] then
                espCache[player].Visible = false
            end
            if hitboxCache[character] then
                hitboxCache[character]:Destroy()
                hitboxCache[character] = nil
            end
            if highlightCache[character] then
                highlightCache[character]:Destroy()
                highlightCache[character] = nil
            end
            if movingPlayers[character] then
                movingPlayers[character] = nil
            end
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    playerConnections[player].characterAdded = player.CharacterAdded:Connect(onCharacterAdded)
end

local function updateVisuals(player)
    local box = espCache[player]
    local character = player.Character
    if not box or not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        if box then box.Visible = false end
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not humanoidRootPart or not head then
        if box then box.Visible = false end
        return
    end
    
    local distance = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        if box then box.Visible = false end
        if highlightCache[character] then
            highlightCache[character]:Destroy()
            highlightCache[character] = nil
        end
        return
    end
    
    local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        if box then box.Visible = false end
        return
    end
    
    local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local feetPos = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
    
    local height = (headPos.Y - feetPos.Y)
    local width = height * 0.6
    
    box.Size = Vector2.new(width, height)
    box.Position = Vector2.new(rootPos.X - width/2, feetPos.Y)
    box.Visible = settings.ESP.Enabled
    box.Color = settings.ESP.Color
    box.Transparency = settings.ESP.Transparency
    
    if settings.ESP.Highlight and not highlightCache[character] then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character
        highlight.FillColor = settings.ESP.HighlightColor
        highlight.OutlineColor = settings.ESP.HighlightColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.2
        highlight.Parent = character
        highlightCache[character] = highlight
    end
    
    if highlightCache[character] then
        highlightCache[character].Enabled = settings.ESP.Highlight
        highlightCache[character].FillColor = settings.ESP.HighlightColor
        highlightCache[character].OutlineColor = settings.ESP.HighlightColor
    end
end

local function updateHitbox(character)
    if not settings.Combat.Hitbox.Enabled or not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        if hitboxCache[character] then
            hitboxCache[character]:Destroy()
            hitboxCache[character] = nil
        end
        return
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
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
        
        hrp.Size = settings.Combat.Hitbox.Type == "Sphere" and
            Vector3.new(settings.Combat.Hitbox.Size * 1.2, settings.Combat.Hitbox.Size * 1.2, settings.Combat.Hitbox.Size * 1.2) or
            Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
        hrp.Transparency = 1
        hrp.CanCollide = false
        
        hitboxCache[character] = box
    end
    
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

local function movePlayer(targetChar)
    if not targetChar or movingPlayers[targetChar] then return end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not root then return end
    
    local distance = (targetRoot.Position - root.Position).Magnitude
    if distance > settings.Combat.KillAll.Distance then return end
    
    movingPlayers[targetChar] = true
    local targetPos = root.CFrame * CFrame.new(math.random(-4, 4), 0, math.random(-4, 4))
    local tween = TweenService:Create(targetRoot, TweenInfo.new(settings.Combat.KillAll.Duration, Enum.EasingStyle.Linear), {CFrame = targetPos})
    tween:Play()
    tween.Completed:Connect(function()
        movingPlayers[targetChar] = nil
    end)
end

local function updateAllVisuals()
    for player, _ in pairs(espCache) do
        if player ~= LocalPlayer then
            updateVisuals(player)
            if player.Character and settings.Combat.Hitbox.Enabled then
                updateHitbox(player.Character)
            end
            if player.Character and settings.Combat.KillAll.Enabled then
                movePlayer(player.Character)
            end
        end
    end
end

local function clearESP(player)
    if espCache[player] then
        espCache[player]:Remove()
        espCache[player] = nil
    end
    if playerConnections[player] then
        for _, conn in pairs(playerConnections[player]) do
            conn:Disconnect()
        end
        playerConnections[player] = nil
    end
    if player.Character and highlightCache[player.Character] then
        highlightCache[player.Character]:Destroy()
        highlightCache[player.Character] = nil
    end
end

local function clearHitboxes()
    for character, box in pairs(hitboxCache) do
        if character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            character.HumanoidRootPart.Transparency = 1
            character.HumanoidRootPart.CanCollide = true
        end
        if box then
            box:Destroy()
        end
    end
    hitboxCache = {}
end

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1 / #tabs, -6, 1, -6)
    tabButton.Position = UDim2.new((i - 1) / #tabs, 3, 0, 3)
    tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(80, 80, 100) or Color3.fromRGB(50, 50, 70)
    tabButton.BackgroundTransparency = 0.05
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(240, 240, 240)
    tabButton.TextTransparency = 0.05
    tabButton.TextSize = 13
    tabButton.Font = Enum.Font.GothamBlack
    tabButton.Parent = tabContainer

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabButton

    local tabGradient = Instance.new("UIGradient")
    tabGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 120))
    }
    tabGradient.Parent = tabButton

    tabButtons[i] = tabButton

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -10, 1, -60)
    contentFrame.Position = UDim2.new(0, 5, 0, 55)
    contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    contentFrame.BackgroundTransparency = 0.05
    contentFrame.Visible = i == currentTab
    contentFrame.Parent = mainFrame

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentFrame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 255)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = contentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scrollFrame

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    contentFrames[i] = contentFrame
    scrollFrames[i] = scrollFrame

    if tabName == "Combat" then
        createToggle(scrollFrame, "Хитбокс Включен", settings.Combat.Hitbox.Enabled, function(value)
            settings.Combat.Hitbox.Enabled = value
            updateAllVisuals()
        end)
        
        local sizeValues = {}
        for i = 1, 8 do table.insert(sizeValues, i) end
        
        createValueChanger(scrollFrame, "Размер Хитбокса", sizeValues, settings.Combat.Hitbox.Size, function(value)
            settings.Combat.Hitbox.Size = value
            updateAllVisuals()
        end)
        
        createToggle(scrollFrame, "Сферический Хитбокс", settings.Combat.Hitbox.Type == "Sphere", function(value)
            settings.Combat.Hitbox.Type = value and "Sphere" or "Box"
            clearHitboxes()
            updateAllVisuals()
        end)
        
        createToggle(scrollFrame, "Сквозь Стены", settings.Combat.Hitbox.ThroughWalls, function(value)
            settings.Combat.Hitbox.ThroughWalls = value
            updateAllVisuals()
        end)
        
        createToggle(scrollFrame, "Убить Всех", settings.Combat.KillAll.Enabled, function(value)
            settings.Combat.KillAll.Enabled = value
            if not value then
                movingPlayers = {}
            end
            updateAllVisuals()
        end)
    elseif tabName == "ESP" then
        createToggle(scrollFrame, "ESP Включен", settings.ESP.Enabled, function(value)
            settings.ESP.Enabled = value
            updateAllVisuals()
        end)
        
        createToggle(scrollFrame, "Подсветка", settings.ESP.Highlight, function(value)
            settings.ESP.Highlight = value
            updateAllVisuals()
        end)
    end

    tabButton.MouseButton1Click:Connect(function()
        currentTab = i
        for j, frame in ipairs(contentFrames) do
            local tween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = j == i and 0.05 or 1})
            frame.Visible = j == i
            tween:Play()
        end
        for j, btn in ipairs(tabButtons) do
            local tween = TweenService:Create(btn, tweenInfo, {BackgroundColor3 = j == i and Color3.fromRGB(80, 80, 100) or Color3.fromRGB(50, 50, 70)})
            tween:Play()
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
    dragArea.TextSize = isMinimized and 12 or 16
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

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        isVisible = not isVisible
        screenGui.Enabled = isVisible
        if isVisible then
            updateAllVisuals()
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    clearESP(player)
    if player.Character then
        movingPlayers[player.Character] = nil
    end
end)

connections.RenderStep = RunService.RenderStepped:Connect(function()
    if isVisible then
        updateAllVisuals()
    end
end)

game:BindToClose(function()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    for player, _ in pairs(playerConnections) do
        clearESP(player)
    end
    for _, box in pairs(espCache) do
        box:Remove()
    end
    clearHitboxes()
    for character, highlight in pairs(highlightCache) do
        if highlight then
            highlight:Destroy()
        end
    end
    movingPlayers = {}
    screenGui:Destroy()
end)