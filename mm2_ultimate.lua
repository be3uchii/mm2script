local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- Удаление старого GUI
if CoreGui:FindFirstChild("MM2UltimateV2") then
    CoreGui:FindFirstChild("MM2UltimateV2"):Destroy()
end

-- Основной GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2UltimateV2"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

-- Загрузочный экран
local LoadingScreen = Instance.new("Frame")
LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
LoadingScreen.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
LoadingScreen.BackgroundTransparency = 0.2
LoadingScreen.Parent = ScreenGui

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(0.5, 0, 0.1, 0)
LoadingText.Position = UDim2.new(0.25, 0, 0.45, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "MM2 Ultimate | Загрузка..."
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 24
LoadingText.TextStrokeTransparency = 0.8
LoadingText.Parent = LoadingScreen

-- Анимация загрузки
local function animateLoading()
    local tween = TweenService:Create(LoadingText, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextTransparency = 0.3})
    tween:Play()
    wait(0.8)
    LoadingScreen:Destroy()
end
coroutine.wrap(animateLoading)()

-- Основной фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true

-- Скругленные углы
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextButton")
Title.Size = UDim2.new(1, -10, 0, 40)
Title.Position = UDim2.new(0, 5, 0, 5)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "MM2 Ultimate V2"
Title.TextColor3 = Color3.fromRGB(200, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextYAlignment = Enum.TextYAlignment.Center
Title.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Вкладки
local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(0, 50, 1, -50)
TabButtons.Position = UDim2.new(0, 5, 0, 50)
TabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabButtons.BackgroundTransparency = 0.2
TabButtons.Parent = MainFrame
local TabButtonsCorner = Instance.new("UICorner")
TabButtonsCorner.CornerRadius = UDim.new(0, 8)
TabButtonsCorner.Parent = TabButtons

-- Создание вкладок
local tabs = {"General", "Murderer", "Sheriff", "Player"}
local tabButtons = {}
local tabScrolls = {}
local currentTab = "General"

for i, tabName in ipairs(tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName .. "Tab"
    TabButton.Size = UDim2.new(0, 50, 0, 50)
    TabButton.Position = UDim2.new(0, 0, 0, (i-1)*55)
    TabButton.BackgroundColor3 = tabName == currentTab and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.Parent = TabButtons
    local TabButtonCorner = Instance.new("UICorner")
    TabButtonCorner.CornerRadius = UDim.new(0, 8)
    TabButtonCorner.Parent = TabButton
    tabButtons[tabName] = TabButton

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = tabName .. "Scroll"
    ScrollFrame.Size = UDim2.new(1, -60, 1, -50)
    ScrollFrame.Position = UDim2.new(0, 60, 0, 50)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    ScrollFrame.Visible = tabName == currentTab
    ScrollFrame.Parent = MainFrame
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.ScrollingEnabled = true
    ScrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.Parent = ScrollFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 5)
    UIPadding.PaddingBottom = UDim.new(0, 5)
    UIPadding.Parent = ScrollFrame

    tabScrolls[tabName] = ScrollFrame
end

-- Функция создания опции (переключатель)
local function CreateToggleOption(parent, text, settingKey)
    local Option = Instance.new("Frame")
    Option.Size = UDim2.new(1, -10, 0, 40)
    Option.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Option.BorderSizePixel = 0
    Option.Parent = parent
    Option.LayoutOrder = #parent:GetChildren()

    local OptionCorner = Instance.new("UICorner")
    OptionCorner.CornerRadius = UDim.new(0, 6)
    OptionCorner.Parent = Option

    local OptionText = Instance.new("TextButton")
    OptionText.Size = UDim2.new(0.7, -10, 1, 0)
    OptionText.Position = UDim2.new(0, 10, 0, 0)
    OptionText.BackgroundTransparency = 1
    OptionText.Text = text
    OptionText.TextColor3 = Color3.fromRGB(255, 255, 255)
    OptionText.Font = Enum.Font.Gotham
    OptionText.TextSize = 16
    OptionText.TextXAlignment = Enum.TextXAlignment.Left
    OptionText.TextYAlignment = Enum.TextYAlignment.Center
    OptionText.Parent = Option

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 60, 0, 30)
    Toggle.Position = UDim2.new(1, -65, 0.5, -15)
    Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Toggle.Text = Settings[settingKey] and "ON" or "OFF"
    Toggle.TextColor3 = Settings[settingKey] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 14
    Toggle.AutoButtonColor = false
    Toggle.Parent = Option
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = Toggle

    local function toggleAction()
        Settings[settingKey] = not Settings[settingKey]
        Toggle.Text = Settings[settingKey] and "ON" or "OFF"
        Toggle.TextColor3 = Settings[settingKey] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        SaveSettings()
    end

    Toggle.MouseButton1Click:Connect(toggleAction)
    Toggle.TouchTap:Connect(toggleAction)
    OptionText.MouseButton1Click:Connect(toggleAction)
    OptionText.TouchTap:Connect(toggleAction)

    local function updateCanvasSize()
        local layout = parent:FindFirstChildOfClass("UIListLayout")
        if layout then
            local totalHeight = layout.AbsoluteContentSize.Y + 10
            parent.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        end
    end
    updateCanvasSize()
    Option:GetPropertyChangedSignal("Parent"):Connect(updateCanvasSize)

    return Option, Toggle
