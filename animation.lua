local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AnimationChanger = Instance.new("ScreenGui")
AnimationChanger.Name = "UltimateVisualMenu"
AnimationChanger.Parent = game:GetService("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AnimationChanger.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.4, 0, 0.2, 0)
Main.Size = UDim2.new(0, 220, 0, 250)
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 30)

local Minimize = Instance.new("TextButton")
Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Minimize.BorderSizePixel = 0
Minimize.Position = UDim2.new(0.85, 0, 0, 0)
Minimize.Size = UDim2.new(0, 30, 0, 30)
Minimize.Font = Enum.Font.SciFi
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextSize = 20

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
FuncTabBtn.Text = "VISUALS"
FuncTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
FuncTabBtn.TextSize = 12
FuncTabBtn.AutoButtonColor = false

local Tabs = Instance.new("Frame")
Tabs.Name = "Tabs"
Tabs.Parent = Main
Tabs.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Tabs.BorderSizePixel = 0
Tabs.Position = UDim2.new(0, 0, 0, 60)
Tabs.Size = UDim2.new(1, 0, 1, -60)
Tabs.ClipsDescendants = true

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

local A_Zombie = Instance.new("TextButton")
A_Zombie.Name = "A_Zombie"
A_Zombie.Parent = Buttons
A_Zombie.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
A_Zombie.BorderSizePixel = 0
A_Zombie.Size = UDim2.new(1, 0, 0, 30)
A_Zombie.Font = Enum.Font.Gotham
A_Zombie.Text = "ZOMBIE"
A_Zombie.TextColor3 = Color3.fromRGB(220, 220, 220)
A_Zombie.TextSize = 13
A_Zombie.AutoButtonColor = false
A_Zombie.LayoutOrder = 1

local A_Levitation = Instance.new("TextButton")
A_Levitation.Name = "A_Levitation"
A_Levitation.Parent = Buttons
A_Levitation.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
A_Levitation.BorderSizePixel = 0
A_Levitation.Size = UDim2.new(1, 0, 0, 30)
A_Levitation.Font = Enum.Font.Gotham
A_Levitation.Text = "LEVITATION"
A_Levitation.TextColor3 = Color3.fromRGB(220, 220, 220)
A_Levitation.TextSize = 13
A_Levitation.AutoButtonColor = false
A_Levitation.LayoutOrder = 2

local A_Vampire = Instance.new("TextButton")
A_Vampire.Name = "A_Vampire"
A_Vampire.Parent = Buttons
A_Vampire.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
A_Vampire.BorderSizePixel = 0
A_Vampire.Size = UDim2.new(1, 0, 0, 30)
A_Vampire.Font = Enum.Font.Gotham
A_Vampire.Text = "VAMPIRE"
A_Vampire.TextColor3 = Color3.fromRGB(220, 220, 220)
A_Vampire.TextSize = 13
A_Vampire.AutoButtonColor = false
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

