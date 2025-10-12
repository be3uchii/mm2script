local function CleanupExistingGUI()
    local coreGui = game:GetService("CoreGui")
    local existingGui = coreGui:FindFirstChild("AimBotGUI")
    if existingGui then
        existingGui:Destroy()
    end
end

CleanupExistingGUI()

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local toggle = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")
local SpeedToggle = Instance.new("TextButton")

ScreenGui.Name = "AimBotGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(187, 244, 255)
Frame.Position = UDim2.new(0, 0, 0.445328146, 0)
Frame.Size = UDim2.new(0, 63, 0, 180)
Frame.Active = true
Frame.Draggable = true

toggle.Name = "toggle"
toggle.Parent = Frame
toggle.BackgroundColor3 = Color3.fromRGB(165, 213, 255)
toggle.Position = UDim2.new(0, 0, 0.328767121, 0)
toggle.Size = UDim2.new(0, 63, 0, 50)
toggle.Font = Enum.Font.SourceSans
toggle.Text = "OFF"
toggle.TextColor3 = Color3.fromRGB(248, 43, 29)
toggle.TextScaled = true
toggle.TextSize = 14.000
toggle.TextWrapped = true

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(165, 201, 255)
TextLabel.Size = UDim2.new(0, 63, 0, 33)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "AimBot"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = Frame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(165, 201, 255)
MinimizeButton.Position = UDim2.new(0, 0, 0.8, 0)
MinimizeButton.Size = UDim2.new(0, 63, 0, 25)
MinimizeButton.Font = Enum.Font.SourceSans
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextScaled = true
MinimizeButton.TextSize = 14.000
MinimizeButton.TextWrapped = true

SpeedToggle.Name = "SpeedToggle"
SpeedToggle.Parent = Frame
SpeedToggle.BackgroundColor3 = Color3.fromRGB(165, 213, 255)
SpeedToggle.Position = UDim2.new(0, 0, 0.6, 0)
SpeedToggle.Size = UDim2.new(0, 63, 0, 25)
SpeedToggle.Font = Enum.Font.SourceSans
SpeedToggle.Text = "SPD: OFF"
SpeedToggle.TextColor3 = Color3.fromRGB(248, 43, 29)
SpeedToggle.TextScaled = true
SpeedToggle.TextSize = 14.000
SpeedToggle.TextWrapped = true

-- Сервисы и переменные
local players = game:GetService("Players")
local plr = players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- Настройки
local silentaim = false
local speedBoost = false
local connections = {}
local lastAttacker = nil
local lastAttackTime = 0
local minimized = false
local isAlive = true
local targetPart = nil
local maxDistance = 1000
local fov = 120
local baseWalkSpeed = 16
local boostedWalkSpeed = 20
local recentDamagers = {}
local targetCache = {}
local lastCacheUpdate = 0
local cacheUpdateInterval = 0.1

-- Кэшированные вычисления
local math_huge = math.huge
local CFrame_new = CFrame.new
local Vector3_new = Vector3.new
local Ray_new = Ray.new
local os_time = os.time
local table_insert = table.insert
local Color3_fromRGB = Color3.fromRGB

-- Оптимизированные функции
local function CleanupConnections()
    for i = 1, #connections do
        local v = connections[i]
        if v and v.Disconnect then
            v:Disconnect()
        end
    end
    connections = {}
end

local function UpdateTargetCache()
    local currentTime = os_time()
    if currentTime - lastCacheUpdate < cacheUpdateInterval then
        return
    end
    
    lastCacheUpdate = currentTime
    targetCache = {}
    
    if not isAlive or not plr.Character then return end
    
    local character = plr.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local cameraPosition = camera.CFrame.Position
    local playersList = players:GetPlayers()
    
    for i = 1, #playersList do
        local enemy = playersList[i]
        if enemy ~= plr and enemy.Character then
            local enemyCharacter = enemy.Character
            local humanoid = enemyCharacter:FindFirstChildOfClass("Humanoid")
            local rootPart = enemyCharacter:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (rootPart.Position - cameraPosition).Magnitude
                if distance <= maxDistance then
                    local priority = 0
                    
                    if recentDamagers[enemy] then
                        priority = priority + 1000
                    end
                    
                    priority = priority + (maxDistance - distance)
                    
                    targetCache[#targetCache + 1] = {
                        player = enemy,
                        rootPart = rootPart,
                        distance = distance,
                        priority = priority
                    }
                end
            end
        end
    end
end

local function IsVisible(part)
    if not part or not plr.Character or not isAlive then return false end
    
    local humanoidRootPart = plr.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local origin = humanoidRootPart.Position
    local direction = (part.Position - origin).Unit * maxDistance
    local ray = Ray_new(origin, direction)
    
    local ignoreList = {plr.Character}
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    return hit and hit:IsDescendantOf(part.Parent)
end

