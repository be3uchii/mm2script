local function CleanupExistingGUI()
    local coreGui = game:GetService("CoreGui")
    local existingGui = coreGui:FindFirstChild("AimBotGUI")
    if existingGui then
        existingGui:Destroy()
    end
end

CleanupExistingGUI()

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local plr = players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local runService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local DragHandle = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local ToggleAimButton = Instance.new("TextButton")
local SpeedButton = Instance.new("TextButton")
local HitboxButton = Instance.new("TextButton")
local StatusIndicator = Instance.new("Frame")
local StatusLabel = Instance.new("TextLabel")
local FOVIndicator = Instance.new("Frame")
local FOVLabel = Instance.new("TextLabel")
local HitboxSizeLabel = Instance.new("TextLabel")
local Tooltip = Instance.new("Frame")
local TooltipText = Instance.new("TextLabel")

ScreenGui.Name = "AimBotGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 280)
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(100, 150, 255)
UIStroke.Parent = MainFrame

TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 30)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

DragHandle.Parent = TitleBar
DragHandle.BackgroundTransparency = 1
DragHandle.Size = UDim2.new(1, -60, 1, 0)

TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Aim Assistant"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

MinimizeButton.Parent = TitleBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -55, 0, 5)
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeButton

ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 35)
ContentFrame.Size = UDim2.new(1, 0, 1, -35)

StatusIndicator.Parent = ContentFrame
StatusIndicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
StatusIndicator.BorderSizePixel = 0
StatusIndicator.Position = UDim2.new(0, 10, 0, 10)
StatusIndicator.Size = UDim2.new(0, 12, 0, 12)

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusIndicator

StatusLabel.Parent = ContentFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 30, 0, 8)
StatusLabel.Size = UDim2.new(1, -40, 0, 16)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

ToggleAimButton.Parent = ContentFrame
ToggleAimButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
ToggleAimButton.BorderSizePixel = 0
ToggleAimButton.Position = UDim2.new(0, 10, 0, 35)
ToggleAimButton.Size = UDim2.new(1, -20, 0, 40)
ToggleAimButton.Font = Enum.Font.GothamBold
ToggleAimButton.Text = "TOGGLE AIM"
ToggleAimButton.TextColor3 = Color3.fromRGB(255, 60, 60)
ToggleAimButton.TextSize = 14

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleAimButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 1
ToggleStroke.Color = Color3.fromRGB(80, 120, 200)
ToggleStroke.Parent = ToggleAimButton

SpeedButton.Parent = ContentFrame
SpeedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
SpeedButton.BorderSizePixel = 0
SpeedButton.Position = UDim2.new(0, 10, 0, 85)
SpeedButton.Size = UDim2.new(1, -20, 0, 35)
SpeedButton.Font = Enum.Font.Gotham
SpeedButton.Text = "SPEED: OFF"
SpeedButton.TextColor3 = Color3.fromRGB(255, 60, 60)
SpeedButton.TextSize = 12

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedButton

local SpeedStroke = Instance.new("UIStroke")
SpeedStroke.Thickness = 1
SpeedStroke.Color = Color3.fromRGB(80, 120, 200)
SpeedStroke.Parent = SpeedButton

HitboxButton.Parent = ContentFrame
HitboxButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
HitboxButton.BorderSizePixel = 0
HitboxButton.Position = UDim2.new(0, 10, 0, 130)
HitboxButton.Size = UDim2.new(1, -20, 0, 35)
HitboxButton.Font = Enum.Font.Gotham
HitboxButton.Text = "HITBOX SIZE: NORMAL"
HitboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxButton.TextSize = 12

local HitboxCorner = Instance.new("UICorner")
HitboxCorner.CornerRadius = UDim.new(0, 6)
HitboxCorner.Parent = HitboxButton

local HitboxStroke = Instance.new("UIStroke")
HitboxStroke.Thickness = 1
HitboxStroke.Color = Color3.fromRGB(80, 120, 200)
HitboxStroke.Parent = HitboxButton

FOVIndicator.Parent = ContentFrame
FOVIndicator.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
FOVIndicator.BorderSizePixel = 0
FOVIndicator.Position = UDim2.new(0, 10, 0, 180)
FOVIndicator.Size = UDim2.new(0, 150, 0, 6)

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVIndicator

FOVLabel.Parent = ContentFrame
FOVLabel.BackgroundTransparency = 1
FOVLabel.Position = UDim2.new(0, 10, 0, 190)
FOVLabel.Size = UDim2.new(1, -20, 0, 20)
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.Text = "FOV: 120°"
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.TextSize = 11
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left

