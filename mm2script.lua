local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("MM2Ultimate") then CoreGui:FindFirstChild("MM2Ultimate"):Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2Ultimate"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 40)
MainFrame.Position = UDim2.new(0.5, -175, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "MM2 ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(1, -40, 0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BorderSizePixel = 0
ToggleButton.Image = "rbxassetid://3926305904"
ToggleButton.ImageRectOffset = Vector2.new(884, 4)
ToggleButton.ImageRectSize = Vector2.new(36, 36)
ToggleButton.Parent = MainFrame

local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(0, 40, 1, -40)
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local GeneralTab = Instance.new("ImageButton")
GeneralTab.Name = "GeneralTab"
GeneralTab.Size = UDim2.new(0, 40, 0, 40)
GeneralTab.Position = UDim2.new(0, 0, 0, 0)
GeneralTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
GeneralTab.BorderSizePixel = 0
GeneralTab.Image = "rbxassetid://3926305904"
GeneralTab.ImageRectOffset = Vector2.new(964, 324)
GeneralTab.ImageRectSize = Vector2.new(36, 36)
GeneralTab.Parent = TabButtons

local MurdererTab = Instance.new("ImageButton")
MurdererTab.Name = "MurdererTab"
MurdererTab.Size = UDim2.new(0, 40, 0, 40)
MurdererTab.Position = UDim2.new(0, 0, 0, 40)
MurdererTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MurdererTab.BorderSizePixel = 0
MurdererTab.Image = "rbxassetid://3926307971"
MurdererTab.ImageRectOffset = Vector2.new(324, 684)
MurdererTab.ImageRectSize = Vector2.new(36, 36)
MurdererTab.Parent = TabButtons

local SheriffTab = Instance.new("ImageButton")
SheriffTab.Name = "SheriffTab"
SheriffTab.Size = UDim2.new(0, 40, 0, 40)
SheriffTab.Position = UDim2.new(0, 0, 0, 80)
SheriffTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SheriffTab.BorderSizePixel = 0
SheriffTab.Image = "rbxassetid://3926307971"
SheriffTab.ImageRectOffset = Vector2.new(324, 644)
SheriffTab.ImageRectSize = Vector2.new(36, 36)
SheriffTab.Parent = TabButtons

local PlayerTab = Instance.new("ImageButton")
PlayerTab.Name = "PlayerTab"
PlayerTab.Size = UDim2.new(0, 40, 0, 40)
PlayerTab.Position = UDim2.new(0, 0, 0, 120)
PlayerTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PlayerTab.BorderSizePixel = 0
PlayerTab.Image = "rbxassetid://3926305904"
PlayerTab.ImageRectOffset = Vector2.new(4, 964)
PlayerTab.ImageRectSize = Vector2.new(36, 36)
PlayerTab.Parent = TabButtons

local OptionsFrame = Instance.new("Frame")
OptionsFrame.Name = "OptionsFrame"
OptionsFrame.Size = UDim2.new(1, -40, 1, -40)
OptionsFrame.Position = UDim2.new(0, 40, 0, 40)
OptionsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Name = "PlayerScroll"
PlayerScroll.Size = UDim2.new(1, 0, 1, 0)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.ScrollBarThickness = 3
PlayerScroll.Visible = false
PlayerScroll.Parent = OptionsFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = GeneralScroll

local UIListLayout2 = Instance.new("UIListLayout")
UIListLayout2.Padding = UDim.new(0, 5)
UIListLayout2.Parent = MurdererScroll

local UIListLayout3 = Instance.new("UIListLayout")
UIListLayout3.Padding = UDim.new(0, 5)
UIListLayout3.Parent = SheriffScroll

local UIListLayout4 = Instance.new("UIListLayout")
UIListLayout4.Padding = UDim.new(0, 5)
UIListLayout4.Parent = PlayerScroll

local function CreateOption(parent, text)
    local Option = Instance.new("Frame")
    Option.Name = text
    Option.Size = UDim2.new(1, -10, 0, 40)
    Option.Position = UDim2.new(0, 5, 0, #parent:GetChildren()*45)
    Option.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Option.BorderSizePixel = 0
    Option.Parent = parent

    local Toggle = Instance.new("TextButton")
    Toggle.Name = "Toggle"
    Toggle.Size = UDim2.new(0, 80, 0, 30)
    Toggle.Position = UDim2.new(1, -85, 0.5, -15)
    Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Toggle.BorderSizePixel = 0
    Toggle.Text = ""
    Toggle.AutoButtonColor = false
    Toggle.Parent = Option

    local ToggleText = Instance.new("TextLabel")
    ToggleText.Name = "ToggleText"
    ToggleText.Size = UDim2.new(0, 80, 0, 30)
    ToggleText.Position = UDim2.new(0, 0, 0, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = "OFF"
    ToggleText.TextColor3 = Color3.fromRGB(255, 50, 50)
    ToggleText.Font = Enum.Font.GothamBold
    ToggleText.TextSize = 16
    ToggleText.Parent = Toggle

    local OptionText = Instance.new("TextLabel")
    OptionText.Name = "OptionText"
    OptionText.Size = UDim2.new(1, -90, 1, 0)
    OptionText.Position = UDim2.new(0, 10, 0, 0)
    OptionText.BackgroundTransparency = 1
    OptionText.Text = text
    OptionText.TextColor3 = Color3.fromRGB(255, 255, 255)
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

-- Функции для убийцы
local KnifeAuraToggle = CreateOption(MurdererScroll, "Knife Aura")
local AutoKillToggle = CreateOption(MurdererScroll, "Auto Kill")
local WallbangToggle = CreateOption(MurdererScroll, "Wallbang")
local TeleportToVictimToggle = CreateOption(MurdererScroll, "Teleport to Victim")

-- Функции для шерифа
local GunAuraToggle = CreateOption(SheriffScroll, "Gun Aura")
local AutoShootToggle = CreateOption(SheriffScroll, "Auto Shoot")
local FOVToggle = CreateOption(SheriffScroll, "FOV Circle")
local FOVSizeSlider = CreateOption(SheriffScroll, "FOV Size")

-- Функции для игрока
local AntiAfkToggle = CreateOption(PlayerScroll, "Anti AFK")
local HideNamesToggle = CreateOption(PlayerScroll, "Hide Names")

-- Состояния функций
local Settings = {
    ESP = false,
    FullBright = false,
    Speed = false,
    NoClip = false,
    AutoPickup = false,
    KnifeAura = false,
    AutoKill = false,
    Wallbang = false,
    TeleportToVictim = false,
    GunAura = false,
    AutoShoot = false,
    FOV = false,
    FOVSize = 100,
    AntiAfk = false,
    HideNames = false
}

local function SaveSettings()
    writefile("MM2Settings.txt", game:GetService("HttpService"):JSONEncode(Settings))
end

local function LoadSettings()
    if isfile("MM2Settings.txt") then
        Settings = game:GetService("HttpService"):JSONDecode(readfile("MM2Settings.txt"))
    end
end

LoadSettings()

local function UpdateToggles()
    ESPToggle.ToggleText.Text = Settings.ESP and "ON" or "OFF"
    ESPToggle.ToggleText.TextColor3 = Settings.ESP and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    FullBrightToggle.ToggleText.Text = Settings.FullBright and "ON" or "OFF"
    FullBrightToggle.ToggleText.TextColor3 = Settings.FullBright and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    SpeedToggle.ToggleText.Text = Settings.Speed and "ON" or "OFF"
    SpeedToggle.ToggleText.TextColor3 = Settings.Speed and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    NoClipToggle.ToggleText.Text = Settings.NoClip and "ON" or "OFF"
    NoClipToggle.ToggleText.TextColor3 = Settings.NoClip and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    AutoPickupToggle.ToggleText.Text = Settings.AutoPickup and "ON" or "OFF"
    AutoPickupToggle.ToggleText.TextColor3 = Settings.AutoPickup and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    KnifeAuraToggle.ToggleText.Text = Settings.KnifeAura and "ON" or "OFF"
    KnifeAuraToggle.ToggleText.TextColor3 = Settings.KnifeAura and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    AutoKillToggle.ToggleText.Text = Settings.AutoKill and "ON" or "OFF"
    AutoKillToggle.ToggleText.TextColor3 = Settings.AutoKill and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    WallbangToggle.ToggleText.Text = Settings.Wallbang and "ON" or "OFF"
    WallbangToggle.ToggleText.TextColor3 = Settings.Wallbang and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    TeleportToVictimToggle.ToggleText.Text = Settings.TeleportToVictim and "ON" or "OFF"
    TeleportToVictimToggle.ToggleText.TextColor3 = Settings.TeleportToVictim and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    GunAuraToggle.ToggleText.Text = Settings.GunAura and "ON" or "OFF"
    GunAuraToggle.ToggleText.TextColor3 = Settings.GunAura and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    AutoShootToggle.ToggleText.Text = Settings.AutoShoot and "ON" or "OFF"
    AutoShootToggle.ToggleText.TextColor3 = Settings.AutoShoot and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    FOVToggle.ToggleText.Text = Settings.FOV and "ON" or "OFF"
    FOVToggle.ToggleText.TextColor3 = Settings.FOV and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    FOVSizeSlider.ToggleText.Text = tostring(Settings.FOVSize)
    FOVSizeSlider.ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    AntiAfkToggle.ToggleText.Text = Settings.AntiAfk and "ON" or "OFF"
    AntiAfkToggle.ToggleText.TextColor3 = Settings.AntiAfk and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    HideNamesToggle.ToggleText.Text = Settings.HideNames and "ON" or "OFF"
    HideNamesToggle.ToggleText.TextColor3 = Settings.HideNames and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
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
KnifeAuraToggle.MouseButton1Click:Connect(function() ToggleSetting("KnifeAura") end)
AutoKillToggle.MouseButton1Click:Connect(function() ToggleSetting("AutoKill") end)
WallbangToggle.MouseButton1Click:Connect(function() ToggleSetting("Wallbang") end)
TeleportToVictimToggle.MouseButton1Click:Connect(function() ToggleSetting("TeleportToVictim") end)
GunAuraToggle.MouseButton1Click:Connect(function() ToggleSetting("GunAura") end)
AutoShootToggle.MouseButton1Click:Connect(function() ToggleSetting("AutoShoot") end)
FOVToggle.MouseButton1Click:Connect(function() ToggleSetting("FOV") end)
AntiAfkToggle.MouseButton1Click:Connect(function() ToggleSetting("AntiAfk") end)
HideNamesToggle.MouseButton1Click:Connect(function() ToggleSetting("HideNames") end)

FOVSizeSlider.MouseButton1Click:Connect(function()
    Settings.FOVSize = Settings.FOVSize + 25
    if Settings.FOVSize > 200 then Settings.FOVSize = 50 end
    UpdateToggles()
    SaveSettings()
end)

GeneralTab.MouseButton1Click:Connect(function()
    GeneralScroll.Visible = true
    MurdererScroll.Visible = false
    SheriffScroll.Visible = false
    PlayerScroll.Visible = false
    GeneralTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MurdererTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SheriffTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    PlayerTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
end)

MurdererTab.MouseButton1Click:Connect(function()
    GeneralScroll.Visible = false
    MurdererScroll.Visible = true
    SheriffScroll.Visible = false
    PlayerScroll.Visible = false
    GeneralTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MurdererTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SheriffTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    PlayerTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
end)

SheriffTab.MouseButton1Click:Connect(function()
    GeneralScroll.Visible = false
    MurdererScroll.Visible = false
    SheriffScroll.Visible = true
    PlayerScroll.Visible = false
    GeneralTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MurdererTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SheriffTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    PlayerTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
end)

PlayerTab.MouseButton1Click:Connect(function()
    GeneralScroll.Visible = false
    MurdererScroll.Visible = false
    SheriffScroll.Visible = false
    PlayerScroll.Visible = true
    GeneralTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MurdererTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SheriffTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    PlayerTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)

local Minimized = false
ToggleButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 40, 0, 40)}):Play()
        ToggleButton.ImageRectOffset = Vector2.new(924, 4)
        OptionsFrame.Visible = false
        TabButtons.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 350, 0, 300)}):Play()
        ToggleButton.ImageRectOffset = Vector2.new(884, 4)
        OptionsFrame.Visible = true
        TabButtons.Visible = true
    end
