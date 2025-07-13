local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera

-- Удаляем старое меню
if CoreGui:FindFirstChild("MM2ProMenu") then CoreGui:FindFirstChild("MM2ProMenu"):Destroy() end

-- Загрузочный экран
local LoadScreen = Instance.new("ScreenGui")
LoadScreen.Name = "MM2Loader"
LoadScreen.Parent = CoreGui

local LoadFrame = Instance.new("Frame")
LoadFrame.Size = UDim2.new(1, 0, 1, 0)
LoadFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
LoadFrame.BackgroundTransparency = 0.2
LoadFrame.BorderSizePixel = 0
LoadFrame.ZIndex = 10
LoadFrame.Parent = LoadScreen

local LoadContainer = Instance.new("Frame")
LoadContainer.Size = UDim2.new(0.8, 0, 0.3, 0)
LoadContainer.Position = UDim2.new(0.1, 0, 0.35, 0)
LoadContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
LoadContainer.BorderSizePixel = 0
LoadContainer.Parent = LoadFrame

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Size = UDim2.new(1, 0, 0.4, 0)
LoadTitle.Position = UDim2.new(0, 0, 0, 0)
LoadTitle.Text = "MM2 PRO LOADING"
LoadTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextSize = 24
LoadTitle.BackgroundTransparency = 1
LoadTitle.Parent = LoadContainer

local LoadBarBG = Instance.new("Frame")
LoadBarBG.Size = UDim2.new(0.9, 0, 0.15, 0)
LoadBarBG.Position = UDim2.new(0.05, 0, 0.5, 0)
LoadBarBG.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
LoadBarBG.BorderSizePixel = 0
LoadBarBG.Parent = LoadContainer

local LoadBar = Instance.new("Frame")
LoadBar.Size = UDim2.new(0, 0, 1, 0)
LoadBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
LoadBar.BorderSizePixel = 0
LoadBar.ZIndex = 2
LoadBar.Parent = LoadBarBG

local LoadText = Instance.new("TextLabel")
LoadText.Size = UDim2.new(1, 0, 0.3, 0)
LoadText.Position = UDim2.new(0, 0, 0.7, 0)
LoadText.Text = "Initializing..."
LoadText.TextColor3 = Color3.fromRGB(200, 200, 255)
LoadText.Font = Enum.Font.Gotham
LoadText.TextSize = 18
LoadText.BackgroundTransparency = 1
LoadText.Parent = LoadContainer

local loadSteps = {
    "Loading assets",
    "Initializing modules",
    "Preparing UI",
    "Setting up ESP",
    "Configuring FOV",
    "Finalizing"
}

for i = 1, 100 do
    LoadBar.Size = UDim2.new(i/100, 0, 1, 0)
    if i % 16 == 0 then
        LoadText.Text = loadSteps[math.floor(i/16)+1] or "Almost done..."
    end
    wait(0.03)
end

wait(0.5)
LoadScreen:Destroy()

