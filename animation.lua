local AnimationChanger = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Close = Instance.new("TextButton")
local Minimize = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local TextLabel_2 = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local NormalTab = Instance.new("Frame")
local Category = Instance.new("TextLabel")
local A_Astronaut = Instance.new("TextButton")
local A_Bubbly = Instance.new("TextButton")
local A_Cartoony = Instance.new("TextButton")
local A_Elder = Instance.new("TextButton")
local A_Knight = Instance.new("TextButton")
local A_Levitation = Instance.new("TextButton")
local A_Mage = Instance.new("TextButton")
local A_Ninja = Instance.new("TextButton")
local A_Pirate = Instance.new("TextButton")
local A_Robot = Instance.new("TextButton")
local A_Stylish = Instance.new("TextButton")
local A_SuperHero = Instance.new("TextButton")
local A_Toy = Instance.new("TextButton")
local A_Vampire = Instance.new("TextButton")
local A_Werewolf = Instance.new("TextButton")
local A_Zombie = Instance.new("TextButton")
local SpecialTab = Instance.new("Frame")
local Category_2 = Instance.new("TextLabel")
local A_Patrol = Instance.new("TextButton")
local A_Confident = Instance.new("TextButton")
local A_Popstar = Instance.new("TextButton")
local A_Cowboy = Instance.new("TextButton")
local A_Ghost = Instance.new("TextButton")
local A_Sneaky = Instance.new("TextButton")
local A_Princess = Instance.new("TextButton")
local OtherTab = Instance.new("Frame")
local Category_3 = Instance.new("TextLabel")
local A_None = Instance.new("TextButton")
local A_Anthro = Instance.new("TextButton")
local A_Adidas = Instance.new("TextButton")

AnimationChanger.Name = "AnimationChanger"
AnimationChanger.Parent = game:WaitForChild("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.421999991, 0, 0.28400004, 0)
Main.Size = UDim2.new(0, 300, 0, 350)
Main.Active = true
Main.Draggable = true

TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(0, 300, 0, 30)

Close.Name = "Close"
Close.Parent = TopBar
Close.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.899999976, 0, 0, 0)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Font = Enum.Font.SciFi
Close.Text = "x"
Close.TextColor3 = Color3.new(1, 0, 0.0156863)
Close.TextSize = 20

Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
Minimize.BorderSizePixel = 0
Minimize.Position = UDim2.new(0.799999952, 0, 0, 0)
Minimize.Size = UDim2.new(0, 30, 0, 30)
Minimize.Font = Enum.Font.SciFi
Minimize.Text = "_"
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.TextSize = 20

TextLabel.Parent = TopBar
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0, 0, 0.600000024, 0)
TextLabel.Size = UDim2.new(0, 270, 0, 10)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Made by Nyser#4623 | Fixed"
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextSize = 15

TextLabel_2.Parent = TopBar
TextLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel_2.BackgroundTransparency = 1
TextLabel_2.BorderSizePixel = 0
TextLabel_2.Position = UDim2.new(0, 0, -0.0266667679, 0)
TextLabel_2.Size = UDim2.new(0, 270, 0, 20)
TextLabel_2.Font = Enum.Font.SourceSans
TextLabel_2.Text = "Animation Changer"
TextLabel_2.TextColor3 = Color3.new(1, 1, 1)
TextLabel_2.TextSize = 20