HitboxSizeLabel.Parent = ContentFrame
HitboxSizeLabel.BackgroundTransparency = 1
HitboxSizeLabel.Position = UDim2.new(0, 10, 0, 215)
HitboxSizeLabel.Size = UDim2.new(1, -20, 0, 20)
HitboxSizeLabel.Font = Enum.Font.Gotham
HitboxSizeLabel.Text = "HITBOX: 1.0x"
HitboxSizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxSizeLabel.TextSize = 11
HitboxSizeLabel.TextXAlignment = Enum.TextXAlignment.Left

Tooltip.Parent = ScreenGui
Tooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Tooltip.BorderSizePixel = 0
Tooltip.Size = UDim2.new(0, 180, 0, 40)
Tooltip.Visible = false
Tooltip.ZIndex = 10

local TooltipCorner = Instance.new("UICorner")
TooltipCorner.CornerRadius = UDim.new(0, 6)
TooltipCorner.Parent = Tooltip

local TooltipStroke = Instance.new("UIStroke")
TooltipStroke.Thickness = 1
TooltipStroke.Color = Color3.fromRGB(100, 150, 255)
TooltipStroke.Parent = Tooltip

TooltipText.Parent = Tooltip
TooltipText.BackgroundTransparency = 1
TooltipText.Size = UDim2.new(1, 0, 1, 0)
TooltipText.Font = Enum.Font.Gotham
TooltipText.Text = "Tooltip information"
TooltipText.TextColor3 = Color3.fromRGB(255, 255, 255)
TooltipText.TextSize = 12
TooltipText.TextWrapped = true

local silentaim = false
local speedBoost = false
local connections = {}
local isAlive = true
local targetPart = nil
local maxDistance = 1000
local fov = 120
local baseWalkSpeed = 16
local boostedWalkSpeed = 24
local hitboxMultiplier = 1.0
local hitboxSizes = {0.5, 1.0, 1.5, 2.0, 3.0}
local currentHitboxIndex = 2
local minimized = false
local uiHidden = false
local recentDamagers = {}

local function TweenObject(obj, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

local function PulseButton(button)
    TweenObject(button, {BackgroundColor3 = Color3.fromRGB(60, 80, 120)}, 0.1)
    task.wait(0.1)
    TweenObject(button, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}, 0.1)
end

local function UpdateTooltip(text, position)
    Tooltip.Text = text
    Tooltip.Position = UDim2.new(0, position.X, 0, position.Y - 50)
    Tooltip.Visible = true
    
    local textSize = TooltipText.TextBounds
    Tooltip.Size = UDim2.new(0, math.max(180, textSize.X + 20), 0, textSize.Y + 20)
end

local function HideTooltip()
    Tooltip.Visible = false
end

local function CleanupConnections()
    for _, v in pairs(connections) do
        if v and v.Disconnect then
            v:Disconnect()
        end
    end
    connections = {}
end

local function IsVisible(part)
    if not part or not plr.Character or not isAlive then return false end
    
    local humanoidRootPart = plr.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local origin = humanoidRootPart.Position
    local direction = (part.Position - origin).Unit * maxDistance
    local ray = Ray.new(origin, direction)
    
    local ignoreList = {plr.Character}
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    return hit and hit:IsDescendantOf(part.Parent)
end

local function GetBestTarget()
    if not isAlive then return nil end
    
    local closestTarget = nil
    local closestDistance = math.huge
    local highestPriority = -1
    
    for _, enemy in pairs(players:GetPlayers()) do
        if enemy ~= plr and enemy.Character then
            local humanoid = enemy.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = enemy.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart and IsVisible(rootPart) then
                local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
                local priority = 0
                
                if recentDamagers[enemy] then
                    priority = priority + 1000
                end
                
                priority = priority + (maxDistance - distance)
                
                if priority > highestPriority or (priority == highestPriority and distance < closestDistance) then
                    highestPriority = priority
                    closestDistance = distance
                    closestTarget = enemy
                    targetPart = rootPart
                end
            end
        end
    end
    
    return closestTarget
end

