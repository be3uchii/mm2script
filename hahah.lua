local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 240, 140
local menuX, menuY = (viewportSize.X - menuWidth)/2, (viewportSize.Y - menuHeight)/2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat"}
local minimizedSize = UDim2.new(0, 80, 0, 30)
local minimizedPosition = UDim2.new(0.5, -40, 0, 10)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)

local settings = {
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 1,
            Color = Color3.fromRGB(255, 0, 0),
            Transparency = 0.8
        }
    }
}

local hitboxHighlights = {}
local connections = {}
local tabButtons = {}
local contentFrames = {}
local scrollFrames = {}

if PlayerGui:FindFirstChild("TestMenuGui") then
    PlayerGui.TestMenuGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TestMenuGui"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Enabled = isVisible

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
mainFrame.Position = defaultPosition
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, 0, 0, 25)
dragArea.BackgroundTransparency = 1
dragArea.Text = "Silence 3.0"
dragArea.TextColor3 = Color3.fromRGB(200, 200, 200)
dragArea.TextSize = isMinimized and 12 or 14
dragArea.Font = Enum.Font.Gotham
dragArea.TextXAlignment = Enum.TextXAlignment.Center
dragArea.AutoButtonColor = false
dragArea.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 25)
tabContainer.Position = UDim2.new(0, 0, 0, 25)
tabContainer.BackgroundTransparency = 1
tabContainer.Visible = not isMinimized
tabContainer.Parent = mainFrame

local function createToggle(parent, text, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 20)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Position = UDim2.new(0, 4, 0, 0)
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.35, 0, 0.8, 0)
    toggle.Position = UDim2.new(0.65, 0, 0.1, 0)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    toggle.Text = defaultValue and "ВКЛ" or "ВЫКЛ"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 12
    toggle.Font = Enum.Font.Gotham
    toggle.AutoButtonColor = false
    toggle.Parent = toggleFrame
    
    toggle.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        toggle.Text = defaultValue and "ВКЛ" or "ВЫКЛ"
        toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        callback(defaultValue)
    end)
    
    return toggleFrame
end

