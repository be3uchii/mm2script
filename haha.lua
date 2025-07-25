local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 280, 180
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Misc"}
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
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
        NoClip = false,
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

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 60))
})
uiGradient.Rotation = 45
uiGradient.Parent = mainFrame

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
tabContainer.Parent = mainFrame

local particleCanvas = Instance.new("Frame")
particleCanvas.Size = UDim2.new(1, 0, 1, 25)
particleCanvas.BackgroundTransparency = 1
particleCanvas.ZIndex = 0
particleCanvas.Parent = mainFrame

local particles = {}
local maxParticles = 8
for i = 1, maxParticles do
    local size = math.random(2, 4)
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, size, 0, size)
    particle.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
    particle.BackgroundTransparency = math.random(40, 70) / 100
    particle.Position = UDim2.new(math.random(), 0, math.random() * 0.5, 0)
    particle.Parent = particleCanvas
    local particleCorner = Instance.new("UICorner")
    particleCorner.CornerRadius = UDim.new(1, 0)
    particleCorner.Parent = particle
    particles[i] = {frame = particle, velocity = Vector2.new(math.random(-2, 2) / 40, math.random(4, 8) / 30), alpha = math.random(40, 70) / 100}
end

local lastParticleUpdate = 0
local function updateParticles()
    if isMinimized or not isVisible then
        particleCanvas.Visible = false
        return
    end
    if tick() - lastParticleUpdate < 0.1 then
        return
    end
    lastParticleUpdate = tick()
    particleCanvas.Visible = true
    for _, particle in ipairs(particles) do
        local pos = particle.frame.Position
        local newX = pos.X.Scale + particle.velocity.X
        local newY = pos.Y.Scale + particle.velocity.Y
        local newAlpha = particle.alpha + math.sin(tick() * 1 + newX * 8) * 0.05
        newAlpha = math.clamp(newAlpha, 0.4, 0.6)
        if newY > 1.5 or newX < -0.1 or newX > 1.1 then
            newX = math.random()
            newY = -0.2
            particle.velocity = Vector2.new(math.random(-2, 2) / 40, math.random(4, 8) / 30)
            particle.alpha = math.random(40, 70) / 100
        end
        particle.frame.Position = UDim2.new(newX, 0, newY, 0)
        particle.frame.BackgroundTransparency = newAlpha
    end
end

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
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 255)
    stroke.Thickness = 1
    stroke.Transparency = defaultValue and 0.2 or 0.4
    stroke.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        toggle.Text = defaultValue and "ВКЛ" or "ВЫКЛ"
        local targetColor = defaultValue and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        local targetTransparency = defaultValue and 0.2 or 0.4
        TweenService:Create(toggle, tweenInfo, {BackgroundColor3 = targetColor, Size = UDim2.new(0.3, 0, 0.8, 0)}):Play()
        TweenService:Create(stroke, tweenInfo, {Transparency = targetTransparency}):Play()
        callback(defaultValue)
    end)
    
    toggle.MouseEnter:Connect(function()
        TweenService:Create(toggle, tweenInfo, {Size = UDim2.new(0.31, 0, 0.82, 0)}):Play()
        TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(90, 90, 255)}):Play()
    end)
    
    toggle.MouseLeave:Connect(function()
        TweenService:Create(toggle, tweenInfo, {Size = UDim2.new(0.3, 0, 0.8, 0)}):Play()
        TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(60, 60, 255)}):Play()
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
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = prevButton
    corner:Clone().Parent = nextButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = prevButton
    stroke:Clone().Parent = nextButton
    
    local currentIndex = defaultValueIndex
    
    local function updateValue()
        valueLabel.Text = tostring(values[currentIndex])
        TweenService:Create(valueLabel, tweenInfo, {TextTransparency = 0.15}):Play()
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
    
    prevButton.MouseEnter:Connect(function()
        TweenService:Create(prevButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 60), Size = UDim2.new(0.105, 0, 0.82, 0)}):Play()
    end)
    
    prevButton.MouseLeave:Connect(function()
        TweenService:Create(prevButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 30, 40), Size = UDim2.new(0.1, 0, 0.8, 0)}):Play()
    end)
    
    nextButton.MouseEnter:Connect(function()
        TweenService:Create(nextButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 60), Size = UDim2.new(0.105, 0, 0.82, 0)}):Play()
    end)
    
    nextButton.MouseLeave:Connect(function()
        TweenService:Create(nextButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 30, 40), Size = UDim2.new(0.1, 0, 0.8, 0)}):Play()
    end)
    
    return changerFrame
