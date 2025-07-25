local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 400, 500
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Misc"}
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local minimizedSize = UDim2.new(0, 90, 0, 35)
local minimizedPosition = UDim2.new(0.5, -45, 0, 10)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)

local hitboxSettings = {
    Enabled = false,
    Size = 1,
    Color = Color3.fromRGB(255, 0, 0),
    Transparency = 0.5
}

local espSettings = {
    Enabled = false,
    Names = false,
    Boxes = false,
    Tracers = false,
    Color = Color3.fromRGB(0, 255, 0),
    TeamCheck = false
}

local miscSettings = {
    NoClip = false,
    Fly = false,
    Speed = false,
    SpeedValue = 16,
    JumpPower = false,
    JumpPowerValue = 50
}

local hitboxParts = {}

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

local function createToggle(parent, name, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 25)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
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

local function createSlider(parent, name, minValue, maxValue, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 40)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 15)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. defaultValue
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.TextTransparency = 0.4
    label.TextSize = 12
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 5)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    track.BorderSizePixel = 0
    track.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local thumb = Instance.new("TextButton")
    thumb.Size = UDim2.new(0, 15, 0, 15)
    thumb.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -5, 0, -5)
    thumb.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    thumb.Text = ""
    thumb.Parent = sliderFrame
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    local dragging = false
    
    local function updateValue(input)
        local posX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        posX = math.clamp(posX, 0, 1)
        local value = math.floor(minValue + (maxValue - minValue) * posX)
        fill.Size = UDim2.new(posX, 0, 1, 0)
        thumb.Position = UDim2.new(posX, -7, 0, -5)
        label.Text = name .. ": " .. value
        callback(value)
    end
    
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input)
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateValue(input)
        end
    end)
    
    return sliderFrame
end

