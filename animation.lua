local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AnimationChanger = Instance.new("ScreenGui")
AnimationChanger.Name = "UltimateVisualMenu"
AnimationChanger.Parent = game:GetService("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AnimationChanger.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.4, 0, 0.2, 0)
Main.Size = UDim2.new(0, 220, 0, 250)
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 32)

local Minimize = Instance.new("ImageButton")
Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundTransparency = 1
Minimize.Position = UDim2.new(0.85, 0, 0.15, 0)
Minimize.Size = UDim2.new(0, 22, 0, 22)
Minimize.Image = "rbxassetid://3926305904"
Minimize.ImageRectOffset = Vector2.new(124, 204)
Minimize.ImageRectSize = Vector2.new(36, 36)
Minimize.ImageColor3 = Color3.fromRGB(200, 200, 200)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "ULTIMATE VISUAL MENU"
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Parent = Main
TabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabButtons.BorderSizePixel = 0
TabButtons.Position = UDim2.new(0, 0, 0, 32)
TabButtons.Size = UDim2.new(1, 0, 0, 32)

local function CreateTabButton(name, posX)
    local button = Instance.new("TextButton")
    button.Name = name
    button.BackgroundColor3 = name == "Animations" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(40, 40, 45)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(posX, 5, 0, 5)
    button.Size = UDim2.new(0.5, -10, 1, -10)
    button.Font = Enum.Font.GothamMedium
    button.Text = name:upper()
    button.TextColor3 = name == "Animations" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
    button.TextSize = 12
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    return button
end

local AnimTabBtn = CreateTabButton("Animations", 0)
AnimTabBtn.Parent = TabButtons

local FuncTabBtn = CreateTabButton("Functions", 0.5)
FuncTabBtn.Parent = TabButtons

local Tabs = Instance.new("Frame")
Tabs.Name = "Tabs"
Tabs.Parent = Main
Tabs.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Tabs.BorderSizePixel = 0
Tabs.Position = UDim2.new(0, 0, 0, 64)
Tabs.Size = UDim2.new(1, 0, 1, -64)

local AnimationsTab = Instance.new("Frame")
AnimationsTab.Name = "AnimationsTab"
AnimationsTab.Parent = Tabs
AnimationsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
AnimationsTab.BorderSizePixel = 0
AnimationsTab.Size = UDim2.new(1, 0, 1, 0)

local Buttons = Instance.new("ScrollingFrame")
Buttons.Name = "Buttons"
Buttons.Parent = AnimationsTab
Buttons.BackgroundTransparency = 1
Buttons.BorderSizePixel = 0
Buttons.Position = UDim2.new(0, 5, 0, 5)
Buttons.Size = UDim2.new(1, -10, 1, -10)
Buttons.ScrollBarThickness = 3
Buttons.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
Buttons.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Buttons
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local function CreateAnimButton(name)
    local button = Instance.new("TextButton")
    button.Name = name
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 32)
    button.Font = Enum.Font.Gotham
    button.Text = name:upper()
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.TextSize = 13
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 65)
    stroke.Thickness = 1
    stroke.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 55),
            TextColor3 = Color3.fromRGB(240, 240, 240)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 45),
            TextColor3 = Color3.fromRGB(220, 220, 220)
        }):Play()
    end)
    
    return button
end

local A_Zombie = CreateAnimButton("Zombie")
A_Zombie.Parent = Buttons
A_Zombie.LayoutOrder = 1

local A_Levitation = CreateAnimButton("Levitation")
A_Levitation.Parent = Buttons
A_Levitation.LayoutOrder = 2

local A_Vampire = CreateAnimButton("Vampire")
A_Vampire.Parent = Buttons
A_Vampire.LayoutOrder = 3

local FunctionsTab = Instance.new("Frame")
FunctionsTab.Name = "FunctionsTab"
FunctionsTab.Parent = Tabs
FunctionsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
FunctionsTab.BorderSizePixel = 0
FunctionsTab.Size = UDim2.new(1, 0, 1, 0)
FunctionsTab.Visible = false