end

-- Функция создания слайдера
local function CreateSliderOption(parent, text, settingKey, minValue, maxValue, defaultValue)
    local Option = Instance.new("Frame")
    Option.Size = UDim2.new(1, -10, 0, 40)
    Option.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Option.BorderSizePixel = 0
    Option.Parent = parent
    Option.LayoutOrder = #parent:GetChildren()

    local OptionCorner = Instance.new("UICorner")
    OptionCorner.CornerRadius = UDim.new(0, 6)
    OptionCorner.Parent = Option

    local OptionText = Instance.new("TextButton")
    OptionText.Size = UDim2.new(0.5, -10, 1, 0)
    OptionText.Position = UDim2.new(0, 10, 0, 0)
    OptionText.BackgroundTransparency = 1
    OptionText.Text = text
    OptionText.TextColor3 = Color3.fromRGB(255, 255, 255)
    OptionText.Font = Enum.Font.Gotham
    OptionText.TextSize = 16
    OptionText.TextXAlignment = Enum.TextXAlignment.Left
    OptionText.TextYAlignment = Enum.TextYAlignment.Center
    OptionText.Parent = Option

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0, 100, 0, 20)
    SliderFrame.Position = UDim2.new(0.65, 0, 0.5, -10)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderFrame.Parent = Option
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 4)
    SliderCorner.Parent = SliderFrame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(0, 0, 1, 0)
    SliderBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SliderBar.Parent = SliderFrame
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 4)
    BarCorner.Parent = SliderBar

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 40, 0, 20)
    ValueLabel.Position = UDim2.new(1, 5, 0.5, -10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(Settings[settingKey])
    ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 14
    ValueLabel.Parent = Option

    local MinusButton = Instance.new("TextButton")
    MinusButton.Size = UDim2.new(0, 20, 0, 20)
    MinusButton.Position = UDim2.new(0.55, -25, 0.5, -10)
    MinusButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinusButton.Text = "−"
    MinusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinusButton.Font = Enum.Font.GothamBold
    MinusButton.TextSize = 14
    MinusButton.Parent = Option
    local MinusCorner = Instance.new("UICorner")
    MinusCorner.CornerRadius = UDim.new(0, 4)
    MinusCorner.Parent = MinusButton

    local PlusButton = Instance.new("TextButton")
    PlusButton.Size = UDim2.new(0, 20, 0, 20)
    PlusButton.Position = UDim2.new(0.55, 5, 0.5, -10)
    PlusButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    PlusButton.Text = "+"
    PlusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlusButton.Font = Enum.Font.GothamBold
    PlusButton.TextSize = 14
    PlusButton.Parent = Option
    local PlusCorner = Instance.new("UICorner")
    PlusCorner.CornerRadius = UDim.new(0, 4)
    PlusCorner.Parent = PlusButton

    local function updateSlider()
        local value = Settings[settingKey]
        local ratio = (value - minValue) / (maxValue - minValue)
        SliderBar.Size = UDim2.new(ratio, 0, 1, 0)
        ValueLabel.Text = tostring(value)
        SaveSettings()
    end

    local function changeValue(delta)
        Settings[settingKey] = math.clamp(Settings[settingKey] + delta, minValue, maxValue)
        updateSlider()
    end

    MinusButton.MouseButton1Click:Connect(function() changeValue(-5) end)
    MinusButton.TouchTap:Connect(function() changeValue(-5) end)
    PlusButton.MouseButton1Click:Connect(function() changeValue(5) end)
    PlusButton.TouchTap:Connect(function() changeValue(5) end)

    local dragging = false
    SliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    SliderFrame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.X
            local framePos = SliderFrame.AbsolutePosition.X
            local frameSize = SliderFrame.AbsoluteSize.X
            local ratio = math.clamp((mousePos - framePos) / frameSize, 0, 1)
            Settings[settingKey] = math.floor(minValue + ratio * (maxValue - minValue))
            updateSlider()
        end
    end)
    SliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local function updateCanvasSize()
        local layout = parent:FindFirstChildOfClass("UIListLayout")
        if layout then
            local totalHeight = layout.AbsoluteContentSize.Y + 10
            parent.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        end
    end
    updateCanvasSize()
    Option:GetPropertyChangedSignal("Parent"):Connect(updateCanvasSize)

    return Option
