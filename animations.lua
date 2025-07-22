local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local AnimationChanger = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Minimize = Instance.new("ImageButton")
local Title = Instance.new("TextLabel")
local Tab = Instance.new("Frame")
local Category = Instance.new("TextLabel")
local Buttons = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local A_Zombie = Instance.new("TextButton")
local A_Levitation = Instance.new("TextButton")
local A_Vampire = Instance.new("TextButton")

AnimationChanger.Name = "AnimationChanger"
AnimationChanger.Parent = game:GetService("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AnimationChanger.ResetOnSpawn = false

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

TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 28)

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 8)
topBarCorner.Parent = TopBar

Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundTransparency = 1
Minimize.Position = UDim2.new(0.85, 0, 0.15, 0)
Minimize.Size = UDim2.new(0, 20, 0, 20)
Minimize.Image = "rbxassetid://3926305904"
Minimize.ImageRectOffset = Vector2.new(124, 204)
Minimize.ImageRectSize = Vector2.new(36, 36)
Minimize.ImageColor3 = Color3.fromRGB(180, 180, 180)

Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "ANIMATIONS"
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

Tab.Name = "Tab"
Tab.Parent = Main
Tab.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Tab.BorderSizePixel = 0
Tab.Position = UDim2.new(0, 0, 0, 28)
Tab.Size = UDim2.new(1, 0, 0, 132)
Tab.ClipsDescendants = true

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

Buttons.Name = "Buttons"
Buttons.Parent = Tab
Buttons.BackgroundTransparency = 1
Buttons.Position = UDim2.new(0, 5, 0, 28)
Buttons.Size = UDim2.new(1, -10, 1, -28)
Buttons.ScrollBarThickness = 3
Buttons.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
Buttons.CanvasSize = UDim2.new(0, 0, 0, 0)

UIListLayout.Parent = Buttons
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local function createButton(name)
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
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = Color3.fromRGB(60, 60, 65)
    buttonStroke.LineJoinMode = Enum.LineJoinMode.Round
    buttonStroke.Thickness = 1
    buttonStroke.Parent = button
    
    local hoverTween
    local clickTween
    
    button.MouseEnter:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 55),
            TextColor3 = Color3.fromRGB(240, 240, 240)
        })
        hoverTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 45),
            TextColor3 = Color3.fromRGB(220, 220, 220)
        })
        hoverTween:Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        if clickTween then clickTween:Cancel() end
        clickTween = TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 35),
            Size = UDim2.new(0.98, 0, 0, 28)
        })
        clickTween:Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        if clickTween then clickTween:Cancel() end
        clickTween = TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 55),
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
    local inactiveColor = Color3.fromRGB(40, 40, 45)
    
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
            Size = UDim2.new(0, 180, 0, 28)
        })
        table.insert(activeTweens, tween)
        tween:Play()
    else
        local tween = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 180, 0, 160)
        })
        table.insert(activeTweens, tween)
        tween:Play()
    end
    
    Minimize.ImageRectOffset = minimized and Vector2.new(84, 204) or Vector2.new(124, 204)
    
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
    Position = UDim2.new(0.4, 0, 0.15, 0),
    Size = UDim2.new(0, 180, 0, 160)
})
openTween:Play()

RunService.Heartbeat:Connect(function()
    Buttons.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)