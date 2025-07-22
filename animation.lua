local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local AnimationChanger = Instance.new("ScreenGui")
AnimationChanger.Name = "AnimationChangerPro"
AnimationChanger.Parent = game:GetService("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AnimationChanger.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.4, 0, 0.2, 0)
Main.Size = UDim2.new(0, 200, 0, 200)
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 30)

local Minimize = Instance.new("ImageButton")
Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundTransparency = 1
Minimize.Position = UDim2.new(0.85, 0, 0.15, 0)
Minimize.Size = UDim2.new(0, 20, 0, 20)
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
Title.Text = "ANIMATION MENU"
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Parent = Main
TabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabButtons.BorderSizePixel = 0
TabButtons.Position = UDim2.new(0, 0, 0, 30)
TabButtons.Size = UDim2.new(1, 0, 0, 30)

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
FuncTabBtn.Text = "FUNCTIONS"
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
Tabs.Position = UDim2.new(0, 0, 0, 60)
Tabs.Size = UDim2.new(1, 0, 1, -60)

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
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Font = Enum.Font.Gotham
    button.Text = name:upper()
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.TextSize = 13
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
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

local A_Zombie = CreateButton("Zombie")
A_Zombie.Parent = Buttons
A_Zombie.LayoutOrder = 1

local A_Levitation = CreateButton("Levitation")
A_Levitation.Parent = Buttons
A_Levitation.LayoutOrder = 2

local A_Vampire = CreateButton("Vampire")
A_Vampire.Parent = Buttons
A_Vampire.LayoutOrder = 3

local FunctionsTab = Instance.new("Frame")
FunctionsTab.Name = "FunctionsTab"
FunctionsTab.Parent = Tabs
FunctionsTab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
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

local function CreateToggle(name)
    local toggle = Instance.new("TextButton")
    toggle.Name = name
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
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
    
    local state = false
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(0, 150, 200),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 45),
                TextColor3 = Color3.fromRGB(220, 220, 220)
            }):Play()
        end
    end)
    
    return toggle, function() return state end
end

local BlackSkyToggle, GetBlackSkyState = CreateToggle("Black Sky")
BlackSkyToggle.Parent = FuncButtons
BlackSkyToggle.LayoutOrder = 1

local NoFogToggle, GetNoFogState = CreateToggle("No Fog")
NoFogToggle.Parent = FuncButtons
NoFogToggle.LayoutOrder = 2

local BrightNightToggle, GetBrightNightState = CreateToggle("Bright Night")
BrightNightToggle.Parent = FuncButtons
BrightNightToggle.LayoutOrder = 3

local NoShadowsToggle, GetNoShadowsState = CreateToggle("No Shadows")
NoShadowsToggle.Parent = FuncButtons
NoShadowsToggle.LayoutOrder = 4

local HighSatToggle, GetHighSatState = CreateToggle("High Saturation")
HighSatToggle.Parent = FuncButtons
HighSatToggle.LayoutOrder = 5

local NoCloudsToggle, GetNoCloudsState = CreateToggle("No Clouds")
NoCloudsToggle.Parent = FuncButtons
NoCloudsToggle.LayoutOrder = 6

local DarkWaterToggle, GetDarkWaterState = CreateToggle("Dark Water")
DarkWaterToggle.Parent = FuncButtons
DarkWaterToggle.LayoutOrder = 7

local NoAmbientToggle, GetNoAmbientState = CreateToggle("No Ambient")
NoAmbientToggle.Parent = FuncButtons
NoAmbientToggle.LayoutOrder = 8

local FullbrightToggle, GetFullbrightState = CreateToggle("Fullbright")
FullbrightToggle.Parent = FuncButtons
FullbrightToggle.LayoutOrder = 9

local ColorCorrToggle, GetColorCorrState = CreateToggle("Color Correction")
ColorCorrToggle.Parent = FuncButtons
ColorCorrToggle.LayoutOrder = 10

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
    local character = game.Players.LocalPlayer.Character
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
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 30)}):Play()
        Minimize.ImageRectOffset = Vector2.new(84, 204)
    else
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 200)}):Play()
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

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if currentAnimation then
        task.wait(1)
        ApplyAnimation(character, currentAnimation)
    end
end)

RunService.Heartbeat:Connect(function()
    Buttons.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    FuncButtons.CanvasSize = UDim2.new(0, 0, 0, FuncListLayout.AbsoluteContentSize.Y)
    
    if GetBlackSkyState() then
        Lighting.Sky.SkyboxBk = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxDn = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxFt = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxLf = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxRt = "rbxassetid://7018684000"
        Lighting.Sky.SkyboxUp = "rbxassetid://7018684000"
    end
    
    if GetNoFogState() then
        Lighting.FogEnd = 100000
    end
    
    if GetBrightNightState() then
        Lighting.ClockTime = 0
        Lighting.Brightness = 2
    end
    
    if GetNoShadowsState() then
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = true
    end
    
    if GetNoCloudsState() then
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("Clouds") then
                obj.Enabled = false
            end
        end
    end
    
    if GetDarkWaterState() then
        Lighting.WaterColor = Color3.fromRGB(10, 20, 30)
    end
    
    if GetNoAmbientState() then
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    end
    
    if GetFullbrightState() then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end
end)