ScrollingFrame.Parent = Main
ScrollingFrame.Active = true
ScrollingFrame.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0, 0, 0.119999997, 0)
ScrollingFrame.Size = UDim2.new(1, 0, 0.879999995, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollingFrame.ScrollBarThickness = 5

NormalTab.Name = "NormalTab"
NormalTab.Parent = ScrollingFrame
NormalTab.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
NormalTab.BorderSizePixel = 0
NormalTab.Position = UDim2.new(0, 0, 0, 0)
NormalTab.Size = UDim2.new(1, 0, 0, 500)

Category.Name = "Category"
Category.Parent = NormalTab
Category.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
Category.BorderSizePixel = 0
Category.Size = UDim2.new(1, 0, 0, 30)
Category.Font = Enum.Font.SourceSans
Category.Text = "Normal"
Category.TextColor3 = Color3.new(0, 0.835294, 1)
Category.TextSize = 14

A_Astronaut.Name = "A_Astronaut"
A_Astronaut.Parent = NormalTab
A_Astronaut.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Astronaut.BorderSizePixel = 0
A_Astronaut.Position = UDim2.new(0, 0, 0.06, 0)
A_Astronaut.Size = UDim2.new(1, 0, 0, 30)
A_Astronaut.Font = Enum.Font.SciFi
A_Astronaut.Text = "Astronaut"
A_Astronaut.TextColor3 = Color3.new(1, 1, 1)
A_Astronaut.TextSize = 20

A_Bubbly.Name = "A_Bubbly"
A_Bubbly.Parent = NormalTab
A_Bubbly.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Bubbly.BorderSizePixel = 0
A_Bubbly.Position = UDim2.new(0, 0, 0.12, 0)
A_Bubbly.Size = UDim2.new(1, 0, 0, 30)
A_Bubbly.Font = Enum.Font.SciFi
A_Bubbly.Text = "Bubbly"
A_Bubbly.TextColor3 = Color3.new(1, 1, 1)
A_Bubbly.TextSize = 20

A_Cartoony.Name = "A_Cartoony"
A_Cartoony.Parent = NormalTab
A_Cartoony.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Cartoony.BorderSizePixel = 0
A_Cartoony.Position = UDim2.new(0, 0, 0.18, 0)
A_Cartoony.Size = UDim2.new(1, 0, 0, 30)
A_Cartoony.Font = Enum.Font.SciFi
A_Cartoony.Text = "Cartoony"
A_Cartoony.TextColor3 = Color3.new(1, 1, 1)
A_Cartoony.TextSize = 20

A_Elder.Name = "A_Elder"
A_Elder.Parent = NormalTab
A_Elder.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Elder.BorderSizePixel = 0
A_Elder.Position = UDim2.new(0, 0, 0.24, 0)
A_Elder.Size = UDim2.new(1, 0, 0, 30)
A_Elder.Font = Enum.Font.SciFi
A_Elder.Text = "Elder"
A_Elder.TextColor3 = Color3.new(1, 1, 1)
A_Elder.TextSize = 20

A_Knight.Name = "A_Knight"
A_Knight.Parent = NormalTab
A_Knight.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Knight.BorderSizePixel = 0
A_Knight.Position = UDim2.new(0, 0, 0.30, 0)
A_Knight.Size = UDim2.new(1, 0, 0, 30)
A_Knight.Font = Enum.Font.SciFi
A_Knight.Text = "Knight"
A_Knight.TextColor3 = Color3.new(1, 1, 1)
A_Knight.TextSize = 20

A_Levitation.Name = "A_Levitation"
A_Levitation.Parent = NormalTab
A_Levitation.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Levitation.BorderSizePixel = 0
A_Levitation.Position = UDim2.new(0, 0, 0.36, 0)
A_Levitation.Size = UDim2.new(1, 0, 0, 30)
A_Levitation.Font = Enum.Font.SciFi
A_Levitation.Text = "Levitation"
A_Levitation.TextColor3 = Color3.new(1, 1, 1)
A_Levitation.TextSize = 20

A_Mage.Name = "A_Mage"
A_Mage.Parent = NormalTab
A_Mage.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Mage.BorderSizePixel = 0
A_Mage.Position = UDim2.new(0, 0, 0.42, 0)
A_Mage.Size = UDim2.new(1, 0, 0, 30)
A_Mage.Font = Enum.Font.SciFi
A_Mage.Text = "Mage"
A_Mage.TextColor3 = Color3.new(1, 1, 1)
A_Mage.TextSize = 20

A_Ninja.Name = "A_Ninja"
A_Ninja.Parent = NormalTab
A_Ninja.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Ninja.BorderSizePixel = 0
A_Ninja.Position = UDim2.new(0, 0, 0.48, 0)
A_Ninja.Size = UDim2.new(1, 0, 0, 30)
A_Ninja.Font = Enum.Font.SciFi
A_Ninja.Text = "Ninja"
A_Ninja.TextColor3 = Color3.new(1, 1, 1)
A_Ninja.TextSize = 20

A_Pirate.Name = "A_Pirate"
A_Pirate.Parent = NormalTab
A_Pirate.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Pirate.BorderSizePixel = 0
A_Pirate.Position = UDim2.new(0, 0, 0.54, 0)
A_Pirate.Size = UDim2.new(1, 0, 0, 30)
A_Pirate.Font = Enum.Font.SciFi
A_Pirate.Text = "Pirate"
A_Pirate.TextColor3 = Color3.new(1, 1, 1)
A_Pirate.TextSize = 20

A_Robot.Name = "A_Robot"
A_Robot.Parent = NormalTab
A_Robot.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Robot.BorderSizePixel = 0
A_Robot.Position = UDim2.new(0, 0, 0.60, 0)
A_Robot.Size = UDim2.new(1, 0, 0, 30)
A_Robot.Font = Enum.Font.SciFi
A_Robot.Text = "Robot"
A_Robot.TextColor3 = Color3.new(1, 1, 1)
A_Robot.TextSize = 20

A_Stylish.Name = "A_Stylish"
A_Stylish.Parent = NormalTab
A_Stylish.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Stylish.BorderSizePixel = 0
A_Stylish.Position = UDim2.new(0, 0, 0.66, 0)
A_Stylish.Size = UDim2.new(1, 0, 0, 30)
A_Stylish.Font = Enum.Font.SciFi
A_Stylish.Text = "Stylish"
A_Stylish.TextColor3 = Color3.new(1, 1, 1)
A_Stylish.TextSize = 20

A_SuperHero.Name = "A_SuperHero"
A_SuperHero.Parent = NormalTab
A_SuperHero.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_SuperHero.BorderSizePixel = 0
A_SuperHero.Position = UDim2.new(0, 0, 0.72, 0)
A_SuperHero.Size = UDim2.new(1, 0, 0, 30)
A_SuperHero.Font = Enum.Font.SciFi
A_SuperHero.Text = "SuperHero"
A_SuperHero.TextColor3 = Color3.new(1, 1, 1)
A_SuperHero.TextSize = 20

A_Toy.Name = "A_Toy"
A_Toy.Parent = NormalTab
A_Toy.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Toy.BorderSizePixel = 0
A_Toy.Position = UDim2.new(0, 0, 0.78, 0)
A_Toy.Size = UDim2.new(1, 0, 0, 30)
A_Toy.Font = Enum.Font.SciFi
A_Toy.Text = "Toy"
A_Toy.TextColor3 = Color3.new(1, 1, 1)
A_Toy.TextSize = 20

A_Vampire.Name = "A_Vampire"
A_Vampire.Parent = NormalTab
A_Vampire.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Vampire.BorderSizePixel = 0
A_Vampire.Position = UDim2.new(0, 0, 0.84, 0)
A_Vampire.Size = UDim2.new(1, 0, 0, 30)
A_Vampire.Font = Enum.Font.SciFi
A_Vampire.Text = "Vampire"
A_Vampire.TextColor3 = Color3.new(1, 1, 1)
A_Vampire.TextSize = 20

A_Werewolf.Name = "A_Werewolf"
A_Werewolf.Parent = NormalTab
A_Werewolf.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Werewolf.BorderSizePixel = 0
A_Werewolf.Position = UDim2.new(0, 0, 0.90, 0)
A_Werewolf.Size = UDim2.new(1, 0, 0, 30)
A_Werewolf.Font = Enum.Font.SciFi
A_Werewolf.Text = "Werewolf"
A_Werewolf.TextColor3 = Color3.new(1, 1, 1)
A_Werewolf.TextSize = 20

A_Zombie.Name = "A_Zombie"
A_Zombie.Parent = NormalTab
A_Zombie.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Zombie.BorderSizePixel = 0
A_Zombie.Position = UDim2.new(0, 0, 0.96, 0)
A_Zombie.Size = UDim2.new(1, 0, 0, 30)
A_Zombie.Font = Enum.Font.SciFi
A_Zombie.Text = "Zombie"
A_Zombie.TextColor3 = Color3.new(1, 1, 1)
A_Zombie.TextSize = 20

SpecialTab.Name = "SpecialTab"
SpecialTab.Parent = ScrollingFrame
SpecialTab.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
SpecialTab.BorderSizePixel = 0
SpecialTab.Position = UDim2.new(0, 0, 0, 530)
SpecialTab.Size = UDim2.new(1, 0, 0, 300)

Category_2.Name = "Category"
Category_2.Parent = SpecialTab
Category_2.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
Category_2.BorderSizePixel = 0
Category_2.Size = UDim2.new(1, 0, 0, 30)
Category_2.Font = Enum.Font.SourceSans
Category_2.Text = "Special"
Category_2.TextColor3 = Color3.new(0, 0.835294, 1)
Category_2.TextSize = 14

A_Patrol.Name = "A_Patrol"
A_Patrol.Parent = SpecialTab
A_Patrol.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Patrol.BorderSizePixel = 0
A_Patrol.Position = UDim2.new(0, 0, 0.06, 0)
A_Patrol.Size = UDim2.new(1, 0, 0, 30)
A_Patrol.Font = Enum.Font.SciFi
A_Patrol.Text = "Patrol"
A_Patrol.TextColor3 = Color3.new(1, 1, 1)
A_Patrol.TextSize = 20

A_Confident.Name = "A_Confident"
A_Confident.Parent = SpecialTab
A_Confident.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Confident.BorderSizePixel = 0
A_Confident.Position = UDim2.new(0, 0, 0.12, 0)
A_Confident.Size = UDim2.new(1, 0, 0, 30)
A_Confident.Font = Enum.Font.SciFi
A_Confident.Text = "Confident"
A_Confident.TextColor3 = Color3.new(1, 1, 1)
A_Confident.TextSize = 20

A_Popstar.Name = "A_Popstar"
A_Popstar.Parent = SpecialTab
A_Popstar.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Popstar.BorderSizePixel = 0
A_Popstar.Position = UDim2.new(0, 0, 0.18, 0)
A_Popstar.Size = UDim2.new(1, 0, 0, 30)
A_Popstar.Font = Enum.Font.SciFi
A_Popstar.Text = "Popstar"
A_Popstar.TextColor3 = Color3.new(1, 1, 1)
A_Popstar.TextSize = 20

A_Cowboy.Name = "A_Cowboy"
A_Cowboy.Parent = SpecialTab
A_Cowboy.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Cowboy.BorderSizePixel = 0
A_Cowboy.Position = UDim2.new(0, 0, 0.24, 0)
A_Cowboy.Size = UDim2.new(1, 0, 0, 30)
A_Cowboy.Font = Enum.Font.SciFi
A_Cowboy.Text = "Cowboy"
A_Cowboy.TextColor3 = Color3.new(1, 1, 1)
A_Cowboy.TextSize = 20

A_Ghost.Name = "A_Ghost"
A_Ghost.Parent = SpecialTab
A_Ghost.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Ghost.BorderSizePixel = 0
A_Ghost.Position = UDim2.new(0, 0, 0.30, 0)
A_Ghost.Size = UDim2.new(1, 0, 0, 30)
A_Ghost.Font = Enum.Font.SciFi
A_Ghost.Text = "Ghost"
A_Ghost.TextColor3 = Color3.new(1, 1, 1)
A_Ghost.TextSize = 20

A_Sneaky.Name = "A_Sneaky"
A_Sneaky.Parent = SpecialTab
A_Sneaky.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Sneaky.BorderSizePixel = 0
A_Sneaky.Position = UDim2.new(0, 0, 0.36, 0)
A_Sneaky.Size = UDim2.new(1, 0, 0, 30)
A_Sneaky.Font = Enum.Font.SciFi
A_Sneaky.Text = "Sneaky"
A_Sneaky.TextColor3 = Color3.new(1, 1, 1)
A_Sneaky.TextSize = 20

A_Princess.Name = "A_Princess"
A_Princess.Parent = SpecialTab
A_Princess.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Princess.BorderSizePixel = 0
A_Princess.Position = UDim2.new(0, 0, 0.42, 0)
A_Princess.Size = UDim2.new(1, 0, 0, 30)
A_Princess.Font = Enum.Font.SciFi
A_Princess.Text = "Princess"
A_Princess.TextColor3 = Color3.new(1, 1, 1)
A_Princess.TextSize = 20

OtherTab.Name = "OtherTab"
OtherTab.Parent = ScrollingFrame
OtherTab.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
OtherTab.BorderSizePixel = 0
OtherTab.Position = UDim2.new(0, 0, 0, 860)
OtherTab.Size = UDim2.new(1, 0, 0, 150)

Category_3.Name = "Category"
Category_3.Parent = OtherTab
Category_3.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
Category_3.BorderSizePixel = 0
Category_3.Size = UDim2.new(1, 0, 0, 30)
Category_3.Font = Enum.Font.SourceSans
Category_3.Text = "Other"
Category_3.TextColor3 = Color3.new(0, 0.835294, 1)
Category_3.TextSize = 14

A_None.Name = "A_None"
A_None.Parent = OtherTab
A_None.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_None.BorderSizePixel = 0
A_None.Position = UDim2.new(0, 0, 0.06, 0)
A_None.Size = UDim2.new(1, 0, 0, 30)
A_None.Font = Enum.Font.SciFi
A_None.Text = "None"
A_None.TextColor3 = Color3.new(1, 1, 1)
A_None.TextSize = 20

A_Anthro.Name = "A_Anthro"
A_Anthro.Parent = OtherTab
A_Anthro.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Anthro.BorderSizePixel = 0
A_Anthro.Position = UDim2.new(0, 0, 0.12, 0)
A_Anthro.Size = UDim2.new(1, 0, 0, 30)
A_Anthro.Font = Enum.Font.SciFi
A_Anthro.Text = "Anthro (Default)"
A_Anthro.TextColor3 = Color3.new(1, 1, 1)
A_Anthro.TextSize = 20

A_Adidas.Name = "A_Adidas"
A_Adidas.Parent = OtherTab
A_Adidas.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Adidas.BorderSizePixel = 0
A_Adidas.Position = UDim2.new(0, 0, 0.18, 0)
A_Adidas.Size = UDim2.new(1, 0, 0, 30)
A_Adidas.Font = Enum.Font.SciFi
A_Adidas.Text = "Adidas"
A_Adidas.TextColor3 = Color3.new(1, 1, 1)
A_Adidas.TextSize = 20

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animate = character:WaitForChild("Animate")

local function applyAnimation(animData)
    for animType, animId in pairs(animData) do
        local animTrack = animate:FindFirstChild(animType)
        if animTrack then
            if animType == "idle" then
                animTrack.Animation1.AnimationId = animId[1]
                animTrack.Animation2.AnimationId = animId[2]
            else
                animTrack.AnimationId = animId
            end
        end
    end
    humanoid.Jump = true
end

local function handleCharacterAdded(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    animate = character:WaitForChild("Animate")
end

player.CharacterAdded:Connect(handleCharacterAdded)

Close.MouseButton1Click:Connect(function()
    AnimationChanger:Destroy()
end)

Minimize.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

A_Astronaut.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=891621366", "http://www.roblox.com/asset/?id=891633237"},
        walk = "http://www.roblox.com/asset/?id=891667138",
        run = "http://www.roblox.com/asset/?id=891636393",
        jump = "http://www.roblox.com/asset/?id=891627522",
        climb = "http://www.roblox.com/asset/?id=891609353",
        fall = "http://www.roblox.com/asset/?id=891617961"
    })
