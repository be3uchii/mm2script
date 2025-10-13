local function CleanupExistingGUI()
    local coreGui = game:GetService("CoreGui")
    local existingGui = coreGui:FindFirstChild("AimBotGUI")
    if existingGui then
        existingGui:Destroy()
    end
end

CleanupExistingGUI()

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimToggle = Instance.new("TextButton")
local SpeedToggle = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local FovFrame = Instance.new("Frame")
local FovTitle = Instance.new("TextLabel")
local FovIncrease = Instance.new("TextButton")
local FovDecrease = Instance.new("TextButton")
local FovValue = Instance.new("TextLabel")

ScreenGui.Name = "AimBotGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0, 10, 0.5, -90)
MainFrame.Size = UDim2.new(0, 120, 0, 200)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "AIM BOT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12

AimToggle.Parent = MainFrame
AimToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
AimToggle.Position = UDim2.new(0, 10, 0, 35)
AimToggle.Size = UDim2.new(1, -20, 0, 30)
AimToggle.Font = Enum.Font.Gotham
AimToggle.Text = "AIM: OFF"
AimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimToggle.TextSize = 12

SpeedToggle.Parent = MainFrame
SpeedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 200)
SpeedToggle.Position = UDim2.new(0, 10, 0, 75)
SpeedToggle.Size = UDim2.new(1, -20, 0, 30)
SpeedToggle.Font = Enum.Font.Gotham
SpeedToggle.Text = "SPEED: OFF"
SpeedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedToggle.TextSize = 12

FovFrame.Parent = MainFrame
FovFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FovFrame.Position = UDim2.new(0, 10, 0, 115)
FovFrame.Size = UDim2.new(1, -20, 0, 50)

FovTitle.Parent = FovFrame
FovTitle.BackgroundTransparency = 1
FovTitle.Size = UDim2.new(1, 0, 0, 15)
FovTitle.Font = Enum.Font.Gotham
FovTitle.Text = "FOV RADIUS"
FovTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FovTitle.TextSize = 10

FovDecrease.Parent = FovFrame
FovDecrease.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FovDecrease.Position = UDim2.new(0, 5, 0, 20)
FovDecrease.Size = UDim2.new(0, 25, 0, 20)
FovDecrease.Font = Enum.Font.GothamBold
FovDecrease.Text = "-"
FovDecrease.TextColor3 = Color3.fromRGB(255, 255, 255)
FovDecrease.TextSize = 12

FovIncrease.Parent = FovFrame
FovIncrease.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FovIncrease.Position = UDim2.new(1, -30, 0, 20)
FovIncrease.Size = UDim2.new(0, 25, 0, 20)
FovIncrease.Font = Enum.Font.GothamBold
FovIncrease.Text = "+"
FovIncrease.TextColor3 = Color3.fromRGB(255, 255, 255)
FovIncrease.TextSize = 12

FovValue.Parent = FovFrame
FovValue.BackgroundTransparency = 1
FovValue.Position = UDim2.new(0, 35, 0, 20)
FovValue.Size = UDim2.new(1, -70, 0, 20)
FovValue.Font = Enum.Font.Gotham
FovValue.Text = "1000"
FovValue.TextColor3 = Color3.fromRGB(255, 255, 255)
FovValue.TextSize = 12

MinimizeButton.Parent = MainFrame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeButton.Position = UDim2.new(0, 10, 1, -25)
MinimizeButton.Size = UDim2.new(1, -20, 0, 20)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 12

local players = game:GetService("Players")
local plr = players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local runService = game:GetService("RunService")

local silentaim = false
local speedBoost = false
local connections = {}
local isAlive = true
local targetPart = nil
local maxDistance = 1000
local baseWalkSpeed = 16
local boostedWalkSpeed = 32
local minimized = false
local priorityTarget = nil
local lastDamageTime = 0
local currentTarget = nil
local targetStickTime = 0
local lastTargetSwitch = 0

local settings = {
    silentaim = false,
    speedBoost = false,
    maxDistance = 1000
}

local function SaveSettings()
    settings.silentaim = silentaim
    settings.speedBoost = speedBoost
    settings.maxDistance = maxDistance
