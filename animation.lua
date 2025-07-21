local AnimationChanger = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Close = Instance.new("TextButton")
local Minimize = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local TextLabel_2 = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

AnimationChanger.Name = "AnimationChanger"
AnimationChanger.Parent = game:WaitForChild("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.421999991, 0, -1, 0)
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
Close.MouseButton1Click:Connect(function()
    Main:TweenPosition(UDim2.new(0.421999991, 0, -1.28400004, 0))
    wait(0.3)
    AnimationChanger:Destroy()
end)

Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
Minimize.BorderSizePixel = 0
Minimize.Position = UDim2.new(0.8, 0, 0, 0)
Minimize.Size = UDim2.new(0, 30, 0, 30)
Minimize.Font = Enum.Font.SciFi
Minimize.Text = "_"
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.TextSize = 20

local minimized = false
Minimize.MouseButton1Click:Connect(function()
    if minimized then
        Main:TweenSize(UDim2.new(0, 300, 0, 350))
        ScrollingFrame.Visible = true
        minimized = false
    else
        Main:TweenSize(UDim2.new(0, 300, 0, 30))
        ScrollingFrame.Visible = false
        minimized = true
    end
end)

TextLabel.Parent = TopBar
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0, 0, 0.600000024, 0)
TextLabel.Size = UDim2.new(0, 270, 0, 10)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Made by Nyser#4623"
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
ScrollingFrame.Size = UDim2.new(0, 300, 0, 310)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)
ScrollingFrame.ScrollBarThickness = 5

UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local function createButton(name)
    local button = Instance.new("TextButton")
    button.Name = "A_" .. name
    button.Parent = ScrollingFrame
    button.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(0, 300, 0, 30)
    button.Font = Enum.Font.SciFi
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 20
    return button
end

local buttons = {
    "Astronaut", "Bubbly", "Cartoony", "Elder", "Knight", "Levitation", "Mage", "Ninja", "Pirate", "Robot",
    "Stylish", "SuperHero", "Toy", "Vampire", "Werewolf", "Zombie", "Patrol", "Confident", "Popstar", "Cowboy",
    "Ghost", "Sneaky", "Princess", "None", "Anthro"
}

local lastAnimation = nil

local function applyAnimation(animData)
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        local animate = character:FindFirstChild("Animate")
        if animate then
            for k, v in pairs(animData) do
                if animate:FindFirstChild(k) then
                    if animate[k]:FindFirstChild("Animation1") then
                        animate[k].Animation1.AnimationId = v[1]
                        if animate[k]:FindFirstChild("Animation2") then
                            animate[k].Animation2.AnimationId = v[2] or v[1]
                        end
                    else
                        animate[k][k.."Anim"].AnimationId = v[1]
                    end
                end
            end
            character.Humanoid.Jump = true
        end
    end
end

local function reconnectAnimations()
    local character = game.Players.LocalPlayer.Character
    if character then
        character:WaitForChild("Humanoid").Died:Connect(function()
            wait(1)
            if character and character:FindFirstChild("Humanoid") then
                character:WaitForChild("Animate")
                wait(0.5)
                if lastAnimation then
                    applyAnimation(lastAnimation)
                end
            end
        end)
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    reconnectAnimations()
    wait(1)
    if lastAnimation then
        applyAnimation(lastAnimation)
    end
end)