local function createColorPicker(parent, name, defaultColor, callback)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, -10, 0, 30)
    colorFrame.BackgroundTransparency = 1
    colorFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.TextTransparency = 0.4
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorFrame
    
    local preview = Instance.new("TextButton")
    preview.Size = UDim2.new(0.25, 0, 0.8, 0)
    preview.Position = UDim2.new(0.75, 0, 0.1, 0)
    preview.BackgroundColor3 = defaultColor
    preview.Text = ""
    preview.Parent = colorFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = preview
    
    preview.MouseButton1Click:Connect(function()
        local colorPicker = Instance.new("Frame")
        colorPicker.Size = UDim2.new(0, 200, 0, 200)
        colorPicker.Position = UDim2.new(0.5, -100, 0.5, -100)
        colorPicker.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        colorPicker.BorderSizePixel = 0
        colorPicker.Parent = screenGui
        
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0.1, 0)
        uiCorner.Parent = colorPicker
        
        local uiStroke = Instance.new("UIStroke")
        uiStroke.Color = Color3.fromRGB(100, 100, 100)
        uiStroke.Thickness = 1
        uiStroke.Parent = colorPicker
        
        local saturation = Instance.new("ImageLabel")
        saturation.Size = UDim2.new(0, 150, 0, 150)
        saturation.Position = UDim2.new(0, 10, 0, 10)
        saturation.Image = "rbxassetid://4155801252"
        saturation.BackgroundColor3 = defaultColor
        saturation.Parent = colorPicker
        
        local brightness = Instance.new("Frame")
        brightness.Size = UDim2.new(1, 0, 1, 0)
        brightness.BackgroundColor3 = Color3.new(0, 0, 0)
        brightness.BackgroundTransparency = 0
        brightness.Parent = saturation
        
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 90
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        gradient.Parent = brightness
        
        local selector = Instance.new("Frame")
        selector.Size = UDim2.new(0, 10, 0, 10)
        selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        selector.BorderSizePixel = 2
        selector.BorderColor3 = Color3.fromRGB(0, 0, 0)
        selector.Parent = saturation
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = selector
        
        local hueSlider = Instance.new("Frame")
        hueSlider.Size = UDim2.new(0, 20, 0, 150)
        hueSlider.Position = UDim2.new(0, 170, 0, 10)
        hueSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        hueSlider.Parent = colorPicker
        
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
        gradient.Rotation = 90
        gradient.Parent = hueSlider
        
        local hueSelector = Instance.new("Frame")
        hueSelector.Size = UDim2.new(1, 0, 0, 5)
        hueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueSelector.BorderSizePixel = 2
        hueSelector.BorderColor3 = Color3.fromRGB(0, 0, 0)
        hueSelector.Parent = hueSlider
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 3)
        corner.Parent = hueSelector
        
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 180, 0, 25)
        closeButton.Position = UDim2.new(0, 10, 0, 170)
        closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        closeButton.Text = "Apply"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextSize = 14
        closeButton.Font = Enum.Font.SourceSansBold
        closeButton.Parent = colorPicker
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.1, 0)
        corner.Parent = closeButton
        
        local function updateColor()
            local huePos = 1 - (hueSelector.Position.Y.Scale + hueSelector.Size.Y.Scale / 2)
            local hue = math.clamp(huePos, 0, 1)
            
            local satPos = selector.Position.X.Scale / saturation.AbsoluteSize.X
            local brightPos = 1 - (selector.Position.Y.Scale / saturation.AbsoluteSize.Y)
            
            local saturationColor = Color3.fromHSV(hue, satPos, brightPos)
            preview.BackgroundColor3 = saturationColor
            saturation.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            callback(saturationColor)
        end
        
        local function setHueSelectorPosition(y)
            hueSelector.Position = UDim2.new(0, 0, math.clamp(y, 0, 1 - hueSelector.Size.Y.Scale), 0)
            updateColor()
        end
        
        local function setSelectorPosition(x, y)
            selector.Position = UDim2.new(
                math.clamp(x / saturation.AbsoluteSize.X - selector.Size.X.Scale / 2, 0, 1 - selector.Size.X.Scale),
                -selector.Size.X.Offset / 2,
                math.clamp(y / saturation.AbsoluteSize.Y - selector.Size.Y.Scale / 2, 0, 1 - selector.Size.Y.Scale),
                -selector.Size.Y.Offset / 2
            )
            updateColor()
        end
        
        hueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local y = (input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y
                setHueSelectorPosition(y)
                
                local connection
                connection = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        connection:Disconnect()
                    else
                        local y = (input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y
                        setHueSelectorPosition(y)
                    end
                end)
            end
        end)
        
        saturation.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                setSelectorPosition(input.Position.X - saturation.AbsolutePosition.X, input.Position.Y - saturation.AbsolutePosition.Y)
                
                local connection
                connection = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        connection:Disconnect()
                    else
                        setSelectorPosition(input.Position.X - saturation.AbsolutePosition.X, input.Position.Y - saturation.AbsolutePosition.Y)
                    end
                end)
            end
        end)
        
        closeButton.MouseButton1Click:Connect(function()
            colorPicker:Destroy()
        end)
    end)
    
    return preview
end

local function updateHitboxes()
    for _, part in pairs(hitboxParts) do
        if part:IsA("BasePart") then
            part:Destroy()
        end
    end
    hitboxParts = {}
    
    if not hitboxSettings.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local hitbox = Instance.new("Part")
                hitbox.Size = Vector3.new(hitboxSettings.Size, hitboxSettings.Size, hitboxSettings.Size)
                hitbox.CFrame = humanoidRootPart.CFrame
                hitbox.Anchored = true
                hitbox.CanCollide = false
                hitbox.Transparency = hitboxSettings.Transparency
                hitbox.Color = hitboxSettings.Color
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
            
            if not espSettings.Enabled then continue end
            
            if player.Character then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local head = player.Character:FindFirstChild("Head")
                
                if humanoidRootPart and humanoid and head then
                    local newFolder = Instance.new("Folder")
                    newFolder.Name = "ESP_Folder"
                    newFolder.Parent = player
                    
                    if espSettings.Names then
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
                        nameLabel.TextColor3 = espSettings.Color
                        nameLabel.TextSize = 14
                        nameLabel.Font = Enum.Font.SourceSansBold
                        nameLabel.TextStrokeTransparency = 0.5
                        nameLabel.Parent = nameTag
                    end
                    
                    if espSettings.Boxes then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Name = "Box"
                        box.Size = Vector3.new(4, 6, 2)
                        box.AlwaysOnTop = true
                        box.ZIndex = 10
                        box.Transparency = 0.5
                        box.Color3 = espSettings.Color
                        box.Adornee = humanoidRootPart
                        box.Parent = newFolder
                    end
                    
                    if espSettings.Tracers then
                        local tracer = Instance.new("Frame")
                        tracer.Name = "Tracer"
                        tracer.Size = UDim2.new(0, 1, 0, 1)
                        tracer.BackgroundColor3 = espSettings.Color
                        tracer.BorderSizePixel = 0
                        tracer.Parent = screenGui
                        
                        RunService.RenderStepped:Connect(function()
                            if tracer.Parent then
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
                        end)
                    end
                end
            end
        end
    end