end

local function LoadSettings()
    silentaim = settings.silentaim
    speedBoost = settings.speedBoost
    maxDistance = settings.maxDistance
    
    AimToggle.Text = silentaim and "AIM: ON" or "AIM: OFF"
    AimToggle.BackgroundColor3 = silentaim and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60)
    
    SpeedToggle.Text = speedBoost and "SPEED: ON" or "SPEED: OFF"
    SpeedToggle.BackgroundColor3 = speedBoost and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(60, 60, 200)
    
    FovValue.Text = tostring(maxDistance)
end

local function CleanupConnections()
    for i = 1, #connections do
        local v = connections[i]
        if v and v.Disconnect then
            v:Disconnect()
        end
    end
    connections = {}
end

local function IsVisible(part)
    if not part or not plr.Character or not isAlive then return false end
    
    local origin = camera.CFrame.Position
    local targetPosition = part.Position
    local direction = (targetPosition - origin).Unit
    local distance = (targetPosition - origin).Magnitude
    
    local ray = Ray.new(origin, direction * math.min(distance, maxDistance))
    
    local ignoreList = {plr.Character, camera}
    local hit, hitPosition = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if hit then
        local hitCharacter = hit:FindFirstAncestorOfClass("Model")
        if hitCharacter and hitCharacter:FindFirstChildOfClass("Humanoid") then
            local hitPlayer = players:GetPlayerFromCharacter(hitCharacter)
            if hitPlayer then
                return hitPlayer.Character == part.Parent
            end
        end
    end
    
    return false
end

local function GetBestTarget()
    if not isAlive or not plr.Character then return nil end
    
    local currentTime = tick()
    
    if priorityTarget and currentTime - lastDamageTime < 3 then
        local enemyCharacter = priorityTarget.Character
        if enemyCharacter then
            local humanoid = enemyCharacter:FindFirstChildOfClass("Humanoid")
            local rootPart = enemyCharacter:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart and IsVisible(rootPart) then
                local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
                if distance <= maxDistance then
                    if currentTarget ~= priorityTarget then
                        currentTarget = priorityTarget
                        targetStickTime = currentTime
                    end
                    targetPart = rootPart
                    return priorityTarget
                end
            end
        else
            priorityTarget = nil
            currentTarget = nil
        end
    else
        priorityTarget = nil
    end
    
    if currentTarget and currentTime - targetStickTime < 0.5 then
        local enemyCharacter = currentTarget.Character
        if enemyCharacter then
            local humanoid = enemyCharacter:FindFirstChildOfClass("Humanoid")
            local rootPart = enemyCharacter:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart and IsVisible(rootPart) then
                local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
                if distance <= maxDistance then
                    targetPart = rootPart
                    return currentTarget
                end
            end
        else
            currentTarget = nil
        end
    end
    
    local cameraPosition = camera.CFrame.Position
    local playersList = players:GetPlayers()
    local bestTarget = nil
    local bestDistance = 9999
    local bestScore = -1
    
    for i = 1, #playersList do
        local enemy = playersList[i]
        if enemy ~= plr and enemy.Character then
            local enemyCharacter = enemy.Character
            local humanoid = enemyCharacter:FindFirstChildOfClass("Humanoid")
            local rootPart = enemyCharacter:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (rootPart.Position - cameraPosition).Magnitude
                if distance <= maxDistance then
                    if IsVisible(rootPart) then
                        local score = 1000 - distance
                        
                        if enemy == currentTarget then
                            score = score + 500
                        end
                        
                        if score > bestScore or (score == bestScore and distance < bestDistance) then
                            bestScore = score
                            bestDistance = distance
                            bestTarget = enemy
                            targetPart = rootPart
                        end
                    end
                end
            end
        end
    end
    
    if bestTarget and bestTarget ~= currentTarget and currentTime - lastTargetSwitch > 0.2 then
        currentTarget = bestTarget
        targetStickTime = currentTime
        lastTargetSwitch = currentTime
    end
    
    return bestTarget
end

