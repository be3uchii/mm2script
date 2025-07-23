local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local DataStoreService = game:GetService("DataStoreService")

local AnimationChanger = Instance.new("ScreenGui")
AnimationChanger.Name = "AnimationChanger"
AnimationChanger.Parent = game:GetService("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AnimationChanger.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.4, 0, -1, 0)
Main.Size = UDim2.new(0, 180, 0, 0)
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 28)

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 8)
topBarCorner.Parent = TopBar

local Minimize = Instance.new("ImageButton")
Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundTransparency = 1
Minimize.Position = UDim2.new(0.85, 0, 0.15, 0)
Minimize.Size = UDim2.new(0, 20, 0, 20)
Minimize.Image = "rbxassetid://3926305904"
Minimize.ImageRectOffset = Vector2.new(124, 204)
Minimize.ImageRectSize = Vector2.new(36, 36)
Minimize.ImageColor3 = Color3.fromRGB(180, 180, 180)

local Close = Instance.new("ImageButton")
Close.Name = "Close"
Close.Parent = TopBar
Close.BackgroundTransparency = 1
Close.Position = UDim2.new(0.70, 0, 0.15, 0)
Close.Size = UDim2.new(0, 20, 0, 20)
Close.Image = "rbxassetid://3926305904"
Close.ImageRectOffset = Vector2.new(964, 244)
Close.ImageRectSize = Vector2.new(36, 36)
Close.ImageColor3 = Color3.fromRGB(180, 180, 180)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0.65, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "ANIMATIONS"
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local Tab = Instance.new("Frame")
Tab.Name = "Tab"
Tab.Parent = Main
Tab.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Tab.BorderSizePixel = 0
Tab.Position = UDim2.new(0, 0, 0, 28)
Tab.Size = UDim2.new(1, 0, 0, 182)
Tab.ClipsDescendants = true

local Category = Instance.new("TextLabel")
Category.Name = "Category"
Category.Parent = Tab
Category.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Category.BorderSizePixel = 0
Category.Size = UDim2.new(1, 0, 0, 24)
Category.Font = Enum.Font.GothamMedium
Category.Text = "  SELECT ANIMATION"
Category.TextColor3 = Color3.fromRGB(0, 200, 255)
Category.TextSize = 12
Category.TextXAlignment = Enum.TextXAlignment.Left

local categoryCorner = Instance.new("UICorner")
categoryCorner.CornerRadius = UDim.new(0, 6)
categoryCorner.Parent = Category

local Buttons = Instance.new("ScrollingFrame")
Buttons.Name = "Buttons"
Buttons.Parent = Tab
Buttons.BackgroundTransparency = 1
Buttons.Position = UDim2.new(0, 5, 0, 28)
Buttons.Size = UDim2.new(1, -10, 1, -58)
Buttons.ScrollBarThickness = 3
Buttons.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
Buttons.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Buttons
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local StatsFrame = Instance.new("Frame")
StatsFrame.Name = "StatsFrame"
StatsFrame.Parent = Tab
StatsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
StatsFrame.BorderSizePixel = 0
StatsFrame.Position = UDim2.new(0, 0, 1, -24)
StatsFrame.Size = UDim2.new(1, 0, 0, 24)

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 6)
statsCorner.Parent = StatsFrame

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Name = "StatsLabel"
StatsLabel.Parent = StatsFrame
StatsLabel.BackgroundTransparency = 1
StatsLabel.Size = UDim2.new(1, -10, 1, 0)
StatsLabel.Position = UDim2.new(0, 5, 0, 0)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Selected: None | Total: 0"
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.TextSize = 11
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

local ResetButton = Instance.new("TextButton")
ResetButton.Name = "ResetButton"
ResetButton.Parent = Tab
ResetButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
ResetButton.BorderSizePixel = 0
ResetButton.Position = UDim2.new(0, 5, 1, -24)
ResetButton.Size = UDim2.new(0, 50, 0, 20)
ResetButton.Font = Enum.Font.Gotham
ResetButton.Text = "RESET"
ResetButton.TextColor3 = Color3.fromRGB(220, 220, 220)
ResetButton.TextSize = 11
ResetButton.AutoButtonColor = false

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = ResetButton