end

local function updateNoClip()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not miscSettings.NoClip
            end
        end
    end
end

local function updateFly()
    if not miscSettings.Fly then return end
    
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
                if not miscSettings.Fly then
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
            humanoid.WalkSpeed = miscSettings.Speed and miscSettings.SpeedValue or 16
        end
    end
end

local function updateJumpPower()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = miscSettings.JumpPower and miscSettings.JumpPowerValue or 50
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
        createToggle(scrollFrame, "Hitbox Enabled", hitboxSettings.Enabled, function(value)
            hitboxSettings.Enabled = value
            updateHitboxes()
        end)
        
        createSlider(scrollFrame, "Hitbox Size", 1, 8, hitboxSettings.Size, function(value)
            hitboxSettings.Size = value
            updateHitboxes()
        end)
        
        createColorPicker(scrollFrame, "Hitbox Color", hitboxSettings.Color, function(value)
            hitboxSettings.Color = value
            updateHitboxes()
        end)
        
        createSlider(scrollFrame, "Hitbox Transparency", 0, 1, hitboxSettings.Transparency, function(value)
            hitboxSettings.Transparency = value
            updateHitboxes()
        end)
    elseif tabName == "ESP" then
        createToggle(scrollFrame, "ESP Enabled", espSettings.Enabled, function(value)
            espSettings.Enabled = value
            updateESP()
        end)
        
        createToggle(scrollFrame, "Name ESP", espSettings.Names, function(value)
            espSettings.Names = value
            updateESP()
        end)
        
        createToggle(scrollFrame, "Box ESP", espSettings.Boxes, function(value)
            espSettings.Boxes = value
            updateESP()
        end)
        
        createToggle(scrollFrame, "Tracer ESP", espSettings.Tracers, function(value)
            espSettings.Tracers = value
            updateESP()
        end)
        
        createColorPicker(scrollFrame, "ESP Color", espSettings.Color, function(value)
            espSettings.Color = value
            updateESP()
        end)
        
        createToggle(scrollFrame, "Team Check", espSettings.TeamCheck, function(value)
            espSettings.TeamCheck = value
            updateESP()
        end)
    elseif tabName == "Misc" then
        createToggle(scrollFrame, "NoClip", miscSettings.NoClip, function(value)
            miscSettings.NoClip = value
            updateNoClip()
        end)
        
        createToggle(scrollFrame, "Fly", miscSettings.Fly, function(value)
            miscSettings.Fly = value
            updateFly()
        end)
        
        createToggle(scrollFrame, "Speed", miscSettings.Speed, function(value)
            miscSettings.Speed = value
            updateSpeed()
        end)
        
        createSlider(scrollFrame, "Speed Value", 16, 100, miscSettings.SpeedValue, function(value)
            miscSettings.SpeedValue = value
            updateSpeed()
        end)
        
        createToggle(scrollFrame, "Jump Power", miscSettings.JumpPower, function(value)
            miscSettings.JumpPower = value
            updateJumpPower()
        end)
        
        createSlider(scrollFrame, "Jump Power Value", 50, 200, miscSettings.JumpPowerValue, function(value)
            miscSettings.JumpPowerValue = value
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