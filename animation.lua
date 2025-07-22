local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AnimationChanger = Instance.new("ScreenGui")
AnimationChanger.Name = "UltimateAnimationMenu"
AnimationChanger.Parent = game:GetService("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AnimationChanger.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.35, 0, 0.1, 0)
Main.Size = UDim2.new(0, 220, 0, 250)
Main.AnchorPoint = Vector2.new(0.5, 0)
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
Title.Text = "ULTIMATE MENU"
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

local AnimTabBtn = Instance.new("TextButton")
AnimTabBtn.Name = "AnimTabBtn"
AnimTabBtn.Parent = TabButtons
AnimTabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
AnimTabBtn.BorderSizePixel = 0
AnimTabBtn.Position = UDim2.new(0, 5, 0, 5)
AnimTabBtn.Size = UDim2.new(0.5, -10, 1, -10)
AnimTabBtn.Font = Enum.Font.GothamMedium
AnimTabBtn.Text = "ANIMATIONS"
AnimTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AnimTabBtn.TextSize = 12
AnimTabBtn.AutoButtonColor = false

local FuncTabBtn = Instance.new("TextButton")
FuncTabBtn.Name = "FuncTabBtn"
FuncTabBtn.Parent = TabButtons
FuncTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
FuncTabBtn.BorderSizePixel = 0
FuncTabBtn.Position = UDim2.new(0.5, 0, 0, 5)
FuncTabBtn.Size = UDim2.new(0.5, -10, 1, -10)
FuncTabBtn.Font = Enum.Font.GothamMedium
FuncTabBtn.Text = "VISUALS"
FuncTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
FuncTabBtn.TextSize = 12
FuncTabBtn.AutoButtonColor = false

local UICorner_2 = Instance.new("UICorner")
UICorner_2.CornerRadius = UDim.new(0, 6)
UICorner_2.Parent = AnimTabBtn

local UICorner_3 = Instance.new("UICorner")
UICorner_3.CornerRadius = UDim.new(0, 6)
UICorner_3.Parent = FuncTabBtn

local Tabs = Instance.new("Frame")
Tabs.Name = "Tabs"
Tabs.Parent = Main
Tabs.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Tabs.BorderSizePixel = 0
Tabs.Position = UDim2.new(0, 0, 0, 64)
Tabs.Size = UDim2.new(1, 0, 1, -64)

local AnimationsTab = Instance.new("Frame")
AnimationsTab.Name = "AnimationsTab"
AnimationsTab.Parent = Tabs
AnimationsTab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
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

local function CreateButton(name)
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
    
    local clickEffect = Instance.new("Frame")
    clickEffect.Name = "ClickEffect"
    clickEffect.BackgroundTransparency = 1
    clickEffect.Size = UDim2.new(1, 0, 1, 0)
    clickEffect.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 55),
            TextColor3 = Color3.fromRGB(240, 240, 240)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 45),
            TextColor3 = Color3.fromRGB(220, 220, 220)
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(0.98, 0, 0, 30)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(1, 0, 0, 32)
        }):Play()
        
        local effect = Instance.new("Frame")
        effect.Name = "Ripple"
        effect.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        effect.BackgroundTransparency = 0.7
        effect.Size = UDim2.new(0, 0, 0, 0)
        effect.Position = UDim2.new(0.5, 0, 0.5, 0)
        effect.AnchorPoint = Vector2.new(0.5, 0.5)
        effect.ZIndex = 2
        effect.Parent = clickEffect
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = effect
        
        TweenService:Create(effect, TweenInfo.new(0.4), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }):Play()
        
        effect.Destroying:Once(function()
            effect:Destroy()
        end)
    end)
    
    return button
end

local A_Zombie = CreateButton("Zombie")
A_Zombie.Parent = Buttons
A_Zombie.LayoutOrder = 1

local A_Levitation = CreateButton("Levitation")
A_Levitation.Parent = Buttons
A_Levitation.LayoutOrder = 2

local A_Vampire = CreateButton("Vampire")
A_Vampire.Parent = Buttons
A_Vampire.LayoutOrder = 3

local VisualsTab = Instance.new("Frame")
VisualsTab.Name = "VisualsTab"
VisualsTab.Parent = Tabs
VisualsTab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
VisualsTab.BorderSizePixel = 0
VisualsTab.Size = UDim2.new(1, 0, 1, 0)
VisualsTab.Visible = false

local VisualsButtons = Instance.new("ScrollingFrame")
VisualsButtons.Name = "VisualsButtons"
VisualsButtons.Parent = VisualsTab
VisualsButtons.BackgroundTransparency = 1
VisualsButtons.BorderSizePixel = 0
VisualsButtons.Position = UDim2.new(0, 5, 0, 5)
VisualsButtons.Size = UDim2.new(1, -10, 1, -10)
VisualsButtons.ScrollBarThickness = 3
VisualsButtons.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
VisualsButtons.CanvasSize = UDim2.new(0, 0, 0, 0)

