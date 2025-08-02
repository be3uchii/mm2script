local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local viewportSize = workspace.CurrentCamera.ViewportSize
local menuWidth, menuHeight = 270, 160
local menuX, menuY = (viewportSize.X - menuWidth) / 2, (viewportSize.Y - menuHeight) / 2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "ESP", "Config", "Misc"}
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local minimizedSize = UDim2.new(0, 80, 0, 20)
local minimizedPosition = UDim2.new(0.5, -40, 0.01, 0)
local defaultPosition = UDim2.new(0, menuX, 0, menuY)

setfpscap(900)

local configFolder = "SilenceConfig"
local configFile = "settings.txt"

local colors = {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(0, 0, 0),
    Color3.fromRGB(255, 0, 0)
}

local themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 30),
        Foreground = Color3.fromRGB(40, 40, 50),
        Text = Color3.fromRGB(230, 230, 230),
        Accent = Color3.fromRGB(60, 60, 255)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Foreground = Color3.fromRGB(220, 220, 230),
        Text = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(80, 120, 255)
    }
}

local transparencies = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9}
local fonts = {"Gotham", "Arial", "SourceSans", "Oswald"}
local fontSizes = {10, 12, 14, 16, 18}

local defaultSettings = {
    PlayerInfo = {
        UserId = LocalPlayer.UserId,
        Name = LocalPlayer.Name
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
        MaxDistance = 160
    },
    Configs = {},
    Misc = {
        Theme = "Dark",
        Transparency = 0.1,
        Font = "Gotham",
        FontSize = 12,
        Animations = false,
        GlowEffects = false,
        Particles = false,
        Parallax = false,
        HoverEffects = false,
        TabTransitions = false
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
local particles = {}
local currentTheme = themes[settings.Misc.Theme]
local mainFrame, screenGui
local glowEffects = {}
local hoverConnections = {}

local function playSound()
    if not soundCache.clickSound then
        soundCache.clickSound = Instance.new("Sound")
        soundCache.clickSound.SoundId = "rbxassetid://6895079853"
        soundCache.clickSound.Volume = 0.25
        soundCache.clickSound.Parent = workspace
    end
    soundCache.clickSound:Play()
end

local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = deepCopy(v)
        elseif typeof(v) == "Color3" then
            v = {r = v.R, g = v.G, b = v.B}
        end
        copy[k] = v
    end
    return copy
end

local function restoreColor(data)
    if type(data) == "table" and data.r and data.g and data.b then
        return Color3.new(data.r, data.g, data.b)
    end
    return data
end

local function ensureConfigFolder()
    if not isfolder(configFolder) then
        makefolder(configFolder)
    end
end

local function saveSettings()
    ensureConfigFolder()
    local tempPath = configFolder.."/temp_"..configFile
    local finalPath = configFolder.."/"..configFile
    
    local serializedSettings = {Configs = settings.Configs, PlayerInfo = settings.PlayerInfo, Misc = settings.Misc}
    writefile(tempPath, HttpService:JSONEncode(serializedSettings))
    if isfile(finalPath) then
        delfile(finalPath)
    end
    writefile(finalPath, readfile(tempPath))
    delfile(tempPath)
end

local function loadSettings()
    ensureConfigFolder()
    local path = configFolder.."/"..configFile
    
    if isfile(path) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        
        if success and result then
            if result.Configs then settings.Configs = result.Configs end
            if result.Misc then
                settings.Misc.Theme = result.Misc.Theme or "Dark"
                settings.Misc.Transparency = result.Misc.Transparency or 0.1
                settings.Misc.Font = result.Misc.Font or "Gotham"
                settings.Misc.FontSize = result.Misc.FontSize or 12
                settings.Misc.Animations = result.Misc.Animations or false
                settings.Misc.GlowEffects = result.Misc.GlowEffects or false
                settings.Misc.Particles = result.Misc.Particles or false
                settings.Misc.Parallax = result.Misc.Parallax or false
                settings.Misc.HoverEffects = result.Misc.HoverEffects or false
                settings.Misc.TabTransitions = result.Misc.TabTransitions or false
            end
        end
    end
end

local function applyTheme()
    currentTheme = themes[settings.Misc.Theme]
    if mainFrame then
        mainFrame.BackgroundColor3 = currentTheme.Background
        mainFrame.BackgroundTransparency = settings.Misc.Transparency
        
        for _, frame in ipairs(contentFrames) do
            frame.BackgroundColor3 = currentTheme.Foreground
        end
        
        for _, button in ipairs(tabButtons) do
            button.BackgroundColor3 = currentTheme.Foreground
        end
        
        if glowEffects.main then
            glowEffects.main.ImageColor3 = currentTheme.Accent
        end
    end
end

local function createParticles()
    if not settings.Misc.Particles or not mainFrame then return end
    
    for _, particle in ipairs(particles) do
        particle:Destroy()
    end
    particles = {}
    
    local particleCount = 10
    for i = 1, particleCount do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
        particle.Position = UDim2.new(0, math.random(0, menuWidth), 0, math.random(0, menuHeight))
        particle.BackgroundColor3 = currentTheme.Accent
        particle.BackgroundTransparency = 0.7
        particle.BorderSizePixel = 0
        particle.ZIndex = -1
        particle.Parent = mainFrame
        
        local speed = math.random(5, 15)
        spawn(function()
            while particle and particle.Parent do
                particle.Position = UDim2.new(
                    0, (particle.Position.X.Offset + speed) % menuWidth,
                    0, particle.Position.Y.Offset
                )
                wait(0.03)
            end
        end)
        
        table.insert(particles, particle)
    end
end

local function setupHoverEffects()
    for _, connection in ipairs(hoverConnections) do
        connection:Disconnect()
    end
    hoverConnections = {}
    
    if not settings.Misc.HoverEffects then return end
    
    local function applyHoverEffect(button)
        local defaultSize = button.Size
        local defaultPos = button.Position
        local defaultColor = button.BackgroundColor3
        
        local enterConnection = button.MouseEnter:Connect(function()
            if settings.Misc.Animations then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    Size = UDim2.new(defaultSize.X.Scale * 1.05, defaultSize.X.Offset, defaultSize.Y.Scale * 1.05, defaultSize.Y.Offset),
                    BackgroundColor3 = Color3.fromRGB(
                        math.min(255, defaultColor.R * 255 + 20),
                        math.min(255, defaultColor.G * 255 + 20),
                        math.min(255, defaultColor.B * 255 + 20)
                    )
                }):Play()
            end
        end)
        
        local leaveConnection = button.MouseLeave:Connect(function()
            if settings.Misc.Animations then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    Size = defaultSize,
                    BackgroundColor3 = defaultColor
                }):Play()
            end
        end)
        
        table.insert(hoverConnections, enterConnection)
        table.insert(hoverConnections, leaveConnection)
    end
    
    for _, button in ipairs(tabButtons) do
        applyHoverEffect(button)
    end
