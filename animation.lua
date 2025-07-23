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
local A_Superhero = Instance.new("TextButton")
local A_Robot = Instance.new("TextButton")
local A_Cartoon = Instance.new("TextButton")
local EmotionsTab = Instance.new("Frame")
local EmoteCategory = Instance.new("TextLabel")
local EmoteButtons = Instance.new("ScrollingFrame")
local EmoteListLayout = Instance.new("UIListLayout")
local E_Dab = Instance.new("TextButton")
local E_Point = Instance.new("TextButton")
local E_Laugh = Instance.new("TextButton")
local E_Dance = Instance.new("TextButton")
local E_Angry = Instance.new("TextButton")
local E_Cheer = Instance.new("TextButton")
local E_Wave = Instance.new("TextButton")
local E_Shrug = Instance.new("TextButton")

AnimationChanger.Name = "AnimationChanger"
AnimationChanger.Parent = game:GetService("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AnimationChanger.ResetOnSpawn = false

Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.35, 0, -1, 0)
Main.Size = UDim2.new(0, 220, 0, 0)
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
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
TopBar.Size = UDim2.new(1, 0, 0, 32)

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 12)
topBarCorner.Parent = TopBar
topBarCorner.CornerRadius = UDim.new(0, 12)

Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundTransparency = 1
Minimize.Position = UDim2.new(0.87, 0, 0.15, 0)
Minimize.Size = UDim2.new(0, 22, 0, 22)
Minimize.Image = "rbxassetid://3926307971"
Minimize.ImageRectOffset = Vector2.new(884, 4)
Minimize.ImageRectSize = Vector2.new(36, 36)
Minimize.ImageColor3 = Color3.fromRGB(200, 200, 200)

Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "ANIMATION CHANGER"
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local titleGradient = Instance.new("UIGradient")
titleGradient.Parent = Title
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 220, 255))
})
titleGradient.Rotation = 90

TabContainer.Name = "TabContainer"
TabContainer.Parent = Main
TabContainer.BackgroundTransparency = 1
TabContainer.Size = UDim2.new(1, 0, 1, -32)
TabContainer.Position = UDim2.new(0, 0, 0, 32)

TabButtons.Name = "TabButtons"
TabButtons.Parent = TabContainer
TabButtons.BackgroundTransparency = 1
TabButtons.Size = UDim2.new(1, 0, 0, 34)

AnimTabButton.Name = "AnimTabButton"
AnimTabButton.Parent = TabButtons
AnimTabButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
AnimTabButton.BorderSizePixel = 0
AnimTabButton.Position = UDim2.new(0, 6, 0, 0)
AnimTabButton.Size = UDim2.new(0.5, -8, 1, 0)
AnimTabButton.Font = Enum.Font.GothamMedium
AnimTabButton.Text = "ANIMATIONS"
AnimTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AnimTabButton.TextSize = 13
AnimTabButton.AutoButtonColor = false

local animTabCorner = Instance.new("UICorner")
animTabCorner.CornerRadius = UDim.new(0, 6)
animTabCorner.Parent = AnimTabButton

EmoteTabButton.Name = "EmoteTabButton"
EmoteTabButton.Parent = TabButtons
EmoteTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
EmoteTabButton.BorderSizePixel = 0
EmoteTabButton.Position = UDim2.new(0.5, 2, 0, 0)
EmoteTabButton.Size = UDim2.new(0.5, -8, 1, 0)
EmoteTabButton.Font = Enum.Font.GothamMedium
EmoteTabButton.Text = "EMOTES"
EmoteTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
EmoteTabButton.TextSize = 13
EmoteTabButton.AutoButtonColor = false

local emoteTabCorner = Instance.new("UICorner")
emoteTabCorner.CornerRadius = UDim.new(0, 6)
emoteTabCorner.Parent = EmoteTabButton

TabSelection.Name = "TabSelection"
TabSelection.Parent = TabButtons
TabSelection.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TabSelection.BorderSizePixel = 0
TabSelection.Size = UDim2.new(0.5, -8, 0, 3)
TabSelection.Position = UDim2.new(0, 6, 1, -3)

