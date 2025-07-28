local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 300, 200
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Visual"}
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local minimizedSize = UDim2.new(0, 80, 0, 28)
local minimizedPosition = UDim2.new(0.5, -40, 0, 10)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)

local settings = {
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 4,
            Color = Color3.fromRGB(255, 0, 0),
            Transparency = 0.5
        },
        AutoStomp = {
            Enabled = false,
            Range = 15
        }
    },
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Health = false,
        Distance = false,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.7,
        MaxDistance = 250
    },
    Visual = {
        NoFog = false,
        FullBright = false,
        NoShadows = false,
        Chams = {
            Enabled = false,
            Color = Color3.fromRGB(255, 0, 255),
            Transparency = 0.5
        },
        ViewBob = {
            Enabled = false,
            Intensity = 5
        }
    }
}

local espCache = {}
local hitboxCache = {}
local connections = {}
local tabButtons = {}
local contentFrames = {}
local scrollFrames = {}
local playerConnections = {}
local chamCache = {}

if PlayerGui:FindFirstChild("SilenceMenu") then
    PlayerGui.SilenceMenu:Destroy()
end

local function disableShadows()
    Lighting.GlobalShadows = false
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CastShadow = false
        end
    end
end

local function updateVisuals()
    if settings.Visual.NoFog then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = Lighting:GetAttribute("OriginalFogEnd") or 100000
    end
    
    if settings.Visual.FullBright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    end
    
    if settings.Visual.NoShadows then
        disableShadows()
    end
end

game:GetService("Workspace").DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") and settings.Visual.NoShadows then
        obj.CastShadow = false
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SilenceMenu"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Enabled = isVisible

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
mainFrame.Position = defaultPosition
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(80, 80, 255)
uiStroke.Thickness = 1.5
uiStroke.Transparency = 0.2
uiStroke.Parent = mainFrame

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, 0, 0, 28)
dragArea.BackgroundTransparency = 1
dragArea.Text = "SILENCE 3.1"
dragArea.TextColor3 = Color3.fromRGB(220, 220, 220)
dragArea.TextTransparency = 0.1
dragArea.TextSize = isMinimized and 12 or 14
dragArea.Font = Enum.Font.GothamBold
dragArea.TextXAlignment = Enum.TextXAlignment.Center
dragArea.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -10, 0, 26)
tabContainer.Position = UDim2.new(0, 5, 0, 30)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local function createToggle(parent, text, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 20)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Position = UDim2.new(0, 5, 0, 0)
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.25, 0, 0.8, 0)
    toggle.Position = UDim2.new(0.75, 0, 0.1, 0)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    toggle.Text = defaultValue and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 10
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = toggleFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = toggle
    
    local function updateToggle(value)
        local tween = TweenService:Create(toggle, tweenInfo, {
            BackgroundColor3 = value and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0),
            Text = value and "ON" or "OFF"
        })
        tween:Play()
        callback(value)
    end
    
    toggle.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        updateToggle(defaultValue)
    end)
    
    return toggleFrame
end

