local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local AnimationChanger = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Minimize = Instance.new("ImageButton")
local Title = Instance.new("TextLabel")
local TabButtons = Instance.new("Frame")
local AnimTabBtn = Instance.new("TextButton")
local FuncTabBtn = Instance.new("TextButton")
local Tabs = Instance.new("Frame")
local AnimationsTab = Instance.new("Frame")
local Category = Instance.new("TextLabel")
local Buttons = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local A_Zombie = Instance.new("TextButton")
local A_Levitation = Instance.new("TextButton")
local A_Vampire = Instance.new("TextButton")
local FunctionsTab = Instance.new("Frame")
local FuncCategory = Instance.new("TextLabel")
local FuncButtons = Instance.new("ScrollingFrame")
local FuncListLayout = Instance.new("UIListLayout")

AnimationChanger.Name = "AnimationChangerPro"
AnimationChanger.Parent = game:GetService("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AnimationChanger.ResetOnSpawn = false

Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.35, 0, -1, 0)
Main.Size = UDim2.new(0, 200, 0, 0)
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = Main

local mainShadow = Instance.new("ImageLabel")
mainShadow.Name = "MainShadow"
mainShadow.Parent = Main
mainShadow.BackgroundTransparency = 1
mainShadow.Size = UDim2.new(1, 10, 1, 10)
mainShadow.Position = UDim2.new(0, -5, 0, -5)
mainShadow.Image = "rbxassetid://1316045217"
mainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
mainShadow.ImageTransparency = 0.8
mainShadow.ScaleType = Enum.ScaleType.Slice
mainShadow.SliceCenter = Rect.new(10, 10, 118, 118)
mainShadow.ZIndex = -1

TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 30)

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 10)
topBarCorner.Parent = TopBar

Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundTransparency = 1
Minimize.Position = UDim2.new(0.85, 0, 0.15, 0)
Minimize.Size = UDim2.new(0, 20, 0, 20)
Minimize.Image = "rbxassetid://3926307971"
Minimize.ImageRectOffset = Vector2.new(884, 4)
Minimize.ImageRectSize = Vector2.new(36, 36)
Minimize.ImageColor3 = Color3.fromRGB(180, 180, 180)

Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "ULTRA MENU"
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

TabButtons.Name = "TabButtons"
TabButtons.Parent = Main
TabButtons.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TabButtons.BorderSizePixel = 0
TabButtons.Position = UDim2.new(0, 0, 0, 30)
TabButtons.Size = UDim2.new(1, 0, 0, 30)

local function createTabButton(name, layoutOrder)
    local button = Instance.new("TextButton")
    button.Name = name
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(0.5, -5, 1, 0)
    button.Position = layoutOrder == 1 and UDim2.new(0, 5, 0, 0) or UDim2.new(0.5, 0, 0, 0)
    button.Font = Enum.Font.GothamMedium
    button.Text = name:upper()
    button.TextColor3 = Color3.fromRGB(180, 180, 180)
    button.TextSize = 12
    button.AutoButtonColor = false
    button.LayoutOrder = layoutOrder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        AnimationsTab.Visible = name == "Animations"
        FunctionsTab.Visible = name == "Functions"
        
        AnimTabBtn.BackgroundColor3 = name == "Animations" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(30, 30, 35)
        FuncTabBtn.BackgroundColor3 = name == "Functions" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(30, 30, 35)
        
        AnimTabBtn.TextColor3 = name == "Animations" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
        FuncTabBtn.TextColor3 = name == "Functions" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
    end)
    
    return button
end

AnimTabBtn = createTabButton("Animations", 1)
AnimTabBtn.Parent = TabButtons
AnimTabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
AnimTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

FuncTabBtn = createTabButton("Functions", 2)
FuncTabBtn.Parent = TabButtons

Tabs.Name = "Tabs"
Tabs.Parent = Main
Tabs.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Tabs.BorderSizePixel = 0
Tabs.Position = UDim2.new(0, 0, 0, 60)
Tabs.Size = UDim2.new(1, 0, 0, 150)

AnimationsTab.Name = "AnimationsTab"
AnimationsTab.Parent = Tabs
AnimationsTab.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
AnimationsTab.BorderSizePixel = 0
AnimationsTab.Size = UDim2.new(1, 0, 1, 0)
AnimationsTab.Visible = true

