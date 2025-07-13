local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local menuGui = Instance.new("ScreenGui")
menuGui.Name = "EpicMM2TrollGui"
menuGui.Enabled = true
menuGui.IgnoreGuiInset = true
menuGui.ResetOnSpawn = false
menuGui.Parent = playerGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "☰"
toggleButton.Font = Enum.Font.Arcade
toggleButton.TextSize = 28
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
toggleButton.BackgroundTransparency = 0.2
toggleButton.Parent = menuGui
local cornerToggle = Instance.new("UICorner")
cornerToggle.CornerRadius = UDim.new(0, 10)
cornerToggle.Parent = toggleButton

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0.5, 0, 0.8, 0)
menuFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
menuFrame.BackgroundTransparency = 0.3
menuFrame.BorderSizePixel = 0
menuFrame.Visible = true
menuFrame.Parent = menuGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
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
uiStroke.Thickness = 3
uiStroke.Parent = menuFrame

local menuTitle = Instance.new("TextLabel")
menuTitle.Size = UDim2.new(1, -40, 0, 50)
menuTitle.Text = "MM2 Ultimate Troll Menu"
menuTitle.Font = Enum.Font.Arcade
menuTitle.TextSize = 28
menuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuTitle.BackgroundTransparency = 1
menuTitle.TextStrokeTransparency = 0.7
menuTitle.TextStrokeColor3 = Color3.fromRGB(0, 255, 255)
menuTitle.Parent = menuFrame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 40, 0, 40)
minimizeButton.Position = UDim2.new(1, -45, 0, 5)
minimizeButton.Text = "-"
minimizeButton.Font = Enum.Font.Arcade
minimizeButton.TextSize = 24
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
minimizeButton.Parent = menuFrame
local cornerMin = Instance.new("UICorner")
cornerMin.CornerRadius = UDim.new(0, 10)
cornerMin.Parent = minimizeButton

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -60)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 10000)
scrollFrame.Parent = menuFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 8)
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
        menuFrame.Size = UDim2.new(0.5, 0, 0, 50)
    else
        minimizeButton.Text = "-"
        scrollFrame.Visible = true
        menuFrame.Size = UDim2.new(0.5, 0, 0.8, 0)
    end
end)

local lastToggle = 0
local toggleCooldown = 0.5
toggleButton.MouseButton1Click:Connect(function()
    if tick() - lastToggle > toggleCooldown then
        menuFrame.Visible = not menuFrame.Visible
        lastToggle = tick()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9119348206"
        sound.Parent = menuGui
        sound:Play()
        Debris:AddItem(sound, 2)
    end
end)

local function createButton(name, text, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -10, 0, 45)
    button.Text = text
    button.Font = Enum.Font.Arcade
    button.TextSize = 20
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    button.BackgroundTransparency = 0.2
    button.Parent = scrollFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    local hoverGradient = Instance.new("UIGradient")
    hoverGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
    })
    hoverGradient.Parent = button
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextSize = 22}):Play()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9119348206"
        sound.Parent = button
        sound:Play()
        Debris:AddItem(sound, 2)
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextSize = 20}):Play()
    end)
    button.MouseButton1Click:Connect(function()
        pcall(callback)
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9119348206"
        sound.Parent = button
        sound:Play()
        Debris:AddItem(sound, 2)
    end)
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
            Debris:AddItem(anim, 10)
        end
    end
end

local function playSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Parent = player.Character and player.Character:FindFirstChild("HumanoidRootPart") or workspace
    sound:Play()
    Debris:AddItem(sound, 5)
end

local function addCrown()
    local character = player.Character
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            local crown = Instance.new("Part")
            crown.Size = Vector3.new(2, 0.5, 2)
            crown.BrickColor = BrickColor.new("Gold")
            crown.Material = Enum.Material.Neon
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
            pointLight.Range = 12
            pointLight.Brightness = 3
            pointLight.Parent = crown
            Debris:AddItem(crown, 8)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function playDance() playAnimation("rbxassetid://507771019") end
