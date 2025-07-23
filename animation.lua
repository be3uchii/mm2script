local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local AnimationChanger = Instance.new("ScreenGui")
AnimationChanger.Name = "AnimationChanger"
AnimationChanger.Parent = game:GetService("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AnimationChanger.ResetOnSpawn = false
AnimationChanger.IgnoreGuiInset = true

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.5, -150, -1, 0)
Main.Size = UDim2.new(0, 300, 0, 0)
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = Main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 65)
mainStroke.Thickness = 1
mainStroke.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 50)

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 12)
topBarCorner.Parent = TopBar

local Minimize = Instance.new("ImageButton")
Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundTransparency = 1
Minimize.Position = UDim2.new(0.93, -5, 0.5, -12)
Minimize.Size = UDim2.new(0, 24, 0, 24)
Minimize.Image = "rbxassetid://3926305904"
Minimize.ImageRectOffset = Vector2.new(124, 204)
Minimize.ImageRectSize = Vector2.new(36, 36)
Minimize.ImageColor3 = Color3.fromRGB(200, 200, 200)

local ThemeButton = Instance.new("ImageButton")
ThemeButton.Name = "ThemeButton"
ThemeButton.Parent = TopBar
ThemeButton.BackgroundTransparency = 1
ThemeButton.Position = UDim2.new(0.85, -5, 0.5, -12)
ThemeButton.Size = UDim2.new(0, 24, 0, 24)
ThemeButton.Image = "rbxassetid://3926305904"
ThemeButton.ImageRectOffset = Vector2.new(964, 764)
ThemeButton.ImageRectSize = Vector2.new(36, 36)
ThemeButton.ImageColor3 = Color3.fromRGB(200, 200, 200)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Font = Enum.Font.GothamBlack
Title.Text = "АНИМАЦИИ"
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local Tabs = Instance.new("ScrollingFrame")
Tabs.Name = "Tabs"
Tabs.Parent = Main
Tabs.BackgroundTransparency = 1
Tabs.Position = UDim2.new(0, 0, 0, 50)
Tabs.Size = UDim2.new(1, 0, 0, 40)
Tabs.CanvasSize = UDim2.new(0, 0, 0, 0)
Tabs.ScrollBarThickness = 4
Tabs.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
Tabs.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar

local TabButtons = Instance.new("UIListLayout")
TabButtons.Parent = Tabs
TabButtons.FillDirection = Enum.FillDirection.Horizontal
TabButtons.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabButtons.VerticalAlignment = Enum.VerticalAlignment.Center
TabButtons.Padding = UDim.new(0, 10)

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = Main
Content.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Content.BorderSizePixel = 0
Content.Position = UDim2.new(0, 0, 0, 90)
Content.Size = UDim2.new(1, 0, 1, -90)
Content.ClipsDescendants = true

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = Content

local AnimationsTab = Instance.new("Frame")
AnimationsTab.Name = "AnimationsTab"
AnimationsTab.Parent = Content
AnimationsTab.BackgroundTransparency = 1
AnimationsTab.Size = UDim2.new(1, 0, 1, 0)
AnimationsTab.Visible = true

local SettingsTab = Instance.new("Frame")
SettingsTab.Name = "SettingsTab"
SettingsTab.Parent = Content
SettingsTab.BackgroundTransparency = 1
SettingsTab.Size = UDim2.new(1, 0, 1, 0)
SettingsTab.Visible = false

local Category = Instance.new("TextLabel")
Category.Name = "Category"
Category.Parent = AnimationsTab
Category.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Category.BorderSizePixel = 0
Category.Size = UDim2.new(1, 0, 0, 40)
Category.Font = Enum.Font.GothamBold
Category.Text = "  ВЫБЕРИТЕ АНИМАЦИЮ"
Category.TextColor3 = Color3.fromRGB(0, 200, 255)
Category.TextSize = 16
Category.TextXAlignment = Enum.TextXAlignment.Left

local categoryCorner = Instance.new("UICorner")
categoryCorner.CornerRadius = UDim.new(0, 8)
categoryCorner.Parent = Category