end

local function createGlowEffect(parent)
    if not settings.Misc.GlowEffects then return end
    
    local glow = Instance.new("ImageLabel")
    glow.Name = "GlowEffect"
    glow.Image = "rbxassetid://5028857084"
    glow.Size = UDim2.new(1, 40, 1, 40)
    glow.Position = UDim2.new(0, -20, 0, -20)
    glow.BackgroundTransparency = 1
    glow.ImageColor3 = currentTheme.Accent
    glow.ImageTransparency = 0.8
    glow.ZIndex = -1
    glow.Parent = parent
    
    return glow
end

local function switchTab(newTab)
    playSound()
    
    if settings.Misc.TabTransitions and settings.Misc.Animations then
        for i, frame in ipairs(contentFrames) do
            if i == currentTab then
                TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                wait(0.1)
                frame.Visible = false
            end
        end
        
        currentTab = newTab
        contentFrames[newTab].Visible = true
        TweenService:Create(contentFrames[newTab], TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    else
        currentTab = newTab
        for i, frame in ipairs(contentFrames) do
            frame.Visible = i == newTab
        end
    end
    
    for i, btn in ipairs(tabButtons) do
        btn.BackgroundColor3 = i == newTab and Color3.fromRGB(
            currentTheme.Accent.R * 255 * 0.7,
            currentTheme.Accent.G * 255 * 0.7,
            currentTheme.Accent.B * 255 * 0.7
        ) or currentTheme.Foreground
    end
end

local function refreshMiscUI(scrollFrame)
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local yOffset = 0
    local elementHeight = 20
    local spacing = 5

    local function createSection(title, offset)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, -8, 0, 20)
        section.Position = UDim2.new(0, 4, 0, offset)
        section.BackgroundTransparency = 1
        section.Parent = scrollFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = currentTheme.Accent
        label.TextSize = 14
        label.Font = Enum.Font[settings.Misc.Font]
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = section

        return offset + elementHeight + spacing
    end

    yOffset = createSection("APPEARANCE", yOffset)

    createCleanToggle(scrollFrame, "Enable Animations", settings.Misc.Animations, function(value)
        settings.Misc.Animations = value
        saveSettings()
    end, "animationsToggle")

    yOffset = yOffset + elementHeight + spacing

    createCleanToggle(scrollFrame, "Enable Glow Effects", settings.Misc.GlowEffects, function(value)
        settings.Misc.GlowEffects = value
        saveSettings()
        if value then
            glowEffects.main = createGlowEffect(mainFrame)
        elseif glowEffects.main then
            glowEffects.main:Destroy()
            glowEffects.main = nil
        end
    end, "glowToggle")

    yOffset = yOffset + elementHeight + spacing

    createCleanToggle(scrollFrame, "Enable Particles", settings.Misc.Particles, function(value)
        settings.Misc.Particles = value
        saveSettings()
        createParticles()
    end, "particlesToggle")

    yOffset = yOffset + elementHeight + spacing

    createCleanToggle(scrollFrame, "Enable Hover Effects", settings.Misc.HoverEffects, function(value)
        settings.Misc.HoverEffects = value
        saveSettings()
        setupHoverEffects()
    end, "hoverToggle")

    yOffset = yOffset + elementHeight + spacing

    createCleanToggle(scrollFrame, "Enable Tab Transitions", settings.Misc.TabTransitions, function(value)
        settings.Misc.TabTransitions = value
        saveSettings()
    end, "tabTransitionsToggle")

    yOffset = yOffset + elementHeight + spacing * 2
    yOffset = createSection("PREFERENCES", yOffset)

    createValueChanger(scrollFrame, "UI Transparency", transparencies, settings.Misc.Transparency, function(value)
        settings.Misc.Transparency = value
        saveSettings()
        if mainFrame then
            mainFrame.BackgroundTransparency = value
        end
    end, "transparencyChanger")

    yOffset = yOffset + elementHeight + spacing

    createValueChanger(scrollFrame, "Font", fonts, settings.Misc.Font, function(value)
        settings.Misc.Font = value
        saveSettings()
        applyTheme()
    end, "fontChanger")

    yOffset = yOffset + elementHeight + spacing

    createValueChanger(scrollFrame, "Font Size", fontSizes, settings.Misc.FontSize, function(value)
        settings.Misc.FontSize = value
        saveSettings()
        applyTheme()
    end, "fontSizeChanger")

    yOffset = yOffset + elementHeight + spacing

    createValueChanger(scrollFrame, "Theme", {"Dark", "Light"}, settings.Misc.Theme, function(value)
        settings.Misc.Theme = value
        saveSettings()
        applyTheme()
        createParticles()
    end, "themeChanger")
