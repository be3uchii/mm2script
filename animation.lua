local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local AnimationChanger = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Minimize = Instance.new("ImageButton")
local Title = Instance.new("TextLabel")
local TabContainer = Instance.new("Frame")
local TabButtons = Instance.new("Frame")
local AnimTabButton = Instance.new("TextButton")
local EmoteTabButton = Instance.new("TextButton")
local TabSelection = Instance.new("Frame")
local Tabs = Instance.new("Frame")
local AnimationsTab = Instance.new("Frame")
local Category = Instance.new("TextLabel")
local Buttons = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local A_Zombie = Instance.new("TextButton")
local A_Levitation = Instance.new("TextButton")
local A_Vampire = Instance.new("TextButton")
local A_Werewolf = Instance.new("TextButton")
local EmotionsTab = Instance.new("Frame")
local EmoteCategory = Instance.new("TextLabel")
local EmoteButtons = Instance.new("ScrollingFrame")
local EmoteListLayout = Instance.new("UIListLayout")
local E_Dab = Instance.new("TextButton")
local E_Point = Instance.new("TextButton")
local E_Laugh = Instance.new("TextButton")
local E_Dance = Instance.new("TextButton")
local E_Angry = Instance.new("TextButton")

-- GUI Setup
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
Main.Size = UDim2.new(0, 200, 0, 0)
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
Title.Text = "ANIMATION CHANGER"
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

TabContainer.Name = "TabContainer"
TabContainer.Parent = Main
TabContainer.BackgroundTransparency = 1
TabContainer.Size = UDim2.new(1, 0, 1, -28)
TabContainer.Position = UDim2.new(0, 0, 0, 28)

TabButtons.Name = "TabButtons"
TabButtons.Parent = TabContainer
TabButtons.BackgroundTransparency = 1
TabButtons.Size = UDim2.new(1, 0, 0, 30)

AnimTabButton.Name = "AnimTabButton"
AnimTabButton.Parent = TabButtons
AnimTabButton.BackgroundColor3 = Color3.fromRGB(0, 180, 230)
AnimTabButton.BorderSizePixel = 0
AnimTabButton.Position = UDim2.new(0, 5, 0, 0)
AnimTabButton.Size = UDim2.new(0.5, -7, 1, 0)
AnimTabButton.Font = Enum.Font.GothamMedium
AnimTabButton.Text = "ANIMATIONS"
AnimTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AnimTabButton.TextSize = 12

local animTabCorner = Instance.new("UICorner")
animTabCorner.CornerRadius = UDim.new(0, 6)
animTabCorner.Parent = AnimTabButton

EmoteTabButton.Name = "EmoteTabButton"
EmoteTabButton.Parent = TabButtons
EmoteTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
EmoteTabButton.BorderSizePixel = 0
EmoteTabButton.Position = UDim2.new(0.5, 2, 0, 0)
EmoteTabButton.Size = UDim2.new(0.5, -7, 1, 0)
EmoteTabButton.Font = Enum.Font.GothamMedium
EmoteTabButton.Text = "EMOTES"
EmoteTabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
EmoteTabButton.TextSize = 12

local emoteTabCorner = Instance.new("UICorner")
emoteTabCorner.CornerRadius = UDim.new(0, 6)
emoteTabCorner.Parent = EmoteTabButton

TabSelection.Name = "TabSelection"
TabSelection.Parent = TabButtons
TabSelection.BackgroundColor3 = Color3.fromRGB(0, 180, 230)
TabSelection.BorderSizePixel = 0
TabSelection.Size = UDim2.new(0.5, -7, 0, 2)
TabSelection.Position = UDim2.new(0, 5, 1, -2)

local selectionCorner = Instance.new("UICorner")
selectionCorner.CornerRadius = UDim.new(0, 2)
selectionCorner.Parent = TabSelection

Tabs.Name = "Tabs"
Tabs.Parent = TabContainer
Tabs.BackgroundTransparency = 1
Tabs.Size = UDim2.new(1, 0, 1, -30)
Tabs.Position = UDim2.new(0, 0, 0, 30)
Tabs.ClipsDescendants = true

AnimationsTab.Name = "AnimationsTab"
AnimationsTab.Parent = Tabs
AnimationsTab.BackgroundTransparency = 1
AnimationsTab.Size = UDim2.new(1, 0, 1, 0)
AnimationsTab.Visible = true