local VisualEffects = {
    BlackSky = {
        Active = false,
        Original = {
            SkyboxBk = Lighting.Sky.SkyboxBk,
            SkyboxDn = Lighting.Sky.SkyboxDn,
            SkyboxFt = Lighting.Sky.SkyboxFt,
            SkyboxLf = Lighting.Sky.SkyboxLf,
            SkyboxRt = Lighting.Sky.SkyboxRt,
            SkyboxUp = Lighting.Sky.SkyboxUp
        },
        Apply = function(self, state)
            self.Active = state
            if state then
                Lighting.Sky.SkyboxBk = "rbxassetid://7018684000"
                Lighting.Sky.SkyboxDn = "rbxassetid://7018684000"
                Lighting.Sky.SkyboxFt = "rbxassetid://7018684000"
                Lighting.Sky.SkyboxLf = "rbxassetid://7018684000"
                Lighting.Sky.SkyboxRt = "rbxassetid://7018684000"
                Lighting.Sky.SkyboxUp = "rbxassetid://7018684000"
            else
                for k,v in pairs(self.Original) do
                    Lighting.Sky[k] = v
                end
            end
        end
    },
    NoFog = {
        Active = false,
        Original = Lighting.FogEnd,
        Apply = function(self, state)
            self.Active = state
            Lighting.FogEnd = state and 100000 or self.Original
        end
    },
    BrightNight = {
        Active = false,
        Original = Lighting.Brightness,
        Apply = function(self, state)
            self.Active = state
            if state then
                Lighting.ClockTime = 0
                Lighting.Brightness = 2
            else
                Lighting.Brightness = self.Original
            end
        end
    },
    NoShadows = {
        Active = false,
        Original = Lighting.GlobalShadows,
        Apply = function(self, state)
            self.Active = state
            Lighting.GlobalShadows = not state and self.Original or false
        end
    },
    PlayerGlow = {
        Active = false,
        Lights = {},
        Apply = function(self, state)
            self.Active = state
            local character = LocalPlayer.Character
            if character then
                if state then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local light = Instance.new("PointLight")
                            light.Name = "PlayerGlow"
                            light.Brightness = 2
                            light.Range = 10
                            light.Color = Color3.fromRGB(0, 200, 255)
                            light.Parent = part
                            table.insert(self.Lights, light)
                        end
                    end
                else
                    for _, light in pairs(self.Lights) do
                        light:Destroy()
                    end
                    self.Lights = {}
                end
            end
        end
    },
    RainbowWorld = {
        Active = false,
        Apply = function(self, state)
            self.Active = state
            if state then
                coroutine.wrap(function()
                    while self.Active do
                        local hue = tick() % 6 / 6
                        Lighting.Ambient = Color3.fromHSV(hue, 0.8, 0.8)
                        Lighting.OutdoorAmbient = Color3.fromHSV((hue + 0.5) % 1, 0.8, 0.8)
                        RunService.RenderStepped:Wait()
                    end
                    Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
                    Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
                end)()
            else
                Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
                Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            end
        end
    },
    NoClouds = {
        Active = false,
        Clouds = {},
        Apply = function(self, state)
            self.Active = state
            for _, obj in pairs(Lighting:GetChildren()) do
                if obj:IsA("Clouds") then
                    if state then
                        obj.Enabled = false
                        table.insert(self.Clouds, obj)
                    else
                        obj.Enabled = true
                    end
                end
            end
        end
    },
    DarkWater = {
        Active = false,
        Original = Lighting.WaterColor,
        Apply = function(self, state)
            self.Active = state
            Lighting.WaterColor = state and Color3.fromRGB(10, 20, 30) or self.Original
        end
    },
    Fullbright = {
        Active = false,
        OriginalAmbient = Lighting.Ambient,
        OriginalOutdoor = Lighting.OutdoorAmbient,
        Apply = function(self, state)
            self.Active = state
            if state then
                Lighting.Ambient = Color3.new(1, 1, 1)
                Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            else
                Lighting.Ambient = self.OriginalAmbient
                Lighting.OutdoorAmbient = self.OriginalOutdoor
            end
        end
    },
    NightVision = {
        Active = false,
        Effect = nil,
        Apply = function(self, state)
            self.Active = state
            if state then
                if not self.Effect then
                    self.Effect = Instance.new("ColorCorrectionEffect")
                    self.Effect.Parent = Lighting
                end
                self.Effect.TintColor = Color3.fromRGB(0, 255, 0)
                self.Effect.Contrast = 0.5
                self.Effect.Brightness = 0.3
                self.Effect.Saturation = -0.5
            elseif self.Effect then
                self.Effect.TintColor = Color3.new(1, 1, 1)
                self.Effect.Contrast = 0
                self.Effect.Brightness = 0
                self.Effect.Saturation = 0
            end
        end
    },
    ThermalVision = {
        Active = false,
        Effect = nil,
        Apply = function(self, state)
            self.Active = state
            if state then
                if not self.Effect then
                    self.Effect = Instance.new("ColorCorrectionEffect")
                    self.Effect.Parent = Lighting
                end
                self.Effect.TintColor = Color3.fromRGB(255, 0, 0)
                self.Effect.Contrast = 1
                self.Effect.Brightness = 0.2
                self.Effect.Saturation = -1
            elseif self.Effect then
                self.Effect.TintColor = Color3.new(1, 1, 1)
                self.Effect.Contrast = 0
                self.Effect.Brightness = 0
                self.Effect.Saturation = 0
            end
        end
    },
    Vignette = {
        Active = false,
        Effect = nil,
        Apply = function(self, state)
            self.Active = state
            if state then
                if not self.Effect then
                    self.Effect = Instance.new("ColorCorrectionEffect")
                    self.Effect.Parent = Lighting
                    self.Effect.Name = "VignetteEffect"
                end
                self.Effect.Enabled = true
            elseif self.Effect then
                self.Effect.Enabled = false
            end
        end
    },
    Bloom = {
        Active = false,
        Effect = nil,
        Apply = function(self, state)
            self.Active = state
            if state then
                if not self.Effect then
                    self.Effect = Instance.new("BloomEffect")
                    self.Effect.Parent = Lighting
                    self.Effect.Intensity = 0.5
                    self.Effect.Size = 24
                    self.Effect.Threshold = 0.8
                end
                self.Effect.Enabled = true
            elseif self.Effect then
                self.Effect.Enabled = false
            end
        end
    },
    PlayerOutline = {
        Active = false,
        Outlines = {},
        Apply = function(self, state)
            self.Active = state
            local character = LocalPlayer.Character
            if character then
                if state then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local outline = Instance.new("SelectionBox")
                            outline.Name = "PlayerOutline"
                            outline.Adornee = part
                            outline.LineThickness = 0.05
                            outline.Color3 = Color3.fromRGB(0, 255, 255)
                            outline.Parent = part
                            table.insert(self.Outlines, outline)
                        end
                    end
                else
                    for _, outline in pairs(self.Outlines) do
                        outline:Destroy()
                    end
                    self.Outlines = {}
                end
            end
        end
    },
    TimeStop = {
        Active = false,
        Original = Lighting.ClockTime,
        Apply = function(self, state)
            self.Active = state
            if state then
                Lighting.ClockTime = 12
            else
                Lighting.ClockTime = self.Original
            end
        end
    },
    Underwater = {
        Active = false,
        Effect = nil,
        Apply = function(self, state)
            self.Active = state
            if state then
                if not self.Effect then
                    self.Effect = Instance.new("PostEffect")
                    self.Effect.Name = "UnderwaterEffect"
                    self.Effect.Parent = Lighting
                end
                self.Effect.Enabled = true
            elseif self.Effect then
                self.Effect.Enabled = false
            end
        end
    }
}

for name, effect in pairs(VisualEffects) do
    local button = Instance.new("TextButton")
    button.Name = name
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Font = Enum.Font.Gotham
    button.Text = name:gsub("(%u)(%l+)", "%1 %2"):upper()
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.TextSize = 13
    button.AutoButtonColor = false
    button.LayoutOrder = #FuncButtons:GetChildren()
    button.Parent = FuncButtons
    
    button.MouseButton1Click:Connect(function()
        effect.Active = not effect.Active
        effect:Apply(effect.Active)
        
        if effect.Active then
            button.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            button.TextColor3 = Color3.fromRGB(220, 220, 220)
        end
    end)
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
        Main.Size = UDim2.new(0, 220, 0, 30)
        Minimize.Text = "+"
        Tabs.Visible = false
    else
        Main.Size = UDim2.new(0, 220, 0, 250)
        Minimize.Text = "-"
        Tabs.Visible = true
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
    
    for name, effect in pairs(VisualEffects) do
        if effect.Active then
            effect:Apply(true)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    Buttons.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    FuncButtons.CanvasSize = UDim2.new(0, 0, 0, FuncListLayout.AbsoluteContentSize.Y)
end)