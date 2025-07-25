local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 300, 200
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Misc"}
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local minimizedSize = UDim2.new(0, 90, 0, 35)
local minimizedPosition = UDim2.new(0.5, -45, 0, 10)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)

local settings = {
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 1,
            Color = Color3.fromRGB(255, 0, 0),
            Transparency = 0.5
        },
        AutoKnife = {
            Enabled = false,
            Range = 50
        },
        AimAssist = {
            Enabled = false,
            Strength = 0.5
        },
        SpeedBoost = {
            Enabled = false,
            Multiplier = 2
        },
        InfiniteAmmo = {
            Enabled = false
        }
    },
    ESP = {
        Enabled = false,
        Boxes = false,
        Color = Color3.fromRGB(0, 255, 0),
        Transparency = 0.5
    },
    Misc = {
        NoClip = false
    }
}

local hitboxParts = {}
local espBoxes = {}
local connections = {}

if PlayerGui:FindFirstChild("TestMenuGui") then
    PlayerGui.TestMenuGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TestMenuGui"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
mainFrame.Position = defaultPosition
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(100, 100, 100)
uiStroke.Thickness = 1.5
uiStroke.Transparency = 0.5
uiStroke.Parent = mainFrame

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, 0, 0, 30)
dragArea.BackgroundTransparency = 1
dragArea.Text = "happy user"
dragArea.TextColor3 = Color3.fromRGB(160, 160, 160)
dragArea.TextTransparency = 0.4
dragArea.TextSize = isMinimized and 13 or 15
dragArea.Font = Enum.Font.SourceSans
dragArea.TextXAlignment = Enum.TextXAlignment.Center
dragArea.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local particleCanvas = Instance.new("Frame")
particleCanvas.Size = UDim2.new(1, 0, 1, 30)
particleCanvas.BackgroundTransparency = 1
particleCanvas.ZIndex = 0
particleCanvas.Parent = mainFrame

local particles = {}
local maxParticles = 10
for i = 1, maxParticles do
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, 2, 0, 2)
    particle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    particle.BackgroundTransparency = math.random(40, 70) / 100
    particle.Position = UDim2.new(math.random(), 0, math.random() * 0.5, 0)
    particle.Parent = particleCanvas
    local particleCorner = Instance.new("UICorner")
    particleCorner.CornerRadius = UDim.new(1, 0)
    particleCorner.Parent = particle
    particles[i] = {frame = particle, velocity = Vector2.new(math.random(-3, 3) / 15, math.random(5, 9) / 10), alpha = math.random(40, 70) / 100}
end

local function updateParticles()
    if isMinimized or not isVisible then
        particleCanvas.Visible = false
        return
    end
    particleCanvas.Visible = true
    for _, particle in ipairs(particles) do
        local pos = particle.frame.Position
        local newX = pos.X.Scale + particle.velocity.X / 100
        local newY = pos.Y.Scale + particle.velocity.Y / 100
        local newAlpha = particle.alpha + math.sin(tick() * 2 + newX * 10) * 0.08
        newAlpha = math.clamp(newAlpha, 0.4, 0.7)
        if newY > 1.5 or newX < -0.1 or newX > 1.1 then
            newX = math.random()
            newY = -0.1
            particle.velocity = Vector2.new(math.random(-3, 3) / 15, math.random(5, 9) / 10)
            particle.alpha = math.random(40, 70) / 100
        end
        particle.frame.Position = UDim2.new(newX, 0, newY, 0)
        particle.frame.BackgroundTransparency = newAlpha
    end
end

local tabButtons = {}
local contentFrames = {}
local scrollFrames = {}

local function createToggle(parent, text, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 25)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.TextTransparency = 0.4
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.25, 0, 0.8, 0)
    toggle.Position = UDim2.new(0.75, 0, 0.1, 0)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    toggle.Text = defaultValue and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 12
    toggle.Font = Enum.Font.SourceSansBold
    toggle.Parent = toggleFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
        local newValue = not defaultValue
        defaultValue = newValue
        toggle.BackgroundColor3 = newValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        toggle.Text = newValue and "ON" or "OFF"
        callback(newValue)
    end)
    
    return toggle
end

local function createValueChanger(parent, text, values, defaultValueIndex, callback)
    local changerFrame = Instance.new("Frame")
    changerFrame.Size = UDim2.new(1, -10, 0, 25)
    changerFrame.BackgroundTransparency = 1
    changerFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.TextTransparency = 0.4
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = changerFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(values[defaultValueIndex])
    valueLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    valueLabel.TextTransparency = 0.4
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = changerFrame
    
    local prevButton = Instance.new("TextButton")
    prevButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    prevButton.Position = UDim2.new(0.7, 0, 0.1, 0)
    prevButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    prevButton.Text = "<"
    prevButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    prevButton.TextSize = 12
    prevButton.Font = Enum.Font.SourceSansBold
    prevButton.Parent = changerFrame
    
    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    nextButton.Position = UDim2.new(0.85, 0, 0.1, 0)
    nextButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    nextButton.Text = ">"
    nextButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    nextButton.TextSize = 12
    nextButton.Font = Enum.Font.SourceSansBold
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