local animations = {
    Astronaut = {
        idle = {"http://www.roblox.com/asset/?id=891621366", "http://www.roblox.com/asset/?id=891633237"},
        walk = {"http://www.roblox.com/asset/?id=891667138"},
        run = {"http://www.roblox.com/asset/?id=891636393"},
        jump = {"http://www.roblox.com/asset/?id=891627522"},
        climb = {"http://www.roblox.com/asset/?id=891609353"},
        fall = {"http://www.roblox.com/asset/?id=891617961"}
    },
    Bubbly = {
        idle = {"http://www.roblox.com/asset/?id=910004836", "http://www.roblox.com/asset/?id=910009958"},
        walk = {"http://www.roblox.com/asset/?id=910034870"},
        run = {"http://www.roblox.com/asset/?id=910025107"},
        jump = {"http://www.roblox.com/asset/?id=910016857"},
        fall = {"http://www.roblox.com/asset/?id=910001910"},
        swimidle = {"http://www.roblox.com/asset/?id=910030921"},
        swim = {"http://www.roblox.com/asset/?id=910028158"}
    },
    Cartoony = {
        idle = {"http://www.roblox.com/asset/?id=742637544", "http://www.roblox.com/asset/?id=742638445"},
        walk = {"http://www.roblox.com/asset/?id=742640026"},
        run = {"http://www.roblox.com/asset/?id=742638842"},
        jump = {"http://www.roblox.com/asset/?id=742637942"},
        climb = {"http://www.roblox.com/asset/?id=742636889"},
        fall = {"http://www.roblox.com/asset/?id=742637151"}
    },
    Elder = {
        idle = {"http://www.roblox.com/asset/?id=845397899", "http://www.roblox.com/asset/?id=845400520"},
        walk = {"http://www.roblox.com/asset/?id=845403856"},
        run = {"http://www.roblox.com/asset/?id=845386501"},
        jump = {"http://www.roblox.com/asset/?id=845398858"},
        climb = {"http://www.roblox.com/asset/?id=845392038"},
        fall = {"http://www.roblox.com/asset/?id=845396048"}
    },
    Knight = {
        idle = {"http://www.roblox.com/asset/?id=657595757", "http://www.roblox.com/asset/?id=657568135"},
        walk = {"http://www.roblox.com/asset/?id=657552124"},
        run = {"http://www.roblox.com/asset/?id=657564596"},
        jump = {"http://www.roblox.com/asset/?id=658409194"},
        climb = {"http://www.roblox.com/asset/?id=658360781"},
        fall = {"http://www.roblox.com/asset/?id=657600338"}
    },
    Levitation = {
        idle = {"http://www.roblox.com/asset/?id=616006778", "http://www.roblox.com/asset/?id=616008087"},
        walk = {"http://www.roblox.com/asset/?id=616013216"},
        run = {"http://www.roblox.com/asset/?id=616010382"},
        jump = {"http://www.roblox.com/asset/?id=616008936"},
        climb = {"http://www.roblox.com/asset/?id=616003713"},
        fall = {"http://www.roblox.com/asset/?id=616005863"}
    },
    Mage = {
        idle = {"http://www.roblox.com/asset/?id=707742142", "http://www.roblox.com/asset/?id=707855907"},
        walk = {"http://www.roblox.com/asset/?id=707897309"},
        run = {"http://www.roblox.com/asset/?id=707861613"},
        jump = {"http://www.roblox.com/asset/?id=707853694"},
        climb = {"http://www.roblox.com/asset/?id=707826056"},
        fall = {"http://www.roblox.com/asset/?id=707829716"}
    },
    Ninja = {
        idle = {"http://www.roblox.com/asset/?id=656117400", "http://www.roblox.com/asset/?id=656118341"},
        walk = {"http://www.roblox.com/asset/?id=656121766"},
        run = {"http://www.roblox.com/asset/?id=656118852"},
        jump = {"http://www.roblox.com/asset/?id=656117878"},
        climb = {"http://www.roblox.com/asset/?id=656114359"},
        fall = {"http://www.roblox.com/asset/?id=656115606"}
    },
    Pirate = {
        idle = {"http://www.roblox.com/asset/?id=750781874", "http://www.roblox.com/asset/?id=750782770"},
        walk = {"http://www.roblox.com/asset/?id=750785693"},
        run = {"http://www.roblox.com/asset/?id=750783738"},
        jump = {"http://www.roblox.com/asset/?id=750782230"},
        climb = {"http://www.roblox.com/asset/?id=750779899"},
        fall = {"http://www.roblox.com/asset/?id=750780242"}
    },
    Robot = {
        idle = {"http://www.roblox.com/asset/?id=616088211", "http://www.roblox.com/asset/?id=616089559"},
        walk = {"http://www.roblox.com/asset/?id=616095330"},
        run = {"http://www.roblox.com/asset/?id=616091570"},
        jump = {"http://www.roblox.com/asset/?id=616090535"},
        climb = {"http://www.roblox.com/asset/?id=616086039"},
        fall = {"http://www.roblox.com/asset/?id=616087089"}
    },
    Stylish = {
        idle = {"http://www.roblox.com/asset/?id=616136790", "http://www.roblox.com/asset/?id=616138447"},
        walk = {"http://www.roblox.com/asset/?id=616146177"},
        run = {"http://www.roblox.com/asset/?id=616140816"},
        jump = {"http://www.roblox.com/asset/?id=616139451"},
        climb = {"http://www.roblox.com/asset/?id=616133594"},
        fall = {"http://www.roblox.com/asset/?id=616134815"}
    },
    SuperHero = {
        idle = {"http://www.roblox.com/asset/?id=616111295", "http://www.roblox.com/asset/?id=616113536"},
        walk = {"http://www.roblox.com/asset/?id=616122287"},
        run = {"http://www.roblox.com/asset/?id=616117076"},
        jump = {"http://www.roblox.com/asset/?id=616115533"},
        climb = {"http://www.roblox.com/asset/?id=616104706"},
        fall = {"http://www.roblox.com/asset/?id=616108001"}
    },
    Toy = {
        idle = {"http://www.roblox.com/asset/?id=782841498", "http://www.roblox.com/asset/?id=782845736"},
        walk = {"http://www.roblox.com/asset/?id=782843345"},
        run = {"http://www.roblox.com/asset/?id=782842708"},
        jump = {"http://www.roblox.com/asset/?id=782847020"},
        climb = {"http://www.roblox.com/asset/?id=782843869"},
        fall = {"http://www.roblox.com/asset/?id=782846423"}
    },
    Vampire = {
        idle = {"http://www.roblox.com/asset/?id=1083445855", "http://www.roblox.com/asset/?id=1083450166"},
        walk = {"http://www.roblox.com/asset/?id=1083473930"},
        run = {"http://www.roblox.com/asset/?id=1083462077"},
        jump = {"http://www.roblox.com/asset/?id=1083455352"},
        climb = {"http://www.roblox.com/asset/?id=1083439238"},
        fall = {"http://www.roblox.com/asset/?id=1083443587"}
    },
    Werewolf = {
        idle = {"http://www.roblox.com/asset/?id=1083195517", "http://www.roblox.com/asset/?id=1083214717"},
        walk = {"http://www.roblox.com/asset/?id=1083178339"},
        run = {"http://www.roblox.com/asset/?id=1083216690"},
        jump = {"http://www.roblox.com/asset/?id=1083218792"},
        climb = {"http://www.roblox.com/asset/?id=1083182000"},
        fall = {"http://www.roblox.com/asset/?id=1083189019"}
    },
    Zombie = {
        idle = {"http://www.roblox.com/asset/?id=616158929", "http://www.roblox.com/asset/?id=616160636"},
        walk = {"http://www.roblox.com/asset/?id=616168032"},
        run = {"http://www.roblox.com/asset/?id=616163682"},
        jump = {"http://www.roblox.com/asset/?id=616161997"},
        climb = {"http://www.roblox.com/asset/?id=616156119"},
        fall = {"http://www.roblox.com/asset/?id=616157476"}
    },
    Patrol = {
        idle = {"http://www.roblox.com/asset/?id=1149612882", "http://www.roblox.com/asset/?id=1150842221"},
        walk = {"http://www.roblox.com/asset/?id=1151231493"},
        run = {"http://www.roblox.com/asset/?id=1150967949"},
        jump = {"http://www.roblox.com/asset/?id=1148811837"},
        climb = {"http://www.roblox.com/asset/?id=1148811837"},
        fall = {"http://www.roblox.com/asset/?id=1148863382"}
    },
    Confident = {
        idle = {"http://www.roblox.com/asset/?id=1069977950", "http://www.roblox.com/asset/?id=1069987858"},
        walk = {"http://www.roblox.com/asset/?id=1070017263"},
        run = {"http://www.roblox.com/asset/?id=1070001516"},
        jump = {"http://www.roblox.com/asset/?id=1069984524"},
        climb = {"http://www.roblox.com/asset/?id=1069946257"},
        fall = {"http://www.roblox.com/asset/?id=1069973677"}
    },
    Popstar = {
        idle = {"http://www.roblox.com/asset/?id=1212900985", "http://www.roblox.com/asset/?id=1150842221"},
        walk = {"http://www.roblox.com/asset/?id=1212980338"},
        run = {"http://www.roblox.com/asset/?id=1212980348"},
        jump = {"http://www.roblox.com/asset/?id=1212954642"},
        climb = {"http://www.roblox.com/asset/?id=1213044953"},
        fall = {"http://www.roblox.com/asset/?id=1212900995"}
    },
    Cowboy = {
        idle = {"http://www.roblox.com/asset/?id=1014390418", "http://www.roblox.com/asset/?id=1014398616"},
        walk = {"http://www.roblox.com/asset/?id=1014421541"},
        run = {"http://www.roblox.com/asset/?id=1014401683"},
        jump = {"http://www.roblox.com/asset/?id=1014394726"},
        climb = {"http://www.roblox.com/asset/?id=1014380606"},
        fall = {"http://www.roblox.com/asset/?id=1014384571"}
    },
    Ghost = {
        idle = {"http://www.roblox.com/asset/?id=616006778", "http://www.roblox.com/asset/?id=616008087"},
        walk = {"http://www.roblox.com/asset/?id=616013216"},
        run = {"http://www.roblox.com/asset/?id=616013216"},
        jump = {"http://www.roblox.com/asset/?id=616008936"},
        fall = {"http://www.roblox.com/asset/?id=616005863"},
        swimidle = {"http://www.roblox.com/asset/?id=616012453"},
        swim = {"http://www.roblox.com/asset/?id=616011509"}
    },
    Sneaky = {
        idle = {"http://www.roblox.com/asset/?id=1132473842", "http://www.roblox.com/asset/?id=1132477671"},
        walk = {"http://www.roblox.com/asset/?id=1132510133"},
        run = {"http://www.roblox.com/asset/?id=1132494274"},
        jump = {"http://www.roblox.com/asset/?id=1132489853"},
        climb = {"http://www.roblox.com/asset/?id=1132461372"},
        fall = {"http://www.roblox.com/asset/?id=1132469004"}
    },
    Princess = {
        idle = {"http://www.roblox.com/asset/?id=941003647", "http://www.roblox.com/asset/?id=941013098"},
        walk = {"http://www.roblox.com/asset/?id=941028902"},
        run = {"http://www.roblox.com/asset/?id=941015281"},
        jump = {"http://www.roblox.com/asset/?id=941008832"},
        climb = {"http://www.roblox.com/asset/?id=940996062"},
        fall = {"http://www.roblox.com/asset/?id=941000007"}
    },
    None = {
        idle = {"http://www.roblox.com/asset/?id=0", "http://www.roblox.com/asset/?id=0"},
        walk = {"http://www.roblox.com/asset/?id=0"},
        run = {"http://www.roblox.com/asset/?id=0"},
        jump = {"http://www.roblox.com/asset/?id=0"},
        fall = {"http://www.roblox.com/asset/?id=0"},
        swimidle = {"http://www.roblox.com/asset/?id=0"},
        swim = {"http://www.roblox.com/asset/?id=0"}
    },
    Anthro = {
        idle = {"http://www.roblox.com/asset/?id=2510196951", "http://www.roblox.com/asset/?id=2510197257"},
        walk = {"http://www.roblox.com/asset/?id=2510202577"},
        run = {"http://www.roblox.com/asset/?id=2510198475"},
        jump = {"http://www.roblox.com/asset/?id=2510197830"},
        climb = {"http://www.roblox.com/asset/?id=2510192778"},
        fall = {"http://www.roblox.com/asset/?id=2510195892"}
    }
}

for _, buttonName in ipairs(buttons) do
    local button = createButton(buttonName)
    button.MouseButton1Click:Connect(function()
        lastAnimation = animations[buttonName]
        applyAnimation(lastAnimation)
    end)
end

reconnectAnimations()

wait(1)
Main:TweenPosition(UDim2.new(0.421999991, 0, 0.28400004, 0))