local function ToggleAimBot()
    silentaim = not silentaim
    AimToggle.Text = silentaim and "AIM: ON" or "AIM: OFF"
    AimToggle.BackgroundColor3 = silentaim and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60)
    SaveSettings()
end

local function ToggleSpeedBoost()
    speedBoost = not speedBoost
    SpeedToggle.Text = speedBoost and "SPEED: ON" or "SPEED: OFF"
    SpeedToggle.BackgroundColor3 = speedBoost and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(60, 60, 200)
    SaveSettings()
    ApplySpeedBoost()
end

local function UpdateFovDisplay()
    FovValue.Text = tostring(maxDistance)
end

local function IncreaseFov()
    maxDistance = math.min(maxDistance + 100, 5000)
    UpdateFovDisplay()
    SaveSettings()
end

local function DecreaseFov()
    maxDistance = math.max(maxDistance - 100, 50)
    UpdateFovDisplay()
    SaveSettings()
end

local function ToggleMinimize()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 120, 0, 25)
        AimToggle.Visible = false
        SpeedToggle.Visible = false
        FovFrame.Visible = false
        MinimizeButton.Text = "□"
    else
        MainFrame.Size = UDim2.new(0, 120, 0, 200)
        AimToggle.Visible = true
        SpeedToggle.Visible = true
        FovFrame.Visible = true
        MinimizeButton.Text = "_"
    end
end

local function ApplySpeedBoost()
    if plr.Character then
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedBoost and boostedWalkSpeed or baseWalkSpeed
        end
    end
end

local function ProcessDamage(damager)
    if not damager or not isAlive then return end
    
    local damagerPlayer = players:GetPlayerFromCharacter(damager)
    if damagerPlayer and damagerPlayer ~= plr then
        priorityTarget = damagerPlayer
        lastDamageTime = tick()
        currentTarget = damagerPlayer
        targetStickTime = tick()
    end
end

local function AimBotFunction()
    if not silentaim or not isAlive then return end
    
    local target = GetBestTarget()
    if target and targetPart then
        local targetPosition = targetPart.Position + Vector3.new(0, 1.5, 0)
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
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
    
    ApplySpeedBoost()
    
    table.insert(connections, humanoid.Touched:Connect(function(hit)
        if not hit or not hit.Parent then return end
        
        local attacker = players:GetPlayerFromCharacter(hit.Parent)
        if not attacker then
            attacker = players:GetPlayerFromCharacter(hit.Parent.Parent)
        end
        
        if attacker and attacker ~= plr then
            ProcessDamage(hit.Parent)
        end
    end))
    
    table.insert(connections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health < humanoid.MaxHealth then
            for _, player in pairs(players:GetPlayers()) do
                if player ~= plr and player.Character then
                    ProcessDamage(player.Character)
                end
            end
        end
        
        if humanoid.Health <= 0 then
            isAlive = false
            targetPart = nil
            priorityTarget = nil
            currentTarget = nil
        end
    end))
    
    table.insert(connections, humanoid.Died:Connect(function()
        isAlive = false
        targetPart = nil
        priorityTarget = nil
        currentTarget = nil
    end))
end

local function Initialize()
    CleanupConnections()
    
    LoadSettings()
    
    table.insert(connections, AimToggle.MouseButton1Click:Connect(ToggleAimBot))
    table.insert(connections, SpeedToggle.MouseButton1Click:Connect(ToggleSpeedBoost))
    table.insert(connections, MinimizeButton.MouseButton1Click:Connect(ToggleMinimize))
    table.insert(connections, FovIncrease.MouseButton1Click:Connect(IncreaseFov))
    table.insert(connections, FovDecrease.MouseButton1Click:Connect(DecreaseFov))
    table.insert(connections, runService.Heartbeat:Connect(AimBotFunction))
    
    if plr.Character then
        SetupCharacter(plr.Character)
    end
    
    table.insert(connections, plr.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        SetupCharacter(character)
        LoadSettings()
    end))
    
    UpdateFovDisplay()
    HookNamecall()
    
    runService.Heartbeat:Connect(function()
        if speedBoost then
            ApplySpeedBoost()
        end
    end)
end

Initialize()