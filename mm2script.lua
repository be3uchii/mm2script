local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Settings = {
    Menu = {
        Open = true,
        Minimized = false,
        Position = UDim2.new(0.5, -175, 0.5, -200),
        Size = UDim2.new(0, 350, 0, 450),
        MinimizedSize = UDim2.new(0, 350, 0, 30),
        AccentColor = Color3.fromRGB(0, 150, 255)
    },
    
    ESP = {
        Enabled = true,
        MaxDistance = 1000,
        Sheriff = {
            Enabled = true,
            Color = Color3.fromRGB(0, 0, 255),
            ThroughWalls = true,
            Tracer = true,
            Box = true,
            Name = true,
            Distance = true
        },
        Murderer = {
            Enabled = true,
            Color = Color3.fromRGB(255, 0, 0),
            ThroughWalls = true,
            Tracer = true,
            Box = true,
            Name = true,
            Distance = true
        },
        Innocent = {
            Enabled = true,
            Color = Color3.fromRGB(0, 255, 0),
            ThroughWalls = true,
            Tracer = false,
            Box = true,
            Name = true,
            Distance = true
        },
        Gun = {
            Enabled = true,
            Color = Color3.fromRGB(255, 255, 0),
            ThroughWalls = true
        },
        Coin = {
            Enabled = true,
            Color = Color3.fromRGB(255, 215, 0),
            ThroughWalls = true
        }
    },
    
    Sheriff = {
        AutoShoot = {
            Enabled = true,
            Key = "C",
            Visible = true,
            Position = UDim2.new(0.8, -25, 0.7, -25)
        },
        AimAssist = {
            Enabled = true,
            FOV = 60,
            Visible = true,
            Smoothness = 0.15,
            Prediction = 0.15
        }
    },
    
    Murderer = {
        KillAura = {
            Enabled = true,
            Range = 18,
            Cooldown = 0.5
        },
        Speed = {
            Enabled = false,
            Value = 25
        }
    }
}

local GUI, FOVCircle, AutoShootButton, MenuButton
local Sheriff, Murderer
local ESPCache = {}
local Connections = {}

local function CreateESP(object, color, settings)
    if ESPCache[object] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = object.Name.."ESP"
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.DepthMode = settings.ThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    highlight.Parent = object
    
    if settings.Box then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Adornee = object
        box.AlwaysOnTop = settings.ThroughWalls
        box.ZIndex = 10
        box.Size = object:IsA("BasePart") and object.Size or Vector3.new(2, 2, 2)
        box.Transparency = 0.5
        box.Color3 = color
        box.Parent = object
    end
    
    ESPCache[object] = {
        Highlight = highlight,
        Connections = {}
    }
    
    if settings.Name or settings.Distance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.Adornee = object
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.Parent = object
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "ESPName"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = settings.Name and object.Name or ""
        nameLabel.TextColor3 = color
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 14
        nameLabel.Parent = billboard
        
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "ESPDistance"
        distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = color
        distanceLabel.Font = Enum.Font.SourceSans
        distanceLabel.TextSize = 12
        distanceLabel.Parent = billboard
        
        ESPCache[object].Billboard = billboard
    end
    
    object.AncestryChanged:Connect(function()
        if not object:IsDescendantOf(game) then
            RemoveESP(object)
        end
    end)
end

local function RemoveESP(object)
    if not ESPCache[object] then return end
    
    for _,v in pairs(ESPCache[object].Connections) do
        v:Disconnect()
    end
    
    if ESPCache[object].Highlight then
        ESPCache[object].Highlight:Destroy()
    end
    
    if ESPCache[object].Billboard then
        ESPCache[object].Billboard:Destroy()
    end
    
    if object:FindFirstChild("ESPBox") then
        object.ESPBox:Destroy()
    end
    
    ESPCache[object] = nil
end