Category.Name = "Category"
Category.Parent = AnimationsTab
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
Buttons.Parent = AnimationsTab
Buttons.BackgroundTransparency = 1
Buttons.Position = UDim2.new(0, 5, 0, 28)
Buttons.Size = UDim2.new(1, -10, 1, -28)
Buttons.ScrollBarThickness = 3
Buttons.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
Buttons.CanvasSize = UDim2.new(0, 0, 0, 0)

UIListLayout.Parent = Buttons
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

EmotionsTab.Name = "EmotionsTab"
EmotionsTab.Parent = Tabs
EmotionsTab.BackgroundTransparency = 1
EmotionsTab.Size = UDim2.new(1, 0, 1, 0)
EmotionsTab.Visible = false

EmoteCategory.Name = "EmoteCategory"
EmoteCategory.Parent = EmotionsTab
EmoteCategory.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
EmoteCategory.BorderSizePixel = 0
EmoteCategory.Size = UDim2.new(1, 0, 0, 24)
EmoteCategory.Font = Enum.Font.GothamMedium
EmoteCategory.Text = "  SELECT EMOTE"
EmoteCategory.TextColor3 = Color3.fromRGB(0, 200, 255)
EmoteCategory.TextSize = 12
EmoteCategory.TextXAlignment = Enum.TextXAlignment.Left

local emoteCategoryCorner = Instance.new("UICorner")
emoteCategoryCorner.CornerRadius = UDim.new(0, 6)
emoteCategoryCorner.Parent = EmoteCategory

EmoteButtons.Name = "EmoteButtons"
EmoteButtons.Parent = EmotionsTab
EmoteButtons.BackgroundTransparency = 1
EmoteButtons.Position = UDim2.new(0, 5, 0, 28)
EmoteButtons.Size = UDim2.new(1, -10, 1, -28)
EmoteButtons.ScrollBarThickness = 3
EmoteButtons.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
EmoteButtons.CanvasSize = UDim2.new(0, 0, 0, 0)

EmoteListLayout.Parent = EmoteButtons
EmoteListLayout.SortOrder = Enum.SortOrder.LayoutOrder
EmoteListLayout.Padding = UDim.new(0, 5)

local function createButton(name, parent)
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
    button.Parent = parent
    
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

-- Create animation buttons
A_Zombie = createButton("Zombie", Buttons)
A_Zombie.LayoutOrder = 1

A_Levitation = createButton("Levitation", Buttons)
A_Levitation.LayoutOrder = 2

A_Vampire = createButton("Vampire", Buttons)
A_Vampire.LayoutOrder = 3

A_Werewolf = createButton("Werewolf", Buttons)
A_Werewolf.LayoutOrder = 4

-- Create emote buttons
E_Dab = createButton("Dab", EmoteButtons)
E_Dab.LayoutOrder = 1

E_Point = createButton("Point", EmoteButtons)
E_Point.LayoutOrder = 2

E_Laugh = createButton("Laugh", EmoteButtons)
E_Laugh.LayoutOrder = 3

E_Dance = createButton("Dance", EmoteButtons)
E_Dance.LayoutOrder = 4

E_Angry = createButton("Angry", EmoteButtons)
E_Angry.LayoutOrder = 5

-- Animation and Emote Data
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
    },
    Werewolf = {
        idle1 = "rbxassetid://1083195517",
        idle2 = "rbxassetid://1083214717",
        walk = "rbxassetid://1083178339",
        run = "rbxassetid://1083216690",
        jump = "rbxassetid://1083218792",
        climb = "rbxassetid://1083182000",
        fall = "rbxassetid://1083189019"
    }
}

local emotes = {
    Dab = "rbxassetid://5079841939",
    Point = "rbxassetid://5079866664",
    Laugh = "rbxassetid://5079841304",
    Dance = "rbxassetid://5079813986",
    Angry = "rbxassetid://5079838722"
}

local currentAnimation = nil
local currentEmote = nil
local minimized = false
local activeTweens = {}
local emotePlaying = false
local emoteTrack = nil

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

local function playEmote(character, emoteName)
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local humanoid = character.Humanoid
    local emoteId = emotes[emoteName]
    if not emoteId then return end
    
    -- Stop current emote if playing
    if emotePlaying and emoteTrack then
        emoteTrack:Stop()
        emotePlaying = false
    end
    
    -- Load and play new emote
    local emote = Instance.new("Animation")
    emote.AnimationId = emoteId
    
    emoteTrack = humanoid:LoadAnimation(emote)
    emoteTrack:Play()
    emotePlaying = true
    
    -- Connect to stop when emote finishes
    if emoteTrack then
        emoteTrack.Stopped:Connect(function()
            emotePlaying = false
        end)
    end
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
    A_Werewolf.BackgroundColor3 = animName == "Werewolf" and activeColor or inactiveColor
    
    A_Zombie.UIStroke.Color = animName == "Zombie" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    A_Levitation.UIStroke.Color = animName == "Levitation" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    A_Vampire.UIStroke.Color = animName == "Vampire" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    A_Werewolf.UIStroke.Color = animName == "Werewolf" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