local function createSlider(parent, text, min, max, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 20)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Position = UDim2.new(0, 5, 0, 0)
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.25, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.75, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    valueLabel.TextTransparency = 0.1
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -10, 0, 4)
    slider.Position = UDim2.new(0, 5, 0, 24)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    slider.BorderSizePixel = 0
    slider.Parent = sliderFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 2)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
    
    local dragging = false
    
    local function updateValue(value)
        value = math.clamp(value, min, max)
        valueLabel.Text = tostring(math.floor(value * 10) / 10)
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        callback(value)
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local value = min + ((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X) * (max - min)
            updateValue(value)
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    slider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local value = min + ((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X) * (max - min)
            updateValue(value)
        end
    end)
    
    return sliderFrame
end

local function createESP(player)
    if espCache[player] then return end
    
    local espData = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    
    espData.Box.Visible = false
    espData.Box.Color = settings.ESP.Color
    espData.Box.Thickness = 1
    espData.Box.Transparency = settings.ESP.Transparency
    espData.Box.Filled = false
    
    espData.Name.Visible = false
    espData.Name.Color = settings.ESP.Color
    espData.Name.Size = 13
    espData.Name.Center = true
    espData.Name.Outline = true
    
    espData.Health.Visible = false
    espData.Health.Color = Color3.fromRGB(0, 255, 0)
    espData.Health.Size = 12
    espData.Health.Center = true
    espData.Health.Outline = true
    
    espData.Distance.Visible = false
    espData.Distance.Color = settings.ESP.Color
    espData.Distance.Size = 12
    espData.Distance.Center = true
    espData.Distance.Outline = true
    
    espCache[player] = espData
    
    if not playerConnections[player] then
        playerConnections[player] = {}
    end
    
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        playerConnections[player].died = humanoid.Died:Connect(function()
            if espCache[player] then
                for _, drawing in pairs(espCache[player]) do
                    drawing.Visible = false
                end
            end
            if hitboxCache[character] then
                hitboxCache[character]:Destroy()
                hitboxCache[character] = nil
            end
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    playerConnections[player].added = player.CharacterAdded:Connect(onCharacterAdded)
end

local function updateESP(player)
    local espData = espCache[player]
    if not espData then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        for _, drawing in pairs(espData) do
            drawing.Visible = false
        end
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        for _, drawing in pairs(espData) do
            drawing.Visible = false
        end
        return
    end
    
    local head = character:FindFirstChild("Head")
    if not head then
        for _, drawing in pairs(espData) do
            drawing.Visible = false
        end
        return
    end
    
    local distance = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        for _, drawing in pairs(espData) do
            drawing.Visible = false
        end
        return
    end
    
    local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        for _, drawing in pairs(espData) do
            drawing.Visible = false
        end
        return
    end
    
    local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local feetPos = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
    
    local height = (headPos.Y - feetPos.Y)
    local width = height * 0.6
    
    if settings.ESP.Boxes then
        espData.Box.Size = Vector2.new(width, height)
        espData.Box.Position = Vector2.new(rootPos.X - width/2, feetPos.Y)
        espData.Box.Visible = settings.ESP.Enabled
        espData.Box.Color = settings.ESP.Color
        espData.Box.Transparency = settings.ESP.Transparency
    else
        espData.Box.Visible = false
    end
    
    if settings.ESP.Names then
        espData.Name.Text = player.Name
        espData.Name.Position = Vector2.new(rootPos.X, feetPos.Y - 15)
        espData.Name.Visible = settings.ESP.Enabled
        espData.Name.Color = settings.ESP.Color
    else
        espData.Name.Visible = false
    end
    
    if settings.ESP.Health then
        local health = math.floor(character.Humanoid.Health)
        local maxHealth = math.floor(character.Humanoid.MaxHealth)
        espData.Health.Text = health.."/"..maxHealth
        espData.Health.Position = Vector2.new(rootPos.X, headPos.Y + 15)
        espData.Health.Visible = settings.ESP.Enabled
        espData.Health.Color = Color3.fromRGB(255 - (255 * (health / maxHealth)), 255 * (health / maxHealth), 0)
    else
        espData.Health.Visible = false
    end
    
    if settings.ESP.Distance then
        espData.Distance.Text = math.floor(distance).."m"
        espData.Distance.Position = Vector2.new(rootPos.X, feetPos.Y + height + 5)
        espData.Distance.Visible = settings.ESP.Enabled
        espData.Distance.Color = settings.ESP.Color
    else
        espData.Distance.Visible = false
    end
end

local function clearESP(player)
    if espCache[player] then
        for _, drawing in pairs(espCache[player]) do
            drawing:Remove()
        end
        espCache[player] = nil
    end
    if playerConnections[player] then
        for _, conn in pairs(playerConnections[player]) do
            conn:Disconnect()
        end
        playerConnections[player] = nil
    end
end

local function updateHitbox(character)
    if not settings.Combat.Hitbox.Enabled then return end
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not hitboxCache[character] then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "HitboxAdornment"
        box.Adornee = hrp
        box.AlwaysOnTop = false
        box.ZIndex = 0
        box.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 2.5, settings.Combat.Hitbox.Size * 1.5)
        box.Transparency = settings.Combat.Hitbox.Transparency
        box.Color3 = settings.Combat.Hitbox.Color
        box.Parent = hrp
        
        hitboxCache[character] = box
        
        hrp:GetPropertyChangedSignal("Size"):Connect(function()
            if hitboxCache[character] then
                hitboxCache[character].Size = Vector3.new(hrp.Size.X * 1.5, hrp.Size.Y * 2.5, hrp.Size.Z * 1.5)
            end
        end)
    end
    
    hrp.Size = Vector3.new(settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size)
    hrp.Transparency = 1
    hrp.CanCollide = false
    
    local box = hitboxCache[character]
    if box then
        box.Size = Vector3.new(hrp.Size.X * 1.5, hrp.Size.Y * 2.5, hrp.Size.Z * 1.5)
        box.Transparency = settings.Combat.Hitbox.Transparency
        box.Color3 = settings.Combat.Hitbox.Color
    end
end

local function clearHitboxes()
    for character, box in pairs(hitboxCache) do
        if character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            character.HumanoidRootPart.Transparency = 1
            character.HumanoidRootPart.CanCollide = true
        end
        box:Destroy()
    end
    hitboxCache = {}
end

local function updateChams(character)
    if not settings.Visual.Chams.Enabled then return end
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then return end
    
    if not chamCache[character] then
        local parts = {}
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ChamAdornment"
                box.Adornee = part
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Size = part.Size
                box.Transparency = settings.Visual.Chams.Transparency
                box.Color3 = settings.Visual.Chams.Color
                box.Parent = part
                table.insert(parts, box)
            end
        end
        chamCache[character] = parts
        
        character.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ChamAdornment"
                box.Adornee = part
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Size = part.Size
                box.Transparency = settings.Visual.Chams.Transparency
                box.Color3 = settings.Visual.Chams.Color
                box.Parent = part
                table.insert(chamCache[character], box)
            end
        end)
    else
        for _, box in pairs(chamCache[character]) do
            if box and box.Parent then
                box.Transparency = settings.Visual.Chams.Transparency
                box.Color3 = settings.Visual.Chams.Color
                box.Visible = settings.Visual.Chams.Enabled
            end
        end
    end