Category.Name = "Category"
Category.Parent = AnimationsTab
Category.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Category.BorderSizePixel = 0
Category.Size = UDim2.new(1, 0, 0, 25)
Category.Font = Enum.Font.GothamMedium
Category.Text = "  ANIMATIONS"
Category.TextColor3 = Color3.fromRGB(0, 200, 255)
Category.TextSize = 12
Category.TextXAlignment = Enum.TextXAlignment.Left

local categoryCorner = Instance.new("UICorner")
categoryCorner.CornerRadius = UDim.new(0, 6)
categoryCorner.Parent = Category

Buttons.Name = "Buttons"
Buttons.Parent = AnimationsTab
Buttons.BackgroundTransparency = 1
Buttons.Position = UDim2.new(0, 5, 0, 30)
Buttons.Size = UDim2.new(1, -10, 1, -30)
Buttons.ScrollBarThickness = 3
Buttons.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
Buttons.CanvasSize = UDim2.new(0, 0, 0, 0)

UIListLayout.Parent = Buttons
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local function createButton(name)
    local button = Instance.new("TextButton")
    button.Name = name
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Font = Enum.Font.Gotham
    button.Text = name:upper()
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.TextSize = 13
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(60, 60, 65)
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Thickness = 1
    stroke.Parent = button
    
    local hoverTween
    local clickTween
    
    button.MouseEnter:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 50),
            TextColor3 = Color3.fromRGB(240, 240, 240)
        })
        hoverTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            TextColor3 = Color3.fromRGB(220, 220, 220)
        })
        hoverTween:Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        if clickTween then clickTween:Cancel() end
        clickTween = TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 30),
            Size = UDim2.new(0.98, 0, 0, 28)
        })
        clickTween:Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        if clickTween then clickTween:Cancel() end
        clickTween = TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 50),
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
        effect.ZIndex = 2
        effect.Parent = button
        
        local effectCorner = Instance.new("UICorner")
        effectCorner.CornerRadius = UDim.new(1, 0)
        effectCorner.Parent = effect
        
        local growTween = TweenService:Create(effect, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        })
        growTween:Play()
        
        growTween.Completed:Connect(function()
            effect:Destroy()
        end)
    end)
    
    return button
end

A_Zombie = createButton("Zombie")
A_Zombie.Parent = Buttons
A_Zombie.LayoutOrder = 1

A_Levitation = createButton("Levitation")
A_Levitation.Parent = Buttons
A_Levitation.LayoutOrder = 2

A_Vampire = createButton("Vampire")
A_Vampire.Parent = Buttons
A_Vampire.LayoutOrder = 3

FunctionsTab.Name = "FunctionsTab"
FunctionsTab.Parent = Tabs
FunctionsTab.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
FunctionsTab.BorderSizePixel = 0
FunctionsTab.Size = UDim2.new(1, 0, 1, 0)
FunctionsTab.Visible = false

FuncCategory.Name = "FuncCategory"
FuncCategory.Parent = FunctionsTab
FuncCategory.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
FuncCategory.BorderSizePixel = 0
FuncCategory.Size = UDim2.new(1, 0, 0, 25)
FuncCategory.Font = Enum.Font.GothamMedium
FuncCategory.Text = "  VISUAL FUNCTIONS"
FuncCategory.TextColor3 = Color3.fromRGB(0, 200, 255)
FuncCategory.TextSize = 12
FuncCategory.TextXAlignment = Enum.TextXAlignment.Left

local funcCategoryCorner = Instance.new("UICorner")
funcCategoryCorner.CornerRadius = UDim.new(0, 6)
funcCategoryCorner.Parent = FuncCategory

FuncButtons.Name = "FuncButtons"
FuncButtons.Parent = FunctionsTab
FuncButtons.BackgroundTransparency = 1
FuncButtons.Position = UDim2.new(0, 5, 0, 30)
FuncButtons.Size = UDim2.new(1, -10, 1, -30)
FuncButtons.ScrollBarThickness = 3
FuncButtons.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
FuncButtons.CanvasSize = UDim2.new(0, 0, 0, 0)

FuncListLayout.Parent = FuncButtons
FuncListLayout.SortOrder = Enum.SortOrder.LayoutOrder
FuncListLayout.Padding = UDim.new(0, 5)