end)

A_Bubbly.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=910004836", "http://www.roblox.com/asset/?id=910009958"},
        walk = "http://www.roblox.com/asset/?id=910034870",
        run = "http://www.roblox.com/asset/?id=910025107",
        jump = "http://www.roblox.com/asset/?id=910016857",
        fall = "http://www.roblox.com/asset/?id=910001910",
        swimidle = "http://www.roblox.com/asset/?id=910030921",
        swim = "http://www.roblox.com/asset/?id=910028158"
    })
end)

A_Cartoony.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=742637544", "http://www.roblox.com/asset/?id=742638445"},
        walk = "http://www.roblox.com/asset/?id=742640026",
        run = "http://www.roblox.com/asset/?id=742638842",
        jump = "http://www.roblox.com/asset/?id=742637942",
        climb = "http://www.roblox.com/asset/?id=742636889",
        fall = "http://www.roblox.com/asset/?id=742637151"
    })
end)

A_Elder.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=845397899", "http://www.roblox.com/asset/?id=845400520"},
        walk = "http://www.roblox.com/asset/?id=845403856",
        run = "http://www.roblox.com/asset/?id=845386501",
        jump = "http://www.roblox.com/asset/?id=845398858",
        climb = "http://www.roblox.com/asset/?id=845392038",
        fall = "http://www.roblox.com/asset/?id=845396048"
    })
