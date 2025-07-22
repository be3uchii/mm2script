local AnimationChanger = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Minimize = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local TextLabel_2 = Instance.new("TextLabel")
local NormalTab = Instance.new("Frame")
local Category = Instance.new("TextLabel")
local A_Zombie = Instance.new("TextButton")
local A_Levitation = Instance.new("TextButton")
local A_Vampire = Instance.new("TextButton")
local A_Ninja = Instance.new("TextButton")

AnimationChanger.Name = "AnimationChanger"
AnimationChanger.Parent = game:WaitForChild("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.421999991, 0, -1, 0)
Main.Size = UDim2.new(0, 250, 0, 160)
Main.Active = true
Main.Draggable = true

TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(0, 250, 0, 25)

Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
Minimize.BorderSizePixel = 0
Minimize.Position = UDim2.new(0.85, 0, 0, 0)
Minimize.Size = UDim2.new(0, 25, 0, 25)
Minimize.Font = Enum.Font.SciFi
Minimize.Text = "-"
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.TextSize = 20

TextLabel.Parent = TopBar
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0, 5, 0.5, -5)
TextLabel.Size = UDim2.new(0, 200, 0, 10)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Made by Nyser#4623"
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextSize = 12
TextLabel.TextXAlignment = Enum.TextXAlignment.Left

TextLabel_2.Parent = TopBar
TextLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel_2.BackgroundTransparency = 1
TextLabel_2.BorderSizePixel = 0
TextLabel_2.Position = UDim2.new(0, 5, 0, 0)
TextLabel_2.Size = UDim2.new(0, 200, 0, 20)
TextLabel_2.Font = Enum.Font.SourceSans
TextLabel_2.Text = "Animation Changer"
TextLabel_2.TextColor3 = Color3.new(1, 1, 1)
TextLabel_2.TextSize = 16
TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left

NormalTab.Name = "NormalTab"
NormalTab.Parent = Main
NormalTab.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
NormalTab.BorderSizePixel = 0
NormalTab.Position = UDim2.new(0, 0, 0.15625, 0)
NormalTab.Size = UDim2.new(0, 250, 0, 135)

Category.Name = "Category"
Category.Parent = NormalTab
Category.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
Category.BorderSizePixel = 0
Category.Size = UDim2.new(0, 250, 0, 25)
Category.Text = "Select Animation"
Category.TextColor3 = Color3.new(0, 0.835294, 1)
Category.TextSize = 14

A_Zombie.Name = "A_Zombie"
A_Zombie.Parent = NormalTab
A_Zombie.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Zombie.BorderSizePixel = 0
A_Zombie.Position = UDim2.new(0, 0, 0.185185179, 0)
A_Zombie.Size = UDim2.new(0, 250, 0, 25)
A_Zombie.Font = Enum.Font.SciFi
A_Zombie.Text = "Zombie"
A_Zombie.TextColor3 = Color3.new(1, 1, 1)
A_Zombie.TextSize = 16

A_Levitation.Name = "A_Levitation"
A_Levitation.Parent = NormalTab
A_Levitation.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Levitation.BorderSizePixel = 0
A_Levitation.Position = UDim2.new(0, 0, 0.370370358, 0)
A_Levitation.Size = UDim2.new(0, 250, 0, 25)
A_Levitation.Font = Enum.Font.SciFi
A_Levitation.Text = "Levitation"
A_Levitation.TextColor3 = Color3.new(1, 1, 1)
A_Levitation.TextSize = 16

A_Vampire.Name = "A_Vampire"
A_Vampire.Parent = NormalTab
A_Vampire.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Vampire.BorderSizePixel = 0
A_Vampire.Position = UDim2.new(0, 0, 0.555555582, 0)
A_Vampire.Size = UDim2.new(0, 250, 0, 25)
A_Vampire.Font = Enum.Font.SciFi
A_Vampire.Text = "Vampire"
A_Vampire.TextColor3 = Color3.new(1, 1, 1)
A_Vampire.TextSize = 16

