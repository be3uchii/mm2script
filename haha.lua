local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Конфигурация
local config = {
    hitbox = {
        enabled = false,
        size = Vector3.new(5, 5, 5),
        transparency = 0.7,
        color = Color3.fromRGB(255, 0, 0)
    },
    esp = {
        enabled = false,
        teamCheck = true,
        box = true,
        name = true,
        health = true,
        distance = true,
        tracer = true,
        chams = true
    },
    aimbot = {
        enabled = false,
        fov = 50,
        smoothness = 0.2,
        teamCheck = true,
        visibleCheck = true,
        keybind = Enum.UserInputType.MouseButton2
    },
    misc = {
        speed = false,
        speedValue = 30,
        jumpPower = false,
        jumpValue = 50,
        noClip = false,
        infiniteStamina = false
    }
}

-- UI Конфигурация
local uiConfig = {
    theme = {
        primary = Color3.fromRGB(20, 20, 25),
        secondary = Color3.fromRGB(30, 30, 35),
        accent = Color3.fromRGB(0, 150, 255),
        text = Color3.fromRGB(240, 240, 240),
        error = Color3.fromRGB(255, 50, 50)
    },
    icons = {
        combat = "rbxassetid://7072717428",
        esp = "rbxassetid://7072708772",
        misc = "rbxassetid://7072723420",
        settings = "rbxassetid://6031280882",
        search = "rbxassetid://3926305904",
        close = "rbxassetid://3926307971",
        minimize = "rbxassetid://6031094679",
        expand = "rbxassetid://6031094667",
        toggleOn = "rbxassetid://7078538820",
        toggleOff = "rbxassetid://7078539136"
    },
    mobile = true
}

-- Создание основного GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MVSD_Hub"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Size = uiConfig.mobile and UDim2.new(0.9, 0, 0.7, 0) or UDim2.new(0, 400, 0, 600)
mainFrame.Position = uiConfig.mobile and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, -200, 0.5, -300)
mainFrame.AnchorPoint = uiConfig.mobile and Vector2.new(0.5, 0.5) or Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = uiConfig.theme.primary
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = uiConfig.theme.secondary
uiStroke.Thickness = 2
uiStroke.Parent = mainFrame

-- Заголовок с поиском
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = uiConfig.theme.secondary
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Text = "MVSD Premium"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = uiConfig.theme.text
title.BackgroundTransparency = 1
title.Parent = header

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0.45, -10, 0, 30)
searchBox.Position = UDim2.new(0.55, 5, 0.5, -15)
searchBox.PlaceholderText = "Поиск..."
searchBox.Text = ""
searchBox.BackgroundColor3 = uiConfig.theme.primary
searchBox.TextColor3 = uiConfig.theme.text
searchBox.Font = Enum.Font.GothamMedium
searchBox.TextSize = 14
searchBox.Parent = header

local searchIcon = Instance.new("ImageLabel")
searchIcon.Size = UDim2.new(0, 20, 0, 20)
searchIcon.Position = UDim2.new(1, -25, 0.5, -10)
searchIcon.Image = uiConfig.icons.search
searchIcon.Parent = searchBox

-- Система вкладок
local tabButtons = {}
local tabContents = {}
local tabs = {
    {name = "Combat", icon = uiConfig.icons.combat},
    {name = "Esp", icon = uiConfig.icons.esp},
    {name = "Misc", icon = uiConfig.icons.misc},
    {name = "Settings", icon = uiConfig.icons.settings}
}

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 40)
tabContainer.Position = UDim2.new(0, 10, 0, 60)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

