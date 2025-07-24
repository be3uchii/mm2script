local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local library = {
    enabled = false,
    dragging = false,
    dragInput = nil,
    dragStart = nil,
    dragPos = nil,
    tabs = {},
    currentTab = nil,
    colors = {
        background = Color3.fromRGB(30, 30, 40),
        header = Color3.fromRGB(25, 25, 35),
        tab = Color3.fromRGB(40, 40, 50),
        button = Color3.fromRGB(50, 50, 60),
        buttonHover = Color3.fromRGB(60, 60, 70),
        text = Color3.fromRGB(255, 255, 255),
        accent = Color3.fromRGB(0, 120, 215)
    }
}

local esp = {
    enabled = false,
    names = false,
    boxes = false,
    tracers = false,
    color = Color3.fromRGB(255, 0, 0),
    teamCheck = true
}

local hitbox = {
    enabled = false,
    size = 1,
    maxSize = 7,
    color = Color3.fromRGB(255, 0, 0),
    transparency = 0.5,
    visible = false,
    parts = {"Head", "HumanoidRootPart", "LeftHand", "RightHand", "LeftLowerLeg", "RightLowerLeg"}
}

local misc = {
    noClip = false,
    speed = false,
    speedValue = 20,
    jumpPower = false,
    jumpValue = 50,
    antiAfk = false
}

local function createHitbox(character)
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    for _, partName in ipairs(hitbox.parts) do
        local part = character:FindFirstChild(partName)
        if part then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "Hitbox"
            box.Adornee = part
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Size = part.Size * hitbox.size
            box.Transparency = hitbox.transparency
            box.Color3 = hitbox.color
            box.Visible = hitbox.visible and hitbox.enabled
            box.Parent = part
        end
    end
end

local function updateHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part:FindFirstChild("Hitbox") then
                    part.Hitbox:Destroy()
                end
            end
            if hitbox.enabled then
                createHitbox(player.Character)
            end
        end
    end
end

local function createEsp(player)
    if not player or player == LocalPlayer then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local holder = Instance.new("Folder")
    holder.Name = player.Name
    holder.Parent = Camera
    
    if esp.names then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "Name"
        billboard.Adornee = character:WaitForChild("Head")
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = player.Name
        text.TextColor3 = esp.color
        text.TextScaled = true
        text.Font = Enum.Font.SourceSansBold
        text.Parent = billboard
        
        billboard.Parent = holder
    end
    
    if esp.boxes then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "Box"
        box.Adornee = character:WaitForChild("HumanoidRootPart")
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Size = character:WaitForChild("HumanoidRootPart").Size * 2
        box.Transparency = 0.7
        box.Color3 = esp.color
        box.Parent = holder
    end
    
    if esp.tracers then
        local beam = Instance.new("Beam")
        beam.Name = "Tracer"
        beam.Attachment0 = Instance.new("Attachment")
        beam.Attachment0.Parent = character:WaitForChild("HumanoidRootPart")
        beam.Attachment1 = Instance.new("Attachment")
        beam.Attachment1.Parent = Camera:WaitForChild("HumanoidRootPart")
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.Color = ColorSequence.new(esp.color)
        beam.Parent = holder
    end
    
    character:WaitForChild("Humanoid").Died:Connect(function()
        holder:Destroy()
    end)
end

local function updateEsp()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Camera:FindFirstChild(player.Name) then
                Camera[player.Name]:Destroy()
            end
            if esp.enabled and (not esp.teamCheck or player.Team ~= LocalPlayer.Team) then
                if player.Character then
                    createEsp(player)
                else
                    player.CharacterAdded:Connect(function(character)
                        createEsp(player)
                    end)
                end
            end
        end
    end
end

local function noClip()
    if not LocalPlayer.Character then return end
    
    local function update()
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = not misc.noClip
            end
        end
    end
    
    update()
    LocalPlayer.CharacterAdded:Connect(update)
end