local function createToggle(name, defaultState)
    local toggle = Instance.new("TextButton")
    toggle.Name = name
    toggle.BackgroundColor3 = defaultState and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(35, 35, 40)
    toggle.BorderSizePixel = 0
    toggle.Size = UDim2.new(1, 0, 0, 30)
    toggle.Font = Enum.Font.Gotham
    toggle.Text = name:upper()
    toggle.TextColor3 = Color3.fromRGB(220, 220, 220)
    toggle.TextSize = 13
    toggle.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggle
    
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = defaultState and Color3.fromRGB(0, 180, 230) or Color3.fromRGB(60, 60, 65)
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Thickness = 1
    stroke.Parent = toggle
    
    local state = defaultState or false
    
    local function updateToggle()
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(35, 35, 40)
        stroke.Color = state and Color3.fromRGB(0, 180, 230) or Color3.fromRGB(60, 60, 65)
    end
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        
        local effect = Instance.new("Frame")
        effect.Name = "ClickEffect"
        effect.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        effect.BackgroundTransparency = 0.7
        effect.Size = UDim2.new(0, 0, 0, 0)
        effect.Position = UDim2.new(0.5, 0, 0.5, 0)
        effect.AnchorPoint = Vector2.new(0.5, 0.5)
        effect.ZIndex = 2
        effect.Parent = toggle
        
        local effectCorner = Instance.new("UICorner")
        effectCorner.CornerRadius = UDim.new(1, 0)
        effectCorner.Parent = effect
        
        local growTween = TweenService:Create(effect, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        })
        growTween:Play()
        
        growTween.Completed:Connect(function()
            effect:Destroy()
        end)
    end)
    
    return toggle, function() return state end
end

local BlackSkyToggle, getBlackSkyState = createToggle("Black Sky", false)
BlackSkyToggle.Parent = FuncButtons
BlackSkyToggle.LayoutOrder = 1

local NoFogToggle, getNoFogState = createToggle("Remove Fog", false)
NoFogToggle.Parent = FuncButtons
NoFogToggle.LayoutOrder = 2

local BrightNightToggle, getBrightNightState = createToggle("Bright Night", false)
BrightNightToggle.Parent = FuncButtons
BrightNightToggle.LayoutOrder = 3

local NoShadowsToggle, getNoShadowsState = createToggle("No Shadows", false)
NoShadowsToggle.Parent = FuncButtons
NoShadowsToggle.LayoutOrder = 4

local SaturationToggle, getSaturationState = createToggle("High Saturation", false)
SaturationToggle.Parent = FuncButtons
SaturationToggle.LayoutOrder = 5

local NoCloudsToggle, getNoCloudsState = createToggle("No Clouds", false)
NoCloudsToggle.Parent = FuncButtons
NoCloudsToggle.LayoutOrder = 6

local DarkWaterToggle, getDarkWaterState = createToggle("Dark Water", false)
DarkWaterToggle.Parent = FuncButtons
DarkWaterToggle.LayoutOrder = 7

local NoAmbientToggle, getNoAmbientState = createToggle("No Ambient", false)
NoAmbientToggle.Parent = FuncButtons
NoAmbientToggle.LayoutOrder = 8

local FullbrightToggle, getFullbrightState = createToggle("Fullbright", false)
FullbrightToggle.Parent = FuncButtons
FullbrightToggle.LayoutOrder = 9

local ColorCorrectionToggle, getColorCorrectionState = createToggle("Color Correction", false)
ColorCorrectionToggle.Parent = FuncButtons
ColorCorrectionToggle.LayoutOrder = 10

local originalLighting = {
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    FogColor = Lighting.FogColor,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ColorShift_Top = Lighting.ColorShift_Top,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    SunRays = Lighting.SunRays.Intensity,
    Atmosphere = Lighting.Atmosphere.Density,
    ClockTime = Lighting.ClockTime
}