end)

-- ESP
local ESPHighlights = {}
local function UpdateESP()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not ESPHighlights[player] then
                local Highlight = Instance.new("Highlight")
                Highlight.Name = player.Name
                Highlight.FillTransparency = 0.8
                Highlight.OutlineTransparency = 0
                Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                Highlight.Parent = player.Character
                ESPHighlights[player] = Highlight
            end
            
            local role = player.Character:FindFirstChild("Role")
            if role then
                if role.Value == "Murderer" then
                    ESPHighlights[player].FillColor = Color3.fromRGB(255, 0, 0)
                    ESPHighlights[player].OutlineColor = Color3.fromRGB(200, 0, 0)
                elseif role.Value == "Sheriff" then
                    ESPHighlights[player].FillColor = Color3.fromRGB(0, 0, 255)
                    ESPHighlights[player].OutlineColor = Color3.fromRGB(0, 0, 200)
                else
                    ESPHighlights[player].FillColor = Color3.fromRGB(0, 255, 0)
                    ESPHighlights[player].OutlineColor = Color3.fromRGB(0, 200, 0)
                end
            end
        elseif ESPHighlights[player] then
            ESPHighlights[player]:Destroy()
            ESPHighlights[player] = nil
        end
    end
end

-- FullBright
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

-- Speed Hack
local function UpdateSpeed()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = Settings.Speed and 25 or 16
    end
