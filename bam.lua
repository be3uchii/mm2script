local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local viewportSize = Camera.ViewportSize

local menuWidth, menuHeight = 280, 180
local menuX, menuY = (viewportSize.X - menuWidth)/2, (viewportSize.Y - menuHeight)/2
local isMinimized = false
local isVisible = true
local currentTab = 1
local tabs = {"Combat", "Visuals", "Movement"}

local settings = {
    Combat = {
        Hitbox = {
            Enabled = false,
            Size = 4,
            Color = Color3.fromRGB(255, 50, 50),
            Transparency = 0.4,
            Expansion = {
                X = 1.5,
                Y = 2.5,
                Z = 1.5
            }
        },
        TriggerBot = {
            Enabled = false,
            Range = 20,
            Delay = 0.1
        }
    },
    Visuals = {
        ESP = {
            Enabled = false,
            Boxes = true,
            Names = false,
            Health = false,
            Distance = false,
            Color = Color3.fromRGB(255, 255, 255),
            MaxDistance = 500
        },
        Chams = {
            Enabled = false,
            Color = Color3.fromRGB(255, 100, 100),
            Transparency = 0.5
        },
        Tracers = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255)
        }
    },
    Movement = {
        NoClip = true,
        Speed = 16,
        JumpPower = 50,
        Fly = {
            Enabled = false,
            Speed = 30
        }
    }
}

local espCache = {}
local hitboxCache = {}
local chamCache = {}
local tracerCache = {}
local connections = {}
local playerConnections = {}
local uiElements = {}

