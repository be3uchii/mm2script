local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 300, 180
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Config"}
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local minimizedSize = UDim2.new(0, 90, 0, 25)
local minimizedPosition = UDim2.new(0.5, -45, 0.01, 0)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)
local keyFileName = "silence_key.dat"
local configFolder = "SilenceConfig"
local configFile = "settings.cfg"
local backupFolder = "SilenceBackups"
local cacheFolder = "SilenceCache"

setfpscap(1000)

local colors = {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(220, 220, 220),
    Color3.fromRGB(200, 50, 50),
    Color3.fromRGB(50, 200, 50),
    Color3.fromRGB(50, 100, 200),
    Color3.fromRGB(200, 200, 50)
}

local transparencies = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9}

local defaultSettings = {
    PlayerInfo = {
        UserId = LocalPlayer.UserId,
        Name = LocalPlayer.Name,
        LastLogin = os.time()
    },
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 4,
            Color = colors[1],
            Transparency = 0.7,
            Type = "Box"
        }
    },
    ESP = {
        Enabled = false,
        ShowDistance = false,
        MaxDistance = 200
    },
    Tracers = {
        Enabled = false
    },
    Configs = {},
    System = {
        PerformanceMode = true,
        SafeMode = false,
        DebugMode = false
    }
}

local settings = table.clone(defaultSettings)
local espCache = {}
local hitboxCache = {}
local connections = {}
local tabButtons = {}
local contentFrames = {}
local scrollFrames = {}
local playerConnections = {}
local configButtons = {}
local uiElements = {}
local soundCache = {}
local startTime = os.time()
local elapsedTime = 0
local timerActive = true
local maxAttempts = 5
local remainingAttempts = maxAttempts
local attemptCooldown = 30
local lastAttemptTime = 0
local cooldownActive = false
local tracers = {}
local tracerConnections = {}
local backupInterval = 300
local lastBackupTime = 0
local debugMode = false
local errorCount = 0
local maxErrors = 50
local initialized = false
local safeMode = false
local performanceMode = false
local cleanupQueue = {}
local cleanupInterval = 10
local lastCleanupTime = 0
local keyValidationAttempts = 0
local maxKeyAttempts = 3

local function ensureFolderStructure()
    local folders = {configFolder, backupFolder, cacheFolder}
    for _, folder in ipairs(folders) do
        if not isfolder(folder) then
            makefolder(folder)
        end
    end
end

local function validateKey(key)
    if key == nil or type(key) ~= "string" then return false end
    if #key ~= 36 then return false end
    
    local pattern = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"
    if not string.match(key, pattern) then return false end
    
    return true
end

local function loadKey()
    if isfile(keyFileName) then
        local success, loadedKey = pcall(function()
            return readfile(keyFileName)
        end)
        
        if success and validateKey(loadedKey) then
            return loadedKey
        end
    end
    return nil
end

local function saveKey(key)
    if validateKey(key) then
        pcall(function()
            writefile(keyFileName, key)
        end)
        return true
    end
    return false
end

local function requestKey()
    local key = loadKey()
    if key then return key end
    
    local input = ""
    local attempts = 0
    
    while attempts < maxKeyAttempts do
        input = getclipboard() or ""
        
        if validateKey(input) then
            if saveKey(input) then
                return input
            end
        end
        
        attempts += 1
        task.wait(1)
    end
    
    return nil
end

local function validateAccess()
    local key = requestKey()
    if not key then
        error("Access validation failed")
    end
    return true
end