end

local function clearChams()
    for _, boxes in pairs(chamCache) do
        for _, box in pairs(boxes) do
            if box then
                box:Destroy()
            end
        end
    end
    chamCache = {}
end

local function updateAllESP()
    for player, _ in pairs(espCache) do
        updateESP(player)
    end
    
    if settings.Combat.Hitbox.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                updateHitbox(player.Character)
            end
        end
    else
        clearHitboxes()
    end
    
    if settings.Visual.Chams.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                updateChams(player.Character)
            end
        end
    else
        clearChams()
    end
end

local function updateNoClip()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part ~= LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                part.CanCollide = false
            end
        end
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CanCollide = true
        end
    end
end

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1 / #tabs, -5, 1, 0)
    tabButton.Position = UDim2.new((i - 1) / #tabs, 2.5, 0, 0)
    tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(70, 70, 90) or Color3.fromRGB(40, 40, 60)
    tabButton.BackgroundTransparency = 0.2
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    tabButton.TextTransparency = 0.1
    tabButton.TextSize = 12
    tabButton.Font = Enum.Font.GothamBold
    tabButton.Parent = tabContainer

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton

    tabButtons[i] = tabButton

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -10, 1, -60)
    contentFrame.Position = UDim2.new(0, 5, 0, 58)
    contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    contentFrame.BackgroundTransparency = 0.2
    contentFrame.Visible = i == currentTab
    contentFrame.Parent = mainFrame

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 6)
    contentCorner.Parent = contentFrame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 255)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = contentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scrollFrame

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)

    contentFrames[i] = contentFrame
    scrollFrames[i] = scrollFrame

    if tabName == "Combat" then
        createToggle(scrollFrame, "Hitbox Enabled", settings.Combat.Hitbox.Enabled, function(value)
            settings.Combat.Hitbox.Enabled = value
            updateAllESP()
        end)
        
        createSlider(scrollFrame, "Hitbox Size", 1, 10, settings.Combat.Hitbox.Size, function(value)
            settings.Combat.Hitbox.Size = value
            updateAllESP()
        end)
        
        createToggle(scrollFrame, "Auto Stomp", settings.Combat.AutoStomp.Enabled, function(value)
            settings.Combat.AutoStomp.Enabled = value
        end)
        
        createSlider(scrollFrame, "Stomp Range", 5, 30, settings.Combat.AutoStomp.Range, function(value)
            settings.Combat.AutoStomp.Range = value
        end)
    elseif tabName == "ESP" then
        createToggle(scrollFrame, "ESP Enabled", settings.ESP.Enabled, function(value)
            settings.ESP.Enabled = value
            updateAllESP()
        end)
        
        createToggle(scrollFrame, "Boxes", settings.ESP.Boxes, function(value)
            settings.ESP.Boxes = value
            updateAllESP()
        end)
        
        createToggle(scrollFrame, "Names", settings.ESP.Names, function(value)
            settings.ESP.Names = value
            updateAllESP()
        end)
        
        createToggle(scrollFrame, "Health", settings.ESP.Health, function(value)
            settings.ESP.Health = value
            updateAllESP()
        end)
        
        createToggle(scrollFrame, "Distance", settings.ESP.Distance, function(value)
            settings.ESP.Distance = value
            updateAllESP()
        end)
        
        createSlider(scrollFrame, "Max Distance", 50, 500, settings.ESP.MaxDistance, function(value)
            settings.ESP.MaxDistance = value
            updateAllESP()
        end)
    elseif tabName == "Visual" then
        createToggle(scrollFrame, "No Fog", settings.Visual.NoFog, function(value)
            settings.Visual.NoFog = value
            updateVisuals()
        end)
        
        createToggle(scrollFrame, "FullBright", settings.Visual.FullBright, function(value)
            settings.Visual.FullBright = value
            updateVisuals()
        end)
        
        createToggle(scrollFrame, "No Shadows", settings.Visual.NoShadows, function(value)
            settings.Visual.NoShadows = value
            if value then
                disableShadows()
            else
                Lighting.GlobalShadows = true
            end
        end)
        
        createToggle(scrollFrame, "Chams", settings.Visual.Chams.Enabled, function(value)
            settings.Visual.Chams.Enabled = value
            updateAllESP()
        end)
        
        createSlider(scrollFrame, "Cham Transparency", 0, 1, settings.Visual.Chams.Transparency, function(value)
            settings.Visual.Chams.Transparency = value
            updateAllESP()
        end)
        
        createToggle(scrollFrame, "View Bob", settings.Visual.ViewBob.Enabled, function(value)
            settings.Visual.ViewBob.Enabled = value
        end)
        
        createSlider(scrollFrame, "Bob Intensity", 1, 10, settings.Visual.ViewBob.Intensity, function(value)
            settings.Visual.ViewBob.Intensity = value
        end)
    end

    tabButton.MouseButton1Click:Connect(function()
        currentTab = i
        for j, frame in ipairs(contentFrames) do
            frame.Visible = j == i
        end
        for j, btn in ipairs(tabButtons) do
            local tween = TweenService:Create(btn, tweenInfo, {
                BackgroundColor3 = j == currentTab and Color3.fromRGB(70, 70, 90) or Color3.fromRGB(40, 40, 60)
            })
            tween:Play()
        end
    end)