local function createUI()
    if PlayerGui:FindFirstChild("SilenceUI") then
        PlayerGui.SilenceUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilenceUI"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Enabled = isVisible
    uiElements.ScreenGui = screenGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    mainFrame.Position = UDim2.new(0, menuX, 0, menuY)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    uiElements.MainFrame = mainFrame

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 6)
    uiCorner.Parent = mainFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(60, 60, 255)
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0.3
    uiStroke.Parent = mainFrame

    local dragArea = Instance.new("TextButton")
    dragArea.Size = UDim2.new(1, 0, 0, 25)
    dragArea.BackgroundTransparency = 1
    dragArea.Text = "SILENCE v5.0"
    dragArea.TextColor3 = Color3.fromRGB(200, 200, 200)
    dragArea.TextSize = 14
    dragArea.Font = Enum.Font.GothamBold
    dragArea.TextXAlignment = Enum.TextXAlignment.Center
    dragArea.Parent = mainFrame
    uiElements.DragArea = dragArea

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 25)
    tabContainer.Position = UDim2.new(0, 0, 0, 25)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    uiElements.TabContainer = tabContainer

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -8, 1, -60)
    contentFrame.Position = UDim2.new(0, 4, 0, 55)
    contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    contentFrame.BackgroundTransparency = 0.2
    contentFrame.Parent = mainFrame
    uiElements.ContentFrame = contentFrame

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
    uiElements.ScrollFrame = scrollFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scrollFrame

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
    end)

    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1/#tabs, -4, 1, -4)
        tabButton.Position = UDim2.new((i-1)/#tabs, 2, 0, 2)
        tabButton.BackgroundColor3 = i == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
        tabButton.BackgroundTransparency = 0.2
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.TextSize = 12
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Parent = tabContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 4)
        tabCorner.Parent = tabButton

        tabButton.MouseButton1Click:Connect(function()
            currentTab = i
            for j, btn in ipairs(tabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = j == currentTab and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
                end
            end
        end)
    end

    local function createToggle(parent, text, config, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -8, 0, 20)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Position = UDim2.new(0, 4, 0, 0)
        toggleFrame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0.25, 0, 0.8, 0)
        toggle.Position = UDim2.new(0.7, 0, 0.1, 0)
        toggle.BackgroundColor3 = config and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        toggle.Text = config and "ON" or "OFF"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 10
        toggle.Font = Enum.Font.GothamBold
        toggle.Parent = toggleFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = toggle

        toggle.MouseButton1Click:Connect(function()
            config = not config
            toggle.Text = config and "ON" or "OFF"
            toggle.BackgroundColor3 = config and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
            if callback then callback(config) end
        end)

        return toggleFrame
    end

    local function createSlider(parent, text, config, min, max, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, -8, 0, 20)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Position = UDim2.new(0, 4, 0, 0)
        sliderFrame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
        valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(config)
        valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        valueLabel.TextSize = 12
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Center
        valueLabel.Parent = sliderFrame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.25, 0, 0.3, 0)
        slider.Position = UDim2.new(0.75, 0, 0.35, 0)
        slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        slider.Parent = sliderFrame

        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(1, 0)
        sliderCorner.Parent = slider

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((config - min)/(max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
        fill.Parent = slider

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill

        local sliderButton = Instance.new("TextButton")
        sliderButton.Size = UDim2.new(0, 10, 0, 10)
        sliderButton.Position = UDim2.new((config - min)/(max - min), -5, 0.5, -5)
        sliderButton.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        sliderButton.Text = ""
        sliderButton.Parent = slider

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(1, 0)
        buttonCorner.Parent = sliderButton

        local dragging = false
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local x = (input.Position.X - slider.AbsolutePosition.X)/slider.AbsoluteSize.X
                x = math.clamp(x, 0, 1)
                local value = math.floor(min + (max - min)*x + 0.5)
                if value ~= config then
                    config = value
                    valueLabel.Text = tostring(value)
                    fill.Size = UDim2.new(x, 0, 1, 0)
                    sliderButton.Position = UDim2.new(x, -5, 0.5, -5)
                    if callback then callback(value) end
                end
            end
        end)

        return sliderFrame
    end

    local function createColorPicker(parent, text, color, callback)
        local pickerFrame = Instance.new("Frame")
        pickerFrame.Size = UDim2.new(1, -8, 0, 20)
        pickerFrame.BackgroundTransparency = 1
        pickerFrame.Position = UDim2.new(0, 4, 0, 0)
        pickerFrame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = pickerFrame

        local colorButton = Instance.new("TextButton")
        colorButton.Size = UDim2.new(0.25, 0, 0.8, 0)
        colorButton.Position = UDim2.new(0.7, 0, 0.1, 0)
        colorButton.BackgroundColor3 = color
        colorButton.Text = ""
        colorButton.Parent = pickerFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = colorButton

        colorButton.MouseButton1Click:Connect(function()
            local colorPicker = Instance.new("Frame")
            colorPicker.Size = UDim2.new(0, 150, 0, 150)
            colorPicker.Position = UDim2.new(0.5, -75, 0.5, -75)
            colorPicker.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            colorPicker.BorderSizePixel = 0
            colorPicker.Parent = parent.Parent.Parent

            local huePicker = Instance.new("ImageButton")
            huePicker.Size = UDim2.new(0, 120, 0, 120)
            huePicker.Position = UDim2.new(0, 5, 0, 5)
            huePicker.Image = "rbxassetid://4155801252"
            huePicker.Parent = colorPicker

            local brightnessPicker = Instance.new("Frame")
            brightnessPicker.Size = UDim2.new(0, 20, 0, 120)
            brightnessPicker.Position = UDim2.new(0, 125, 0, 5)
            brightnessPicker.BackgroundColor3 = Color3.new(1, 1, 1)
            brightnessPicker.Parent = colorPicker

            local brightnessGradient = Instance.new("UIGradient")
            brightnessGradient.Rotation = 90
            brightnessGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
            }
            brightnessGradient.Parent = brightnessPicker

            local selectedColor = Instance.new("Frame")
            selectedColor.Size = UDim2.new(0, 20, 0, 20)
            selectedColor.Position = UDim2.new(0, 130, 0, 130)
            selectedColor.BackgroundColor3 = color
            selectedColor.Parent = colorPicker

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0.5, 0)
            corner.Parent = selectedColor

            local closeButton = Instance.new("TextButton")
            closeButton.Size = UDim2.new(0, 20, 0, 20)
            closeButton.Position = UDim2.new(0, 130, 0, 130)
            closeButton.BackgroundTransparency = 1
            closeButton.Text = "X"
            closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            closeButton.TextSize = 14
            closeButton.Font = Enum.Font.GothamBold
            closeButton.Parent = colorPicker

            local function updateColor(hue, sat, val)
                local newColor = Color3.fromHSV(hue, sat, val)
                selectedColor.BackgroundColor3 = newColor
                colorButton.BackgroundColor3 = newColor
                if callback then callback(newColor) end
            end

            huePicker.MouseButton1Down:Connect(function(x, y)
                local xPos = math.clamp(x - huePicker.AbsolutePosition.X, 0, huePicker.AbsoluteSize.X)
                local yPos = math.clamp(y - huePicker.AbsolutePosition.Y, 0, huePicker.AbsoluteSize.Y)
                local hue = xPos / huePicker.AbsoluteSize.X
                local sat = 1 - (yPos / huePicker.AbsoluteSize.Y)
                updateColor(hue, sat, 1)
            end)

            brightnessPicker.MouseButton1Down:Connect(function(x, y)
                local yPos = math.clamp(y - brightnessPicker.AbsolutePosition.Y, 0, brightnessPicker.AbsoluteSize.Y)
                local val = yPos / brightnessPicker.AbsoluteSize.Y
                local h, s = Color3.toHSV(selectedColor.BackgroundColor3)
                updateColor(h, s, 1 - val)
            end)

            closeButton.MouseButton1Click:Connect(function()
                colorPicker:Destroy()
            end)
        end)

        return pickerFrame
    end

    local function updateUI()
        for _, child in ipairs(uiElements.ScrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        if currentTab == 1 then
            createToggle(uiElements.ScrollFrame, "Hitbox Enabled", settings.Combat.Hitbox.Enabled, function(value)
                settings.Combat.Hitbox.Enabled = value
            end)
            createSlider(uiElements.ScrollFrame, "Hitbox Size", settings.Combat.Hitbox.Size, 1, 10, function(value)
                settings.Combat.Hitbox.Size = value
            end)
            createColorPicker(uiElements.ScrollFrame, "Hitbox Color", settings.Combat.Hitbox.Color, function(value)
                settings.Combat.Hitbox.Color = value
            end)
            createSlider(uiElements.ScrollFrame, "Hitbox Transparency", settings.Combat.Hitbox.Transparency * 100, 0, 100, function(value)
                settings.Combat.Hitbox.Transparency = value / 100
            end)
            createToggle(uiElements.ScrollFrame, "TriggerBot", settings.Combat.TriggerBot.Enabled, function(value)
                settings.Combat.TriggerBot.Enabled = value
            end)
            createSlider(uiElements.ScrollFrame, "TriggerBot Range", settings.Combat.TriggerBot.Range, 5, 50, function(value)
                settings.Combat.TriggerBot.Range = value
            end)
            createSlider(uiElements.ScrollFrame, "TriggerBot Delay", settings.Combat.TriggerBot.Delay * 100, 0, 50, function(value)
                settings.Combat.TriggerBot.Delay = value / 100
            end)
        elseif currentTab == 2 then
            createToggle(uiElements.ScrollFrame, "ESP Enabled", settings.Visuals.ESP.Enabled, function(value)
                settings.Visuals.ESP.Enabled = value
            end)
            createToggle(uiElements.ScrollFrame, "ESP Boxes", settings.Visuals.ESP.Boxes, function(value)
                settings.Visuals.ESP.Boxes = value
            end)
            createToggle(uiElements.ScrollFrame, "ESP Names", settings.Visuals.ESP.Names, function(value)
                settings.Visuals.ESP.Names = value
            end)
            createToggle(uiElements.ScrollFrame, "ESP Health", settings.Visuals.ESP.Health, function(value)
                settings.Visuals.ESP.Health = value
            end)
            createToggle(uiElements.ScrollFrame, "ESP Distance", settings.Visuals.ESP.Distance, function(value)
                settings.Visuals.ESP.Distance = value
            end)
            createColorPicker(uiElements.ScrollFrame, "ESP Color", settings.Visuals.ESP.Color, function(value)
                settings.Visuals.ESP.Color = value
            end)
            createSlider(uiElements.ScrollFrame, "ESP Max Distance", settings.Visuals.ESP.MaxDistance, 50, 1000, function(value)
                settings.Visuals.ESP.MaxDistance = value
            end)
            createToggle(uiElements.ScrollFrame, "Chams Enabled", settings.Visuals.Chams.Enabled, function(value)
                settings.Visuals.Chams.Enabled = value
            end)
            createColorPicker(uiElements.ScrollFrame, "Chams Color", settings.Visuals.Chams.Color, function(value)
                settings.Visuals.Chams.Color = value
            end)
            createSlider(uiElements.ScrollFrame, "Chams Transparency", settings.Visuals.Chams.Transparency * 100, 0, 100, function(value)
                settings.Visuals.Chams.Transparency = value / 100
            end)
            createToggle(uiElements.ScrollFrame, "Tracers Enabled", settings.Visuals.Tracers.Enabled, function(value)
                settings.Visuals.Tracers.Enabled = value
            end)
            createColorPicker(uiElements.ScrollFrame, "Tracers Color", settings.Visuals.Tracers.Color, function(value)
                settings.Visuals.Tracers.Color = value
            end)
        elseif currentTab == 3 then
            createToggle(uiElements.ScrollFrame, "NoClip", settings.Movement.NoClip, function(value)
                settings.Movement.NoClip = value
            end)
            createSlider(uiElements.ScrollFrame, "Walk Speed", settings.Movement.Speed, 16, 100, function(value)
                settings.Movement.Speed = value
            end)
            createSlider(uiElements.ScrollFrame, "Jump Power", settings.Movement.JumpPower, 50, 200, function(value)
                settings.Movement.JumpPower = value
            end)
            createToggle(uiElements.ScrollFrame, "Fly Enabled", settings.Movement.Fly.Enabled, function(value)
                settings.Movement.Fly.Enabled = value
            end)
            createSlider(uiElements.ScrollFrame, "Fly Speed", settings.Movement.Fly.Speed, 10, 100, function(value)
                settings.Movement.Fly.Speed = value
            end)
        end
    end

    for i, tabButton in ipairs(tabContainer:GetChildren()) do
        if tabButton:IsA("TextButton") then
            tabButton.MouseButton1Click:Connect(updateUI)
        end
    end

    updateUI()

    dragArea.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            mainFrame.Size = UDim2.new(0, 80, 0, 30)
            mainFrame.Position = UDim2.new(0.5, -40, 0, 10)
            tabContainer.Visible = false
            contentFrame.Visible = false
            dragArea.TextSize = 12
        else
            mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
            mainFrame.Position = UDim2.new(0, menuX, 0, menuY)
            tabContainer.Visible = true
            contentFrame.Visible = true
            dragArea.TextSize = 14
        end
    end)

    local dragInput, dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not isMinimized then
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragInput = nil
                end
            end)
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragStart and not isMinimized then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            isVisible = not isVisible
            screenGui.Enabled = isVisible
        end
    end)