end

local function createMainGUI()
    clearAll()
    settings = table.clone(defaultSettings)
    loadSettings()
    scanConfigs()

    if PlayerGui:FindFirstChild("SilenceGui") then
        PlayerGui.SilenceGui:Destroy()
        task.wait(0.1)
    end

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilenceGui"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Enabled = isVisible

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    mainFrame.Position = defaultPosition
    mainFrame.BackgroundColor3 = currentTheme.Background
    mainFrame.BackgroundTransparency = settings.Misc.Transparency
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    if settings.Misc.GlowEffects then
        glowEffects.main = createGlowEffect(mainFrame)
    end

    if settings.Misc.Particles then
        createParticles()
    end

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 6)
    uiCorner.Parent = mainFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = currentTheme.Accent
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0.5
    uiStroke.Parent = mainFrame

    local dragArea = Instance.new("TextButton")
    dragArea.Size = UDim2.new(1, 0, 0, 20)
    dragArea.BackgroundTransparency = 1
    dragArea.Text = "SILENCE"
    dragArea.TextColor3 = currentTheme.Text
    dragArea.TextTransparency = 0.1
    dragArea.TextSize = isMinimized and 12 or 14
    dragArea.Font = Enum.Font[settings.Misc.Font]
    dragArea.TextXAlignment = Enum.TextXAlignment.Center
    dragArea.Selectable = false
    dragArea.Parent = mainFrame

    local rightIcon = Instance.new("ImageLabel")
    rightIcon.Name = "RightIcon"
    rightIcon.Image = "rbxassetid://70459115196971"
    rightIcon.Size = UDim2.new(0, 18, 0, 18)
    rightIcon.Position = UDim2.new(0.5, 30, 0.5, -9)
    rightIcon.BackgroundTransparency = 1
    rightIcon.ImageTransparency = 0.1
    rightIcon.Visible = not isMinimized
    rightIcon.Parent = dragArea

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 20)
    tabContainer.Position = UDim2.new(0, 0, 0, 20)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    local tabIcons = {
        "rbxassetid://15571374043",
        "rbxassetid://6523858394",
        "rbxassetid://7059346373",
        "rbxassetid://7059346373"
    }

    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1 / #tabs, -2, 1, -2)
        tabButton.Position = UDim2.new((i - 1) / #tabs, 1, 0, 1)
        tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
        tabButton.BackgroundTransparency = 0.1
        tabButton.Text = ""
        tabButton.Selectable = false
        tabButton.Parent = tabContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 4)
        tabCorner.Parent = tabButton

        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Size = i == 1 and UDim2.new(0, 18, 0, 18) or UDim2.new(0, 14, 0, 14)
        tabIcon.Position = i == 1 and UDim2.new(0.5, -9, 0.5, -9) or UDim2.new(0.5, -7, 0.5, -7)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = tabIcons[i]
        tabIcon.ImageTransparency = 0.1
        tabIcon.Parent = tabButton

        tabButtons[i] = tabButton

        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, -8, 1, -44)
        contentFrame.Position = UDim2.new(0, 4, 0, 44)
        contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        contentFrame.BackgroundTransparency = 0.1
        contentFrame.Visible = i == currentTab
        contentFrame.Parent = mainFrame

        local contentCorner = Instance.new("UICorner")
        contentCorner.CornerRadius = UDim.new(0, 4)
        contentCorner.Parent = contentFrame

        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 255)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Selectable = false
        scrollFrame.Parent = contentFrame

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 3)
        layout.Parent = scrollFrame

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
        end)

        contentFrames[i] = contentFrame
        scrollFrames[i] = scrollFrame

        if tabName == "Combat" then
            refreshCombatUI()
        elseif tabName == "ESP" then
            refreshESPUI()
        elseif tabName == "Config" then
            refreshConfigUI(scrollFrame)
        elseif tabName == "Misc" then
            refreshMiscUI(scrollFrame)
        end

        tabButton.MouseButton1Click:Connect(function()
            switchTab(i)
        end)
    end

    setupHoverEffects()

    local function tweenFrame(frame, size, position)
        local sizeTween = TweenService:Create(frame, tweenInfo, {Size = size})
        local positionTween = TweenService:Create(frame, tweenInfo, {Position = position})
        sizeTween:Play()
        positionTween:Play()
    end

    dragArea.MouseButton1Click:Connect(function()
        playSound()
        isMinimized = not isMinimized
        local targetSize = isMinimized and minimizedSize or UDim2.new(0, menuWidth, 0, menuHeight)
        local targetPosition = isMinimized and minimizedPosition or defaultPosition
        tweenFrame(mainFrame, targetSize, targetPosition)
        tabContainer.Visible = not isMinimized
        for _, frame in ipairs(contentFrames) do
            frame.Visible = not isMinimized and frame == contentFrames[currentTab]
        end
        dragArea.TextSize = isMinimized and 12 or 14
        mainFrame.BackgroundTransparency = isMinimized and 0.3 or settings.Misc.Transparency
        rightIcon.Visible = not isMinimized
    end)

    local dragging = false
    local dragStart, frameStart
    local minY = 0
    local maxY = viewportSize.Y * 0.7

    dragArea.MouseButton1Down:Connect(function()
        dragging = true
        dragStart = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        frameStart = mainFrame.Position
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(0, UserInputService:GetMouseLocation().Y - dragStart.Y)
            local newY = math.clamp(frameStart.Y.Offset + delta.Y, minY, maxY)
            mainFrame.Position = UDim2.new(0, frameStart.X.Offset, 0, newY)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            defaultPosition = mainFrame.Position
        end
    end)

    connections.InputBegan = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.Insert then
            playSound()
            isVisible = not isVisible
            screenGui.Enabled = isVisible
            if isVisible then
                updateAllESP()
            end
        end
    end)

    disableShadows()
    connections.DescendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") then
            obj.CastShadow = false
        end
    end)

    local function handlePlayerAdded(player)
        if player ~= LocalPlayer then
            createESP(player)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        handlePlayerAdded(player)
    end

    connections.PlayerAdded = Players.PlayerAdded:Connect(handlePlayerAdded)

    connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        clearESP(player)
    end)

    connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
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

    return screenGui