end

-- Настройки (все по умолчанию выключены)
local Settings = {
    ESP = false,
    ESPMurderer = false,
    ESPSheriff = false,
    ESPInnocent = false,
    FullBright = false,
    Speed = false,
    SpeedValue = 25,
    NoClip = false,
    AutoPickup = false,
    KnifeAura = false,
    KnifeAuraRange = 15,
    AutoKill = false,
    Wallbang = false,
    TeleportToVictim = false,
    GunAura = false,
    GunAuraRange = 50,
    AutoShoot = false,
    FOV = false,
    FOVSize = 100,
    AntiAfk = false,
    HideNames = false,
    AutoFarmCoins = false,
    InfiniteJump = false,
    KillAll = false,
    CoinESP = false,
    SilentAim = false,
    KnifeThrowSpeed = false,
    BypassAntiCheat = false,
    SilentAimGun = false,
    RapidFire = false,
    SheriffESP = false,
    GodMode = false,
    Fly = false,
    PlayerTeleport = false
}

-- Сохранение и загрузка настроек
local function SaveSettings()
    if writefile then
        local success, err = pcall(function()
            writefile("MM2UltimateV2.txt", HttpService:JSONEncode(Settings))
        end)
        if not success then warn("Ошибка сохранения настроек: " .. err) end
    end
end

local function LoadSettings()
    if isfile and readfile then
        if isfile("MM2UltimateV2.txt") then
            local success, result = pcall(function()
                return HttpService:JSONDecode(readfile("MM2UltimateV2.txt"))
            end)
            if success then
                for k, v in pairs(result) do
                    Settings[k] = v
                end
            end
        end
    end
end
LoadSettings()