local VisualsListLayout = Instance.new("UIListLayout")
VisualsListLayout.Parent = VisualsButtons
VisualsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
VisualsListLayout.Padding = UDim.new(0, 5)

local function CreateVisualToggle(name)
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
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggle
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 65)
    stroke.Thickness = 1
    stroke.Parent = toggle
    
    local state = false
    local clickEffect = Instance.new("Frame")
    clickEffect.Name = "ClickEffect"
    clickEffect.BackgroundTransparency = 1
    clickEffect.Size = UDim2.new(1, 0, 1, 0)
    clickEffect.Parent = toggle
    
    local function updateToggle()
        if state then
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
    end
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        
        local effect = Instance.new("Frame")
        effect.Name = "Ripple"
        effect.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        effect.BackgroundTransparency = 0.7
        effect.Size = UDim2.new(0, 0, 0, 0)
        effect.Position = UDim2.new(0.5, 0, 0.5, 0)
        effect.AnchorPoint = Vector2.new(0.5, 0.5)
        effect.ZIndex = 2
        effect.Parent = clickEffect
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = effect
        
        TweenService:Create(effect, TweenInfo.new(0.4), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }):Play()
        
        effect.Destroying:Once(function()
            effect:Destroy()
        end)
    end)
    
    toggle.MouseButton1Down:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.1), {
            Size = UDim2.new(0.98, 0, 0, 30)
        }):Play()
    end)
    
    toggle.MouseButton1Up:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.1), {
            Size = UDim2.new(1, 0, 0, 32)
        }):Play()
    end)
    
    return toggle, function() return state end, function(newState) state = newState updateToggle() end
end

local BlackSkyToggle, GetBlackSkyState, SetBlackSkyState = CreateVisualToggle("Black Sky")
BlackSkyToggle.Parent = VisualsButtons
BlackSkyToggle.LayoutOrder = 1

local NoFogToggle, GetNoFogState, SetNoFogState = CreateVisualToggle("No Fog")
NoFogToggle.Parent = VisualsButtons
NoFogToggle.LayoutOrder = 2

local BrightNightToggle, GetBrightNightState, SetBrightNightState = CreateVisualToggle("Bright Night")
BrightNightToggle.Parent = VisualsButtons
BrightNightToggle.LayoutOrder = 3

local NoShadowsToggle, GetNoShadowsState, SetNoShadowsState = CreateVisualToggle("No Shadows")
NoShadowsToggle.Parent = VisualsButtons
NoShadowsToggle.LayoutOrder = 4

local HighSatToggle, GetHighSatState, SetHighSatState = CreateVisualToggle("High Saturation")
HighSatToggle.Parent = VisualsButtons
HighSatToggle.LayoutOrder = 5

local NoCloudsToggle, GetNoCloudsState, SetNoCloudsState = CreateVisualToggle("No Clouds")
NoCloudsToggle.Parent = VisualsButtons
NoCloudsToggle.LayoutOrder = 6

local DarkWaterToggle, GetDarkWaterState, SetDarkWaterState = CreateVisualToggle("Dark Water")
DarkWaterToggle.Parent = VisualsButtons
DarkWaterToggle.LayoutOrder = 7

local NoAmbientToggle, GetNoAmbientState, SetNoAmbientState = CreateVisualToggle("No Ambient")
NoAmbientToggle.Parent = VisualsButtons
NoAmbientToggle.LayoutOrder = 8

local FullbrightToggle, GetFullbrightState, SetFullbrightState = CreateVisualToggle("Fullbright")
FullbrightToggle.Parent = VisualsButtons
FullbrightToggle.LayoutOrder = 9

local ColorCorrToggle, GetColorCorrState, SetColorCorrState = CreateVisualToggle("Color Correction")
ColorCorrToggle.Parent = VisualsButtons
ColorCorrToggle.LayoutOrder = 10

local PlayerGlowToggle, GetPlayerGlowState, SetPlayerGlowState = CreateVisualToggle("Player Glow")
PlayerGlowToggle.Parent = VisualsButtons
PlayerGlowToggle.LayoutOrder = 11

local RainbowSkyToggle, GetRainbowSkyState, SetRainbowSkyState = CreateVisualToggle("Rainbow Sky")
RainbowSkyToggle.Parent = VisualsButtons
RainbowSkyToggle.LayoutOrder = 12

local TimeStopToggle, GetTimeStopState, SetTimeStopState = CreateVisualToggle("Time Stop")
TimeStopToggle.Parent = VisualsButtons
TimeStopToggle.LayoutOrder = 13

local originalLighting = {
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    Brightness = Lighting.Brightness,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime,
    WaterColor = Lighting.WaterColor,
    Sky = {
        SkyboxBk = Lighting.Sky.SkyboxBk,
        SkyboxDn = Lighting.Sky.SkyboxDn,
        SkyboxFt = Lighting.Sky.SkyboxFt,
        SkyboxLf = Lighting.Sky.SkyboxLf,
        SkyboxRt = Lighting.Sky.SkyboxRt,
        SkyboxUp = Lighting.Sky.SkyboxUp
    }
}