end

local function createColorButton(parent, text, defaultColor, callback)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, -8, 0, 20)
    colorFrame.BackgroundTransparency = 1
    colorFrame.Position = UDim2.new(0, 4, 0, 0)
    colorFrame.Parent = parent
    
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
    label.Parent = colorFrame
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0.3, 0, 0.8, 0)
    colorButton.Position = UDim2.new(0.7, 0, 0.1, 0)
    colorButton.BackgroundColor3 = defaultColor
    colorButton.Text = ""
    colorButton.Parent = colorFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = colorButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = colorButton
    
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 255)
    }
    
    local currentColorIndex = 1
    for i, color in ipairs(colors) do
        if color == defaultColor then
            currentColorIndex = i
            break
        end
    end
    
    colorButton.MouseButton1Click:Connect(function()
        currentColorIndex = currentColorIndex % #colors + 1
        TweenService:Create(colorButton, tweenInfo, {BackgroundColor3 = colors[currentColorIndex], Size = UDim2.new(0.3, 0, 0.8, 0)}):Play()
        callback(colors[currentColorIndex])
    end)
    
    colorButton.MouseEnter:Connect(function()
        TweenService:Create(colorButton, tweenInfo, {Size = UDim2.new(0.31, 0, 0.82, 0)}):Play()
        TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(90, 90, 255), Thickness = 1.1}):Play()
    end)
    
    colorButton.MouseLeave:Connect(function()
        TweenService:Create(colorButton, tweenInfo, {Size = UDim2.new(0.3, 0, 0.8, 0)}):Play()
        TweenService:Create(stroke, tweenInfo, {Color = Color3.fromRGB(60, 60, 255), Thickness = 1}):Play()
    end)
    
    return colorFrame
end

local function createTransparencySlider(parent, text, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -8, 0, 20)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Position = UDim2.new(0, 4, 0, 0)
    sliderFrame.Parent = parent
    
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
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.25, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.75, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(math.floor(defaultValue * 100)) .. "%"
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextTransparency = 0.2
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = sliderFrame
    
    local values = {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1}
    local currentIndex = math.floor(defaultValue * 10) + 1
    
    local prevButton = Instance.new("TextButton")
    prevButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    prevButton.Position = UDim2.new(0.65, 0, 0.1, 0)
    prevButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    prevButton.Text = "<"
    prevButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    prevButton.TextSize = 10
    prevButton.Font = Enum.Font.GothamBold
    prevButton.Parent = sliderFrame
    
    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    nextButton.Position = UDim2.new(0.85, 0, 0.1, 0)
    nextButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    nextButton.Text = ">"
    nextButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    nextButton.TextSize = 10
    nextButton.Font = Enum.Font.GothamBold
    nextButton.Parent = sliderFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = prevButton
    corner:Clone().Parent = nextButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = prevButton
    stroke:Clone().Parent = nextButton
    
    local function updateValue()
        valueLabel.Text = tostring(math.floor(values[currentIndex] * 100)) .. "%"
        TweenService:Create(valueLabel, tweenInfo, {TextTransparency = 0.15}):Play()
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
    
    prevButton.MouseEnter:Connect(function()
        TweenService:Create(prevButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 60), Size = UDim2.new(0.105, 0, 0.82, 0)}):Play()
    end)
    
    prevButton.MouseLeave:Connect(function()
        TweenService:Create(prevButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 30, 40), Size = UDim2.new(0.1, 0, 0.8, 0)}):Play()
    end)
    
    nextButton.MouseEnter:Connect(function()
        TweenService:Create(nextButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 60), Size = UDim2.new(0.105, 0, 0.82, 0)}):Play()
    end)
    
    nextButton.MouseLeave:Connect(function()
        TweenService:Create(nextButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 30, 40), Size = UDim2.new(0.1, 0, 0.8, 0)}):Play()
    end)
    
    return sliderFrame