local function playJump() playAnimation("rbxassetid://507765000") end
local function playWave() playAnimation("rbxassetid://507770453") end
local function playLaugh() playAnimation("rbxassetid://507770818") end
local function playSpin() playAnimation("rbxassetid://507771955") end
local function playClap() playAnimation("rbxassetid://507770239") end
local function playSalute() playAnimation("rbxassetid://507770364") end
local function playPoint() playAnimation("rbxassetid://507770072") end
local function playCheer() playAnimation("rbxassetid://507770677") end
local function playFloss() playAnimation("rbxassetid://591745643") end
local function playDab() playAnimation("rbxassetid://33796059") end
local function playMoonwalk() playAnimation("rbxassetid://744687205") end
local function playOrangeJustice() playAnimation("rbxassetid://3153742971") end
local function playHypeDance() playAnimation("rbxassetid://429703734") end
local function playKazotskyKick() playAnimation("rbxassetid://507771019") end
local function playBreakdance() playAnimation("rbxassetid://507771019") end
local function playZombieWalk() playAnimation("rbxassetid://507771019") end
local function playSillyDance() playAnimation("rbxassetid://507771019") end
local function playRobotDance() playAnimation("rbxassetid://507771019") end
local function playGangnamStyle() playAnimation("rbxassetid://507771019") end
local function playTpose() playAnimation("rbxassetid://507771019") end
local function playRumba() playAnimation("rbxassetid://507771019") end
local function playTwerk() playAnimation("rbxassetid://507771019") end
local function playMacarena() playAnimation("rbxassetid://507771019") end

local function addFireEffect()
    local character = player.Character
    if character then
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if torso then
            local fire = Instance.new("Fire")
            fire.Size = 6
            fire.Heat = 12
            fire.Color = Color3.fromRGB(255, 100, 0)
            fire.SecondaryColor = Color3.fromRGB(255, 255, 0)
            fire.Parent = torso
            Debris:AddItem(fire, 6)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addSparkles()
    local character = player.Character
    if character then
        local sparkles = Instance.new("Sparkles")
        sparkles.SparkleColor = Color3.fromRGB(0, 255, 255)
        sparkles.Parent = character:FindFirstChild("HumanoidRootPart")
        Debris:AddItem(sparkles, 6)
        playSound("rbxassetid://9119348206")
    end
end

local function addSmoke()
    local character = player.Character
    if character then
        local smoke = Instance.new("Smoke")
        smoke.Color = Color3.fromRGB(200, 200, 200)
        smoke.Opacity = 0.4
        smoke.Size = 1.2
        smoke.Parent = character:FindFirstChild("HumanoidRootPart")
        Debris:AddItem(smoke, 6)
        playSound("rbxassetid://9119348206")
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
        playSound("rbxassetid://9119348206")
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
                playSound("rbxassetid://9119348206")
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
                wait(6)
                connection:Disconnect()
                playSound("rbxassetid://9119348206")
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
                bodyVelocity.MaxForce = Vector3.new(6000, 0, 6000)
                bodyVelocity.Velocity = (targetRoot.Position - character.HumanoidRootPart.Position).Unit * 15
                bodyVelocity.Parent = targetRoot
                Debris:AddItem(bodyVelocity, 0.5)
                playSound("rbxassetid://9119348206")
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
                        local angle = tick() * 3
                        rootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(math.cos(angle) * 6, 0, math.sin(angle) * 6)
                    else
                        connection:Disconnect()
                    end
                end)
                wait(6)
                connection:Disconnect()
                playSound("rbxassetid://9119348206")
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
                        rootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
                    else
                        connection:Disconnect()
                    end
                end)
                wait(6)
                connection:Disconnect()
                playSound("rbxassetid://9119348206")
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
            playSound("rbxassetid://9119348206")
        end
    end
end