local colorCorrection
local playerGlow = {}
local rainbowHue = 0

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
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 220, 0, 32)
        }):Play()
        Minimize.ImageRectOffset = Vector2.new(84, 204)
    else
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 220, 0, 250)
        }):Play()
        Minimize.ImageRectOffset = Vector2.new(124, 204)
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
    VisualsTab.Visible = false
    AnimTabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    AnimTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FuncTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    FuncTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    
    TweenService:Create(AnimTabBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0.5, -5, 1, -10)
    }):Play()
    TweenService:Create(FuncTabBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0.5, -10, 1, -10)
    }):Play()
end)

FuncTabBtn.MouseButton1Click:Connect(function()
    AnimationsTab.Visible = false
    VisualsTab.Visible = true
    FuncTabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    FuncTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AnimTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    AnimTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    
    TweenService:Create(FuncTabBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0.5, -5, 1, -10)
    }):Play()
    TweenService:Create(AnimTabBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0.5, -10, 1, -10)
    }):Play()
end)

A_Zombie.MouseButton1Click:Connect(function() SetAnimation("Zombie") end)
A_Levitation.MouseButton1Click:Connect(function() SetAnimation("Levitation") end)
A_Vampire.MouseButton1Click:Connect(function() SetAnimation("Vampire") end)

LocalPlayer.CharacterAdded:Connect(function(character)
    if currentAnimation then
        task.wait(1)
        ApplyAnimation(character, currentAnimation)
    end
end)

local function CreatePlayerGlow(player)
    if player == LocalPlayer then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local glow = Instance.new("BoxHandleAdornment")
    glow.Name = "PlayerGlow"
    glow.Adornee = humanoidRootPart
    glow.AlwaysOnTop = true
    glow.ZIndex = 1
    glow.Size = Vector3.new(4, 7, 4)
    glow.Transparency = 0.7
    glow.Color3 = Color3.fromRGB(0, 200, 255)
    glow.Parent = humanoidRootPart
    
    playerGlow[player] = glow
    
    player.CharacterRemoving:Connect(function()
        if glow then
            glow:Destroy()
            playerGlow[player] = nil
        end
    end)
end

Players.PlayerAdded:Connect(CreatePlayerGlow)
for _, player in ipairs(Players:GetPlayers()) do
    CreatePlayerGlow(player)
end

RunService.Heartbeat:Connect(function(deltaTime)
    Buttons.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    VisualsButtons.CanvasSize = UDim2.new(0, 0, 0, VisualsListLayout.AbsoluteContentSize.Y)
    
    if GetBlackSkyState() then
        Lighting.Sky.SkyboxBk = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxDn = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxFt = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxLf = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxRt = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxUp = "rbxassetid://7018684000"
    else
        Lighting.Sky.SkyboxBk = originalLighting.Sky.SkyboxBk
        Lighting.Sky.SkyboxDn = originalLighting.Sky.SkyboxDn
        Lighting.Sky.SkyboxFt = originalLighting.Sky.SkyboxFt
        Lighting.Sky.SkyboxLf = originalLighting.Sky.SkyboxLf
        Lighting.Sky.SkyboxRt = originalLighting.Sky.SkyboxRt
        Lighting.Sky.SkyboxUp = originalLighting.Sky.SkyboxUp
    end
    
    if GetNoFogState() then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = originalLighting.FogEnd
    end
    
    if GetBrightNightState() then
        Lighting.ClockTime = 0
        Lighting.Brightness = 2
    else
        Lighting.Brightness = originalLighting.Brightness
    end
    
    if GetNoShadowsState() then
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = true
    end
    
    if GetHighSatState() then
        if not colorCorrection then
            colorCorrection = Instance.new("ColorCorrectionEffect")
            colorCorrection.Parent = Lighting
        end
        colorCorrection.Saturation = 1.5
    elseif colorCorrection then
        colorCorrection.Saturation = 0
    end
    
    if GetNoCloudsState() then
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
    
    if GetDarkWaterState() then
        Lighting.WaterColor = Color3.fromRGB(10, 20, 30)
    else
        Lighting.WaterColor = originalLighting.WaterColor
    end
    
    if GetNoAmbientState() then
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    else
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
    
    if GetFullbrightState() then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end
    
    if GetColorCorrState() then
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
    
    if GetPlayerGlowState() then
        for player, glow in pairs(playerGlow) do
            if glow and glow.Parent then
                glow.Visible = true
            end
        end
    else
        for player, glow in pairs(playerGlow) do
            if glow then
                glow.Visible = false
            end
        end
    end
    
    if GetRainbowSkyState() then
        rainbowHue = (rainbowHue + deltaTime * 30) % 360
        local color = Color3.fromHSV(rainbowHue/360, 0.7, 1)
        Lighting.Sky.SkyboxBk = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxDn = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxFt = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxLf = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxRt = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxUp = "rbxassetid://7018684000"
        Lighting.Ambient = color
        Lighting.OutdoorAmbient = color
    end
    
    if GetTimeStopState() then
        Lighting.ClockTime = Lighting.ClockTime
    end
end)