end

local function updateHitboxes()
    for player, highlight in pairs(hitboxHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    hitboxHighlights = {}
    
    if not settings.Combat.Hitbox.Enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.Size = Vector3.new(2, 2, 1)
                    humanoidRootPart.Transparency = 1
                    humanoidRootPart.Color = Color3.fromRGB(255, 255, 255)
                    humanoidRootPart.CanCollide = false
                    humanoidRootPart.CastShadow = false
                end
            end
        end
        if connections.Hitbox then
            connections.Hitbox:Disconnect()
            connections.Hitbox = nil
        end
        if connections.HitboxCheck then
            connections.HitboxCheck:Disconnect()
            connections.HitboxCheck = nil
        end
        return
    end
    
    local function applyHitbox(player)
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoidRootPart and humanoid.Health > 0 then
                humanoidRootPart.Size = Vector3.new(settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size)
                humanoidRootPart.Transparency = settings.Combat.Hitbox.Transparency
                humanoidRootPart.Color = settings.Combat.Hitbox.Color
                humanoidRootPart.CanCollide = false
                humanoidRootPart.CastShadow = false
                
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
                else
                    local highlight = hitboxHighlights[player]
                    highlight.FillColor = settings.Combat.Hitbox.Color
                    highlight.FillTransparency = settings.Combat.Hitbox.Transparency
                    highlight.OutlineColor = settings.Combat.Hitbox.Color
                    highlight.OutlineTransparency = settings.Combat.Hitbox.Transparency
                end
            elseif hitboxHighlights[player] then
                hitboxHighlights[player]:Destroy()
                hitboxHighlights[player] = nil
            end
        end
    end
    
    if connections.Hitbox then
        connections.Hitbox:Disconnect()
    end
    connections.Hitbox = RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            applyHitbox(player)
        end
    end)
    
    if connections.HitboxCheck then
        connections.HitboxCheck:Disconnect()
    end
    connections.HitboxCheck = RunService.Heartbeat:Connect(function()
        if tick() - (connections.HitboxLastCheck or 0) < 0.5 then return end
        connections.HitboxLastCheck = tick()
        if settings.Combat.Hitbox.Enabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChildOfClass("Humanoid") and not hitboxHighlights[player] then
                    applyHitbox(player)
                end
            end
        end
    end)
end

local function updateESP()
    for player, highlight in pairs(espBoxes) do
        if highlight then
            highlight:Destroy()
        end
    end
    espBoxes = {}
    
    if not settings.ESP.Enabled or not settings.ESP.Boxes then
        if connections.ESP then
            connections.ESP:Disconnect()
            connections.ESP = nil
        end
        if connections.ESPCheck then
            connections.ESPCheck:Disconnect()
            connections.ESPCheck = nil
        end
        return
    end
    
    local function applyESP(player)
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoidRootPart and humanoid.Health > 0 then
                humanoidRootPart.CastShadow = false
                humanoidRootPart.CanCollide = false
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
                else
                    local highlight = espBoxes[player]
                    highlight.FillColor = settings.ESP.Color
                    highlight.FillTransparency = settings.ESP.Transparency
                    highlight.OutlineColor = settings.ESP.Color
                    highlight.OutlineTransparency = settings.ESP.Transparency
                end
            elseif espBoxes[player] then
                espBoxes[player]:Destroy()
                espBoxes[player] = nil
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
    
    if connections.ESPCheck then
        connections.ESPCheck:Disconnect()
    end
    connections.ESPCheck = RunService.Heartbeat:Connect(function()
        if tick() - (connections.ESPLastCheck or 0) < 0.5 then return end
        connections.ESPLastCheck = tick()
        if settings.ESP.Enabled and settings.ESP.Boxes then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChildOfClass("Humanoid") and not espBoxes[player] then
                    applyESP(player)
                end
            end
        end
    end)
