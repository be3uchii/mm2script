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

local function playSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Parent = player.Character and player.Character:FindFirstChild("HumanoidRootPart") or workspace
    sound:Play()
    Debris:AddItem(sound, 5)
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

local function addFakeBloodTrail()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local blood = Instance.new("Part")
                blood.Size = Vector3.new(0.5, 0.1, 0.5)
                blood.BrickColor = BrickColor.new("Really red")
                blood.Material = Enum.Material.Neon
                blood.Anchored = true
                blood.Position = rootPart.Position + Vector3.new(0, -1.9, 0)
                blood.Parent = workspace
                Debris:AddItem(blood, 5)
            end)
            wait(6)
            connection:Disconnect()
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addFakeWantedPoster()
    local character = player.Character
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 150, 0, 100)
            billboard.Adornee = head
            billboard.AlwaysOnTop = true
            billboard.Parent = character
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = "WANTED!\nREWARD: 1000 COINS"
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextSize = 18
            textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            textLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            textLabel.BackgroundTransparency = 0.3
            textLabel.Parent = billboard
            Debris:AddItem(billboard, 8)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addTrollLaughSound()
    local character = player.Character
    if character then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://184689353"
        sound.Volume = 2
        sound.Parent = character:FindFirstChild("HumanoidRootPart") or workspace
        sound:Play()
        Debris:AddItem(sound, 5)
    end
end

local function addFakeFootprints()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local footprint = Instance.new("Part")
                footprint.Size = Vector3.new(0.8, 0.1, 0.4)
                footprint.BrickColor = BrickColor.new("Really black")
                footprint.Material = Enum.Material.Concrete
                footprint.Anchored = true
                footprint.Position = rootPart.Position + Vector3.new(0, -1.9, 0)
                footprint.Parent = workspace
                Debris:AddItem(footprint, 5)
            end)
            wait(6)
            connection:Disconnect()
            playSound("rbxassetid://9119348206")
        end
    end
end

local function addFakeTrap()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local trap = Instance.new("Part")
            trap.Size = Vector3.new(3, 0.2, 3)
            trap.BrickColor = BrickColor.new("Dark gray")
            trap.Material = Enum.Material.Metal
            trap.Anchored = true
            trap.Position = rootPart.Position + Vector3.new(0, -1.9, 0)
            trap.Parent = workspace
            local clickDetector = Instance.new("ClickDetector")
            clickDetector.Parent = trap
            clickDetector.MouseClick:Connect(function()
                local explosion = Instance.new("Explosion")
                explosion.BlastRadius = 5
                explosion.BlastPressure = 0
                explosion.Position = trap.Position
                explosion.Parent = workspace
                Debris:AddItem(explosion, 1)
                trap:Destroy()
                playSound("rbxassetid://9119348206")
            end)
            Debris:AddItem(trap, 10)
        end
    end
end

local function addFakeCoinMagnet()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local magnet = Instance.new("Part")
            magnet.Size = Vector3.new(1, 1, 1)
            magnet.BrickColor = BrickColor.new("Gold")
            magnet.Material = Enum.Material.Neon
            magnet.Anchored = true
            magnet.Position = rootPart.Position + Vector3.new(0, 3, 0)
            magnet.Parent = workspace
            local clickDetector = Instance.new("ClickDetector")
            clickDetector.Parent = magnet
            clickDetector.MouseClick:Connect(function()
                local sparkles = Instance.new("Sparkles")
                sparkles.SparkleColor = Color3.fromRGB(255, 255, 0)
                sparkles.Parent = magnet
                Debris:AddItem(sparkles, 1)
                magnet:Destroy()
                playSound("rbxassetid://9119348206")
            end)
            Debris:AddItem(magnet, 10)
        end
    end
end

