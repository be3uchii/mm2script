local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local menuGui = Instance.new("ScreenGui")
menuGui.Name = "CrazyMenuGui"
menuGui.Enabled = true
menuGui.IgnoreGuiInset = true
menuGui.ResetOnSpawn = false
menuGui.Parent = playerGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "☰"
toggleButton.Font = Enum.Font.Arcade
toggleButton.TextSize = 24
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
toggleButton.BackgroundTransparency = 0.2
toggleButton.Parent = menuGui
local cornerToggle = Instance.new("UICorner")
cornerToggle.CornerRadius = UDim.new(0, 8)
cornerToggle.Parent = toggleButton

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0.4, 0, 0.7, 0)
menuFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
menuFrame.BackgroundTransparency = 0.3
menuFrame.BorderSizePixel = 0
menuFrame.Visible = true
menuFrame.Parent = menuGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = menuFrame

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
})
uiGradient.Rotation = 45
uiGradient.Parent = menuFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Thickness = 2
uiStroke.Parent = menuFrame

local menuTitle = Instance.new("TextLabel")
menuTitle.Size = UDim2.new(1, -40, 0, 50)
menuTitle.Text = "Ultimate Crazy Menu"
menuTitle.Font = Enum.Font.Arcade
menuTitle.TextSize = 24
menuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuTitle.BackgroundTransparency = 1
menuTitle.TextStrokeTransparency = 0.8
menuTitle.TextStrokeColor3 = Color3.fromRGB(0, 255, 255)
menuTitle.Parent = menuFrame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -35, 0, 5)
minimizeButton.Text = "-"
minimizeButton.Font = Enum.Font.Arcade
minimizeButton.TextSize = 20
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
minimizeButton.Parent = menuFrame
local cornerMin = Instance.new("UICorner")
cornerMin.CornerRadius = UDim.new(0, 8)
cornerMin.Parent = minimizeButton

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -60)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 7000)
scrollFrame.Parent = menuFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.Parent = scrollFrame

local isDragging = false
local dragStart = nil
local startPos = nil

menuTitle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = menuFrame.Position
    end
end)

menuTitle.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

menuTitle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        minimizeButton.Text = "+"
        scrollFrame.Visible = false
        menuFrame.Size = UDim2.new(0.4, 0, 0, 50)
    else
        minimizeButton.Text = "-"
        scrollFrame.Visible = true
        menuFrame.Size = UDim2.new(0.4, 0, 0.7, 0)
    end
end)

local lastToggle = 0
local toggleCooldown = 0.5
toggleButton.MouseButton1Click:Connect(function()
    if tick() - lastToggle > toggleCooldown then
        menuFrame.Visible = not menuFrame.Visible
        lastToggle = tick()
    end
end)

local function createButton(name, text, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Text = text
    button.Font = Enum.Font.Arcade
    button.TextSize = 18
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    button.BackgroundTransparency = 0.2
    button.Parent = scrollFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    local hoverGradient = Instance.new("UIGradient")
    hoverGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
    })
    hoverGradient.Parent = button
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
    end)
    button.MouseButton1Click:Connect(callback)
end

local function addCrown()
    local character = player.Character
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            local crown = Instance.new("Part")
            crown.Size = Vector3.new(2, 0.5, 2)
            crown.BrickColor = BrickColor.new("Gold")
            crown.Parent = character
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = head
            weld.Part1 = crown
            weld.Parent = crown
            crown.Position = head.Position + Vector3.new(0, 1.5, 0)
            local sparkles = Instance.new("Sparkles")
            sparkles.SparkleColor = Color3.fromRGB(255, 215, 0)
            sparkles.Parent = crown
            local pointLight = Instance.new("PointLight")
            pointLight.Color = Color3.fromRGB(255, 215, 0)
            pointLight.Range = 10
            pointLight.Brightness = 2
            pointLight.Parent = crown
            Debris:AddItem(crown, 5)
        end
    end
end

local function playAnimation(animId)
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            local anim = Instance.new("Animation")
            anim.AnimationId = animId
            local track = humanoid:LoadAnimation(anim)
            track:Play()
            Debris:AddItem(anim, 5)
        end
    end