local resetStroke = Instance.new("UIStroke")
resetStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
resetStroke.Color = Color3.fromRGB(60, 60, 65)
resetStroke.LineJoinMode = Enum.LineJoinMode.Round
resetStroke.Thickness = 1
resetStroke.Parent = ResetButton

local ThemeToggle = Instance.new("TextButton")
ThemeToggle.Name = "ThemeToggle"
ThemeToggle.Parent = TopBar
ThemeToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
ThemeToggle.BorderSizePixel = 0
ThemeToggle.Position = UDim2.new(0.55, 0, 0.15, 0)
ThemeToggle.Size = UDim2.new(0, 20, 0, 20)
ThemeToggle.Font = Enum.Font.Gotham
ThemeToggle.Text = "🌙"
ThemeToggle.TextColor3 = Color3.fromRGB(220, 220, 220)
ThemeToggle.TextSize = 11
ThemeToggle.AutoButtonColor = false

local themeCorner = Instance.new("UICorner")
themeCorner.CornerRadius = UDim.new(0, 6)
themeCorner.Parent = ThemeToggle

local themeStroke = Instance.new("UIStroke")
themeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
themeStroke.Color = Color3.fromRGB(60, 60, 65)
themeStroke.LineJoinMode = Enum.LineJoinMode.Round
themeStroke.Thickness = 1
themeStroke.Parent = ThemeToggle

local PreviewFrame = Instance.new("Frame")
PreviewFrame.Name = "PreviewFrame"
PreviewFrame.Parent = Main
PreviewFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
PreviewFrame.BackgroundTransparency = 0.3
PreviewFrame.BorderSizePixel = 0
PreviewFrame.Position = UDim2.new(1, 5, 0, 28)
PreviewFrame.Size = UDim2.new(0, 120, 0, 80)
PreviewFrame.Visible = false

local previewCorner = Instance.new("UICorner")
previewCorner.CornerRadius = UDim.new(0, 8)
previewCorner.Parent = PreviewFrame

local Viewport = Instance.new("ViewportFrame")
Viewport.Name = "Viewport"
Viewport.Parent = PreviewFrame
Viewport.BackgroundTransparency = 1
Viewport.Size = UDim2.new(1, 0, 1, 0)
Viewport.Ambient = Color3.fromRGB(150, 150, 150)
Viewport.LightColor = Color3.fromRGB(255, 255, 255)

local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://182845418"
ClickSound.Parent = AnimationChanger
ClickSound.Volume = 0.5

local animations = {
    Zombie = {
        idle1 = "rbxassetid://616158929",
        idle2 = "rbxassetid://616160636",
        walk = "rbxassetid://616168032",
        run = "rbxassetid://616163682",
        jump = "rbxassetid://616161997",
        climb = "rbxassetid://616156119",
        fall = "rbxassetid://616157476",
        usage = 0
    },
    Levitation = {
        idle1 = "rbxassetid://616006778",
        idle2 = "rbxassetid://616008087",
        walk = "rbxassetid://616013216",
        run = "rbxassetid://616010382",
        jump = "rbxassetid://616008936",
        climb = "rbxassetid://616003713",
        fall = "rbxassetid://616005863",
        usage = 0
    },
    Vampire = {
        idle1 = "rbxassetid://1083445855",
        idle2 = "rbxassetid://1083450166",
        walk = "rbxassetid://1083473930",
        run = "rbxassetid://1083462077",
        jump = "rbxassetid://1083455352",
        climb = "rbxassetid://1083439238",
        fall = "rbxassetid://1083443587",
        usage = 0
    },
    Ninja = {
        idle1 = "rbxassetid://656117400",
        idle2 = "rbxassetid://656118341",
        walk = "rbxassetid://656121397",
        run = "rbxassetid://656118852",
        jump = "rbxassetid://656117878",
        climb = "rbxassetid://656116887",
        fall = "rbxassetid://656119721",
        usage = 0
    },
    Dance = {
        idle1 = "rbxassetid://507771019",
        idle2 = "rbxassetid://507771955",
        walk = "rbxassetid://507777623",
        run = "rbxassetid://507767714",
        jump = "rbxassetid://507765000",
        climb = "rbxassetid://507765644",
        fall = "rbxassetid://507767968",
        usage = 0
    }
}