local function ToggleAimBot()
    silentaim = not silentaim
    
    if silentaim then
        TweenObject(ToggleAimButton, {TextColor3 = Color3.fromRGB(60, 255, 100)}, 0.2)
        TweenObject(StatusIndicator, {BackgroundColor3 = Color3.fromRGB(60, 255, 100)}, 0.2)
        TweenObject(ToggleAimButton, {BackgroundColor3 = Color3.fromRGB(30, 60, 40)}, 0.2)
        StatusLabel.Text = "Status: ON"
        
        local glow = Instance.new("Frame")
        glow.Name = "GlowEffect"
        glow.BackgroundColor3 = Color3.fromRGB(60, 255, 100)
        glow.BackgroundTransparency = 0.7
        glow.Size = UDim2.new(1, 0, 1, 0)
        glow.ZIndex = -1
        
        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(0, 6)
        glowCorner.Parent = glow
        
        glow.Parent = ToggleAimButton
        
        TweenObject(glow, {BackgroundTransparency = 1}, 0.5):Wait()
        glow:Destroy()
    else
        TweenObject(ToggleAimButton, {TextColor3 = Color3.fromRGB(255, 60, 60)}, 0.2)
        TweenObject(StatusIndicator, {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}, 0.2)
        TweenObject(ToggleAimButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}, 0.2)
        StatusLabel.Text = "Status: OFF"
    end
    
    PulseButton(ToggleAimButton)
end

local function ToggleSpeedBoost()
    speedBoost = not speedBoost
    
    if speedBoost then
        TweenObject(SpeedButton, {TextColor3 = Color3.fromRGB(60, 255, 100)}, 0.2)
        TweenObject(SpeedButton, {BackgroundColor3 = Color3.fromRGB(30, 60, 40)}, 0.2)
        SpeedButton.Text = "SPEED: ON"
    else
        TweenObject(SpeedButton, {TextColor3 = Color3.fromRGB(255, 60, 60)}, 0.2)
        TweenObject(SpeedButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}, 0.2)
        SpeedButton.Text = "SPEED: OFF"
    end
    
    if plr.Character then
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedBoost and boostedWalkSpeed or baseWalkSpeed
        end
    end
    
    PulseButton(SpeedButton)
end

local function ChangeHitboxSize()
    currentHitboxIndex = currentHitboxIndex + 1
    if currentHitboxIndex > #hitboxSizes then
        currentHitboxIndex = 1
    end
    
    hitboxMultiplier = hitboxSizes[currentHitboxIndex]
    
    local sizeText = ""
    if hitboxMultiplier == 0.5 then
        sizeText = "SMALL"
    elseif hitboxMultiplier == 1.0 then
        sizeText = "NORMAL"
    elseif hitboxMultiplier == 1.5 then
        sizeText = "LARGE"
    elseif hitboxMultiplier == 2.0 then
        sizeText = "HUGE"
    else
        sizeText = "MAX"
    end
    
    HitboxButton.Text = "HITBOX SIZE: " .. sizeText
    HitboxSizeLabel.Text = "HITBOX: " .. hitboxMultiplier .. "x"
    
    TweenObject(HitboxButton, {BackgroundColor3 = Color3.fromRGB(60, 60, 100)}, 0.1)
    task.wait(0.1)
    TweenObject(HitboxButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}, 0.1)
end