local Buttons = Instance.new("ScrollingFrame")
Buttons.Name = "Buttons"
Buttons.Parent = AnimationsTab
Buttons.BackgroundTransparency = 1
Buttons.Position = UDim2.new(0, 10, 0, 50)
Buttons.Size = UDim2.new(1, -20, 1, -60)
Buttons.ScrollBarThickness = 4
Buttons.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
Buttons.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Buttons
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

local SettingsFrame = Instance.new("ScrollingFrame")
SettingsFrame.Name = "SettingsFrame"
SettingsFrame.Parent = SettingsTab
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.Position = UDim2.new(0, 10, 0, 10)
SettingsFrame.Size = UDim2.new(1, -20, 1, -20)
SettingsFrame.ScrollBarThickness = 4
SettingsFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
SettingsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Parent = SettingsFrame
SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsLayout.Padding = UDim.new(0, 10)

local themes = {
    Dark = {
        MainBg = Color3.fromRGB(25, 25, 30),
        TopBarBg = Color3.fromRGB(20, 20, 25),
        CategoryBg = Color3.fromRGB(35, 35, 40),
        ButtonBg = Color3.fromRGB(40, 40, 45),
        ButtonHover = Color3.fromRGB(50, 50, 55),
        ButtonActive = Color3.fromRGB(0, 180, 230),
        TextColor = Color3.fromRGB(230, 230, 230),
        AccentColor = Color3.fromRGB(0, 200, 255),
        StrokeColor = Color3.fromRGB(60, 60, 65),
        ThemeIcon = "rbxassetid://3926305904",
        ThemeIconOffset = Vector2.new(964, 764)
    },
    Light = {
        MainBg = Color3.fromRGB(240, 240, 245),
        TopBarBg = Color3.fromRGB(220, 220, 225),
        CategoryBg = Color3.fromRGB(200, 200, 205),
        ButtonBg = Color3.fromRGB(210, 210, 215),
        ButtonHover = Color3.fromRGB(190, 190, 195),
        ButtonActive = Color3.fromRGB(0, 160, 200),
        TextColor = Color3.fromRGB(30, 30, 35),
        AccentColor = Color3.fromRGB(0, 180, 220),
        StrokeColor = Color3.fromRGB(150, 150, 155),
        ThemeIcon = "rbxassetid://3926305904",
        ThemeIconOffset = Vector2.new(404, 364)
    }
}

local graphicsSettings = {
    Low = {
        EffectsEnabled = false,
        ShadowsEnabled = false,
        TextureQuality = Enum.MaterialQuality.Low,
        AnimationQuality = Enum.QualityLevel.Level01,
        UpdateRate = 30
    },
    Medium = {
        EffectsEnabled = true,
        ShadowsEnabled = false,
        TextureQuality = Enum.MaterialQuality.Medium,
        AnimationQuality = Enum.QualityLevel.Level05,
        UpdateRate = 60
    },
    High = {
        EffectsEnabled = true,
        ShadowsEnabled = true,
        TextureQuality = Enum.MaterialQuality.High,
        AnimationQuality = Enum.QualityLevel.Level10,
        UpdateRate = 120
    }
}

local currentTheme = "Dark"
local currentAnimation = nil
local minimized = false
local activeTweens = {}
local currentGraphics = "Medium"
local targetFPS = 60
local lastFrameTime = 0

local function createTabButton(name)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 30)
    button.BackgroundColor3 = themes[currentTheme].ButtonBg
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Text = name
    button.TextColor3 = themes[currentTheme].TextColor
    button.TextSize = 14
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = themes[currentTheme].StrokeColor
    stroke.Thickness = 1
    stroke.Parent = button
    
    button.MouseButton1Click:Connect(function()
        AnimationsTab.Visible = name == "Анимации"
        SettingsTab.Visible = name == "Настройки"
        for _, btn in pairs(Tabs:GetChildren()) do
            if btn:IsA("TextButton") then
                local tween = TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = name == btn.Text and themes[currentTheme].ButtonActive or themes[currentTheme].ButtonBg,
                    TextColor3 = themes[currentTheme].TextColor
                })
                tween:Play()
                TweenService:Create(btn.UIStroke, TweenInfo.new(0.2), {
                    Color = name == btn.Text and themes[currentTheme].AccentColor or themes[currentTheme].StrokeColor
                }):Play()
            end
        end
    end)
    
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = themes[currentTheme].ButtonHover,
            TextColor3 = themes[currentTheme].AccentColor
        })
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = button.BackgroundColor3 == themes[currentTheme].ButtonActive and themes[currentTheme].ButtonActive or themes[currentTheme].ButtonBg,
            TextColor3 = themes[currentTheme].TextColor
        })
        tween:Play()
    end)
    
    button.Parent = Tabs
    return button
