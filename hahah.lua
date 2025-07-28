local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 300, 180
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Информация"}
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local minimizedSize = UDim2.new(0, 80, 0, 30)
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
        Aimbot = {
            Enabled = false,
            Smoothness = 0.1,
            FOV = 100,
            TargetPart = "Head"
        },
        NoClip = {
            Enabled = false
        }
    },
    ESP = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.7,
        MaxDistance = 150,
        Chams = {
            Enabled = false,
            Color = Color3.fromRGB(0, 255, 0),
            Transparency = 0.3
        },
        XRay = {
            Enabled = false,
            WallTransparency = 0.8
        },
        Distance = {
            Enabled = false,
            Color = Color3.fromRGB(200, 200, 200),
            TextSize = 10
        },
        Health = {
            Enabled = false,
            Color = Color3.fromRGB(0, 255, 0),
            TextSize = 10
        }
    }
}

local espCache = {}
local hitboxCache = {}
local chamsCache = {}
local connections = {}
local tabButtons = {}
local contentFrames = {}
local scrollFrames = {}
local playerConnections = {}

if PlayerGui:FindFirstChild("TestMenuGui") then
    PlayerGui.TestMenuGui:Destroy()
end

local function disableShadows()
    Lighting.GlobalShadows = false
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CastShadow = false
        end
    end
end

disableShadows()
game:GetService("Workspace").DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") then
        obj.CastShadow = false
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TestMenuGui"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Enabled = isVisible

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
mainFrame.Position = defaultPosition
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(80, 80, 255)
uiStroke.Thickness = 1.5
uiStroke.Transparency = 0.2
uiStroke.Parent = mainFrame

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 60))
}
uiGradient.Rotation = 45
uiGradient.Parent = mainFrame

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, 0, 0, 25)
dragArea.BackgroundTransparency = 1
dragArea.Text = "Silence 4.0"
dragArea.TextColor3 = Color3.fromRGB(220, 220, 255)
dragArea.TextTransparency = 0.1
dragArea.TextSize = isMinimized and 12 or 14
dragArea.Font = Enum.Font.GothamBlack
dragArea.TextXAlignment = Enum.TextXAlignment.Center
dragArea.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 25)
tabContainer.Position = UDim2.new(0, 0, 0, 25)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local function createToggle(parent, text, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 20)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Position = UDim2.new(0, 5, 0, 0)
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.35, 0, 0.8, 0)
    toggle.Position = UDim2.new(0.65, 0, 0.1, 0)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 220, 0) or Color3.fromRGB(220, 0, 0)
    toggle.Text = defaultValue and "ВКЛ" or "ВЫКЛ"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 10
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = toggleFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = toggle
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    stroke.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        toggle.Text = defaultValue and "ВКЛ" or "ВЫКЛ"
        toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 220, 0) or Color3.fromRGB(220, 0, 0)
        callback(defaultValue)
    end)
    
    return toggleFrame
end

local function createValueChanger(parent, text, values, defaultValueIndex, callback)
    local changerFrame = Instance.new("Frame")
    changerFrame.Size = UDim2.new(1, -10, 0, 20)
    changerFrame.BackgroundTransparency = 1
    changerFrame.Position = UDim2.new(0, 5, 0, 0)
    changerFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = changerFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(values[defaultValueIndex])
    valueLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    valueLabel.TextTransparency = 0.1
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = changerFrame
    
    local prevButton = Instance.new("TextButton")
    prevButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    prevButton.Position = UDim2.new(0.75, 0, 0.1, 0)
    prevButton.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    prevButton.Text = "<"
    prevButton.TextColor3 = Color3.fromRGB(220, 220, 255)
    prevButton.TextSize = 10
    prevButton.Font = Enum.Font.GothamBold
    prevButton.Parent = changerFrame
    
    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    nextButton.Position = UDim2.new(0.85, 0, 0.1, 0)
    nextButton.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    nextButton.Text = ">"
    nextButton.TextColor3 = Color3.fromRGB(220, 220, 255)
    nextButton.TextSize = 10
    nextButton.Font = Enum.Font.GothamBold
    nextButton.Parent = changerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = prevButton
    corner:Clone().Parent = nextButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    stroke.Parent = prevButton
    stroke:Clone().Parent = nextButton
    
    local currentIndex = defaultValueIndex
    
    local function updateValue()
        valueLabel.Text = tostring(values[currentIndex])
        callback(values[currentIndex])
    end
    
    prevButton.MouseButton1Click:Connect(function()
        currentIndex = currentIndex > 1 and currentIndex - 1 or #values
        updateValue()
    end)
    
    nextButton.MouseButton1Click:Connect(function()
        currentIndex = currentIndex < #values and currentIndex + 1 or 1
        updateValue()
    end)
    
    return changerFrame