end

local screenGui = createMainGUI()

local followIconGui = Instance.new("ScreenGui")
followIconGui.Name = "UltimateFollowIcon"
followIconGui.ResetOnSpawn = false
followIconGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
followIconGui.DisplayOrder = 999999
followIconGui.IgnoreGuiInset = true
followIconGui.Parent = PlayerGui

local image = Instance.new("ImageLabel")
image.Name = "Icon"
image.Image = "rbxassetid://10983765946"
image.Size = UDim2.new(0, 60, 0, 60)
image.AnchorPoint = Vector2.new(0.5, 0.5)
image.BackgroundTransparency = 1
image.ImageTransparency = 0.2
image.Active = false
image.Selectable = false
image.Parent = followIconGui

local blur = Instance.new("ImageLabel")
blur.Name = "BlurEffect"
blur.Image = "rbxassetid://10983765946"
blur.Size = UDim2.new(1, 10, 1, 10)
blur.AnchorPoint = Vector2.new(0.5, 0.5)
blur.BackgroundTransparency = 1
blur.ImageTransparency = 0.7
blur.Position = UDim2.new(0.5, 0, 0.5, 0)
blur.ZIndex = -1
blur.Parent = image

local activeTouch = nil
local targetPosition = UDim2.new(0.5, 0, 0.5, 0)
local currentPosition = targetPosition
local lastInteraction = os.clock()
local minTransparency = 0.2
local maxTransparency = 0.6
local smoothness = 0.35
local viewportSize = workspace.CurrentCamera.ViewportSize
local yOffset = -0.02