end

-- NoClip
local function NoClip()
    if Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = not Settings.NoClip
            end
        end
    end
end

-- Auto Pickup Gun
local function AutoPickup()
    if Settings.AutoPickup and Player.Character then
        local gun = workspace:FindFirstChild("GunDrop")
        if gun and (gun.Position - Player.Character.HumanoidRootPart.Position).Magnitude < 15 then
            firetouchinterest(Player.Character.HumanoidRootPart, gun, 0)
            firetouchinterest(Player.Character.HumanoidRootPart, gun, 1)
        end
    end
end

-- Knife Aura
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

-- Auto Kill
local function AutoKill()
    if Settings.AutoKill and Player.Character then
        local knife = Player.Character:FindFirstChild("Knife")
        if knife then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local distance = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < 25 then
                        Player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                        task.wait(0.1)
                        game:GetService("ReplicatedStorage").KnifeHit:FireServer(player.Character.Humanoid, player.Character.HumanoidRootPart.CFrame)
                    end
                end
            end
        end
    end
end

-- Wallbang
local function Wallbang()
    if Settings.Wallbang and Player.Character then
        local knife = Player.Character:FindFirstChild("Knife")
        if knife then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    game:GetService("ReplicatedStorage").KnifeHit:FireServer(player.Character.Humanoid, player.Character.HumanoidRootPart.CFrame)
                end
            end
        end
    end