local selectionCorner = Instance.new("UICorner")
selectionCorner.CornerRadius = UDim.new(0, 2)
selectionCorner.Parent = TabSelection

Tabs.Name = "Tabs"
Tabs.Parent = TabContainer
Tabs.BackgroundTransparency = 1
Tabs.Size = UDim2.new(1, 0, 1, -34)
Tabs.Position = UDim2.new(0, 0, 0, 34)
Tabs.ClipsDescendants = true

AnimationsTab.Name = "AnimationsTab"
AnimationsTab.Parent = Tabs
AnimationsTab.BackgroundTransparency = 1
AnimationsTab.Size = UDim2.new(1, 0, 1, 0)
AnimationsTab.Visible = true

Category.Name = "Category"
Category.Parent = AnimationsTab
Category.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Category.BorderSizePixel = 0
Category.Size = UDim2.new(1, -12, 0, 26)
Category.Position = UDim2.new(0, 6, 0, 0)
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
Buttons.Position = UDim2.new(0, 6, 0, 30)
Buttons.Size = UDim2.new(1, -12, 1, -30)
Buttons.ScrollBarThickness = 4
Buttons.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
Buttons.ScrollBarImageTransparency = 0.5
Buttons.CanvasSize = UDim2.new(0, 0, 0, 0)
Buttons.ScrollingDirection = Enum.ScrollingDirection.Y

UIListLayout.Parent = Buttons
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

EmotionsTab.Name = "EmotionsTab"
EmotionsTab.Parent = Tabs
EmotionsTab.BackgroundTransparency = 1
EmotionsTab.Size = UDim2.new(1, 0, 1, 0)
EmotionsTab.Visible = false

EmoteCategory.Name = "EmoteCategory"
EmoteCategory.Parent = EmotionsTab
EmoteCategory.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
EmoteCategory.BorderSizePixel = 0
EmoteCategory.Size = UDim2.new(1, -12, 0, 26)
EmoteCategory.Position = UDim2.new(0, 6, 0, 0)
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
EmoteButtons.Position = UDim2.new(0, 6, 0, 30)
EmoteButtons.Size = UDim2.new(1, -12, 1, -30)
EmoteButtons.ScrollBarThickness = 4
EmoteButtons.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
EmoteButtons.ScrollBarImageTransparency = 0.5
EmoteButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
EmoteButtons.ScrollingDirection = Enum.ScrollingDirection.Y

EmoteListLayout.Parent = EmoteButtons
EmoteListLayout.SortOrder = Enum.SortOrder.LayoutOrder
EmoteListLayout.Padding = UDim.new(0, 6)

local function createButton(name, parent)
    local button = Instance.new("TextButton")
    button.Name = name
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 34)
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
    
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Parent = button
    buttonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 45))
    })
    buttonGradient.Rotation = 90
    
    local hoverTween
    local clickTween
    
    button.MouseEnter:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 65),
            TextColor3 = Color3.fromRGB(255, 255, 255)
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
            Size = UDim2.new(0.98, 0, 0, 32)
        })
        clickTween:Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        if clickTween then clickTween:Cancel() end
        clickTween = TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 65),
            Size = UDim2.new(1, 0, 0, 34)
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

A_Zombie = createButton("Zombie", Buttons)
A_Zombie.LayoutOrder = 1

A_Levitation = createButton("Levitation", Buttons)
A_Levitation.LayoutOrder = 2

A_Vampire = createButton("Vampire", Buttons)
A_Vampire.LayoutOrder = 3

A_Werewolf = createButton("Werewolf", Buttons)
A_Werewolf.LayoutOrder = 4

A_Superhero = createButton("Superhero", Buttons)
A_Superhero.LayoutOrder = 5

A_Robot = createButton("Robot", Buttons)
A_Robot.LayoutOrder = 6

A_Cartoon = createButton("Cartoon", Buttons)
A_Cartoon.LayoutOrder = 7

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