local colorCorrection
local function updateVisualEffects()
    if getBlackSkyState() then
        Lighting.Sky.SkyboxBk = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxDn = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxFt = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxLf = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxRt = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxUp = "rbxassetid://7018684000"
    else
        Lighting.Sky.SkyboxBk = originalLighting.SkyboxBk
        Lighting.Sky.SkyboxDn = originalLighting.SkyboxDn
        Lighting.Sky.SkyboxFt = originalLighting.SkyboxFt
        Lighting.Sky.SkyboxLf = originalLighting.SkyboxLf
        Lighting.Sky.SkyboxRt = originalLighting.SkyboxRt
        Lighting.Sky.SkyboxUp = originalLighting.SkyboxUp
    end
    
    if getNoFogState() then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = originalLighting.FogEnd
    end
    
    if getBrightNightState() then
        Lighting.ClockTime = 0
        Lighting.Brightness = 2
    else
        Lighting.Brightness = originalLighting.Brightness
    end
    
    if getNoShadowsState() then
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = true
    end
    
    if getSaturationState() then
        if not colorCorrection then
            colorCorrection = Instance.new("ColorCorrectionEffect")
            colorCorrection.Parent = Lighting
        end
        colorCorrection.Saturation = 1.5
    elseif colorCorrection then
        colorCorrection.Saturation = 0
    end
    
    if getNoCloudsState() then
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("Clouds") then
                obj.Enabled = false
            end
        end
    else
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("Clouds") then
                obj.Enabled = true
            end
        end
    end
    
    if getDarkWaterState() then
        Lighting.WaterColor = Color3.fromRGB(10, 20, 30)
    else
        Lighting.WaterColor = originalLighting.WaterColor
    end
    
    if getNoAmbientState() then
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    else
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
    
    if getFullbrightState() then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end
    
    if getColorCorrectionState() then
        if not colorCorrection then
            colorCorrection = Instance.new("ColorCorrectionEffect")
            colorCorrection.Parent = Lighting
        end
        colorCorrection.Contrast = 0.2
        colorCorrection.Brightness = 0.1
    elseif colorCorrection then
        colorCorrection.Contrast = 0
        colorCorrection.Brightness = 0
    end
end

RunService.Heartbeat:Connect(updateVisualEffects)

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

local currentAnimation = nil
local minimized = false
local activeTweens = {}

local function cancelAllTweens()
    for _, tween in pairs(activeTweens) do
        tween:Cancel()
    end
    activeTweens = {}
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
    currentAnimation = animName
    local character = game.Players.LocalPlayer.Character
    if character then
        applyAnimation(character, animName)
    end
    
    local activeColor = Color3.fromRGB(0, 180, 230)
    local inactiveColor = Color3.fromRGB(35, 35, 40)
    
    A_Zombie.BackgroundColor3 = animName == "Zombie" and activeColor or inactiveColor
    A_Levitation.BackgroundColor3 = animName == "Levitation" and activeColor or inactiveColor
    A_Vampire.BackgroundColor3 = animName == "Vampire" and activeColor or inactiveColor
    
    if animName == "Zombie" then
        A_Zombie.UIStroke.Color = Color3.fromRGB(0, 150, 200)
    else
        A_Zombie.UIStroke.Color = Color3.fromRGB(60, 60, 65)
    end
    
    if animName == "Levitation" then
        A_Levitation.UIStroke.Color = Color3.fromRGB(0, 150, 200)
    else
        A_Levitation.UIStroke.Color = Color3.fromRGB(60, 60, 65)
    end
    
    if animName == "Vampire" then
        A_Vampire.UIStroke.Color = Color3.fromRGB(0, 150, 200)
    else
        A_Vampire.UIStroke.Color = Color3.fromRGB(60, 60, 65)
    end
end

local function toggleMenu()
    minimized = not minimized
    cancelAllTweens()
    
    if minimized then
        local tween = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 200, 0, 30)
        })
        table.insert(activeTweens, tween)
        tween:Play()
    else
        local tween = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 200, 0, 210)
        })
        table.insert(activeTweens, tween)
        tween:Play()
    end
    
    Minimize.ImageRectOffset = minimized and Vector2.new(844, 4) or Vector2.new(884, 4)
    
    local rotateTween = TweenService:Create(Minimize, TweenInfo.new(0.25), {
        Rotation = minimized and 180 or 0
    })
    rotateTween:Play()
end

Minimize.MouseButton1Click:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        toggleMenu()
    end
end)

A_Zombie.MouseButton1Click:Connect(function() setAnimation("Zombie") end)
A_Levitation.MouseButton1Click:Connect(function() setAnimation("Levitation") end)
A_Vampire.MouseButton1Click:Connect(function() setAnimation("Vampire") end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if currentAnimation then
        task.wait(1)
        applyAnimation(character, currentAnimation)
    end
end)

local openTween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.35, 0, 0.1, 0),
    Size = UDim2.new(0, 200, 0, 210)
})
openTween:Play()

RunService.Heartbeat:Connect(function()
    Buttons.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    FuncButtons.CanvasSize = UDim2.new(0, 0, 0, FuncListLayout.AbsoluteContentSize.Y)
end)