for i, tab in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1/#tabs, -10, 1, 0)
    tabButton.Position = UDim2.new((i-1)/#tabs, 5, 0, 0)
    tabButton.Text = ""
    tabButton.BackgroundColor3 = i == 1 and uiConfig.theme.accent or uiConfig.theme.secondary
    tabButton.Parent = tabContainer
    
    local tabIcon = Instance.new("ImageLabel")
    tabIcon.Size = UDim2.new(0, 24, 0, 24)
    tabIcon.Position = UDim2.new(0.5, -12, 0.5, -12)
    tabIcon.Image = tab.icon
    tabIcon.Parent = tabButton
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, -20, 1, -120)
    tabContent.Position = UDim2.new(0, 10, 0, 110)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = uiConfig.theme.accent
    tabContent.Visible = i == 1
    tabContent.Parent = mainFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.Parent = tabContent
    
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    tabButtons[i] = tabButton
    tabContents[i] = tabContent
end

-- Функции для создания элементов UI
local function createSection(title, parent)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 40)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = title
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextColor3 = uiConfig.theme.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = section
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 25)
    line.BackgroundColor3 = uiConfig.theme.accent
    line.Parent = section
    
    return section
end

local function createToggle(name, state, callback, parent)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, 0, 0, 40)
    toggle.BackgroundTransparency = 1
    toggle.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = uiConfig.theme.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = toggle
    
    local button = Instance.new("ImageButton")
    button.Size = UDim2.new(0, 50, 0, 25)
    button.Position = UDim2.new(1, -50, 0.5, -12.5)
    button.Image = state and uiConfig.icons.toggleOn or uiConfig.icons.toggleOff
    button.BackgroundTransparency = 1
    button.Parent = toggle
    
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Image = state and uiConfig.icons.toggleOn or uiConfig.icons.toggleOff
        callback(state)
    end)
    
    return toggle
end

local function createSlider(name, min, max, value, callback, parent)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 60)
    slider.BackgroundTransparency = 1
    slider.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. value
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = uiConfig.theme.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = slider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 5)
    track.Position = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = uiConfig.theme.secondary
    track.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = uiConfig.theme.accent
    fill.Parent = track
    
    local handle = Instance.new("TextButton")
    handle.Size = UDim2.new(0, 15, 0, 15)
    handle.Position = UDim2.new((value - min)/(max - min), -7.5, 0.5, -7.5)
    handle.Text = ""
    handle.BackgroundColor3 = uiConfig.theme.text
    handle.Parent = slider
    
    local dragging = false
    local function updateValue(input)
        local pos = (input.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X
        pos = math.clamp(pos, 0, 1)
        local newValue = math.floor(min + (max - min)*pos)
        if newValue ~= value then
            value = newValue
            label.Text = name .. ": " .. value
            fill.Size = UDim2.new(pos, 0, 1, 0)
            handle.Position = UDim2.new(pos, -7.5, 0.5, -7.5)
            callback(value)
        end
    end
    
    handle.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input)
        end
    end)
    
    track.MouseButton1Down:Connect(function(x, y)
        updateValue({Position = Vector2.new(x, y)})
    end)
    
    return slider
end

-- Заполнение вкладок
local combatSection = createSection("Aimbot", tabContents[1])
createToggle("Enable Aimbot", config.aimbot.enabled, function(state)
    config.aimbot.enabled = state
end, combatSection)

createSlider("Aimbot FOV", 5, 200, config.aimbot.fov, function(value)
    config.aimbot.fov = value
end, combatSection)

createSlider("Smoothness", 0, 1, config.aimbot.smoothness*10, function(value)
    config.aimbot.smoothness = value/10
end, combatSection)

local hitboxSection = createSection("Hitbox", tabContents[1])
createToggle("Enable Hitbox", config.hitbox.enabled, function(state)
    config.hitbox.enabled = state
    updateHitboxes()
end, hitboxSection)

createSlider("Hitbox Size", 1, 10, config.hitbox.size.X, function(value)
    config.hitbox.size = Vector3.new(value, value, value)
    updateHitboxes()
end, hitboxSection)

local espSection = createSection("ESP", tabContents[2])
createToggle("Enable ESP", config.esp.enabled, function(state)
    config.esp.enabled = state
    updateESP()
end, espSection)

createToggle("Team Check", config.esp.teamCheck, function(state)
    config.esp.teamCheck = state
    updateESP()
end, espSection)

