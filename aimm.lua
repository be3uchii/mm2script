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
local boostedWalkSpeed = 25
local targetCache = {}
local lastCacheUpdate = 0
local cacheUpdateInterval = 0.2
local minimized = false

local math_huge = math.huge
local CFrame_new = CFrame.new
local Vector3_new = Vector3.new
local Ray_new = Ray.new
local table_insert = table.insert

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
    local currentTime = os.time()
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
                    targetCache[#targetCache + 1] = {
                        player = enemy,
                        rootPart = rootPart,
                        distance = distance
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
    
    for i = 1, #targetCache do
        local targetData = targetCache[i]
        if IsVisible(targetData.rootPart) then
            if targetData.distance < closestDistance then
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
    AimToggle.Text = silentaim and "AIM: ON" or "AIM: OFF"
    AimToggle.BackgroundColor3 = silentaim and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60)
end

local function ToggleSpeedBoost()
    speedBoost = not speedBoost
    SpeedToggle.Text = speedBoost and "SPEED: ON" or "SPEED: OFF"
    SpeedToggle.BackgroundColor3 = speedBoost and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(60, 60, 200)
    
    if plr.Character then
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedBoost and boostedWalkSpeed or baseWalkSpeed
        end
    end
end

local function UpdateFovDisplay()
    FovValue.Text = tostring(maxDistance)
end

local function IncreaseFov()
    maxDistance = math.min(maxDistance + 100, 5000)
    UpdateFovDisplay()
end

local function DecreaseFov()
    maxDistance = math.max(maxDistance - 100, 100)
    UpdateFovDisplay()
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

local function SmoothAim(targetPosition)
    local currentCFrame = camera.CFrame
    local targetCFrame = CFrame_new(currentCFrame.Position, targetPosition)
    local smoothFactor = 0.4
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
    
    humanoid.WalkSpeed = speedBoost and boostedWalkSpeed or baseWalkSpeed
    
    table_insert(connections, humanoid.Died:Connect(function()
        isAlive = false
        targetPart = nil
        targetCache = {}
    end))
end

local function Initialize()
    CleanupConnections()
    
    table_insert(connections, AimToggle.MouseButton1Click:Connect(ToggleAimBot))
    table_insert(connections, SpeedToggle.MouseButton1Click:Connect(ToggleSpeedBoost))
    table_insert(connections, MinimizeButton.MouseButton1Click:Connect(ToggleMinimize))
    table_insert(connections, FovIncrease.MouseButton1Click:Connect(IncreaseFov))
    table_insert(connections, FovDecrease.MouseButton1Click:Connect(DecreaseFov))
    table_insert(connections, runService.Heartbeat:Connect(AimBotFunction))
    
    if plr.Character then
        SetupCharacter(plr.Character)
    end
    
    table_insert(connections, plr.CharacterAdded:Connect(function(character)
        SetupCharacter(character)
    end))
    
    UpdateFovDisplay()
    HookNamecall()
end

Initialize()