local FuncButtons = Instance.new("ScrollingFrame")
FuncButtons.Name = "FuncButtons"
FuncButtons.Parent = FunctionsTab
FuncButtons.BackgroundTransparency = 1
FuncButtons.BorderSizePixel = 0
FuncButtons.Position = UDim2.new(0, 5, 0, 5)
FuncButtons.Size = UDim2.new(1, -10, 1, -10)
FuncButtons.ScrollBarThickness = 3
FuncButtons.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
FuncButtons.CanvasSize = UDim2.new(0, 0, 0, 0)

local FuncListLayout = Instance.new("UIListLayout")
FuncListLayout.Parent = FuncButtons
FuncListLayout.SortOrder = Enum.SortOrder.LayoutOrder
FuncListLayout.Padding = UDim.new(0, 5)

local VisualEffects = {
    BlackSky = {Skybox = {
        Bk = "rbxassetid://7018684000", Dn = "rbxassetid://7018684000",
        Ft = "rbxassetid://7018684000", Lf = "rbxassetid://7018684000",
        Rt = "rbxassetid://7018684000", Up = "rbxassetid://7018684000"
    }},
    OriginalSky = {Skybox = Lighting.Sky:GetAttributes()},
    OriginalLighting = {
        FogEnd = Lighting.FogEnd,
        Brightness = Lighting.Brightness,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ClockTime = Lighting.ClockTime,
        WaterColor = Lighting.WaterColor
    }
}

local ActiveEffects = {
    BlackSky = false,
    NoFog = false,
    BrightNight = false,
    NoShadows = false,
    HighSaturation = false,
    NoClouds = false,
    DarkWater = false,
    NoAmbient = false,
    Fullbright = false,
    ColorCorrection = false,
    Vignette = false,
    Bloom = false,
    SunRays = false,
    DepthOfField = false,
    PlayerGlow = false,
    RainbowWorld = false,
    NightVision = false,
    Underwater = false,
    FogColor = false,
    NoParticles = false,
    CustomTime = false,
    CustomFog = false
}

local function CreateToggle(name, layoutOrder)
    local toggle = Instance.new("TextButton")
    toggle.Name = name
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    toggle.BorderSizePixel = 0
    toggle.Size = UDim2.new(1, 0, 0, 32)
    toggle.Font = Enum.Font.Gotham
    toggle.Text = name:upper()
    toggle.TextColor3 = Color3.fromRGB(220, 220, 220)
    toggle.TextSize = 13
    toggle.AutoButtonColor = false
    toggle.LayoutOrder = layoutOrder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggle
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 65)
    stroke.Thickness = 1
    stroke.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
        ActiveEffects[name] = not ActiveEffects[name]
        
        if ActiveEffects[name] then
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(0, 150, 200),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {
                Color = Color3.fromRGB(0, 180, 230)
            }):Play()
        else
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 45),
                TextColor3 = Color3.fromRGB(220, 220, 220)
            }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {
                Color = Color3.fromRGB(60, 60, 65)
            }):Play()
        end
    end)
    
    return toggle
end

local BlackSkyToggle = CreateToggle("Black Sky", 1)
BlackSkyToggle.Parent = FuncButtons

local NoFogToggle = CreateToggle("No Fog", 2)
NoFogToggle.Parent = FuncButtons

local BrightNightToggle = CreateToggle("Bright Night", 3)
BrightNightToggle.Parent = FuncButtons

local NoShadowsToggle = CreateToggle("No Shadows", 4)
NoShadowsToggle.Parent = FuncButtons

local HighSatToggle = CreateToggle("High Saturation", 5)
HighSatToggle.Parent = FuncButtons

local NoCloudsToggle = CreateToggle("No Clouds", 6)
NoCloudsToggle.Parent = FuncButtons

local DarkWaterToggle = CreateToggle("Dark Water", 7)
DarkWaterToggle.Parent = FuncButtons

local NoAmbientToggle = CreateToggle("No Ambient", 8)
NoAmbientToggle.Parent = FuncButtons

local FullbrightToggle = CreateToggle("Fullbright", 9)
FullbrightToggle.Parent = FuncButtons

local ColorCorrToggle = CreateToggle("Color Correction", 10)
ColorCorrToggle.Parent = FuncButtons

local VignetteToggle = CreateToggle("Vignette", 11)
VignetteToggle.Parent = FuncButtons

local BloomToggle = CreateToggle("Bloom", 12)
BloomToggle.Parent = FuncButtons

local SunRaysToggle = CreateToggle("Sun Rays", 13)
SunRaysToggle.Parent = FuncButtons