end)

A_Knight.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=657595757", "http://www.roblox.com/asset/?id=657568135"},
        walk = "http://www.roblox.com/asset/?id=657552124",
        run = "http://www.roblox.com/asset/?id=657564596",
        jump = "http://www.roblox.com/asset/?id=658409194",
        climb = "http://www.roblox.com/asset/?id=658360781",
        fall = "http://www.roblox.com/asset/?id=657600338"
    })
end)

A_Levitation.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=616006778", "http://www.roblox.com/asset/?id=616008087"},
        walk = "http://www.roblox.com/asset/?id=616013216",
        run = "http://www.roblox.com/asset/?id=616010382",
        jump = "http://www.roblox.com/asset/?id=616008936",
        climb = "http://www.roblox.com/asset/?id=616003713",
        fall = "http://www.roblox.com/asset/?id=616005863"
    })
end)

A_Mage.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=707742142", "http://www.roblox.com/asset/?id=707855907"},
        walk = "http://www.roblox.com/asset/?id=707897309",
        run = "http://www.roblox.com/asset/?id=707861613",
        jump = "http://www.roblox.com/asset/?id=707853694",
        climb = "http://www.roblox.com/asset/?id=707826056",
        fall = "http://www.roblox.com/asset/?id=707829716"
    })
end)