local function addTrollTaunt()
    local messages = {"CATCH ME IF YOU CAN!", "TOO SLOW!", "BET YOU CAN'T FIND ME!", "TROLLED AGAIN!", "WHO'S NEXT?"}
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(messages[math.random(1, #messages)], "All")
    playSound("rbxassetid://9119348206")
end

local function addFakeWeaponCrate()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local crate = Instance.new("Part")
            crate.Size = Vector3.new(2, 2, 2)
            crate.BrickColor = BrickColor.new("Brown")
            crate.Material = Enum.Material.Wood
            crate.Anchored = true
            crate.Position = rootPart.Position + Vector3.new(0, 0, 3)
            crate.Parent = workspace
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.Adornee = crate
            billboard.AlwaysOnTop = true
            billboard.Parent = crate
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = "LEGENDARY WEAPON!"
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextSize = 16
            textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Parent = billboard
            local clickDetector = Instance.new("ClickDetector")
            clickDetector.Parent = crate
            clickDetector.MouseClick:Connect(function()
                local explosion = Instance.new("Explosion")
                explosion.BlastRadius = 5
                explosion.BlastPressure = 0
                explosion.Position = crate.Position
                explosion.Parent = workspace
                Debris:AddItem(explosion, 1)
                crate:Destroy()
                playSound("rbxassetid://9119348206")
            end)
            Debris:AddItem(crate, 10)
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

-- New Trolling Functions
local function massChatSpam()
    local messages = {"YOU CAN'T ESCAPE!", "TROLLED FOREVER!", "SERVER IS MINE!", "GET REKT!", "CHAOS TIME!"}
    for i = 1, 10 do
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(messages[math.random(1, #messages)], "All")
        wait(0.3)
    end
    playSound("rbxassetid://9119348206")
end

local function freezePlayer()
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
                targetRoot.Anchored = true
                wait(5)
                targetRoot.Anchored = false
                playSound("rbxassetid://9119348206")
            end
        end
    end
end

local function massTeleportChaos()
    for i = 1, 5 do
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = p.Character.HumanoidRootPart
                targetRoot.CFrame = targetRoot.CFrame + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))
            end
        end
        wait(0.2)
    end
    playSound("rbxassetid://9119348206")
end

local function dropFakeCoinsEverywhere()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = p.Character.HumanoidRootPart
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
                    coin:Destroy()
                    playSound("rbxassetid://9119348206")
                end)
                Debris:AddItem(coin, 8)
            end
        end
    end
    playSound("rbxassetid://9119348206")
end

local function fakeRoleReveal()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.Adornee = p.Character.Head
            billboard.AlwaysOnTop = true
            billboard.Parent = p.Character
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = math.random(1, 2) == 1 and "MURDERER!" or "SHERIFF!"
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextSize = 20
            textLabel.TextColor3 = math.random(1, 2) == 1 and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Parent = billboard
            Debris:AddItem(billboard, 8)
        end
    end
    playSound("rbxassetid://9119348206")
end

local function pushAllPlayers()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = p.Character.HumanoidRootPart
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(8000, 0, 8000)
            bodyVelocity.Velocity = Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))
            bodyVelocity.Parent = targetRoot
            Debris:AddItem(bodyVelocity, 0.5)
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeTraps()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = p.Character.HumanoidRootPart
            for i = 1, 5 do
                local trap = Instance.new("Part")
                trap.Size = Vector3.new(3, 0.2, 3)
                trap.BrickColor = BrickColor.new("Dark gray")
                trap.Material = Enum.Material.Metal
                trap.Anchored = true
                trap.Position = rootPart.Position + Vector3.new(math.random(-5, 5), -1.9, math.random(-5, 5))
                trap.Parent = workspace
                local clickDetector = Instance.new("ClickDetector")
                clickDetector.Parent = trap
                clickDetector.MouseClick:Connect(function()
                    local explosion = Instance.new("Explosion")
                    explosion.BlastRadius = 5
                    explosion.BlastPressure = 0
                    explosion.Position = trap.Position
                    explosion.Parent = workspace
                    Debris:AddItem(explosion, 1)
                    trap:Destroy()
                    playSound("rbxassetid://9119348206")
                end)
                Debris:AddItem(trap, 10)
            end
        end
    end
    playSound("rbxassetid://9119348206")
end

local function blockPlayerMovement()
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
                local block = Instance.new("Part")
                block.Size = Vector3.new(5, 5, 5)
                block.Transparency = 0.8
                block.Anchored = true
                block.Position = targetRoot.Position
                block.Parent = workspace
                Debris:AddItem(block, 5)
                playSound("rbxassetid://9119348206")
            end
        end
    end
end

local function fakeObjectiveMarker()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = p.Character.HumanoidRootPart
            local marker = Instance.new("Part")
            marker.Size = Vector3.new(1, 1, 1)
            marker.BrickColor = BrickColor.new("Bright yellow")
            marker.Material = Enum.Material.Neon
            marker.Anchored = true
            marker.Position = rootPart.Position + Vector3.new(math.random(-10, 10), 3, math.random(-10, 10))
            marker.Parent = workspace
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.Adornee = marker
            billboard.AlwaysOnTop = true
            billboard.Parent = marker
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = "OBJECTIVE!"
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextSize = 16
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Parent = billboard
            Debris:AddItem(marker, 10)
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamAnnoyingSound()
    for i = 1, 5 do
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://184689353"
        sound.Volume = 2
        sound.Parent = workspace
        sound:Play()
        Debris:AddItem(sound, 3)
        wait(0.5)
    end
end

local function teleportToSafeSpot()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = CFrame.new(Vector3.new(1000, 1000, 1000))
            playSound("rbxassetid://9119348206")
        end
    end
end

local function massNudgePlayers()
    for i = 1, 3 do
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = p.Character.HumanoidRootPart
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(6000, 0, 6000)
                bodyVelocity.Velocity = Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
                bodyVelocity.Parent = targetRoot
                Debris:AddItem(bodyVelocity, 0.3)
            end
        end
        wait(0.2)
    end
    playSound("rbxassetid://9119348206")
end

local function fakePlayerDeath()
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
            rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 50, 0)
            wait(2)
            rootPart.CFrame = rootPart.CFrame + Vector3.new(0, -50, 0)
            playSound("rbxassetid://9119348206")
        end
    end
