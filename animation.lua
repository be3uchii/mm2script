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
local Background = Instance.new("Frame")
local Gradient = Instance.new("UIGradient")

AnimationChanger.Name = "AnimationChanger"
AnimationChanger.Parent = game:GetService("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AnimationChanger.ResetOnSpawn = false

Background.Name = "Background"
Background.Parent = Main
Background.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Background.BackgroundTransparency = 0.2
Background.BorderSizePixel = 0
Background.Size = UDim2.new(1, 0, 1, 0)
Background.ZIndex = 0

Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 120)))
}
Gradient.Rotation = 90
Gradient.Parent = Background

Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.4, 0, -1, 0)
Main.Size = UDim2.new(0, 220, 0, 0)
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = Main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 150, 200)
mainStroke.Thickness = 2
mainStroke.Parent = Main

local glow = Instance.new("ImageLabel")
glow.Name = "Glow"
glow.Parent = Main
glow.BackgroundTransparency = 1
glow.Size = UDim2.new(1, 20, 1, 20)
glow.Position = UDim2.new(0, -10, 0, -10)
glow.Image = "rbxassetid://5028857084"
glow.ImageColor3 = Color3.fromRGB(0, 150, 200)
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(24, 24, 276, 276)
glow.ZIndex = -1

TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.ZIndex = 2

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 12)
topBarCorner.Parent = TopBar

local topBarStroke = Instance.new("UIStroke")
topBarStroke.Color = Color3.fromRGB(60, 60, 65)
topBarStroke.Thickness = 1
topBarStroke.Parent = TopBar

Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundTransparency = 1
Minimize.Position = UDim2.new(0.85, 0, 0.15, 0)
Minimize.Size = UDim2.new(0, 24, 0, 24)
Minimize.Image = "rbxassetid://3926305904"
Minimize.ImageRectOffset = Vector2.new(124, 204)
Minimize.ImageRectSize = Vector2.new(36, 36)
Minimize.ImageColor3 = Color3.fromRGB(180, 180, 180)
Minimize.ZIndex = 3

Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "ANIMATION PACKS"
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(0, 150, 200)
titleStroke.Thickness = 1
titleStroke.Parent = Title

Tab.Name = "Tab"
Tab.Parent = Main
Tab.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Tab.BorderSizePixel = 0
Tab.Position = UDim2.new(0, 0, 0, 36)
Tab.Size = UDim2.new(1, 0, 0, 250)
Tab.ClipsDescendants = true
Tab.ZIndex = 1

Category.Name = "Category"
Category.Parent = Tab
Category.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Category.BorderSizePixel = 0
Category.Size = UDim2.new(1, 0, 0, 30)
Category.Font = Enum.Font.GothamMedium
Category.Text = "  SELECT ANIMATION PACK"
Category.TextColor3 = Color3.fromRGB(0, 200, 255)
Category.TextSize = 12
Category.TextXAlignment = Enum.TextXAlignment.Left
Category.ZIndex = 2

local categoryCorner = Instance.new("UICorner")
categoryCorner.CornerRadius = UDim.new(0, 8)
categoryCorner.Parent = Category

local categoryStroke = Instance.new("UIStroke")
categoryStroke.Color = Color3.fromRGB(0, 150, 200)
categoryStroke.Thickness = 1
categoryStroke.Parent = Category

Buttons.Name = "Buttons"
Buttons.Parent = Tab
Buttons.BackgroundTransparency = 1
Buttons.Position = UDim2.new(0, 6, 0, 34)
Buttons.Size = UDim2.new(1, -12, 1, -34)
Buttons.ScrollBarThickness = 4
Buttons.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 200)
Buttons.CanvasSize = UDim2.new(0, 0, 0, 0)
Buttons.ZIndex = 1

UIListLayout.Parent = Buttons
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

Snowflakes.Name = "Snowflakes"
Snowflakes.Parent = Main

