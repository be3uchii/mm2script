local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 280, 180
local menuX, menuY = (viewportSize.X - menuWidth)/2, (viewportSize.Y - menuHeight)/2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Misc"}
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local minimizedSize = UDim2.new(0, 80, 0, 30)
local minimizedPosition = UDim2.new(0.5, -40, 0, 10)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)

local settings = {
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 1,
            Color = Color3.fromRGB(255, 0, 0),
            Transparency = 0.5
        }
    },
    ESP = {
        Enabled = false,
        Boxes = false,
        Color = Color3.fromRGB(0, 255, 0),
        Transparency = 0.5
    },
    Misc = {
        NoClip = true,
        Speed = {
            Enabled = false,
            Value = 16
        }
    }
}

local hitboxHighlights = {}
local espBoxes = {}
local connections = {}
local tabButtons = {}
local contentFrames = {}
local scrollFrames = {}
local wallParts = {}

local function findWalls()
    wallParts = {}
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide and part.Transparency < 0.5 then
            table.insert(wallParts, part)
        end
    end
end

findWalls()
workspace.DescendantAdded:Connect(function(part)
    if part:IsA("BasePart") and part.CanCollide and part.Transparency < 0.5 then
        table.insert(wallParts, part)
    end
end)

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
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(60, 60, 255)
uiStroke.Thickness = 1
uiStroke.Transparency = 0.3
uiStroke.Parent = mainFrame

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, 0, 0, 25)
dragArea.BackgroundTransparency = 1
dragArea.Text = "Silence 3.0"
dragArea.TextColor3 = Color3.fromRGB(200, 200, 200)
dragArea.TextTransparency = 0.2
dragArea.TextSize = isMinimized and 12 or 14
dragArea.Font = Enum.Font.GothamBold
dragArea.TextXAlignment = Enum.TextXAlignment.Center
dragArea.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 25)
tabContainer.Position = UDim2.new(0, 0, 0, 25)
tabContainer.BackgroundTransparency = 1
tabContainer.Visible = not isMinimized
tabContainer.Parent = mainFrame

local function createToggle(parent, text, defaultValue, callback)
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
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextTransparency = 0.2
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.3, 0, 0.8, 0)
    toggle.Position = UDim2.new(0.7, 0, 0.1, 0)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    toggle.Text = defaultValue and "ВКЛ" or "ВЫКЛ"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 10
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = toggleFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = toggle
    
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
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextTransparency = 0.2
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = changerFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(values[defaultValueIndex])
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextTransparency = 0.2
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = changerFrame
    
    local prevButton = Instance.new("TextButton")
    prevButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    prevButton.Position = UDim2.new(0.7, 0, 0.1, 0)
    prevButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    prevButton.Text = "<"
    prevButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    prevButton.TextSize = 10
    prevButton.Font = Enum.Font.GothamBold
    prevButton.Parent = changerFrame
    
    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    nextButton.Position = UDim2.new(0.85, 0, 0.1, 0)
    nextButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    nextButton.Text = ">"
    nextButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    nextButton.TextSize = 10
    nextButton.Font = Enum.Font.GothamBold
    nextButton.Parent = changerFrame
    
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

local function updateHitboxes()
    for player, highlight in pairs(hitboxHighlights) do
        if highlight then highlight:Destroy() end
    end
    hitboxHighlights = {}
    
    if not settings.Combat.Hitbox.Enabled then
        if connections.Hitbox then
            connections.Hitbox:Disconnect()
            connections.Hitbox = nil
        end
        return
    end
    
    local function applyHitbox(player)
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoidRootPart and humanoid.Health > 0 then
                humanoidRootPart.Size = Vector3.new(settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size)
                humanoidRootPart.Transparency = settings.Combat.Hitbox.Transparency
                humanoidRootPart.Color = settings.Combat.Hitbox.Color
                
                if not hitboxHighlights[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = humanoidRootPart
                    highlight.FillColor = settings.Combat.Hitbox.Color
                    highlight.FillTransparency = settings.Combat.Hitbox.Transparency
                    highlight.OutlineColor = settings.Combat.Hitbox.Color
                    highlight.OutlineTransparency = settings.Combat.Hitbox.Transparency
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = humanoidRootPart
                    hitboxHighlights[player] = highlight
                end
            end
        end
    end
    
    connections.Hitbox = RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            applyHitbox(player)
        end
    end)
end