end

local function createButton(name)
    local button = Instance.new("TextButton")
    button.Name = name
    button.BackgroundColor3 = themes[currentTheme].ButtonBg
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 50)
    button.Font = Enum.Font.GothamMedium
    button.Text = name:upper()
    button.TextColor3 = themes[currentTheme].TextColor
    button.TextSize = 16
    button.AutoButtonColor = false
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = themes[currentTheme].StrokeColor
    buttonStroke.Thickness = 1
    buttonStroke.Parent = button
    
    local hoverTween
    local clickTween
    
    button.MouseEnter:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = themes[currentTheme].ButtonHover,
            TextColor3 = themes[currentTheme].AccentColor
        })
        hoverTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = currentAnimation == name and themes[currentTheme].ButtonActive or themes[currentTheme].ButtonBg,
            TextColor3 = themes[currentTheme].TextColor
        })
        hoverTween:Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        if clickTween then clickTween:Cancel() end
        clickTween = TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(themes[currentTheme].ButtonActive.R * 0.8, themes[currentTheme].ButtonActive.G * 0.8, themes[currentTheme].ButtonActive.B * 0.8),
            Size = UDim2.new(0.98, 0, 0, 48)
        })
        clickTween:Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        if clickTween then clickTween:Cancel() end
        clickTween = TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = themes[currentTheme].ButtonActive,
            Size = UDim2.new(1, 0, 0, 50)
        })
        clickTween:Play()
        
        local effect = Instance.new("Frame")
        effect.BackgroundColor3 = themes[currentTheme].AccentColor
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
        
        setAnimation(name)
    end)
    
    button.Parent = Buttons
    return button
end

local function createSettingsOption(name, options, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = themes[currentTheme].ButtonBg
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, 50)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = themes[currentTheme].StrokeColor
    stroke.Thickness = 1
    stroke.Parent = frame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position = UDim2.new(0, 10, 0, 0)
    nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.Text = name
    nameLabel.TextColor3 = themes[currentTheme].TextColor
    nameLabel.TextSize = 16
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.BackgroundColor3 = themes[currentTheme].CategoryBg
    dropdown.Position = UDim2.new(0.55, 0, 0, 10)
    dropdown.Size = UDim2.new(0.4, -10, 0, 30)
    dropdown.Font = Enum.Font.GothamMedium
    dropdown.Text = options[1]
    dropdown.TextColor3 = themes[currentTheme].TextColor
    dropdown.TextSize = 14
    dropdown.AutoButtonColor = false
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdown
    
    local dropdownStroke = Instance.new("UIStroke")
    dropdownStroke.Color = themes[currentTheme].StrokeColor
    dropdownStroke.Thickness = 1
    dropdownStroke.Parent = dropdown
    
    local currentIndex = 1
    dropdown.MouseButton1Click:Connect(function()
        currentIndex = (currentIndex % #options) + 1
        dropdown.Text = options[currentIndex]
        callback(options[currentIndex])
        
        local effect = Instance.new("Frame")
        effect.BackgroundColor3 = themes[currentTheme].AccentColor
        effect.BackgroundTransparency = 0.7
        effect.Size = UDim2.new(0, 0, 0, 0)
        effect.Position = UDim2.new(0.5, 0, 0.5, 0)
        effect.AnchorPoint = Vector2.new(0.5, 0.5)
        effect.Parent = dropdown
        
        local effectCorner = Instance.new("UICorner")
        effectCorner.CornerRadius = UDim.new(1, 0)
        effectCorner.Parent = effect
        
        local growTween = TweenService:Create(effect, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        })
        growTween:Play()
        growTween.Completed:Connect(function()
            effect:Destroy()
        end)
    end)
    
    dropdown.MouseEnter:Connect(function()
        TweenService:Create(dropdown, TweenInfo.new(0.2), {
            BackgroundColor3 = themes[currentTheme].ButtonHover
        }):Play()
    end)
    
    dropdown.MouseLeave:Connect(function()
        TweenService:Create(dropdown, TweenInfo.new(0.2), {
            BackgroundColor3 = themes[currentTheme].CategoryBg
        }):Play()
    end)
    
    dropdown.Parent = frame
    frame.Parent = SettingsFrame
    return frame