-- Создание опций
local Options = {
    General = {
        {text = "ESP", key = "ESP", isToggle = true},
        {text = "ESP Murderer Only", key = "ESPMurderer", isToggle = true},
        {text = "ESP Sheriff Only", key = "ESPSheriff", isToggle = true},
        {text = "ESP Innocent Only", key = "ESPInnocent", isToggle = true},
        {text = "FullBright", key = "FullBright", isToggle = true},
        {text = "Speed Hack", key = "Speed", isToggle = true},
        {text = "Speed Value", key = "SpeedValue", isSlider = true, min = 16, max = 50, default = 25},
        {text = "NoClip", key = "NoClip", isToggle = true},
        {text = "Auto Pickup Gun", key = "AutoPickup", isToggle = true},
        {text = "Auto Farm Coins", key = "AutoFarmCoins", isToggle = true},
        {text = "Infinite Jump", key = "InfiniteJump", isToggle = true},
        {text = "Kill All", key = "KillAll", isToggle = true},
        {text = "Coin ESP", key = "CoinESP", isToggle = true}
    },
    Murderer = {
        {text = "Knife Aura", key = "KnifeAura", isToggle = true},
        {text = "Knife Aura Range", key = "KnifeAuraRange", isSlider = true, min = 5, max = 30, default = 15},
        {text = "Auto Kill", key = "AutoKill", isToggle = true},
        {text = "Wallbang", key = "Wallbang", isToggle = true},
        {text = "Teleport to Victim", key = "TeleportToVictim", isToggle = true},
        {text = "Silent Aim", key = "SilentAim", isToggle = true},
        {text = "Knife Throw Speed", key = "KnifeThrowSpeed", isToggle = true},
        {text = "Bypass Anti-Cheat", key = "BypassAntiCheat", isToggle = true}
    },
    Sheriff = {
        {text = "Gun Aura", key = "GunAura", isToggle = true},
        {text = "Gun Aura Range", key = "GunAuraRange", isSlider = true, min = 10, max = 100, default = 50},
        {text = "Auto Shoot", key = "AutoShoot", isToggle = true},
        {text = "FOV Circle", key = "FOV", isToggle = true},
        {text = "FOV Size", key = "FOVSize", isSlider = true, min = 50, max = 200, default = 100},
        {text = "Silent Aim Gun", key = "SilentAimGun", isToggle = true},
        {text = "Rapid Fire", key = "RapidFire", isToggle = true},
        {text = "Sheriff ESP", key = "SheriffESP", isToggle = true}
    },
    Player = {
        {text = "Anti AFK", key = "AntiAfk", isToggle = true},
        {text = "Hide Names", key = "HideNames", isToggle = true},
        {text = "God Mode", key = "GodMode", isToggle = true},
        {text = "Fly", key = "Fly", isToggle = true},
        {text = "Player Teleport", key = "PlayerTeleport", isToggle = true}
    }
}

-- Инициализация опций
local Toggles = {}
for tabName, options in pairs(Options) do
    for _, option in ipairs(options) do
        local opt
        if option.isSlider then
            opt = CreateSliderOption(tabScrolls[tabName], option.text, option.key, option.min, option.max, option.default)
        else
            opt, Toggles[option.key] = CreateToggleOption(tabScrolls[tabName], option.text, option.key)
        end
    end
end

-- Сворачивание/разворачивание
local Minimized = false
Title.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    local newSize = Minimized and UDim2.new(0, 400, 0, 40) or UDim2.new(0, 400, 0, 300)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = newSize}):Play()
    TabButtons.Visible = not Minimized
    for _, scroll in pairs(tabScrolls) do
        scroll.Visible = not Minimized and scroll.Name == currentTab .. "Scroll"
    end
end)
Title.TouchTap:Connect(function()
    Minimized = not Minimized
    local newSize = Minimized and UDim2.new(0, 400, 0, 40) or UDim2.new(0, 400, 0, 300)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = newSize}):Play()
    TabButtons.Visible = not Minimized
    for _, scroll in pairs(tabScrolls) do
        scroll.Visible = not Minimized and scroll.Name == currentTab .. "Scroll"
    end
end)

-- Переключение вкладок
for tabName, button in pairs(tabButtons) do
    button.MouseButton1Click:Connect(function()
        currentTab = tabName
        for name, scroll in pairs(tabScrolls) do
            scroll.Visible = name == tabName
        end
        for name, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = name == tabName and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)
        end
    end)
    button.TouchTap:Connect(function()
        currentTab = tabName
        for name, scroll in pairs(tabScrolls) do
            scroll.Visible = name == tabName
        end
        for name, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = name == tabName and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)
        end
    end)
end