A_Ninja.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=656117400", "http://www.roblox.com/asset/?id=656118341"},
        walk = "http://www.roblox.com/asset/?id=656121766",
        run = "http://www.roblox.com/asset/?id=656118852",
        jump = "http://www.roblox.com/asset/?id=656117878",
        climb = "http://www.roblox.com/asset/?id=656114359",
        fall = "http://www.roblox.com/asset/?id=656115606"
    })
end)

A_Pirate.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=750781874", "http://www.roblox.com/asset/?id=750782770"},
        walk = "http://www.roblox.com/asset/?id=750785693",
        run = "http://www.roblox.com/asset/?id=750783738",
        jump = "http://www.roblox.com/asset/?id=750782230",
        climb = "http://www.roblox.com/asset/?id=750779899",
        fall = "http://www.roblox.com/asset/?id=750780242"
    })
end)

A_Robot.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=616088211", "http://www.roblox.com/asset/?id=616089559"},
        walk = "http://www.roblox.com/asset/?id=616095330",
        run = "http://www.roblox.com/asset/?id=616091570",
        jump = "http://www.roblox.com/asset/?id=616090535",
        climb = "http://www.roblox.com/asset/?id=616086039",
        fall = "http://www.roblox.com/asset/?id=616087089"
    })
end)