local currentAnimation = nil
local minimized = false
local activeTweens = {}
local totalSelections = 0
local isDarkTheme = true
local playerDataStore = DataStoreService:GetDataStore("AnimationChangerPrefs")
local buttons = {}
local lastTapTime = 0
local tapThreshold = 0.3

local function savePreferences()
    local success, err = pcall(function()
        playerDataStore:SetAsync(Players.LocalPlayer.UserId, {
            CurrentAnimation = currentAnimation,
            AnimationUsage = animations,
            IsDarkTheme = isDarkTheme
        })
    end)
end

local function loadPreferences()
    local success, data = pcall(function()
        return playerDataStore:GetAsync(Players.LocalPlayer.UserId)
    end)
    if success and data then
        if data.CurrentAnimation and animations[data.CurrentAnimation] then
            currentAnimation = data.CurrentAnimation
            setAnimation(data.CurrentAnimation)
        end
        if data.AnimationUsage then
            for animName, stats in pairs(data.AnimationUsage) do
                if animations[animName] then
                    animations[animName].usage = stats.usage or 0
                    totalSelections = totalSelections + (stats.usage or 0)
                end
            end
        end
        isDarkTheme = data.IsDarkTheme ~= false
        updateTheme()
        updateStats()
    end
end

local function cancelAllTweens()
    for _, tween in pairs(activeTweens) do
        tween:Cancel()
    end
    activeTweens = {}
end

local function updateTheme()
    local bgColor = isDarkTheme and Color3.fromRGB(25, 25, 30) or Color3.fromRGB(220, 220, 220)
    local topBarColor = isDarkTheme and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(200, 200, 200)
    local categoryColor = isDarkTheme and Color3.fromRGB(35, 35, 40) or Color3.fromRGB(180, 180, 180)
    local textColor = isDarkTheme and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(30, 30, 30)
    local statsColor = isDarkTheme and Color3.fromRGB(35, 35, 40) or Color3.fromRGB(180, 180, 180)
    
    Main.BackgroundColor3 = bgColor
    TopBar.BackgroundColor3 = topBarColor
    Tab.BackgroundColor3 = bgColor
    Category.BackgroundColor3 = categoryColor
    StatsFrame.BackgroundColor3 = statsColor
    Title.TextColor3 = textColor
    Category.TextColor3 = isDarkTheme and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(0, 150, 200)
    StatsLabel.TextColor3 = textColor
    ResetButton.BackgroundColor3 = isDarkTheme and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(160, 160, 160)
    ResetButton.TextColor3 = textColor
    ThemeToggle.Text = isDarkTheme and "🌙" or "☀️"
    
    for _, button in pairs(buttons) do
        button.BackgroundColor3 = currentAnimation == button.Name and Color3.fromRGB(0, 180, 230) or (isDarkTheme and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(160, 160, 160))
        button.TextColor3 = textColor
        button.UIStroke.Color = currentAnimation == button.Name and Color3.fromRGB(0, 150, 200) or (isDarkTheme and Color3.fromRGB(60, 60, 65) or Color3.fromRGB(100, 100, 100))
    end
end