local function updatePosition(input)
    local pos = input.Position
    local x = math.clamp(pos.X / viewportSize.X, 0.02, 0.98)
    local y = math.clamp((pos.Y / viewportSize.Y) + yOffset, 0.02, 0.98)
    targetPosition = UDim2.new(x, 0, y, 0)
    lastInteraction = os.clock()
    image.ImageTransparency = minTransparency
    blur.ImageTransparency = 0.7
end

local function onViewportSizeChanged()
    viewportSize = workspace.CurrentCamera.ViewportSize
    local currentX = currentPosition.X.Scale
    local currentY = currentPosition.Y.Scale
    currentPosition = UDim2.new(currentX, 0, currentY, 0)
    targetPosition = currentPosition
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportSizeChanged)

UserInputService.TouchStarted:Connect(function(input, processed)
    if not processed and not activeTouch then
        activeTouch = input
        updatePosition(input)
    end
end)

UserInputService.TouchMoved:Connect(function(input, processed)
    if not processed and activeTouch and input == activeTouch then
        updatePosition(input)
    end
end)

UserInputService.TouchEnded:Connect(function(input)
    if input == activeTouch then
        activeTouch = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if activeTouch then
        currentPosition = targetPosition
        image.Position = currentPosition
        
        local velocity = (targetPosition.Y.Scale - currentPosition.Y.Scale) * 50
        blur.Size = UDim2.new(1, math.abs(velocity)*0.8, 1, math.abs(velocity)*0.8)
    else
        local delta = os.clock() - lastInteraction
        if delta > 0.5 then
            local newTransparency = math.min(maxTransparency, minTransparency + (delta - 0.5) * 0.25)
            image.ImageTransparency = newTransparency
            blur.ImageTransparency = newTransparency + 0.5
        end
        
        local x = currentPosition.X.Scale + (targetPosition.X.Scale - currentPosition.X.Scale) * smoothness
        local y = currentPosition.Y.Scale + (targetPosition.Y.Scale - currentPosition.Y.Scale) * smoothness
        currentPosition = UDim2.new(x, 0, y, 0)
        image.Position = currentPosition
        
        blur.Size = UDim2.new(1, 5, 1, 5)
    end
end)

GuiService:RegisterIsActiveCallback("IconBlocker", function(isActive)
    if not isActive then
        activeTouch = nil
    end
end)

game:BindToClose(function()
    clearAll()
    if screenGui then
        screenGui:Destroy()
    end
    if followIconGui then
        followIconGui:Destroy()
    end
    if soundCache.clickSound then
        soundCache.clickSound:Stop()
        soundCache.clickSound:Destroy()
    end
end)