end

local function createColorPicker(parent, text, defaultColor, callback)
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(1, -10, 0, 20)
    pickerFrame.BackgroundTransparency = 1
    pickerFrame.Position = UDim2.new(0, 5, 0, 0)
    pickerFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = pickerFrame
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0.35, 0, 0.8, 0)
    colorButton.Position = UDim2.new(0.65, 0, 0.1, 0)
    colorButton.BackgroundColor3 = defaultColor
    colorButton.Text = ""
    colorButton.Parent = pickerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = colorButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    stroke.Parent = colorButton
    
    colorButton.MouseButton1Click:Connect(function()
        local colors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 255, 255)
        }
        local currentIndex = 1
        for i, color in ipairs(colors) do
            if color == defaultColor then
                currentIndex = i
                break
            end
        end
        currentIndex = currentIndex % #colors + 1
        colorButton.BackgroundColor3 = colors[currentIndex]
        callback(colors[currentIndex])
    end)
    
    return pickerFrame
end

local function createESP(player)
    if espCache[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = settings.ESP.Color
    box.Thickness = 1
    box.Transparency = settings.ESP.Transparency
    box.Filled = false
    box.ZIndex = 1
    espCache[player] = box
    
    local distanceLabel = Drawing.new("Text")
    distanceLabel.Visible = false
    distanceLabel.Color = settings.ESP.Distance.Color
    distanceLabel.Size = settings.ESP.Distance.TextSize
    distanceLabel.Transparency = settings.ESP.Transparency
    distanceLabel.Text = ""
    distanceLabel.ZIndex = 2
    if not espCache[player].Labels then espCache[player].Labels = {} end
    espCache[player].Labels.Distance = distanceLabel
    
    local healthLabel = Drawing.new("Text")
    healthLabel.Visible = false
    healthLabel.Color = settings.ESP.Health.Color
    healthLabel.Size = settings.ESP.Health.TextSize
    healthLabel.Transparency = settings.ESP.Transparency
    healthLabel.Text = ""
    healthLabel.ZIndex = 2
    espCache[player].Labels.Health = healthLabel
    
    if not playerConnections[player] then
        playerConnections[player] = {}
    end
    
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        playerConnections[player].died = humanoid.Died:Connect(function()
            if espCache[player] then
                espCache[player].Visible = false
                for _, label in pairs(espCache[player].Labels) do
                    label.Visible = false
                end
            end
            if hitboxCache[character] then
                hitboxCache[character]:Destroy()
                hitboxCache[character] = nil
            end
            if chamsCache[character] then
                chamsCache[character]:Destroy()
                chamsCache[character] = nil
            end
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    playerConnections[player].added = player.CharacterAdded:Connect(onCharacterAdded)
end

local function updateChams(character)
    if not settings.ESP.Chams.Enabled then return end
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then return end
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and not chamsCache[part] then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = part
            highlight.FillColor = settings.ESP.Chams.Color
            highlight.FillTransparency = settings.ESP.Chams.Transparency
            highlight.OutlineColor = settings.ESP.Chams.Color
            highlight.OutlineTransparency = 0
            highlight.Parent = part
            chamsCache[part] = highlight
        end
    end
end

local function clearChams()
    for _, highlight in pairs(chamsCache) do
        highlight:Destroy()
    end
    chamsCache = {}
end

local function updateXRay()
    if not settings.ESP.XRay.Enabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and obj:IsDescendantOf(player.Character) then
                        continue
                    end
                    obj.Transparency = 0
                end
            end
        end
        return
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            local isPlayerPart = false
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and obj:IsDescendantOf(player.Character) then
                    isPlayerPart = true
                    break
                end
            end
            if not isPlayerPart then
                obj.Transparency = settings.ESP.XRay.WallTransparency
            end
        end
    end
end

local function updateESP(player)
    local box = espCache[player]
    if not box then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        box.Visible = false
        for _, label in pairs(box.Labels) do
            label.Visible = false
        end
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        box.Visible = false
        for _, label in pairs(box.Labels) do
            label.Visible = false
        end
        return
    end
    
    local head = character:FindFirstChild("Head")
    if not head then
        box.Visible = false
        for _, label in pairs(box.Labels) do
            label.Visible = false
        end
        return
    end
    
    local distance = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        box.Visible = false
        for _, label in pairs(box.Labels) do
            label.Visible = false
        end
        return
    end
    
    local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        box.Visible = false
        for _, label in pairs(box.Labels) do
            label.Visible = false
        end
        return
    end
    
    local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local feetPos = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
    
    local height = (headPos.Y - feetPos.Y)
    local width = height * 0.6
    
    box.Size = Vector2.new(width, height)
    box.Position = Vector2.new(rootPos.X - width/2, feetPos.Y)
    box.Visible = settings.ESP.Enabled
    
    local distanceLabel = box.Labels.Distance
    distanceLabel.Text = math.floor(distance) .. " studs"
    distanceLabel.Position = Vector2.new(rootPos.X, feetPos.Y - 15)
    distanceLabel.Visible = settings.ESP.Distance.Enabled and settings.ESP.Enabled
    
    local healthLabel = box.Labels.Health
    local humanoid = character:FindFirstChild("Humanoid")
    healthLabel.Text = math.floor(humanoid.Health) .. "/" .. humanoid.MaxHealth
    healthLabel.Position = Vector2.new(rootPos.X, feetPos.Y + height + 5)
    healthLabel.Visible = settings.ESP.Health.Enabled and settings.ESP.Enabled
    
    updateChams(character)
end

local function clearESP(player)
    if espCache[player] then
        espCache[player]:Remove()
        for _, label in pairs(espCache[player].Labels) do
            label:Remove()
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

local function updateAimbot()
    if not settings.Combat.Aimbot.Enabled then return end
    
    local closestPlayer = nil
    local closestDistance = settings.Combat.Aimbot.FOV
    local camera = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPart = player.Character:FindFirstChild(settings.Combat.Aimbot.TargetPart)
            if targetPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    if closestPlayer and closestPlayer.Character then
        local targetPart = closestPlayer.Character:FindFirstChild(settings.Combat.Aimbot.TargetPart)
        if targetPart then
            local targetPos = camera:WorldToViewportPoint(targetPart.Position)
            local currentPos = mousePos
            local newPos = currentPos + (Vector2.new(targetPos.X, targetPos.Y) - currentPos) * settings.Combat.Aimbot.Smoothness
            mousemoverel((newPos - currentPos).X, (newPos - currentPos).Y)
        end
    end
end

local function updateNoClip()
    if not settings.Combat.NoClip.Enabled then
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        return
    end
    
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
    
    if settings.ESP.Chams.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                updateChams(player.Character)
            end
        end
    else
        clearChams()
    end
    
    updateXRay()
end

for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1 / #tabs, -4, 1, -4)
    tabButton.Position = UDim2.new((i - 1) / #tabs, 2, 0, 2)
    tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(80, 80, 100) or Color3.fromRGB(45, 45, 60)
    tabButton.BackgroundTransparency = 0.1
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(220, 220, 255)
    tabButton.TextTransparency = 0.1
    tabButton.TextSize = 12
    tabButton.Font = Enum.Font.GothamBlack
    tabButton.Parent = tabContainer

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabButton

    local tabStroke = Instance.new("UIStroke")
    tabStroke.Color = Color3.fromRGB(80, 80, 255)
    tabStroke.Thickness = 1
    tabStroke.Transparency = 0.2
    tabStroke.Parent = tabButton

    tabButtons[i] = tabButton

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -10, 1, -60)
    contentFrame.Position = UDim2.new(0, 5, 0, 55)
    contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    contentFrame.BackgroundTransparency = 0.1
    contentFrame.Visible = i == currentTab
    contentFrame.Parent = mainFrame

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentFrame

    local contentStroke = Instance.new("UIStroke")
    contentStroke.Color = Color3.fromRGB(80, 80, 255)
    contentStroke.Thickness = 1
    contentStroke.Transparency = 0.2
    contentStroke.Parent = contentFrame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 255)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = contentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.Parent = scrollFrame

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)

    contentFrames[i] = contentFrame
    scrollFrames[i] = scrollFrame

    if tabName == "Combat" then
        createToggle(scrollFrame, "Hitbox Включен", settings.Combat.Hitbox.Enabled, function(value)
            settings.Combat.Hitbox.Enabled = value
            updateAllESP()
        end)
        createValueChanger(scrollFrame, "Размер Hitbox", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, settings.Combat.Hitbox.Size, function(value)
            settings.Combat.Hitbox.Size = value
            updateAllESP()
        end)
        createColorPicker(scrollFrame, "Цвет Hitbox", settings.Combat.Hitbox.Color, function(value)
            settings.Combat.Hitbox.Color = value
            updateAllESP()
        end)
        createValueChanger(scrollFrame, "Прозрачность Hitbox", {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1}, settings.Combat.Hitbox.Transparency, function(value)
            settings.Combat.Hitbox.Transparency = value
            updateAllESP()
        end)
        createToggle(scrollFrame, "Aimbot Включен", settings.Combat.Aimbot.Enabled, function(value)
            settings.Combat.Aimbot.Enabled = value
        end)
        createValueChanger(scrollFrame, "Плавность Aimbot", {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1}, settings.Combat.Aimbot.Smoothness, function(value)
            settings.Combat.Aimbot.Smoothness = value
        end)
        createValueChanger(scrollFrame, "FOV Aimbot", {50, 75, 100, 125, 150, 175, 200}, settings.Combat.Aimbot.FOV, function(value)
            settings.Combat.Aimbot.FOV = value
        end)
        createValueChanger(scrollFrame, "Цель Aimbot", {"Head", "Torso"}, settings.Combat.Aimbot.TargetPart == "Head" and 1 or 2, function(value)
            settings.Combat.Aimbot.TargetPart = value
        end)
        createToggle(scrollFrame, "NoClip Включен", settings.Combat.NoClip.Enabled, function(value)
            settings.Combat.NoClip.Enabled = value
            updateNoClip()
        end)
    elseif tabName == "ESP" then
        createToggle(scrollFrame, "ESP Включен", settings.ESP.Enabled, function(value)
            settings.ESP.Enabled = value
            updateAllESP()
        end)
        createColorPicker(scrollFrame, "Цвет ESP", settings.ESP.Color, function(value)
            settings.ESP.Color = value
            for _, box in pairs(espCache) do
                box.Color = value
            end
        end)
        createValueChanger(scrollFrame, "Прозрачность ESP", {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1}, settings.ESP.Transparency, function(value)
            settings.ESP.Transparency = value
            for _, box in pairs(espCache) do
                box.Transparency = value
                for _, label in pairs(box.Labels) do
                    label.Transparency = value
                end
            end
        end)
        createValueChanger(scrollFrame, "Макс. Дистанция", {50, 100, 150, 200, 300, 500, 1000}, settings.ESP.MaxDistance, function(value)
            settings.ESP.MaxDistance = value
            updateAllESP()
        end)
        createToggle(scrollFrame, "Chams Включен", settings.ESP.Chams.Enabled, function(value)
            settings.ESP.Chams.Enabled = value
            updateAllESP()
        end)
        createColorPicker(scrollFrame, "Цвет Chams", settings.ESP.Chams.Color, function(value)
            settings.ESP.Chams.Color = value
            updateAllESP()
        end)
        createValueChanger(scrollFrame, "Прозрачность Chams", {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1}, settings.ESP.Chams.Transparency, function(value)
            settings.ESP.Chams.Transparency = value
            updateAllESP()
        end)
        createToggle(scrollFrame, "X-Ray Включен", settings.ESP.XRay.Enabled, function(value)
            settings.ESP.XRay.Enabled = value
            updateAllESP()
        end)
        createValueChanger(scrollFrame, "Прозрачность Стен", {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1}, settings.ESP.XRay.WallTransparency, function(value)
            settings.ESP.XRay.WallTransparency = value
            updateAllESP()
        end)
        createToggle(scrollFrame, "Дистанция Включена", settings.ESP.Distance.Enabled, function(value)
            settings.ESP.Distance.Enabled = value
            updateAllESP()
        end)
        createColorPicker(scrollFrame, "Цвет Дистанции", settings.ESP.Distance.Color, function(value)
            settings.ESP.Distance.Color = value
            for _, box in pairs(espCache) do
                box.Labels.Distance.Color = value
            end
        end)
        createValueChanger(scrollFrame, "Размер Текста Дистанции", {8, 10, 12, 14, 16}, settings.ESP.Distance.TextSize, function(value)
            settings.ESP.Distance.TextSize = value
            for _, box in pairs(espCache) do
                box.Labels.Distance.Size = value
            end
        end)
        createToggle(scrollFrame, "Здоровье Включено", settings.ESP.Health.Enabled, function(value)
            settings.ESP.Health.Enabled = value
            updateAllESP()
        end)
        createColorPicker(scrollFrame, "Цвет Здоровья", settings.ESP.Health.Color, function(value)
            settings.ESP.Health.Color = value
            for _, box in pairs(espCache) do
                box.Labels.Health.Color = value
            end
        end)
        createValueChanger(scrollFrame, "Размер Текста Здоровья", {8, 10, 12, 14, 16}, settings.ESP.Health.TextSize, function(value)
            settings.ESP.Health.TextSize = value
            for _, box in pairs(espCache) do
                box.Labels.Health.Size = value
            end
        end)
    elseif tabName == "Информация" then
        local infoText = Instance.new("TextLabel")
        infoText.Size = UDim2.new(1, -10, 1, 0)
        infoText.Position = UDim2.new(0, 5, 0, 5)
        infoText.BackgroundTransparency = 1
        infoText.Text = [[
# Silence 4.0 - Руководство

## Вкладка Combat
- **Hitbox**: Увеличивает хитбоксы врагов для облегчения попаданий. Настройки: включение, размер, цвет, прозрачность.
- **Aimbot**: Автоматически наводит прицел на врагов. Настройки: включение, плавность, поле обзора (FOV), цель (голова/торс).
- **NoClip**: Позволяет проходить сквозь стены и объекты. Настройка: включение.

## Вкладка ESP
- **ESP**: Отображает рамки вокруг игроков. Настройки: включение, цвет, прозрачность, максимальная дистанция.
- **Chams**: Подсвечивает игроков через стены. Настройки: включение, цвет, прозрачность.
- **X-Ray**: Делает стены и объекты прозрачными, игроки остаются видимыми. Настройки: включение, прозрачность стен.
- **Distance**: Показывает расстояние до игроков. Настройки: включение, цвет, размер текста.
- **Health**: Отображает здоровье игроков. Настройки: включение, цвет, размер текста.

## Управление
- **Insert**: Показать/скрыть меню.
- **Клик по заголовку**: Свернуть/развернуть меню.
]]
        infoText.TextColor3 = Color3.fromRGB(220, 220, 255)
        infoText.TextTransparency = 0.1
        infoText.TextSize = 12
        infoText.Font = Enum.Font.Gotham
        infoText.TextXAlignment = Enum.TextXAlignment.Left
        infoText.TextYAlignment = Enum.TextYAlignment.Top
        infoText.RichText = true
        infoText.Parent = scrollFrame

        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, infoText.TextBounds.Y + 10)
    end

    tabButton.MouseButton1Click:Connect(function()
        currentTab = i
        for j, frame in ipairs(contentFrames) do
            frame.Visible = j == i
        end
        for j, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = j == currentTab and Color3.fromRGB(80, 80, 100) or Color3.fromRGB(45, 45, 60)
        end
    end)