end

local animations = {
    Zombie = {
        idle1 = "rbxassetid://616158929",
        idle2 = "rbxassetid://616160636",
        walk = "rbxassetid://616168032",
        run = "rbxassetid://616163682",
        jump = "rbxassetid://616161997",
        climb = "rbxassetid://616156119",
        fall = "rbxassetid://616157476"
    },
    Levitation = {
        idle1 = "rbxassetid://616006778",
        idle2 = "rbxassetid://616008087",
        walk = "rbxassetid://616013216",
        run = "rbxassetid://616010382",
        jump = "rbxassetid://616008936",
        climb = "rbxassetid://616003713",
        fall = "rbxassetid://616005863"
    },
    Vampire = {
        idle1 = "rbxassetid://1083445855",
        idle2 = "rbxassetid://1083450166",
        walk = "rbxassetid://1083473930",
        run = "rbxassetid://1083462077",
        jump = "rbxassetid://1083455352",
        climb = "rbxassetid://1083439238",
        fall = "rbxassetid://1083443587"
    }
}

local function cancelAllTweens()
    for _, tween in pairs(activeTweens) do
        tween:Cancel()
    end
    activeTweens = {}
end

local function applyTheme(theme)
    currentTheme = theme
    Main.BackgroundColor3 = themes[theme].MainBg
    TopBar.BackgroundColor3 = themes[theme].TopBarBg
    Content.BackgroundColor3 = themes[theme].MainBg
    Category.BackgroundColor3 = themes[theme].CategoryBg
    Category.TextColor3 = themes[theme].AccentColor
    Title.TextColor3 = themes[theme].TextColor
    Minimize.ImageColor3 = themes[theme].TextColor
    ThemeButton.ImageColor3 = themes[theme].TextColor
    ThemeButton.Image = themes[theme].ThemeIcon
    ThemeButton.ImageRectOffset = themes[theme].ThemeIconOffset
    mainStroke.Color = themes[theme].StrokeColor
    
    for _, button in pairs(Buttons:GetChildren()) do
        if button:IsA("TextButton") then
            button.BackgroundColor3 = currentAnimation == button.Name and themes[theme].ButtonActive or themes[theme].ButtonBg
            button.TextColor3 = themes[theme].TextColor
            button.UIStroke.Color = currentAnimation == button.Name and themes[theme].AccentColor or themes[theme].StrokeColor
        end
    end
    
    for _, tab in pairs(Tabs:GetChildren()) do
        if tab:IsA("TextButton") then
            tab.BackgroundColor3 = tab.BackgroundColor3 == themes[theme].ButtonActive and themes[theme].ButtonActive or themes[theme].ButtonBg
            tab.TextColor3 = themes[theme].TextColor
            tab.UIStroke.Color = tab.BackgroundColor3 == themes[theme].ButtonActive and themes[theme].AccentColor or themes[theme].StrokeColor
        end
    end
    
    for _, setting in pairs(SettingsFrame:GetChildren()) do
        if setting:IsA("Frame") then
            setting.BackgroundColor3 = themes[theme].ButtonBg
            setting.UIStroke.Color = themes[theme].StrokeColor
            setting:GetChildren()[1].TextColor3 = themes[theme].TextColor
            setting:GetChildren()[2].BackgroundColor3 = themes[theme].CategoryBg
            setting:GetChildren()[2].TextColor3 = themes[theme].TextColor
            setting:GetChildren()[2].UIStroke.Color = themes[theme].StrokeColor
        end
    end
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