local function UpdateESP()
    if not Settings.ESP.Enabled then
        for object,_ in pairs(ESPCache) do
            RemoveESP(object)
        end
        return
    end

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                if player == Sheriff and Settings.ESP.Sheriff.Enabled then
                    CreateESP(rootPart, Settings.ESP.Sheriff.Color, Settings.ESP.Sheriff)
                elseif player == Murderer and Settings.ESP.Murderer.Enabled then
                    CreateESP(rootPart, Settings.ESP.Murderer.Color, Settings.ESP.Murderer)
                elseif Settings.ESP.Innocent.Enabled then
                    CreateESP(rootPart, Settings.ESP.Innocent.Color, Settings.ESP.Innocent)
                else
                    RemoveESP(rootPart)
                end
                
                if ESPCache[rootPart] and ESPCache[rootPart].Billboard then
                    local distance = (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) and 
                                   (rootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude or 0
                    ESPCache[rootPart].Billboard.ESPDistance.Text = Settings.ESP.Distance and tostring(math.floor(distance)).."m" or ""
                end
            else
                RemoveESP(rootPart)
            end
        end
    end

    if Settings.ESP.Gun.Enabled then
        for _,gun in ipairs(workspace:GetChildren()) do
            if gun.Name == "GunDrop" or gun:IsA("Tool") then
                CreateESP(gun, Settings.ESP.Gun.Color, {
                    ThroughWalls = Settings.ESP.Gun.ThroughWalls,
                    Box = true,
                    Name = false,
                    Distance = false
                })
            end
        end
    end

    if Settings.ESP.Coin.Enabled then
        for _,coin in ipairs(workspace:GetChildren()) do
            if coin.Name:find("Coin") or coin.Name:find("Diamond") then
                CreateESP(coin, Settings.ESP.Coin.Color, {
                    ThroughWalls = Settings.ESP.Coin.ThroughWalls,
                    Box = false,
                    Name = false,
                    Distance = false
                })
            end
        end
    end
end

local function FindRoles()
    Sheriff = nil
    Murderer = nil
    
    for _,player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local knife = player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
            local gun = player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
            
            if knife then
                Murderer = player
            elseif gun then
                Sheriff = player
            end
        end
    end
end

local function AutoShoot()
    if not Settings.Sheriff.AutoShoot.Enabled or not AutoShootButton or not Sheriff or Sheriff ~= Player then return end
    if not Player.Character then return end
    
    local gun = Player.Character:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
    if not gun then return end
    
    if Murderer and Murderer.Character then
        local targetHRP = Murderer.Character:FindFirstChild("HumanoidRootPart")
        local localHRP = Player.Character:FindFirstChild("HumanoidRootPart")
        
        if targetHRP and localHRP then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetHRP.Position)
            if onScreen then
                local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local mousePos = Vector2.new(screenPos.X, screenPos.Y)
                local distance = (mousePos - center).Magnitude
                
                if distance <= Settings.Sheriff.AimAssist.FOV then
                    local args = {
                        [1] = targetHRP.Position,
                        [2] = gun:FindFirstChild("Handle") or gun
                    }
                    game:GetService("ReplicatedStorage"):FindFirstChild("ShootGun"):FireServer(unpack(args))
                end
            end
        end
    end
end

local function KillAura()
    if not Settings.Murderer.KillAura.Enabled or not Murderer or Murderer ~= Player then return end
    if not Player.Character then return end
    
    local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local distance = (humanoidRootPart.Position - targetHRP.Position).Magnitude
                if distance <= Settings.Murderer.KillAura.Range then
                    local args = {
                        [1] = player.Character:FindFirstChildOfClass("Humanoid"),
                        [2] = Player.Character:FindFirstChild("Knife")
                    }
                    game:GetService("ReplicatedStorage"):FindFirstChild("KnifeHit"):FireServer(unpack(args))
                end
            end
        end
    end
end

local function CreateToggle(parent, name, setting, yOffset)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name.."Toggle"
    toggleFrame.Size = UDim2.new(1, -10, 0, 30)
    toggleFrame.Position = UDim2.new(0, 5, 0, yOffset)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 100, 0, 25)
    toggleButton.Position = UDim2.new(1, -105, 0, 0)
    toggleButton.BackgroundColor3 = setting.Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = setting.Enabled and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 14
    toggleButton.Parent = toggleFrame

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 180, 0, 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    toggleButton.MouseButton1Click:Connect(function()
        setting.Enabled = not setting.Enabled
        toggleButton.BackgroundColor3 = setting.Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleButton.Text = setting.Enabled and "ON" or "OFF"
    end)

    return toggleFrame
end

