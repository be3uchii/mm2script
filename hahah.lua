local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 300, 200
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP"}
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local minimizedSize = UDim2.new(0, 85, 0, 28)
local minimizedPosition = UDim2.new(0.5, -42.5, 0, 10)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)

local settings = {
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 4,
            Color = Color3.fromRGB(255, 50, 50),
            Transparency = 0.7,
            Type = "Box",
            ThroughWalls = false
        }
    },
    ESP = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.7,
        MaxDistance = 150
    }
}

local configFolder = "SilenceConfig"
local configFile = "settings.json"

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
dragArea.Text = "Silence 4.3"
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
    toggleFrame.Size = UDim2.new(1, -8, 0, 24)
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
    toggle.Size = UDim2.new(0.3, 0, 0.8, 0)
    toggle.Position = UDim2.new(0.7, 0, 0.1, 0)
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

local function createSlider(parent, text, min, max, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -8, 0, 24)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Position = UDim2.new(0, 4, 0, 0)
    sliderFrame.Parent = parent
    
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
    label.Parent = sliderFrame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.3, 0, 0.2, 0)
    slider.Position = UDim2.new(0.7, 0, 0.4, 0)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    slider.Parent = sliderFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0.5, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(60, 60, 255)
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0.5, 0)
    fillCorner.Parent = fill
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0.3, 0, 0.6, 0)
    valueText.Position = UDim2.new(0.7, 0, 0.7, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(defaultValue)
    valueText.TextColor3 = Color3.fromRGB(230, 230, 230)
    valueText.TextSize = 10
    valueText.Font = Enum.Font.GothamBold
    valueText.TextXAlignment = Enum.TextXAlignment.Center
    valueText.Parent = sliderFrame
    
    local dragging = false
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    slider.MouseMoved:Connect(function()
        if dragging then
            local mouseX = UserInputService:GetMouseLocation().X
            local sliderAbsolutePos = slider.AbsolutePosition.X
            local sliderAbsoluteSize = slider.AbsoluteSize.X
            
            local relativeX = math.clamp(mouseX - sliderAbsolutePos, 0, sliderAbsoluteSize)
            local percent = relativeX / sliderAbsoluteSize
            local value = math.floor(min + (max - min) * percent + 0.5)
            
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valueText.Text = tostring(value)
            callback(value)
            saveSettings()
        end
    end)
    
    return sliderFrame
end

local function createColorPicker(parent, text, defaultColor, callback)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, -8, 0, 24)
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
    
    local colorPreview = Instance.new("TextButton")
    colorPreview.Size = UDim2.new(0.3, 0, 0.8, 0)
    colorPreview.Position = UDim2.new(0.7, 0, 0.1, 0)
    colorPreview.BackgroundColor3 = defaultColor
    colorPreview.Text = ""
    colorPreview.Parent = colorFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = colorPreview
    
    colorPreview.MouseButton1Click:Connect(function()
        local colorPicker = Instance.new("Frame")
        colorPicker.Size = UDim2.new(0, 200, 0, 150)
        colorPicker.Position = UDim2.new(0.5, -100, 0.5, -75)
        colorPicker.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        colorPicker.Parent = screenGui
        
        local hueSlider = Instance.new("Frame")
        hueSlider.Size = UDim2.new(0, 20, 0, 120)
        hueSlider.Position = UDim2.new(0, 10, 0, 10)
        hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
        hueSlider.Parent = colorPicker
        
        local saturationValue = Instance.new("Frame")
        saturationValue.Size = UDim2.new(0, 120, 0, 120)
        saturationValue.Position = UDim2.new(0, 40, 0, 10)
        saturationValue.BackgroundColor3 = defaultColor
        saturationValue.Parent = colorPicker
        
        local currentColor = defaultColor
        local h, s, v = currentColor:ToHSV()
        
        local function updateColor()
            currentColor = Color3.fromHSV(h, s, v)
            saturationValue.BackgroundColor3 = currentColor
            colorPreview.BackgroundColor3 = currentColor
            callback(currentColor)
            saveSettings()
        end
        
        hueSlider.MouseButton1Down:Connect(function()
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mouseY = UserInputService:GetMouseLocation().Y
                local relativeY = math.clamp(mouseY - hueSlider.AbsolutePosition.Y, 0, hueSlider.AbsoluteSize.Y)
                h = 1 - (relativeY / hueSlider.AbsoluteSize.Y)
                updateColor()
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                end
            end)
        end)
        
        saturationValue.MouseButton1Down:Connect(function()
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mouseX = UserInputService:GetMouseLocation().X
                local mouseY = UserInputService:GetMouseLocation().Y
                local relativeX = math.clamp(mouseX - saturationValue.AbsolutePosition.X, 0, saturationValue.AbsoluteSize.X)
                local relativeY = math.clamp(mouseY - saturationValue.AbsolutePosition.Y, 0, saturationValue.AbsoluteSize.Y)
                s = relativeX / saturationValue.AbsoluteSize.X
                v = 1 - (relativeY / saturationValue.AbsoluteSize.Y)
                updateColor()
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                end
            end)
        end)
        
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 60, 0, 20)
        closeButton.Position = UDim2.new(0.5, -30, 0, 135)
        closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        closeButton.Text = "Close"
        closeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
        closeButton.TextSize = 12
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Parent = colorPicker
        
        closeButton.MouseButton1Click:Connect(function()
            colorPicker:Destroy()
        end)
    end)
    
    return colorFrame