local function createColorButton(parent, text, defaultColor, callback)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, -10, 0, 25)
    colorFrame.BackgroundTransparency = 1
    colorFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.TextTransparency = 0.4
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorFrame
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0.25, 0, 0.8, 0)
    colorButton.Position = UDim2.new(0.75, 0, 0.1, 0)
    colorButton.BackgroundColor3 = defaultColor
    colorButton.Text = ""
    colorButton.Parent = colorFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = colorButton
    
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
        colorButton.BackgroundColor3 = colors[currentColorIndex]
        callback(colors[currentColorIndex])
    end)
    
    return colorButton
end

local function createTransparencySlider(parent, text, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 25)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.TextTransparency = 0.4
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.25, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.75, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(math.floor(defaultValue * 100)) .. "%"
    valueLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    valueLabel.TextTransparency = 0.4
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = sliderFrame
    
    local values = {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1}
    local currentIndex = math.floor(defaultValue * 10) + 1
    
    local prevButton = Instance.new("TextButton")
    prevButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    prevButton.Position = UDim2.new(0.6, 0, 0.1, 0)
    prevButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    prevButton.Text = "<"
    prevButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    prevButton.TextSize = 12
    prevButton.Font = Enum.Font.SourceSansBold
    prevButton.Parent = sliderFrame
    
    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    nextButton.Position = UDim2.new(0.85, 0, 0.1, 0)
    nextButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    nextButton.Text = ">"
    nextButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    nextButton.TextSize = 12
    nextButton.Font = Enum.Font.SourceSansBold
    nextButton.Parent = sliderFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = prevButton
    corner:Clone().Parent = nextButton
    
    local function updateValue()
        valueLabel.Text = tostring(math.floor(values[currentIndex] * 100)) .. "%"
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
    
    return sliderFrame
end

local function updateHitboxes()
    for _, part in pairs(hitboxParts) do
        if part:IsA("BasePart") then
            part:Destroy()
        end
    end
    hitboxParts = {}
    
    if not settings.Combat.Hitbox.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoidRootPart then
                humanoidRootPart.Size = Vector3.new(settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size)
                humanoidRootPart.Transparency = settings.Combat.Hitbox.Transparency
                humanoidRootPart.Color = settings.Combat.Hitbox.Color
                humanoidRootPart.Material = Enum.Material.Neon
                humanoidRootPart.CanCollide = true
                
                local highlight = Instance.new("Highlight")
                highlight.Adornee = humanoidRootPart
                highlight.FillColor = settings.Combat.Hitbox.Color
                highlight.FillTransparency = settings.Combat.Hitbox.Transparency
                highlight.OutlineColor = settings.Combat.Hitbox.Color
                highlight.OutlineTransparency = settings.Combat.Hitbox.Transparency
                highlight.Parent = humanoidRootPart
                
                table.insert(hitboxParts, humanoidRootPart)
            end
        end
    end
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if espBoxes[player] then
                espBoxes[player]:Destroy()
                espBoxes[player] = nil
            end
            
            if not settings.ESP.Enabled or not settings.ESP.Boxes then continue end
            
            if player.Character then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESPBox"
                    highlight.Adornee = player.Character
                    highlight.FillColor = settings.ESP.Color
                    highlight.FillTransparency = settings.ESP.Transparency
                    highlight.OutlineColor = settings.ESP.Color
                    highlight.OutlineTransparency = settings.ESP.Transparency
                    highlight.Parent = player.Character
                    
                    espBoxes[player] = highlight
                end
            end
        end
    end
end

local function updateNoClip()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not settings.Misc.NoClip
            end
        end
    end
end

local function updateAutoKnife()
    if not settings.Combat.AutoKnife.Enabled then
        if connections.AutoKnife then
            connections.AutoKnife:Disconnect()
            connections.AutoKnife = nil
        end
        return
    end
    
    if connections.AutoKnife then
        connections.AutoKnife:Disconnect()
    end
    
    connections.AutoKnife = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife") then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                        if distance <= settings.Combat.AutoKnife.Range then
                            game:GetService("ReplicatedStorage").Remotes.KnifeThrow:FireServer(humanoidRootPart.Position)
                        end
                    end
                end
            end
        end
    end)