createToggle("Box ESP", config.esp.box, function(state)
    config.esp.box = state
    updateESP()
end, espSection)

createToggle("Name ESP", config.esp.name, function(state)
    config.esp.name = state
    updateESP()
end, espSection)

createToggle("Health ESP", config.esp.health, function(state)
    config.esp.health = state
    updateESP()
end, espSection)

createToggle("Distance ESP", config.esp.distance, function(state)
    config.esp.distance = state
    updateESP()
end, espSection)

createToggle("Tracers", config.esp.tracer, function(state)
    config.esp.tracer = state
    updateESP()
end, espSection)

createToggle("Chams", config.esp.chams, function(state)
    config.esp.chams = state
    updateESP()
end, espSection)

local miscSection = createSection("Movement", tabContents[3])
createToggle("Speed Hack", config.misc.speed, function(state)
    config.misc.speed = state
    updateMovement()
end, miscSection)

createSlider("Speed Value", 16, 100, config.misc.speedValue, function(value)
    config.misc.speedValue = value
    updateMovement()
end, miscSection)

createToggle("High Jump", config.misc.jumpPower, function(state)
    config.misc.jumpPower = state
    updateMovement()
end, miscSection)

createSlider("Jump Value", 20, 150, config.misc.jumpValue, function(value)
    config.misc.jumpValue = value
    updateMovement()
end, miscSection)

createToggle("No Clip", config.misc.noClip, function(state)
    config.misc.noClip = state
    updateMovement()
end, miscSection)

createToggle("Infinite Stamina", config.misc.infiniteStamina, function(state)
    config.misc.infiniteStamina = state
    updateMovement()
end, miscSection)

-- Система поиска
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = string.lower(searchBox.Text)
    
    for _, content in ipairs(tabContents) do
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("Frame") then
                local label = child:FindFirstChildOfClass("TextLabel")
                if label then
                    child.Visible = string.find(string.lower(label.Text), searchText) ~= nil
                end
            end
        end
    end
end)

-- Функции для игровых механик
local hitboxParts = {}
local espObjects = {}
local chamParts = {}

local function updateHitboxes()
    for _, part in pairs(hitboxParts) do
        part:Destroy()
    end
    hitboxParts = {}
    
    if not config.hitbox.enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local hitbox = Instance.new("Part")
                    hitbox.Size = config.hitbox.size
                    hitbox.Transparency = config.hitbox.transparency
                    hitbox.Color = config.hitbox.color
                    hitbox.Anchored = true
                    hitbox.CanCollide = false
                    hitbox.Material = Enum.Material.Neon
                    hitbox.Parent = workspace
                    
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = humanoidRootPart
                    weld.Part1 = hitbox
                    weld.Parent = hitbox
                    
                    table.insert(hitboxParts, hitbox)
                end
            end
        end
    end
end

local function updateESP()
    for _, obj in pairs(espObjects) do
        for _, element in pairs(obj) do
            element:Destroy()
        end
    end
    espObjects = {}
    
    for _, part in pairs(chamParts) do
        part:Destroy()
    end
    chamParts = {}
    
    if not config.esp.enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    espObjects[player] = {}
                    
                    -- Box ESP
                    if config.esp.box then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Size = character:GetExtentsSize() * 1.1
                        box.Adornee = humanoidRootPart
                        box.AlwaysOnTop = true
                        box.ZIndex = 5
                        box.Transparency = 0.5
                        box.Color3 = player.TeamColor.Color
                        box.Parent = character
                        table.insert(espObjects[player], box)
                    end
                    
                    -- Name ESP
                    if config.esp.name then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Size = UDim2.new(0, 100, 0, 40)
                        billboard.Adornee = humanoidRootPart
                        billboard.AlwaysOnTop = true
                        billboard.ExtentsOffset = Vector3.new(0, 3, 0)
                        
                        local nameLabel = Instance.new("TextLabel")
                        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                        nameLabel.Text = player.Name
                        nameLabel.TextColor3 = Color3.new(1, 1, 1)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Parent = billboard
                        
                        billboard.Parent = character
                        table.insert(espObjects[player], billboard)
                    end
                    
                    -- Chams
                    if config.esp.chams then
                        for _, part in ipairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                local highlight = Instance.new("Highlight")
                                highlight.FillColor = player.TeamColor.Color
                                highlight.OutlineColor = Color3.new(1, 1, 1)
                                highlight.FillTransparency = 0.5
                                highlight.OutlineTransparency = 0
                                highlight.Parent = part
                                table.insert(chamParts, highlight)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function updateMovement()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = config.misc.speed and config.misc.speedValue or 16
            humanoid.JumpPower = config.misc.jumpPower and config.misc.jumpValue or 50
            
            if config.misc.infiniteStamina then
                for _, v in ipairs(character:GetDescendants()) do
                    if v:IsA("NumberValue") and v.Name == "Stamina" then
                        v.Value = 100
                    end
                end
            end
        end
    end
