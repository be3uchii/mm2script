-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- Локальный игрок
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Настройки
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

-- Глобальные переменные
local GUI, FOVCircle, AimButton
local Sheriff, Murderer
local ESPCache = {}
local Connections = {}

-- Функция для создания GUI
local function CreateGUI()
    -- Основное окно
    GUI = Instance.new("ScreenGui")
    GUI.Name = "MM2EnhancedGUI"
    GUI.ResetOnSpawn = false
    GUI.Parent = Player.PlayerGui

    -- Главный фрейм
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

    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.BorderSizePixel = 0
    Title.Text = "MM2 Улучшенный v2.0"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.Parent = MainFrame

    -- Кнопки управления
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
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.TextSize = 18
    MinimizeButton.Parent = MainFrame

    -- Вкладки
    local TabButtons = Instance.new("Frame")
    TabButtons.Name = "TabButtons"
    TabButtons.Size = UDim2.new(1, 0, 0, 30)
    TabButtons.Position = UDim2.new(0, 0, 0, 30)
    TabButtons.BackgroundTransparency = 1
    TabButtons.Parent = MainFrame

    local ESPTab = Instance.new("TextButton")
    ESPTab.Name = "ESPTab"
    ESPTab.Size = UDim2.new(0.33, -2, 1, 0)
    ESPTab.Position = UDim2.new(0, 0, 0, 0)
    ESPTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ESPTab.BorderSizePixel = 0
    ESPTab.Text = "ESP"
    ESPTab.TextColor3 = Color3.new(1, 1, 1)
    ESPTab.Font = Enum.Font.SourceSans
    ESPTab.TextSize = 14
    ESPTab.Parent = TabButtons

    local SheriffTab = Instance.new("TextButton")
    SheriffTab.Name = "SheriffTab"
    SheriffTab.Size = UDim2.new(0.33, -2, 1, 0)
    SheriffTab.Position = UDim2.new(0.33, 0, 0, 0)
    SheriffTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SheriffTab.BorderSizePixel = 0
    SheriffTab.Text = "Шериф"
    SheriffTab.TextColor3 = Color3.new(1, 1, 1)
    SheriffTab.Font = Enum.Font.SourceSans
    SheriffTab.TextSize = 14
    SheriffTab.Parent = TabButtons

    local MurdererTab = Instance.new("TextButton")
    MurdererTab.Name = "MurdererTab"
    MurdererTab.Size = UDim2.new(0.33, -2, 1, 0)
    MurdererTab.Position = UDim2.new(0.66, 0, 0, 0)
    MurdererTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    MurdererTab.BorderSizePixel = 0
    MurdererTab.Text = "Убийца"
    MurdererTab.TextColor3 = Color3.new(1, 1, 1)
    MurdererTab.Font = Enum.Font.SourceSans
    MurdererTab.TextSize = 14
    MurdererTab.Parent = TabButtons

    -- Контейнеры вкладок
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -10, 1, -70)
    TabContainer.Position = UDim2.new(0, 5, 0, 65)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    -- Вкладка ESP
    local ESPContainer = Instance.new("ScrollingFrame")
    ESPContainer.Name = "ESPContainer"
    ESPContainer.Size = UDim2.new(1, 0, 1, 0)
    ESPContainer.BackgroundTransparency = 1
    ESPContainer.ScrollBarThickness = 5
    ESPContainer.CanvasSize = UDim2.new(0, 0, 0, 500)
    ESPContainer.Visible = true
    ESPContainer.Parent = TabContainer

    -- Вкладка Шерифа
    local SheriffContainer = Instance.new("ScrollingFrame")
    SheriffContainer.Name = "SheriffContainer"
    SheriffContainer.Size = UDim2.new(1, 0, 1, 0)
    SheriffContainer.BackgroundTransparency = 1
    SheriffContainer.ScrollBarThickness = 5
    SheriffContainer.CanvasSize = UDim2.new(0, 0, 0, 300)
    SheriffContainer.Visible = false
    SheriffContainer.Parent = TabContainer

    -- Вкладка Убийцы
    local MurdererContainer = Instance.new("ScrollingFrame")
    MurdererContainer.Name = "MurdererContainer"
    MurdererContainer.Size = UDim2.new(1, 0, 1, 0)
    MurdererContainer.BackgroundTransparency = 1
    MurdererContainer.ScrollBarThickness = 5
    MurdererContainer.CanvasSize = UDim2.new(0, 0, 0, 200)
    MurdererContainer.Visible = false
    MurdererContainer.Parent = TabContainer

    -- Функция для создания переключателей
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
        toggleButton.Text = setting.Enabled and "ВКЛ" or "ВЫКЛ"
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
            toggleButton.Text = setting.Enabled and "ВКЛ" or "ВЫКЛ"
        end)

        return toggleFrame
    end

    -- Функция для создания слайдеров
    local function CreateSlider(parent, name, setting, min, max, yOffset)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = name .. "Slider"
        sliderFrame.Size = UDim2.new(1, -10, 0, 50)
        sliderFrame.Position = UDim2.new(0, 5, 0, yOffset)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = parent

        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Name = "SliderLabel"
        sliderLabel.Size = UDim2.new(1, 0, 0, 25)
        sliderLabel.Position = UDim2.new(0, 0, 0, 0)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Text = name .. ": " .. tostring(setting)
        sliderLabel.TextColor3 = Color3.new(1, 1, 1)
        sliderLabel.Font = Enum.Font.SourceSans
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
                sliderLabel.Text = name .. ": " .. tostring(setting)
            else
                sliderBox.Text = tostring(setting)
            end
        end)

        return sliderFrame
    end

    -- Создаем элементы ESP
    local yOffset = 0
    CreateToggle(ESPContainer, "Включить ESP", Settings.ESP, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Шериф", Settings.ESP.Sheriff, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Убийца", Settings.ESP.Murderer, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Игроки", Settings.ESP.Innocent, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Пистолет", Settings.ESP.Gun, yOffset)
    yOffset = yOffset + 35
    CreateToggle(ESPContainer, "Монеты", Settings.ESP.Coin, yOffset)

    -- Создаем элементы Шерифа
    yOffset = 0
    CreateToggle(SheriffContainer, "Аим-помощь", Settings.Sheriff.AimAssist, yOffset)
    yOffset = yOffset + 35
    CreateSlider(SheriffContainer, "FOV", Settings.Sheriff.AimAssist.FOV, 10, 200, yOffset)
    yOffset = yOffset + 55
    CreateSlider(SheriffContainer, "Плавность", Settings.Sheriff.AimAssist.Smoothness, 0.1, 1, yOffset)
    yOffset = yOffset + 55
    CreateToggle(SheriffContainer, "Показывать FOV", Settings.Sheriff.AimAssist, yOffset)

    -- Создаем элементы Убийцы
    yOffset = 0
    CreateToggle(MurdererContainer, "Килл-аура", Settings.Murderer.KillAura, yOffset)
    yOffset = yOffset + 35
    CreateSlider(MurdererContainer, "Дистанция", Settings.Murderer.KillAura.Range, 5, 30, yOffset)

    -- Создаем FOV круг
    FOVCircle = Instance.new("Frame")
    FOVCircle.Name = "FOVCircle"
    FOVCircle.Size = UDim2.new(0, Settings.Sheriff.AimAssist.FOV * 2, 0, Settings.Sheriff.AimAssist.FOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -Settings.Sheriff.AimAssist.FOV, 0.5, -Settings.Sheriff.AimAssist.FOV)
    FOVCircle.BackgroundTransparency = 0.9
    FOVCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    FOVCircle.BorderSizePixel = 0
    FOVCircle.Visible = Settings.Sheriff.AimAssist.Visible and Settings.Menu.Open
    FOVCircle.Parent = GUI

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = FOVCircle

    -- Создаем кнопку аима для шерифа
    AimButton = Instance.new("TextButton")
    AimButton.Name = "AimButton"
    AimButton.Size = Settings.Sheriff.AimAssist.Button.Size
    AimButton.Position = Settings.Sheriff.AimAssist.Button.Position
    AimButton.BackgroundColor3 = Settings.Sheriff.AimAssist.Button.Color
    AimButton.BackgroundTransparency = Settings.Sheriff.AimAssist.Button.Transparency
    AimButton.BorderSizePixel = 0
    AimButton.Text = "АИМ"
    AimButton.TextColor3 = Color3.new(1, 1, 1)
    AimButton.Font = Enum.Font.SourceSansBold
    AimButton.TextSize = 14
    AimButton.Visible = false
    AimButton.Active = true
    AimButton.Draggable = true
    AimButton.Parent = GUI

    local aimCorner = Instance.new("UICorner")
    aimCorner.CornerRadius = UDim.new(0.5, 0)
    aimCorner.Parent = AimButton

    -- Обработчики событий
    CloseButton.MouseButton1Click:Connect(function()
        GUI:Destroy()
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        Settings.Menu.Open = not Settings.Menu.Open
        MainFrame.Visible = Settings.Menu.Open
        FOVCircle.Visible = Settings.Sheriff.AimAssist.Visible and Settings.Menu.Open
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
        AimButton.Visible = Settings.Sheriff.AimAssist.Enabled
    end)

    MurdererTab.MouseButton1Click:Connect(function()
        ESPContainer.Visible = false
        SheriffContainer.Visible = false
        MurdererContainer.Visible = true
    end)

    -- Обработчик для кнопки аима
    AimButton.MouseButton1Click:Connect(function()
        if Settings.Sheriff.AimAssist.Enabled and Sheriff and Murderer and Murderer.Character then
            local targetHRP = Murderer.Character:FindFirstChild("HumanoidRootPart")
            local localHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHRP and localHRP then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetHRP.Position)
                if onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local mousePos = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (mousePos - center).Magnitude

                    if distance <= Settings.Sheriff.AimAssist.FOV then
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Sheriff.AimAssist.Smoothness)
                        
                        -- Симулируем выстрел
                        if Player.Character then
                            local gun = Player.Character:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
                            if gun and gun:FindFirstChild("Handle") then
                                local args = {
                                    [1] = targetHRP.Position,
                                    [2] = gun.Handle
                                }
                                game:GetService("ReplicatedStorage"):FindFirstChild("ShootGun"):FireServer(unpack(args))
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Функция для создания ESP
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

    -- Обновляем ESP при удалении объекта
    object.AncestryChanged:Connect(function()
        if not object:IsDescendantOf(game) and ESPCache[object] then
            ESPCache[object]:Destroy()
            ESPCache[object] = nil
        end
    end)
