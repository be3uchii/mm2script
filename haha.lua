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

-- Настройки функций
local settings = {
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 1,
            Color = Color3.fromRGB(255, 0, 0)
        }
    },
    ESP = {
        Enabled = false,
        Names = false,
        Boxes = false,
        Tracers = false,
        Color = Color3.fromRGB(0, 255, 0)
    },
    Misc = {
        NoClip = false,
        Fly = false,
        Speed = false,
        SpeedValue = 16,
        JumpPower = false,
        JumpPowerValue = 50
    }
}

local hitboxParts = {}
local espFolders = {}
local tracers = {}

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

local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 25)
    button.Position = UDim2.new(0, 5, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BackgroundTransparency = 0.3
    button.Text = text
    button.TextColor3 = Color3.fromRGB(160, 160, 160)
    button.TextTransparency = 0.4
    button.TextSize = 14
    button.Font = Enum.Font.SourceSans
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

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
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local hitbox = Instance.new("Part")
                hitbox.Size = Vector3.new(settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size)
                hitbox.CFrame = humanoidRootPart.CFrame
                hitbox.Anchored = true
                hitbox.CanCollide = false
                hitbox.Transparency = 0.5
                hitbox.Color = settings.Combat.Hitbox.Color
                hitbox.Material = Enum.Material.Neon
                hitbox.Parent = workspace
                
                table.insert(hitboxParts, hitbox)
                
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = humanoidRootPart
                weld.Part1 = hitbox
                weld.Parent = hitbox
            end
        end
    end
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local espFolder = player:FindFirstChild("ESP_Folder")
            if espFolder then
                espFolder:Destroy()
            end
            
            if not settings.ESP.Enabled then continue end
            
            if player.Character then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local head = player.Character:FindFirstChild("Head")
                
                if humanoidRootPart and humanoid and head then
                    local newFolder = Instance.new("Folder")
                    newFolder.Name = "ESP_Folder"
                    newFolder.Parent = player
                    
                    if settings.ESP.Names then
                        local nameTag = Instance.new("BillboardGui")
                        nameTag.Name = "NameTag"
                        nameTag.Size = UDim2.new(0, 200, 0, 50)
                        nameTag.StudsOffset = Vector3.new(0, 2.5, 0)
                        nameTag.AlwaysOnTop = true
                        nameTag.Adornee = head
                        nameTag.Parent = newFolder
                        
                        local nameLabel = Instance.new("TextLabel")
                        nameLabel.Size = UDim2.new(1, 0, 1, 0)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Text = player.Name
                        nameLabel.TextColor3 = settings.ESP.Color
                        nameLabel.TextSize = 14
                        nameLabel.Font = Enum.Font.SourceSansBold
                        nameLabel.TextStrokeTransparency = 0.5
                        nameLabel.Parent = nameTag
                    end
                    
                    if settings.ESP.Boxes then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Name = "Box"
                        box.Size = Vector3.new(4, 6, 2)
                        box.AlwaysOnTop = true
                        box.ZIndex = 10
                        box.Transparency = 0.5
                        box.Color3 = settings.ESP.Color
                        box.Adornee = humanoidRootPart
                        box.Parent = newFolder
                    end
                    
                    if settings.ESP.Tracers then
                        local tracer = Instance.new("Frame")
                        tracer.Name = "Tracer_" .. player.Name
                        tracer.Size = UDim2.new(0, 1, 0, 1)
                        tracer.BackgroundColor3 = settings.ESP.Color
                        tracer.BorderSizePixel = 0
                        tracer.Parent = screenGui
                        tracers[player] = tracer
                    end
                end
            end
        end
    end
end

local function updateTracers()
    for player, tracer in pairs(tracers) do
        if player and player.Character and tracer then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    tracer.Visible = true
                    tracer.Position = UDim2.new(0, vector.X, 0, vector.Y)
                    tracer.Rotation = math.deg(math.atan2(
                        (vector.Y - viewportSize.Y/2),
                        (vector.X - viewportSize.X/2)
                    )) + 90
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                    tracer.Size = UDim2.new(0, 200, 0, 2 + (100 / distance))
                else
                    tracer.Visible = false
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

local function updateFly()
    if not settings.Misc.Fly then return end
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 10000
    bodyGyro.D = 100
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.P = 10000
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    
    if LocalPlayer.Character then
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            bodyGyro.Parent = humanoidRootPart
            bodyVelocity.Parent = humanoidRootPart
            
            local flySpeed = 50
            
            game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                
                if input.KeyCode == Enum.KeyCode.Space then
                    bodyVelocity.Velocity = Vector3.new(bodyVelocity.Velocity.X, flySpeed, bodyVelocity.Velocity.Z)
                elseif input.KeyCode == Enum.KeyCode.LeftShift then
                    bodyVelocity.Velocity = Vector3.new(bodyVelocity.Velocity.X, -flySpeed, bodyVelocity.Velocity.Z)
                end
            end)
            
            game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                
                if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then
                    bodyVelocity.Velocity = Vector3.new(bodyVelocity.Velocity.X, 0, bodyVelocity.Velocity.Z)
                end
            end)
            
            RunService.RenderStepped:Connect(function()
                if not settings.Misc.Fly then
                    bodyGyro:Destroy()
                    bodyVelocity:Destroy()
                    return
                end
                
                local cam = workspace.CurrentCamera.CFrame
                local moveDirection = Vector3.new()
                
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + cam.LookVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - cam.LookVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - cam.RightVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + cam.RightVector
                end
                
                moveDirection = moveDirection.Unit * flySpeed
                bodyVelocity.Velocity = Vector3.new(moveDirection.X, bodyVelocity.Velocity.Y, moveDirection.Z)
                bodyGyro.CFrame = cam
            end)
        end
    end