local function updateESP()
    for player, highlight in pairs(espBoxes) do
        if highlight then highlight:Destroy() end
    end
    espBoxes = {}
    
    if not settings.ESP.Enabled then
        if connections.ESP then
            connections.ESP:Disconnect()
            connections.ESP = nil
        end
        return
    end
    
    if not settings.ESP.Boxes then return end
    
    local function applyESP(player)
        if player ~= LocalPlayer then
            if player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    if not espBoxes[player] then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ESPBox"
                        highlight.Adornee = player.Character
                        highlight.FillColor = settings.ESP.Color
                        highlight.FillTransparency = settings.ESP.Transparency
                        highlight.OutlineColor = settings.ESP.Color
                        highlight.OutlineTransparency = settings.ESP.Transparency
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = player.Character
                        espBoxes[player] = highlight
                    end
                end
            end
        end
    end
    
    if connections.ESP then
        connections.ESP:Disconnect()
    end
    
    connections.ESP = RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            applyESP(player)
        end
    end)
    
    for _, player in pairs(Players:GetPlayers()) do
        player.CharacterAdded:Connect(function(character)
            task.wait()
            applyESP(player)
        end)
    end
end

local function updateNoClip()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if settings.Misc.NoClip then
                    part.CanCollide = false
                    for _, wall in pairs(wallParts) do
                        if wall:IsDescendantOf(workspace) then
                            wall.CanCollide = true
                        end
                    end
                else
                    part.CanCollide = true
                end
            end
        end
    end
end

local function updateSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = settings.Misc.Speed.Enabled and settings.Misc.Speed.Value or 16
    end
end

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1/#tabs, -3, 1, -3)
    tabButton.Position = UDim2.new((i-1)/#tabs, 1.5, 0, 1.5)
    tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
    tabButton.BackgroundTransparency = 0.2
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextTransparency = 0.2
    tabButton.TextSize = 12
    tabButton.Font = Enum.Font.GothamBold
    tabButton.Parent = tabContainer

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -8, 1, -60)
    contentFrame.Position = UDim2.new(0, 4, 0, 55)
    contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    contentFrame.BackgroundTransparency = 0.2
    contentFrame.Visible = i == currentTab and not isMinimized
    contentFrame.Parent = mainFrame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 255)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = contentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.Parent = scrollFrame

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)

    contentFrames[i] = contentFrame
    scrollFrames[i] = scrollFrame

    if tabName == "Combat" then
        createToggle(scrollFrame, "Хитбокс Вкл", settings.Combat.Hitbox.Enabled, function(value)
            settings.Combat.Hitbox.Enabled = value
            updateHitboxes()
        end)
        createValueChanger(scrollFrame, "Размер Хитбокса", {1,2,3,4,5,6,7,8}, settings.Combat.Hitbox.Size, function(value)
            settings.Combat.Hitbox.Size = value
            updateHitboxes()
        end)
    elseif tabName == "ESP" then
        createToggle(scrollFrame, "ESP Вкл", settings.ESP.Enabled, function(value)
            settings.ESP.Enabled = value
            updateESP()
        end)
        createToggle(scrollFrame, "Боксы ESP", settings.ESP.Boxes, function(value)
            settings.ESP.Boxes = value
            updateESP()
        end)
    elseif tabName == "Misc" then
        createToggle(scrollFrame, "NoClip", settings.Misc.NoClip, function(value)
            settings.Misc.NoClip = value
            updateNoClip()
        end)
        createToggle(scrollFrame, "Скорость Вкл", settings.Misc.Speed.Enabled, function(value)
            settings.Misc.Speed.Enabled = value
            updateSpeed()
        end)
        createValueChanger(scrollFrame, "Значение Скорости", {16,18,20,22,24,26,28,30}, settings.Misc.Speed.Value, function(value)
            settings.Misc.Speed.Value = value
            updateSpeed()
        end)
    end

    tabButton.MouseButton1Click:Connect(function()
        currentTab = i
        for j, frame in ipairs(contentFrames) do
            frame.Visible = j == i and not isMinimized
            if frame.Visible then
                frame.BackgroundTransparency = 0.2
            end
        end
        for j, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = j == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
        end
    end)
end

dragArea.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    mainFrame.Size = isMinimized and minimizedSize or UDim2.new(0, menuWidth, 0, menuHeight)
    mainFrame.Position = isMinimized and minimizedPosition or defaultPosition
    tabContainer.Visible = not isMinimized
    for _, frame in ipairs(contentFrames) do
        frame.Visible = not isMinimized and frame == contentFrames[currentTab]
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        isVisible = not isVisible
        screenGui.Enabled = isVisible
        if isVisible then
            updateHitboxes()
            updateESP()
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait()
        updateHitboxes()
        updateESP()
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    updateNoClip()
    updateSpeed()
    task.wait()
    updateHitboxes()
    updateESP()
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            task.wait()
            updateHitboxes()
            updateESP()
        end)
    end
end

RunService:BindToRenderStep("MenuUpdate", Enum.RenderPriority.Input.Value + 1, function()
    if isVisible then
        for i, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = i == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
        end
    end
end)

game:BindToClose(function()
    RunService:UnbindFromRenderStep("MenuUpdate")
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    screenGui:Destroy()
end)

updateNoClip()
updateHitboxes()
updateESP()