local function CreateSlider(parent, name, setting, min, max, yOffset)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name.."Slider"
    sliderFrame.Size = UDim2.new(1, -10, 0, 50)
    sliderFrame.Position = UDim2.new(0, 5, 0, yOffset)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = "SliderLabel"
    sliderLabel.Size = UDim2.new(1, 0, 0, 25)
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name..": "..tostring(setting)
    sliderLabel.TextColor3 = Color3.new(1, 1, 1)
    sliderLabel.Font = Enum.Font.SourceSansBold
    sliderLabel.TextSize = 16
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderFrame

    local sliderBox = Instance.new("TextBox")
    sliderBox.Name = "SliderBox"
    sliderBox.Size = UDim2.new(0, 100, 0, 25)
    sliderBox.Position = UDim2.new(1, -105, 0, 0)
    sliderBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBox.BorderSizePixel = 0
    sliderBox.Text = tostring(setting)
    sliderBox.TextColor3 = Color3.new(1, 1, 1)
    sliderBox.Font = Enum.Font.SourceSans
    sliderBox.TextSize = 14
    sliderBox.Parent = sliderFrame

    sliderBox.FocusLost:Connect(function()
        local num = tonumber(sliderBox.Text)
        if num then
            setting = math.clamp(num, min, max)
            sliderBox.Text = tostring(setting)
            sliderLabel.Text = name..": "..tostring(setting)
        else
            sliderBox.Text = tostring(setting)
        end
    end)

    return sliderFrame
end