end

local function updateAimAssist()
    if not settings.Combat.AimAssist.Enabled then
        if connections.AimAssist then
            connections.AimAssist:Disconnect()
            connections.AimAssist = nil
        end
        return
    end
    
    if connections.AimAssist then
        connections.AimAssist:Disconnect()
    end
    
    connections.AimAssist = RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") then
            local closestPlayer = nil
            local closestDistance = math.huge
            local camera = workspace.CurrentCamera
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoidRootPart = player.Character.HumanoidRootPart
                    local screenPos, onScreen = camera:WorldToScreenPoint(humanoidRootPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
            
            if closestPlayer and closestPlayer.Character then
                local targetPos = closestPlayer.Character.HumanoidRootPart.Position
                local currentPos = camera.CFrame.Position
                local direction = (targetPos - currentPos).Unit
                local newCFrame = CFrame.new(currentPos, currentPos + direction)
                camera.CFrame = camera.CFrame:Lerp(newCFrame, settings.Combat.AimAssist.Strength)
            end
        end
    end)
end

local function updateSpeedBoost()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        humanoid.WalkSpeed = settings.Combat.SpeedBoost.Enabled and 16 * settings.Combat.SpeedBoost.Multiplier or 16
    end
end

local function updateInfiniteAmmo()
    if not settings.Combat.InfiniteAmmo.Enabled then
        if connections.InfiniteAmmo then
            connections.InfiniteAmmo:Disconnect()
            connections.InfiniteAmmo = nil
        end
        return
    end
    
    if connections.InfiniteAmmo then
        connections.InfiniteAmmo:Disconnect()
    end
    
    connections.InfiniteAmmo = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") then
            local gun = LocalPlayer.Character.Gun
            if gun:FindFirstChild("Ammo") then
                gun.Ammo.Value = 999
            end
        end
    end)