end

local function playDance() playAnimation("rbxassetid://507771019") end
local function playJump() playAnimation("rbxassetid://507765000") end
local function playHandAnim() playAnimation("rbxassetid://148840371") end
local function playWaveAnim() playAnimation("rbxassetid://507770453") end
local function playLaughAnim() playAnimation("rbxassetid://507770818") end
local function playSpinAnim() playAnimation("rbxassetid://507771955") end
local function playClapAnim() playAnimation("rbxassetid://507770239") end
local function playSaluteAnim() playAnimation("rbxassetid://507770364") end
local function playPointAnim() playAnimation("rbxassetid://507770072") end
local function playCheerAnim() playAnimation("rbxassetid://507770677") end
local function playDance2() playAnimation("rbxassetid://507771533") end
local function playDance3() playAnimation("rbxassetid://507771019") end
local function playBowAnim() playAnimation("rbxassetid://507770933") end
local function playFlossAnim() playAnimation("rbxassetid://591745643") end
local function playDabAnim() playAnimation("rbxassetid://33796059") end
local function playMoonwalk() playAnimation("rbxassetid://744687205") end
local function playBreakdance() playAnimation("rbxassetid://507771019") end
local function playZombieWalk() playAnimation("rbxassetid://507771019") end
local function playSillyDance() playAnimation("rbxassetid://507771019") end
local function playRobotDance() playAnimation("rbxassetid://507771019") end
local function playTwistAnim() playAnimation("rbxassetid://507771019") end
local function playWiggleAnim() playAnimation("rbxassetid://507771019") end
local function playGangnamStyle() playAnimation("rbxassetid://507771019") end
local function playTposeAnim() playAnimation("rbxassetid://507771019") end

local function addFireEffect()
    local character = player.Character
    if character then
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if torso then
            local fire = Instance.new("Fire")
            fire.Size = 5
            fire.Heat = 10
            fire.Color = Color3.fromRGB(255, 100, 0)
            fire.SecondaryColor = Color3.fromRGB(255, 255, 0)
            fire.Parent = torso
            Debris:AddItem(fire, 5)
        end
    end
end

local function addSparkles()
    local character = player.Character
    if character then
        local sparkles = Instance.new("Sparkles")
        sparkles.SparkleColor = Color3.fromRGB(0, 255, 255)
        sparkles.Parent = character:FindFirstChild("HumanoidRootPart")
        Debris:AddItem(sparkles, 5)
    end
end

local function addSmoke()
    local character = player.Character
    if character then
        local smoke = Instance.new("Smoke")
        smoke.Color = Color3.fromRGB(200, 200, 200)
        smoke.Opacity = 0.5
        smoke.Size = 1
        smoke.Parent = character:FindFirstChild("HumanoidRootPart")
        Debris:AddItem(smoke, 5)
    end
end

local function changeColor()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.BrickColor = BrickColor.Random()
            end
        end
    end
end