local function GetBestTarget()
    if not isAlive then return nil end
    
    UpdateTargetCache()
    
    local closestTarget = nil
    local closestDistance = math_huge
    local highestPriority = -1
    
    for i = 1, #targetCache do
        local targetData = targetCache[i]
        if IsVisible(targetData.rootPart) then
            if targetData.priority > highestPriority or 
               (targetData.priority == highestPriority and targetData.distance < closestDistance) then
                highestPriority = targetData.priority
                closestDistance = targetData.distance
                closestTarget = targetData.player
                targetPart = targetData.rootPart
            end
        end
    end
    
    return closestTarget
end

local function ToggleAimBot()
    silentaim = not silentaim
    toggle.Text = silentaim and "ON" or "OFF"
    toggle.TextColor3 = silentaim and Color3_fromRGB(136, 255, 0) or Color3_fromRGB(255, 0, 4)
end

local function ToggleSpeedBoost()
    speedBoost = not speedBoost
    SpeedToggle.Text = speedBoost and "SPD: ON" or "SPD: OFF"
    SpeedToggle.TextColor3 = speedBoost and Color3_fromRGB(136, 255, 0) or Color3_fromRGB(255, 0, 4)
    
    if plr.Character then
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedBoost and boostedWalkSpeed or baseWalkSpeed
        end
    end
end

local function ToggleMinimize()
    minimized = not minimized
    if minimized then
        Frame.Size = UDim2.new(0, 63, 0, 33)
        toggle.Visible = false
        SpeedToggle.Visible = false
        MinimizeButton.Position = UDim2.new(0, 0, 0, 0)
        MinimizeButton.Text = "+"
    else
        Frame.Size = UDim2.new(0, 63, 0, 180)
        toggle.Visible = true
        SpeedToggle.Visible = true
        MinimizeButton.Position = UDim2.new(0, 0, 0.85, 0)
        MinimizeButton.Text = "-"
    end
end

local function SmoothAim(targetPosition)
    local currentCFrame = camera.CFrame
    local targetCFrame = CFrame_new(currentCFrame.Position, targetPosition)
    
    -- Плавное перемещение камеры
    local smoothFactor = 0.3
    local newCFrame = currentCFrame:Lerp(targetCFrame, smoothFactor)
    camera.CFrame = newCFrame
end

local function AimBotFunction()
    if not silentaim or not isAlive then return end
    
    local target = GetBestTarget()
    if target and targetPart then
        local targetPosition = targetPart.Position + Vector3_new(0, 1.5, 0)
        SmoothAim(targetPosition)
    end
end

local function ProcessDamage(attacker)
    if not attacker or not isAlive then return end
    
    local attackerPlayer = players:GetPlayerFromCharacter(attacker)
    if attackerPlayer and attackerPlayer ~= plr then
        lastAttacker = attacker
        lastAttackTime = os_time()
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
    
    table_insert(connections, {
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
    
    -- Оптимизированное отслеживание повреждений
    table_insert(connections, humanoid.Touched:Connect(function(hit)
        if not hit or not hit.Parent then return end
        
        local attacker = players:GetPlayerFromCharacter(hit.Parent)
        if not attacker then
            attacker = players:GetPlayerFromCharacter(hit.Parent.Parent)
        end
        
        if attacker and attacker ~= plr then
            ProcessDamage(hit.Parent)
        end
    end))
    
    humanoid.WalkSpeed = speedBoost and boostedWalkSpeed or baseWalkSpeed
    
    table_insert(connections, humanoid.Died:Connect(function()
        isAlive = false
        targetPart = nil
        targetCache = {}
    end))
    
    table_insert(connections, humanoid.HealthChanged:Connect(function(health)
        if health < humanoid.MaxHealth then
            for _, player in pairs(players:GetPlayers()) do
                if player ~= plr and player.Character then
                    ProcessDamage(player.Character)
                end
            end
        end
    end))
end

-- Горячие клавиши
local function SetupHotkeys()
    table_insert(connections, uis.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.X then
            ToggleAimBot()
        elseif input.KeyCode == Enum.KeyCode.C then
            ToggleSpeedBoost()
        elseif input.KeyCode == Enum.KeyCode.V then
            ToggleMinimize()
        end
    end))
end

local function Initialize()
    CleanupConnections()
    
    table_insert(connections, toggle.MouseButton1Click:Connect(ToggleAimBot))
    table_insert(connections, SpeedToggle.MouseButton1Click:Connect(ToggleSpeedBoost))
    table_insert(connections, MinimizeButton.MouseButton1Click:Connect(ToggleMinimize))
    table_insert(connections, runService.Heartbeat:Connect(AimBotFunction))
    
    if plr.Character then
        SetupCharacter(plr.Character)
    end
    
    table_insert(connections, plr.CharacterAdded:Connect(function(character)
        SetupCharacter(character)
    end))
    
    SetupHotkeys()
    HookNamecall()
end

Initialize()