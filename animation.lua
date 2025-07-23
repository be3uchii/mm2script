local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local AnimationChanger = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Minimize = Instance.new("ImageButton")
local Title = Instance.new("TextLabel")
local Tab = Instance.new("Frame")
local Category = Instance.new("TextLabel")
local Buttons = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local Snowflakes = Instance.new("Folder")

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

Snowflakes.Name = "Snowflakes"
Snowflakes.Parent = Main

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
    Ninja = {
        idle1 = "rbxassetid://656117400",
        idle2 = "rbxassetid://656118341",
        walk = "rbxassetid://656121766",
        run = "rbxassetid://656118852",
        jump = "rbxassetid://656117878",
        climb = "rbxassetid://656114359",
        fall = "rbxassetid://656115606"
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
    Superhero = {
        idle1 = "rbxassetid://616111295",
        idle2 = "rbxassetid://616113536",
        walk = "rbxassetid://616122287",
        run = "rbxassetid://616117076",
        jump = "rbxassetid://616115533",
        climb = "rbxassetid://616104706",
        fall = "rbxassetid://616108001"
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
    Mummy = {
        idle1 = "rbxassetid://1084363347",
        idle2 = "rbxassetid://1084362071",
        walk = "rbxassetid://1084367822",
        run = "rbxassetid://1084365492",
        jump = "rbxassetid://1084361482",
        climb = "rbxassetid://1084358036",
        fall = "rbxassetid://1084359446"
    },
    Knight = {
        idle1 = "rbxassetid://657595757",
        idle2 = "rbxassetid://657568135",
        walk = "rbxassetid://657552124",
        run = "rbxassetid://657564596",
        jump = "rbxassetid://657561987",
        climb = "rbxassetid://657562335",
        fall = "rbxassetid://657552124"
    },
    Pirate = {
        idle1 = "rbxassetid://750785034",
        idle2 = "rbxassetid://750783693",
        walk = "rbxassetid://750785693",
        run = "rbxassetid://750782230",
        jump = "rbxassetid://750782230",
        climb = "rbxassetid://750779899",
        fall = "rbxassetid://750782230"
    },
    Adidas = {
        idle1 = "rbxassetid://10929578655",
        idle2 = "rbxassetid://10929578999",
        walk = "rbxassetid://10929579234",
        run = "rbxassetid://10929579456",
        jump = "rbxassetid://10929579678",
        climb = "rbxassetid://10929579890",
        fall = "rbxassetid://10929580012"
    },
    Stylish = {
        idle1 = "rbxassetid://10929580234",
        idle2 = "rbxassetid://10929580456",
        walk = "rbxassetid://10929580678",
        run = "rbxassetid://10929580890",
        jump = "rbxassetid://10929581012",
        climb = "rbxassetid://10929581234",
        fall = "rbxassetid://10929581456"
    },
    Default = {
        idle1 = "rbxassetid://507766388",
        idle2 = "rbxassetid://507766666",
        walk = "rbxassetid://507777826",
        run = "rbxassetid://507767714",
        jump = "rbxassetid://507765000",
        climb = "rbxassetid://507765644",
        fall = "rbxassetid://507767968"
    }
}

local animationButtons = {}
for animName, _ in pairs(animations) do
    if animName ~= "Default" then
        local button = createButton(animName)
        button.Parent = Buttons
        button.LayoutOrder = #animationButtons + 1
        animationButtons[animName] = button
    end
end

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
    
    if animName ~= "Default" then
        character.Humanoid.Jump = true
    end
end

local function setAnimation(animName)
    if currentAnimation == animName then
        animName = "Default"
    end
    
    currentAnimation = animName ~= "Default" and animName or nil
    local character = Players.LocalPlayer.Character
    if character then
        applyAnimation(character, animName)
    end
    
    local activeColor = Color3.fromRGB(0, 180, 230)
    local inactiveColor = Color3.fromRGB(40, 40, 45)
    local activeStroke = Color3.fromRGB(0, 150, 200)
    local inactiveStroke = Color3.fromRGB(60, 60, 65)
    
    for name, button in pairs(animationButtons) do
        button.BackgroundColor3 = animName == name and activeColor or inactiveColor
        button.UIStroke.Color = animName == name and activeStroke or inactiveStroke
    end
end

local function createSnowflake()
    local snowflake = Instance.new("ImageLabel")
    snowflake.Name = "Snowflake"
    snowflake.BackgroundTransparency = 1
    snowflake.Size = UDim2.new(0, math.random(6, 12), 0, math.random(6, 12))
    snowflake.Position = UDim2.new(0, math.random(0, 180), 0, -20)
    snowflake.Image = "rbxassetid://7151279853"
    snowflake.ImageTransparency = math.random(5, 8) / 10
    snowflake.Rotation = math.random(0, 360)
    snowflake.Parent = Snowflakes
    
    local speed = math.random(10, 20)
    local sway = math.random(5, 15)
    local swayDir = math.random() > 0.5 and 1 or -1
    
    coroutine.wrap(function()
        while snowflake and snowflake.Parent do
            local xPos = snowflake.Position.X.Offset + math.sin(tick() * 2) * sway * swayDir
            local yPos = snowflake.Position.Y.Offset + speed
            
            snowflake.Position = UDim2.new(0, xPos, 0, yPos)
            snowflake.Rotation = snowflake.Rotation + 0.5
            
            if yPos > Main.AbsoluteSize.Y + 20 then
                snowflake:Destroy()
                break
            end
            
            wait(0.03)
        end
    end)()
end

local snowflakeLoop
local function toggleSnowflakes(enable)
    if enable then
        Snowflakes.Visible = true
        for i = 1, 15 do
            createSnowflake()
        end
        
        snowflakeLoop = RunService.Heartbeat:Connect(function()
            if #Snowflakes:GetChildren() < 20 then
                createSnowflake()
            end
        end)
    else
        if snowflakeLoop then
            snowflakeLoop:Disconnect()
            snowflakeLoop = nil
        end
        Snowflakes.Visible = false
        for _, child in ipairs(Snowflakes:GetChildren()) do
            child:Destroy()
        end
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
        toggleSnowflakes(false)
    else
        local tween = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 180, 0, 160)
        })
        table.insert(activeTweens, tween)
        tween:Play()
        toggleSnowflakes(true)
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

for animName, button in pairs(animationButtons) do
    button.MouseButton1Click:Connect(function()
        setAnimation(animName)
    end)
end

Players.LocalPlayer.CharacterAdded:Connect(function(character)
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

toggleSnowflakes(true)