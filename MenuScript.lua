local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create ScreenGui
local menuGui = Instance.new("ScreenGui")
menuGui.Name = "EpicMM2TrollGui"
menuGui.Enabled = true
menuGui.IgnoreGuiInset = true
menuGui.ResetOnSpawn = false
menuGui.Parent = playerGui

-- Toggle Button
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

-- Menu Frame
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0.6, 0, 0.85, 0)
menuFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
menuFrame.BackgroundTransparency = 0.3
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false -- Initially hidden
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

-- Menu Title
local menuTitle = Instance.new("TextLabel")
menuTitle.Size = UDim2.new(1, -40, 0, 50)
menuTitle.Text = "MM2 Chaos Troll Menu v2"
menuTitle.Font = Enum.Font.Arcade
menuTitle.TextSize = 28
menuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuTitle.BackgroundTransparency = 1
menuTitle.TextStrokeTransparency = 0.7
menuTitle.TextStrokeColor3 = Color3.fromRGB(0, 255, 255)
menuTitle.Parent = menuFrame

-- Minimize Button
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

-- Scrolling Frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -60)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 5000)
scrollFrame.Parent = menuFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.Parent = scrollFrame

-- Dragging Logic
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

-- Minimize Logic
local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        minimizeButton.Text = "+"
        scrollFrame.Visible = false
        menuFrame.Size = UDim2.new(0.6, 0, 0, 50)
    else
        minimizeButton.Text = "-"
        scrollFrame.Visible = true
        menuFrame.Size = UDim2.new(0.6, 0, 0.85, 0)
    end
end)

-- Toggle Menu
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

-- Button Creation Function
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

-- Utility Functions
local function playAnimation(animId)
    pcall(function()
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
    end)
end

local function playSound(soundId)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Parent = player.Character and player.Character:FindFirstChild("HumanoidRootPart") or workspace
        sound:Play()
        Debris:AddItem(sound, 5)
    end)
end

-- Existing Visual Features (from previous script)
local function addCrown()
    pcall(function()
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
    end)
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
    pcall(function()
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
    end)
end

local function addSparkles()
    pcall(function()
        local character = player.Character
        if character then
            local sparkles = Instance.new("Sparkles")
            sparkles.SparkleColor = Color3.fromRGB(0, 255, 255)
            sparkles.Parent = character:FindFirstChild("HumanoidRootPart")
            Debris:AddItem(sparkles, 6)
            playSound("rbxassetid://9119348206")
        end
    end)
end

local function addSmoke()
    pcall(function()
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
    end)
end

local function changeColor()
    pcall(function()
        local character = player.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.Random()
                end
            end
            playSound("rbxassetid://9119348206")
        end
    end)
end

local function teleportToPlayer()
    pcall(function()
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
    end)
end

local function stickToPlayer()
    pcall(function()
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
    end)
end

local function nudgePlayer()
    pcall(function()
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
    end)
end

local function orbitPlayer()
    pcall(function()
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
    end)
end

local function mirrorMovement()
    pcall(function()
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
    end)
end

local function fakeDeath()
    pcall(function()
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
    end)
end

local function dropFakeGun()
    pcall(function()
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
    end)
end

local function fakeMurdererIndicator()
    pcall(function()
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
    end)
end