local function createButton(name, layoutOrder)
    local button = Instance.new("TextButton")
    button.Name = name
    button.BackgroundColor3 = isDarkTheme and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(160, 160, 160)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Font = Enum.Font.Gotham
    button.Text = name:upper()
    button.TextColor3 = isDarkTheme and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(30, 30, 30)
    button.TextSize = 13
    button.AutoButtonColor = false
    button.LayoutOrder = layoutOrder
    button.Parent = Buttons
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = isDarkTheme and Color3.fromRGB(60, 60, 65) or Color3.fromRGB(100, 100, 100)
    buttonStroke.LineJoinMode = Enum.LineJoinMode.Round
    buttonStroke.Thickness = 1
    buttonStroke.Parent = button
    
    local hoverTween
    local clickTween
    
    button.MouseEnter:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = isDarkTheme and Color3.fromRGB(50, 50, 55) or Color3.fromRGB(180, 180, 180),
            TextColor3 = isDarkTheme and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(20, 20, 20)
        })
        hoverTween:Play()
        
        PreviewFrame.Visible = true
        Viewport:ClearAllChildren()
        local characterModel = Players.LocalPlayer.Character and Players.LocalPlayer.Character:Clone() or Instance.new("Model")
        characterModel.Parent = Viewport
        local humanoid = characterModel:FindFirstChildOfClass("Humanoid") or Instance.new("Humanoid")
        humanoid.Parent = characterModel
        local animator = Instance.new("Animator")
        animator.Parent = humanoid
        local animation = Instance.new("Animation")
        animation.AnimationId = animations[name].idle1
        local track = humanoid:LoadAnimation(animation)
        track:Play()
        local camera = Instance.new("Camera")
        camera.CFrame = CFrame.new(Vector3.new(0, 2, 5), Vector3.new(0, 2, 0))
        Viewport.CurrentCamera = camera
    end)
    
    button.MouseLeave:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = currentAnimation == name and Color3.fromRGB(0, 180, 230) or (isDarkTheme and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(160, 160, 160)),
            TextColor3 = isDarkTheme and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(30, 30, 30)
        })
        hoverTween:Play()
        PreviewFrame.Visible = false
        Viewport:ClearAllChildren()
    end)
    
    button.MouseButton1Down:Connect(function()
        if clickTween then clickTween:Cancel() end
        clickTween = TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = isDarkTheme and Color3.fromRGB(30, 30, 35) or Color3.fromRGB(140, 140, 140),
            Size = UDim2.new(0.98, 0, 0, 28)
        })
        clickTween:Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        if clickTween then clickTween:Cancel() end
        clickTween = TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(0, 180, 230),
            Size = UDim2.new(1, 0, 0, 30)
        })
        clickTween:Play()
        
        local effect = Instance.new("Frame")
        effect.Name = "ClickEffect"
        effect.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        effect.BackgroundTransparency = 0.7
        effect.Size = UDim2.new(0, 0, 0, 0)
        effect.Position = UDim2.new(0.5, 0, 0.5, 0)
        effect.AnchorPoint = Vector2.new(0.5, 0.5)
        effect.Parent = button
        
        local effectCorner = Instance.new("UICorner")
        effectCorner.CornerRadius = UDim.new(1, 0)
        effectCorner.Parent = effect
        
        local growTween = TweenService:Create(effect, TweenInfo.new(0.3), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        })
        growTween:Play()
        
        growTween.Completed:Connect(function()
            effect:Destroy()
        end)
        
        ClickSound:Play()
        setAnimation(name)
    end)
    
    buttons[name] = button
    return button
end

local function applyAnimation(character, animName)
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local animate = character:FindFirstChild("Animate")
    if not animate then return end
    
    local animData = animations[animName]
    if not animData then return end
    
    animate.idle.Animation1.AnimationId = animData.idle1
    animate.idle.Animation2.AnimationId = animData.idle2
    animate.walk.WalkAnim.AnimationId = animData.walk
    animate.run.RunAnim.AnimationId = animData.run
    animate.jump.JumpAnim.AnimationId = animData.jump
    animate.climb.ClimbAnim.AnimationId = animData.climb
    animate.fall.FallAnim.AnimationId = animData.fall
    character.Humanoid.Jump = true
end

local function resetAnimation()
    local character = Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local animate = character:FindFirstChild("Animate")
    if not animate then return end
    
    animate.idle.Animation1.AnimationId = "rbxassetid://0"
    animate.idle.Animation2.AnimationId = "rbxassetid://0"
    animate.walk.WalkAnim.AnimationId = "rbxassetid://0"
    animate.run.RunAnim.AnimationId = "rbxassetid://0"
    animate.jump.JumpAnim.AnimationId = "rbxassetid://0"
    animate.climb.ClimbAnim.AnimationId = "rbxassetid://0"
    animate.fall.FallAnim.AnimationId = "rbxassetid://0"
    character.Humanoid.Jump = true
    
    currentAnimation = nil
    updateStats()
    savePreferences()
    
    for _, button in pairs(buttons) do
        button.BackgroundColor3 = isDarkTheme and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(160, 160, 160)
        button.UIStroke.Color = isDarkTheme and Color3.fromRGB(60, 60, 65) or Color3.fromRGB(100, 100, 100)
    end
end

local function updateStats()
    local selected = currentAnimation or "None"
    StatsLabel.Text = string.format("Selected: %s | Total: %d", selected, totalSelections)
end