local DepthOfFieldToggle = CreateToggle("Depth Of Field", 14)
DepthOfFieldToggle.Parent = FuncButtons

local PlayerGlowToggle = CreateToggle("Player Glow", 15)
PlayerGlowToggle.Parent = FuncButtons

local RainbowWorldToggle = CreateToggle("Rainbow World", 16)
RainbowWorldToggle.Parent = FuncButtons

local NightVisionToggle = CreateToggle("Night Vision", 17)
NightVisionToggle.Parent = FuncButtons

local UnderwaterToggle = CreateToggle("Underwater", 18)
UnderwaterToggle.Parent = FuncButtons

local FogColorToggle = CreateToggle("Fog Color", 19)
FogColorToggle.Parent = FuncButtons

local NoParticlesToggle = CreateToggle("No Particles", 20)
NoParticlesToggle.Parent = FuncButtons

local CustomTimeToggle = CreateToggle("Custom Time", 21)
CustomTimeToggle.Parent = FuncButtons

local CustomFogToggle = CreateToggle("Custom Fog", 22)
CustomFogToggle.Parent = FuncButtons

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
local colorCorrection
local vignette
local bloom
local sunRays
local depthOfField
local characterGlow

local function ApplyAnimation(character, animName)
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

local function SetAnimation(animName)
    currentAnimation = animName
    local character = LocalPlayer.Character
    if character then
        ApplyAnimation(character, animName)
    end
    
    local activeColor = Color3.fromRGB(0, 150, 200)
    local inactiveColor = Color3.fromRGB(40, 40, 45)
    
    A_Zombie.BackgroundColor3 = animName == "Zombie" and activeColor or inactiveColor
    A_Levitation.BackgroundColor3 = animName == "Levitation" and activeColor or inactiveColor
    A_Vampire.BackgroundColor3 = animName == "Vampire" and activeColor or inactiveColor
    
    A_Zombie.TextColor3 = animName == "Zombie" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 220)
    A_Levitation.TextColor3 = animName == "Levitation" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 220)
    A_Vampire.TextColor3 = animName == "Vampire" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 220)
end

local function ToggleMenu()
    minimized = not minimized
    if minimized then
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 220, 0, 32)}):Play()
        Minimize.ImageRectOffset = Vector2.new(84, 204)
    else
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 220, 0, 250)}):Play()
        Minimize.ImageRectOffset = Vector2.new(124, 204)
    end
end