end

local function toggleMenu()
    isMinimized = not isMinimized
    local targetSize = isMinimized and minimizedSize or UDim2.new(0, menuWidth, 0, menuHeight)
    local targetPosition = isMinimized and minimizedPosition or defaultPosition
    
    local sizeTween = TweenService:Create(mainFrame, tweenInfo, {Size = targetSize})
    local posTween = TweenService:Create(mainFrame, tweenInfo, {Position = targetPosition})
    
    sizeTween:Play()
    posTween:Play()
    
    tabContainer.Visible = not isMinimized
    for _, frame in ipairs(contentFrames) do
        frame.Visible = not isMinimized and frame == contentFrames[currentTab]
    end
    
    dragArea.TextSize = isMinimized and 12 or 14
end

dragArea.MouseButton1Click:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        isVisible = not isVisible
        screenGui.Enabled = isVisible
        if isVisible then
            updateAllESP()
            updateVisuals()
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    clearESP(player)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    updateNoClip()
    character:WaitForChild("Humanoid").Died:Connect(updateNoClip)
end)

if LocalPlayer.Character then
    updateNoClip()
end

Lighting:SetAttribute("OriginalFogEnd", Lighting.FogEnd)
updateVisuals()

connections.RenderStep = RunService.RenderStepped:Connect(function()
    if isVisible then
        for player, _ in pairs(espCache) do
            if player ~= LocalPlayer then
                updateESP(player)
            end
        end
        
        if settings.Combat.Hitbox.Enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    updateHitbox(player.Character)
                end
            end
        else
            clearHitboxes()
        end
        
        if settings.Visual.Chams.Enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    updateChams(player.Character)
                end
            end
        else
            clearChams()
        end
        
        if settings.Visual.ViewBob.Enabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                local intensity = settings.Visual.ViewBob.Intensity / 100
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(
                    math.sin(tick() * 5) * intensity,
                    math.abs(math.sin(tick() * 10)) * intensity,
                    0
                )
            end
        end
        
        if settings.Combat.AutoStomp.Enabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        
                        if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            if distance <= settings.Combat.AutoStomp.Range then
                                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    updateNoClip()
end)

game:BindToClose(function()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    for player, _ in pairs(playerConnections) do
        clearESP(player)
    end
    for _, espData in pairs(espCache) do
        for _, drawing in pairs(espData) do
            drawing:Remove()
        end
    end
    clearHitboxes()
    clearChams()
    screenGui:Destroy()
end)