local function createButton(name)
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
    button.ZIndex = 2
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = Color3.fromRGB(60, 60, 65)
    buttonStroke.LineJoinMode = Enum.LineJoinMode.Round
    buttonStroke.Thickness = 1
    buttonStroke.Parent = button
    
    local buttonGlow = Instance.new("ImageLabel")
    buttonGlow.Name = "Glow"
    buttonGlow.Parent = button
    buttonGlow.BackgroundTransparency = 1
    buttonGlow.Size = UDim2.new(1, 10, 1, 10)
    buttonGlow.Position = UDim2.new(0, -5, 0, -5)
    buttonGlow.Image = "rbxassetid://5028857084"
    buttonGlow.ImageColor3 = Color3.fromRGB(0, 150, 200)
    buttonGlow.ImageTransparency = 1
    buttonGlow.ScaleType = Enum.ScaleType.Slice
    buttonGlow.SliceCenter = Rect.new(24, 24, 276, 276)
    buttonGlow.ZIndex = -1
    
    local hoverTween
    local clickTween
    
    button.MouseEnter:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 55),
            TextColor3 = Color3.fromRGB(240, 240, 240)
        })
        hoverTween:Play()
        
        TweenService:Create(buttonGlow, TweenInfo.new(0.3), {
            ImageTransparency = 0.7
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 45),
            TextColor3 = Color3.fromRGB(220, 220, 220)
        })
        hoverTween:Play()
        
        TweenService:Create(buttonGlow, TweenInfo.new(0.3), {
            ImageTransparency = 1
        }):Play()
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
            BackgroundColor3 = Color3.fromRGB(50, 50, 55),
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
        effect.ZIndex = -1
        
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
    Astronaut = {
        idle1 = "rbxassetid://891621366",
        idle2 = "rbxassetid://891633237",
        walk = "rbxassetid://891627522",
        run = "rbxassetid://891627522",
        jump = "rbxassetid://891617961",
        climb = "rbxassetid://891609353",
        fall = "rbxassetid://891614536"
    },
    Toy = {
        idle1 = "rbxassetid://782841498",
        idle2 = "rbxassetid://782842760",
        walk = "rbxassetid://782843345",
        run = "rbxassetid://782842760",
        jump = "rbxassetid://782843018",
        climb = "rbxassetid://782842498",
        fall = "rbxassetid://782842760"
    },
    Cartoony = {
        idle1 = "rbxassetid://742637544",
        idle2 = "rbxassetid://742638445",
        walk = "rbxassetid://742640026",
        run = "rbxassetid://742638853",
        jump = "rbxassetid://742637942",
        climb = "rbxassetid://742636889",
        fall = "rbxassetid://742637253"
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
        
        if animName == name then
            TweenService:Create(button:FindFirstChild("Glow"), TweenInfo.new(0.3), {
                ImageTransparency = 0.5
            }):Play()
        else
            TweenService:Create(button:FindFirstChild("Glow"), TweenInfo.new(0.3), {
                ImageTransparency = 1
            }):Play()
        end
    end
end

local function createSnowflake()
    local snowflake = Instance.new("ImageLabel")
    snowflake.Name = "Snowflake"
    snowflake.BackgroundTransparency = 1
    snowflake.Size = UDim2.new(0, math.random(6, 12), 0, math.random(6, 12))
    snowflake.Position = UDim2.new(0, math.random(0, 200), 0, -20)
    snowflake.Image = "rbxassetid://7151279853"
    snowflake.ImageTransparency = math.random(5, 8) / 10
    snowflake.Rotation = math.random(0, 360)
    snowflake.ZIndex = 0
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

local function toggleSnowflakes(enable)
    if enable then
        Snowflakes.Visible = true
        for i = 1, 20 do
            createSnowflake()
        end
        
        local snowflakeLoop
        snowflakeLoop = RunService.Heartbeat:Connect(function()
            if #Snowflakes:GetChildren() < 25 then
                createSnowflake()
            end
        end)
        
        return snowflakeLoop
    else
        Snowflakes.Visible = false
        for _, child in ipairs(Snowflakes:GetChildren()) do
            child:Destroy()
        end
        return nil
    end
end

local snowflakeLoop
local function toggleMenu()
    minimized = not minimized
    cancelAllTweens()
    
    if minimized then
        local tween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 220, 0, 36)
        })
        table.insert(activeTweens, tween)
        tween:Play()
        
        if snowflakeLoop then
            snowflakeLoop:Disconnect()
            snowflakeLoop = nil
        end
        toggleSnowflakes(false)
    else
        local tween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 220, 0, 286)
        })
        table.insert(activeTweens, tween)
        tween:Play()
        
        snowflakeLoop = toggleSnowflakes(true)
    end
    
    Minimize.ImageRectOffset = minimized and Vector2.new(84, 204) or Vector2.new(124, 204)
    
    local rotateTween = TweenService:Create(Minimize, TweenInfo.new(0.3), {
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
    Size = UDim2.new(0, 220, 0, 286)
})
openTween:Play()

RunService.Heartbeat:Connect(function()
    Buttons.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)

toggleSnowflakes(true)