end

local function setEmote(emoteName)
    currentEmote = emoteName
    local character = game.Players.LocalPlayer.Character
    if character then
        playEmote(character, emoteName)
    end
    
    local activeColor = Color3.fromRGB(0, 180, 230)
    local inactiveColor = Color3.fromRGB(40, 40, 45)
    
    E_Dab.BackgroundColor3 = emoteName == "Dab" and activeColor or inactiveColor
    E_Point.BackgroundColor3 = emoteName == "Point" and activeColor or inactiveColor
    E_Laugh.BackgroundColor3 = emoteName == "Laugh" and activeColor or inactiveColor
    E_Dance.BackgroundColor3 = emoteName == "Dance" and activeColor or inactiveColor
    E_Angry.BackgroundColor3 = emoteName == "Angry" and activeColor or inactiveColor
    
    E_Dab.UIStroke.Color = emoteName == "Dab" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    E_Point.UIStroke.Color = emoteName == "Point" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    E_Laugh.UIStroke.Color = emoteName == "Laugh" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    E_Dance.UIStroke.Color = emoteName == "Dance" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    E_Angry.UIStroke.Color = emoteName == "Angry" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
end

local function toggleMenu()
    minimized = not minimized
    cancelAllTweens()
    
    if minimized then
        local tween = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 200, 0, 28)
        })
        table.insert(activeTweens, tween)
        tween:Play()
    else
        local tween = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 200, 0, 190)
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

local function switchTab(tabName)
    local activeColor = Color3.fromRGB(0, 180, 230)
    local inactiveColor = Color3.fromRGB(40, 40, 45)
    
    if tabName == "Animations" then
        AnimationsTab.Visible = true
        EmotionsTab.Visible = false
        
        AnimTabButton.BackgroundColor3 = activeColor
        AnimTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        EmoteTabButton.BackgroundColor3 = inactiveColor
        EmoteTabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        
        local tween = TweenService:Create(TabSelection, TweenInfo.new(0.2), {
            Position = UDim2.new(0, 5, 1, -2)
        })
        tween:Play()
    else
        AnimationsTab.Visible = false
        EmotionsTab.Visible = true
        
        EmoteTabButton.BackgroundColor3 = activeColor
        EmoteTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        AnimTabButton.BackgroundColor3 = inactiveColor
        AnimTabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        
        local tween = TweenService:Create(TabSelection, TweenInfo.new(0.2), {
            Position = UDim2.new(0.5, 2, 1, -2)
        })
        tween:Play()
    end
end

-- Connections
Minimize.MouseButton1Click:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        toggleMenu()
    end
end)

AnimTabButton.MouseButton1Click:Connect(function() switchTab("Animations") end)
EmoteTabButton.MouseButton1Click:Connect(function() switchTab("Emotes") end)

A_Zombie.MouseButton1Click:Connect(function() setAnimation("Zombie") end)
A_Levitation.MouseButton1Click:Connect(function() setAnimation("Levitation") end)
A_Vampire.MouseButton1Click:Connect(function() setAnimation("Vampire") end)
A_Werewolf.MouseButton1Click:Connect(function() setAnimation("Werewolf") end)

E_Dab.MouseButton1Click:Connect(function() setEmote("Dab") end)
E_Point.MouseButton1Click:Connect(function() setEmote("Point") end)
E_Laugh.MouseButton1Click:Connect(function() setEmote("Laugh") end)
E_Dance.MouseButton1Click:Connect(function() setEmote("Dance") end)
E_Angry.MouseButton1Click:Connect(function() setEmote("Angry") end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if currentAnimation then
        task.wait(1)
        applyAnimation(character, currentAnimation)
    end
end)

local openTween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.4, 0, 0.15, 0),
    Size = UDim2.new(0, 200, 0, 190)
})
openTween:Play()

RunService.Heartbeat:Connect(function()
    Buttons.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    EmoteButtons.CanvasSize = UDim2.new(0, 0, 0, EmoteListLayout.AbsoluteContentSize.Y)
end)