end

local function spamFakeWeapons()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = p.Character.HumanoidRootPart
            for i = 1, 5 do
                local gun = Instance.new("Part")
                gun.Size = Vector3.new(1, 0.5, 2)
                gun.BrickColor = BrickColor.new("Really black")
                gun.Material = Enum.Material.Metal
                gun.Anchored = false
                gun.Position = rootPart.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
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
    playSound("rbxassetid://9119348206")
end

local function slowAllPlayers()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
            local humanoid = p.Character.Humanoid
            humanoid.WalkSpeed = 8
            wait(5)
            humanoid.WalkSpeed = 16
        end
    end
    playSound("rbxassetid://9119348206")
end

local function reversePlayerControls()
    local character = player.Character
    if character then
        local players = game.Players:GetPlayers()
        local otherPlayers = {}
        for _, p in pairs(players) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
                table.insert(otherPlayers, p)
            end
        end
        if #otherPlayers > 0 then
            local target = otherPlayers[math.random(1, #otherPlayers)]
            local humanoid = target.Character:FindFirstChild("Humanoid")
            if humanoid then
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if humanoid.MoveDirection.Magnitude > 0 then
                        humanoid:Move(-humanoid.MoveDirection)
                    end
                end)
                wait(5)
                connection:Disconnect()
                playSound("rbxassetid://9119348206")
            end
        end
    end
end

local function dropFakeKnives()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = p.Character.HumanoidRootPart
            for i = 1, 5 do
                local knife = Instance.new("Part")
                knife.Size = Vector3.new(0.2, 0.2, 2)
                knife.BrickColor = BrickColor.new("Really red")
                knife.Material = Enum.Material.Metal
                knife.Anchored = false
                knife.Position = rootPart.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                knife.Parent = workspace
                local clickDetector = Instance.new("ClickDetector")
                clickDetector.Parent = knife
                clickDetector.MouseClick:Connect(function()
                    knife:Destroy()
                    playSound("rbxassetid://9119348206")
                end)
                Debris:AddItem(knife, 10)
            end
        end
    end
    playSound("rbxassetid://9119348206")
end

local function teleportPlayersToYou()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = p.Character.HumanoidRootPart
                    targetRoot.CFrame = rootPart.CFrame + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
                end
            end
            playSound("rbxassetid://9119348206")
        end
    end
end

local function fakeGameCrash()
    for i = 1, 10 do
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("SERVER CRASH IN 3...2...1...", "All")
        wait(0.3)
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeObjectives()
    for i = 1, 10 do
        local marker = Instance.new("Part")
        marker.Size = Vector3.new(1, 1, 1)
        marker.BrickColor = BrickColor.new("Bright yellow")
        marker.Material = Enum.Material.Neon
        marker.Anchored = true
        marker.Position = Vector3.new(math.random(-50, 50), 3, math.random(-50, 50))
        marker.Parent = workspace
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.Adornee = marker
        billboard.AlwaysOnTop = true
        billboard.Parent = marker
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Text = "SECRET OBJECTIVE!"
        textLabel.Font = Enum.Font.Arcade
        textLabel.TextSize = 16
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Parent = billboard
        Debris:AddItem(marker, 8)
    end
    playSound("rbxassetid://9119348206")
end

local function lockPlayerCamera()
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
                local camera = workspace.CurrentCamera
                camera.CameraType = Enum.CameraType.Scriptable
                camera.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 5, 10), targetRoot.Position)
                wait(5)
                camera.CameraType = Enum.CameraType.Custom
                playSound("rbxassetid://9119348206")
            end
        end
    end