local function dropFakeGun()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local gun = Instance.new("Part")
            gun.Size = Vector3.new(1, 0.5, 2)
            gun.BrickColor = BrickColor.new("Really black")
            gun.Material = Enum.Material.Metal
            gun.Anchored = false
            gun.Position = rootPart.Position + Vector3.new(0, 0, 3)
            gun.Parent = workspace
            local clickDetector = Instance.new("ClickDetector")
            clickDetector.Parent = gun
            clickDetector.MouseClick:Connect(function()
                local explosion = Instance.new("Explosion")
                explosion.BlastRadius = 5
                explosion.BlastPressure = 0
                explosion.Position = gun.Position
                explosion.Parent = workspace
                Debris:AddItem(explosion, 1)
                gun:Destroy()
                playSound("rbxassetid://9119348206")
            end)
            Debris:AddItem(gun, 10)
        end
    end
end

local function fakeMurdererIndicator()
    local character = player.Character
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.Adornee = head
            billboard.AlwaysOnTop = true
            billboard.Parent = character
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = "MURDERER!"
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextSize = 20
            textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Parent = billboard
            Debris:AddItem(billboard, 8)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function spamChat()
    local messages = {"WHO'S THE MURDERER?!", "RUN FOR YOUR LIVES!", "I SAW YOU!", "SHERIFF WHERE U AT?", "LOL GET TROLLED!"}
    for i = 1, 5 do
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(messages[math.random(1, #messages)], "All")
        wait(0.5)
    end
    playSound("rbxassetid://9119348206")
end

local function fakeCoinDrop()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for i = 1, 10 do
                local coin = Instance.new("Part")
                coin.Size = Vector3.new(0.5, 0.5, 0.5)
                coin.BrickColor = BrickColor.new("Gold")
                coin.Material = Enum.Material.Neon
                coin.Anchored = false
                coin.Position = rootPart.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                coin.Parent = workspace
                local clickDetector = Instance.new("ClickDetector")
                clickDetector.Parent = coin
                clickDetector.MouseClick:Connect(function()
                    local sparkles = Instance.new("Sparkles")
                    sparkles.SparkleColor = Color3.fromRGB(255, 255, 0)
                    sparkles.Parent = coin
                    Debris:AddItem(sparkles, 1)
                    coin:Destroy()
                    playSound("rbxassetid://9119348206")
                end)
                Debris:AddItem(coin, 10)
            end
        end
    end
end

local function teleportSpam()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for i = 1, 5 do
                rootPart.CFrame = rootPart.CFrame + Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
                wait(0.2)
            end
            playSound("rbxassetid://9119348206")
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
            trail.Lifetime = 1.5
            trail.Attachment0 = Instance.new("Attachment", rootPart)
            trail.Attachment1 = Instance.new("Attachment", rootPart)
            trail.Attachment1.Position = Vector3.new(0, -1, 0)
            trail.Parent = rootPart
            Debris:AddItem(trail, 6)
            playSound("rbxassetid://9119348206")
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
                Debris:AddItem(highlight, 6)
            end
        end
        playSound("rbxassetid://9119348206")
    end
end

local function sizeChange()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.BodyDepthScale.Value = 2.5
            humanoid.BodyHeightScale.Value = 2.5
            humanoid.BodyWidthScale.Value = 2.5
            wait(6)
            humanoid.BodyDepthScale.Value = 1
            humanoid.BodyHeightScale.Value = 1
            humanoid.BodyWidthScale.Value = 1
            playSound("rbxassetid://9119348206")
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
        wait(6)
        connection:Disconnect()
        playSound("rbxassetid://9119348206")
    end
end

local function addBeam()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local beam = Instance.new("Beam")
            beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 255))
            beam.Width0 = 0.6
            beam.Width1 = 0.6
            beam.Attachment0 = Instance.new("Attachment", rootPart)
            beam.Attachment1 = Instance.new("Attachment", rootPart)
            beam.Attachment1.Position = Vector3.new(0, 6, 0)
            beam.Parent = rootPart
            Debris:AddItem(beam, 6)
            playSound("rbxassetid://9119348206")
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
            aura.Size = NumberSequence.new(2.5)
            aura.Lifetime = NumberRange.new(1, 2)
            aura.Rate = 25
            aura.Speed = NumberRange.new(6)
            aura.Parent = rootPart
            Debris:AddItem(aura, 6)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addExplosionEffect()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local explosion = Instance.new("Explosion")
            explosion.BlastRadius = 6
            explosion.BlastPressure = 0
            explosion.Position = rootPart.Position
            explosion.Parent = workspace
            Debris:AddItem(explosion, 1)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function changeTransparency()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                local tween = TweenService:Create(part, TweenInfo.new(1), {Transparency = 0.6})
                tween:Play()
                wait(6)
                local tweenBack = TweenService:Create(part, TweenInfo.new(1), {Transparency = 0})
                tweenBack:Play()
            end
        end
        playSound("rbxassetid://9119348206")
    end
end

local function addSpin()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
            bodyAngularVelocity.AngularVelocity = Vector3.new(0, 12, 0)
            bodyAngularVelocity.MaxTorque = Vector3.new(0, 12000, 0)
            bodyAngularVelocity.Parent = rootPart
            Debris:AddItem(bodyAngularVelocity, 6)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addFloat()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(0, 12000, 0)
            bodyVelocity.Velocity = Vector3.new(0, 12, 0)
            bodyVelocity.Parent = rootPart
            Debris:AddItem(bodyVelocity, 6)
            playSound("rbxassetid://9119348206")
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
        wait(6)
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.SmoothPlastic
            end
        end
        playSound("rbxassetid://9119348206")
    end
end

local function addForceField()
    local character = player.Character
    if character then
        local forceField = Instance.new("ForceField")
        forceField.Parent = character
        Debris:AddItem(forceField, 6)
        playSound("rbxassetid://9119348206")
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
            particles.Size = NumberSequence.new(1.2)
            particles.Lifetime = NumberRange.new(0.5, 1.5)
            particles.Rate = 60
            particles.Speed = NumberRange.new(4)
            particles.Parent = rootPart
            Debris:AddItem(particles, 6)
            playSound("rbxassetid://9119348206")
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
            particles.Size = NumberSequence.new(0.6)
            particles.Lifetime = NumberRange.new(1, 2)
            particles.Rate = 35
            particles.Speed = NumberRange.new(6)
            particles.SpreadAngle = Vector2.new(360, 360)
            particles.Parent = head
            Debris:AddItem(particles, 6)
            playSound("rbxassetid://9119348206")
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
            beam.Width0 = 0.4
            beam.Width1 = 0.4
            beam.Attachment0 = Instance.new("Attachment", rootPart)
            beam.Attachment1 = Instance.new("Attachment", rootPart)
            beam.Attachment1.Position = Vector3.new(0, 12, 0)
            beam.Parent = rootPart
            Debris:AddItem(beam, 6)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addHologram()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local hologram = Instance.new("Part")
            hologram.Size = Vector3.new(2.5, 2.5, 2.5)
            hologram.Transparency = 0.4
            hologram.BrickColor = BrickColor.new("Cyan")
            hologram.Material = Enum.Material.Neon
            hologram.Anchored = true
            hologram.Position = rootPart.Position + Vector3.new(0, 6, 0)
            hologram.Parent = workspace
            Debris:AddItem(hologram, 6)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addPulse()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local pulse = Instance.new("Part")
            pulse.Size = Vector3.new(6, 0.3, 6)
            pulse.Transparency = 0.4
            pulse.BrickColor = BrickColor.new("Magenta")
            pulse.Material = Enum.Material.Neon
            pulse.Anchored = true
            pulse.Position = rootPart.Position
            pulse.Parent = workspace
            local tween = TweenService:Create(pulse, TweenInfo.new(2), {Size = Vector3.new(12, 0.3, 12), Transparency = 1})
            tween:Play()
            Debris:AddItem(pulse, 2)
            playSound("rbxassetid://9119348206")
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
            trail.Lifetime = 1.5
            trail.Attachment0 = Instance.new("Attachment", rootPart)
            trail.Attachment1 = Instance.new("Attachment", rootPart)
            trail.Attachment1.Position = Vector3.new(0, -1, 0)
            trail.Parent = rootPart
            Debris:AddItem(trail, 6)
            playSound("rbxassetid://9119348206")
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
            particles.Size = NumberSequence.new(0.6)
            particles.Lifetime = NumberRange.new(0.5, 1)
            particles.Rate = 120
            particles.Speed = NumberRange.new(25)
            particles.SpreadAngle = Vector2.new(15, 15)
            particles.Parent = rootPart
            Debris:AddItem(particles, 6)
            playSound("rbxassetid://9119348206")
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
            particles.Size = NumberSequence.new(0.4)
            particles.Lifetime = NumberRange.new(1, 2)
            particles.Rate = 60
            particles.Speed = NumberRange.new(3)
            particles.SpreadAngle = Vector2.new(360, 360)
            particles.Parent = rootPart
            Debris:AddItem(particles, 6)
            playSound("rbxassetid://9119348206")
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
            particles.Size = NumberSequence.new(1.2)
            particles.Lifetime = NumberRange.new(1, 2)
            particles.Rate = 35
            particles.Speed = NumberRange.new(12)
            particles.Rotation = NumberRange.new(0, 360)
            particles.RotSpeed = NumberRange.new(120)
            particles.Parent = rootPart
            Debris:AddItem(particles, 6)
            playSound("rbxassetid://9119348206")
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
            particles.Size = NumberSequence.new(0.6)
            particles.Lifetime = NumberRange.new(2, 3)
            particles.Rate = 25
            particles.Speed = NumberRange.new(6)
            particles.SpreadAngle = Vector2.new(360, 360)
            particles.Parent = rootPart
            Debris:AddItem(particles, 6)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addGlowRing()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local ring = Instance.new("Part")
            ring.Size = Vector3.new(4, 0.3, 4)
            ring.Transparency = 0.4
            ring.BrickColor = BrickColor.new("Lime green")
            ring.Material = Enum.Material.Neon
            ring.Anchored = true
            ring.Position = rootPart.Position
            ring.Parent = workspace
            local tween = TweenService:Create(ring, TweenInfo.new(2), {Size = Vector3.new(8, 0.3, 8), Transparency = 1})
            tween:Play()
            Debris:AddItem(ring, 2)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addFlameTrail()
    local character = player.Character
    if character then
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local trail = Instance.new("Trail")
            trail.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
            trail.Lifetime = 0.6
            trail.Attachment0 = Instance.new("Attachment", rootPart)
            trail.Attachment1 = Instance.new("Attachment", rootPart)
            trail.Attachment1.Position = Vector3.new(0, -1, 0)
            trail.Parent = rootPart
            Debris:AddItem(trail, 6)
            playSound("rbxassetid://9119348206")
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
        wait(6)
        connection:Disconnect()
        playSound("rbxassetid://9119348206")
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
        smoke.Opacity = 0.4
        smoke.Size = 0.6
        smoke.Parent = character:FindFirstChild("HumanoidRootPart")
        wait(6)
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                local tween = TweenService:Create(part, TweenInfo.new(1), {Transparency = 0})
                tween:Play()
            end
        end
        Debris:AddItem(smoke, 6)
        playSound("rbxassetid://9119348206")
    end
end

local function addCloneShadow()
    local character = player.Character
    if character then
        local clone = character:Clone()
        clone.Parent = workspace
        for _, part in pairs(clone:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.7
                part.Anchored = true
            end
        end
        Debris:AddItem(clone, 6)
        playSound("rbxassetid://9119348206")
    end
end

local function addSpeedBoost()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 60
            wait(6)
            humanoid.WalkSpeed = 16
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addJumpBoost()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = 120
            wait(6)
            humanoid.JumpPower = 50
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addGravityShift()
    local character = player.Character
    if character then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(0, 12000, 0)
        bodyVelocity.Velocity = Vector3.new(0, -12, 0)
        bodyVelocity.Parent = character:FindFirstChild("HumanoidRootPart")
        Debris:AddItem(bodyVelocity, 6)
        playSound("rbxassetid://9119348206")
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
        wait(6)
        connection:Disconnect()
        playSound("rbxassetid://9119348206")
    end
end

local function addOrbitingStars()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for i = 1, 6 do
                local star = Instance.new("Part")
                star.Size = Vector3.new(0.6, 0.6, 0.6)
                star.BrickColor = BrickColor.new("Yellow")
                star.Material = Enum.Material.Neon
                star.Anchored = true
                star.Parent = workspace
                local angle = (i - 1) * (2 * math.pi / 6)
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    star.Position = rootPart.Position + Vector3.new(math.cos(tick() + angle) * 4, 1, math.sin(tick() + angle) * 4)
                end)
                Debris:AddItem(star, 6)
                wait(0)
            end
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addShockwave()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local shockwave = Instance.new("Part")
            shockwave.Size = Vector3.new(1, 0.3, 1)
            shockwave.Transparency = 0.4
            shockwave.BrickColor = BrickColor.new("White")
            shockwave.Material = Enum.Material.Neon
            shockwave.Anchored = true
            shockwave.Position = rootPart.Position
            shockwave.Parent = workspace
            local tween = TweenService:Create(shockwave, TweenInfo.new(1.5), {Size = Vector3.new(12, 0.3, 12), Transparency = 1})
            tween:Play()
            Debris:AddItem(shockwave, 1.5)
            playSound("rbxassetid://9119348206")
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
            particles.Size = NumberSequence.new(0.6)
            particles.Lifetime = NumberRange.new(1, 2)
            particles.Rate = 60
            particles.Speed = NumberRange.new(6)
            particles.SpreadAngle = Vector2.new(360, 360)
            particles.Parent = rootPart
            Debris:AddItem(particles, 6)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addGlowingOrbs()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for i = 1, 4 do
                local orb = Instance.new("Part")
                orb.Size = Vector3.new(0.6, 0.6, 0.6)
                orb.BrickColor = BrickColor.new("Cyan")
                orb.Material = Enum.Material.Neon
                orb.Anchored = true
                orb.Parent = workspace
                local angle = (i - 1) * (2 * math.pi / 4)
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    orb.Position = rootPart.Position + Vector3.new(math.cos(tick() + angle) * 3, math.sin(tick()) * 2, math.sin(tick() + angle) * 3)
                end)
                Debris:AddItem(orb, 6)
                wait(0)
            end
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addGlitchEffect()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for i = 1, 10 do
                local glitch = character:Clone()
                glitch.Parent = workspace
                for _, part in pairs(glitch:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0.8
                        part.Anchored = true
                        part.Position = part.Position + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
                    end
                end
                Debris:AddItem(glitch, 0.5)
                wait(0.1)
            end
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addHoloClone()
    local character = player.Character
    if character then
        local clone = character:Clone()
        clone.Parent = workspace
        for _, part in pairs(clone:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.5
                part.BrickColor = BrickColor.new("Cyan")
                part.Material = Enum.Material.Neon
                part.Anchored = true
            end
        end
        Debris:AddItem(clone, 6)
        playSound("rbxassetid://9119348206")
    end
end

local function addDiscoFloor()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for i = -2, 2 do
                for j = -2, 2 do
                    local tile = Instance.new("Part")
                    tile.Size = Vector3.new(2, 0.2, 2)
                    tile.BrickColor = BrickColor.new(Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
                    tile.Material = Enum.Material.Neon
                    tile.Anchored = true
                    tile.Position = rootPart.Position + Vector3.new(i * 2, -2, j * 2)
                    tile.Parent = workspace
                    Debris:AddItem(tile, 6)
                end
            end
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addFakeKnife()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local knife = Instance.new("Part")
            knife.Size = Vector3.new(0.2, 0.2, 2)
            knife.BrickColor = BrickColor.new("Really red")
            knife.Material = Enum.Material.Metal
            knife.Anchored = false
            knife.Position = rootPart.Position + Vector3.new(0, 0, 3)
            knife.Parent = workspace
            local clickDetector = Instance.new("ClickDetector")
            clickDetector.Parent = knife
            clickDetector.MouseClick:Connect(function()
                local sparkles = Instance.new("Sparkles")
                sparkles.SparkleColor = Color3.fromRGB(255, 0, 0)
                sparkles.Parent = knife
                Debris:AddItem(sparkles, 1)
                knife:Destroy()
                playSound("rbxassetid://9119348206")
            end)
            Debris:AddItem(knife, 10)
        end
    end
end

local function addPlayerESP()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.Adornee = p.Character.Head
            billboard.AlwaysOnTop = true
            billboard.Parent = p.Character
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = p.Name
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextSize = 16
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.BackgroundTransparency = 1
            textLabel.Parent = billboard
            Debris:AddItem(billboard, 10)
        end
    end
    playSound("rbxassetid://9119348206")
end

local function addRoleESP()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.Adornee = p.Character.Head
            billboard.AlwaysOnTop = true
            billboard.Parent = p.Character
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = "Role: Unknown"
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextSize = 16
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Parent = billboard
            Debris:AddItem(billboard, 10)
        end
    end
    playSound("rbxassetid://9119348206")
end

local function autoCoinCollect()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for _, obj in pairs(workspace:GetChildren()) do
                if obj.Name:lower():find("coin") then
                    rootPart.CFrame = obj.CFrame
                    wait(0.1)
                end
            end
            playSound("rbxassetid://9119348206")
        end
    end
end

local function fakeSheriffRole()
    local character = player.Character
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.Adornee = head
            billboard.AlwaysOnTop = true
            billboard.Parent = character
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = "SHERIFF!"
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextSize = 20
            textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Parent = billboard
            Debris:AddItem(billboard, 8)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function randomTeleportAll()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = p.Character.HumanoidRootPart
            targetRoot.CFrame = targetRoot.CFrame + Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
        end
    end
    playSound("rbxassetid://9119348206")
end

local function addRandomDecoys()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for i = 1, 3 do
                local decoy = character:Clone()
                decoy.Parent = workspace
                for _, part in pairs(decoy:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0.6
                        part.Anchored = true
                        part.Position = rootPart.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                    end
                end
                Debris:AddItem(decoy, 6)
                wait(0.1)
            end
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addChaosParticles()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local particles = Instance.new("ParticleEmitter")
            particles.Texture = "rbxassetid://243098098"
            particles.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
            })
            particles.Size = NumberSequence.new(0.8)
            particles.Lifetime = NumberRange.new(1, 2)
            particles.Rate = 80
            particles.Speed = NumberRange.new(8)
            particles.SpreadAngle = Vector2.new(360, 360)
            particles.Parent = rootPart
            Debris:AddItem(particles, 6)
            playSound("rbxassetid://9119348206")
        end
    end
end

createButton("CrownButton", "Add Crown", addCrown)
createButton("DanceButton", "Dance Animation", playDance)
createButton("JumpButton", "Jump Animation", playJump)
createButton("WaveButton", "Wave Animation", playWave)
createButton("LaughButton", "Laugh Animation", playLaugh)
createButton("SpinButton", "Spin Animation", playSpin)
createButton("ClapButton", "Clap Animation", playClap)
createButton("SaluteButton", "Salute Animation", playSalute)
createButton("PointButton", "Point Animation", playPoint)
createButton("CheerButton", "Cheer Animation", playCheer)
createButton("FlossButton", "Floss Animation", playFloss)
createButton("DabButton", "Dab Animation", playDab)
createButton("MoonwalkButton", "Moonwalk Animation", playMoonwalk)
createButton("OrangeJusticeButton", "Orange Justice Animation", playOrangeJustice)
createButton("HypeDanceButton", "Hype Dance Animation", playHypeDance)
createButton("KazotskyKickButton", "Kazotsky Kick Animation", playKazotskyKick)
createButton("BreakdanceButton", "Breakdance Animation", playBreakdance)
createButton("ZombieWalkButton", "Zombie Walk Animation", playZombieWalk)
createButton("SillyDanceButton", "Silly Dance Animation", playSillyDance)
createButton("RobotDanceButton", "Robot Dance Animation", playRobotDance)
createButton("GangnamStyleButton", "Gangnam Style Animation", playGangnamStyle)
createButton("TposeButton", "T-Pose Animation", playTpose)
createButton("RumbaButton", "Rumba Animation", playRumba)
createButton("TwerkButton", "Twerk Animation", playTwerk)
createButton("MacarenaButton", "Macarena Animation", playMacarena)
createButton("FireButton", "Fire Effect", addFireEffect)
createButton("SparklesButton", "Sparkles Effect", addSparkles)
createButton("SmokeButton", "Smoke Effect", addSmoke)
createButton("ColorButton", "Random Color", changeColor)
createButton("TeleportPlayerButton", "Teleport to Player", teleportToPlayer)
createButton("StickPlayerButton", "Stick to Player", stickToPlayer)
createButton("NudgePlayerButton", "Nudge Player", nudgePlayer)
createButton("OrbitPlayerButton", "Orbit Player", orbitPlayer)
createButton("MirrorMovementButton", "Mirror Movement", mirrorMovement)
createButton("FakeDeathButton", "Fake Death", fakeDeath)
createButton("FakeGunButton", "Drop Fake Gun", dropFakeGun)
createButton("FakeMurdererButton", "Fake Murderer Indicator", fakeMurdererIndicator)
createButton("SpamChatButton", "Spam Chat", spamChat)
createButton("FakeCoinButton", "Drop Fake Coins", fakeCoinDrop)
createButton("TeleportSpamButton", "Teleport Spam", teleportSpam)
createButton("TrailButton", "Trail Effect", addTrail)
createButton("GlowButton", "Glow Effect", glowEffect)
createButton("SizeButton", "Size Change", sizeChange)
createButton("RainbowButton", "Rainbow Effect", rainbowEffect)
createButton("BeamButton", "Beam Effect", addBeam)
createButton("AuraButton", "Aura Effect", addAura)
createButton("ExplosionButton", "Explosion Effect", addExplosionEffect)
createButton("TransparencyButton", "Transparency Effect", changeTransparency)
createButton("SpinEffectButton", "Spin Effect", addSpin)
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
createButton("GlitchButton", "Glitch Effect", addGlitchEffect)
createButton("HoloCloneButton", "Holo Clone", addHoloClone)
createButton("DiscoFloorButton", "Disco Floor", addDiscoFloor)
createButton("FakeKnifeButton", "Drop Fake Knife", addFakeKnife)
createButton("PlayerESPButton", "Player ESP", addPlayerESP)
createButton("RoleESPButton", "Role ESP", addRoleESP)
createButton("AutoCoinButton", "Auto Coin Collect", autoCoinCollect)
createButton("FakeSheriffButton", "Fake Sheriff Role", fakeSheriffRole)
createButton("RandomTeleportButton", "Random Teleport All", randomTeleportAll)
createButton("RandomDecoysButton", "Random Decoys", addRandomDecoys)
createButton("ChaosParticlesButton", "Chaos Particles", addChaosParticles)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.M then
        if tick() - lastToggle > toggleCooldown then
            menuFrame.Visible = not menuFrame.Visible
            lastToggle = tick()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://9119348206"
            sound.Parent = menuGui
            sound:Play()
            Debris:AddItem(sound, 2)
        end
    end
end)