-- Перетаскивание меню
local function setupTouchDrag(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end
setupTouchDrag(MainFrame)

-- ESP
local ESPHighlights = {}
local ESPBillboards = {}
local function UpdateESP()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local role = player.Character:FindFirstChild("Role")
            local shouldShow = Settings.ESP and (
                (Settings.ESPMurderer and role and role.Value == "Murderer") or
                (Settings.ESPSheriff and role and role.Value == "Sheriff") or
                (Settings.ESPInnocent and (not role or role.Value == "Innocent")) or
                (Settings.SheriffESP and role and role.Value == "Murderer")
            )
            if shouldShow then
                if not ESPHighlights[player] then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = player.Name
                    Highlight.FillTransparency = 0.7
                    Highlight.OutlineTransparency = 0
                    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    Highlight.Parent = player.Character
                    ESPHighlights[player] = Highlight
                end
                if not ESPBillboards[player] then
                    local Billboard = Instance.new("BillboardGui")
                    Billboard.Name = player.Name .. "_ESP"
                    Billboard.Adornee = player.Character.HumanoidRootPart
                    Billboard.Size = UDim2.new(0, 100, 0, 50)
                    Billboard.StudsOffset = Vector3.new(0, 3, 0)
                    Billboard.AlwaysOnTop = true
                    Billboard.Parent = player.Character

                    local NameLabel = Instance.new("TextLabel")
                    NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    NameLabel.BackgroundTransparency = 1
                    NameLabel.Text = player.Name
                    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    NameLabel.Font = Enum.Font.GothamBold
                    NameLabel.TextSize = 14
                    NameLabel.TextStrokeTransparency = 0.8
                    NameLabel.Parent = Billboard

                    local RoleLabel = Instance.new("TextLabel")
                    RoleLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    RoleLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    RoleLabel.BackgroundTransparency = 1
                    RoleLabel.Text = role and role.Value or "Innocent"
                    RoleLabel.Font = Enum.Font.Gotham
                    RoleLabel.TextSize = 12
                    RoleLabel.TextStrokeTransparency = 0.8
                    RoleLabel.Parent = Billboard

                    ESPBillboards[player] = Billboard
                end
                if role then
                    if role.Value == "Murderer" then
                        ESPHighlights[player].FillColor = Color3.fromRGB(255, 0, 0)
                        ESPHighlights[player].OutlineColor = Color3.fromRGB(200, 0, 0)
                        ESPBillboards[player].TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                        ESPBillboards[player].TextLabel.Text = player.Name
                        ESPBillboards[player].TextLabel_2.Text = "Murderer"
                        ESPBillboards[player].TextLabel_2.TextColor3 = Color3.fromRGB(255, 0, 0)
                    elseif role.Value == "Sheriff" then
                        ESPHighlights[player].FillColor = Color3.fromRGB(0, 0, 255)
                        ESPHighlights[player].OutlineColor = Color3.fromRGB(0, 0, 200)
                        ESPBillboards[player].TextLabel.TextColor3 = Color3.fromRGB(0, 0, 255)
                        ESPBillboards[player].TextLabel.Text = player.Name
                        ESPBillboards[player].TextLabel_2.Text = "Sheriff"
                        ESPBillboards[player].TextLabel_2.TextColor3 = Color3.fromRGB(0, 0, 255)
                    else
                        ESPHighlights[player].FillColor = Color3.fromRGB(0, 255, 0)
                        ESPHighlights[player].OutlineColor = Color3.fromRGB(0, 200, 0)
                        ESPBillboards[player].TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                        ESPBillboards[player].TextLabel.Text = player.Name
                        ESPBillboards[player].TextLabel_2.Text = "Innocent"
                        ESPBillboards[player].TextLabel_2.TextColor3 = Color3.fromRGB(0, 255, 0)
                    end
                end
            else
                if ESPHighlights[player] then
                    ESPHighlights[player]:Destroy()
                    ESPHighlights[player] = nil
                end
                if ESPBillboards[player] then
                    ESPBillboards[player]:Destroy()
                    ESPBillboards[player] = nil
                end
            end
        else
            if ESPHighlights[player] then
                ESPHighlights[player]:Destroy()
                ESPHighlights[player] = nil
            end
            if ESPBillboards[player] then
                ESPBillboards[player]:Destroy()
                ESPBillboards[player] = nil
            end
        end
    end
end

-- Coin ESP
local CoinHighlights = {}
local function UpdateCoinESP()
    if Settings.CoinESP then
        for _, coin in ipairs(workspace:GetDescendants()) do
            if coin.Name == "Coin" and coin:IsA("BasePart") then
                if not CoinHighlights[coin] then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = coin.Name
                    Highlight.FillTransparency = 0.5
                    Highlight.OutlineTransparency = 0
                    Highlight.FillColor = Color3.fromRGB(255, 215, 0)
                    Highlight.OutlineColor = Color3.fromRGB(200, 165, 0)
                    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    Highlight.Parent = coin
                    CoinHighlights[coin] = Highlight
                end
            end
        end
    else
        for _, highlight in pairs(CoinHighlights) do
            highlight:Destroy()
        end
        CoinHighlights = {}
    end
end

-- FullBright
local function UpdateFullBright()
    if Settings.FullBright then
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
    else
        Lighting.GlobalShadows = true
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 1000
    end
end

-- Speed Hack
local function UpdateSpeed()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = Settings.Speed and Settings.SpeedValue or 16
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
            task.wait(0.05)
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
                    if distance <= Settings.KnifeAuraRange then
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
                    if distance <= 25 then
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
                    if distance <= Settings.GunAuraRange then
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
                    if distance <= Settings.FOVSize then
                        Player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(Player.Character.HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position)
                        game:GetService("ReplicatedStorage").GunEvent:FireServer(player.Character.HumanoidRootPart.Position)
                    end
                end
            end
        end
    end
end

-- FOV Circle
local FOVCircleGui = nil
local function UpdateFOV()
    if Settings.FOV then
        if not FOVCircleGui then
            FOVCircleGui = Instance.new("ScreenGui")
            FOVCircleGui.Name = "FOVCircleGui"
            FOVCircleGui.Parent = CoreGui
            FOVCircleGui.IgnoreGuiInset = true

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, Settings.FOVSize * 2, 0, Settings.FOVSize * 2)
            Circle.Position = UDim2.new(0.5, -Settings.FOVSize, 0.5, -Settings.FOVSize)
            Circle.BackgroundTransparency = 1
            Circle.Parent = FOVCircleGui

            local UIStroke = Instance.new("UIStroke")
            UIStroke.Thickness = 2
            UIStroke.Color = Color3.fromRGB(0, 170, 255)
            UIStroke.Transparency = 0.3
            UIStroke.Parent = Circle

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(1, 0)
            UICorner.Parent = Circle
        end
        FOVCircleGui.Frame.Size = UDim2.new(0, Settings.FOVSize * 2, 0, Settings.FOVSize * 2)
        FOVCircleGui.Frame.Position = UDim2.new(0.5, -Settings.FOVSize, 0.5, -Settings.FOVSize)
    elseif FOVCircleGui then
        FOVCircleGui:Destroy()
        FOVCircleGui = nil
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