end

-- Функция для удаления ESP
local function RemoveESP(object)
    if ESPCache[object] then
        ESPCache[object]:Destroy()
        ESPCache[object] = nil
    end
end

-- Функция для обновления ESP
local function UpdateESP()
    if not Settings.ESP.Enabled then
        for object, _ in pairs(ESPCache) do
            RemoveESP(object)
        end
        return
    end

    -- Игроки
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

    -- Пистолет
    if Settings.ESP.Gun.Enabled then
        local gun = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChildOfClass("Tool")
        if gun then
            CreateESP(gun, Settings.ESP.Gun.Color, Settings.ESP.Gun.ThroughWalls)
        end
    end

    -- Монеты
    if Settings.ESP.Coin.Enabled then
        for _, coin in ipairs(workspace:GetChildren()) do
            if coin.Name:find("Coin") or coin.Name:find("Diamond") then
                CreateESP(coin, Settings.ESP.Coin.Color, Settings.ESP.Coin.ThroughWalls)
            end
        end
    end
end

-- Функция для определения ролей
local function FindRoles()
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

-- Функция для килл-ауры убийцы
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

-- Основной цикл
local function MainLoop()
    FindRoles()
    UpdateESP()

    if FOVCircle then
        FOVCircle.Size = UDim2.new(0, Settings.Sheriff.AimAssist.FOV * 2, 0, Settings.Sheriff.AimAssist.FOV * 2)
        FOVCircle.Position = UDim2.new(0.5, -Settings.Sheriff.AimAssist.FOV, 0.5, -Settings.Sheriff.AimAssist.FOV)
        FOVCircle.Visible = Settings.Sheriff.AimAssist.Visible and Settings.Menu.Open
    end

    if AimButton then
        AimButton.Visible = Settings.Sheriff.AimAssist.Enabled and (Player == Sheriff)
    end

    KillAura()
end

-- Инициализация
CreateGUI()

-- Обработчики событий
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

-- Очистка при отключении
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