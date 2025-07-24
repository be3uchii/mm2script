local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
    boxes = false,
    tracers = false,
    color = Color3.fromRGB(255, 0, 0)
}

local hitbox = {
    enabled = false,
    size = 1,
    maxSize = 7,
    color = Color3.fromRGB(255, 0, 0),
    transparency = 0.5,
    visible = false,
    parts = {"HumanoidRootPart"}
}

local misc = {
    noClip = false
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
            if esp.enabled and player.Team ~= LocalPlayer.Team then
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
    mainFrame.Size = UDim2.new(0, 300, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
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
    tabButtons.Size = UDim2.new(0, 80, 1, -30)
    tabButtons.Position = UDim2.new(0, 0, 0, 30)
    tabButtons.BackgroundColor3 = library.colors.tab
    tabButtons.BorderSizePixel = 0
    tabButtons.Parent = mainFrame
    
    local tabContent = Instance.new("Frame")
    tabContent.Name = "TabContent"
    tabContent.Size = UDim2.new(1, -80, 1, -30)
    tabContent.Position = UDim2.new(0, 80, 0, 30)
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
    end
    
    local function createColorPicker(tab, text, color, callback)
        local picker = Instance.new("Frame")
        picker.Name = text
        picker.Size = UDim2.new(1, -20, 0, 30)
        picker.Position = UDim2.new(0, 10, 0, 10 + (#tab.elements * 35))
        picker.BackgroundTransparency = 1
        picker.Parent = tab.frame
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = library.colors.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.Parent = picker
        
        local preview = Instance.new("TextButton")
        preview.Name = "Preview"
        preview.Size = UDim2.new(0, 50, 0, 20)
        preview.Position = UDim2.new(1, -50, 0, 5)
        preview.BackgroundColor3 = color
        preview.BorderSizePixel = 0
        preview.Text = ""
        preview.Parent = picker
        
        local colors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(0, 0, 0)
        }
        
        local colorIndex = 1
        for i, c in ipairs(colors) do
            if c == color then
                colorIndex = i
                break
            end
        end
        
        preview.MouseButton1Click:Connect(function()
            colorIndex = colorIndex + 1
            if colorIndex > #colors then
                colorIndex = 1
            end
            local newColor = colors[colorIndex]
            preview.BackgroundColor3 = newColor
            callback(newColor)
        end)
        
        table.insert(tab.elements, picker)
        tab.frame.CanvasSize = UDim2.new(0, 0, 0, 10 + (#tab.elements * 35))
    end
    
    local espTab = createTab("ESP")
    createToggle(espTab, "Enabled", esp.enabled, function(state)
        esp.enabled = state
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
    createSlider(hitboxTab, "Transparency", 0, 10, hitbox.transparency * 10, function(value)
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
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        library.enabled = false
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        if mainFrame.Size.Y.Offset == 30 then
            mainFrame.Size = UDim2.new(0, 300, 0, 350)
            tabButtons.Visible = true
            tabContent.Visible = true
            minimizeButton.Text = "_"
        else
            mainFrame.Size = UDim2.new(0, 300, 0, 30)
            tabButtons.Visible = false
            tabContent.Visible = false
            minimizeButton.Text = "+"
        end
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
            if esp.enabled and player.Team ~= LocalPlayer.Team then
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
    end)
end

init()