E_Cheer = createButton("Cheer", EmoteButtons)
E_Cheer.LayoutOrder = 6

E_Wave = createButton("Wave", EmoteButtons)
E_Wave.LayoutOrder = 7

E_Shrug = createButton("Shrug", EmoteButtons)
E_Shrug.LayoutOrder = 8

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
    },
    Superhero = {
        idle1 = "rbxassetid://2510196951",
        idle2 = "rbxassetid://2510197257",
        walk = "rbxassetid://2510198479",
        run = "rbxassetid://2510197834",
        jump = "rbxassetid://2510198020",
        climb = "rbxassetid://2510196680",
        fall = "rbxassetid://2510198320"
    },
    Robot = {
        idle1 = "rbxassetid://616088211",
        idle2 = "rbxassetid://616089559",
        walk = "rbxassetid://616095330",
        run = "rbxassetid://616091570",
        jump = "rbxassetid://616090535",
        climb = "rbxassetid://616086039",
        fall = "rbxassetid://616087089"
    },
    Cartoon = {
        idle1 = "rbxassetid://742637544",
        idle2 = "rbxassetid://742638445",
        walk = "rbxassetid://742640026",
        run = "rbxassetid://742638842",
        jump = "rbxassetid://742637942",
        climb = "rbxassetid://742636889",
        fall = "rbxassetid://742637151"
    }
}

local emotes = {
    Dab = "rbxassetid://5079841939",
    Point = "rbxassetid://5079866664",
    Laugh = "rbxassetid://5079841304",
    Dance = "rbxassetid://5079813986",
    Angry = "rbxassetid://5079838722",
    Cheer = "rbxassetid://5079815726",
    Wave = "rbxassetid://507770239",
    Shrug = "rbxassetid://5104363179"
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
    
    if emotePlaying and emoteTrack then
        emoteTrack:Stop()
        emotePlaying = false
    end
    
    local emote = Instance.new("Animation")
    emote.AnimationId = emoteId
    
    emoteTrack = humanoid:LoadAnimation(emote)
    emoteTrack:Play()
    emotePlaying = true
    
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
    
    local activeColor = Color3.fromRGB(0, 170, 255)
    local inactiveColor = Color3.fromRGB(40, 40, 45)
    
    A_Zombie.BackgroundColor3 = animName == "Zombie" and activeColor or inactiveColor
    A_Levitation.BackgroundColor3 = animName == "Levitation" and activeColor or inactiveColor
    A_Vampire.BackgroundColor3 = animName == "Vampire" and activeColor or inactiveColor
    A_Werewolf.BackgroundColor3 = animName == "Werewolf" and activeColor or inactiveColor
    A_Superhero.BackgroundColor3 = animName == "Superhero" and activeColor or inactiveColor
    A_Robot.BackgroundColor3 = animName == "Robot" and activeColor or inactiveColor
    A_Cartoon.BackgroundColor3 = animName == "Cartoon" and activeColor or inactiveColor
    
    A_Zombie.UIStroke.Color = animName == "Zombie" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    A_Levitation.UIStroke.Color = animName == "Levitation" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    A_Vampire.UIStroke.Color = animName == "Vampire" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    A_Werewolf.UIStroke.Color = animName == "Werewolf" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    A_Superhero.UIStroke.Color = animName == "Superhero" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    A_Robot.UIStroke.Color = animName == "Robot" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    A_Cartoon.UIStroke.Color = animName == "Cartoon" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
end

local function setEmote(emoteName)
    currentEmote = emoteName
    local character = game.Players.LocalPlayer.Character
    if character then
        playEmote(character, emoteName)
    end
    
    local activeColor = Color3.fromRGB(0, 170, 255)
    local inactiveColor = Color3.fromRGB(40, 40, 45)
    
    E_Dab.BackgroundColor3 = emoteName == "Dab" and activeColor or inactiveColor
    E_Point.BackgroundColor3 = emoteName == "Point" and activeColor or inactiveColor
    E_Laugh.BackgroundColor3 = emoteName == "Laugh" and activeColor or inactiveColor
    E_Dance.BackgroundColor3 = emoteName == "Dance" and activeColor or inactiveColor
    E_Angry.BackgroundColor3 = emoteName == "Angry" and activeColor or inactiveColor
    E_Cheer.BackgroundColor3 = emoteName == "Cheer" and activeColor or inactiveColor
    E_Wave.BackgroundColor3 = emoteName == "Wave" and activeColor or inactiveColor
    E_Shrug.BackgroundColor3 = emoteName == "Shrug" and activeColor or inactiveColor
    
    E_Dab.UIStroke.Color = emoteName == "Dab" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    E_Point.UIStroke.Color = emoteName == "Point" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    E_Laugh.UIStroke.Color = emoteName == "Laugh" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    E_Dance.UIStroke.Color = emoteName == "Dance" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    E_Angry.UIStroke.Color = emoteName == "Angry" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    E_Cheer.UIStroke.Color = emoteName == "Cheer" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    E_Wave.UIStroke.Color = emoteName == "Wave" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
    E_Shrug.UIStroke.Color = emoteName == "Shrug" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 65)