end

local function createESP(player)
    if espCache[player] then return end
    
    espCache[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    
    local esp = espCache[player]
    
    esp.Box.Visible = false
    esp.Box.Color = settings.Visuals.ESP.Color
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    
    esp.Name.Visible = false
    esp.Name.Color = settings.Visuals.ESP.Color
    esp.Name.Size = 13
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Font = 2
    
    esp.Health.Visible = false
    esp.Health.Color = Color3.fromRGB(0, 255, 0)
    esp.Health.Size = 13
    esp.Health.Center = true
    esp.Health.Outline = true
    esp.Health.Font = 2
    
    esp.Distance.Visible = false
    esp.Distance.Color = settings.Visuals.ESP.Color
    esp.Distance.Size = 13
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Font = 2
    
    esp.Tracer.Visible = false
    esp.Tracer.Color = settings.Visuals.Tracers.Color
    esp.Tracer.Thickness = 1
    esp.Tracer.Transparency = 1
    
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
            if chamCache[character] then
                chamCache[character]:Destroy()
                chamCache[character] = nil
            end
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    playerConnections[player].added = player.CharacterAdded:Connect(onCharacterAdded)
end

local function updateESP(player)
    local esp = espCache[player]
    if not esp then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        for _, drawing in pairs(esp) do
            drawing.Visible = false
        end
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        for _, drawing in pairs(esp) do
            drawing.Visible = false
        end
        return
    end
    
    local head = character:FindFirstChild("Head")
    if not head then
        for _, drawing in pairs(esp) do
            drawing.Visible = false
        end
        return
    end
    
    local distance = (humanoidRootPart.Position - Camera.CFrame.Position).Magnitude
    if distance > settings.Visuals.ESP.MaxDistance then
        for _, drawing in pairs(esp) do
            drawing.Visible = false
        end
        return
    end
    
    local rootPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        for _, drawing in pairs(esp) do
            drawing.Visible = false
        end
        return
    end
    
    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local feetPos = Camera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
    
    local height = (headPos.Y - feetPos.Y)
    local width = height * 0.6
    
    esp.Box.Size = Vector2.new(width, height)
    esp.Box.Position = Vector2.new(rootPos.X - width/2, feetPos.Y)
    esp.Box.Visible = settings.Visuals.ESP.Enabled and settings.Visuals.ESP.Boxes
    esp.Box.Color = settings.Visuals.ESP.Color
    
    esp.Name.Text = player.Name
    esp.Name.Position = Vector2.new(rootPos.X, feetPos.Y - 15)
    esp.Name.Visible = settings.Visuals.ESP.Enabled and settings.Visuals.ESP.Names
    esp.Name.Color = settings.Visuals.ESP.Color
    
    local health = math.floor(character.Humanoid.Health)
    esp.Health.Text = tostring(health)
    esp.Health.Position = Vector2.new(rootPos.X, feetPos.Y + height + 5)
    esp.Health.Color = Color3.fromHSV(health/100 * 0.3, 1, 1)
    esp.Health.Visible = settings.Visuals.ESP.Enabled and settings.Visuals.ESP.Health
    
    esp.Distance.Text = tostring(math.floor(distance)) .. "m"
    esp.Distance.Position = Vector2.new(rootPos.X, feetPos.Y + height + 20)
    esp.Distance.Visible = settings.Visuals.ESP.Enabled and settings.Visuals.ESP.Distance
    esp.Distance.Color = settings.Visuals.ESP.Color
    
    esp.Tracer.From = Vector2.new(viewportSize.X/2, viewportSize.Y)
    esp.Tracer.To = Vector2.new(rootPos.X, feetPos.Y + height)
    esp.Tracer.Visible = settings.Visuals.ESP.Enabled and settings.Visuals.Tracers.Enabled
    esp.Tracer.Color = settings.Visuals.Tracers.Color
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
        box.Size = Vector3.new(
            settings.Combat.Hitbox.Size * settings.Combat.Hitbox.Expansion.X,
            settings.Combat.Hitbox.Size * settings.Combat.Hitbox.Expansion.Y,
            settings.Combat.Hitbox.Size * settings.Combat.Hitbox.Expansion.Z
        )
        box.Transparency = settings.Combat.Hitbox.Transparency
        box.Color3 = settings.Combat.Hitbox.Color
        box.Parent = hrp
        
        hitboxCache[character] = box
        
        hrp:GetPropertyChangedSignal("Size"):Connect(function()
            if hitboxCache[character] then
                hitboxCache[character].Size = Vector3.new(
                    hrp.Size.X * settings.Combat.Hitbox.Expansion.X,
                    hrp.Size.Y * settings.Combat.Hitbox.Expansion.Y,
                    hrp.Size.Z * settings.Combat.Hitbox.Expansion.Z
                )
            end
        end)
    end
    
    hrp.Size = Vector3.new(settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size, settings.Combat.Hitbox.Size)
    hrp.Transparency = 1
    hrp.CanCollide = false
    
    local box = hitboxCache[character]
    if box then
        box.Size = Vector3.new(
            hrp.Size.X * settings.Combat.Hitbox.Expansion.X,
            hrp.Size.Y * settings.Combat.Hitbox.Expansion.Y,
            hrp.Size.Z * settings.Combat.Hitbox.Expansion.Z
        )
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
    if not settings.Visuals.Chams.Enabled then return end
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then return end
    
    if not chamCache[character] then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ChamsAdornment"
        box.Adornee = character
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Size = character:GetExtentsSize()
        box.Transparency = settings.Visuals.Chams.Transparency
        box.Color3 = settings.Visuals.Chams.Color
        box.Parent = character
        
        chamCache[character] = box
        
        character.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") then
                part.Transparency = 0.5
            end
        end)
    end
    
    local box = chamCache[character]
    if box then
        box.Size = character:GetExtentsSize()
        box.Transparency = settings.Visuals.Chams.Transparency
        box.Color3 = settings.Visuals.Chams.Color
    end