local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MVSD_Hub"
    screenGui.Parent = game:GetService("CoreGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Main"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = library.colors.background
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = library.colors.header
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "MVSD Hub"
    title.TextColor3 = library.colors.text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "Close"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -30, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = library.colors.text
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 14
    closeButton.Parent = header
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "Minimize"
    minimizeButton.Size = UDim2.new(0, 20, 0, 20)
    minimizeButton.Position = UDim2.new(1, -55, 0, 5)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = library.colors.text
    minimizeButton.Font = Enum.Font.SourceSansBold
    minimizeButton.TextSize = 14
    minimizeButton.Parent = header
    
    local tabButtons = Instance.new("Frame")
    tabButtons.Name = "TabButtons"
    tabButtons.Size = UDim2.new(0, 100, 1, -30)
    tabButtons.Position = UDim2.new(0, 0, 0, 30)
    tabButtons.BackgroundColor3 = library.colors.tab
    tabButtons.BorderSizePixel = 0
    tabButtons.Parent = mainFrame
    
    local tabContent = Instance.new("Frame")
    tabContent.Name = "TabContent"
    tabContent.Size = UDim2.new(1, -100, 1, -30)
    tabContent.Position = UDim2.new(0, 100, 0, 30)
    tabContent.BackgroundTransparency = 1
    tabContent.Parent = mainFrame
    
    local function createTab(name)
        local tab = {
            name = name,
            button = nil,
            frame = nil,
            elements = {}
        }
        
        tab.button = Instance.new("TextButton")
        tab.button.Name = name
        tab.button.Size = UDim2.new(1, -10, 0, 30)
        tab.button.Position = UDim2.new(0, 5, 0, 5 + (#library.tabs * 35))
        tab.button.BackgroundColor3 = library.colors.button
        tab.button.BorderSizePixel = 0
        tab.button.Text = name
        tab.button.TextColor3 = library.colors.text
        tab.button.Font = Enum.Font.SourceSans
        tab.button.TextSize = 16
        tab.button.Parent = tabButtons
        
        tab.frame = Instance.new("ScrollingFrame")
        tab.frame.Name = name
        tab.frame.Size = UDim2.new(1, 0, 1, 0)
        tab.frame.Position = UDim2.new(0, 0, 0, 0)
        tab.frame.BackgroundTransparency = 1
        tab.frame.Visible = false
        tab.frame.ScrollBarThickness = 5
        tab.frame.CanvasSize = UDim2.new(0, 0, 0, 0)
        tab.frame.Parent = tabContent
        
        table.insert(library.tabs, tab)
        
        if #library.tabs == 1 then
            library.currentTab = tab
            tab.button.BackgroundColor3 = library.colors.accent
            tab.frame.Visible = true
        end
        
        tab.button.MouseButton1Click:Connect(function()
            for _, t in ipairs(library.tabs) do
                t.button.BackgroundColor3 = library.colors.button
                t.frame.Visible = false
            end
            tab.button.BackgroundColor3 = library.colors.accent
            tab.frame.Visible = true
            library.currentTab = tab
        end)
        
        return tab
    end
    
    local function createToggle(tab, text, state, callback)
        local toggle = Instance.new("Frame")
        toggle.Name = text
        toggle.Size = UDim2.new(1, -20, 0, 30)
        toggle.Position = UDim2.new(0, 10, 0, 10 + (#tab.elements * 35))
        toggle.BackgroundTransparency = 1
        toggle.Parent = tab.frame
        
        local button = Instance.new("TextButton")
        button.Name = "Button"
        button.Size = UDim2.new(0, 20, 0, 20)
        button.Position = UDim2.new(0, 0, 0, 5)
        button.BackgroundColor3 = state and library.colors.accent or library.colors.button
        button.BorderSizePixel = 0
        button.Text = ""
        button.Parent = toggle
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -30, 1, 0)
        label.Position = UDim2.new(0, 25, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = library.colors.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.Parent = toggle
        
        button.MouseButton1Click:Connect(function()
            state = not state
            button.BackgroundColor3 = state and library.colors.accent or library.colors.button
            callback(state)
        end)
        
        table.insert(tab.elements, toggle)
        tab.frame.CanvasSize = UDim2.new(0, 0, 0, 10 + (#tab.elements * 35))
        
        return {
            toggle = toggle,
            button = button,
            label = label
        }
    end
    
    local function createSlider(tab, text, min, max, value, callback)
        local slider = Instance.new("Frame")
        slider.Name = text
        slider.Size = UDim2.new(1, -20, 0, 50)
        slider.Position = UDim2.new(0, 10, 0, 10 + (#tab.elements * 55))
        slider.BackgroundTransparency = 1
        slider.Parent = tab.frame
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. value
        label.TextColor3 = library.colors.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.Parent = slider
        
        local track = Instance.new("Frame")
        track.Name = "Track"
        track.Size = UDim2.new(1, 0, 0, 5)
        track.Position = UDim2.new(0, 0, 0, 25)
        track.BackgroundColor3 = library.colors.button
        track.BorderSizePixel = 0
        track.Parent = slider
        
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        fill.Position = UDim2.new(0, 0, 0, 0)
        fill.BackgroundColor3 = library.colors.accent
        fill.BorderSizePixel = 0
        fill.Parent = track
        
        local button = Instance.new("TextButton")
        button.Name = "Button"
        button.Size = UDim2.new(0, 15, 0, 15)
        button.Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7)
        button.BackgroundColor3 = library.colors.text
        button.BorderSizePixel = 0
        button.Text = ""
        button.Parent = slider
        
        local dragging = false
        
        button.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                pos = math.clamp(pos, 0, 1)
                local newValue = math.floor(min + (max - min) * pos)
                if newValue ~= value then
                    value = newValue
                    label.Text = text .. ": " .. value
                    fill.Size = UDim2.new(pos, 0, 1, 0)
                    button.Position = UDim2.new(pos, -7, 0.5, -7)
                    callback(value)
                end
            end
        end)
        
        table.insert(tab.elements, slider)
        tab.frame.CanvasSize = UDim2.new(0, 0, 0, 10 + (#tab.elements * 55))
        
        return {
            slider = slider,
            label = label,
            track = track,
            fill = fill,
            button = button
        }
    end
    
    local function createColorPicker(tab, text, color, callback)
        local picker = Instance.new("Frame")
        picker.Name = text
        picker.Size = UDim2.new(1, -20, 0, 50)
        picker.Position = UDim2.new(0, 10, 0, 10 + (#tab.elements * 55))
        picker.BackgroundTransparency = 1
        picker.Parent = tab.frame
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -60, 0, 20)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = library.colors.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.Parent = picker
        
        local preview = Instance.new("Frame")
        preview.Name = "Preview"
        preview.Size = UDim2.new(0, 50, 0, 50)
        preview.Position = UDim2.new(1, -50, 0, 0)
        preview.BackgroundColor3 = color
        preview.BorderSizePixel = 0
        preview.Parent = picker
        
        local colorPicker = Instance.new("Frame")
        colorPicker.Name = "ColorPicker"
        colorPicker.Size = UDim2.new(0, 200, 0, 200)
        colorPicker.Position = UDim2.new(0.5, -100, 0, 60)
        colorPicker.BackgroundColor3 = library.colors.background
        colorPicker.BorderSizePixel = 0
        colorPicker.Visible = false
        colorPicker.Parent = picker
        
        local saturation = Instance.new("ImageLabel")
        saturation.Name = "Saturation"
        saturation.Size = UDim2.new(1, -40, 1, -40)
        saturation.Position = UDim2.new(0, 20, 0, 20)
        saturation.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
        saturation.BorderSizePixel = 0
        saturation.Image = "rbxassetid://4155801252"
        saturation.Parent = colorPicker
        
        local hue = Instance.new("ImageLabel")
        hue.Name = "Hue"
        hue.Size = UDim2.new(0, 20, 1, -40)
        hue.Position = UDim2.new(1, -20, 0, 20)
        hue.BorderSizePixel = 0
        hue.Image = "rbxassetid://3570695787"
        hue.Parent = colorPicker
        
        local brightness = Instance.new("Frame")
        brightness.Name = "Brightness"
        brightness.Size = UDim2.new(1, -40, 0, 20)
        brightness.Position = UDim2.new(0, 20, 1, -20)
        brightness.BackgroundColor3 = Color3.new(0, 0, 0)
        brightness.BorderSizePixel = 0
        brightness.Parent = colorPicker
        
        local brightnessGradient = Instance.new("UIGradient")
        brightnessGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
        })
        brightnessGradient.Rotation = 0
        brightnessGradient.Parent = brightness
        
        local saturationSelector = Instance.new("Frame")
        saturationSelector.Name = "SaturationSelector"
        saturationSelector.Size = UDim2.new(0, 10, 0, 10)
        saturationSelector.Position = UDim2.new(0.5, -5, 0.5, -5)
        saturationSelector.BackgroundColor3 = Color3.new(1, 1, 1)
        saturationSelector.BorderColor3 = Color3.new(0, 0, 0)
        saturationSelector.BorderSizePixel = 1
        saturationSelector.Parent = saturation
        
        local hueSelector = Instance.new("Frame")
        hueSelector.Name = "HueSelector"
        hueSelector.Size = UDim2.new(1, 0, 0, 2)
        hueSelector.Position = UDim2.new(0, 0, 0, 0)
        hueSelector.BackgroundColor3 = Color3.new(1, 1, 1)
        hueSelector.BorderColor3 = Color3.new(0, 0, 0)
        hueSelector.BorderSizePixel = 1
        hueSelector.Parent = hue
        
        local brightnessSelector = Instance.new("Frame")
        brightnessSelector.Name = "BrightnessSelector"
        brightnessSelector.Size = UDim2.new(0, 10, 1, 0)
        brightnessSelector.Position = UDim2.new(0.5, -5, 0, 0)
        brightnessSelector.BackgroundColor3 = Color3.new(1, 1, 1)
        brightnessSelector.BorderColor3 = Color3.new(0, 0, 0)
        brightnessSelector.BorderSizePixel = 1
        brightnessSelector.Visible = false
        brightnessSelector.Parent = brightness
        
        local function updateColor(h, s, v)
            local newColor = Color3.fromHSV(h, s, v)
            preview.BackgroundColor3 = newColor
            saturation.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            callback(newColor)
        end
        
        local h, s, v = color:ToHSV()
        updateColor(h, s, v)
        saturationSelector.Position = UDim2.new(s, -5, 1 - v, -5)
        hueSelector.Position = UDim2.new(0, 0, h, -1)
        brightnessSelector.Position = UDim2.new(v, -5, 0, 0)
        
        preview.MouseButton1Click:Connect(function()
            colorPicker.Visible = not colorPicker.Visible
        end)
        
        saturation.MouseButton1Down:Connect(function(x, y)
            local pos = saturation.AbsolutePosition
            local size = saturation.AbsoluteSize
            local relX = math.clamp((x - pos.X) / size.X, 0, 1)
            local relY = math.clamp((y - pos.Y) / size.Y, 0, 1)
            s = relX
            v = 1 - relY
            saturationSelector.Position = UDim2.new(s, -5, v, -5)
            updateColor(h, s, v)
        end)
        
        hue.MouseButton1Down:Connect(function(x, y)
            local pos = hue.AbsolutePosition
            local size = hue.AbsoluteSize
            local relY = math.clamp((y - pos.Y) / size.Y, 0, 1)
            h = relY
            hueSelector.Position = UDim2.new(0, 0, h, -1)
            updateColor(h, s, v)
        end)
        
        brightness.MouseButton1Down:Connect(function(x, y)
            local pos = brightness.AbsolutePosition
            local size = brightness.AbsoluteSize
            local relX = math.clamp((x - pos.X) / size.X, 0, 1)
            v = relX
            brightnessSelector.Position = UDim2.new(v, -5, 0, 0)
            updateColor(h, s, v)
        end)
        
        table.insert(tab.elements, picker)
        tab.frame.CanvasSize = UDim2.new(0, 0, 0, 10 + (#tab.elements * 55))
        
        return {
            picker = picker,
            preview = preview,
            colorPicker = colorPicker
        }
    end
    
    local espTab = createTab("ESP")
    createToggle(espTab, "Enabled", esp.enabled, function(state)
        esp.enabled = state
        updateEsp()
    end)
    createToggle(espTab, "Names", esp.names, function(state)
        esp.names = state
        updateEsp()
    end)
    createToggle(espTab, "Boxes", esp.boxes, function(state)
        esp.boxes = state
        updateEsp()
    end)
    createToggle(espTab, "Tracers", esp.tracers, function(state)
        esp.tracers = state
        updateEsp()
    end)
    createToggle(espTab, "Team Check", esp.teamCheck, function(state)
        esp.teamCheck = state
        updateEsp()
    end)
    createColorPicker(espTab, "Color", esp.color, function(color)
        esp.color = color
        updateEsp()
    end)
    
    local hitboxTab = createTab("Hitbox")
    createToggle(hitboxTab, "Enabled", hitbox.enabled, function(state)
        hitbox.enabled = state
        updateHitboxes()
    end)
    createToggle(hitboxTab, "Visible", hitbox.visible, function(state)
        hitbox.visible = state
        updateHitboxes()
    end)
    createSlider(hitboxTab, "Size", 1, hitbox.maxSize, hitbox.size, function(value)
        hitbox.size = value
        updateHitboxes()
    end)
    createSlider(hitboxTab, "Transparency", 0, 1, hitbox.transparency * 10, function(value)
        hitbox.transparency = value / 10
        updateHitboxes()
    end)
    createColorPicker(hitboxTab, "Color", hitbox.color, function(color)
        hitbox.color = color
        updateHitboxes()
    end)
    
    local miscTab = createTab("Misc")
    createToggle(miscTab, "No Clip", misc.noClip, function(state)
        misc.noClip = state
        noClip()
    end)
    createToggle(miscTab, "Speed", misc.speed, function(state)
        misc.speed = state
        if state then
            LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = misc.speedValue
        else
            LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 16
        end
    end)
    createSlider(miscTab, "Speed Value", 16, 100, misc.speedValue, function(value)
        misc.speedValue = value
        if misc.speed then
            LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = value
        end
    end)
    createToggle(miscTab, "Jump Power", misc.jumpPower, function(state)
        misc.jumpPower = state
        if state then
            LocalPlayer.Character:WaitForChild("Humanoid").JumpPower = misc.jumpValue
        else
            LocalPlayer.Character:WaitForChild("Humanoid").JumpPower = 50
        end
    end)
    createSlider(miscTab, "Jump Value", 50, 200, misc.jumpValue, function(value)
        misc.jumpValue = value
        if misc.jumpPower then
            LocalPlayer.Character:WaitForChild("Humanoid").JumpPower = value
        end
    end)
    createToggle(miscTab, "Anti AFK", misc.antiAfk, function(state)
        misc.antiAfk = state
        if state then
            local vu = game:GetService("VirtualUser")
            game:GetService("Players").LocalPlayer.Idled:connect(function()
                vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                wait(1)
                vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            end)
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        library.enabled = false
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        mainFrame.Size = UDim2.new(0, 400, 0, 30)
        tabButtons.Visible = false
        tabContent.Visible = false
        minimizeButton.Text = "+"
        
        minimizeButton.MouseButton1Click:Connect(function()
            mainFrame.Size = UDim2.new(0, 400, 0, 500)
            tabButtons.Visible = true
            tabContent.Visible = true
            minimizeButton.Text = "_"
        end)
    end)
    
    library.enabled = true
end

local function init()
    createGui()
    
    Players.PlayerAdded:Connect(function(player)
        if esp.enabled then
            player.CharacterAdded:Connect(function(character)
                createEsp(player)
            end)
        end
        if hitbox.enabled then
            player.CharacterAdded:Connect(function(character)
                createHitbox(character)
            end)
        end
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if esp.enabled then
                if player.Character then
                    createEsp(player)
                else
                    player.CharacterAdded:Connect(function(character)
                        createEsp(player)
                    end)
                end
            end
            if hitbox.enabled then
                if player.Character then
                    createHitbox(player.Character)
                else
                    player.CharacterAdded:Connect(function(character)
                        createHitbox(character)
                    end)
                end
            end
        end
    end
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        if misc.noClip then
            noClip()
        end
        if misc.speed then
            character:WaitForChild("Humanoid").WalkSpeed = misc.speedValue
        end
        if misc.jumpPower then
            character:WaitForChild("Humanoid").JumpPower = misc.jumpValue
        end
    end)
end

init()