end

local function spamFakeRoleIndicators()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            for i = 1, 3 do
                local billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.Adornee = p.Character.Head
                billboard.AlwaysOnTop = true
                billboard.Parent = p.Character
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.Text = math.random(1, 3) == 1 and "MURDERER!" or math.random(1, 2) == 1 and "SHERIFF!" or "INNOCENT!"
                textLabel.Font = Enum.Font.Arcade
                textLabel.TextSize = 20
                textLabel.TextColor3 = math.random(1, 3) == 1 and Color3.fromRGB(255, 0, 0) or math.random(1, 2) == 1 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
                textLabel.BackgroundTransparency = 1
                textLabel.Parent = billboard
                Debris:AddItem(billboard, 5)
                wait(0.2)
            end
        end
    end
    playSound("rbxassetid://9119348206")
end

local function massSlowPlayers()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
            local humanoid = p.Character.Humanoid
            humanoid.WalkSpeed = 4
            wait(4)
            humanoid.WalkSpeed = 16
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeCrates()
    for i = 1, 10 do
        local crate = Instance.new("Part")
        crate.Size = Vector3.new(2, 2, 2)
        crate.BrickColor = BrickColor.new("Brown")
        crate.Material = Enum.Material.Wood
        crate.Anchored = true
        crate.Position = Vector3.new(math.random(-50, 50), 0, math.random(-50, 50))
        crate.Parent = workspace
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.Adornee = crate
        billboard.AlwaysOnTop = true
        billboard.Parent = crate
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Text = "EPIC LOOT!"
        textLabel.Font = Enum.Font.Arcade
        textLabel.TextSize = 16
        textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Parent = billboard
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.Parent = crate
        clickDetector.MouseClick:Connect(function()
            local explosion = Instance.new("Explosion")
            explosion.BlastRadius = 5
            explosion.BlastPressure = 0
            explosion.Position = crate.Position
            explosion.Parent = workspace
            Debris:AddItem(explosion, 1)
            crate:Destroy()
            playSound("rbxassetid://9119348206")
        end)
        Debris:AddItem(crate, 10)
    end
    playSound("rbxassetid://9119348206")
end

local function fakePlayerTeleport()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for i = 1, 10 do
                rootPart.CFrame = CFrame.new(Vector3.new(math.random(-50, 50), rootPart.Position.Y, math.random(-50, 50)))
                wait(0.1)
            end
            playSound("rbxassetid://9119348206")
        end
    end
end

local function spamFakeFootprints()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = p.Character.HumanoidRootPart
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local footprint = Instance.new("Part")
                footprint.Size = Vector3.new(0.8, 0.1, 0.4)
                footprint.BrickColor = BrickColor.new("Really black")
                footprint.Material = Enum.Material.Concrete
                footprint.Anchored = true
                footprint.Position = rootPart.Position + Vector3.new(math.random(-2, 2), -1.9, math.random(-2, 2))
                footprint.Parent = workspace
                Debris:AddItem(footprint, 5)
            end)
            wait(5)
            connection:Disconnect()
        end
    end
    playSound("rbxassetid://9119348206")
end

local function anchorAllPlayers()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = p.Character.HumanoidRootPart
            targetRoot.Anchored = true
            wait(3)
            targetRoot.Anchored = false
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeBloodTrails()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = p.Character.HumanoidRootPart
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local blood = Instance.new("Part")
                blood.Size = Vector3.new(0.5, 0.1, 0.5)
                blood.BrickColor = BrickColor.new("Really red")
                blood.Material = Enum.Material.Neon
                blood.Anchored = true
                blood.Position = rootPart.Position + Vector3.new(math.random(-2, 2), -1.9, math.random(-2, 2))
                blood.Parent = workspace
                Debris:AddItem(blood, 5)
            end)
            wait(5)
            connection:Disconnect()
        end
    end
    playSound("rbxassetid://9119348206")
end