-- Auto Farm Coins
local function AutoFarmCoins()
    if Settings.AutoFarmCoins and Player.Character then
        for _, coin in ipairs(workspace:GetDescendants()) do
            if coin.Name == "Coin" and coin:IsA("BasePart") then
                local distance = (Player.Character.HumanoidRootPart.Position - coin.Position).Magnitude
                if distance < 20 then
                    firetouchinterest(Player.Character.HumanoidRootPart, coin, 0)
                    task.wait(0.05)
                    firetouchinterest(Player.Character.HumanoidRootPart, coin, 1)
                end
            end
        end
    end
end

-- Infinite Jump
local function InfiniteJump()
    if Settings.InfiniteJump and Player.Character then
        UserInputService.JumpRequest:Connect(function()
            if Settings.InfiniteJump then
                Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

-- Kill All
local function KillAll()
    if Settings.KillAll and Player.Character then
        local knife = Player.Character:FindFirstChild("Knife")
        local gun = Player.Character:FindFirstChild("Gun")
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                if knife then
                    game:GetService("ReplicatedStorage").KnifeHit:FireServer(player.Character.Humanoid, player.Character.HumanoidRootPart.CFrame)
                elseif gun then
                    game:GetService("ReplicatedStorage").GunEvent:FireServer(player.Character.HumanoidRootPart.Position)
                end
            end
        end
    end
end

-- Silent Aim (Murderer)
local function SilentAim()
    if Settings.SilentAim and Player.Character then
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
            if closestPlayer then
                game:GetService("ReplicatedStorage").KnifeHit:FireServer(closestPlayer.Character.Humanoid, closestPlayer.Character.HumanoidRootPart.CFrame)
            end
        end
    end
end

-- Knife Throw Speed
local function KnifeThrowSpeed()
    if Settings.KnifeThrowSpeed and Player.Character then
        local knife = Player.Character:FindFirstChild("Knife")
        if knife then
            knife.Velocity = knife.Velocity * 1.5 -- Увеличение скорости броска
        end
    end
end

-- Bypass Anti-Cheat (Murderer)
local function BypassAntiCheat()
    if Settings.BypassAntiCheat and Player.Character then
        -- Простой обход анти-чита (фиктивный, для примера)
        Player.Character.HumanoidRootPart.Anchored = false
    end
end

-- Silent Aim Gun (Sheriff)
local function SilentAimGun()
    if Settings.SilentAimGun and Player.Character then
        local gun = Player.Character:FindFirstChild("Gun")
        if gun then
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
                game:GetService("ReplicatedStorage").GunEvent:FireServer(closestPlayer.Character.HumanoidRootPart.Position)
            end
        end
    end
end

-- Rapid Fire
local function RapidFire()
    if Settings.RapidFire and Player.Character then
        local gun = Player.Character:FindFirstChild("Gun")
        if gun then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    game:GetService("ReplicatedStorage").GunEvent:FireServer(player.Character.HumanoidRootPart.Position)
                    task.wait(0.05) -- Ускоренная стрельба
                end
            end
        end
    end
end

-- God Mode
local function GodMode()
    if Settings.GodMode and Player.Character then
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
    end
end

-- Fly
local function Fly()
    if Settings.Fly and Player.Character then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 50, 0)
        bodyVelocity.Parent = Player.Character.HumanoidRootPart
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then
                bodyVelocity.Velocity = Vector3.new(0, 50, 0)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if Player.Character and Player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
            Player.Character.HumanoidRootPart.BodyVelocity:Destroy()
        end
    end
