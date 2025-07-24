local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local UI = {
    enabled = true,
    mainColor = Color3.fromRGB(28, 28, 38),
    accentColor = Color3.fromRGB(0, 170, 255),
    textColor = Color3.fromRGB(255, 255, 255),
    transparency = 0.2,
    size = UDim2.new(0, 350, 0, 400),
    minimizedSize = UDim2.new(0, 350, 0, 30),
    position = UDim2.new(0.5, -175, 0.5, -200)
}

local ESP = {
    enabled = false,
    boxes = false,
    tracers = false,
    color = Color3.fromRGB(255, 0, 0),
    teamCheck = true
}

local Hitbox = {
    enabled = false,
    size = 1,
    maxSize = 7,
    color = Color3.fromRGB(255, 0, 0),
    transparency = 0.5,
    visible = false
}

local function CreateHitbox(character)
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part:FindFirstChild("Hitbox") then
            part.Hitbox:Destroy()
        end
    end

    if Hitbox.enabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "Hitbox"
                box.Adornee = part
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Size = part.Size * Hitbox.size
                box.Transparency = Hitbox.transparency
                box.Color3 = Hitbox.color
                box.Visible = Hitbox.visible
                box.Parent = part
            end
        end
    end
end

local function UpdateHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateHitbox(player.Character)
        end
    end
end

local function CreateESP(player)
    if not player or player == LocalPlayer then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local holder = Instance.new("Folder")
    holder.Name = player.Name
    holder.Parent = Camera

    if Camera:FindFirstChild(player.Name) then
        Camera[player.Name]:Destroy()
    end

    if ESP.enabled and (not ESP.teamCheck or player.Team ~= LocalPlayer.Team) then
        if ESP.boxes then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "Box"
            box.Adornee = character:WaitForChild("HumanoidRootPart")
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Size = character:WaitForChild("HumanoidRootPart").Size * 2
            box.Transparency = 0.7
            box.Color3 = ESP.color
            box.Parent = holder
        end

        if ESP.tracers then
            local beam = Instance.new("Beam")
            beam.Name = "Tracer"
            beam.Attachment0 = Instance.new("Attachment")
            beam.Attachment0.Parent = character:WaitForChild("HumanoidRootPart")
            beam.Attachment1 = Instance.new("Attachment")
            beam.Attachment1.Parent = Camera:WaitForChild("HumanoidRootPart")
            beam.Width0 = 0.1
            beam.Width1 = 0.1
            beam.Color = ColorSequence.new(ESP.color)
            beam.Parent = holder
        end
    end

    character:WaitForChild("Humanoid").Died:Connect(function()
        holder:Destroy()
    end)
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                CreateESP(player)
            else
                player.CharacterAdded:Connect(function(character)
                    CreateESP(player)
                end)
            end
        end
    end
end