local function teleportToPlayer()
    local character = player.Character
    if character then
        local players = game.Players:GetPlayers()
        local otherPlayers = {}
        for _, p in pairs(players) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(otherPlayers, p)
            end
        end
        if #otherPlayers > 0 then
            local target = otherPlayers[math.random(1, #otherPlayers)]
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 3)
            end
        end
    end
end

local function stickToPlayer()
    local character = player.Character
    if character then
        local players = game.Players:GetPlayers()
        local otherPlayers = {}
        for _, p in pairs(players) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(otherPlayers, p)
            end
        end
        if #otherPlayers > 0 then
            local target = otherPlayers[math.random(1, #otherPlayers)]
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        rootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 2)
                    else
                        connection:Disconnect()
                    end
                end)
                wait(5)
                connection:Disconnect()
            end
        end
    end
end

local function nudgePlayer()
    local character = player.Character
    if character then
        local players = game.Players:GetPlayers()
        local otherPlayers = {}
        for _, p in pairs(players) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(otherPlayers, p)
            end
        end
        if #otherPlayers > 0 then
            local target = otherPlayers[math.random(1, #otherPlayers)]
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(5000, 0, 5000)
                bodyVelocity.Velocity = (targetRoot.Position - character.HumanoidRootPart.Position).Unit * 10
                bodyVelocity.Parent = targetRoot
                Debris:AddItem(bodyVelocity, 0.5)
            end
        end
    end
end

local function orbitPlayer()
    local character = player.Character
    if character then
        local players = game.Players:GetPlayers()
        local otherPlayers = {}
        for _, p in pairs(players) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(otherPlayers, p)
            end
        end
        if #otherPlayers > 0 then
            local target = otherPlayers[math.random(1, #otherPlayers)]
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local angle = tick() * 2
                        rootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(math.cos(angle) * 5, 0, math.sin(angle) * 5)
                    else
                        connection:Disconnect()
                    end
                end)
                wait(5)
                connection:Disconnect()
            end
        end
    end
end

local function mirrorMovement()
    local character = player.Character
    if character then
        local players = game.Players:GetPlayers()
        local otherPlayers = {}
        for _, p in pairs(players) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(otherPlayers, p)
            end
        end
        if #otherPlayers > 0 then
            local target = otherPlayers[math.random(1, #otherPlayers)]
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        rootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                    else
                        connection:Disconnect()
                    end
                end)
                wait(5)
                connection:Disconnect()
            end
        end
    end
end

local function fakeDeath()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507771019"
            local track = humanoid:LoadAnimation(anim)
            track:Play()
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    local tween = TweenService:Create(part, TweenInfo.new(1), {Transparency = 0.8})
                    tween:Play()
                end
            end
            wait(3)
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    local tween = TweenService:Create(part, TweenInfo.new(1), {Transparency = 0})
                    tween:Play()
                end
            end
            Debris:AddItem(anim, 5)
        end
    end
end

local function addTrail()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local trail = Instance.new("Trail")
            trail.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
            trail.Lifetime = 1
            trail.Attachment0 = Instance.new("Attachment", rootPart)
            trail.Attachment1 = Instance.new("Attachment", rootPart)
            trail.Attachment1.Position = Vector3.new(0, -1, 0)
            trail.Parent = rootPart
            Debris:AddItem(trail, 5)
        end
    end
end

local function glowEffect()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                highlight.Parent = part
                Debris:AddItem(highlight, 5)
            end
        end
    end
end

local function sizeChange()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.BodyDepthScale.Value = 2
            humanoid.BodyHeightScale.Value = 2
            humanoid.BodyWidthScale.Value = 2
            wait(5)
            humanoid.BodyDepthScale.Value = 1
            humanoid.BodyHeightScale.Value = 1
            humanoid.BodyWidthScale.Value = 1
        end
    end
end

local function rainbowEffect()
    local character = player.Character
    if character then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.new(Color3.fromHSV(tick() % 360 / 360, 1, 1))
                end
            end
        end)
        wait(5)
        connection:Disconnect()
    end
end

local function addBeam()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local beam = Instance.new("Beam")
            beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 255))
            beam.Width0 = 0.5
            beam.Width1 = 0.5
            beam.Attachment0 = Instance.new("Attachment", rootPart)
            beam.Attachment1 = Instance.new("Attachment", rootPart)
            beam.Attachment1.Position = Vector3.new(0, 5, 0)
            beam.Parent = rootPart
            Debris:AddItem(beam, 5)
        end
    end
end

local function addAura()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local aura = Instance.new("ParticleEmitter")
            aura.Texture = "rbxassetid://243098098"
            aura.Color = ColorSequence.new(Color3.fromRGB(255, 0, 255))
            aura.Size = NumberSequence.new(2)
            aura.Lifetime = NumberRange.new(1, 2)
            aura.Rate = 20
            aura.Speed = NumberRange.new(5)
            aura.Parent = rootPart
            Debris:AddItem(aura, 5)
        end
    end
end

local function addExplosionEffect()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local explosion = Instance.new("Explosion")
            explosion.BlastRadius = 5
            explosion.BlastPressure = 0
            explosion.Position = rootPart.Position
            explosion.Parent = workspace
            Debris:AddItem(explosion, 1)
        end
    end
end

local function changeTransparency()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                local tween = TweenService:Create(part, TweenInfo.new(1), {Transparency = 0.5})
                tween:Play()
                wait(5)
                local tweenBack = TweenService:Create(part, TweenInfo.new(1), {Transparency = 0})
                tweenBack:Play()
            end
        end
    end
end

local function addSpin()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
            bodyAngularVelocity.AngularVelocity = Vector3.new(0, 10, 0)
            bodyAngularVelocity.MaxTorque = Vector3.new(0, 10000, 0)
            bodyAngularVelocity.Parent = rootPart
            Debris:AddItem(bodyAngularVelocity, 5)
        end
    end
end

local function addFloat()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(0, 10000, 0)
            bodyVelocity.Velocity = Vector3.new(0, 10, 0)
            bodyVelocity.Parent = rootPart
            Debris:AddItem(bodyVelocity, 5)
        end
    end
end

local function addNeon()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Neon
            end
        end
        wait(5)
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.SmoothPlastic
            end
        end
    end
end

local function addForceField()
    local character = player.Character
    if character then
        local forceField = Instance.new("ForceField")
        forceField.Parent = character
        Debris:AddItem(forceField, 5)
    end
end

local function addGlowParticles()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local particles = Instance.new("ParticleEmitter")
            particles.Texture = "rbxassetid://243098098"
            particles.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
            particles.Size = NumberSequence.new(1)
            particles.Lifetime = NumberRange.new(0.5, 1)
            particles.Rate = 50
            particles.Speed = NumberRange.new(3)
            particles.Parent = rootPart
            Debris:AddItem(particles, 5)
        end
    end
end

local function addStarEffect()
    local character = player.Character
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            local particles = Instance.new("ParticleEmitter")
            particles.Texture = "rbxassetid://243098098"
            particles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
            particles.Size = NumberSequence.new(0.5)
            particles.Lifetime = NumberRange.new(1, 2)
            particles.Rate = 30
            particles.Speed = NumberRange.new(5)
            particles.SpreadAngle = Vector2.new(360, 360)
            particles.Parent = head
            Debris:AddItem(particles, 5)
        end
    end
end

local function addLightning()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local beam = Instance.new("Beam")
            beam.Texture = "rbxassetid://243098098"
            beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
            beam.Width0 = 0.3
            beam.Width1 = 0.3
            beam.Attachment0 = Instance.new("Attachment", rootPart)
            beam.Attachment1 = Instance.new("Attachment", rootPart)
            beam.Attachment1.Position = Vector3.new(0, 10, 0)
            beam.Parent = rootPart
            Debris:AddItem(beam, 5)
        end
    end
end

local function addHologram()
    local character = player.Character
    if character then
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local hologram = Instance.new("Part")
            hologram.Size = Vector3.new(2, 2, 2)
            hologram.Transparency = 0.5
            hologram.BrickColor = BrickColor.new("Cyan")
            hologram.Material = Enum.Material.Neon
            hologram.Anchored = true
            hologram.Position = rootPart.Position + Vector3.new(0, 5, 0)
            hologram.Parent = workspace
            Debris:AddItem(hologram, 5)
        end
    end
end

local function addPulse()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local pulse = Instance.new("Part")
            pulse.Size = Vector3.new(5, 0.2, 5)
            pulse.Transparency = 0.5
            pulse.BrickColor = BrickColor.new("Magenta")
            pulse.Material = Enum.Material.Neon
            pulse.Anchored = true
            pulse.Position = rootPart.Position
            pulse.Parent = workspace
            local tween = TweenService:Create(pulse, TweenInfo.new(2), {Size = Vector3.new(10, 0.2, 10), Transparency = 1})
            tween:Play()
            Debris:AddItem(pulse, 2)
        end
    end
end

local function addRainbowTrail()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local trail = Instance.new("Trail")
            trail.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            trail.Lifetime = 1
            trail.Attachment0 = Instance.new("Attachment", rootPart)
            trail.Attachment1 = Instance.new("Attachment", rootPart)
            trail.Attachment1.Position = Vector3.new(0, -1, 0)
            trail.Parent = rootPart
            Debris:AddItem(trail, 5)
        end
    end
end

local function addSpeedLines()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local particles = Instance.new("ParticleEmitter")
            particles.Texture = "rbxassetid://243098098"
            particles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
            particles.Size = NumberSequence.new(0.5)
            particles.Lifetime = NumberRange.new(0.5, 1)
            particles.Rate = 100
            particles.Speed = NumberRange.new(20)
            particles.SpreadAngle = Vector2.new(10, 10)
            particles.Parent = rootPart
            Debris:AddItem(particles, 5)
        end
    end
end

local function addGlitter()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local particles = Instance.new("ParticleEmitter")
            particles.Texture = "rbxassetid://243098098"
            particles.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
            particles.Size = NumberSequence.new(0.3)
            particles.Lifetime = NumberRange.new(1, 2)
            particles.Rate = 50
            particles.Speed = NumberRange.new(2)
            particles.SpreadAngle = Vector2.new(360, 360)
            particles.Parent = rootPart
            Debris:AddItem(particles, 5)
        end
    end
end

local function addVortex()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local particles = Instance.new("ParticleEmitter")
            particles.Texture = "rbxassetid://243098098"
            particles.Color = ColorSequence.new(Color3.fromRGB(0, 0, 255))
            particles.Size = NumberSequence.new(1)
            particles.Lifetime = NumberRange.new(1, 2)
            particles.Rate = 30
            particles.Speed = NumberRange.new(10)
            particles.Rotation = NumberRange.new(0, 360)
            particles.RotSpeed = NumberRange.new(100)
            particles.Parent = rootPart
            Debris:AddItem(particles, 5)
        end
    end
end

local function addBubbleEffect()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local particles = Instance.new("ParticleEmitter")
            particles.Texture = "rbxassetid://243098098"
            particles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
            particles.Size = NumberSequence.new(0.5)
            particles.Lifetime = NumberRange.new(2, 3)
            particles.Rate = 20
            particles.Speed = NumberRange.new(5)
            particles.SpreadAngle = Vector2.new(360, 360)
            particles.Parent = rootPart
            Debris:AddItem(particles, 5)
        end
    end
end

local function addGlowRing()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local ring = Instance.new("Part")
            ring.Size = Vector3.new(3, 0.2, 3)
            ring.Transparency = 0.5
            ring.BrickColor = BrickColor.new("Lime green")
            ring.Material = Enum.Material.Neon
            ring.Anchored = true
            ring.Position = rootPart.Position
            ring.Parent = workspace
            local tween = TweenService:Create(ring, TweenInfo.new(2), {Size = Vector3.new(6, 0.2, 6), Transparency = 1})
            tween:Play()
            Debris:AddItem(ring, 2)
        end
    end
end

local function addFlameTrail()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local trail = Instance.new("Trail")
            trail.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
            trail.Lifetime = 0.5
            trail.Attachment0 = Instance.new("Attachment", rootPart)
            trail.Attachment1 = Instance.new("Attachment", rootPart)
            trail.Attachment1.Position = Vector3.new(0, -1, 0)
            trail.Parent = rootPart
            Debris:AddItem(trail, 5)
        end
    end
end

local function addDiscoEffect()
    local character = player.Character
    if character then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.new(Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
                end
            end
        end)
        wait(5)
        connection:Disconnect()
    end
end

local function addGhostEffect()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                local tween = TweenService:Create(part, TweenInfo.new(1), {Transparency = 0.7})
                tween:Play()
            end
        end
        local smoke = Instance.new("Smoke")
        smoke.Color = Color3.fromRGB(200, 200, 200)
        smoke.Opacity = 0.3
        smoke.Size = 0.5
        smoke.Parent = character:FindFirstChild("HumanoidRootPart")
        wait(5)
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                local tween = TweenService:Create(part, TweenInfo.new(1), {Transparency = 0})
                tween:Play()
            end
        end
        Debris:AddItem(smoke, 5)
    end
end

local function addCloneShadow()
    local character = player.Character
    if character then
        local clone = character:Clone()
        clone.Parent = workspace
        for _, part in pairs(clone:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.8
                part.Anchored = true
            end
        end
        Debris:AddItem(clone, 5)
    end
end

local function addSpeedBoost()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 50
            wait(5)
            humanoid.WalkSpeed = 16
        end
    end
end

local function addJumpBoost()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = 100
            wait(5)
            humanoid.JumpPower = 50
        end
    end
end

local function addGravityShift()
    local character = player.Character
    if character then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(0, 10000, 0)
        bodyVelocity.Velocity = Vector3.new(0, -10, 0)
        bodyVelocity.Parent = character:FindFirstChild("HumanoidRootPart")
        Debris:AddItem(bodyVelocity, 5)
    end
end

local function addColorPulse()
    local character = player.Character
    if character then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.new(Color3.fromHSV(math.sin(tick()) * 0.5 + 0.5, 1, 1))
                end
            end
        end)
        wait(5)
        connection:Disconnect()
    end
end

local function addOrbitingStars()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for i = 1, 5 do
                local star = Instance.new("Part")
                star.Size = Vector3.new(0.5, 0.5, 0.5)
                star.BrickColor = BrickColor.new("Yellow")
                star.Material = Enum.Material.Neon
                star.Anchored = true
                star.Parent = workspace
                local angle = (i - 1) * (2 * math.pi / 5)
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    star.Position = rootPart.Position + Vector3.new(math.cos(tick() + angle) * 3, 1, math.sin(tick() + angle) * 3)
                end)
                Debris:AddItem(star, 5)
                wait(0)
            end
        end
    end
end

local function addShockwave()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local shockwave = Instance.new("Part")
            shockwave.Size = Vector3.new(1, 0.2, 1)
            shockwave.Transparency = 0.5
            shockwave.BrickColor = BrickColor.new("White")
            shockwave.Material = Enum.Material.Neon
            shockwave.Anchored = true
            shockwave.Position = rootPart.Position
            shockwave.Parent = workspace
            local tween = TweenService:Create(shockwave, TweenInfo.new(1.5), {Size = Vector3.new(10, 0.2, 10), Transparency = 1})
            tween:Play()
            Debris:AddItem(shockwave, 1.5)
        end
    end
end

local function addRainbowParticles()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local particles = Instance.new("ParticleEmitter")
            particles.Texture = "rbxassetid://243098098"
            particles.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            particles.Size = NumberSequence.new(0.5)
            particles.Lifetime = NumberRange.new(1, 2)
            particles.Rate = 50
            particles.Speed = NumberRange.new(5)
            particles.SpreadAngle = Vector2.new(360, 360)
            particles.Parent = rootPart
            Debris:AddItem(particles, 5)
        end
    end
end

local function addGlowingOrbs()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for i = 1, 3 do
                local orb = Instance.new("Part")
                orb.Size = Vector3.new(0.5, 0.5, 0.5)
                orb.BrickColor = BrickColor.new("Cyan")
                orb.Material = Enum.Material.Neon
                orb.Anchored = true
                orb.Parent = workspace
                local angle = (i - 1) * (2 * math.pi / 3)
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    orb.Position = rootPart.Position + Vector3.new(math.cos(tick() + angle) * 2, math.sin(tick()) * 2, math.sin(tick() + angle) * 2)
                end)
                Debris:AddItem(orb, 5)
                wait(0)
            end
        end
    end