end

local function toggleMenu()
    minimized = not minimized
    cancelAllTweens()
    
    if minimized then
        local tween = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 220, 0, 32)
        })
        table.insert(activeTweens, tween)
        tween:Play()
    else
        local tween = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 220, 0, 250)
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

local function switchTab(tabName)
    local activeColor = Color3.fromRGB(0, 170, 255)
    local inactiveColor = Color3.fromRGB(40, 40, 45)
    
    if tabName == "Animations" then
        AnimationsTab.Visible = true
        EmotionsTab.Visible = false
        
        AnimTabButton.BackgroundColor3 = activeColor
        AnimTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        EmoteTabButton.BackgroundColor3 = inactiveColor
        EmoteTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        local tween = TweenService:Create(TabSelection, TweenInfo.new(0.2), {
            Position = UDim2.new(0, 6, 1, -3)
        })
        tween:Play()
    else
        AnimationsTab.Visible = false
        EmotionsTab.Visible = true
        
        EmoteTabButton.BackgroundColor3 = activeColor
        EmoteTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        AnimTabButton.BackgroundColor3 = inactiveColor
        AnimTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        local tween = TweenService:Create(TabSelection, TweenInfo.new(0.2), {
            Position = UDim2.new(0.5, 2, 1, -3)
        })
        tween:Play()
    end
end

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
A_Superhero.MouseButton1Click:Connect(function() setAnimation("Superhero") end)
A_Robot.MouseButton1Click:Connect(function() setAnimation("Robot") end)
A_Cartoon.MouseButton1Click:Connect(function() setAnimation("Cartoon") end)

E_Dab.MouseButton1Click:Connect(function() setEmote("Dab") end)
E_Point.MouseButton1Click:Connect(function() setEmote("Point") end)
E_Laugh.MouseButton1Click:Connect(function() setEmote("Laugh") end)
E_Dance.MouseButton1Click:Connect(function() setEmote("Dance") end)
E_Angry.MouseButton1Click:Connect(function() setEmote("Angry") end)
E_Cheer.MouseButton1Click:Connect(function() setEmote("Cheer") end)
E_Wave.MouseButton1Click:Connect(function() setEmote("Wave") end)
E_Shrug.MouseButton1Click:Connect(function() setEmote("Shrug") end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if currentAnimation then
        task.wait(1)
        applyAnimation(character, currentAnimation)
    end
    if currentEmote then
        task.wait(1)
        playEmote(character, currentEmote)
    end
end)

local openTween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.35, 0, 0.15, 0),
    Size = UDim2.new(0, 220, 0, 250)
})
openTween:Play()

RunService.Heartbeat:Connect(function()
    Buttons.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    EmoteButtons.CanvasSize = UDim2.new(0, 0, 0, EmoteListLayout.AbsoluteContentSize.Y)
end)