local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 270, 160
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP"}
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local minimizedSize = UDim2.new(0, 80, 0, 25)
local minimizedPosition = UDim2.new(0.5, -40, 0, 10)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)

local configFolder = "SilenceConfig"
local configFile = "settings.json"

local colors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(255, 0, 255),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(255, 128, 0),
    Color3.fromRGB(255, 0, 128),
    Color3.fromRGB(128, 0, 255),
    Color3.fromRGB(0, 255, 128),
    Color3.fromRGB(128, 255, 0),
    Color3.fromRGB(255, 128, 128),
    Color3.fromRGB(128, 255, 128),
    Color3.fromRGB(128, 128, 255),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(0, 0, 0),
    Color3.fromRGB(64, 64, 64),
    Color3.fromRGB(128, 128, 128),
    Color3.fromRGB(192, 192, 192),
    Color3.fromRGB(255, 64, 64),
    Color3.fromRGB(64, 255, 64),
    Color3.fromRGB(64, 64, 255),
    Color3.fromRGB(255, 128, 64),
    Color3.fromRGB(255, 64, 128),
    Color3.fromRGB(128, 64, 255),
    Color3.fromRGB(64, 255, 128),
    Color3.fromRGB(128, 255, 64),
    Color3.fromRGB(255, 192, 128),
    Color3.fromRGB(255, 128, 192),
    Color3.fromRGB(192, 128, 255)
}

local transparencies = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9}

local settings = {
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 4,
            Color = colors[1],
            Transparency = 0.7,
            Type = "Box",
            ThroughWalls = false
        }
    },
    ESP = {
        Enabled = false,
        ShowDistance = false,
        MaxDistance = 160
    }
}

local function saveSettings()
    if not isfolder(configFolder) then
        makefolder(configFolder)
    end
    writefile(configFolder.."/"..configFile, HttpService:JSONEncode(settings))
end

local function loadSettings()
    if isfolder(configFolder) and isfile(configFolder.."/"..configFile) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(configFolder.."/"..configFile))
        end)
        if success and result then
            for category, data in pairs(result) do
                if settings[category] then
                    for key, value in pairs(data) do
                        if settings[category][key] ~= nil then
                            settings[category][key] = value
                        end
                    end
                end
            end
        end
    end
end

loadSettings()

local espCache = {}
local hitboxCache = {}
local connections = {}
local tabButtons = {}
local contentFrames = {}
local scrollFrames = {}
local playerConnections = {}

if PlayerGui:FindFirstChild("SilenceGui") then
    PlayerGui.SilenceGui:Destroy()
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
screenGui.Name = "SilenceGui"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Enabled = isVisible

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
mainFrame.Position = defaultPosition
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(60, 60, 255)
uiStroke.Thickness = 2
uiStroke.Transparency = 0.1
uiStroke.Parent = mainFrame

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, 0, 0, 24)
dragArea.BackgroundTransparency = 1
dragArea.Text = "Silence 4.7"
dragArea.TextColor3 = Color3.fromRGB(230, 230, 230)
dragArea.TextTransparency = 0.1
dragArea.TextSize = isMinimized and 12 or 14
dragArea.Font = Enum.Font.GothamBold
dragArea.TextXAlignment = Enum.TextXAlignment.Center
dragArea.Parent = mainFrame

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 24)
tabContainer.Position = UDim2.new(0, 0, 0, 24)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local function createToggle(parent, text, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -8, 0, 20)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Position = UDim2.new(0, 4, 0, 0)
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.3, 0, 0.9, 0)
    toggle.Position = UDim2.new(0.7, 0, 0.05, 0)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 230, 0) or Color3.fromRGB(230, 0, 0)
    toggle.Text = defaultValue and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 10
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = toggleFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        toggle.Text = defaultValue and "ON" or "OFF"
        toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 230, 0) or Color3.fromRGB(230, 0, 0)
        callback(defaultValue)
        saveSettings()
    end)
    
    return toggleFrame
end

local function createValueChanger(parent, text, values, defaultValueIndex, callback)
    local changerFrame = Instance.new("Frame")
    changerFrame.Size = UDim2.new(1, -8, 0, 20)
    changerFrame.BackgroundTransparency = 1
    changerFrame.Position = UDim2.new(0, 4, 0, 0)
    changerFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
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
    valueLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    valueLabel.TextTransparency = 0.1
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = changerFrame
    
    local prevButton = Instance.new("TextButton")
    prevButton.Size = UDim2.new(0.1, 0, 0.9, 0)
    prevButton.Position = UDim2.new(0.7, 0, 0.05, 0)
    prevButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    prevButton.Text = "<"
    prevButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    prevButton.TextSize = 10
    prevButton.Font = Enum.Font.GothamBold
    prevButton.Parent = changerFrame
    
    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.new(0.1, 0, 0.9, 0)
    nextButton.Position = UDim2.new(0.85, 0, 0.05, 0)
    nextButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    nextButton.Text = ">"
    nextButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    nextButton.TextSize = 10
    nextButton.Font = Enum.Font.GothamBold
    nextButton.Parent = changerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = prevButton
    corner:Clone().Parent = nextButton
    
    local currentIndex = defaultValueIndex
    
    local function updateValue()
        valueLabel.Text = tostring(values[currentIndex])
        callback(values[currentIndex])
        saveSettings()
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