local function createNotification(title, message, duration)
    duration = duration or 5
    
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "Notification"
    notificationFrame.Size = UDim2.new(0, 300, 0, 80)
    notificationFrame.Position = UDim2.new(1, -320, 1, -100)
    notificationFrame.AnchorPoint = Vector2.new(0, 1)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.ZIndex = 100
    notificationFrame.Parent = PlayerGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = notificationFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 101
    titleLabel.Parent = notificationFrame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 1, -40)
    messageLabel.Position = UDim2.new(0, 10, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.Text = message
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.ZIndex = 101
    messageLabel.Parent = notificationFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundTransparency = 1
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 12
    closeButton.ZIndex = 101
    closeButton.Parent = notificationFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 2
    stroke.Parent = notificationFrame
    
    local tweenIn = TweenService:Create(notificationFrame, tweenInfo, {Position = UDim2.new(1, -320, 1, -100)})
    local tweenOut = TweenService:Create(notificationFrame, tweenInfo, {Position = UDim2.new(1, 320, 1, -100)})
    
    tweenIn:Play()
    
    closeButton.MouseButton1Click:Connect(function()
        tweenOut:Play()
        tweenOut.Completed:Wait()
        notificationFrame:Destroy()
    end)
    
    task.delay(duration, function()
        if notificationFrame.Parent then
            tweenOut:Play()
            tweenOut.Completed:Wait()
            notificationFrame:Destroy()
        end
    end)
end

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilenceUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    uiElements.ScreenGui = screenGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    mainFrame.Position = defaultPosition
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    uiElements.MainFrame = mainFrame
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(40, 40, 40)
    mainStroke.Thickness = 2
    mainStroke.Parent = mainFrame
    
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.Size = UDim2.new(1, 0, 0, 25)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = headerFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0, 100, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Text = "SILENCE"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = headerFrame
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 20, 0, 20)
    minimizeButton.Position = UDim2.new(1, -25, 0.5, -10)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    minimizeButton.Text = "_"
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 14
    minimizeButton.Parent = headerFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -50, 0.5, -10)
    closeButton.BackgroundTransparency = 1
    closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 12
    closeButton.Parent = headerFrame
    
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "Tabs"
    tabsFrame.Size = UDim2.new(1, -20, 0, 25)
    tabsFrame.Position = UDim2.new(0, 10, 0, 30)
    tabsFrame.BackgroundTransparency = 1
    tabsFrame.Parent = mainFrame
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -65)
    contentFrame.Position = UDim2.new(0, 10, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Tab"
        tabButton.Size = UDim2.new(0, 80, 1, 0)
        tabButton.Position = UDim2.new(0, (i-1)*85, 0, 0)
        tabButton.BackgroundColor3 = i == 1 and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(20, 20, 20)
        tabButton.BorderSizePixel = 0
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.Text = tabName
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 11
        tabButton.Parent = tabsFrame
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 4)
        tabCorner.Parent = tabButton
        
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 3
        tabContent.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
        tabContent.Visible = i == 1
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Parent = contentFrame
        
        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.Padding = UDim.new(0, 5)
        uiListLayout.Parent = tabContent
        
        tabButtons[i] = tabButton
        contentFrames[i] = tabContent
        scrollFrames[i] = tabContent
        
        tabButton.MouseButton1Click:Connect(function()
            currentTab = i
            for j, frame in ipairs(contentFrames) do
                frame.Visible = j == i
            end
            for j, button in ipairs(tabButtons) do
                button.BackgroundColor3 = j == i and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(20, 20, 20)
            end
        end)
    end
    
    local function createButton(parent, text, callback)
        local button = Instance.new("TextButton")
        button.Name = text .. "Button"
        button.Size = UDim2.new(1, 0, 0, 25)
        button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        button.BorderSizePixel = 0
        button.TextColor3 = Color3.fromRGB(200, 200, 200)
        button.Text = text
        button.Font = Enum.Font.Gotham
        button.TextSize = 11
        button.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = button
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(50, 50, 50)
        stroke.Thickness = 1
        stroke.Parent = button
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
        end)
        
        button.MouseButton1Click:Connect(callback)
        
        return button
    end
    
    local function createToggle(parent, text, defaultValue, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = text .. "Toggle"
        toggleFrame.Size = UDim2.new(1, 0, 0, 20)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = parent
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "Toggle"
        toggleButton.Size = UDim2.new(0, 40, 0, 20)
        toggleButton.Position = UDim2.new(1, -40, 0, 0)
        toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(50, 50, 50)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = ""
        toggleButton.Parent = toggleFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 10)
        toggleCorner.Parent = toggleButton
        
        local toggleDot = Instance.new("Frame")
        toggleDot.Name = "Dot"
        toggleDot.Size = UDim2.new(0, 16, 0, 16)
        toggleDot.Position = UDim2.new(0, defaultValue and 22 or 2, 0, 2)
        toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleDot.BorderSizePixel = 0
        toggleDot.Parent = toggleButton
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(0, 8)
        dotCorner.Parent = toggleDot
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Text = text
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        toggleButton.MouseButton1Click:Connect(function()
            defaultValue = not defaultValue
            TweenService:Create(toggleDot, tweenInfo, {Position = UDim2.new(0, defaultValue and 22 or 2, 0, 2)}):Play()
            TweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = defaultValue and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(50, 50, 50)}):Play()
            callback(defaultValue)
        end)
        
        return toggleFrame
    end
    
    local function createSlider(parent, text, minValue, maxValue, defaultValue, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = text .. "Slider"
        sliderFrame.Size = UDim2.new(1, 0, 0, 40)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 0, 15)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Text = text .. ": " .. defaultValue
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame
        
        local track = Instance.new("Frame")
        track.Name = "Track"
        track.Size = UDim2.new(1, 0, 0, 5)
        track.Position = UDim2.new(0, 0, 0, 20)
        track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        track.BorderSizePixel = 0
        track.Parent = sliderFrame
        
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(0, 2)
        trackCorner.Parent = track
        
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
        fill.Position = UDim2.new(0, 0, 0, 0)
        fill.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
        fill.BorderSizePixel = 0
        fill.Parent = track
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 2)
        fillCorner.Parent = fill
        
        local handle = Instance.new("Frame")
        handle.Name = "Handle"
        handle.Size = UDim2.new(0, 12, 0, 12)
        handle.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -6, 0.5, -6)
        handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        handle.BorderSizePixel = 0
        handle.Parent = track
        
        local handleCorner = Instance.new("UICorner")
        handleCorner.CornerRadius = UDim.new(0, 6)
        handleCorner.Parent = handle
        
        local dragging = false
        
        local function updateValue(value)
            value = math.clamp(value, minValue, maxValue)
            local ratio = (value - minValue) / (maxValue - minValue)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            handle.Position = UDim2.new(ratio, -6, 0.5, -6)
            label.Text = text .. ": " .. string.format("%.1f", value)
            callback(value)
        end
        
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        handle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                local trackPos = track.AbsolutePosition
                local trackSize = track.AbsoluteSize
                local relativeX = (mousePos.X - trackPos.X) / trackSize.X
                local value = minValue + relativeX * (maxValue - minValue)
                updateValue(value)
                dragging = true
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local trackPos = track.AbsolutePosition
                local trackSize = track.AbsoluteSize
                local relativeX = math.clamp((mousePos.X - trackPos.X) / trackSize.X, 0, 1)
                local value = minValue + relativeX * (maxValue - minValue)
                updateValue(value)
            end
        end)
        
        return sliderFrame
    end
    
    local function createColorPicker(parent, text, defaultColor, callback)
        local pickerFrame = Instance.new("Frame")
        pickerFrame.Name = text .. "Picker"
        pickerFrame.Size = UDim2.new(1, 0, 0, 30)
        pickerFrame.BackgroundTransparency = 1
        pickerFrame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Text = text
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = pickerFrame
        
        local colorBox = Instance.new("Frame")
        colorBox.Name = "ColorBox"
        colorBox.Size = UDim2.new(0, 40, 0, 20)
        colorBox.Position = UDim2.new(1, -40, 0.5, -10)
        colorBox.BackgroundColor3 = defaultColor
        colorBox.BorderSizePixel = 0
        colorBox.Parent = pickerFrame
        
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 4)
        boxCorner.Parent = colorBox
        
        local boxStroke = Instance.new("UIStroke")
        boxStroke.Color = Color3.fromRGB(100, 100, 100)
        boxStroke.Thickness = 1
        boxStroke.Parent = colorBox
        
        colorBox.MouseButton1Click:Connect(function()
            local colorPicker = Instance.new("Frame")
            colorPicker.Name = "ColorPicker"
            colorPicker.Size = UDim2.new(0, 200, 0, 150)
            colorPicker.Position = UDim2.new(0.5, -100, 0.5, -75)
            colorPicker.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            colorPicker.BorderSizePixel = 0
            colorPicker.ZIndex = 100
            colorPicker.Parent = screenGui
            
            local pickerCorner = Instance.new("UICorner")
            pickerCorner.CornerRadius = UDim.new(0, 8)
            pickerCorner.Parent = colorPicker
            
            local pickerStroke = Instance.new("UIStroke")
            pickerStroke.Color = Color3.fromRGB(50, 50, 50)
            pickerStroke.Thickness = 2
            pickerStroke.Parent = colorPicker
            
            local hueSlider = createSlider(colorPicker, "Hue", 0, 360, 0, function(value)
            end)
            hueSlider.Position = UDim2.new(0, 10, 0, 10)
            hueSlider.Size = UDim2.new(1, -20, 0, 40)
            
            local closeButton = Instance.new("TextButton")
            closeButton.Name = "CloseButton"
            closeButton.Size = UDim2.new(0, 20, 0, 20)
            closeButton.Position = UDim2.new(1, -25, 0, 5)
            closeButton.BackgroundTransparency = 1
            closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            closeButton.Text = "X"
            closeButton.Font = Enum.Font.GothamBold
            closeButton.TextSize = 12
            closeButton.ZIndex = 101
            closeButton.Parent = colorPicker
            
            closeButton.MouseButton1Click:Connect(function()
                colorPicker:Destroy()
            end)
        end)
        
        return pickerFrame
    end
    
    local combatContent = contentFrames[1]
    
    local hitboxToggle = createToggle(combatContent, "Hitbox", settings.Combat.Hitbox.Enabled, function(value)
        settings.Combat.Hitbox.Enabled = value
        updateHitboxes()
    end)
    
    local hitboxSizeSlider = createSlider(combatContent, "Hitbox Size", 1, 10, settings.Combat.Hitbox.Size, function(value)
        settings.Combat.Hitbox.Size = value
        updateHitboxes()
    end)
    
    local espContent = contentFrames[2]
    
    local espToggle = createToggle(espContent, "ESP", settings.ESP.Enabled, function(value)
        settings.ESP.Enabled = value
        updateESP()
    end)
    
    local distanceToggle = createToggle(espContent, "Show Distance", settings.ESP.ShowDistance, function(value)
        settings.ESP.ShowDistance = value
        updateESP()
    end)
    
    local maxDistanceSlider = createSlider(espContent, "Max Distance", 50, 500, settings.ESP.MaxDistance, function(value)
        settings.ESP.MaxDistance = value
        updateESP()
    end)
    
    local tracersToggle = createToggle(espContent, "Tracers", settings.Tracers.Enabled, function(value)
        settings.Tracers.Enabled = value
        updateTracers()
    end)
    
    local configContent = contentFrames[3]
    
    local saveButton = createButton(configContent, "Save Config", function()
        saveConfig()
    end)
    
    local loadButton = createButton(configContent, "Load Config", function()
        loadConfig()
    end)
    
    local resetButton = createButton(configContent, "Reset Config", function()
        resetConfig()
    end)
    
    local performanceToggle = createToggle(configContent, "Performance Mode", settings.System.PerformanceMode, function(value)
        settings.System.PerformanceMode = value
        performanceMode = value
    end)
    
    local safeToggle = createToggle(configContent, "Safe Mode", settings.System.SafeMode, function(value)
        settings.System.SafeMode = value
        safeMode = value
    end)
    
    local debugToggle = createToggle(configContent, "Debug Mode", settings.System.DebugMode, function(value)
        settings.System.DebugMode = value
        debugMode = value
    end)
    
    local configList = Instance.new("ScrollingFrame")
    configList.Name = "ConfigList"
    configList.Size = UDim2.new(1, 0, 0, 100)
    configList.Position = UDim2.new(0, 0, 0, 120)
    configList.BackgroundTransparency = 1
    configList.ScrollBarThickness = 3
    configList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    configList.Parent = configContent
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = configList
    
    local function refreshConfigList()
        for _, button in ipairs(configButtons) do
            button:Destroy()
        end
        configButtons = {}
        
        if isfolder(configFolder) then
            local files = listfiles(configFolder)
            for _, file in ipairs(files) do
                if string.match(file, "%.cfg$") then
                    local fileName = string.match(file, "([^\\/]+)%.cfg$")
                    local button = createButton(configList, fileName, function()
                        loadConfig(fileName .. ".cfg")
                    end)
                    table.insert(configButtons, button)
                end
            end
        end
    end
    
    refreshConfigList()
    
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(mainFrame, tweenInfo, {Size = minimizedSize, Position = minimizedPosition}):Play()
            minimizeButton.Text = "+"
        else
            TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, menuWidth, 0, menuHeight), Position = defaultPosition}):Play()
            minimizeButton.Text = "_"
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        isVisible = false
        local tweenOut = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.01, 0)})
        tweenOut:Play()
        tweenOut.Completed:Wait()
        screenGui:Destroy()
    end)
    
    headerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local dragStart = input.Position
            local frameStart = mainFrame.Position
            
            local connection
            connection = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = moveInput.Position - dragStart
                    mainFrame.Position = UDim2.new(0, frameStart.X.Offset + delta.X, 0, frameStart.Y.Offset + delta.Y)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    return screenGui
