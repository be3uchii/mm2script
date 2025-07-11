local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Settings = {
    Menu = {
        Open = false,
        Position = UDim2.new(0.5, -150, 0.5, -175),
        Size = UDim2.new(0, 300, 0, 400)
    },
    ESP = {
        Enabled = false,
        Sheriff = {
            Enabled = false,
            Color = Color3.fromRGB(0, 0, 255),
            ThroughWalls = true
        },
        Murderer = {
            Enabled = false,
            Color = Color3.fromRGB(255, 0, 0),
            ThroughWalls = true
        },
        Innocent = {
            Enabled = false,
            Color = Color3.fromRGB(0, 255, 0),
            ThroughWalls = false
        },
        Gun = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 0),
            ThroughWalls = true
        },
        Coin = {
            Enabled = false,
            Color = Color3.fromRGB(255, 215, 0),
            ThroughWalls = false
        }
    },
    Sheriff = {
        AimAssist = {
            Enabled = false,
            FOV = 50,
            Visible = false,
            Smoothness = 0.2,
            Button = {
                Size = UDim2.new(0, 50, 0, 50),
                Position = UDim2.new(0.5, -25, 0.8, -25),
                Color = Color3.fromRGB(0, 150, 255),
                Transparency = 0.5
            }
        }
    },
    Murderer = {
        KillAura = {
            Enabled = false,
            Range = 15
        }
    }
}

local GUI, FOVCircle, AimButton, MenuButton
local Sheriff, Murderer
local ESPCache = {}
local Connections = {}

local function CreateGUI()
    GUI = Instance.new("ScreenGui")
    GUI.Name = "MM2ScriptGUI"
    GUI.ResetOnSpawn = false
    GUI.Parent = Player.PlayerGui

    MenuButton = Instance.new("TextButton")
    MenuButton.Name = "MenuButton"
    MenuButton.Size = UDim2.new(0, 40, 0, 40)
    MenuButton.Position = UDim2.new(0, 10, 0, 10)
    MenuButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    MenuButton.Text = "M"
    MenuButton.TextColor3 = Color3.new(1, 1, 1)
    MenuButton.Font = Enum.Font.SourceSansBold
    MenuButton.TextSize = 20
    MenuButton.Parent = GUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Settings.Menu.Size
    MainFrame.Position = Settings.Menu.Position
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = Settings.Menu.Open
    MainFrame.Parent = GUI

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.BorderSizePixel = 0
    Title.Text = "MM2 Script"
    Title.TextColor3 = Color3.new(1, 1, 1)
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

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -10, 1, -40)
    TabContainer.Position = UDim2.new(0, 5, 0, 35)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    local ESPContainer = Instance.new("ScrollingFrame")
    ESPContainer.Name = "ESPContainer"
    ESPContainer.Size = UDim2.new(1, 0, 1, 0)
    ESPContainer.BackgroundTransparency = 1
    ESPContainer.ScrollBarThickness = 5
    ESPContainer.CanvasSize = UDim2.new(0, 0, 0, 300)
    ESPContainer.Visible = true
    ESPContainer.Parent = TabContainer

    local function CreateToggle(parent, name, setting, yOffset)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = name .. "Toggle"
        toggleFrame.Size = UDim2.new(1, -10, 0, 30)
        toggleFrame.Position = UDim2.new(0, 5, 0, yOffset)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = parent

        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "ToggleButton"
        toggleButton.Size = UDim2.new(0, 100, 0, 25)
        toggleButton.Position = UDim2.new(1, -105, 0, 0)
        toggleButton.BackgroundColor3 = setting.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = setting.Enabled and "ON" or "OFF"
        toggleButton.TextColor3 = Color3.new(1, 1, 1)
        toggleButton.Font = Enum.Font.SourceSans
        toggleButton.TextSize = 14
        toggleButton.Parent = toggleFrame

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(0, 180, 0, 25)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame

        toggleButton.MouseButton1Click:Connect(function()
            setting.Enabled = not setting.Enabled
            toggleButton.BackgroundColor3 = setting.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            toggleButton.Text = setting.Enabled and "ON" or "OFF"
        end)

        return toggleFrame
    end

    local yOffset = 0
    CreateToggle(ESPContainer, "ESP", Settings.ESP, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Sheriff", Settings.ESP.Sheriff, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Murderer", Settings.ESP.Murderer, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Players", Settings.ESP.Innocent, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Gun", Settings.ESP.Gun, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Coins", Settings.ESP.Coin, yOffset)

    MenuButton.MouseButton1Click:Connect(function()
        Settings.Menu.Open = not Settings.Menu.Open
        MainFrame.Visible = Settings.Menu.Open
    end)

    CloseButton.MouseButton1Click:Connect(function()
        Settings.Menu.Open = false
        MainFrame.Visible = false
    end)
end

local function CreateESP(object, color, throughWalls)
    if ESPCache[object] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = object.Name .. "ESP"
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = throughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    highlight.Parent = object

    ESPCache[object] = highlight

    object.AncestryChanged:Connect(function()
        if not object:IsDescendantOf(game) and ESPCache[object] then
            ESPCache[object]:Destroy()
            ESPCache[object] = nil
        end
    end)
end

local function RemoveESP(object)
    if ESPCache[object] then
        ESPCache[object]:Destroy()
        ESPCache[object] = nil
    end
end

local function UpdateESP()
    if not Settings.ESP.Enabled then
        for object, _ in pairs(ESPCache) do
            RemoveESP(object)
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            if player == Sheriff and Settings.ESP.Sheriff.Enabled then
                CreateESP(player.Character, Settings.ESP.Sheriff.Color, Settings.ESP.Sheriff.ThroughWalls)
            elseif player == Murderer and Settings.ESP.Murderer.Enabled then
                CreateESP(player.Character, Settings.ESP.Murderer.Color, Settings.ESP.Murderer.ThroughWalls)
            elseif Settings.ESP.Innocent.Enabled then
                CreateESP(player.Character, Settings.ESP.Innocent.Color, Settings.ESP.Innocent.ThroughWalls)
            else
                RemoveESP(player.Character)
            end
        end
    end

    if Settings.ESP.Gun.Enabled then
        local gun = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChildOfClass("Tool")
        if gun then
            CreateESP(gun, Settings.ESP.Gun.Color, Settings.ESP.Gun.ThroughWalls)
        end
    end

    if Settings.ESP.Coin.Enabled then
        for _, coin in ipairs(workspace:GetChildren()) do
            if coin.Name:find("Coin") or coin.Name:find("Diamond") then
                CreateESP(coin, Settings.ESP.Coin.Color, Settings.ESP.Coin.ThroughWalls)
            end
        end
    end
end

local function FindRoles()
    Sheriff = nil
    Murderer = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
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

local function KillAura()
    if not Settings.Murderer.KillAura.Enabled or not Murderer or Murderer ~= Player then return end
    if not Player.Character then return end

    local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    for _, player in ipairs(Players:GetPlayers()) do
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

local function MainLoop()
    FindRoles()
    UpdateESP()
    KillAura()
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
    if child.Name:find("Coin") or child.Name:find("Diamond") or child.Name == "GunDrop" then
        UpdateESP()
    end
end))

table.insert(Connections, RunService.RenderStepped:Connect(MainLoop))

Player.CharacterRemoving:Connect(function()
    for _, conn in ipairs(Connections) do
        conn:Disconnect()
    end
    
    for _, esp in pairs(ESPCache) do
        esp:Destroy()
    end
    
    if GUI then
        GUI:Destroy()
    end
end)