end

local function updateNoClip()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not settings.Misc.NoClip
                part.CastShadow = false
            end
        end
    end
end

local function updateSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        humanoid.WalkSpeed = settings.Misc.Speed.Enabled and settings.Misc.Speed.Value or 16
    end
end

Lighting.GlobalShadows = false

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1 / #tabs, -3, 1, -3)
    tabButton.Position = UDim2.new((i - 1) / #tabs, 1.5, 0, 1.5)
    tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
    tabButton.BackgroundTransparency = 0.2
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextTransparency = 0.2
    tabButton.TextSize = 12
    tabButton.Font = Enum.Font.GothamBold
    tabButton.Parent = tabContainer

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabButton

    local tabStroke = Instance.new("UIStroke")
    tabStroke.Color = i == currentTab and Color3.fromRGB(60, 60, 255) or Color3.fromRGB(40, 40, 60)
    tabStroke.Thickness = 1
    tabStroke.Transparency = i == currentTab and 0.2 or 0.4
    tabStroke.Parent = tabButton

    tabButtons[i] = tabButton

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -8, 1, -60)
    contentFrame.Position = UDim2.new(0, 4, 0, 55)
    contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    contentFrame.BackgroundTransparency = 0.2
    contentFrame.Visible = i == currentTab
    contentFrame.Parent = mainFrame

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentFrame

    local contentStroke = Instance.new("UIStroke")
    contentStroke.Color = Color3.fromRGB(60, 60, 255)
    contentStroke.Thickness = 1
    contentStroke.Transparency = 0.3
    contentStroke.Parent = contentFrame

    local contentGradient = Instance.new("UIGradient")
    contentGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 65))
    })
    contentGradient.Rotation = 45
    contentGradient.Parent = contentFrame

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
        createValueChanger(scrollFrame, "Размер Хитбокса", {1, 2, 3, 4, 5, 6, 7, 8}, settings.Combat.Hitbox.Size, function(value)
            settings.Combat.Hitbox.Size = value
            updateHitboxes()
        end)
        createColorButton(scrollFrame, "Цвет Хитбокса", settings.Combat.Hitbox.Color, function(value)
            settings.Combat.Hitbox.Color = value
            updateHitboxes()
        end)
        createTransparencySlider(scrollFrame, "Прозрачность Хитбокса", settings.Combat.Hitbox.Transparency, function(value)
            settings.Combat.Hitbox.Transparency = value
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
        createColorButton(scrollFrame, "Цвет Боксов", settings.ESP.Color, function(value)
            settings.ESP.Color = value
            updateESP()
        end)
        createTransparencySlider(scrollFrame, "Прозрачность Боксов", settings.ESP.Transparency, function(value)
            settings.ESP.Transparency = value
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
        createValueChanger(scrollFrame, "Значение Скорости", {16, 16.5, 17, 17.5, 18, 18.5, 19, 19.5, 20}, settings.Misc.Speed.Value, function(value)
            settings.Misc.Speed.Value = value
            updateSpeed()
        end)
    end

    tabButton.MouseButton1Click:Connect(function()
        currentTab = i
        for j, frame in ipairs(contentFrames) do
            frame.Visible = j == i
            TweenService:Create(frame, tweenInfo, {BackgroundTransparency = j == i and 0.2 or 0.5}):Play()
        end
        for j, btn in ipairs(tabButtons) do
            local isActive = j == currentTab
            btn.BackgroundColor3 = isActive and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = isActive and Color3.fromRGB(60, 60, 255) or Color3.fromRGB(40, 40, 60)
                stroke.Transparency = isActive and 0.2 or 0.4
                TweenService:Create(stroke, tweenInfo, {Color = stroke.Color, Transparency = stroke.Transparency}):Play()
            end
        end
    end)
    
    tabButton.MouseEnter:Connect(function()
        if i != currentTab then
            TweenService:Create(tabButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}):Play()
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if i != currentTab then
            TweenService:Create(tabButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
        end
    end)
end

dragArea.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and minimizedSize or UDim2.new(0, menuWidth, 0, menuHeight)
    local targetTransparency = isMinimized and 0.3 or 0.2
    local targetPosition = isMinimized and minimizedPosition or defaultPosition
    TweenService:Create(mainFrame, tweenInfo, {Size = targetSize, BackgroundTransparency = targetTransparency, Position = targetPosition}):Play()
    tabContainer.Visible = not isMinimized
    for _, frame in ipairs(contentFrames) do
        frame.Visible = not isMinimized and frame == contentFrames[currentTab]
    end
    TweenService:Create(dragArea, tweenInfo, {TextTransparency = isMinimized and 0.3 or 0.2, TextSize = isMinimized and 12 or 14}):Play()
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
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = false
                if part.Name == "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
        task.defer(function()
            updateHitboxes()
            updateESP()
        end)
    end
    player.CharacterAdded:Connect(function(character)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = false
                if part.Name == "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
        task.defer(function()
            updateHitboxes()
            updateESP()
        end)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if hitboxHighlights[player] then
        hitboxHighlights[player]:Destroy()
        hitboxHighlights[player] = nil
    end
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CastShadow = false
            if part.Name == "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    end
    updateNoClip()
    updateSpeed()
    task.defer(function()
        updateHitboxes()
        updateESP()
    end)
    
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        task.defer(function()
            updateHitboxes()
            updateESP()
        end)
    end)
end)

if LocalPlayer.Character then
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CastShadow = false
            if part.Name == "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    end
    task.defer(function()
        updateHitboxes()
        updateESP()
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = player.Character.Humanoid
        humanoid.Died:Connect(function()
            task.defer(function()
                updateHitboxes()
                updateESP()
            end)
        end)
        player.CharacterAdded:Connect(function(character)
            local newHumanoid = character:WaitForChild("Humanoid")
            newHumanoid.Died:Connect(function()
                task.defer(function()
                    updateHitboxes()
                    updateESP()
                end)
            end)
        end)
    end
end

local function checkRoundEnd()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local roundEndRemote = ReplicatedStorage:FindFirstChild("RoundEnd") or (remotes and remotes:FindFirstChild("RoundEnd"))
    if roundEndRemote then
        roundEndRemote.OnClientEvent:Connect(function()
            task.wait(0.2)
            task.defer(function()
                updateHitboxes()
                updateESP()
            end)
        end)
    end
end

checkRoundEnd()
ReplicatedStorage.ChildAdded:Connect(checkRoundEnd)

RunService:BindToRenderStep("MenuUpdate", Enum.RenderPriority.Input.Value + 1, function()
    if isVisible then
        updateParticles()
    end
    for i, btn in ipairs(tabButtons) do
        local targetColor = i == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
        local targetTransparency = i == currentTab and 0.2 or 0.4
        if btn.BackgroundColor3 ~= targetColor or btn.BackgroundTransparency ~= targetTransparency then
            TweenService:Create(btn, tweenInfo, {BackgroundColor3 = targetColor, BackgroundTransparency = targetTransparency}):Play()
        end
    end
end)

game:BindToClose(function()
    RunService:UnbindFromRenderStep("MenuUpdate")
    for _, conn in pairs(connections) do
        if conn then
            conn:Disconnect()
        end
    end
    for _, highlight in pairs(hitboxHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    for _, highlight in pairs(espBoxes) do
        if highlight then
            highlight:Destroy()
        end
    end
    Lighting.GlobalShadows = true
    screenGui:Destroy()
end)