end

local function createESP(player)
    if espCache[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = settings.ESP.Color
    box.Thickness = 2
    box.Transparency = settings.ESP.Transparency
    box.Filled = false
    box.ZIndex = 1
    espCache[player] = box
    
    if not playerConnections[player] then
        playerConnections[player] = {}
    end
    
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        playerConnections[player].died = humanoid.Died:Connect(function()
            if espCache[player] then
                espCache[player].Visible = false
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
    local box = espCache[player]
    if not box then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        box.Visible = false
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        box.Visible = false
        return
    end
    
    local head = character:FindFirstChild("Head")
    if not head then
        box.Visible = false
        return
    end
    
    local distance = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    if distance > settings.ESP.MaxDistance then
        box.Visible = false
        return
    end
    
    local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        box.Visible = false
        return
    end
    
    local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local feetPos = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
    
    local height = (headPos.Y - feetPos.Y)
    local width = height * 0.6
    
    box.Size = Vector2.new(width, height)
    box.Position = Vector2.new(rootPos.X - width/2, feetPos.Y)
    box.Visible = settings.ESP.Enabled
    box.Color = settings.ESP.Color
    box.Transparency = settings.ESP.Transparency
end

local function clearESP(player)
    if espCache[player] then
        espCache[player]:Remove()
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
    if distance > 150 then
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
    contentFrame.Position = UDim2.new(0, 4, 0, 52)
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
        
        createSlider(scrollFrame, "Hitbox Size", 1, 8, settings.Combat.Hitbox.Size, function(value)
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
        
        createColorPicker(scrollFrame, "Hitbox Color", settings.Combat.Hitbox.Color, function(color)
            settings.Combat.Hitbox.Color = color
            updateAllESP()
        end)
        
        createSlider(scrollFrame, "Hitbox Transparency", 0, 1, settings.Combat.Hitbox.Transparency, function(value)
            settings.Combat.Hitbox.Transparency = value
            updateAllESP()
        end)
    elseif tabName == "ESP" then
        createToggle(scrollFrame, "ESP Enabled", settings.ESP.Enabled, function(value)
            settings.ESP.Enabled = value
            updateAllESP()
        end)
        
        createSlider(scrollFrame, "Max Distance", 50, 500, settings.ESP.MaxDistance, function(value)
            settings.ESP.MaxDistance = value
            updateAllESP()
        end)
        
        createColorPicker(scrollFrame, "ESP Color", settings.ESP.Color, function(color)
            settings.ESP.Color = color
            updateAllESP()
        end)
        
        createSlider(scrollFrame, "ESP Transparency", 0, 1, settings.ESP.Transparency, function(value)
            settings.ESP.Transparency = value
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
    for _, box in pairs(espCache) do
        box:Remove()
    end
    clearHitboxes()
    screenGui:Destroy()
end)