A_Stylish.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=616136790", "http://www.roblox.com/asset/?id=616138447"},
        walk = "http://www.roblox.com/asset/?id=616146177",
        run = "http://www.roblox.com/asset/?id=616140816",
        jump = "http://www.roblox.com/asset/?id=616139451",
        climb = "http://www.roblox.com/asset/?id=616133594",
        fall = "http://www.roblox.com/asset/?id=616134815"
    })
end)

A_SuperHero.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=616111295", "http://www.roblox.com/asset/?id=616113536"},
        walk = "http://www.roblox.com/asset/?id=616122287",
        run = "http://www.roblox.com/asset/?id=616117076",
        jump = "http://www.roblox.com/asset/?id=616115533",
        climb = "http://www.roblox.com/asset/?id=616104706",
        fall = "http://www.roblox.com/asset/?id=616108001"
    })
end)

A_Toy.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=782841498", "http://www.roblox.com/asset/?id=782845736"},
        walk = "http://www.roblox.com/asset/?id=782843345",
        run = "http://www.roblox.com/asset/?id=782842708",
        jump = "http://www.roblox.com/asset/?id=782847020",
        climb = "http://www.roblox.com/asset/?id=782843869",
        fall = "http://www.roblox.com/asset/?id=782846423"
    })
end)