local function setAnimation(animName)
    currentAnimation = animName
    local character = Players.LocalPlayer.Character
    if character then
        applyAnimation(character, animName)
    end
    
    animations[animName].usage = animations[animName].usage + 1
    totalSelections = totalSelections + 1
    updateStats()
    savePreferences()
    
    local activeColor = Color3.fromRGB(0, 180, 230)
    for _, button in pairs(buttons) do
        button.BackgroundColor3 = button.Name == animName and activeColor or (isDarkTheme and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(160, 160, 160))
        button.UIStroke.Color = button.Name == animName and Color3.fromRGB(0, 150, 200) or (isDarkTheme and Color3.fromRGB(60, 60, 65) or Color3.fromRGB(100, 100, 100))
    end
end

local function toggleMenu()
    minimized = not minimized
    cancelAllTweens()
    
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local targetSize = minimized and UDim2.new(0, 180, 0, 28) or UDim2.new(0, 180, 0, 210)
    local tween = TweenService:Create(Main, tweenInfo, {Size = targetSize})
    table.insert(activeTweens, tween)
    tween:Play()
    
    Minimize.ImageRectOffset = minimized and Vector2.new(84, 204) or Vector2.new(124, 204)
    local rotateTween = TweenService:Create(Minimize, TweenInfo.new(0.25), {Rotation = minimized and 180 or 0})
    rotateTween:Play()
    
    ClickSound:Play()
end

createButton("Zombie", 1)
createButton("Levitation", 2)
createButton("Vampire", 3)
createButton("Ninja", 4)
createButton("Dance", 5)

Minimize.MouseButton1Click:Connect(function()
    ClickSound:Play()
    toggleMenu()
end)

Close.MouseButton1Click:Connect(function()
    ClickSound:Play()
    cancelAllTweens()
    AnimationChanger.Enabled = false
end)

ResetButton.MouseButton1Click:Connect(function()
    ClickSound:Play()
    resetAnimation()
    
    local effect = Instance.new("Frame")
    effect.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    effect.BackgroundTransparency = 0.7
    effect.Size = UDim2.new(0, 0, 0, 0)
    effect.Position = UDim2.new(0.5, 0, 0.5, 0)
    effect.AnchorPoint = Vector2.new(0.5, 0.5)
    effect.Parent = ResetButton
    
    local effectCorner = Instance.new("UICorner")
    effectCorner.CornerRadius = UDim.new(1, 0)
    effectCorner.Parent = effect
    
    local growTween = TweenService:Create(effect, TweenInfo.new(0.3), {
        Size = UDim2.new(2, 0, 2, 0),
        BackgroundTransparency = 1
    })
    growTween:Play()
    
    growTween.Completed:Connect(function()
        effect:Destroy()
    end)
end)

ThemeToggle.MouseButton1Click:Connect(function()
    ClickSound:Play()
    isDarkTheme = not isDarkTheme
    updateTheme()
    savePreferences()
    
    local effect = Instance.new("Frame")
    effect.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    effect.BackgroundTransparency = 0.7
    effect.Size = UDim2.new(0, 0, 0, 0)
    effect.Position = UDim2.new(0.5, 0, 0.5, 0)
    effect.AnchorPoint = Vector2.new(0.5, 0.5)
    effect.Parent = ThemeToggle
    
    local effectCorner = Instance.new("UICorner")
    effectCorner.CornerRadius = UDim.new(1, 0)
    effectCorner.Parent = effect
    
    local growTween = TweenService:Create(effect, TweenInfo.new(0.3), {
        Size = UDim2.new(2, 0, 2, 0),
        BackgroundTransparency = 1
    })
    growTween:Play()
    
    growTween.Completed:Connect(function()
        effect:Destroy()
    end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.Begin then
        local currentTime = tick()
        if currentTime - lastTapTime < tapThreshold then
            if AnimationChanger.Enabled then
                toggleMenu()
            else
                AnimationChanger.Enabled = true
                local openTween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.4, 0, 0.15, 0),
                    Size = UDim2.new(0, 180, 0, 210)
                })
                openTween:Play()
                ClickSound:Play()
            end
        end
        lastTapTime = currentTime
    end
end)

Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if currentAnimation then
        task.wait(1)
        applyAnimation(character, currentAnimation)
    end
end)

local openTween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.4, 0, 0.15, 0),
    Size = UDim2.new(0, 180, 0, 210)
})
openTween:Play()

RunService.Heartbeat:Connect(function()
    Buttons.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)

loadPreferences()