-- Основное меню
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2ProMenu"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 320) -- Открыто по умолчанию
MainFrame.Position = UDim2.new(0.5, -175, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "MM2 PRO"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(1, -40, 0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
ToggleButton.BorderSizePixel = 0
ToggleButton.Image = "rbxassetid://3926305904"
ToggleButton.ImageRectOffset = Vector2.new(884, 4)
ToggleButton.ImageRectSize = Vector2.new(36, 36)
ToggleButton.Parent = MainFrame

local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(0, 40, 1, -40)
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local GeneralTab = Instance.new("ImageButton")
GeneralTab.Name = "GeneralTab"
GeneralTab.Size = UDim2.new(0, 40, 0, 40)
GeneralTab.Position = UDim2.new(0, 0, 0, 0)
GeneralTab.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
GeneralTab.BorderSizePixel = 0
GeneralTab.Image = "rbxassetid://3926305904"
GeneralTab.ImageRectOffset = Vector2.new(964, 324)
GeneralTab.ImageRectSize = Vector2.new(36, 36)
GeneralTab.Parent = TabButtons

local MurdererTab = Instance.new("ImageButton")
MurdererTab.Name = "MurdererTab"
MurdererTab.Size = UDim2.new(0, 40, 0, 40)
MurdererTab.Position = UDim2.new(0, 0, 0, 40)
MurdererTab.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
MurdererTab.BorderSizePixel = 0
MurdererTab.Image = "rbxassetid://3926307971"
MurdererTab.ImageRectOffset = Vector2.new(324, 684)
MurdererTab.ImageRectSize = Vector2.new(36, 36)
MurdererTab.Parent = TabButtons

local SheriffTab = Instance.new("ImageButton")
SheriffTab.Name = "SheriffTab"
SheriffTab.Size = UDim2.new(0, 40, 0, 40)
SheriffTab.Position = UDim2.new(0, 0, 0, 80)
SheriffTab.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
SheriffTab.BorderSizePixel = 0
SheriffTab.Image = "rbxassetid://3926307971"
SheriffTab.ImageRectOffset = Vector2.new(324, 644)
SheriffTab.ImageRectSize = Vector2.new(36, 36)
SheriffTab.Parent = TabButtons

local ESPSettingsTab = Instance.new("ImageButton")
ESPSettingsTab.Name = "ESPSettingsTab"
ESPSettingsTab.Size = UDim2.new(0, 40, 0, 40)
ESPSettingsTab.Position = UDim2.new(0, 0, 0, 120)
ESPSettingsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
ESPSettingsTab.BorderSizePixel = 0
ESPSettingsTab.Image = "rbxassetid://3926307971"
ESPSettingsTab.ImageRectOffset = Vector2.new(644, 204)
ESPSettingsTab.ImageRectSize = Vector2.new(36, 36)
ESPSettingsTab.Parent = TabButtons

local AboutTab = Instance.new("ImageButton")
AboutTab.Name = "AboutTab"
AboutTab.Size = UDim2.new(0, 40, 0, 40)
AboutTab.Position = UDim2.new(0, 0, 0, 160)
AboutTab.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
AboutTab.BorderSizePixel = 0
AboutTab.Image = "rbxassetid://3926307971"
AboutTab.ImageRectOffset = Vector2.new(84, 644)
AboutTab.ImageRectSize = Vector2.new(36, 36)
AboutTab.Parent = TabButtons

local OptionsFrame = Instance.new("Frame")
OptionsFrame.Name = "OptionsFrame"
OptionsFrame.Size = UDim2.new(1, -40, 1, -40)
OptionsFrame.Position = UDim2.new(0, 40, 0, 40)
OptionsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
OptionsFrame.BorderSizePixel = 0
OptionsFrame.ClipsDescendants = true
OptionsFrame.Parent = MainFrame

local GeneralScroll = Instance.new("ScrollingFrame")
GeneralScroll.Name = "GeneralScroll"
GeneralScroll.Size = UDim2.new(1, 0, 1, 0)
GeneralScroll.BackgroundTransparency = 1
GeneralScroll.ScrollBarThickness = 3
GeneralScroll.Visible = true
GeneralScroll.Parent = OptionsFrame

local MurdererScroll = Instance.new("ScrollingFrame")
MurdererScroll.Name = "MurdererScroll"
MurdererScroll.Size = UDim2.new(1, 0, 1, 0)
MurdererScroll.BackgroundTransparency = 1
MurdererScroll.ScrollBarThickness = 3
MurdererScroll.Visible = false
MurdererScroll.Parent = OptionsFrame

local SheriffScroll = Instance.new("ScrollingFrame")
SheriffScroll.Name = "SheriffScroll"
SheriffScroll.Size = UDim2.new(1, 0, 1, 0)
SheriffScroll.BackgroundTransparency = 1
SheriffScroll.ScrollBarThickness = 3
SheriffScroll.Visible = false
SheriffScroll.Parent = OptionsFrame

local ESPScroll = Instance.new("ScrollingFrame")
ESPScroll.Name = "ESPScroll"
ESPScroll.Size = UDim2.new(1, 0, 1, 0)
ESPScroll.BackgroundTransparency = 1
ESPScroll.ScrollBarThickness = 3
ESPScroll.Visible = false
ESPScroll.Parent = OptionsFrame

local AboutFrame = Instance.new("Frame")
AboutFrame.Name = "AboutFrame"
AboutFrame.Size = UDim2.new(1, 0, 1, 0)
AboutFrame.BackgroundTransparency = 1
AboutFrame.Visible = false
AboutFrame.Parent = OptionsFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = GeneralScroll

local function CreateOption(parent, text, height)
    local Option = Instance.new("Frame")
    Option.Name = text
    Option.Size = UDim2.new(1, -20, 0, height or 40)
    Option.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * (height or 48))
    Option.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
    Option.BorderSizePixel = 0
    Option.Parent = parent

    local Toggle = Instance.new("TextButton")
    Toggle.Name = "Toggle"
    Toggle.Size = UDim2.new(0, 80, 0, 32)
    Toggle.Position = UDim2.new(1, -85, 0.5, -16)
    Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
    Toggle.BorderSizePixel = 0
    Toggle.Text = ""
    Toggle.AutoButtonColor = false
    Toggle.Parent = Option

    local ToggleText = Instance.new("TextLabel")
    ToggleText.Name = "ToggleText"
    ToggleText.Size = UDim2.new(0, 80, 0, 32)
    ToggleText.Position = UDim2.new(0, 0, 0, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = "OFF"
    ToggleText.TextColor3 = Color3.fromRGB(255, 80, 80)
    ToggleText.Font = Enum.Font.GothamBold
    ToggleText.TextSize = 16
    ToggleText.Parent = Toggle

    local OptionText = Instance.new("TextLabel")
    OptionText.Name = "OptionText"
    OptionText.Size = UDim2.new(1, -90, 1, 0)
    OptionText.Position = UDim2.new(0, 10, 0, 0)
    OptionText.BackgroundTransparency = 1
    OptionText.Text = text
    OptionText.TextColor3 = Color3.fromRGB(200, 200, 255)
    OptionText.Font = Enum.Font.Gotham
    OptionText.TextSize = 16
    OptionText.TextXAlignment = Enum.TextXAlignment.Left
    OptionText.Parent = Option

    return Toggle
end

-- Общие функции
local ESPToggle = CreateOption(GeneralScroll, "ESP")
local FullBrightToggle = CreateOption(GeneralScroll, "FullBright")
local SpeedToggle = CreateOption(GeneralScroll, "Speed Hack")
local NoClipToggle = CreateOption(GeneralScroll, "NoClip")
local AutoPickupToggle = CreateOption(GeneralScroll, "Auto Pick Gun")
local AntiAfkToggle = CreateOption(GeneralScroll, "Anti AFK")

-- Функции для убийцы
local KnifeAuraToggle = CreateOption(MurdererScroll, "Knife Aura")
local AutoKillToggle = CreateOption(MurdererScroll, "Auto Kill")
local WallbangToggle = CreateOption(MurdererScroll, "Wallbang Kill")
local TeleportToVictimToggle = CreateOption(MurdererScroll, "Teleport to Victim")

-- Функции для шерифа
local GunAuraToggle = CreateOption(SheriffScroll, "Gun Aura")
local AutoShootToggle = CreateOption(SheriffScroll, "Auto Shoot")
local FOVToggle = CreateOption(SheriffScroll, "FOV Circle")
local FOVSizeSlider = CreateOption(SheriffScroll, "FOV Size", 60)

local SliderBar = Instance.new("Frame")
SliderBar.Name = "SliderBar"
SliderBar.Size = UDim2.new(0.8, 0, 0.2, 0)
SliderBar.Position = UDim2.new(0.1, 0, 0.7, 0)
SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = FOVSizeSlider

local SliderFill = Instance.new("Frame")
SliderFill.Name = "SliderFill"
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBar

local SliderDot = Instance.new("Frame")
SliderDot.Name = "SliderDot"
SliderDot.Size = UDim2.new(0, 12, 1.5, 0)
SliderDot.Position = UDim2.new(0.5, -6, -0.25, 0)
SliderDot.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
SliderDot.BorderSizePixel = 0
SliderDot.Parent = SliderBar

-- Настройки ESP
local ESPMurdererToggle = CreateOption(ESPScroll, "Show Murderer")
local ESPSheriffToggle = CreateOption(ESPScroll, "Show Sheriff")
local ESPInnocentToggle = CreateOption(ESPScroll, "Show Innocents")
local ESPNamesToggle = CreateOption(ESPScroll, "Show Names")
local ESPDistanceToggle = CreateOption(ESPScroll, "Show Distance")
local ESPThroughWalls = CreateOption(ESPScroll, "Through Walls")

-- Вкладка "О чите"
local AboutText = Instance.new("TextLabel")
AboutText.Name = "AboutText"
AboutText.Size = UDim2.new(1, -20, 1, -20)
AboutText.Position = UDim2.new(0, 10, 0, 10)
AboutText.BackgroundTransparency = 1
AboutText.Text = [[MM2 PRO CHEAT MENU
Version: 3.0
Developed for Mobile

Key Features:
- Professional ESP system
- FOV targeting for Sheriff
- Role-specific abilities
- Auto-updating players
- Smooth UI experience

ESP Settings:
Customize which players to show
and what information to display

Controls:
Drag the top bar to move menu
Click [-] to minimize

All settings are saved automatically]]
AboutText.TextColor3 = Color3.fromRGB(200, 200, 255)
AboutText.Font = Enum.Font.Gotham
AboutText.TextSize = 16
AboutText.TextXAlignment = Enum.TextXAlignment.Left
AboutText.TextYAlignment = Enum.TextYAlignment.Top
AboutText.Parent = AboutFrame

-- Состояния функций
local Settings = {
    ESP = false,
    FullBright = false,
    Speed = false,
    NoClip = false,
    AutoPickup = false,
    AntiAfk = false,
    KnifeAura = false,
    AutoKill = false,
    Wallbang = false,
    TeleportToVictim = false,
    GunAura = false,
    AutoShoot = false,
    FOV = false,
    FOVSize = 120,
    ESPMurderer = true,
    ESPSheriff = true,
    ESPInnocent = true,
    ESPNames = true,
    ESPDistance = true,
    ESPThroughWalls = true
}

local function SaveSettings()
    writefile("MM2ProSettings.txt", HttpService:JSONEncode(Settings))
end

local function LoadSettings()
    if isfile("MM2ProSettings.txt") then
        Settings = HttpService:JSONDecode(readfile("MM2ProSettings.txt"))
    end
end

LoadSettings()

local function UpdateToggles()
    local function setToggle(toggle, value)
        toggle.ToggleText.Text = value and "ON" or "OFF"
        toggle.ToggleText.TextColor3 = value and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    end

    setToggle(ESPToggle, Settings.ESP)
    setToggle(FullBrightToggle, Settings.FullBright)
    setToggle(SpeedToggle, Settings.Speed)
    setToggle(NoClipToggle, Settings.NoClip)
    setToggle(AutoPickupToggle, Settings.AutoPickup)
    setToggle(AntiAfkToggle, Settings.AntiAfk)
    setToggle(KnifeAuraToggle, Settings.KnifeAura)
    setToggle(AutoKillToggle, Settings.AutoKill)
    setToggle(WallbangToggle, Settings.Wallbang)
    setToggle(TeleportToVictimToggle, Settings.TeleportToVictim)
    setToggle(GunAuraToggle, Settings.GunAura)
    setToggle(AutoShootToggle, Settings.AutoShoot)
    setToggle(FOVToggle, Settings.FOV)
    setToggle(ESPMurdererToggle, Settings.ESPMurderer)
    setToggle(ESPSheriffToggle, Settings.ESPSheriff)
    setToggle(ESPInnocentToggle, Settings.ESPInnocent)
    setToggle(ESPNamesToggle, Settings.ESPNames)
    setToggle(ESPDistanceToggle, Settings.ESPDistance)
    setToggle(ESPThroughWalls, Settings.ESPThroughWalls)
    
    FOVSizeSlider.ToggleText.Text = tostring(Settings.FOVSize)
    SliderFill.Size = UDim2.new(Settings.FOVSize/200, 0, 1, 0)
    SliderDot.Position = UDim2.new(Settings.FOVSize/200, -6, -0.25, 0)
end

UpdateToggles()

local function ToggleSetting(setting)
    Settings[setting] = not Settings[setting]
    UpdateToggles()
    SaveSettings()
end

ESPToggle.MouseButton1Click:Connect(function() ToggleSetting("ESP") end)
FullBrightToggle.MouseButton1Click:Connect(function() ToggleSetting("FullBright") end)
SpeedToggle.MouseButton1Click:Connect(function() ToggleSetting("Speed") end)
NoClipToggle.MouseButton1Click:Connect(function() ToggleSetting("NoClip") end)
AutoPickupToggle.MouseButton1Click:Connect(function() ToggleSetting("AutoPickup") end)
AntiAfkToggle.MouseButton1Click:Connect(function() ToggleSetting("AntiAfk") end)
KnifeAuraToggle.MouseButton1Click:Connect(function() ToggleSetting("KnifeAura") end)
AutoKillToggle.MouseButton1Click:Connect(function() ToggleSetting("AutoKill") end)
WallbangToggle.MouseButton1Click:Connect(function() ToggleSetting("Wallbang") end)
TeleportToVictimToggle.MouseButton1Click:Connect(function() ToggleSetting("TeleportToVictim") end)
GunAuraToggle.MouseButton1Click:Connect(function() ToggleSetting("GunAura") end)
AutoShootToggle.MouseButton1Click:Connect(function() ToggleSetting("AutoShoot") end)
FOVToggle.MouseButton1Click:Connect(function() ToggleSetting("FOV") end)
ESPMurdererToggle.MouseButton1Click:Connect(function() ToggleSetting("ESPMurderer") end)
ESPSheriffToggle.MouseButton1Click:Connect(function() ToggleSetting("ESPSheriff") end)
ESPInnocentToggle.MouseButton1Click:Connect(function() ToggleSetting("ESPInnocent") end)
ESPNamesToggle.MouseButton1Click:Connect(function() ToggleSetting("ESPNames") end)
ESPDistanceToggle.MouseButton1Click:Connect(function() ToggleSetting("ESPDistance") end)
ESPThroughWalls.MouseButton1Click:Connect(function() ToggleSetting("ESPThroughWalls") end)

FOVSizeSlider.MouseButton1Click:Connect(function()
    Settings.FOVSize = Settings.FOVSize + 20
    if Settings.FOVSize > 200 then Settings.FOVSize = 60 end
    UpdateToggles()
    SaveSettings()
end)

local draggingSlider = false
SliderDot.MouseButton1Down:Connect(function()
    draggingSlider = true
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

Mouse.Move:Connect(function()
    if draggingSlider then
        local relativeX = math.clamp((Mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        Settings.FOVSize = math.floor(60 + relativeX * 140)
        UpdateToggles()
        SaveSettings()
    end
end)

local tabs = {
    General = GeneralScroll,
    Murderer = MurdererScroll,
    Sheriff = SheriffScroll,
    ESPSettings = ESPScroll,
    About = AboutFrame
}

local tabButtons = {
    General = GeneralTab,
    Murderer = MurdererTab,
    Sheriff = SheriffTab,
    ESPSettings = ESPSettingsTab,
    About = AboutTab
}

local function SwitchTab(tabName)
    for name, frame in pairs(tabs) do
        frame.Visible = (name == tabName)
    end
    
    for name, button in pairs(tabButtons) do
        button.BackgroundColor3 = (name == tabName) and Color3.fromRGB(40, 40, 80) or Color3.fromRGB(25, 25, 50)
    end
end

GeneralTab.MouseButton1Click:Connect(function() SwitchTab("General") end)
MurdererTab.MouseButton1Click:Connect(function() SwitchTab("Murderer") end)
SheriffTab.MouseButton1Click:Connect(function() SwitchTab("Sheriff") end)
ESPSettingsTab.MouseButton1Click:Connect(function() SwitchTab("ESPSettings") end)
AboutTab.MouseButton1Click:Connect(function() SwitchTab("About") end)

local Minimized = false
ToggleButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 40, 0, 40)}):Play()
        ToggleButton.ImageRectOffset = Vector2.new(924, 4)
        OptionsFrame.Visible = false
        TabButtons.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 350, 0, 320)}):Play()
        ToggleButton.ImageRectOffset = Vector2.new(884, 4)
        OptionsFrame.Visible = true
        TabButtons.Visible = true
    end
