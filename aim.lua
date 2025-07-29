local function CleanupExistingGUI()
    local coreGui = game:GetService("CoreGui")
    local existingGui = coreGui:FindFirstChild("AimBotGUI")
    if existingGui then
        existingGui:Destroy()
    end
end

CleanupExistingGUI()

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

local players = game:GetService("Players")
local plr = players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local runService = game:GetService("RunService")

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
    toggle.Text = silentaim and "ON" or "OFF"
    toggle.TextColor3 = silentaim and Color3.fromRGB(136, 255, 0) or Color3.fromRGB(255, 0, 4)
end

local function ToggleSpeedBoost()
    speedBoost = not speedBoost
    SpeedToggle.Text = speedBoost and "SPD: ON" or "SPD: OFF"
    SpeedToggle.TextColor3 = speedBoost and Color3.fromRGB(136, 255, 0) or Color3.fromRGB(255, 0, 4)
    
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

local function AimBotFunction()
    if not silentaim or not isAlive then return end
    
    local target = GetBestTarget()
    if target and targetPart then
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position + Vector3.new(0, 1.5, 0))
    end
end

local function ProcessDamage(attacker)
    if not attacker or not isAlive then return end
    
    local attackerPlayer = players:GetPlayerFromCharacter(attacker)
    if attackerPlayer and attackerPlayer ~= plr then
        lastAttacker = attacker
        lastAttackTime = os.time()
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
    
    table.insert(connections, toggle.MouseButton1Click:Connect(ToggleAimBot))
    table.insert(connections, SpeedToggle.MouseButton1Click:Connect(ToggleSpeedBoost))
    table.insert(connections, MinimizeButton.MouseButton1Click:Connect(ToggleMinimize))
    table.insert(connections, runService.Heartbeat:Connect(AimBotFunction))
    
    if plr.Character then
        SetupCharacter(plr.Character)
    end
    
    table.insert(connections, plr.CharacterAdded:Connect(function(character)
        SetupCharacter(character)
    end))
    
    HookNamecall()
end

Initialize()
