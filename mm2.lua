-- Murder Mystery 2 Script by DeepSeek Chat
-- Features: FOV Circle, Aim Assist, ESP
-- All features disabled by default

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings (all disabled by default)
local settings = {
    FOV = {
        Enabled = false,
        Size = 100,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.5,
        Thickness = 2,
        Filled = false
    },
    Aim = {
        Enabled = false,
        Target = "Murderer", -- "Murderer" or "Sheriff"
        Smoothness = 0.2,
        Keybind = Enum.UserInputType.MouseButton2 -- Right mouse button
    },
    ESP = {
        Enabled = false,
        MurdererColor = Color3.fromRGB(255, 0, 0),
        SheriffColor = Color3.fromRGB(0, 0, 255),
        PlayerColor = Color3.fromRGB(0, 255, 0),
        Transparency = 0.7,
        Thickness = 1
    }
}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2Hax"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false -- Hidden by default
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 150, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MM2 Script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = TitleBar

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(1, -50, 1, -50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "Menu"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = ScreenGui

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = settings.FOV.Size
FOVCircle.Color = settings.FOV.Color
FOVCircle.Transparency = settings.FOV.Transparency
FOVCircle.Thickness = settings.FOV.Thickness
FOVCircle.Filled = settings.FOV.Filled
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- ESP Boxes storage
local ESPBoxes = {}

-- Function to check if player is murderer
local function isMurderer(player)
    local character = player.Character
    if not character then return false end
    local knife = character:FindFirstChild("Knife") or character:FindFirstChild("KnifeClient")
    return knife ~= nil
end

-- Function to check if player is sheriff
local function isSheriff(player)
    local character = player.Character
    if not character then return false end
    local gun = character:FindFirstChild("Gun") or character:FindFirstChild("GunClient")
    return gun ~= nil
end

-- Function to create ESP box
local function createESP(player)
    if ESPBoxes[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = settings.ESP.PlayerColor
    box.Thickness = settings.ESP.Thickness
    box.Filled = false
    box.Transparency = settings.ESP.Transparency
    box.ZIndex = 1
    
    ESPBoxes[player] = box
end

-- Function to update ESP boxes
local function updateESP()
    if not settings.ESP.Enabled then return end
    
    for player, box in pairs(ESPBoxes) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local head = character:FindFirstChild("Head")
            
            if rootPart and head then
                local rootPos, rootVis = Camera:WorldToViewportPoint(rootPart.Position)
                local headPos = Camera:WorldToViewportPoint(head.Position)
                
                if rootVis then
                    local size = Vector2.new(2000 / rootPos.Z, headPos.Y - rootPos.Y)
                    local position = Vector2.new(rootPos.X - size.X / 2, rootPos.Y - size.Y / 2)
                    
                    box.Size = size
                    box.Position = position
                    box.Visible = true
                    
                    -- Set color based on role
                    if isMurderer(player) then
                        box.Color = settings.ESP.MurdererColor
                    elseif isSheriff(player) then
                        box.Color = settings.ESP.SheriffColor
                    else
                        box.Color = settings.ESP.PlayerColor
                    end
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end

-- Function to clear ESP boxes
local function clearESP()
    for player, box in pairs(ESPBoxes) do
        if box then
            box:Remove()
        end
    end
    ESPBoxes = {}
end

-- Function to find target for aim assist
local function findTarget()
    if not settings.Aim.Enabled then return nil end
    
    local target = nil
    local closestDist = settings.FOV.Size
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                -- Check if player matches target type
                local isTarget = false
                if settings.Aim.Target == "Murderer" and isMurderer(player) then
                    isTarget = true
                elseif settings.Aim.Target == "Sheriff" and isSheriff(player) then
                    isTarget = true
                end
                
                if isTarget then
                    local screenPos = Camera:WorldToViewportPoint(rootPart.Position)
                    if screenPos.Z > 0 then -- On screen
                        local mousePos = UserInputService:GetMouseLocation()
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        -- Check if within FOV
                        if settings.FOV.Enabled and dist > settings.FOV.Size then
                            continue
                        end
                        
                        if dist < closestDist then
                            closestDist = dist
                            target = rootPart
                        end
                    end
                end
            end
        end
    end
    
    return target
end

-- Aim assist function
local function aimAssist()
    if not settings.Aim.Enabled then return end
    if not UserInputService:IsMouseButtonPressed(settings.Aim.Keybind) then return end
    
    local target = findTarget()
    if target then
        local camera = workspace.CurrentCamera
        local targetPos = target.Position
        local cameraPos = camera.CFrame.Position
        
        -- Calculate direction to target
        local direction = (targetPos - cameraPos).Unit
        
        -- Smooth the aim
        local currentLook = camera.CFrame.LookVector
        local newLook = currentLook:Lerp(direction, settings.Aim.Smoothness)
        
        -- Set new camera CFrame
        camera.CFrame = CFrame.new(cameraPos, cameraPos + newLook)
    end
end

-- Check if target is in FOV for hit registration
local function isInFOV(target)
    if not settings.FOV.Enabled then return true end
    
    local screenPos = Camera:WorldToViewportPoint(target.Position)
    if screenPos.Z > 0 then
        local mousePos = UserInputService:GetMouseLocation()
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        return dist <= settings.FOV.Size
    end
    return false
end

-- Create UI controls
local function createCheckbox(name, text, position, parent, settingTable, settingKey)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = position
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local checkbox = Instance.new("TextButton")
    checkbox.Name = "Checkbox"
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(0, 0, 0.5, -10)
    checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    checkbox.BorderSizePixel = 0
    checkbox.Text = ""
    checkbox.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 25, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local function updateCheckbox()
        checkbox.BackgroundColor3 = settingTable[settingKey] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end
    
    updateCheckbox()
    
    checkbox.MouseButton1Click:Connect(function()
        settingTable[settingKey] = not settingTable[settingKey]
        updateCheckbox()
    end)
    
    return frame
end

local function createSlider(name, text, position, parent, settingTable, settingKey, min, max)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = position
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(settingTable[settingKey])
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Name = "Slider"
    slider.Size = UDim2.new(1, 0, 0, 5)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((settingTable[settingKey] - min) / (max - min), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(0, 15, 0, 15)
    button.Position = UDim2.new(fill.Size.X.Scale, -7.5, 0.5, -7.5)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = frame
    
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
            local xPos = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
            xPos = math.clamp(xPos, 0, 1)
            
            local value = min + (max - min) * xPos
            settingTable[settingKey] = math.floor(value)
            
            fill.Size = UDim2.new(xPos, 0, 1, 0)
            button.Position = UDim2.new(xPos, -7.5, 0.5, -7.5)
            label.Text = text .. ": " .. tostring(settingTable[settingKey])
        end
    end)
    
    return frame
end

local function createDropdown(name, text, position, parent, settingTable, settingKey, options)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = position
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Name = "Dropdown"
    dropdown.Size = UDim2.new(1, 0, 0, 25)
    dropdown.Position = UDim2.new(0, 0, 0, 25)
    dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropdown.BorderSizePixel = 0
    dropdown.Text = settingTable[settingKey]
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Parent = frame
    
    local list = Instance.new("Frame")
    list.Name = "List"
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 0, 50)
    list.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    list.BorderSizePixel = 0
    list.Visible = false
    list.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Name = "Layout"
    layout.Parent = list
    
    local function updateList()
        list:ClearAllChildren()
        
        for _, option in pairs(options) do
            local button = Instance.new("TextButton")
            button.Name = option
            button.Size = UDim2.new(1, 0, 0, 25)
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            button.BorderSizePixel = 0
            button.Text = option
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Parent = list
            
            button.MouseButton1Click:Connect(function()
                settingTable[settingKey] = option
                dropdown.Text = option
                list.Visible = false
                list.Size = UDim2.new(1, 0, 0, 0)
            end)
        end
        
        list.Size = UDim2.new(1, 0, 0, #options * 25)
    end
    
    dropdown.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
        if list.Visible then
            updateList()
        else
            list.Size = UDim2.new(1, 0, 0, 0)
        end
    end)
    
    return frame
end

-- Create tabs
local TabButtons = {}
local TabFrames = {}

local function createTab(name, text)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "TabButton"
    tabButton.Size = UDim2.new(0.33, -1, 0, 30)
    tabButton.Position = UDim2.new(#TabButtons * 0.33, 0, 0, 30)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabButton.BorderSizePixel = 0
    tabButton.Text = text
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Parent = MainFrame
    
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = name .. "TabFrame"
    tabFrame.Size = UDim2.new(1, 0, 1, -60)
    tabFrame.Position = UDim2.new(0, 0, 0, 60)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = #TabButtons == 0
    tabFrame.Parent = MainFrame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scroll"
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.Position = UDim2.new(0, 0, 0, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 5
    scroll.Parent = tabFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Name = "Layout"
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    
    tabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(TabFrames) do
            frame.Visible = false
        end
        tabFrame.Visible = true
        
        for _, button in pairs(TabButtons) do
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
        tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    table.insert(TabButtons, tabButton)
    table.insert(TabFrames, tabFrame)
    
    return scroll
end

-- Create tabs and controls
local fovTab = createTab("FOV", "FOV")
local aimTab = createTab("Aim", "Aim")
local espTab = createTab("ESP", "ESP")

-- FOV Tab
createCheckbox("FOVEnabled", "Enable FOV", UDim2.new(0, 0, 0, 0), fovTab, settings.FOV, "Enabled")
createSlider("FOVSize", "FOV Size", UDim2.new(0, 0, 0, 30), fovTab, settings.FOV, "Size", 50, 500)
createSlider("FOVThickness", "FOV Thickness", UDim2.new(0, 0, 0, 80), fovTab, settings.FOV, "Thickness", 1, 10)
createCheckbox("FOVFilled", "Filled FOV", UDim2.new(0, 0, 0, 130), fovTab, settings.FOV, "Filled")

-- Aim Tab
createCheckbox("AimEnabled", "Enable Aim Assist", UDim2.new(0, 0, 0, 0), aimTab, settings.Aim, "Enabled")
createDropdown("AimTarget", "Target", UDim2.new(0, 0, 0, 30), aimTab, settings.Aim, "Target", {"Murderer", "Sheriff"})
createSlider("AimSmoothness", "Smoothness", UDim2.new(0, 0, 0, 80), aimTab, settings.Aim, "Smoothness", 0.1, 1)

-- ESP Tab
createCheckbox("ESPEnabled", "Enable ESP", UDim2.new(0, 0, 0, 0), espTab, settings.ESP, "Enabled")
createSlider("ESPThickness", "ESP Thickness", UDim2.new(0, 0, 0, 30), espTab, settings.ESP, "Thickness", 1, 5)

-- UI Controls
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Size = UDim2.new(0, 250, 0, 30)
    for _, frame in pairs(TabFrames) do
        frame.Visible = false
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Main loop
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    FOVCircle.Visible = settings.FOV.Enabled
    FOVCircle.Radius = settings.FOV.Size
    FOVCircle.Color = settings.FOV.Color
    FOVCircle.Transparency = settings.FOV.Transparency
    FOVCircle.Thickness = settings.FOV.Thickness
    FOVCircle.Filled = settings.FOV.Filled
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- Update ESP
    if settings.ESP.Enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end
        updateESP()
    else
        clearESP()
    end
    
    -- Aim assist
    aimAssist()
end)

-- Player added/removed events
Players.PlayerAdded:Connect(function(player)
    if settings.ESP.Enabled then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
end)

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and settings.ESP.Enabled then
        createESP(player)
    end
end

-- Hook for hit registration (this is a simplified version)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and tostring(self) == "HitPart" then
        local target = args[1]
        if target and target:IsA("BasePart") and target.Parent then
            local character = target.Parent
            if character:FindFirstChild("Humanoid") then
                if not isInFOV(target) then
                    return nil -- Block the hit if not in FOV
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Notify user
LocalPlayer:SetAttribute("MM2ScriptLoaded", true)
print("MM2 Script loaded! Press the Menu button to open settings.")