local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MVSD_Hub"
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UI.size
    MainFrame.Position = UI.position
    MainFrame.BackgroundColor3 = UI.mainColor
    MainFrame.BackgroundTransparency = UI.transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = UI.mainColor
    Header.BackgroundTransparency = UI.transparency
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "MVSD HUB"
    Title.TextColor3 = UI.textColor
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = Header

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = UI.textColor
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.Parent = Header

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "Minimize"
    MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
    MinimizeButton.Position = UDim2.new(1, -55, 0, 5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = UI.textColor
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 14
    MinimizeButton.Parent = Header

    local TabButtons = Instance.new("Frame")
    TabButtons.Name = "TabButtons"
    TabButtons.Size = UDim2.new(0, 100, 1, -30)
    TabButtons.Position = UDim2.new(0, 0, 0, 30)
    TabButtons.BackgroundColor3 = UI.mainColor
    TabButtons.BackgroundTransparency = UI.transparency
    TabButtons.BorderSizePixel = 0
    TabButtons.Parent = MainFrame

    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = "TabContent"
    TabContent.Size = UDim2.new(1, -100, 1, -30)
    TabContent.Position = UDim2.new(0, 100, 0, 30)
    TabContent.BackgroundTransparency = 1
    TabContent.ScrollBarThickness = 5
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.Parent = MainFrame

    local function CreateTab(name)
        local Tab = {
            name = name,
            button = nil,
            frame = nil,
            elements = {}
        }

        Tab.button = Instance.new("TextButton")
        Tab.button.Name = name
        Tab.button.Size = UDim2.new(1, -10, 0, 30)
        Tab.button.Position = UDim2.new(0, 5, 0, 5 + (#library.tabs * 35))
        Tab.button.BackgroundColor3 = UI.mainColor
        Tab.button.BackgroundTransparency = UI.transparency
        Tab.button.BorderSizePixel = 0
        Tab.button.Text = name
        Tab.button.TextColor3 = UI.textColor
        Tab.button.Font = Enum.Font.Gotham
        Tab.button.TextSize = 14
        Tab.button.Parent = TabButtons

        Tab.frame = Instance.new("Frame")
        Tab.frame.Name = name
        Tab.frame.Size = UDim2.new(1, 0, 1, 0)
        Tab.frame.Position = UDim2.new(0, 0, 0, 0)
        Tab.frame.BackgroundTransparency = 1
        Tab.frame.Visible = false
        Tab.frame.Parent = TabContent

        table.insert(library.tabs, Tab)

        if #library.tabs == 1 then
            library.currentTab = Tab
            Tab.button.BackgroundColor3 = UI.accentColor
            Tab.frame.Visible = true
        end

        Tab.button.MouseButton1Click:Connect(function()
            for _, t in ipairs(library.tabs) do
                t.button.BackgroundColor3 = UI.mainColor
                t.frame.Visible = false
            end
            Tab.button.BackgroundColor3 = UI.accentColor
            Tab.frame.Visible = true
            library.currentTab = Tab
        end)

        return Tab
    end

    local function CreateToggle(tab, text, state, callback)
        local Toggle = Instance.new("Frame")
        Toggle.Name = text
        Toggle.Size = UDim2.new(1, -20, 0, 30)
        Toggle.Position = UDim2.new(0, 10, 0, 10 + (#tab.elements * 35))
        Toggle.BackgroundTransparency = 1
        Toggle.Parent = tab.frame

        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Size = UDim2.new(0, 20, 0, 20)
        Button.Position = UDim2.new(0, 0, 0, 5)
        Button.BackgroundColor3 = state and UI.accentColor or UI.mainColor
        Button.BackgroundTransparency = UI.transparency
        Button.BorderSizePixel = 0
        Button.Text = ""
        Button.Parent = Toggle

        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(1, -30, 1, 0)
        Label.Position = UDim2.new(0, 25, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = UI.textColor
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.Parent = Toggle

        Button.MouseButton1Click:Connect(function()
            state = not state
            Button.BackgroundColor3 = state and UI.accentColor or UI.mainColor
            callback(state)
        end)

        table.insert(tab.elements, Toggle)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 10 + (#tab.elements * 35))

        return {
            toggle = Toggle,
            button = Button,
            label = Label
        }
    end

    local function CreateSlider(tab, text, min, max, value, callback)
        local Slider = Instance.new("Frame")
        Slider.Name = text
        Slider.Size = UDim2.new(1, -20, 0, 50)
        Slider.Position = UDim2.new(0, 10, 0, 10 + (#tab.elements * 55))
        Slider.BackgroundTransparency = 1
        Slider.Parent = tab.frame

        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text .. ": " .. value
        Label.TextColor3 = UI.textColor
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.Parent = Slider

        local Track = Instance.new("Frame")
        Track.Name = "Track"
        Track.Size = UDim2.new(1, 0, 0, 5)
        Track.Position = UDim2.new(0, 0, 0, 25)
        Track.BackgroundColor3 = UI.mainColor
        Track.BackgroundTransparency = UI.transparency
        Track.BorderSizePixel = 0
        Track.Parent = Slider

        local Fill = Instance.new("Frame")
        Fill.Name = "Fill"
        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        Fill.Position = UDim2.new(0, 0, 0, 0)
        Fill.BackgroundColor3 = UI.accentColor
        Fill.BorderSizePixel = 0
        Fill.Parent = Track

        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Size = UDim2.new(0, 15, 0, 15)
        Button.Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7)
        Button.BackgroundColor3 = UI.textColor
        Button.BorderSizePixel = 0
        Button.Text = ""
        Button.Parent = Slider

        local Dragging = false

        Button.MouseButton1Down:Connect(function()
            Dragging = true
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
                pos = math.clamp(pos, 0, 1)
                local newValue = math.floor(min + (max - min) * pos)
                if newValue ~= value then
                    value = newValue
                    Label.Text = text .. ": " .. value
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    Button.Position = UDim2.new(pos, -7, 0.5, -7)
                    callback(value)
                end
            end
        end)

        table.insert(tab.elements, Slider)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 10 + (#tab.elements * 55))

        return {
            slider = Slider,
            label = Label,
            track = Track,
            fill = Fill,
            button = Button
        }
    end

    local function CreateColorPicker(tab, text, color, callback)
        local Picker = Instance.new("Frame")
        Picker.Name = text
        Picker.Size = UDim2.new(1, -20, 0, 50)
        Picker.Position = UDim2.new(0, 10, 0, 10 + (#tab.elements * 55))
        Picker.BackgroundTransparency = 1
        Picker.Parent = tab.frame

        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(1, -60, 0, 20)
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = UI.textColor
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.Parent = Picker

        local Preview = Instance.new("Frame")
        Preview.Name = "Preview"
        Preview.Size = UDim2.new(0, 50, 0, 50)
        Preview.Position = UDim2.new(1, -50, 0, 0)
        Preview.BackgroundColor3 = color
        Preview.BorderSizePixel = 0
        Preview.Parent = Picker

        local ColorPicker = Instance.new("Frame")
        ColorPicker.Name = "ColorPicker"
        ColorPicker.Size = UDim2.new(0, 200, 0, 200)
        ColorPicker.Position = UDim2.new(0.5, -100, 0, 60)
        ColorPicker.BackgroundColor3 = UI.mainColor
        ColorPicker.BackgroundTransparency = UI.transparency
        ColorPicker.BorderSizePixel = 0
        ColorPicker.Visible = false
        ColorPicker.Parent = Picker

        local Saturation = Instance.new("ImageLabel")
        Saturation.Name = "Saturation"
        Saturation.Size = UDim2.new(1, -40, 1, -40)
        Saturation.Position = UDim2.new(0, 20, 0, 20)
        Saturation.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
        Saturation.BorderSizePixel = 0
        Saturation.Image = "rbxassetid://4155801252"
        Saturation.Parent = ColorPicker

        local Hue = Instance.new("ImageLabel")
        Hue.Name = "Hue"
        Hue.Size = UDim2.new(0, 20, 1, -40)
        Hue.Position = UDim2.new(1, -20, 0, 20)
        Hue.BorderSizePixel = 0
        Hue.Image = "rbxassetid://3570695787"
        Hue.Parent = ColorPicker

        local Brightness = Instance.new("Frame")
        Brightness.Name = "Brightness"
        Brightness.Size = UDim2.new(1, -40, 0, 20)
        Brightness.Position = UDim2.new(0, 20, 1, -20)
        Brightness.BackgroundColor3 = Color3.new(0, 0, 0)
        Brightness.BorderSizePixel = 0
        Brightness.Parent = ColorPicker

        local BrightnessGradient = Instance.new("UIGradient")
        BrightnessGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
        })
        BrightnessGradient.Rotation = 0
        BrightnessGradient.Parent = Brightness

        local SaturationSelector = Instance.new("Frame")
        SaturationSelector.Name = "SaturationSelector"
        SaturationSelector.Size = UDim2.new(0, 10, 0, 10)
        SaturationSelector.Position = UDim2.new(0.5, -5, 0.5, -5)
        SaturationSelector.BackgroundColor3 = Color3.new(1, 1, 1)
        SaturationSelector.BorderColor3 = Color3.new(0, 0, 0)
        SaturationSelector.BorderSizePixel = 1
        SaturationSelector.Parent = Saturation

        local HueSelector = Instance.new("Frame")
        HueSelector.Name = "HueSelector"
        HueSelector.Size = UDim2.new(1, 0, 0, 2)
        HueSelector.Position = UDim2.new(0, 0, 0, 0)
        HueSelector.BackgroundColor3 = Color3.new(1, 1, 1)
        HueSelector.BorderColor3 = Color3.new(0, 0, 0)
        HueSelector.BorderSizePixel = 1
        HueSelector.Parent = Hue

        local BrightnessSelector = Instance.new("Frame")
        BrightnessSelector.Name = "BrightnessSelector"
        BrightnessSelector.Size = UDim2.new(0, 10, 1, 0)
        BrightnessSelector.Position = UDim2.new(0.5, -5, 0, 0)
        BrightnessSelector.BackgroundColor3 = Color3.new(1, 1, 1)
        BrightnessSelector.BorderColor3 = Color3.new(0, 0, 0)
        BrightnessSelector.BorderSizePixel = 1
        BrightnessSelector.Visible = false
        BrightnessSelector.Parent = Brightness

        local function UpdateColor(h, s, v)
            local newColor = Color3.fromHSV(h, s, v)
            Preview.BackgroundColor3 = newColor
            Saturation.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            callback(newColor)
        end

        local h, s, v = color:ToHSV()
        UpdateColor(h, s, v)
        SaturationSelector.Position = UDim2.new(s, -5, 1 - v, -5)
        HueSelector.Position = UDim2.new(0, 0, h, -1)
        BrightnessSelector.Position = UDim2.new(v, -5, 0, 0)

        Preview.MouseButton1Click:Connect(function()
            ColorPicker.Visible = not ColorPicker.Visible
        end)

        Saturation.MouseButton1Down:Connect(function(x, y)
            local pos = Saturation.AbsolutePosition
            local size = Saturation.AbsoluteSize
            local relX = math.clamp((x - pos.X) / size.X, 0, 1)
            local relY = math.clamp((y - pos.Y) / size.Y, 0, 1)
            s = relX
            v = 1 - relY
            SaturationSelector.Position = UDim2.new(s, -5, v, -5)
            UpdateColor(h, s, v)
        end)

        Hue.MouseButton1Down:Connect(function(x, y)
            local pos = Hue.AbsolutePosition
            local size = Hue.AbsoluteSize
            local relY = math.clamp((y - pos.Y) / size.Y, 0, 1)
            h = relY
            HueSelector.Position = UDim2.new(0, 0, h, -1)
            UpdateColor(h, s, v)
        end)

        Brightness.MouseButton1Down:Connect(function(x, y)
            local pos = Brightness.AbsolutePosition
            local size = Brightness.AbsoluteSize
            local relX = math.clamp((x - pos.X) / size.X, 0, 1)
            v = relX
            BrightnessSelector.Position = UDim2.new(v, -5, 0, 0)
            UpdateColor(h, s, v)
        end)

        table.insert(tab.elements, Picker)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 10 + (#tab.elements * 55))

        return {
            picker = Picker,
            preview = Preview,
            colorPicker = ColorPicker
        }
    end

    local ESPTab = CreateTab("ESP")
    CreateToggle(ESPTab, "Enabled", ESP.enabled, function(state)
        ESP.enabled = state
        UpdateESP()
    end)
    CreateToggle(ESPTab, "Boxes", ESP.boxes, function(state)
        ESP.boxes = state
        UpdateESP()
    end)
    CreateToggle(ESPTab, "Tracers", ESP.tracers, function(state)
        ESP.tracers = state
        UpdateESP()
    end)
    CreateToggle(ESPTab, "Team Check", ESP.teamCheck, function(state)
        ESP.teamCheck = state
        UpdateESP()
    end)
    CreateColorPicker(ESPTab, "Color", ESP.color, function(color)
        ESP.color = color
        UpdateESP()
    end)

    local HitboxTab = CreateTab("Hitbox")
    CreateToggle(HitboxTab, "Enabled", Hitbox.enabled, function(state)
        Hitbox.enabled = state
        UpdateHitboxes()
    end)
    CreateToggle(HitboxTab, "Visible", Hitbox.visible, function(state)
        Hitbox.visible = state
        UpdateHitboxes()
    end)
    CreateSlider(HitboxTab, "Size", 1, Hitbox.maxSize, Hitbox.size, function(value)
        Hitbox.size = value
        UpdateHitboxes()
    end)
    CreateSlider(HitboxTab, "Transparency", 0, 1, Hitbox.transparency * 10, function(value)
        Hitbox.transparency = value / 10
        UpdateHitboxes()
    end)
    CreateColorPicker(HitboxTab, "Color", Hitbox.color, function(color)
        Hitbox.color = color
        UpdateHitboxes()
    end)

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        UI.enabled = false
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        MainFrame.Size = UI.minimizedSize
        TabButtons.Visible = false
        TabContent.Visible = false
        MinimizeButton.Text = "+"

        MinimizeButton.MouseButton1Click:Connect(function()
            MainFrame.Size = UI.size
            TabButtons.Visible = true
            TabContent.Visible = true
            MinimizeButton.Text = "_"
        end)
    end)

    local function DragGUI()
        local Dragging = false
        local DragInput, DragStart, StartPos

        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                DragStart = input.Position
                StartPos = MainFrame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        Header.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                local Delta = input.Position - DragStart
                MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
            end
        end)
    end

    DragGUI()
end

local function Init()
    CreateGUI()

    Players.PlayerAdded:Connect(function(player)
        if ESP.enabled then
            player.CharacterAdded:Connect(function(character)
                CreateESP(player)
            end)
        end
        if Hitbox.enabled then
            player.CharacterAdded:Connect(function(character)
                CreateHitbox(character)
            end)
        end
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if ESP.enabled then
                if player.Character then
                    CreateESP(player)
                else
                    player.CharacterAdded:Connect(function(character)
                        CreateESP(player)
                    end)
                end
            end
            if Hitbox.enabled then
                if player.Character then
                    CreateHitbox(player.Character)
                else
                    player.CharacterAdded:Connect(function(character)
                        CreateHitbox(character)
                    end)
                end
            end
        end
    end
end

Init()