local function fakeServerMessage()
    for i = 1, 5 do
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("SERVER: EMERGENCY! MURDERER DETECTED!", "All")
        wait(0.5)
    end
    playSound("rbxassetid://9119348206")
end

local function teleportPlayersToRandom()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = p.Character.HumanoidRootPart
            targetRoot.CFrame = CFrame.new(Vector3.new(math.random(-100, 100), 0, math.random(-100, 100)))
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeWantedPosters()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 150, 0, 100)
            billboard.Adornee = head
            billboard.AlwaysOnTop = true
            billboard.Parent = p.Character
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = "WANTED!\nREWARD: " .. math.random(500, 2000) .. " COINS"
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextSize = 18
            textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            textLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            textLabel.BackgroundTransparency = 0.3
            textLabel.Parent = billboard
            Debris:AddItem(billboard, 8)
        end
    end
    playSound("rbxassetid://9119348206")
end

local function disablePlayerJump()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
            local humanoid = p.Character.Humanoid
            humanoid.JumpPower = 0
            wait(5)
            humanoid.JumpPower = 50
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeSheriffRoles()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.Adornee = head
            billboard.AlwaysOnTop = true
            billboard.Parent = p.Character
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = "SHERIFF!"
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextSize = 20
            textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Parent = billboard
            Debris:AddItem(billboard, 8)
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeMurdererRoles()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.Adornee = head
            billboard.AlwaysOnTop = true
            billboard.Parent = p.Character
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = "MURDERER!"
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextSize = 20
            textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Parent = billboard
            Debris:AddItem(billboard, 8)
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeInnocentRoles()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.Adornee = head
            billboard.AlwaysOnTop = true
            billboard.Parent = p.Character
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.Text = "INNOCENT!"
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextSize = 20
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.BackgroundTransparency = 1
            textLabel.Parent = billboard
            Debris:AddItem(billboard, 8)
        end
    end
    playSound("rbxassetid://9119348206")
end

local function teleportToHiddenSpot()
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = CFrame.new(Vector3.new(math.random(-500, 500), 100, math.random(-500, 500)))
            playSound("rbxassetid://9119348206")
        end
    end
end