end

-- Teleport to Victim
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

-- Gun Aura
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

-- Auto Shoot
local function AutoShoot()
    if Settings.AutoShoot and Player.Character then
        local gun = Player.Character:FindFirstChild("Gun")
        if gun then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local distance = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < 100 then
                        Player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(Player.Character.HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position)
                        game:GetService("ReplicatedStorage").GunEvent:FireServer(player.Character.HumanoidRootPart.Position)
                    end
                end
            end
        end
    end
end

-- FOV Circle
local FOVCircle = nil
local function UpdateFOV()
    if Settings.FOV then
        if not FOVCircle then
            FOVCircle = Instance.new("Part")
            FOVCircle.Shape = Enum.PartType.Cylinder
            FOVCircle.Size = Vector3.new(0.2, Settings.FOVSize, Settings.FOVSize)
            FOVCircle.Transparency = 0.7
            FOVCircle.Color = Color3.fromRGB(0, 170, 255)
            FOVCircle.Anchored = true
            FOVCircle.CanCollide = false
            FOVCircle.Parent = workspace
        end
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            FOVCircle.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, 0, math.rad(90))
            FOVCircle.Size = Vector3.new(0.2, Settings.FOVSize, Settings.FOVSize)
        end
    elseif FOVCircle then
        FOVCircle:Destroy()
        FOVCircle = nil
    end
end

-- Anti AFK
local function AntiAFK()
    if Settings.AntiAfk then
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end

-- Hide Names
local function HideNames()
    if Settings.HideNames then
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= Player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.DisplayName = ""
                end
            end
        end
    else
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= Player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.DisplayName = player.Name
                end
            end
        end
    end
end

-- Основной цикл
RunService.Heartbeat:Connect(function()
    if Settings.ESP then UpdateESP() else
        for _, highlight in pairs(ESPHighlights) do
            highlight:Destroy()
        end
        ESPHighlights = {}
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
    HideNames()
end)

-- Обработка изменений персонажа
Player.CharacterAdded:Connect(function(character)
    if Settings.Speed then
        character:WaitForChild("Humanoid").WalkSpeed = 25
    end
end)

_G.MM2Ultimate = ScreenGui