local function setAnimation(animName)
    if currentAnimation == animName then return end
    currentAnimation = animName
    local character = Players.LocalPlayer.Character
    if character then
        applyAnimation(character, animName)
    end
    
    for _, button in pairs(Buttons:GetChildren()) do
        if button:IsA("TextButton") then
            local tween = TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = button.Name == animName and themes[currentTheme].ButtonActive or themes[currentTheme].ButtonBg,
                TextColor3 = themes[currentTheme].TextColor
            })
            tween:Play()
            TweenService:Create(button.UIStroke, TweenInfo.new(0.2), {
                Color = button.Name == animName and themes[currentTheme].AccentColor or themes[currentTheme].StrokeColor
            }):Play()
        end
    end
end

local function applyGraphicsSettings(level)
    currentGraphics = level
    local settings = graphicsSettings[level]
    
    Lighting.GlobalShadows = settings.ShadowsEnabled
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = settings.TextureQuality
        end
    end
    
    targetFPS = settings.UpdateRate
    
    local character = Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = settings.EffectsEnabled and 16 or 8
            humanoid.JumpPower = settings.EffectsEnabled and 50 or 25
        end
    end
end

local function toggleMenu()
    minimized = not minimized
    cancelAllTweens()
    
    local targetSize = minimized and UDim2.new(0, 300, 0, 50) or UDim2.new(0, 300, 0, 500)
    local targetPos = minimized and UDim2.new(0.5, -150, 0, 0) or UDim2.new(0.5, -150, 0.1, 0)
    local tween = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = targetSize,
        Position = targetPos
    })
    table.insert(activeTweens, tween)
    tween:Play()
    
    TweenService:Create(Minimize, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Rotation = minimized and 180 or 0,
        ImageRectOffset = minimized and Vector2.new(84, 204) or Vector2.new(124, 204)
    }):Play()
end

createTabButton("Анимации")
createTabButton("Настройки")

createButton("Zombie").LayoutOrder = 1
createButton("Levitation").LayoutOrder = 2
createButton("Vampire").LayoutOrder = 3

createSettingsOption("Качество графики", {"Low", "Medium", "High"}, applyGraphicsSettings)
createSettingsOption("Ограничение FPS", {"30", "60", "120"}, function(fps)
    targetFPS = tonumber(fps)
end)
createSettingsOption("Эффекты анимации", {"Вкл", "Выкл"}, function(state)
    local settings = graphicsSettings[currentGraphics]
    settings.EffectsEnabled = state == "Вкл"
    applyGraphicsSettings(currentGraphics)
end)
createSettingsOption("Тени", {"Вкл", "Выкл"}, function(state)
    local settings = graphicsSettings[currentGraphics]
    settings.ShadowsEnabled = state == "Вкл"
    applyGraphicsSettings(currentGraphics)
end)

Minimize.MouseButton1Click:Connect(toggleMenu)

ThemeButton.MouseButton1Click:Connect(function()
    local newTheme = currentTheme == "Dark" and "Light" or "Dark"
    applyTheme(newTheme)
    
    local effect = Instance.new("Frame")
    effect.BackgroundColor3 = themes[currentTheme].AccentColor
    effect.BackgroundTransparency = 0.7
    effect.Size = UDim2.new(0, 0, 0, 0)
    effect.Position = UDim2.new(0.5, 0, 0.5, 0)
    effect.AnchorPoint = Vector2.new(0.5, 0.5)
    effect.Parent = ThemeButton
    
    local effectCorner = Instance.new("UICorner")
    effectCorner.CornerRadius = UDim.new(1, 0)
    effectCorner.Parent = effect
    
    local growTween = TweenService:Create(effect, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
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
    if input.KeyCode == Enum.KeyCode.RightControl then
        toggleMenu()
    end
end)

Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if currentAnimation then
        task.wait(1)
        applyAnimation(character, currentAnimation)
    end
    applyGraphicsSettings(currentGraphics)
end)

local openTween = TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -150, 0.1, 0),
    Size = UDim2.new(0, 300, 0, 500)
})
openTween:Play()

RunService.Heartbeat:Connect(function()
    local currentTime = os.clock()
    if currentTime - lastFrameTime < 1 / targetFPS then
        return
    end
    lastFrameTime = currentTime
    
    Buttons.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    Tabs.CanvasSize = UDim2.new(0, TabButtons.AbsoluteContentSize.X, 0, 0)
    SettingsFrame.CanvasSize = UDim2.new(0, 0, 0, SettingsLayout.AbsoluteContentSize.Y)
end)