local function createColorButton(parent, text, defaultColor, callback)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, -8, 0, 20)
    colorFrame.BackgroundTransparency = 1
    colorFrame.Position = UDim2.new(0, 4, 0, 0)
    colorFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextTransparency = 0.1
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorFrame
    
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0.3, 0, 0.9, 0)
    colorButton.Position = UDim2.new(0.7, 0, 0.05, 0)
    colorButton.BackgroundColor3 = defaultColor
    colorButton.Text = ""
    colorButton.Parent = colorFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = colorButton
    
    colorButton.MouseButton1Click:Connect(function()
        local currentIndex = 1
        for i, color in ipairs(colors) do
            if color == defaultColor then
                currentIndex = i
                break
            end
        end
        
        currentIndex = currentIndex % #colors + 1
        defaultColor = colors[currentIndex]
        colorButton.BackgroundColor3 = defaultColor
        callback(defaultColor)
        saveSettings()
    end)
    
    return colorFrame
end

local function createESP(player)
    if espCache[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Thickness = 2
    box.Filled = false
    box.ZIndex = 1
    
    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Color = Color3.new(1, 1, 1)
    distanceText.Size = 14
    distanceText.ZIndex = 1
    
    espCache[player] = {
        box = box,
        distanceText = distanceText
    }
    
    if not playerConnections[player] then
        playerConnections[player] = {}
    end
    
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        playerConnections[player].died = humanoid.Died:Connect(function()
            if espCache[player] then
                espCache[player].box.Visible = false
                espCache[player].distanceText.Visible = false
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
    
    playerConnections[player].characterAdded = player.CharacterAdded:Connect(onCharacterAdded)
end

local function updateESP(player)
    local espData = espCache[player]
    if not espData then return end
    
    local box = espData.box
    local distanceText = espData.distanceText
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        box.Visible = false
        distanceText.Visible = false
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        box.Visible = false
        distanceText.Visible = false
        return
    end
    
    local head = character:FindFirstChild("Head")
    if not head then
        box.Visible = false
        distanceText.Visible = false
        return
    end
    
    local distance = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        box.Visible = false
        distanceText.Visible = false
        return
    end
    
    local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        box.Visible = false
        distanceText.Visible = false
        return
    end
    
    local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local feetPos = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
    
    local height = (headPos.Y - feetPos.Y)
    local width = height * 0.6
    
    box.Size = Vector2.new(width, height)
    box.Position = Vector2.new(rootPos.X - width/2, feetPos.Y)
    box.Visible = settings.ESP.Enabled
    
    if settings.ESP.ShowDistance then
        distanceText.Text = tostring(math.floor(distance)) .. "m"
        distanceText.Position = Vector2.new(rootPos.X, headPos.Y - 20)
        distanceText.Visible = settings.ESP.Enabled
    else
        distanceText.Visible = false
    end
end

local function clearESP(player)
    if espCache[player] then
        espCache[player].box:Remove()
        espCache[player].distanceText:Remove()
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
    
    local distance = (hrp.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        if hitboxCache[character] then
            hitboxCache[character]:Destroy()
            hitboxCache[character] = nil
        end
        return
    end
    
    if not hitboxCache[character] then
        local box
        if settings.Combat.Hitbox.Type == "Sphere" then
            box = Instance.new("SphereHandleAdornment")
            box.Radius = settings.Combat.Hitbox.Size * 1.2
        else
            box = Instance.new("BoxHandleAdornment")
            box.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
        end
        
        box.Name = "HitboxAdornment"
        box.Adornee = hrp
        box.AlwaysOnTop = settings.Combat.Hitbox.ThroughWalls
        box.ZIndex = 0
        box.Transparency = settings.Combat.Hitbox.Transparency
        box.Color3 = settings.Combat.Hitbox.Color
        box.Parent = hrp
        
        hitboxCache[character] = box
    end
    
    if settings.Combat.Hitbox.Type == "Sphere" then
        hrp.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.2, settings.Combat.Hitbox.Size * 1.2, settings.Combat.Hitbox.Size * 1.2)
    else
        hrp.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
    end
    
    hrp.Transparency = 1
    hrp.CanCollide = false
    
    local box = hitboxCache[character]
    if box then
        if settings.Combat.Hitbox.Type == "Sphere" then
            box.Radius = settings.Combat.Hitbox.Size * 1.2
        else
            box.Size = Vector3.new(settings.Combat.Hitbox.Size * 1.5, settings.Combat.Hitbox.Size * 1.8, settings.Combat.Hitbox.Size * 1.5)
        end
        box.Transparency = settings.Combat.Hitbox.Transparency
        box.Color3 = settings.Combat.Hitbox.Color
        box.AlwaysOnTop = settings.Combat.Hitbox.ThroughWalls
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
    tabButton.Size = UDim2.new(1 / #tabs, -4, 1, -4)
    tabButton.Position = UDim2.new((i - 1) / #tabs, 2, 0, 2)
    tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
    tabButton.BackgroundTransparency = 0.1
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    tabButton.TextTransparency = 0.1
    tabButton.TextSize = 12
    tabButton.Font = Enum.Font.GothamBold
    tabButton.Parent = tabContainer

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton

    tabButtons[i] = tabButton

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -8, 1, -56)
    contentFrame.Position = UDim2.new(0, 4, 0, 56)
    contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    contentFrame.BackgroundTransparency = 0.1
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
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 255)
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
        createToggle(scrollFrame, "Hitbox Enabled", settings.Combat.Hitbox.Enabled, function(value)
            settings.Combat.Hitbox.Enabled = value
            updateAllESP()
        end)
        
        local sizeValues = {}
        for i = 1, 8 do table.insert(sizeValues, i) end
        
        createValueChanger(scrollFrame, "Hitbox Size", sizeValues, settings.Combat.Hitbox.Size, function(value)
            settings.Combat.Hitbox.Size = value
            updateAllESP()
        end)
        
        createToggle(scrollFrame, "Sphere Hitbox", settings.Combat.Hitbox.Type == "Sphere", function(value)
            settings.Combat.Hitbox.Type = value and "Sphere" or "Box"
            clearHitboxes()
            updateAllESP()
        end)
        
        createToggle(scrollFrame, "Through Walls", settings.Combat.Hitbox.ThroughWalls, function(value)
            settings.Combat.Hitbox.ThroughWalls = value
            updateAllESP()
        end)
        
        createColorButton(scrollFrame, "Hitbox Color", settings.Combat.Hitbox.Color, function(value)
            settings.Combat.Hitbox.Color = value
            updateAllESP()
        end)
        
        createValueChanger(scrollFrame, "Hitbox Transparency", transparencies, table.find(transparencies, settings.Combat.Hitbox.Transparency) or 7, function(value)
            settings.Combat.Hitbox.Transparency = value
            updateAllESP()
        end)
    elseif tabName == "ESP" then
        createToggle(scrollFrame, "ESP Enabled", settings.ESP.Enabled, function(value)
            settings.ESP.Enabled = value
            updateAllESP()
        end)
        
        createToggle(scrollFrame, "Show Distance", settings.ESP.ShowDistance, function(value)
            settings.ESP.ShowDistance = value
            updateAllESP()
        end)
    end

    tabButton.MouseButton1Click:Connect(function()
        currentTab = i
        for j, frame in ipairs(contentFrames) do
            frame.Visible = j == i
        end
        for j, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = j == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
        end
    end)
end

local function tweenFrame(frame, size, position)
    local sizeTween = TweenService:Create(frame, tweenInfo, {Size = size})
    local positionTween = TweenService:Create(frame, tweenInfo, {Position = position})
    sizeTween:Play()
    positionTween:Play()
end

dragArea.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and minimizedSize or UDim2.new(0, menuWidth, 0, menuHeight)
    local targetPosition = isMinimized and minimizedPosition or defaultPosition
    tweenFrame(mainFrame, targetSize, targetPosition)
    tabContainer.Visible = not isMinimized
    for _, frame in ipairs(contentFrames) do
        frame.Visible = not isMinimized and frame == contentFrames[currentTab]
    end
    dragArea.TextSize = isMinimized and 12 or 14
end)

local dragging = false
local dragStart, frameStart

dragArea.MouseButton1Down:Connect(function()
    dragging = true
    dragStart = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    frameStart = mainFrame.Position
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - dragStart
        mainFrame.Position = UDim2.new(0, frameStart.X.Offset + delta.X, 0, frameStart.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
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
    end
end)

game:BindToClose(function()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    for player, _ in pairs(playerConnections) do
        clearESP(player)
    end
    for _, espData in pairs(espCache) do
        espData.box:Remove()
        espData.distanceText:Remove()
    end
    clearHitboxes()
    screenGui:Destroy()
end)