local function UpdateVisualEffects()
    if ActiveEffects["Black Sky"] then
        for part, asset in pairs(VisualEffects.BlackSky.Skybox) do
            Lighting.Sky["Skybox"..part] = asset
        end
    else
        for part, asset in pairs(VisualEffects.OriginalSky.Skybox) do
            Lighting.Sky["Skybox"..part] = asset
        end
    end
    
    if ActiveEffects["No Fog"] then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = VisualEffects.OriginalLighting.FogEnd
    end
    
    if ActiveEffects["Bright Night"] then
        Lighting.ClockTime = 0
        Lighting.Brightness = 2
    else
        Lighting.Brightness = VisualEffects.OriginalLighting.Brightness
    end
    
    if ActiveEffects["No Shadows"] then
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = true
    end
    
    if ActiveEffects["High Saturation"] then
        if not colorCorrection then
            colorCorrection = Instance.new("ColorCorrectionEffect")
            colorCorrection.Parent = Lighting
        end
        colorCorrection.Saturation = 1.5
    elseif colorCorrection then
        colorCorrection.Saturation = 0
    end
    
    if ActiveEffects["No Clouds"] then
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
    
    if ActiveEffects["Dark Water"] then
        Lighting.WaterColor = Color3.fromRGB(10, 20, 30)
    else
        Lighting.WaterColor = VisualEffects.OriginalLighting.WaterColor
    end
    
    if ActiveEffects["No Ambient"] then
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    else
        Lighting.Ambient = VisualEffects.OriginalLighting.Ambient
        Lighting.OutdoorAmbient = VisualEffects.OriginalLighting.OutdoorAmbient
    end
    
    if ActiveEffects["Fullbright"] then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end
    
    if ActiveEffects["Color Correction"] then
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
    
    if ActiveEffects["Vignette"] then
        if not vignette then
            vignette = Instance.new("VignetteEffect")
            vignette.Parent = Lighting
        end
    elseif vignette then
        vignette:Destroy()
        vignette = nil
    end
    
    if ActiveEffects["Bloom"] then
        if not bloom then
            bloom = Instance.new("BloomEffect")
            bloom.Parent = Lighting
        end
    elseif bloom then
        bloom:Destroy()
        bloom = nil
    end
    
    if ActiveEffects["Sun Rays"] then
        if not sunRays then
            sunRays = Instance.new("SunRaysEffect")
            sunRays.Parent = Lighting
        end
    elseif sunRays then
        sunRays:Destroy()
        sunRays = nil
    end
    
    if ActiveEffects["Depth Of Field"] then
        if not depthOfField then
            depthOfField = Instance.new("DepthOfFieldEffect")
            depthOfField.Parent = Lighting
        end
    elseif depthOfField then
        depthOfField:Destroy()
        depthOfField = nil
    end
    
    if ActiveEffects["Player Glow"] then
        if LocalPlayer.Character and not characterGlow then
            characterGlow = Instance.new("PointLight")
            characterGlow.Parent = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head")
            characterGlow.Range = 15
            characterGlow.Brightness = 1
            characterGlow.Color = Color3.new(1, 1, 1)
        end
    elseif characterGlow then
        characterGlow:Destroy()
        characterGlow = nil
    end
    
    if ActiveEffects["Rainbow World"] then
        Lighting.Ambient = Color3.fromHSV(tick()%5/5, 0.5, 1)
        Lighting.OutdoorAmbient = Color3.fromHSV(tick()%5/5, 0.5, 1)
    end
    
    if ActiveEffects["Night Vision"] then
        if not colorCorrection then
            colorCorrection = Instance.new("ColorCorrectionEffect")
            colorCorrection.Parent = Lighting
        end
        colorCorrection.TintColor = Color3.new(0, 0.5, 0)
        colorCorrection.Contrast = 0.5
    end
    
    if ActiveEffects["Underwater"] then
        if not depthOfField then
            depthOfField = Instance.new("DepthOfFieldEffect")
            depthOfField.Parent = Lighting
        end
        depthOfField.FarIntensity = 0.1
        depthOfField.NearIntensity = 0.5
        depthOfField.FocusDistance = 10
    end
    
    if ActiveEffects["Fog Color"] then
        Lighting.FogColor = Color3.fromHSV(tick()%5/5, 0.8, 0.8)
    end
    
    if ActiveEffects["No Particles"] then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("ParticleEmitter") then
                part.Enabled = false
            end
        end
    end
    
    if ActiveEffects["Custom Time"] then
        Lighting.ClockTime = 12
    end
    
    if ActiveEffects["Custom Fog"] then
        Lighting.FogStart = 50
        Lighting.FogEnd = 500
    end
end

Minimize.MouseButton1Click:Connect(ToggleMenu)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        ToggleMenu()
    end
end)

AnimTabBtn.MouseButton1Click:Connect(function()
    AnimationsTab.Visible = true
    FunctionsTab.Visible = false
    AnimTabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    AnimTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FuncTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    FuncTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

FuncTabBtn.MouseButton1Click:Connect(function()
    AnimationsTab.Visible = false
    FunctionsTab.Visible = true
    FuncTabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    FuncTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AnimTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    AnimTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

A_Zombie.MouseButton1Click:Connect(function() SetAnimation("Zombie") end)
A_Levitation.MouseButton1Click:Connect(function() SetAnimation("Levitation") end)
A_Vampire.MouseButton1Click:Connect(function() SetAnimation("Vampire") end)

LocalPlayer.CharacterAdded:Connect(function(character)
    if currentAnimation then
        task.wait(1)
        ApplyAnimation(character, currentAnimation)
    end
    if ActiveEffects["Player Glow"] then
        characterGlow = Instance.new("PointLight")
        characterGlow.Parent = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
        characterGlow.Range = 15
        characterGlow.Brightness = 1
        characterGlow.Color = Color3.new(1, 1, 1)
    end
end)

RunService.Heartbeat:Connect(function()
    Buttons.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    FuncButtons.CanvasSize = UDim2.new(0, 0, 0, FuncListLayout.AbsoluteContentSize.Y)
    UpdateVisualEffects()
end)