end

dragArea.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and minimizedSize or UDim2.new(0, menuWidth, 0, menuHeight)
    local targetPosition = isMinimized and minimizedPosition or defaultPosition
    local tween = TweenService:Create(mainFrame, tweenInfo, {Size = targetSize, Position = targetPosition})
    tween:Play()
    tabContainer.Visible = not isMinimized
    for _, frame in ipairs(contentFrames) do
        frame.Visible = not isMinimized and frame == contentFrames[currentTab]
    end
    dragArea.TextSize = isMinimized and 12 or 14
end)

local dragging, dragInput, dragStart, startPos
dragArea.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

dragArea.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        isVisible = not isVisible
        screenGui.Enabled = isVisible
        if isVisible then
            updateAllESP()
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
    disableShadows()
    character:WaitForChild("Humanoid").Died:Connect(function()
        disableShadows()
    end)
end)

if LocalPlayer.Character then
    updateNoClip()
    disableShadows()
end

setfpscap(1000)

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
        
        updateAimbot()
        updateNoClip()
    end
end)

game:BindToClose(function()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    for player, _ in pairs(playerConnections) do
        clearESP(player)
    end
    for _, box in pairs(espCache) do
        box:Remove()
        for _, label in pairs(box.Labels) do
            label:Remove()
        end
    end
    clearHitboxes()
    clearChams()
    screenGui:Destroy()
end)