end

local function updateESP()
    for player, parts in pairs(espCache) do
        for _, part in ipairs(parts) do
            part:Destroy()
        end
    end
    espCache = {}
    
    if not settings.ESP.Enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
                    and (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 0
                
                if distance <= settings.ESP.MaxDistance then
                    local espParts = {}
                    
                    for _, partName in ipairs({"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}) do
                        local part = character:FindFirstChild(partName)
                        if part then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ESP"
                            highlight.Adornee = part
                            highlight.FillColor = Color3.fromRGB(255, 50, 50)
                            highlight.FillTransparency = 0.7
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.OutlineTransparency = 0
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.Parent = part
                            
                            table.insert(espParts, highlight)
                        end
                    end
                    
                    if settings.ESP.ShowDistance then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "Distance"
                        billboard.Size = UDim2.new(0, 100, 0, 30)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Adornee = rootPart
                        billboard.Parent = rootPart
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.Text = string.format("%.1f studs", distance)
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 12
                        label.Parent = billboard
                        
                        table.insert(espParts, billboard)
                    end
                    
                    espCache[player] = espParts
                end
            end
        end
    end
end

local function updateHitboxes()
    for player, hitbox in pairs(hitboxCache) do
        hitbox:Destroy()
    end
    hitboxCache = {}
    
    if not settings.Combat.Hitbox.Enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local hitbox = Instance.new("Part")
                hitbox.Name = "Hitbox"
                hitbox.Size = Vector3.new(settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size)
                hitbox.CFrame = rootPart.CFrame
                hitbox.Anchored = true
                hitbox.CanCollide = false
                hitbox.Transparency = settings.Combat.Hitbox.Transparency
                hitbox.Color = settings.Combat.Hitbox.Color
                hitbox.Material = Enum.Material.ForceField
                hitbox.Parent = workspace
                
                hitboxCache[player] = hitbox
                
                local weld = Instance.new("Weld")
                weld.Part0 = rootPart
                weld.Part1 = hitbox
                weld.C0 = CFrame.new()
                weld.Parent = hitbox
            end
        end
    end
end

local function updateTracers()
    for _, tracer in pairs(tracers) do
        tracer:Destroy()
    end
    tracers = {}
    
    for _, connection in pairs(tracerConnections) do
        connection:Disconnect()
    end
    tracerConnections = {}
    
    if not settings.Tracers.Enabled then return end
    
    local tracerFrame = Instance.new("Frame")
    tracerFrame.Name = "Tracers"
    tracerFrame.Size = UDim2.new(1, 0, 1, 0)
    tracerFrame.Position = UDim2.new(0, 0, 0, 0)
    tracerFrame.BackgroundTransparency = 1
    tracerFrame.Parent = uiElements.ScreenGui
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local line = Instance.new("Frame")
                line.Name = player.Name .. "Tracer"
                line.Size = UDim2.new(0, 2, 0, 100)
                line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                line.BorderSizePixel = 0
                line.AnchorPoint = Vector2.new(0.5, 1)
                line.Parent = tracerFrame
                
                local connection = RunService.RenderStepped:Connect(function()
                    if rootPart and rootPart.Parent then
                        local screenPos, visible = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
                        if visible then
                            line.Visible = true
                            line.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                            
                            local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
                                and (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 0
                            
                            local length = math.clamp(distance * 0.5, 50, 200)
                            line.Size = UDim2.new(0, 2, 0, length)
                            
                            local angle = math.atan2(screenPos.Y - viewportSize.Y/2, screenPos.X - viewportSize.X/2)
                            line.Rotation = math.deg(angle) + 90
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end)
                
                tracers[player] = line
                table.insert(tracerConnections, connection)
            end
        end
    end
end

local function saveConfig(filename)
    filename = filename or configFile
    local filePath = configFolder .. "/" .. filename
    
    local success, message = pcall(function()
        local data = HttpService:JSONEncode(settings)
        writefile(filePath, data)
    end)
    
    if success then
        createNotification("Success", "Config saved: " .. filename, 3)
        refreshConfigList()
    else
        createNotification("Error", "Failed to save config: " .. message, 5)
    end
end

local function loadConfig(filename)
    filename = filename or configFile
    local filePath = configFolder .. "/" .. filename
    
    if not isfile(filePath) then
        createNotification("Error", "Config file not found: " .. filename, 5)
        return
    end
    
    local success, message = pcall(function()
        local data = readfile(filePath)
        local loaded = HttpService:JSONDecode(data)
        
        for category, categorySettings in pairs(loaded) do
            if settings[category] then
                for key, value in pairs(categorySettings) do
                    if settings[category][key] ~= nil then
                        settings[category][key] = value
                    end
                end
            end
        end
        
        updateHitboxes()
        updateESP()
        updateTracers()
    end)
    
    if success then
        createNotification("Success", "Config loaded: " .. filename, 3)
    else
        createNotification("Error", "Failed to load config: " .. message, 5)
    end
end

local function resetConfig()
    settings = table.clone(defaultSettings)
    updateHitboxes()
    updateESP()
    updateTracers()
    createNotification("Success", "Config reset to defaults", 3)
end

local function cleanup()
    for _, item in ipairs(cleanupQueue) do
        if item and item.Parent then
            item:Destroy()
        end
    end
    cleanupQueue = {}
end

local function initialize()
    if initialized then return end
    
    ensureFolderStructure()
    
    if not validateAccess() then
        error("Access validation failed")
    end
    
    createUI()
    
    Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        updateESP()
        updateHitboxes()
        updateTracers()
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if espCache[player] then
            for _, part in ipairs(espCache[player]) do
                part:Destroy()
            end
            espCache[player] = nil
        end
        
        if hitboxCache[player] then
            hitboxCache[player]:Destroy()
            hitboxCache[player] = nil
        end
        
        if tracers[player] then
            tracers[player]:Destroy()
            tracers[player] = nil
        end
    end)
    
    RunService.Heartbeat:Connect(function(deltaTime)
        elapsedTime += deltaTime
        
        if timerActive then
            if os.time() - lastBackupTime >= backupInterval then
                local backupName = "backup_" .. os.date("%Y%m%d_%H%M%S") .. ".cfg"
                saveConfig(backupName)
                lastBackupTime = os.time()
            end
            
            if os.time() - lastCleanupTime >= cleanupInterval then
                cleanup()
                lastCleanupTime = os.time()
            end
        end
    end)
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(1)
        updateESP()
        updateHitboxes()
        updateTracers()
    end)
    
    initialized = true
    createNotification("Silence", "Initialized successfully", 3)
end

local function safeShutdown()
    timerActive = false
    
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    
    for _, connection in ipairs(playerConnections) do
        connection:Disconnect()
    end
    
    for _, connection in ipairs(tracerConnections) do
        connection:Disconnect()
    end
    
    for player, parts in pairs(espCache) do
        for _, part in ipairs(parts) do
            pcall(function() part:Destroy() end)
        end
    end
    
    for player, hitbox in pairs(hitboxCache) do
        pcall(function() hitbox:Destroy() end)
    end
    
    for player, tracer in pairs(tracers) do
        pcall(function() tracer:Destroy() end)
    end
    
    if uiElements.ScreenGui and uiElements.ScreenGui.Parent then
        uiElements.ScreenGui:Destroy()
    end
    
    cleanup()
end

local function errorHandler(err)
    errorCount += 1
    if debugMode then
        createNotification("Error", err, 5)
    end
    
    if errorCount >= maxErrors then
        safeShutdown()
        error("Too many errors, shutting down")
    end
end

xpcall(initialize, errorHandler)