end

local function updateSpeed()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = settings.Misc.Speed and settings.Misc.SpeedValue or 16
        end
    end
end

local function updateJumpPower()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = settings.Misc.JumpPower and settings.Misc.JumpPowerValue or 50
        end
    end
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
    elseif tabName == "ESP" then
        createToggle(scrollFrame, "ESP Enabled", settings.ESP.Enabled, function(value)
            settings.ESP.Enabled = value
            updateESP()
        end)
        
        createToggle(scrollFrame, "Name ESP", settings.ESP.Names, function(value)
            settings.ESP.Names = value
            updateESP()
        end)
        
        createToggle(scrollFrame, "Box ESP", settings.ESP.Boxes, function(value)
            settings.ESP.Boxes = value
            updateESP()
        end)
        
        createToggle(scrollFrame, "Tracer ESP", settings.ESP.Tracers, function(value)
            settings.ESP.Tracers = value
            updateESP()
        end)
        
        createColorButton(scrollFrame, "ESP Color", settings.ESP.Color, function(value)
            settings.ESP.Color = value
            updateESP()
        end)
    elseif tabName == "Misc" then
        createToggle(scrollFrame, "NoClip", settings.Misc.NoClip, function(value)
            settings.Misc.NoClip = value
            updateNoClip()
        end)
        
        createToggle(scrollFrame, "Fly", settings.Misc.Fly, function(value)
            settings.Misc.Fly = value
            updateFly()
        end)
        
        createToggle(scrollFrame, "Speed", settings.Misc.Speed, function(value)
            settings.Misc.Speed = value
            updateSpeed()
        end)
        
        createValueChanger(scrollFrame, "Speed Value", {16, 20, 25, 30, 40, 50, 75, 100}, settings.Misc.SpeedValue, function(value)
            settings.Misc.SpeedValue = value
            updateSpeed()
        end)
        
        createToggle(scrollFrame, "Jump Power", settings.Misc.JumpPower, function(value)
            settings.Misc.JumpPower = value
            updateJumpPower()
        end)
        
        createValueChanger(scrollFrame, "Jump Power Value", {50, 75, 100, 125, 150, 175, 200}, settings.Misc.JumpPowerValue, function(value)
            settings.Misc.JumpPowerValue = value
            updateJumpPower()
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
    updateFly()
    updateSpeed()
    updateJumpPower()
end)

RunService:BindToRenderStep("MenuUpdate", Enum.RenderPriority.Input.Value + 1, function()
    updateParticles()
    updateTracers()
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
    screenGui:Destroy()
end)