end)

-- Профессиональный ESP
local ESPHighlights = {}
local ESPLabels = {}

local function UpdateESP()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local role = player.Character:FindFirstChild("Role")
            local showESP = false
            local espColor = Color3.new(0,1,0)
            
            if role then
                if role.Value == "Murderer" and Settings.ESPMurderer then
                    showESP = true
                    espColor = Color3.new(1,0,0)
                elseif role.Value == "Sheriff" and Settings.ESPSheriff then
                    showESP = true
                    espColor = Color3.new(0,0,1)
                elseif role.Value == "Innocent" and Settings.ESPInnocent then
                    showESP = true
                    espColor = Color3.new(0,1,0)
                end
            end
            
            if Settings.ESP and showESP then
                -- Highlight
                if not ESPHighlights[player] then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = player.Name
                    Highlight.FillTransparency = 0.8
                    Highlight.OutlineTransparency = 0.3
                    Highlight.DepthMode = Settings.ESPThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                    Highlight.Parent = player.Character
                    ESPHighlights[player] = Highlight
                end
                ESPHighlights[player].FillColor = espColor
                ESPHighlights[player].OutlineColor = espColor
                
                -- Label
                if not ESPLabels[player] then
                    local Billboard = Instance.new("BillboardGui")
                    Billboard.Name = player.Name.."Label"
                    Billboard.AlwaysOnTop = true
                    Billboard.Size = UDim2.new(0, 200, 0, 50)
                    Billboard.StudsOffset = Vector3.new(0, 3.5, 0)
                    Billboard.Parent = player.Character.Head
                    
                    local TextLabel = Instance.new("TextLabel")
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.TextStrokeTransparency = 0.5
                    TextLabel.TextStrokeColor3 = Color3.new(0,0,0)
                    TextLabel.Font = Enum.Font.GothamBold
                    TextLabel.TextSize = 18
                    TextLabel.Parent = Billboard
                    
                    ESPLabels[player] = TextLabel
                end
                
                local distance = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                local text = ""
                if Settings.ESPNames then text = player.Name end
                if Settings.ESPDistance then
                    if text ~= "" then text = text .. " | " end
                    text = text .. math.floor(distance) .. "m"
                end
                
                ESPLabels[player].Text = text
                ESPLabels[player].TextColor3 = espColor
                ESPLabels[player].Visible = text ~= ""
            else
                if ESPHighlights[player] then
                    ESPHighlights[player]:Destroy()
                    ESPHighlights[player] = nil
                end
                if ESPLabels[player] then
                    ESPLabels[player].Parent:Destroy()
                    ESPLabels[player] = nil
                end
            end
        else
            if ESPHighlights[player] then
                ESPHighlights[player]:Destroy()
                ESPHighlights[player] = nil
            end
            if ESPLabels[player] then
                if ESPLabels[player].Parent then
                    ESPLabels[player].Parent:Destroy()
                end
                ESPLabels[player] = nil
            end
        end
    end