local function CreateGUI()
    GUI = Instance.new("ScreenGui")
    GUI.Name = "MM2UltimateGUI"
    GUI.ResetOnSpawn = false
    GUI.Parent = Player.PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Settings.Menu.Open and (Settings.Menu.Minimized and Settings.Menu.MinimizedSize or Settings.Menu.Size)
    MainFrame.Position = Settings.Menu.Position
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = true
    MainFrame.Parent = GUI

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Title.BorderSizePixel = 0
    Title.Text = "MM2 Ultimate"
    Title.TextColor3 = Settings.Menu.AccentColor
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.Parent = MainFrame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 18
    CloseButton.Parent = MainFrame

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = Settings.Menu.Minimized and "+" or "-"
    MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.TextSize = 18
    MinimizeButton.Parent = MainFrame

    local TabButtons = Instance.new("Frame")
    TabButtons.Name = "TabButtons"
    TabButtons.Size = UDim2.new(1, 0, 0, 30)
    TabButtons.Position = UDim2.new(0, 0, 0, 30)
    TabButtons.BackgroundTransparency = 1
    TabButtons.Visible = not Settings.Menu.Minimized
    TabButtons.Parent = MainFrame

    local ESPTab = Instance.new("TextButton")
    ESPTab.Name = "ESPTab"
    ESPTab.Size = UDim2.new(0.33, -2, 1, 0)
    ESPTab.Position = UDim2.new(0, 0, 0, 0)
    ESPTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ESPTab.BorderSizePixel = 0
    ESPTab.Text = "ESP"
    ESPTab.TextColor3 = Color3.new(1, 1, 1)
    ESPTab.Font = Enum.Font.SourceSansBold
    ESPTab.TextSize = 14
    ESPTab.Parent = TabButtons

    local SheriffTab = Instance.new("TextButton")
    SheriffTab.Name = "SheriffTab"
    SheriffTab.Size = UDim2.new(0.33, -2, 1, 0)
    SheriffTab.Position = UDim2.new(0.33, 0, 0, 0)
    SheriffTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SheriffTab.BorderSizePixel = 0
    SheriffTab.Text = "Sheriff"
    SheriffTab.TextColor3 = Color3.new(1, 1, 1)
    SheriffTab.Font = Enum.Font.SourceSansBold
    SheriffTab.TextSize = 14
    SheriffTab.Parent = TabButtons

    local MurdererTab = Instance.new("TextButton")
    MurdererTab.Name = "MurdererTab"
    MurdererTab.Size = UDim2.new(0.33, -2, 1, 0)
    MurdererTab.Position = UDim2.new(0.66, 0, 0, 0)
    MurdererTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MurdererTab.BorderSizePixel = 0
    MurdererTab.Text = "Murderer"
    MurdererTab.TextColor3 = Color3.new(1, 1, 1)
    MurdererTab.Font = Enum.Font.SourceSansBold
    MurdererTab.TextSize = 14
    MurdererTab.Parent = TabButtons

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -10, 1, -70)
    TabContainer.Position = UDim2.new(0, 5, 0, 65)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Visible = not Settings.Menu.Minimized
    TabContainer.Parent = MainFrame

    local ESPContainer = Instance.new("ScrollingFrame")
    ESPContainer.Name = "ESPContainer"
    ESPContainer.Size = UDim2.new(1, 0, 1, 0)
    ESPContainer.BackgroundTransparency = 1
    ESPContainer.ScrollBarThickness = 5
    ESPContainer.CanvasSize = UDim2.new(0, 0, 0, 350)
    ESPContainer.Visible = true
    ESPContainer.Parent = TabContainer

    local SheriffContainer = Instance.new("ScrollingFrame")
    SheriffContainer.Name = "SheriffContainer"
    SheriffContainer.Size = UDim2.new(1, 0, 1, 0)
    SheriffContainer.BackgroundTransparency = 1
    SheriffContainer.ScrollBarThickness = 5
    SheriffContainer.CanvasSize = UDim2.new(0, 0, 0, 300)
    SheriffContainer.Visible = false
    SheriffContainer.Parent = TabContainer

    local MurdererContainer = Instance.new("ScrollingFrame")
    MurdererContainer.Name = "MurdererContainer"
    MurdererContainer.Size = UDim2.new(1, 0, 1, 0)
    MurdererContainer.BackgroundTransparency = 1
    MurdererContainer.ScrollBarThickness = 5
    MurdererContainer.CanvasSize = UDim2.new(0, 0, 0, 200)
    MurdererContainer.Visible = false
    MurdererContainer.Parent = TabContainer

    local yOffset = 0
    CreateToggle(ESPContainer, "ESP", Settings.ESP, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Sheriff ESP", Settings.ESP.Sheriff, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Murderer ESP", Settings.ESP.Murderer, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Innocent ESP", Settings.ESP.Innocent, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Gun ESP", Settings.ESP.Gun, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Coin ESP", Settings.ESP.Coin, yOffset)

    yOffset = 0
    CreateToggle(SheriffContainer, "Auto Shoot", Settings.Sheriff.AutoShoot, yOffset)
    yOffset = yOffset + 35
    CreateToggle(SheriffContainer, "Aim Assist", Settings.Sheriff.AimAssist, yOffset)
    yOffset = yOffset + 35
    CreateSlider(SheriffContainer, "FOV", Settings.Sheriff.AimAssist.FOV, 10, 200, yOffset)
    yOffset = yOffset + 55
    CreateSlider(SheriffContainer, "Smoothness", Settings.Sheriff.AimAssist.Smoothness, 0.1, 1, yOffset)
    yOffset = yOffset + 55
    CreateToggle(SheriffContainer, "Show FOV", Settings.Sheriff.AimAssist, yOffset)

    yOffset = 0
    CreateToggle(MurdererContainer, "Kill Aura", Settings.Murderer.KillAura, yOffset)
    yOffset = yOffset + 35
    CreateSlider(MurdererContainer, "Range", Settings.Murderer.KillAura.Range, 5, 30, yOffset)
    yOffset = yOffset + 55
    CreateToggle(MurdererContainer, "Speed Hack", Settings.Murderer.Speed, yOffset)
    yOffset = yOffset + 35
    CreateSlider(MurdererContainer, "Speed Value", Settings.Murderer.Speed.Value, 16, 50, yOffset)

    FOVCircle = Instance.new("Frame")
    FOVCircle.Name = "FOVCircle"
    FOVCircle.Size = UDim2.new(0, Settings.Sheriff.AimAssist.FOV * 2, 0, Settings.Sheriff.AimAssist.FOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -Settings.Sheriff.AimAssist.FOV, 0.5, -Settings.Sheriff.AimAssist.FOV)
    FOVCircle.BackgroundTransparency = 0.9
    FOVCircle.BackgroundColor3 = Settings.Menu.AccentColor
    FOVCircle.BorderSizePixel = 0
    FOVCircle.Visible = Settings.Sheriff.AimAssist.Enabled and Settings.Sheriff.AimAssist.Visible and not Settings.Menu.Minimized
    FOVCircle.Parent = GUI

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = FOVCircle

    AutoShootButton = Instance.new("TextButton")
    AutoShootButton.Name = "AutoShootButton"
    AutoShootButton.Size = UDim2.new(0, 50, 0, 50)
    AutoShootButton.Position = Settings.Sheriff.AutoShoot.Position
    AutoShootButton.BackgroundColor3 = Settings.Menu.AccentColor
    AutoShootButton.BackgroundTransparency = 0.5
    AutoShootButton.BorderSizePixel = 0
    AutoShootButton.Text = Settings.Sheriff.AutoShoot.Key
    AutoShootButton.TextColor3 = Color3.new(1, 1, 1)
    AutoShootButton.Font = Enum.Font.SourceSansBold
    AutoShootButton.TextSize = 20
    AutoShootButton.Visible = Settings.Sheriff.AutoShoot.Enabled and Settings.Sheriff.AutoShoot.Visible
    AutoShootButton.Active = true
    AutoShootButton.Draggable = true
    AutoShootButton.Parent = GUI

    local shootCorner = Instance.new("UICorner")
    shootCorner.CornerRadius = UDim.new(0.5, 0)
    shootCorner.Parent = AutoShootButton

    MenuButton = Instance.new("TextButton")
    MenuButton.Name = "MenuButton"
    MenuButton.Size = UDim2.new(0, 40, 0, 40)
    MenuButton.Position = UDim2.new(0, 10, 0, 10)
    MenuButton.BackgroundColor3 = Settings.Menu.AccentColor
    MenuButton.Text = "M"
    MenuButton.TextColor3 = Color3.new(1, 1, 1)
    MenuButton.Font = Enum.Font.SourceSansBold
    MenuButton.TextSize = 20
    MenuButton.Parent = GUI

    CloseButton.MouseButton1Click:Connect(function()
        GUI:Destroy()
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        Settings.Menu.Minimized = not Settings.Menu.Minimized
        MainFrame.Size = Settings.Menu.Minimized and Settings.Menu.MinimizedSize or Settings.Menu.Size
        MinimizeButton.Text = Settings.Menu.Minimized and "+" or "-"
        TabButtons.Visible = not Settings.Menu.Minimized
        TabContainer.Visible = not Settings.Menu.Minimized
        FOVCircle.Visible = Settings.Sheriff.AimAssist.Enabled and Settings.Sheriff.AimAssist.Visible and not Settings.Menu.Minimized
    end)

    ESPTab.MouseButton1Click:Connect(function()
        ESPContainer.Visible = true
        SheriffContainer.Visible = false
        MurdererContainer.Visible = false
    end)

    SheriffTab.MouseButton1Click:Connect(function()
        ESPContainer.Visible = false
        SheriffContainer.Visible = true
        MurdererContainer.Visible = false
        AutoShootButton.Visible = Settings.Sheriff.AutoShoot.Enabled and Settings.Sheriff.AutoShoot.Visible
    end)

    MurdererTab.MouseButton1Click:Connect(function()
        ESPContainer.Visible = false
        SheriffContainer.Visible = false
        MurdererContainer.Visible = true
    end)

    MenuButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        FOVCircle.Visible = Settings.Sheriff.AimAssist.Enabled and Settings.Sheriff.AimAssist.Visible and MainFrame.Visible and not Settings.Menu.Minimized
    end)

    AutoShootButton.MouseButton1Down:Connect(function()
        while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Settings.Sheriff.AutoShoot.Enabled do
            AutoShoot()
            wait(0.1)
        end
    end)

    AutoShootButton.Changed:Connect(function(prop)
        if prop == "Position" then
            Settings.Sheriff.AutoShoot.Position = AutoShootButton.Position
        end
    end)
