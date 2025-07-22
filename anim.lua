local AnimationChanger = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Minimize = Instance.new("ImageButton")
local Title = Instance.new("TextLabel")
local Tab = Instance.new("Frame")
local Category = Instance.new("TextLabel")
local Buttons = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local A_Zombie = Instance.new("TextButton")
local A_Levitation = Instance.new("TextButton")
local A_Vampire = Instance.new("TextButton")

AnimationChanger.Name = "AnimationChanger"
AnimationChanger.Parent = game:WaitForChild("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AnimationChanger.ResetOnSpawn = false

Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.422, 0, -1, 0)
Main.Size = UDim2.new(0, 220, 0, 170)
Main.Active = true
Main.Draggable = true

TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 30)

Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundTransparency = 1
Minimize.Position = UDim2.new(0.9, -15, 0.5, -10)
Minimize.Size = UDim2.new(0, 20, 0, 20)
Minimize.Image = "rbxassetid://3926305904"
Minimize.ImageRectOffset = Vector2.new(124, 204)
Minimize.ImageRectSize = Vector2.new(36, 36)

Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0.9, -10, 1, 0)
Title.Font = Enum.Font.GothamSemibold
Title.Text = "ANIMATION CHANGER"
Title.TextColor3 = Color3.fromRGB(200, 200, 200)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

Tab.Name = "Tab"
Tab.Parent = Main
Tab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Tab.BorderSizePixel = 0
Tab.Position = UDim2.new(0, 0, 0, 30)
Tab.Size = UDim2.new(1, 0, 1, -30)

Category.Name = "Category"
Category.Parent = Tab
Category.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Category.BorderSizePixel = 0
Category.Size = UDim2.new(1, 0, 0, 25)
Category.Font = Enum.Font.Gotham
Category.Text = "  SELECT ANIMATION"
Category.TextColor3 = Color3.fromRGB(0, 200, 255)
Category.TextSize = 12
Category.TextXAlignment = Enum.TextXAlignment.Left

Buttons.Name = "Buttons"
Buttons.Parent = Tab
Buttons.BackgroundTransparency = 1
Buttons.Position = UDim2.new(0, 0, 0, 25)
Buttons.Size = UDim2.new(1, 0, 1, -25)

UIListLayout.Parent = Buttons
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

A_Zombie.Name = "A_Zombie"
A_Zombie.Parent = Buttons
A_Zombie.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
A_Zombie.BorderSizePixel = 0
A_Zombie.Size = UDim2.new(1, -10, 0, 30)
A_Zombie.Font = Enum.Font.Gotham
A_Zombie.Text = "ZOMBIE"
A_Zombie.TextColor3 = Color3.fromRGB(200, 200, 200)
A_Zombie.TextSize = 14
A_Zombie.LayoutOrder = 1

A_Levitation.Name = "A_Levitation"
A_Levitation.Parent = Buttons
A_Levitation.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
A_Levitation.BorderSizePixel = 0
A_Levitation.Size = UDim2.new(1, -10, 0, 30)
A_Levitation.Font = Enum.Font.Gotham
A_Levitation.Text = "LEVITATION"
A_Levitation.TextColor3 = Color3.fromRGB(200, 200, 200)
A_Levitation.TextSize = 14
A_Levitation.LayoutOrder = 2

A_Vampire.Name = "A_Vampire"
A_Vampire.Parent = Buttons
A_Vampire.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
A_Vampire.BorderSizePixel = 0
A_Vampire.Size = UDim2.new(1, -10, 0, 30)
A_Vampire.Font = Enum.Font.Gotham
A_Vampire.Text = "VAMPIRE"
A_Vampire.TextColor3 = Color3.fromRGB(200, 200, 200)
A_Vampire.TextSize = 14
A_Vampire.LayoutOrder = 3

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

local function ApplyToCharacter(character, animName)
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

local function ApplyAnimation(animName)
    currentAnimation = animName
    local character = game.Players.LocalPlayer.Character
    if character then
        ApplyToCharacter(character, animName)
    end
end

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    Tab.Visible = not minimized
    Main.Size = UDim2.new(0, 220, 0, minimized and 30 or 170)
end)

A_Zombie.MouseButton1Click:Connect(function() 
    ApplyAnimation("Zombie")
    A_Zombie.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    A_Levitation.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    A_Vampire.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

A_Levitation.MouseButton1Click:Connect(function() 
    ApplyAnimation("Levitation")
    A_Zombie.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    A_Levitation.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    A_Vampire.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

A_Vampire.MouseButton1Click:Connect(function() 
    ApplyAnimation("Vampire")
    A_Zombie.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    A_Levitation.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    A_Vampire.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if currentAnimation then
        task.wait(1)
        ApplyToCharacter(character, currentAnimation)
    end
end)

task.wait(1)
Main:TweenPosition(UDim2.new(0.422, 0, 0.2, 0), "Out", "Quad", 0.5)