end

-- FOV Circle
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.Size = UDim2.new(0, Settings.FOVSize, 0, Settings.FOVSize)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local Circle = Instance.new("ImageLabel")
Circle.Name = "Circle"
Circle.Size = UDim2.new(1, 0, 1, 0)
Circle.BackgroundTransparency = 1
Circle.Image = "rbxassetid://266543268"
Circle.ImageColor3 = Color3.fromRGB(0, 150, 255)
Circle.ImageTransparency = 0.7
Circle.Parent = FOVCircle

local function UpdateFOV()
    FOVCircle.Visible = Settings.FOV
    FOVCircle.Size = UDim2.new(0, Settings.FOVSize, 0, Settings.FOVSize)
    Circle.ImageColor3 = Settings.AutoShoot and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 150, 255)
end

-- Остальные функции
local function UpdateFullBright()
    if Settings.FullBright then
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
    else
        Lighting.GlobalShadows = true
        Lighting.Brightness = 1
    end
end

local function UpdateSpeed()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = Settings.Speed and 25 or 16
    end
end

local function NoClip()
    if Settings.NoClip and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

local function AutoPickup()
    if Settings.AutoPickup and Player.Character then
        local gun = workspace:FindFirstChild("GunDrop")
        if gun and (gun.Position - Player.Character.HumanoidRootPart.Position).Magnitude < 15 then
            firetouchinterest(Player.Character.HumanoidRootPart, gun, 0)
            firetouchinterest(Player.Character.HumanoidRootPart, gun, 1)
        end
    end
