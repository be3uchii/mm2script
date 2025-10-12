local function CleanupExistingGUI()
    local existingGui = game:GetService("CoreGui"):FindFirstChild("AimBotGUI")
    if existingGui then existingGui:Destroy() end
end

CleanupExistingGUI()

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimBotGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0, 10, 0.5, -90)
Frame.Size = UDim2.new(0, 70, 0, 200)
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel")
title.Parent = Frame
title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
title.Size = UDim2.new(1, 0, 0, 25)
title.Font = Enum.Font.GothamBold
title.Text = "AIM"
title.TextColor3 = Color3.fromRGB(220, 220, 255)
title.TextSize = 14

local toggle = Instance.new("TextButton")
toggle.Name = "toggle"
toggle.Parent = Frame
toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
toggle.Position = UDim2.new(0, 5, 0, 35)
toggle.Size = UDim2.new(1, -10, 0, 40)
toggle.Font = Enum.Font.GothamBold
toggle.Text = "OFF"
toggle.TextColor3 = Color3.fromRGB(255, 80, 80)
toggle.TextSize = 16

local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Name = "SpeedToggle"
SpeedToggle.Parent = Frame
SpeedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
SpeedToggle.Position = UDim2.new(0, 5, 0, 85)
SpeedToggle.Size = UDim2.new(1, -10, 0, 30)
SpeedToggle.Font = Enum.Font.Gotham
SpeedToggle.Text = "SPEED: OFF"
SpeedToggle.TextColor3 = Color3.fromRGB(255, 80, 80)
SpeedToggle.TextSize = 12

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = Frame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
MinimizeButton.Position = UDim2.new(0, 5, 1, -25)
MinimizeButton.Size = UDim2.new(1, -10, 0, 20)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(220, 220, 255)
MinimizeButton.TextSize = 14

-- Core Variables
local players = game:GetService("Players")
local plr = players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

local silentaim = false
local speedBoost = false
local minimized = false
local isAlive = true
local targetPart = nil
local connections = {}
local recentDamagers = {}

local baseWalkSpeed = 16
local boostedWalkSpeed = 24
local maxDistance = 1000
local cooldown = 0.1

-- Optimized Functions
local function CleanupConnections()
    for _, conn in pairs(connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    connections = {}
end

local function IsVisible(part)
    if not part or not plr.Character or not isAlive then return false end
    
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local ray = Ray.new(root.Position, (part.Position - root.Position).Unit * maxDistance)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {plr.Character})
    
    return hit and hit:IsDescendantOf(part.Parent)
end

local function GetBestTarget()
    if not isAlive then return nil end
    
    local bestTarget, bestPriority = nil, -math.huge
    
    for _, enemy in pairs(players:GetPlayers()) do
        if enemy == plr or not enemy.Character then continue end
        
        local humanoid = enemy.Character:FindFirstChildOfClass("Humanoid")
        local rootPart = enemy.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and humanoid.Health > 0 and rootPart and IsVisible(rootPart) then
            local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
            local priority = (recentDamagers[enemy] and 1000 or 0) + (maxDistance - distance)
            
            if priority > bestPriority then
                bestPriority = priority
                bestTarget = enemy
                targetPart = rootPart
            end
        end
    end
    
    return bestTarget
end

-- Toggle Functions
local function ToggleAimBot()
    silentaim = not silentaim
    toggle.Text = silentaim and "ON" or "OFF"
    toggle.TextColor3 = silentaim and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    toggle.BackgroundColor3 = silentaim and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(80, 40, 40)
end

local function ToggleSpeedBoost()
    speedBoost = not speedBoost
    SpeedToggle.Text = speedBoost and "SPEED: ON" or "SPEED: OFF"
    SpeedToggle.TextColor3 = speedBoost and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    
    if plr.Character then
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedBoost and boostedWalkSpeed or baseWalkSpeed
        end
    end
end

local function ToggleMinimize()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 70, 0, 25) or UDim2.new(0, 70, 0, 200)
    local targetPos = minimized and UDim2.new(0, 5, 0, 0) or UDim2.new(0, 5, 1, -25)
    
    Frame.Size = targetSize
    toggle.Visible = not minimized
    SpeedToggle.Visible = not minimized
    MinimizeButton.Position = targetPos
    MinimizeButton.Text = minimized and "+" or "-"
end

-- Core Logic
local function AimBotFunction()
    if not silentaim or not isAlive then return end
    
    local target = GetBestTarget()
    if target and targetPart then
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPart.Position)
    end
end

local function ProcessDamage(attacker)
    if not attacker or not isAlive then return end
    
    local attackerPlayer = players:GetPlayerFromCharacter(attacker)
    if attackerPlayer and attackerPlayer ~= plr then
        recentDamagers[attackerPlayer] = true
        task.delay(5, function() recentDamagers[attackerPlayer] = nil end)
    end
end

local function SetupCharacter(character)
    isAlive = true
    local humanoid = character:WaitForChild("Humanoid")
    
    humanoid.WalkSpeed = speedBoost and boostedWalkSpeed or baseWalkSpeed
    
    table.insert(connections, humanoid.Died:Connect(function()
        isAlive = false
        targetPart = nil
    end))
end

-- Initialization
local function Initialize()
    CleanupConnections()
    
    table.insert(connections, toggle.MouseButton1Click:Connect(ToggleAimBot))
    table.insert(connections, SpeedToggle.MouseButton1Click:Connect(ToggleSpeedBoost))
    table.insert(connections, MinimizeButton.MouseButton1Click:Connect(ToggleMinimize))
    table.insert(connections, runService.Heartbeat:Connect(AimBotFunction))
    
    if plr.Character then
        SetupCharacter(plr.Character)
    end
    
    table.insert(connections, plr.CharacterAdded:Connect(SetupCharacter))
end

Initialize()