end

local function MainLoop()
    FindRoles()
    UpdateESP()
    
    if Settings.Sheriff.AutoShoot.Enabled and Player == Sheriff then
        AutoShootButton.Visible = Settings.Sheriff.AutoShoot.Visible
    else
        AutoShootButton.Visible = false
    end
    
    if Settings.Murderer.KillAura.Enabled and Player == Murderer then
        KillAura()
    end
    
    if Settings.Murderer.Speed.Enabled and Player == Murderer and Player.Character then
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.Murderer.Speed.Value
        end
    end
    
    if FOVCircle then
        FOVCircle.Size = UDim2.new(0, Settings.Sheriff.AimAssist.FOV * 2, 0, Settings.Sheriff.AimAssist.FOV * 2)
        FOVCircle.Position = UDim2.new(0.5, -Settings.Sheriff.AimAssist.FOV, 0.5, -Settings.Sheriff.AimAssist.FOV)
        FOVCircle.Visible = Settings.Sheriff.AimAssist.Enabled and Settings.Sheriff.AimAssist.Visible and not Settings.Menu.Minimized
    end
end

CreateGUI()

table.insert(Connections, Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        UpdateESP()
    end)
end))

table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
    if player == Sheriff then Sheriff = nil end
    if player == Murderer then Murderer = nil end
    UpdateESP()
end))

table.insert(Connections, workspace.ChildAdded:Connect(function(child)
    if child.Name:find("Coin") or child.Name:find("Diamond") or child.Name == "GunDrop" or child:IsA("Tool") then
        UpdateESP()
    end
end))

table.insert(Connections, RunService.RenderStepped:Connect(MainLoop))

Player.CharacterRemoving:Connect(function()
    for _, conn in ipairs(Connections) do
        conn:Disconnect()
    end
    
    for _, esp in pairs(ESPCache) do
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
    end
    
    if GUI then
        GUI:Destroy()
    end
end)