end

-- Player Teleport
local function PlayerTeleport()
    if Settings.PlayerTeleport and Player.Character then
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
            Player.Character.HumanoidRootPart.CFrame = closestPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        end
    end
end

-- Обновление после окончания матча
local function ResetOnRoundEnd()
    for _, highlight in pairs(ESPHighlights) do
        highlight:Destroy()
    end
    for _, billboard in pairs(ESPBillboards) do
        billboard:Destroy()
    end
    for _, highlight in pairs(CoinHighlights) do
        highlight:Destroy()
    end
    ESPHighlights = {}
    ESPBillboards = {}
    CoinHighlights = {}
    UpdateESP()
    UpdateFOV()
    UpdateCoinESP()
end

game:GetService("ReplicatedStorage").ChildAdded:Connect(function(child)
    if child.Name == "RoundEnd" then
        ResetOnRoundEnd()
    end
end)

-- Основной цикл
RunService.Heartbeat:Connect(function()
    if Settings.ESP or Settings.SheriffESP then
        UpdateESP()
    else
        for _, highlight in pairs(ESPHighlights) do
            highlight:Destroy()
        end
        for _, billboard in pairs(ESPBillboards) do
            billboard:Destroy()
        end
        ESPHighlights = {}
        ESPBillboards = {}
    end
    UpdateCoinESP()
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
    AutoFarmCoins()
    InfiniteJump()
    KillAll()
    SilentAim()
    KnifeThrowSpeed()
    BypassAntiCheat()
    SilentAimGun()
    RapidFire()
    GodMode()
    Fly()
    PlayerTeleport()
end)

-- Обработка нового персонажа
Player.CharacterAdded:Connect(function(character)
    if Settings.Speed then
        character:WaitForChild("Humanoid").WalkSpeed = Settings.SpeedValue
    end
    ResetOnRoundEnd()
end)

-- Горячая клавиша для меню
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

_G.MM2UltimateV2 = ScreenGui