local function massBlockPlayers()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = p.Character.HumanoidRootPart
            local block = Instance.new("Part")
            block.Size = Vector3.new(5, 5, 5)
            block.Transparency = 0.8
            block.Anchored = true
            block.Position = targetRoot.Position
            block.Parent = workspace
            Debris:AddItem(block, 5)
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamTrollTaunts()
    local messages = {"YOU'LL NEVER WIN!", "TROLLED AGAIN!", "CAN'T CATCH ME!", "SERVER DOMINATED!", "RUN OR CRY!"}
    for i = 1, 8 do
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(messages[math.random(1, #messages)], "All")
        wait(0.4)
    end
    playSound("rbxassetid://9119348206")
end

local function fakeRoundEnd()
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("ROUND ENDED! MURDERER WINS!", "All")
    wait(1)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("JUST KIDDING! TROLLED!", "All")
    playSound("rbxassetid://9119348206")
end

local function teleportAllToCenter()
    local center = Vector3.new(0, 0, 0)
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = p.Character.HumanoidRootPart
            targetRoot.CFrame = CFrame.new(center + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeTrapsEverywhere()
    for i = 1, 15 do
        local trap = Instance.new("Part")
        trap.Size = Vector3.new(3, 0.2, 3)
        trap.BrickColor = BrickColor.new("Dark gray")
        trap.Material = Enum.Material.Metal
        trap.Anchored = true
        trap.Position = Vector3.new(math.random(-50, 50), -1.9, math.random(-50, 50))
        trap.Parent = workspace
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.Parent = trap
        clickDetector.MouseClick:Connect(function()
            local explosion = Instance.new("Explosion")
            explosion.BlastRadius = 5
            explosion.BlastPressure = 0
            explosion.Position = trap.Position
            explosion.Parent = workspace
            Debris:AddItem(explosion, 1)
            trap:Destroy()
            playSound("rbxassetid://9119348206")
        end)
        Debris:AddItem(trap, 10)
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeCoinMagnets()
    for i = 1, 10 do
        local magnet = Instance.new("Part")
        magnet.Size = Vector3.new(1, 1, 1)
        magnet.BrickColor = BrickColor.new("Gold")
        magnet.Material = Enum.Material.Neon
        magnet.Anchored = true
        magnet.Position = Vector3.new(math.random(-50, 50), 3, math.random(-50, 50))
        magnet.Parent = workspace
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.Parent = magnet
        clickDetector.MouseClick:Connect(function()
            magnet:Destroy()
            playSound("rbxassetid://9119348206")
        end)
        Debris:AddItem(magnet, 10)
    end
    playSound("rbxassetid://9119348206")
end

local function massReverseControls()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
            local humanoid = p.Character.Humanoid
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if humanoid.MoveDirection.Magnitude > 0 then
                    humanoid:Move(-humanoid.MoveDirection)
                end
            end)
            wait(5)
            connection:Disconnect()
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeDeathSounds()
    for i = 1, 5 do
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://184689353"
        sound.Volume = 2
        sound.Parent = workspace
        sound:Play()
        Debris:AddItem(sound, 3)
        wait(0.5)
    end
end

local function teleportPlayersToSky()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = p.Character.HumanoidRootPart
            targetRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 100, 0)
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeObjectivesEverywhere()
    for i = 1, 15 do
        local marker = Instance.new("Part")
        marker.Size = Vector3.new(1, 1, 1)
        marker.BrickColor = BrickColor.new("Bright yellow")
        marker.Material = Enum.Material.Neon
        marker.Anchored = true
        marker.Position = Vector3.new(math.random(-100, 100), 3, math.random(-100, 100))
        marker.Parent = workspace
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.Adornee = marker
        billboard.AlwaysOnTop = true
        billboard.Parent = marker
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Text = "HIDDEN OBJECTIVE!"
        textLabel.Font = Enum.Font.Arcade
        textLabel.TextSize = 16
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Parent = billboard
        Debris:AddItem(marker, 8)
    end
    playSound("rbxassetid://9119348206")
end

local function massFakePlayerDeaths()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = p.Character.HumanoidRootPart
            local explosion = Instance.new("Explosion")
            explosion.BlastRadius = 5
            explosion.BlastPressure = 0
            explosion.Position = rootPart.Position
            explosion.Parent = workspace
            Debris:AddItem(explosion, 1)
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeRoleAnnouncements()
    local roles = {"MURDERER DETECTED!", "SHERIFF SPOTTED!", "INNOCENT IN DANGER!"}
    for i = 1, 8 do
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("SERVER: " .. roles[math.random(1, #roles)], "All")
        wait(0.4)
    end
    playSound("rbxassetid://9119348206")
end

local function teleportPlayersToCorners()
    local corners = {
        Vector3.new(100, 0, 100),
        Vector3.new(-100, 0, 100),
        Vector3.new(100, 0, -100),
        Vector3.new(-100, 0, -100)
    }
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = p.Character.HumanoidRootPart
            targetRoot.CFrame = CFrame.new(corners[math.random(1, #corners)])
        end
    end
    playSound("rbxassetid://9119348206")
end

local function spamFakeCoinDrops()
    for i = 1, 20 do
        local coin = Instance.new("Part")
        coin.Size = Vector3.new(0.5, 0.5, 0.5)
        coin.BrickColor = BrickColor.new("Gold")
        coin.Material = Enum.Material.Neon
        coin.Anchored = false
        coin.Position = Vector3.new(math.random(-50, 50), 0, math.random(-50, 50))
        coin.Parent = workspace
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.Parent = coin
        clickDetector.MouseClick:Connect(function()
            coin:Destroy()
            playSound("rbxassetid://9119348206")
        end)
        Debris:AddItem(coin, 8)
    end
    playSound("rbxassetid://9119348206")
end

createButton("TeleportToPlayerButton", "Teleport to Player", teleportToPlayer)
createButton("StickToPlayerButton", "Stick to Player", stickToPlayer)
createButton("NudgePlayerButton", "Nudge Player", nudgePlayer)
createButton("OrbitPlayerButton", "Orbit Player", orbitPlayer)
createButton("MirrorMovementButton", "Mirror Player Movement", mirrorMovement)
createButton("DropFakeGunButton", "Drop Fake Gun", dropFakeGun)
createButton("FakeMurdererIndicatorButton", "Fake Murderer Indicator", fakeMurdererIndicator)
createButton("SpamChatButton", "Spam Chat", spamChat)
createButton("FakeCoinDropButton", "Fake Coin Drop", fakeCoinDrop)
createButton("TeleportSpamButton", "Teleport Spam", teleportSpam)
createButton("SpeedBoostButton", "Speed Boost", addSpeedBoost)