end

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1 / #tabs, -4, 1, -4)
    tabButton.Position = UDim2.new((i - 1) / #tabs, 2, 0, 2)
    tabButton.BackgroundColor3 = i == 1 and Color3.fromRGB(85, 85, 85) or Color3.fromRGB(50, 50, 50)
    tabButton.BackgroundTransparency = 0.3
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(160, 160, 160)
    tabButton.TextTransparency = 0.4
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.SourceSans
    tabButton.Parent = tabContainer

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 10)
    tabCorner.Parent = tabButton

    local tabStroke = Instance.new("UIStroke")
    tabStroke.Color = i == currentTab and Color3.fromRGB(160, 160, 160) or Color3.fromRGB(130, 130, 130)
    tabStroke.Thickness = 1
    tabStroke.Transparency = i == currentTab and 0.3 or 0.6
    tabStroke.Parent = tabButton

    tabButtons[i] = tabButton

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -10, 1, -70)
    contentFrame.Position = UDim2.new(0, 5, 0, 65)
    contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    contentFrame.BackgroundTransparency = 0.3
    contentFrame.Visible = i == 1
    contentFrame.Parent = mainFrame

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 10)
    contentCorner.Parent = contentFrame

    local contentStroke = Instance.new("UIStroke")
    contentStroke.Color = Color3.fromRGB(100, 100, 100)
    contentStroke.Thickness = 1
    contentStroke.Transparency = 0.6
    contentStroke.Parent = contentFrame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = contentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scrollFrame

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    contentFrames[i] = contentFrame
    scrollFrames[i] = scrollFrame

    if tabName == "Combat" then
        createToggle(scrollFrame, "Hitbox Enabled", settings.Combat.Hitbox.Enabled, function(value)
            settings.Combat.Hitbox.Enabled = value
            updateHitboxes()
        end)
        
        createValueChanger(scrollFrame, "Hitbox Size", {1, 2, 3, 4, 5, 6, 7, 8}, settings.Combat.Hitbox.Size, function(value)
            settings.Combat.Hitbox.Size = value
            updateHitboxes()
        end)
        
        createColorButton(scrollFrame, "Hitbox Color", settings.Combat.Hitbox.Color, function(value)
            settings.Combat.Hitbox.Color = value
            updateHitboxes()
        end)
        
        createTransparencySlider(scrollFrame, "Hitbox Transparency", settings.Combat.Hitbox.Transparency, function(value)
            settings.Combat.Hitbox.Transparency = value
            updateHitboxes()
        end)
        
        createToggle(scrollFrame, "Auto Knife Throw", settings.Combat.AutoKnife.Enabled, function(value)
            settings.Combat.AutoKnife.Enabled = value
            updateAutoKnife()
        end)
        
        createValueChanger(scrollFrame, "Knife Throw Range", {10, 20, 30, 40, 50, 60, 70, 80}, settings.Combat.AutoKnife.Range, function(value)
            settings.Combat.AutoKnife.Range = value
            updateAutoKnife()
        end)
        
        createToggle(scrollFrame, "Sheriff Aim Assist", settings.Combat.AimAssist.Enabled, function(value)
            settings.Combat.AimAssist.Enabled = value
            updateAimAssist()
        end)
        
        createValueChanger(scrollFrame, "Aim Assist Strength", {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1}, settings.Combat.AimAssist.Strength, function(value)
            settings.Combat.AimAssist.Strength = value
            updateAimAssist()
        end)
        
        createToggle(scrollFrame, "Speed Boost", settings.Combat.SpeedBoost.Enabled, function(value)
            settings.Combat.SpeedBoost.Enabled = value
            updateSpeedBoost()
        end)
        
        createValueChanger(scrollFrame, "Speed Multiplier", {1.5, 2, 2.5, 3, 3.5, 4}, settings.Combat.SpeedBoost.Multiplier, function(value)
            settings.Combat.SpeedBoost.Multiplier = value
            updateSpeedBoost()
        end)
        
        createToggle(scrollFrame, "Infinite Ammo", settings.Combat.InfiniteAmmo.Enabled, function(value)
            settings.Combat.InfiniteAmmo.Enabled = value
            updateInfiniteAmmo()
        end)
    elseif tabName == "ESP" then
        createToggle(scrollFrame, "ESP Enabled", settings.ESP.Enabled, function(value)
            settings.ESP.Enabled = value
            updateESP()
        end)
        
        createToggle(scrollFrame, "Box ESP", settings.ESP.Boxes, function(value)
            settings.ESP.Boxes = value
            updateESP()
        end)
        
        createColorButton(scrollFrame, "Box Color", settings.ESP.Color, function(value)
            settings.ESP.Color = value
            updateESP()
        end)
        
        createTransparencySlider(scrollFrame, "Box Transparency", settings.ESP.Transparency, function(value)
            settings.ESP.Transparency = value
            updateESP()
        end)
    elseif tabName == "Misc" then
        createToggle(scrollFrame, "NoClip", settings.Misc.NoClip, function(value)
            settings.Misc.NoClip = value
            updateNoClip()
        end)
    end

    tabButton.MouseButton1Click:Connect(function()
        for j, frame in ipairs(contentFrames) do
            frame.Visible = j == i
            local tween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = j == i and 0.3 or 0.6})
            tween:Play()
        end
        currentTab = i
        for j, btn in ipairs(tabButtons) do
            local targetStrokeColor = j == currentTab and Color3.fromRGB(160, 160, 160) or Color3.fromRGB(130, 130, 130)
            local targetStrokeTransparency = j == currentTab and 0.3 or 0.6
            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if stroke then
                local strokeTween = TweenService:Create(stroke, tweenInfo, {Color = targetStrokeColor, Transparency = targetStrokeTransparency})
                strokeTween:Play()
            end
        end
    end)
end

dragArea.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and minimizedSize or UDim2.new(0, menuWidth, 0, menuHeight)
    local targetTransparency = isMinimized and 0.5 or 0.3
    local targetPosition = isMinimized and minimizedPosition or defaultPosition
    local tween = TweenService:Create(mainFrame, tweenInfo, {Size = targetSize, BackgroundTransparency = targetTransparency, Position = targetPosition})
    tween:Play()
    tabContainer.Visible = not isMinimized
    for _, frame in ipairs(contentFrames) do
        frame.Visible = not isMinimized and frame == contentFrames[currentTab]
    end
    local titleTween = TweenService:Create(dragArea, tweenInfo, {TextTransparency = isMinimized and 0.5 or 0.4, TextSize = isMinimized and 13 or 15})
    titleTween:Play()
end)

Players.PlayerAdded:Connect(function(player)
    updateHitboxes()
    updateESP()
end)

Players.PlayerRemoving:Connect(function(player)
    updateHitboxes()
    updateESP()
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    updateNoClip()
    updateSpeedBoost()
end)

RunService:BindToRenderStep("MenuUpdate", Enum.RenderPriority.Input.Value + 1, function()
    updateParticles()
    for i, btn in ipairs(tabButtons) do
        local targetColor = i == currentTab and Color3.fromRGB(85, 85, 85) or Color3.fromRGB(50, 50, 50)
        local targetTransparency = i == currentTab and 0.25 or 0.4
        if btn.BackgroundColor3 ~= targetColor or btn.BackgroundTransparency ~= targetTransparency then
            local tween = TweenService:Create(btn, tweenInfo, {BackgroundColor3 = targetColor, BackgroundTransparency = targetTransparency})
            tween:Play()
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
    screenGui:Destroy()
end)