end

createButton("CrownButton", "Add Crown", addCrown)
createButton("DanceButton", "Dance Animation", playDance)
createButton("JumpButton", "Jump Animation", playJump)
createButton("HandAnimButton", "Hand Animation", playHandAnim)
createButton("WaveButton", "Wave Animation", playWaveAnim)
createButton("LaughButton", "Laugh Animation", playLaughAnim)
createButton("SpinAnimButton", "Spin Animation", playSpinAnim)
createButton("ClapButton", "Clap Animation", playClapAnim)
createButton("SaluteButton", "Salute Animation", playSaluteAnim)
createButton("PointButton", "Point Animation", playPointAnim)
createButton("CheerButton", "Cheer Animation", playCheerAnim)
createButton("Dance2Button", "Dance 2 Animation", playDance2)
createButton("Dance3Button", "Dance 3 Animation", playDance3)
createButton("BowButton", "Bow Animation", playBowAnim)
createButton("FlossButton", "Floss Animation", playFlossAnim)
createButton("DabButton", "Dab Animation", playDabAnim)
createButton("MoonwalkButton", "Moonwalk Animation", playMoonwalk)
createButton("BreakdanceButton", "Breakdance Animation", playBreakdance)
createButton("ZombieWalkButton", "Zombie Walk Animation", playZombieWalk)
createButton("SillyDanceButton", "Silly Dance Animation", playSillyDance)
createButton("RobotDanceButton", "Robot Dance Animation", playRobotDance)
createButton("TwistButton", "Twist Animation", playTwistAnim)
createButton("WiggleButton", "Wiggle Animation", playWiggleAnim)
createButton("GangnamStyleButton", "Gangnam Style Animation", playGangnamStyle)
createButton("TposeButton", "T-Pose Animation", playTposeAnim)
createButton("FireButton", "Fire Effect", addFireEffect)
createButton("SparklesButton", "Sparkles", addSparkles)
createButton("SmokeButton", "Smoke Effect", addSmoke)
createButton("ColorButton", "Random Color", changeColor)
createButton("TeleportPlayerButton", "Teleport to Player", teleportToPlayer)
createButton("StickPlayerButton", "Stick to Player", stickToPlayer)
createButton("NudgePlayerButton", "Nudge Player", nudgePlayer)
createButton("OrbitPlayerButton", "Orbit Player", orbitPlayer)
createButton("MirrorMovementButton", "Mirror Movement", mirrorMovement)
createButton("FakeDeathButton", "Fake Death", fakeDeath)
createButton("TrailButton", "Trail Effect", addTrail)
createButton("GlowButton", "Glow Effect", glowEffect)
createButton("SizeButton", "Size Change", sizeChange)
createButton("RainbowButton", "Rainbow Effect", rainbowEffect)
createButton("BeamButton", "Beam Effect", addBeam)
createButton("AuraButton", "Aura Effect", addAura)
createButton("ExplosionButton", "Explosion Effect", addExplosionEffect)
createButton("TransparencyButton", "Transparency Effect", changeTransparency)
createButton("SpinButton", "Spin Effect", addSpin)
createButton("FloatButton", "Float Effect", addFloat)
createButton("NeonButton", "Neon Material", addNeon)
createButton("ForceFieldButton", "Force Field", addForceField)
createButton("GlowParticlesButton", "Glow Particles", addGlowParticles)
createButton("StarEffectButton", "Star Effect", addStarEffect)
createButton("LightningButton", "Lightning Effect", addLightning)
createButton("HologramButton", "Hologram Effect", addHologram)
createButton("PulseButton", "Pulse Effect", addPulse)
createButton("RainbowTrailButton", "Rainbow Trail", addRainbowTrail)
createButton("SpeedLinesButton", "Speed Lines", addSpeedLines)
createButton("GlitterButton", "Glitter Effect", addGlitter)
createButton("VortexButton", "Vortex Effect", addVortex)
createButton("BubbleButton", "Bubble Effect", addBubbleEffect)
createButton("GlowRingButton", "Glow Ring", addGlowRing)
createButton("FlameTrailButton", "Flame Trail", addFlameTrail)
createButton("DiscoButton", "Disco Effect", addDiscoEffect)
createButton("GhostButton", "Ghost Effect", addGhostEffect)
createButton("CloneShadowButton", "Clone Shadow", addCloneShadow)
createButton("SpeedBoostButton", "Speed Boost", addSpeedBoost)
createButton("JumpBoostButton", "Jump Boost", addJumpBoost)
createButton("GravityShiftButton", "Gravity Shift", addGravityShift)
createButton("ColorPulseButton", "Color Pulse", addColorPulse)
createButton("OrbitingStarsButton", "Orbiting Stars", addOrbitingStars)
createButton("ShockwaveButton", "Shockwave Effect", addShockwave)
createButton("RainbowParticlesButton", "Rainbow Particles", addRainbowParticles)
createButton("GlowingOrbsButton", "Glowing Orbs", addGlowingOrbs)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.M then
        if tick() - lastToggle > toggleCooldown then
            menuFrame.Visible = not menuFrame.Visible
            lastToggle = tick()
        end
    end
end)