end

-- Aimbot
local function findClosestPlayer()
    local closestPlayer = nil
    local closestDistance = config.aimbot.fov
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                if config.aimbot.teamCheck and player.Team == LocalPlayer.Team then continue end
                
                local screenPoint = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if screenPoint.Z > 0 then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local playerPos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local distance = (mousePos - playerPos).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimAt(target)
    if not target or not target.Character then return end
    
    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local camera = workspace.CurrentCamera
    local targetPosition = humanoidRootPart.Position
    
    if config.aimbot.visibleCheck then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, target.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local raycastResult = workspace:Raycast(camera.CFrame.Position, (targetPosition - camera.CFrame.Position).Unit * 1000, raycastParams)
        if raycastResult and raycastResult.Instance:IsDescendantOf(target.Character) == false then
            return
        end
    end
    
    local currentCFrame = camera.CFrame
    local targetCFrame = CFrame.new(camera.CFrame.Position, targetPosition)
    
    local newCFrame = currentCFrame:Lerp(targetCFrame, config.aimbot.smoothness)
    camera.CFrame = newCFrame
end

-- No Clip
local noclipConnection
local function updateNoClip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if config.misc.noClip then
        noclipConnection = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- Обработчики событий
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        updateHitboxes()
        updateESP()
    end)
end)

Players.PlayerRemoving:Connect(function()
    updateHitboxes()
    updateESP()
end)

LocalPlayer.CharacterAdded:Connect(function()
    updateMovement()
    updateNoClip()
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.UserInputType == config.aimbot.keybind and config.aimbot.enabled then
        local target = findClosestPlayer()
        if target then
            aimAt(target)
        end
    end
end)

-- Инициализация
updateHitboxes()
updateESP()
updateMovement()
updateNoClip()

-- Горячие клавиши
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed then
        if input.KeyCode == Enum.KeyCode.RightShift then
            mainFrame.Visible = not mainFrame.Visible
        elseif input.KeyCode == Enum.KeyCode.F1 then
            for i, content in ipairs(tabContents) do
                content.Visible = i == 1
            end
        end
    end
end)

-- Адаптация под мобильные устройства
if uiConfig.mobile then
    local resizeButton = Instance.new("TextButton")
    resizeButton.Size = UDim2.new(0, 30, 0, 30)
    resizeButton.Position = UDim2.new(1, -35, 1, -35)
    resizeButton.Text = "↔"
    resizeButton.TextSize = 20
    resizeButton.BackgroundColor3 = uiConfig.theme.accent
    resizeButton.Parent = mainFrame
    
    local dragging = false
    local startPos
    local startSize
    
    resizeButton.MouseButton1Down:Connect(function()
        dragging = true
        startPos = UserInputService:GetMouseLocation()
        startSize = mainFrame.Size
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local currentPos = UserInputService:GetMouseLocation()
            local delta = currentPos - startPos
            local newWidth = math.clamp(startSize.Width.Offset + delta.X, 300, 800)
            local newHeight = math.clamp(startSize.Height.Offset + delta.Y, 400, 1000)
            mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
end