A_Ninja.Name = "A_Ninja"
A_Ninja.Parent = NormalTab
A_Ninja.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Ninja.BorderSizePixel = 0
A_Ninja.Position = UDim2.new(0, 0, 0.740740716, 0)
A_Ninja.Size = UDim2.new(0, 250, 0, 25)
A_Ninja.Font = Enum.Font.SciFi
A_Ninja.Text = "Ninja"
A_Ninja.TextColor3 = Color3.new(1, 1, 1)
A_Ninja.TextSize = 16

local function applyAnimation(animationData)
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        local animate = character:FindFirstChild("Animate")
        if animate then
            animate.idle.Animation1.AnimationId = animationData.idle1
            animate.idle.Animation2.AnimationId = animationData.idle2
            animate.walk.WalkAnim.AnimationId = animationData.walk
            animate.run.RunAnim.AnimationId = animationData.run
            animate.jump.JumpAnim.AnimationId = animationData.jump
            animate.climb.ClimbAnim.AnimationId = animationData.climb
            animate.fall.FallAnim.AnimationId = animationData.fall
            character.Humanoid.Jump = true
        end
    end
end

local animations = {
    Zombie = {
        idle1 = "http://www.roblox.com/asset/?id=616158929",
        idle2 = "http://www.roblox.com/asset/?id=616160636",
        walk = "http://www.roblox.com/asset/?id=616168032",
        run = "http://www.roblox.com/asset/?id=616163682",
        jump = "http://www.roblox.com/asset/?id=616161997",
        climb = "http://www.roblox.com/asset/?id=616156119",
        fall = "http://www.roblox.com/asset/?id=616157476"
    },
    Levitation = {
        idle1 = "http://www.roblox.com/asset/?id=616006778",
        idle2 = "http://www.roblox.com/asset/?id=616008087",
        walk = "http://www.roblox.com/asset/?id=616013216",
        run = "http://www.roblox.com/asset/?id=616010382",
        jump = "http://www.roblox.com/asset/?id=616008936",
        climb = "http://www.roblox.com/asset/?id=616003713",
        fall = "http://www.roblox.com/asset/?id=616005863"
    },
    Vampire = {
        idle1 = "http://www.roblox.com/asset/?id=1083445855",
        idle2 = "http://www.roblox.com/asset/?id=1083450166",
        walk = "http://www.roblox.com/asset/?id=1083473930",
        run = "http://www.roblox.com/asset/?id=1083462077",
        jump = "http://www.roblox.com/asset/?id=1083455352",
        climb = "http://www.roblox.com/asset/?id=1083439238",
        fall = "http://www.roblox.com/asset/?id=1083443587"
    },
    Ninja = {
        idle1 = "http://www.roblox.com/asset/?id=656117400",
        idle2 = "http://www.roblox.com/asset/?id=656118341",
        walk = "http://www.roblox.com/asset/?id=656121766",
        run = "http://www.roblox.com/asset/?id=656118852",
        jump = "http://www.roblox.com/asset/?id=656117878",
        climb = "http://www.roblox.com/asset/?id=656114359",
        fall = "http://www.roblox.com/asset/?id=656115606"
    }
}

local currentAnimation = nil
local minimized = false

Minimize.MouseButton1Click:Connect(function()
    if minimized then
        Main:TweenSize(UDim2.new(0, 250, 0, 160))
        minimized = false
    else
        Main:TweenSize(UDim2.new(0, 250, 0, 25))
        minimized = true
    end
end)

A_Zombie.MouseButton1Click:Connect(function()
    currentAnimation = "Zombie"
    applyAnimation(animations.Zombie)
end)

A_Levitation.MouseButton1Click:Connect(function()
    currentAnimation = "Levitation"
    applyAnimation(animations.Levitation)
end)

A_Vampire.MouseButton1Click:Connect(function()
    currentAnimation = "Vampire"
    applyAnimation(animations.Vampire)
end)

A_Ninja.MouseButton1Click:Connect(function()
    currentAnimation = "Ninja"
    applyAnimation(animations.Ninja)
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if currentAnimation then
        wait(1)
        applyAnimation(animations[currentAnimation])
    end
end)

wait(1)
Main:TweenPosition(UDim2.new(0.421999991, 0, 0.28400004, 0))