end

local function KnifeAura()
    if Settings.KnifeAura and Player.Character then
        local knife = Player.Character:FindFirstChild("Knife")
        if knife then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local distance = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < 15 then
                        game:GetService("ReplicatedStorage").KnifeHit:FireServer(player.Character.Humanoid, player.Character.HumanoidRootPart.CFrame)
                    end
                end
            end
        end
    end
end

local function AutoKill()
    if Settings.AutoKill and Player.Character then
        local knife = Player.Character:FindFirstChild("Knife")
        if knife then
            local closestPlayer, closestDistance = nil, math.huge
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local distance = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestPlayer = player
                        closestDistance = distance
                    end
                end
            end
            
            if closestPlayer and closestDistance < 25 then
                Player.Character.HumanoidRootPart.CFrame = closestPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                task.wait(0.1)
                game:GetService("ReplicatedStorage").KnifeHit:FireServer(closestPlayer.Character.Humanoid, closestPlayer.Character.HumanoidRootPart.CFrame)
            end
        end
    end
end

local function Wallbang()
    if Settings.Wallbang and Player.Character then
        local knife = Player.Character:FindFirstChild("Knife")
        if knife then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {Player.Character, player.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    raycastParams.IgnoreWater = true
                    
                    local raycastResult = workspace:Raycast(
                        Player.Character.HumanoidRootPart.Position,
                        (player.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position),
                        raycastParams
                    )
                    
                    if not raycastResult then
                        game:GetService("ReplicatedStorage").KnifeHit:FireServer(player.Character.Humanoid, player.Character.HumanoidRootPart.CFrame)
                    end
                end
            end
        end
    end
end

local function TeleportToVictim()
    if Settings.TeleportToVictim and Player.Character then
        local closestPlayer, closestDistance = nil, math.huge
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local distance = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestPlayer = player
                    closestDistance = distance
                end
            end
        end
        if closestPlayer then
            Player.Character.HumanoidRootPart.CFrame = closestPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
        end
    end
end

local function GunAura()
    if Settings.GunAura and Player.Character then
        local gun = Player.Character:FindFirstChild("Gun")
        if gun then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local distance = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < 50 then
                        game:GetService("ReplicatedStorage").GunEvent:FireServer(player.Character.HumanoidRootPart.Position)
                    end
                end
            end
        end
    end
end

local function AutoShoot()
    if Settings.AutoShoot and Player.Character then
        local gun = Player.Character:FindFirstChild("Gun")
        if gun then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local screenPoint = Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
                    if screenPoint.Z > 0 then
                        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                        local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
                        local distance = (mousePos - targetPos).Magnitude
                        
                        if distance < Settings.FOVSize/2 then
                            game:GetService("ReplicatedStorage").GunEvent:FireServer(player.Character.HumanoidRootPart.Position)
                        end
                    end
                end
            end
        end
    end
end

local function AntiAFK()
    if Settings.AntiAfk then
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end

-- Автоматическое обновление игроков
local function CleanupESP()
    for player in pairs(ESPHighlights) do
        if not player:IsDescendantOf(game) then
            if ESPHighlights[player] then
                ESPHighlights[player]:Destroy()
                ESPHighlights[player] = nil
            end
            if ESPLabels[player] and ESPLabels[player].Parent then
                ESPLabels[player].Parent:Destroy()
                ESPLabels[player] = nil
            end
        end
    end
end

-- Основной цикл
RunService.Heartbeat:Connect(function()
    CleanupESP()
    
    if Settings.ESP then 
        UpdateESP()
    else
        for player in pairs(ESPHighlights) do
            if ESPHighlights[player] then
                ESPHighlights[player]:Destroy()
            end
            if ESPLabels[player] and ESPLabels[player].Parent then
                ESPLabels[player].Parent:Destroy()
            end
        end
        ESPHighlights = {}
        ESPLabels = {}
    end
    
    UpdateFullBright()
    UpdateSpeed()
    NoClip()
    AutoPickup()
    KnifeAura()
    AutoKill()
    Wallbang()
    TeleportToVictim()
    GunAura()
    AutoShoot()
    UpdateFOV()
    AntiAFK()
end)

-- Обработка изменений персонажа
Player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    if Settings.Speed then
        character.Humanoid.WalkSpeed = 25
    end
end)

-- Обработка изменения ролей
game:GetService("ReplicatedStorage").RoleChanged.OnClientEvent:Connect(function(role)
    -- Очищаем ESP при смене ролей
    for player in pairs(ESPHighlights) do
        if ESPHighlights[player] then
            ESPHighlights[player]:Destroy()
            ESPHighlights[player] = nil
        end
        if ESPLabels[player] and ESPLabels[player].Parent then
            ESPLabels[player].Parent:Destroy()
            ESPLabels[player] = nil
        end
    end
    ESPHighlights = {}
    ESPLabels = {}
end)

-- Инициализация
SwitchTab("General")
_G.MM2ProMenu = ScreenGui