end

local function clearChams()
    for character, box in pairs(chamCache) do
        box:Destroy()
    end
    chamCache = {}
end

local function updateNoClip()
    if not settings.Movement.NoClip then return end
    if not LocalPlayer.Character then return end
    
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") and part ~= LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            part.CanCollide = false
        end
    end
end

local function updateSpeed()
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid.WalkSpeed = settings.Movement.Speed
    humanoid.JumpPower = settings.Movement.JumpPower
end

local function updateFly()
    if not settings.Movement.Fly.Enabled then return end
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid.PlatformStand = true
    
    local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyVelocity.Parent = rootPart
    
    local flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyGyro.P = 1000
    flyGyro.D = 50
    flyGyro.Parent = rootPart
    
    connections.Fly = RunService.Heartbeat:Connect(function()
        if not settings.Movement.Fly.Enabled then
            flyVelocity:Destroy()
            flyGyro:Destroy()
            humanoid.PlatformStand = false
            connections.Fly:Disconnect()
            return
        end
        
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * settings.Movement.Fly.Speed
        end
        
        flyVelocity.Velocity = moveDirection
        flyGyro.CFrame = camera.CFrame
    end)
end

local function updateTriggerBot()
    if not settings.Combat.TriggerBot.Enabled then return end
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local target = nil
    local closestDistance = settings.Combat.TriggerBot.Range
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local head = character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                local distance = (head.Position - rootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    target = head
                end
            end
        end
    end
    
    if target then
        wait(settings.Combat.TriggerBot.Delay)
        mouse1click()
    end
end

local function updateAll()
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
    
    if settings.Visuals.Chams.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                updateChams(player.Character)
            end
        end
    else
        clearChams()
    end
    
    updateNoClip()
    updateSpeed()
    updateTriggerBot()
end

local function setupPlayer(player)
    if player == LocalPlayer then return end
    createESP(player)
end

local function removePlayer(player)
    clearESP(player)
    if player.Character and hitboxCache[player.Character] then
        hitboxCache[player.Character]:Destroy()
        hitboxCache[player.Character] = nil
    end
    if player.Character and chamCache[player.Character] then
        chamCache[player.Character]:Destroy()
        chamCache[player.Character] = nil
    end
end

local function init()
    createUI()
    
    for _, player in ipairs(Players:GetPlayers()) do
        setupPlayer(player)
    end
    
    Players.PlayerAdded:Connect(setupPlayer)
    Players.PlayerRemoving:Connect(removePlayer)
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        updateNoClip()
        updateSpeed()
        character:WaitForChild("Humanoid").Died:Connect(function()
            updateNoClip()
        end)
    end)
    
    if LocalPlayer.Character then
        updateNoClip()
        updateSpeed()
    end
    
    connections.RenderStep = RunService.RenderStepped:Connect(function()
        updateAll()
    end)
    
    game:BindToClose(function()
        for _, conn in pairs(connections) do
            conn:Disconnect()
        end
        for player, _ in pairs(playerConnections) do
            clearESP(player)
        end
        for _, esp in pairs(espCache) do
            for _, drawing in pairs(esp) do
                drawing:Remove()
            end
        end
        clearHitboxes()
        clearChams()
        if uiElements.ScreenGui then
            uiElements.ScreenGui:Destroy()
        end
    end)
end

init()