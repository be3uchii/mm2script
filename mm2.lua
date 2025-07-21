local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local GuiService = game:GetService("GuiService")

local settings = {
    FOV = {
        Включено = false,
        Размер = 120,
        Цвет = Color3.fromRGB(255, 255, 255),
        Прозрачность = 0.7,
        Толщина = 2,
        Заполнен = false
    },
    AIM = {
        Включено = false,
        Цель = "Убийца",
        Плавность = 0.3,
        Клавиша = Enum.UserInputType.MouseButton2
    },
    ESP = {
        Включено = false,
        ЦветУбийцы = Color3.fromRGB(255, 0, 0),
        ЦветШерифа = Color3.fromRGB(0, 0, 255),
        ЦветИгрока = Color3.fromRGB(0, 255, 0),
        Прозрачность = 0.8,
        Толщина = 2
    }
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2Script"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MM2 АИМ+ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
MinimizeButton.Position = UDim2.new(1, -70, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "─"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(1, -65, 1, -65)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "МЕНЮ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = settings.FOV.Размер
FOVCircle.Color = settings.FOV.Цвет
FOVCircle.Transparency = settings.FOV.Прозрачность
FOVCircle.Thickness = settings.FOV.Толщина
FOVCircle.Filled = settings.FOV.Заполнен
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

local ESPBoxes = {}

local function isMurderer(player)
    if not player.Character then return false end
    local knife = player.Character:FindFirstChild("Knife") or player.Character:FindFirstChild("KnifeClient")
    return knife ~= nil
end

local function isSheriff(player)
    if not player.Character then return false end
    local gun = player.Character:FindFirstChild("Gun") or player.Character:FindFirstChild("GunClient")
    return gun ~= nil
end

local function hasWeapon()
    if not LocalPlayer.Character then return false end
    local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("GunClient")
    local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("KnifeClient")
    return gun ~= nil or knife ~= nil
end

local function createESP(player)
    if ESPBoxes[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = settings.ESP.ЦветИгрока
    box.Thickness = settings.ESP.Толщина
    box.Filled = false
    box.Transparency = settings.ESP.Прозрачность
    box.ZIndex = 1
    
    ESPBoxes[player] = box
end

local function updateESP()
    if not settings.ESP.Включено then 
        for _, box in pairs(ESPBoxes) do
            box.Visible = false
        end
        return 
    end
    
    for player, box in pairs(ESPBoxes) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            
            if rootPart and head then
                local rootPos, rootVis = Camera:WorldToViewportPoint(rootPart.Position)
                local headPos = Camera:WorldToViewportPoint(head.Position)
                
                if rootVis then
                    local size = Vector2.new(2000 / rootPos.Z, headPos.Y - rootPos.Y)
                    local position = Vector2.new(rootPos.X - size.X / 2, rootPos.Y - size.Y / 2)
                    
                    box.Size = size
                    box.Position = position
                    box.Visible = true
                    
                    if isMurderer(player) then
                        box.Color = settings.ESP.ЦветУбийцы
                    elseif isSheriff(player) then
                        box.Color = settings.ESP.ЦветШерифа
                    else
                        box.Color = settings.ESP.ЦветИгрока
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

local function clearESP()
    for player, box in pairs(ESPBoxes) do
        if box then
            box:Remove()
        end
    end
    ESPBoxes = {}
end

local function findTarget()
    if not settings.AIM.Включено then return nil end
    
    local target = nil
    local closestDist = settings.FOV.Размер
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local isTarget = false
                if settings.AIM.Цель == "Убийца" and isMurderer(player) then
                    isTarget = true
                elseif settings.AIM.Цель == "Шериф" and isSheriff(player) then
                    isTarget = true
                end
                
                if isTarget then
                    local screenPos = Camera:WorldToViewportPoint(rootPart.Position)
                    if screenPos.Z > 0 then
                        local mousePos = UserInputService:GetMouseLocation()
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        if settings.FOV.Включено and dist > settings.FOV.Размер then
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

local function aimAssist()
    if not settings.AIM.Включено then return end
    if not UserInputService:IsMouseButtonPressed(settings.AIM.Клавиша) then return end
    
    local target = findTarget()
    if target then
        local targetPos = target.Position
        local cameraPos = Camera.CFrame.Position
        
        local direction = (targetPos - cameraPos).Unit
        local currentLook = Camera.CFrame.LookVector
        local newLook = currentLook:Lerp(direction, settings.AIM.Плавность)
        
        Camera.CFrame = CFrame.new(cameraPos, cameraPos + newLook)
    end
end

local function isInFOV(target)
    if not settings.FOV.Включено then return true end
    if not target then return false end
    
    local screenPos = Camera:WorldToViewportPoint(target.Position)
    if screenPos.Z > 0 then
        local mousePos = UserInputService:GetMouseLocation()
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        return dist <= settings.FOV.Размер
    end
    return false
end

local function getTargetInFOV()
    if not settings.FOV.Включено then return nil end
    if not hasWeapon() then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local isTarget = false
                
                if isMurderer(LocalPlayer) and not isMurderer(player) then
                    isTarget = true
                elseif isSheriff(LocalPlayer) and isMurderer(player) then
                    isTarget = true
                end
                
                if isTarget and isInFOV(rootPart) then
                    return rootPart
                end
            end
        end
    end
    
    return nil
end

local function createCheckbox(name, text, pos, parent, settingTable, settingKey)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.Position = pos
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local checkbox = Instance.new("TextButton")
    checkbox.Name = "Checkbox"
    checkbox.Size = UDim2.new(0, 25, 0, 25)
    checkbox.Position = UDim2.new(0, 0, 0.5, -12)
    checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    checkbox.BorderSizePixel = 0
    checkbox.Text = ""
    checkbox.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 35, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local function updateCheckbox()
        if settingTable[settingKey] then
            checkbox.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            checkbox.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end
    end
    
    updateCheckbox()
    
    checkbox.MouseButton1Click:Connect(function()
        settingTable[settingKey] = not settingTable[settingKey]
        updateCheckbox()
    end)
    
    return frame
end

local function createSlider(name, text, pos, parent, settingTable, settingKey, min, max)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, -20, 0, 60)
    frame.Position = pos
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(settingTable[settingKey])
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Name = "Slider"
    slider.Size = UDim2.new(1, 0, 0, 8)
    slider.Position = UDim2.new(0, 0, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((settingTable[settingKey] - min) / (max - min), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(0, 20, 0, 20)
    button.Position = UDim2.new(fill.Size.X.Scale, -10, 0.5, -10)
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
            
            local value = math.floor(min + (max - min) * xPos)
            settingTable[settingKey] = value
            
            fill.Size = UDim2.new(xPos, 0, 1, 0)
            button.Position = UDim2.new(xPos, -10, 0.5, -10)
            label.Text = text .. ": " .. tostring(value)
            
            if name:find("FOV") then
                FOVCircle.Radius = value
            end
        end
    end)
    
    return frame
end

local function createDropdown(name, text, pos, parent, settingTable, settingKey, options)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, -20, 0, 70)
    frame.Position = pos
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Name = "Dropdown"
    dropdown.Size = UDim2.new(1, 0, 0, 30)
    dropdown.Position = UDim2.new(0, 0, 0, 30)
    dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    dropdown.BorderSizePixel = 0
    dropdown.Text = settingTable[settingKey]
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Font = Enum.Font.Gotham
    dropdown.Parent = frame
    
    local list = Instance.new("ScrollingFrame")
    list.Name = "List"
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 0, 65)
    list.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 5
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
            button.Size = UDim2.new(1, -5, 0, 30)
            button.Position = UDim2.new(0, 0, 0, 0)
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
            button.BorderSizePixel = 0
            button.Text = option
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Font = Enum.Font.Gotham
            button.Parent = list
            
            button.MouseButton1Click:Connect(function()
                settingTable[settingKey] = option
                dropdown.Text = option
                list.Visible = false
                list.Size = UDim2.new(1, 0, 0, 0)
            end)
        end
        
        list.CanvasSize = UDim2.new(0, 0, 0, #options * 35)
        list.Size = UDim2.new(1, 0, 0, math.min(#options * 35, 150))
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

local TabButtons = {}
local TabFrames = {}

local function createTab(name, text)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "TabButton"
    tabButton.Size = UDim2.new(0.33, -2, 0, 35)
    tabButton.Position = UDim2.new(#TabButtons * 0.33, 0, 0, 35)
    tabButton.BackgroundColor3 = #TabButtons == 0 and Color3.fromRGB(60, 60, 70) or Color3.fromRGB(40, 40, 50)
    tabButton.BorderSizePixel = 0
    tabButton.Text = text
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Font = Enum.Font.GothamBold
    tabButton.Parent = MainFrame
    
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = name .. "TabFrame"
    tabFrame.Size = UDim2.new(1, 0, 1, -70)
    tabFrame.Position = UDim2.new(0, 0, 0, 70)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = #TabButtons == 0
    tabFrame.ScrollBarThickness = 5
    tabFrame.Parent = MainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Name = "Layout"
    layout.Padding = UDim.new(0, 10)
    layout.Parent = tabFrame
    
    tabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(TabFrames) do
            frame.Visible = false
        end
        tabFrame.Visible = true
        
        for _, button in pairs(TabButtons) do
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end
        tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end)
    
    table.insert(TabButtons, tabButton)
    table.insert(TabFrames, tabFrame)
    
    return tabFrame
end

local fovTab = createTab("FOV", "FOV")
local aimTab = createTab("AIM", "АИМ")
local espTab = createTab("ESP", "ESP")

createCheckbox("FOVEnabled", "Включить FOV", UDim2.new(0, 0, 0, 0), fovTab, settings.FOV, "Включено")
createSlider("FOVSize", "Размер FOV", UDim2.new(0, 0, 0, 40), fovTab, settings.FOV, "Размер", 50, 300)
createSlider("FOVThickness", "Толщина FOV", UDim2.new(0, 0, 0, 110), fovTab, settings.FOV, "Толщина", 1, 10)
createCheckbox("FOVFilled", "Заполненный FOV", UDim2.new(0, 0, 0, 180), fovTab, settings.FOV, "Заполнен")

createCheckbox("AimEnabled", "Включить АИМ", UDim2.new(0, 0, 0, 0), aimTab, settings.AIM, "Включено")
createDropdown("AimTarget", "Цель АИМ", UDim2.new(0, 0, 0, 50), aimTab, settings.AIM, "Цель", {"Убийца", "Шериф"})
createSlider("AimSmoothness", "Плавность АИМ", UDim2.new(0, 0, 0, 130), aimTab, settings.AIM, "Плавность", 0.1, 1)

createCheckbox("ESPEnabled", "Включить ESP", UDim2.new(0, 0, 0, 0), espTab, settings.ESP, "Включено")
createSlider("ESPThickness", "Толщина ESP", UDim2.new(0, 0, 0, 50), espTab, settings.ESP, "Толщина", 1, 5)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

MinimizeButton.MouseButton1Click:Connect(function()
    if MainFrame.Size.Y.Offset == 35 then
        MainFrame.Size = UDim2.new(0, 350, 0, 400)
        for _, frame in pairs(TabFrames) do
            frame.Visible = frame.Name == TabFrames[1].Name
        end
    else
        MainFrame.Size = UDim2.new(0, 350, 0, 35)
        for _, frame in pairs(TabFrames) do
            frame.Visible = false
        end
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and (tostring(self) == "HitPart" or tostring(self) == "KnifeHit") then
        local target = args[1]
        if target and target:IsA("BasePart") and target.Parent then
            local character = target.Parent
            if character:FindFirstChild("Humanoid") then
                if settings.FOV.Включено and hasWeapon() then
                    local targetInFOV = getTargetInFOV()
                    if targetInFOV and targetInFOV.Parent == character then
                        return oldNamecall(self, ...)
                    else
                        return nil
                    end
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = settings.FOV.Включено
    FOVCircle.Radius = settings.FOV.Размер
    FOVCircle.Color = settings.FOV.Цвет
    FOVCircle.Transparency = settings.FOV.Прозрачность
    FOVCircle.Thickness = settings.FOV.Толщина
    FOVCircle.Filled = settings.FOV.Заполнен
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    if settings.ESP.Включено then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end
        updateESP()
    else
        clearESP()
    end
    
    aimAssist()
end)

Players.PlayerAdded:Connect(function(player)
    if settings.ESP.Включено then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and settings.ESP.Включено then
        createESP(player)
    end
end

LocalPlayer:SetAttribute("MM2ScriptLoaded", true)