local function ToggleMinimize()
    minimized = not minimized
    
    if minimized then
        TweenObject(MainFrame, {Size = UDim2.new(0, 200, 0, 35)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenObject(MinimizeButton, {BackgroundColor3 = Color3.fromRGB(60, 255, 100)}, 0.2)
        MinimizeButton.Text = "+"
    else
        TweenObject(MainFrame, {Size = UDim2.new(0, 200, 0, 280)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenObject(MinimizeButton, {BackgroundColor3 = Color3.fromRGB(255, 180, 60)}, 0.2)
        MinimizeButton.Text = "-"
    end
    
    PulseButton(MinimizeButton)
end

local function ToggleUI()
    uiHidden = not uiHidden
    
    if uiHidden then
        TweenObject(MainFrame, {BackgroundTransparency = 1}, 0.3)
        TweenObject(UIStroke, {Transparency = 1}, 0.3)
        
        for _, child in ipairs(MainFrame:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                TweenObject(child, {TextTransparency = 1}, 0.3)
            elseif child:IsA("Frame") and child ~= MainFrame then
                TweenObject(child, {BackgroundTransparency = 1}, 0.3)
            end
        end
    else
        TweenObject(MainFrame, {BackgroundTransparency = 0}, 0.3)
        TweenObject(UIStroke, {Transparency = 0}, 0.3)
        
        for _, child in ipairs(MainFrame:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                TweenObject(child, {TextTransparency = 0}, 0.3)
            elseif child:IsA("Frame") and child ~= MainFrame then
                TweenObject(child, {BackgroundTransparency = 0}, 0.3)
            end
        end
    end
end

local function CloseGUI()
    TweenObject(MainFrame, {Size = UDim2.new(0, 200, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In):Wait()
    TweenObject(MainFrame, {BackgroundTransparency = 1}, 0.2):Wait()
    ScreenGui:Destroy()
    CleanupConnections()
end

local function AimBotFunction()
    if not silentaim or not isAlive then return end
    
    local target = GetBestTarget()
    if target and targetPart then
        local modifiedPosition = targetPart.Position + Vector3.new(0, 1.5 * hitboxMultiplier, 0)
        camera.CFrame = CFrame.new(camera.CFrame.Position, modifiedPosition)
    end
end

local function ProcessDamage(attacker)
    if not attacker or not isAlive then return end
    
    local attackerPlayer = players:GetPlayerFromCharacter(attacker)
    if attackerPlayer and attackerPlayer ~= plr then
        recentDamagers[attackerPlayer] = true
        
        task.delay(5, function()
            recentDamagers[attackerPlayer] = nil
        end)
    end
end

local function HookNamecall()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if not silentaim or not isAlive then return oldNamecall(self, ...) end
        
        local args = {...}
        local method = getnamecallmethod()
        
        if tostring(self) == "HitPart" and method == "FireServer" then
            local target = GetBestTarget()
            if target and targetPart then
                args[1] = targetPart
                args[2] = targetPart.Position
                return self.FireServer(self, unpack(args))
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    table.insert(connections, {
        Disconnect = function()
            if oldNamecall then
                setmetatable(game, {__namecall = oldNamecall})
            end
        end
    })
end

local function SetupCharacter(character)
    isAlive = true
    local humanoid = character:WaitForChild("Humanoid")
    
    humanoid.Touched:Connect(function(hit)
        if not hit or not hit.Parent then return end
        
        local attacker = players:GetPlayerFromCharacter(hit.Parent)
        if not attacker then
            attacker = players:GetPlayerFromCharacter(hit.Parent.Parent)
        end
        
        if attacker and attacker ~= plr then
            ProcessDamage(hit.Parent)
        end
    end)
    
    humanoid.WalkSpeed = speedBoost and boostedWalkSpeed or baseWalkSpeed
    
    table.insert(connections, humanoid.Died:Connect(function()
        isAlive = false
        targetPart = nil
    end))
    
    table.insert(connections, humanoid.HealthChanged:Connect(function(health)
        if health < humanoid.MaxHealth then
            for _, player in pairs(players:GetPlayers()) do
                if player ~= plr and player.Character then
                    ProcessDamage(player.Character)
                end
            end
        end
    end))
end

local function Initialize()
    CleanupConnections()
    
    table.insert(connections, ToggleAimButton.MouseButton1Click:Connect(ToggleAimBot))
    table.insert(connections, SpeedButton.MouseButton1Click:Connect(ToggleSpeedBoost))
    table.insert(connections, HitboxButton.MouseButton1Click:Connect(ChangeHitboxSize))
    table.insert(connections, MinimizeButton.MouseButton1Click:Connect(ToggleMinimize))
    table.insert(connections, CloseButton.MouseButton1Click:Connect(CloseGUI))
    table.insert(connections, runService.Heartbeat:Connect(AimBotFunction))
    
    ToggleAimButton.MouseEnter:Connect(function()
        UpdateTooltip("Toggle silent aim functionality", ToggleAimButton.AbsolutePosition)
    end)
    
    SpeedButton.MouseEnter:Connect(function()
        UpdateTooltip("Toggle speed boost ("..baseWalkSpeed.." -> "..boostedWalkSpeed..")", SpeedButton.AbsolutePosition)
    end)
    
    HitboxButton.MouseEnter:Connect(function()
        UpdateTooltip("Cycle through hitbox sizes (0.5x to 3.0x)", HitboxButton.AbsolutePosition)
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        UpdateTooltip("Minimize/expand the menu", MinimizeButton.AbsolutePosition)
    end)
    
    CloseButton.MouseEnter:Connect(function()
        UpdateTooltip("Close the menu", CloseButton.AbsolutePosition)
    end)
    
    ToggleAimButton.MouseLeave:Connect(HideTooltip)
    SpeedButton.MouseLeave:Connect(HideTooltip)
    HitboxButton.MouseLeave:Connect(HideTooltip)
    MinimizeButton.MouseLeave:Connect(HideTooltip)
    CloseButton.MouseLeave:Connect(HideTooltip)
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    DragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            TweenObject(MainFrame, {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}, 0.1)
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    TweenObject(MainFrame, {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}, 0.1)
                end
            end)
        end
    end)
    
    DragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightShift then
            ToggleUI()
        end
    end)
    
    if plr.Character then
        SetupCharacter(plr.Character)
    end
    
    table.insert(connections, plr.CharacterAdded:Connect(function(character)
        SetupCharacter(character)
    end))
    
    HookNamecall()
    
    TweenObject(MainFrame, {Position = UDim2.new(0.1, 0, 0.3, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

Initialize()