local function createValueChanger(parent, text, values, defaultValueIndex, callback)
    local changerFrame = Instance.new("Frame")
    changerFrame.Size = UDim2.new(1, -8, 0, 20)
    changerFrame.BackgroundTransparency = 1
    changerFrame.Position = UDim2.new(0, 4, 0, 0)
    changerFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = changerFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(values[defaultValueIndex])
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = changerFrame
    
    local prevButton = Instance.new("TextButton")
    prevButton.Size = UDim2.new(0.15, 0, 0.8, 0)
    prevButton.Position = UDim2.new(0.7, 0, 0.1, 0)
    prevButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    prevButton.Text = "<"
    prevButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    prevButton.TextSize = 12
    prevButton.Font = Enum.Font.Gotham
    prevButton.AutoButtonColor = false
    prevButton.Parent = changerFrame
    
    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.new(0.15, 0, 0.8, 0)
    nextButton.Position = UDim2.new(0.85, 0, 0.1, 0)
    nextButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    nextButton.Text = ">"
    nextButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    nextButton.TextSize = 12
    nextButton.Font = Enum.Font.Gotham
    nextButton.AutoButtonColor = false
    nextButton.Parent = changerFrame
    
    local currentIndex = defaultValueIndex
    
    local function updateValue()
        valueLabel.Text = tostring(values[currentIndex])
        callback(values[currentIndex])
    end
    
    prevButton.MouseButton1Click:Connect(function()
        currentIndex = math.max(1, currentIndex - 1)
        updateValue()
    end)
    
    nextButton.MouseButton1Click:Connect(function()
        currentIndex = math.min(#values, currentIndex + 1)
        updateValue()
    end)
    
    return changerFrame
end

local hitboxUpdateCooldown = 0.2
local lastHitboxUpdate = 0

local function updateHitboxes()
    if not settings.Combat.Hitbox.Enabled then
        for player, highlight in pairs(hitboxHighlights) do
            if highlight then
                highlight:Destroy()
            end
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                rootPart.Size = Vector3.new(2, 2, 1)
                rootPart.Transparency = 1
                rootPart.Color = Color3.new(1, 1, 1)
            end
        end
        hitboxHighlights = {}
        if connections.Hitbox then
            connections.Hitbox:Disconnect()
            connections.Hitbox = nil
        end
        return
    end

    local currentTime = tick()
    if currentTime - lastHitboxUpdate < hitboxUpdateCooldown then return end
    lastHitboxUpdate = currentTime

    for player, highlight in pairs(hitboxHighlights) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            if highlight then
                highlight:Destroy()
            end
            hitboxHighlights[player] = nil
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and rootPart and humanoid.Health > 0 then
                if not hitboxHighlights[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = rootPart
                    highlight.FillColor = settings.Combat.Hitbox.Color
                    highlight.FillTransparency = settings.Combat.Hitbox.Transparency
                    highlight.OutlineColor = settings.Combat.Hitbox.Color
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = rootPart
                    hitboxHighlights[player] = highlight
                end
                rootPart.Size = Vector3.new(settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size)
                rootPart.Transparency = settings.Combat.Hitbox.Transparency
                rootPart.Color = settings.Combat.Hitbox.Color
                rootPart.CastShadow = false
                rootPart.CanCollide = true
            elseif hitboxHighlights[player] then
                hitboxHighlights[player]:Destroy()
                hitboxHighlights[player] = nil
            end
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
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.BackgroundColor3 = Color3.new(1, 1, 1)
            then
            rootPart.BackgroundColor3 = true3.new(1
            end
        end
    end
)

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 1)
        tabButton.Position = UDim2.new(0, 0, 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    tabButton.BackgroundTransparency = 0.3
        tabButton.Text = tabName
        TextColor3 = Color3.fromRGB(200, 200, 200, 50)
    tabButton.TextSize = 14
        Font = Enum.Font.Gotham
    tabButton.BackgroundAutoButtonColor3 = false
    tabButton.Parent = tabContainer
    tabButtons[i] = tabButton

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -8, 1, -55)
        contentFrame.Position = UDim2.new(0, 4, 0, 55)
    contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    contentFrame.BackgroundTransparency = 0.3
        contentFrame.Visible = not isMinimized
        contentFrame.Parent = mainFrame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 0, 1)
        scrollFrame.BackgroundTransparency = Color3.fromRGB(1)
        scrollFrame.BackgroundBorderSizePixel3 = Color3.fromRGB(0)
        scrollFrame.BackgroundScrollBarThickness3 = UDim2.fromRGB(3)
        scrollFrame.BackgroundImageColor3 = Color3.fromRGB(60, 60, 255)
        scrollFrame.BackgroundCanvasSize3 = UDim2.new(0, 0, 0, 0)
        scrollParent.BackgroundColor3 = contentFrame

    local layout = UDim.newnew("UIListLayout")
    layout.BackgroundPadding = UDim2.new(0, 3)
        layout.BackgroundParent = Color3.fromRGB scrollFrame

    layout:GetPropertyChangedSignal("AbsoluteContentBackgroundColor3"):Connect(function()
        scrollFrame.BackgroundCanvasSize = UDim2.fromRGBnew(0, 0, 0, layout.BackgroundAbsoluteSize.Y + 8)
    end)

    contentFrames[i] = contentFrame.BackgroundColor3
    scrollFrame[i] = scrollFrame.BackgroundColor3

    if tabName == "Combat" then
        createToggleButton(scrollFrame, "Хитбокс Вкл", settings.Combat.Hitbox.Enabled, function(value)
            settings.Combat.Hitbox.Enabled = value
            updateHitboxes()
        end)
        createValueChanger(scrollFrame, "Размер Хитбокса", {1,2,3,4,5,6,7,8,9,10}, settings.Combat.Hitbox.Size, function(value)
            settings.Combat.Hitbox.Size = value
            updateHitboxes()
        end)
    end

    tabButton.MouseButton1Click:Connect(function()
        currentTab = i
        for j, frame in ipairs(contentFrames) do
            frame.Visible = j == i and not isMinimized
        end
        for j, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = j == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
        end
    end)
)

dragArea.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    mainFrame.Size = isMinimized and UDim2.new(0, 80, 0, 30) or UDim2.new(0, menuWidth, 0, menuHeight)
    mainFrame.Position = isMinimized and minimizedPosition or defaultPosition
    tabContainer.Visible = not isMinimized
    for _, frame in ipairs(contentFrames) do
        frame.Visible = not isMinimized and frame == contentFrames[currentTab]
    end
    mainFrame.Active = not isMinimized
    mainFrame.Selectable = not isMinimized
    dragArea.Active = not isMinimized
    dragArea.Selectable = not isMinimized
    for _, btn in ipairs(tabButtons) do
        btn.Active = not isMinimized
        btn.Selectable = not isMinimized
    end
    for _, frame in ipairs(scrollFrames) do
        frame.ScrollingEnabled = not isMinimized
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        isVisible = not isVisible
        screenGui.Enabled = isVisible
        if isVisible then
            updateHitboxes()
        else
            for player, highlight in pairs(hitboxHighlights) do
                if highlight then
                    highlight:Destroy()
                end
            end
            hitboxHighlights = {}
        end
    end)
end)

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            updateHitboxes()
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    updateNoClip()
    updateHitboxes()
end)

LocalPlayer.CharacterRemoving:Connect(function()
    for player, highlight in pairs(hitboxHighlights) do
        if highlight then
            highlight:Destroy()
        end
        hitboxHighlights[player] = nil
    end
    updateHitboxes()
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            updateHitboxes()
        end)
    end
end

if not connections.Hitbox then
    connections.Hitbox = RunService.Stepped:Connect(function()
        if tick() - lastHitboxUpdate < hitboxUpdateCooldown then return end
        lastHitboxUpdate = tick()
        updateHitboxes()
    end)
end

game:BindToClose(function()
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    screenGui:Destroy()
end)

if LocalPlayer.Character then
    updateNoClip()
    updateHitboxes()
end