local function spamChat()
    pcall(function()
        local messages = {
            "GET TROLLED NOOBS!", 
            "WHO'S THE MURDERER? NOT ME!", 
            "SHERIFF UR TRASH!", 
            "EZ CLAP!", 
            "CRY MORE LOL!"
        }
        for i = 1, 10 do
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(messages[math.random(1, #messages)], "All")
            wait(0.3)
        end
        playSound("rbxassetid://9119348206")
    end)
end

local function fakeCoinDrop()
    pcall(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for i = 1, 15 do
                    local coin = Instance.new("Part")
                    coin.Size = Vector3.new(0.5, 0.5, 0.5)
                    coin.BrickColor = BrickColor.new("Gold")
                    coin.Material = Enum.Material.Neon
                    coin.Anchored = false
                    coin.Position = rootPart.Position + Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
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
    end)
end

local function teleportSpam()
    pcall(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for i = 1, 10 do
                    rootPart.CFrame = rootPart.CFrame + Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
                    wait(0.1)
                end
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

local function addTrail()
    pcall(function()
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
    end)
end

local function glowEffect()
    pcall(function()
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
    end)
end

local function sizeChange()
    pcall(function()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.BodyDepthScale.Value = 3
                humanoid.BodyHeightScale.Value = 3
                humanoid.BodyWidthScale.Value = 3
                wait(6)
                humanoid.BodyDepthScale.Value = 1
                humanoid.BodyHeightScale.Value = 1
                humanoid.BodyWidthScale.Value = 1
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

local function rainbowEffect()
    pcall(function()
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
    end)
end

local function addBeam()
    pcall(function()
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
    end)
end

local function addAura()
    pcall(function()
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
    end)
end

local function addExplosionEffect()
    pcall(function()
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
    end)
end

local function changeTransparency()
    pcall(function()
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
    end)
end

local function addSpin()
    pcall(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
                bodyAngularVelocity.AngularVelocity = Vector3.new(0, 15, 0)
                bodyAngularVelocity.MaxTorque = Vector3.new(0, 15000, 0)
                bodyAngularVelocity.Parent = rootPart
                Debris:AddItem(bodyAngularVelocity, 6)
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

local function addFloat()
    pcall(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(0, 15000, 0)
                bodyVelocity.Velocity = Vector3.new(0, 15, 0)
                bodyVelocity.Parent = rootPart
                Debris:AddItem(bodyVelocity, 6)
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

local function addNeon()
    pcall(function()
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
    end)
end

local function addForceField()
    pcall(function()
        local character = player.Character
        if character then
            local forceField = Instance.new("ForceField")
            forceField.Parent = character
            Debris:AddItem(forceField, 6)
            playSound("rbxassetid://9119348206")
        end
    end)
end

local function addGlowParticles()
    pcall(function()
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
    end)
end

local function addStarEffect()
    pcall(function()
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
    end)
end

local function addLightning()
    pcall(function()
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
    end)
end

local function addHologram()
    pcall(function()
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
    end)
end

local function addPulse()
    pcall(function()
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
    end)
end

local function addRainbowTrail()
    pcall(function()
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
    end)
end

local function addSpeedLines()
    pcall(function()
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
    end)
end

local function addGlitter()
    pcall(function()
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
    end)
end

local function addVortex()
    pcall(function()
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
    end)
end

local function addBubbleEffect()
    pcall(function()
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
    end)
end

local function addGlowRing()
    pcall(function()
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
    end)
end

local function addFlameTrail()
    pcall(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
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
    end)
end

local function addDiscoEffect()
    pcall(function()
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
    end)
end

local function addGhostEffect()
    pcall(function()
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
    end)
end

local function addCloneShadow()
    pcall(function()
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
    end)
end

local function addSpeedBoost()
    pcall(function()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 100
                wait(6)
                humanoid.WalkSpeed = 16
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

local function addJumpBoost()
    pcall(function()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = 150
                wait(6)
                humanoid.JumpPower = 50
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

local function addGravityShift()
    pcall(function()
        local character = player.Character
        if character then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(0, 15000, 0)
            bodyVelocity.Velocity = Vector3.new(0, -15, 0)
            bodyVelocity.Parent = character:FindFirstChild("HumanoidRootPart")
            Debris:AddItem(bodyVelocity, 6)
            playSound("rbxassetid://9119348206")
        end
    end)
end

local function addColorPulse()
    pcall(function()
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
    end)
end

local function addOrbitingStars()
    pcall(function()
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
    end)
end

local function addShockwave()
    pcall(function()
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
    end)
end

local function addRainbowParticles()
    pcall(function()
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
    end)
end

local function addGlowingOrbs()
    pcall(function()
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
    end)
end

local function addGlitchEffect()
    pcall(function()
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
    end)
end

local function addHoloClone()
    pcall(function()
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
    end)
end

local function addDiscoFloor()
    pcall(function()
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
    end)
end

local function addFakeKnife()
    pcall(function()
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
    end)
end

local function addPlayerESP()
    pcall(function()
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
    end)
end

local function addRoleESP()
    pcall(function()
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
    end)
end

local function autoCoinCollect()
    pcall(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name:lower():find("coin") then
                        rootPart.CFrame = obj.CFrame
                        wait(0.05)
                    end
                end
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

local function fakeSheriffRole()
    pcall(function()
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
    end)
end

local function randomTeleportAll()
    pcall(function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = p.Character.HumanoidRootPart
                targetRoot.CFrame = targetRoot.CFrame + Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
            end
        end
        playSound("rbxassetid://9119348206")
    end)
end

local function addRandomDecoys()
    pcall(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for i = 1, 5 do
                    local decoy = character:Clone()
                    decoy.Parent = workspace
                    for _, part in pairs(decoy:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 0.6
                            part.Anchored = true
                            part.Position = rootPart.Position + Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
                        end
                    end
                    Debris:AddItem(decoy, 6)
                    wait(0.1)
                end
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

local function addChaosParticles()
    pcall(function()
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
                particles.Rate = 100
                particles.Speed = NumberRange.new(8)
                particles.SpreadAngle = Vector2.new(360, 360)
                particles.Parent = rootPart
                Debris:AddItem(particles, 6)
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

-- Existing MM2 Cheats
local function killAll()
    pcall(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
                        local targetHumanoid = p.Character.Humanoid
                        targetHumanoid:TakeDamage(100)
                    end
                end
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("ALL NOOBS DOWN! EZ!", "All")
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

local function autoGrabGun()
    pcall(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name:lower():find("gun") then
                        rootPart.CFrame = obj.CFrame
                        wait(0.05)
                    end
                end
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

local function silentAim()
    pcall(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local closestPlayer = nil
                local closestDistance = math.huge
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (p.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = p
                        end
                    end
                end
                if closestPlayer then
                    rootPart.CFrame = CFrame.new(rootPart.Position, closestPlayer.Character.HumanoidRootPart.Position)
                    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("LOCKED ON " .. closestPlayer.Name .. "!", "All")
                end
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

local function fakeBanMessage()
    pcall(function()
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[SYSTEM]: " .. player.Name .. " has been banned for exploiting!", "All")
        playSound("rbxassetid://9119348206")
    end)
end

local function spamTaunts()
    pcall(function()
        local taunts = {
            "UR SO BAD LMAO!",
            "GET GOOD NOOB!",
            "EZ WIN FOR ME!",
            "CRY HARDER!",
            "MM2 IS MY PLAYGROUND!"
        }
        for i = 1, 15 do
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(taunts[math.random(1, #taunts)], "All")
            wait(0.2)
        end
        playSound("rbxassetid://9119348206")
    end)
end

local function fakeKillFeed()
    pcall(function()
        for i = 1, 5 do
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(player.Name .. " killed " .. game.Players:GetPlayers()[math.random(1, #game.Players:GetPlayers())].Name .. "!", "All")
            wait(0.3)
        end
        playSound("rbxassetid://9119348206")
    end)
end

local function massTeleportSpam()
    pcall(function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = p.Character.HumanoidRootPart
                for i = 1, 5 do
                    targetRoot.CFrame = targetRoot.CFrame + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))
                    wait(0.1)
                end
            end
        end
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("CHAOS TELEPORT ACTIVATE!", "All")
        playSound("rbxassetid://9119348206")
    end)
end

local function lagPlayers()
    pcall(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for i = 1, 50 do
                    local part = Instance.new("Part")
                    part.Size = Vector3.new(0.2, 0.2, 0.2)
                    part.Transparency = 1
                    part.Anchored = true
                    part.Position = rootPart.Position + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
                    part.Parent = workspace
                    local particles = Instance.new("ParticleEmitter")
                    particles.Texture = "rbxassetid://243098098"
                    particles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
                    particles.Size = NumberSequence.new(0.5)
                    particles.Lifetime = NumberRange.new(1, 2)
                    particles.Rate = 200
                    particles.Speed = NumberRange.new(5)
                    particles.Parent = part
                    Debris:AddItem(part, 3)
                end
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("LAG PARTY STARTED!", "All")
                playSound("rbxassetid://9119348206")
            end
        end
    end)
end

local function bombSpam()
    pcall(function