A_Vampire.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=1083445855", "http://www.roblox.com/asset/?id=1083450166"},
        walk = "http://www.roblox.com/asset/?id=1083473930",
        run = "http://www.roblox.com/asset/?id=1083462077",
        jump = "http://www.roblox.com/asset/?id=1083455352",
        climb = "http://www.roblox.com/asset/?id=1083439238",
        fall = "http://www.roblox.com/asset/?id=1083443587"
    })
end)

A_Werewolf.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=1083195517", "http://www.roblox.com/asset/?id=1083214717"},
        walk = "http://www.roblox.com/asset/?id=1083178339",
        run = "http://www.roblox.com/asset/?id=1083216690",
        jump = "http://www.roblox.com/asset/?id=1083218792",
        climb = "http://www.roblox.com/asset/?id=1083182000",
        fall = "http://www.roblox.com/asset/?id=1083189019"
    })
end)

A_Zombie.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=616158929", "http://www.roblox.com/asset/?id=616160636"},
        walk = "http://www.roblox.com/asset/?id=616168032",
        run = "http://www.roblox.com/asset/?id=616163682",
        jump = "http://www.roblox.com/asset/?id=616161997",
        climb = "http://www.roblox.com/asset/?id=616156119",
        fall = "http://www.roblox.com/asset/?id=616157476"
    })
end)

A_Patrol.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=1149612882", "http://www.roblox.com/asset/?id=1150842221"},
        walk = "http://www.roblox.com/asset/?id=1151231493",
        run = "http://www.roblox.com/asset/?id=1150967949",
        jump = "http://www.roblox.com/asset/?id=1148811837",
        climb = "http://www.roblox.com/asset/?id=1148811837",
        fall = "http://www.roblox.com/asset/?id=1148863382"
    })
end)

A_Confident.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=1069977950", "http://www.roblox.com/asset/?id=1069987858"},
        walk = "http://www.roblox.com/asset/?id=1070017263",
        run = "http://www.roblox.com/asset/?id=1070001516",
        jump = "http://www.roblox.com/asset/?id=1069984524",
        climb = "http://www.roblox.com/asset/?id=1069946257",
        fall = "http://www.roblox.com/asset/?id=1069973677"
    })
end)

A_Popstar.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=1212900985", "http://www.roblox.com/asset/?id=1150842221"},
        walk = "http://www.roblox.com/asset/?id=1212980338",
        run = "http://www.roblox.com/asset/?id=1212980348",
        jump = "http://www.roblox.com/asset/?id=1212954642",
        climb = "http://www.roblox.com/asset/?id=1213044953",
        fall = "http://www.roblox.com/asset/?id=1212900995"
    })
end)

A_Cowboy.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=1014390418", "http://www.roblox.com/asset/?id=1014398616"},
        walk = "http://www.roblox.com/asset/?id=1014421541",
        run = "http://www.roblox.com/asset/?id=1014401683",
        jump = "http://www.roblox.com/asset/?id=1014394726",
        climb = "http://www.roblox.com/asset/?id=1014380606",
        fall = "http://www.roblox.com/asset/?id=1014384571"
    })
end)

A_Ghost.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=616006778", "http://www.roblox.com/asset/?id=616008087"},
        walk = "http://www.roblox.com/asset/?id=616013216",
        run = "http://www.roblox.com/asset/?id=616013216",
        jump = "http://www.roblox.com/asset/?id=616008936",
        fall = "http://www.roblox.com/asset/?id=616005863",
        swimidle = "http://www.roblox.com/asset/?id=616012453",
        swim = "http://www.roblox.com/asset/?id=616011509"
    })
end)

A_Sneaky.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=1132473842", "http://www.roblox.com/asset/?id=1132477671"},
        walk = "http://www.roblox.com/asset/?id=1132510133",
        run = "http://www.roblox.com/asset/?id=1132494274",
        jump = "http://www.roblox.com/asset/?id=1132489853",
        climb = "http://www.roblox.com/asset/?id=1132461372",
        fall = "http://www.roblox.com/asset/?id=1132469004"
    })
end)

A_Princess.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=941003647", "http://www.roblox.com/asset/?id=941013098"},
        walk = "http://www.roblox.com/asset/?id=941028902",
        run = "http://www.roblox.com/asset/?id=941015281",
        jump = "http://www.roblox.com/asset/?id=941008832",
        climb = "http://www.roblox.com/asset/?id=940996062",
        fall = "http://www.roblox.com/asset/?id=941000007"
    })
end)

A_None.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"0", "0"},
        walk = "0",
        run = "0",
        jump = "0",
        fall = "0",
        swimidle = "0",
        swim = "0"
    })
end)

A_Anthro.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=2510196951", "http://www.roblox.com/asset/?id=2510197257"},
        walk = "http://www.roblox.com/asset/?id=2510202577",
        run = "http://www.roblox.com/asset/?id=2510198475",
        jump = "http://www.roblox.com/asset/?id=2510197830",
        climb = "http://www.roblox.com/asset/?id=2510192778",
        fall = "http://www.roblox.com/asset/?id=2510195892"
    })
end)

A_Adidas.MouseButton1Click:Connect(function()
    applyAnimation({
        idle = {"http://www.roblox.com/asset/?id=1307429376", "http://www.roblox.com/asset/?id=1307431199"},
        walk = "http://www.roblox.com/asset/?id=1307434163",
        run = "http://www.roblox.com/asset/?id=1307432958",
        jump = "http://www.roblox.com/asset/?id=1307431857",
        climb = "http://www.roblox.com/asset/?id=1307428379",
        fall = "http://www.roblox.com/asset/?id=1307429884"
    })
end)