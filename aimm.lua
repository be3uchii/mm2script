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
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local ToggleContainer = Instance.new("Frame")
local AimToggle = Instance.new("TextButton")
local AimStatus = Instance.new("Frame")
local SpeedToggle = Instance.new("TextButton")
local SpeedStatus = Instance.new("Frame")
local FOVToggle = Instance.new("TextButton")
local FOVStatus = Instance.new("Frame")
local Visualizer = Instance.new("Frame")
local FOVCircle = Instance.new("ImageLabel")
local TargetIndicator = Instance.new("Frame")
local StatusPanel = Instance.new("Frame")
local StatusTitle = Instance.new("TextLabel")
local TargetInfo = Instance.new("TextLabel")
local DistanceInfo = Instance.new("TextLabel")
local FOVInfo = Instance.new("TextLabel")
local SettingsPanel = Instance.new("Frame")
local SettingsTitle = Instance.new("TextLabel")
local FOVSlider = Instance.new("Frame")
local FOVText = Instance.new("TextLabel")
local FOVValue = Instance.new("TextLabel")
local SliderTrack = Instance.new("Frame")
local SliderButton = Instance.new("TextButton")
local DistanceSlider = Instance.new("Frame")
local DistanceText = Instance.new("TextLabel")
local DistanceValue = Instance.new("TextLabel")
local DistanceTrack = Instance.new("Frame")
local DistanceButton = Instance.new("TextButton")
local SmoothnessSlider = Instance.new("Frame")
local SmoothnessText = Instance.new("TextLabel")
local SmoothnessValue = Instance.new("TextLabel")
local SmoothnessTrack = Instance.new("Frame")
local SmoothnessButton = Instance.new("TextButton")

ScreenGui.Name = "AimBotGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(100, 150, 255)
UIStroke.Parent = MainFrame

TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 30)

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0, 120, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "PRECISION AIM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.TextSize = 18

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TopBar
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeButton.TextSize = 18

ToggleContainer.Name = "ToggleContainer"
ToggleContainer.Parent = MainFrame
ToggleContainer.BackgroundTransparency = 1
ToggleContainer.Position = UDim2.new(0, 15, 0, 45)
ToggleContainer.Size = UDim2.new(1, -30, 0, 150)

AimToggle.Name = "AimToggle"
AimToggle.Parent = ToggleContainer
AimToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
AimToggle.BorderSizePixel = 0
AimToggle.Position = UDim2.new(0, 0, 0, 0)
AimToggle.Size = UDim2.new(1, 0, 0, 40)
AimToggle.Font = Enum.Font.GothamBold
AimToggle.Text = "AIM ASSIST"
AimToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
AimToggle.TextSize = 12

local AimToggleCorner = Instance.new("UICorner")
AimToggleCorner.CornerRadius = UDim.new(0, 6)
AimToggleCorner.Parent = AimToggle

AimStatus.Name = "AimStatus"
AimStatus.Parent = AimToggle
AimStatus.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
AimStatus.BorderSizePixel = 0
AimStatus.Position = UDim2.new(1, -25, 0.5, -8)
AimStatus.Size = UDim2.new(0, 16, 0, 16)

local AimStatusCorner = Instance.new("UICorner")
AimStatusCorner.CornerRadius = UDim.new(1, 0)
AimStatusCorner.Parent = AimStatus

SpeedToggle.Name = "SpeedToggle"
SpeedToggle.Parent = ToggleContainer
SpeedToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
SpeedToggle.BorderSizePixel = 0
SpeedToggle.Position = UDim2.new(0, 0, 0, 50)
SpeedToggle.Size = UDim2.new(1, 0, 0, 40)
SpeedToggle.Font = Enum.Font.GothamBold
SpeedToggle.Text = "SPEED BOOST"
SpeedToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
SpeedToggle.TextSize = 12

local SpeedToggleCorner = Instance.new("UICorner")
SpeedToggleCorner.CornerRadius = UDim.new(0, 6)
SpeedToggleCorner.Parent = SpeedToggle

SpeedStatus.Name = "SpeedStatus"
SpeedStatus.Parent = SpeedToggle
SpeedStatus.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
SpeedStatus.BorderSizePixel = 0
SpeedStatus.Position = UDim2.new(1, -25, 0.5, -8)
SpeedStatus.Size = UDim2.new(0, 16, 0, 16)

local SpeedStatusCorner = Instance.new("UICorner")
SpeedStatusCorner.CornerRadius = UDim.new(1, 0)
SpeedStatusCorner.Parent = SpeedStatus

FOVToggle.Name = "FOVToggle"
FOVToggle.Parent = ToggleContainer
FOVToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
FOVToggle.BorderSizePixel = 0
FOVToggle.Position = UDim2.new(0, 0, 0, 100)
FOVToggle.Size = UDim2.new(1, 0, 0, 40)
FOVToggle.Font = Enum.Font.GothamBold
FOVToggle.Text = "FOV VISUALIZER"
FOVToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
FOVToggle.TextSize = 12

local FOVToggleCorner = Instance.new("UICorner")
FOVToggleCorner.CornerRadius = UDim.new(0, 6)
FOVToggleCorner.Parent = FOVToggle

FOVStatus.Name = "FOVStatus"
FOVStatus.Parent = FOVToggle
FOVStatus.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
FOVStatus.BorderSizePixel = 0
FOVStatus.Position = UDim2.new(1, -25, 0.5, -8)
FOVStatus.Size = UDim2.new(0, 16, 0, 16)

local FOVStatusCorner = Instance.new("UICorner")
FOVStatusCorner.CornerRadius = UDim.new(1, 0)
FOVStatusCorner.Parent = FOVStatus

Visualizer.Name = "Visualizer"
Visualizer.Parent = ScreenGui
Visualizer.BackgroundTransparency = 1
Visualizer.Size = UDim2.new(1, 0, 1, 0)

FOVCircle.Name = "FOVCircle"
FOVCircle.Parent = Visualizer
FOVCircle.BackgroundTransparency = 1
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, 300, 0, 300)
FOVCircle.Image = "rbxassetid://3570695787"
FOVCircle.ImageColor3 = Color3.fromRGB(100, 150, 255)
FOVCircle.ImageTransparency = 0.8
FOVCircle.Visible = false

TargetIndicator.Name = "TargetIndicator"
TargetIndicator.Parent = Visualizer
TargetIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
TargetIndicator.BorderSizePixel = 0
TargetIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
TargetIndicator.Size = UDim2.new(0, 10, 0, 10)
TargetIndicator.Visible = false

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(1, 0)
TargetCorner.Parent = TargetIndicator

StatusPanel.Name = "StatusPanel"
StatusPanel.Parent = MainFrame
StatusPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
StatusPanel.BorderSizePixel = 0
StatusPanel.Position = UDim2.new(0, 15, 0, 210)
StatusPanel.Size = UDim2.new(1, -30, 0, 80)

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusPanel

StatusTitle.Name = "StatusTitle"
StatusTitle.Parent = StatusPanel
StatusTitle.BackgroundTransparency = 1
StatusTitle.Position = UDim2.new(0, 10, 0, 5)
StatusTitle.Size = UDim2.new(1, -20, 0, 20)
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.Text = "CURRENT STATUS"
StatusTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
StatusTitle.TextSize = 12
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left

TargetInfo.Name = "TargetInfo"
TargetInfo.Parent = StatusPanel
TargetInfo.BackgroundTransparency = 1
TargetInfo.Position = UDim2.new(0, 10, 0, 25)
TargetInfo.Size = UDim2.new(1, -20, 0, 15)
TargetInfo.Font = Enum.Font.Gotham
TargetInfo.Text = "Target: None"
TargetInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
TargetInfo.TextSize = 11
TargetInfo.TextXAlignment = Enum.TextXAlignment.Left

DistanceInfo.Name = "DistanceInfo"
DistanceInfo.Parent = StatusPanel
DistanceInfo.BackgroundTransparency = 1
DistanceInfo.Position = UDim2.new(0, 10, 0, 40)
DistanceInfo.Size = UDim2.new(1, -20, 0, 15)
DistanceInfo.Font = Enum.Font.Gotham
DistanceInfo.Text = "Distance: -"
DistanceInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
DistanceInfo.TextSize = 11
DistanceInfo.TextXAlignment = Enum.TextXAlignment.Left

FOVInfo.Name = "FOVInfo"
FOVInfo.Parent = StatusPanel
FOVInfo.BackgroundTransparency = 1
FOVInfo.Position = UDim2.new(0, 10, 0, 55)
FOVInfo.Size = UDim2.new(1, -20, 0, 15)
FOVInfo.Font = Enum.Font.Gotham
FOVInfo.Text = "In FOV: No"
FOVInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
FOVInfo.TextSize = 11
FOVInfo.TextXAlignment = Enum.TextXAlignment.Left

SettingsPanel.Name = "SettingsPanel"
SettingsPanel.Parent = MainFrame
SettingsPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
SettingsPanel.BorderSizePixel = 0
SettingsPanel.Position = UDim2.new(0, 15, 0, 305)
SettingsPanel.Size = UDim2.new(1, -30, 0, 0)
SettingsPanel.ClipsDescendants = true

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 6)
SettingsCorner.Parent = SettingsPanel

SettingsTitle.Name = "SettingsTitle"
SettingsTitle.Parent = SettingsPanel
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Size = UDim2.new(1, 0, 0, 25)
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.Text = "ADVANCED SETTINGS"
SettingsTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
SettingsTitle.TextSize = 12

FOVSlider.Name = "FOVSlider"
FOVSlider.Parent = SettingsPanel
FOVSlider.BackgroundTransparency = 1
FOVSlider.Position = UDim2.new(0, 10, 0, 30)
FOVSlider.Size = UDim2.new(1, -20, 0, 30)

FOVText.Name = "FOVText"
FOVText.Parent = FOVSlider
FOVText.BackgroundTransparency = 1
FOVText.Size = UDim2.new(0, 80, 1, 0)
FOVText.Font = Enum.Font.Gotham
FOVText.Text = "FOV Size:"
FOVText.TextColor3 = Color3.fromRGB(200, 200, 200)
FOVText.TextSize = 11
FOVText.TextXAlignment = Enum.TextXAlignment.Left

FOVValue.Name = "FOVValue"
FOVValue.Parent = FOVSlider
FOVValue.BackgroundTransparency = 1
FOVValue.Position = UDim2.new(1, -30, 0, 0)
FOVValue.Size = UDim2.new(0, 30, 1, 0)
FOVValue.Font = Enum.Font.GothamBold
FOVValue.Text = "120"
FOVValue.TextColor3 = Color3.fromRGB(100, 150, 255)
FOVValue.TextSize = 11

SliderTrack.Name = "SliderTrack"
SliderTrack.Parent = FOVSlider
SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
SliderTrack.BorderSizePixel = 0
SliderTrack.Position = UDim2.new(0, 80, 0.5, -2)
SliderTrack.Size = UDim2.new(1, -120, 0, 4)

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(1, 0)
TrackCorner.Parent = SliderTrack

SliderButton.Name = "SliderButton"
SliderButton.Parent = SliderTrack
SliderButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
SliderButton.BorderSizePixel = 0
SliderButton.Position = UDim2.new(0.5, -8, 0.5, -8)
SliderButton.Size = UDim2.new(0, 16, 0, 16)
SliderButton.Font = Enum.Font.SourceSans
SliderButton.Text = ""
SliderButton.TextSize = 14

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = SliderButton

DistanceSlider.Name = "DistanceSlider"
DistanceSlider.Parent = SettingsPanel
DistanceSlider.BackgroundTransparency = 1
DistanceSlider.Position = UDim2.new(0, 10, 0, 70)
DistanceSlider.Size = UDim2.new(1, -20, 0, 30)

DistanceText.Name = "DistanceText"
DistanceText.Parent = DistanceSlider
DistanceText.BackgroundTransparency = 1
DistanceText.Size = UDim2.new(0, 80, 1, 0)
DistanceText.Font = Enum.Font.Gotham
DistanceText.Text = "Max Distance:"
DistanceText.TextColor3 = Color3.fromRGB(200, 200, 200)
DistanceText.TextSize = 11
DistanceText.TextXAlignment = Enum.TextXAlignment.Left

DistanceValue.Name = "DistanceValue"
DistanceValue.Parent = DistanceSlider
DistanceValue.BackgroundTransparency = 1
DistanceValue.Position = UDim2.new(1, -40, 0, 0)
DistanceValue.Size = UDim2.new(0, 40, 1, 0)
DistanceValue.Font = Enum.Font.GothamBold
DistanceValue.Text = "1000"
DistanceValue.TextColor3 = Color3.fromRGB(100, 150, 255)
DistanceValue.TextSize = 11

DistanceTrack.Name = "DistanceTrack"
DistanceTrack.Parent = DistanceSlider
DistanceTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
DistanceTrack.BorderSizePixel = 0
DistanceTrack.Position = UDim2.new(0, 80, 0.5, -2)
DistanceTrack.Size = UDim2.new(1, -130, 0, 4)

local DistanceTrackCorner = Instance.new("UICorner")
DistanceTrackCorner.CornerRadius = UDim.new(1, 0)
DistanceTrackCorner.Parent = DistanceTrack

DistanceButton.Name = "DistanceButton"
DistanceButton.Parent = DistanceTrack
DistanceButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
DistanceButton.BorderSizePixel = 0
DistanceButton.Position = UDim2.new(0.8, -8, 0.5, -8)
DistanceButton.Size = UDim2.new(0, 16, 0, 16)
DistanceButton.Font = Enum.Font.SourceSans
DistanceButton.Text = ""
DistanceButton.TextSize = 14

local DistanceCorner = Instance.new("UICorner")
DistanceCorner.CornerRadius = UDim.new(1, 0)
DistanceCorner.Parent = DistanceButton

SmoothnessSlider.Name = "SmoothnessSlider"
SmoothnessSlider.Parent = SettingsPanel
SmoothnessSlider.BackgroundTransparency = 1
SmoothnessSlider.Position = UDim2.new(0, 10, 0, 110)
SmoothnessSlider.Size = UDim2.new(1, -20, 0, 30)

SmoothnessText.Name = "SmoothnessText"
SmoothnessText.Parent = SmoothnessSlider
SmoothnessText.BackgroundTransparency = 1
SmoothnessText.Size = UDim2.new(0, 80, 1, 0)
SmoothnessText.Font = Enum.Font.Gotham
SmoothnessText.Text = "Smoothness:"
SmoothnessText.TextColor3 = Color3.fromRGB(200, 200, 200)
SmoothnessText.TextSize = 11
SmoothnessText.TextXAlignment = Enum.TextXAlignment.Left

SmoothnessValue.Name = "SmoothnessValue"
SmoothnessValue.Parent = SmoothnessSlider
SmoothnessValue.BackgroundTransparency = 1
SmoothnessValue.Position = UDim2.new(1, -40, 0, 0)
SmoothnessValue.Size = UDim2.new(0, 40, 1, 0)
SmoothnessValue.Font = Enum.Font.GothamBold
SmoothnessValue.Text = "0.3"
SmoothnessValue.TextColor3 = Color3.fromRGB(100, 150, 255)
SmoothnessValue.TextSize = 11

SmoothnessTrack.Name = "SmoothnessTrack"
SmoothnessTrack.Parent = SmoothnessSlider
SmoothnessTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
SmoothnessTrack.BorderSizePixel = 0
SmoothnessTrack.Position = UDim2.new(0, 80, 0.5, -2)
SmoothnessTrack.Size = UDim2.new(1, -130, 0, 4)

local SmoothnessTrackCorner = Instance.new("UICorner")
SmoothnessTrackCorner.CornerRadius = UDim.new(1, 0)
SmoothnessTrackCorner.Parent = SmoothnessTrack

SmoothnessButton.Name = "SmoothnessButton"
SmoothnessButton.Parent = SmoothnessTrack
SmoothnessButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
SmoothnessButton.BorderSizePixel = 0
SmoothnessButton.Position = UDim2.new(0.3, -8, 0.5, -8)
SmoothnessButton.Size = UDim2.new(0, 16, 0, 16)
SmoothnessButton.Font = Enum.Font.SourceSans
SmoothnessButton.Text = ""
SmoothnessButton.TextSize = 14

local SmoothnessCorner = Instance.new("UICorner")
SmoothnessCorner.CornerRadius = UDim.new(1, 0)
SmoothnessCorner.Parent = SmoothnessButton

local silentaim = false
local speedBoost = false
local fovVisible = false
local settingsExpanded = false
local connections = {}
local isAlive = true
local targetPart = nil
local currentTarget = nil
local maxDistance = 1000
local fov = 120
local smoothness = 0.3
local baseWalkSpeed = 16
local boostedWalkSpeed = 26
local mouse = plr:GetMouse()
local fovTween = nil
local targetTween = nil
local lastTargetPos = Vector3.new()

local function CleanupConnections()
    for _, v in pairs(connections) do
        if v and v.Disconnect then
            v:Disconnect()
        end
    end
    connections = {}
end

local function TweenObject(obj, properties, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
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

local function IsInFOV(position)
    local screenPoint, visible = camera:WorldToViewportPoint(position)
    if not visible then return false end
    
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local point = Vector2.new(screenPoint.X, screenPoint.Y)
    local distance = (point - center).Magnitude
    
    return distance <= (fov / 2)
end

local function GetBestTarget()
    if not isAlive then return nil end
    
    local closestTarget = nil
    local closestDistance = math.huge
    local highestPriority = -1
    
    for _, enemy in pairs(Players:GetPlayers()) do
        if enemy ~= plr and enemy.Character then
            local humanoid = enemy.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = enemy.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart and IsVisible(rootPart) then
                local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
                local inFOV = IsInFOV(rootPart.Position)
                local priority = 0
                
                if inFOV then
                    priority = priority + 1000
                end
                
                if distance <= maxDistance then
                    priority = priority + (maxDistance - distance)
                end
                
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

local function UpdateVisualizer()
    if not fovVisible then
        FOVCircle.Visible = false
        TargetIndicator.Visible = false
        return
    end
    
    FOVCircle.Visible = true
    FOVCircle.Size = UDim2.new(0, fov * 2.5, 0, fov * 2.5)
    
    if currentTarget and targetPart then
        local screenPoint, visible = camera:WorldToViewportPoint(targetPart.Position)
        if visible then
            TargetIndicator.Visible = true
            TargetIndicator.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y)
            
            local distance = (targetPart.Position - camera.CFrame.Position).Magnitude
            local scale = math.clamp(500 / distance, 0.5, 2)
            TargetIndicator.Size = UDim2.new(0, 10 * scale, 0, 10 * scale)
        else
            TargetIndicator.Visible = false
        end
    else
        TargetIndicator.Visible = false
    end
end

local function UpdateStatus()
    if currentTarget and targetPart then
        local distance = (targetPart.Position - camera.CFrame.Position).Magnitude
        local inFOV = IsInFOV(targetPart.Position)
        
        TargetInfo.Text = "Target: " .. currentTarget.Name
        DistanceInfo.Text = string.format("Distance: %.1f", distance)
        FOVInfo.Text = "In FOV: " .. (inFOV and "Yes" or "No")
        
        TargetInfo.TextColor3 = inFOV and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        DistanceInfo.TextColor3 = distance <= maxDistance and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        FOVInfo.TextColor3 = inFOV and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    else
        TargetInfo.Text = "Target: None"
        DistanceInfo.Text = "Distance: -"
        FOVInfo.Text = "In FOV: No"
        
        TargetInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
        DistanceInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
        FOVInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

local function ToggleAimBot()
    silentaim = not silentaim
    AimToggle.TextColor3 = silentaim and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    AimStatus.BackgroundColor3 = silentaim and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    
    if silentaim then
        TweenObject(AimToggle, {BackgroundColor3 = Color3.fromRGB(40, 60, 40)}, 0.2)
        TweenObject(AimStatus, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -27, 0.5, -10)}, 0.2)
    else
        TweenObject(AimToggle, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}, 0.2)
        TweenObject(AimStatus, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -25, 0.5, -8)}, 0.2)
        currentTarget = nil
        targetPart = nil
    end
end

local function ToggleSpeedBoost()
    speedBoost = not speedBoost
    SpeedToggle.TextColor3 = speedBoost and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    SpeedStatus.BackgroundColor3 = speedBoost and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    
    if speedBoost then
        TweenObject(SpeedToggle, {BackgroundColor3 = Color3.fromRGB(40, 60, 40)}, 0.2)
        TweenObject(SpeedStatus, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -27, 0.5, -10)}, 0.2)
    else
        TweenObject(SpeedToggle, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}, 0.2)
        TweenObject(SpeedStatus, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -25, 0.5, -8)}, 0.2)
    end
    
    if plr.Character then
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedBoost and boostedWalkSpeed or baseWalkSpeed
        end
    end
end

local function ToggleFOV()
    fovVisible = not fovVisible
    FOVToggle.TextColor3 = fovVisible and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    FOVStatus.BackgroundColor3 = fovVisible and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    
    if fovVisible then
        TweenObject(FOVToggle, {BackgroundColor3 = Color3.fromRGB(40, 60, 40)}, 0.2)
        TweenObject(FOVStatus, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -27, 0.5, -10)}, 0.2)
        FOVCircle.Visible = true
        TweenObject(FOVCircle, {ImageTransparency = 0.3}, 0.3)
    else
        TweenObject(FOVToggle, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}, 0.2)
        TweenObject(FOVStatus, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -25, 0.5, -8)}, 0.2)
        if fovTween then fovTween:Cancel() end
        fovTween = TweenObject(FOVCircle, {ImageTransparency = 1}, 0.3)
        fovTween.Completed:Connect(function()
            if not fovVisible then
                FOVCircle.Visible = false
            end
        end)
    end
end

local function ToggleMinimize()
    if settingsExpanded then
        ToggleSettings()
    end
    
    if MainFrame.Size.Y.Offset == 320 then
        TweenObject(MainFrame, {Size = UDim2.new(0, 220, 0, 40)}, 0.3)
        TweenObject(ToggleContainer, {BackgroundTransparency = 1}, 0.2)
        TweenObject(StatusPanel, {BackgroundTransparency = 1}, 0.2)
        MinimizeButton.Text = "+"
    else
        TweenObject(MainFrame, {Size = UDim2.new(0, 220, 0, 320)}, 0.3)
        TweenObject(ToggleContainer, {BackgroundTransparency = 0}, 0.2)
        TweenObject(StatusPanel, {BackgroundTransparency = 0}, 0.2)
        MinimizeButton.Text = "−"
    end
end

local function ToggleSettings()
    settingsExpanded = not settingsExpanded
    
    if settingsExpanded then
        TweenObject(SettingsPanel, {Size = UDim2.new(1, -30, 0, 150)}, 0.3)
        TweenObject(MainFrame, {Size = UDim2.new(0, 220, 0, 470)}, 0.3)
    else
        TweenObject(SettingsPanel, {Size = UDim2.new(1, -30, 0, 0)}, 0.3)
        TweenObject(MainFrame, {Size = UDim2.new(0, 220, 0, 320)}, 0.3)
    end
end

local function UpdateFOV(value)
    fov = math.clamp(value, 50, 300)
    FOVValue.Text = tostring(math.floor(fov))
    SliderButton.Position = UDim2.new((fov - 50) / 250, -8, 0.5, -8)
    
    if fovVisible then
        TweenObject(FOVCircle, {Size = UDim2.new(0, fov * 2.5, 0, fov * 2.5)}, 0.2)
    end
end

local function UpdateMaxDistance(value)
    maxDistance = math.clamp(value, 100, 5000)
    DistanceValue.Text = tostring(math.floor(maxDistance))
    DistanceButton.Position = UDim2.new((maxDistance - 100) / 4900, -8, 0.5, -8)
end

local function UpdateSmoothness(value)
    smoothness = math.clamp(math.floor(value * 100) / 100, 0.1, 1.0)
    SmoothnessValue.Text = string.format("%.1f", smoothness)
    SmoothnessButton.Position = UDim2.new((smoothness - 0.1) / 0.9, -8, 0.5, -8)
end

local function SetupSlider(sliderButton, track, minValue, maxValue, currentValue, callback)
    local dragging = false
    
    local function updateFromInput(input)
        if not dragging then return end
        
        local absolutePosition = Vector2.new(track.AbsolutePosition.X, track.AbsolutePosition.Y)
        local absoluteSize = Vector2.new(track.AbsoluteSize.X, track.AbsoluteSize.Y)
        
        local relativeX = (input.Position.X - absolutePosition.X) / absoluteSize.X
        relativeX = math.clamp(relativeX, 0, 1)
        
        local value = minValue + (maxValue - minValue) * relativeX
        callback(value)
    end
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            TweenObject(sliderButton, {Size = UDim2.new(0, 20, 0, 20)}, 0.1)
        end
    end)
    
    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            TweenObject(sliderButton, {Size = UDim2.new(0, 16, 0, 16)}, 0.1)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromInput(input)
        end
    end)
    
    callback(currentValue)
end

local function CheckAlive()
    if plr.Character then
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        isAlive = humanoid and humanoid.Health > 0
    else
        isAlive = false
    end
end

local function Initialize()
    CleanupConnections()
    
    CheckAlive()
    
    table.insert(connections, plr.CharacterAdded:Connect(function(character)
        task.wait(1)
        CheckAlive()
        if speedBoost and character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = boostedWalkSpeed
            end
        end
    end))
    
    table.insert(connections, plr.CharacterRemoving:Connect(function()
        isAlive = false
        currentTarget = nil
        targetPart = nil
    end))
    
    AimToggle.MouseButton1Click:Connect(ToggleAimBot)
    SpeedToggle.MouseButton1Click:Connect(ToggleSpeedBoost)
    FOVToggle.MouseButton1Click:Connect(ToggleFOV)
    MinimizeButton.MouseButton1Click:Connect(ToggleMinimize)
    CloseButton.MouseButton1Click:Connect(function()
        CleanupConnections()
        ScreenGui:Destroy()
    end)
    
    SettingsTitle.MouseButton1Click:Connect(ToggleSettings)
    
    SetupSlider(SliderButton, SliderTrack, 50, 300, 120, UpdateFOV)
    SetupSlider(DistanceButton, DistanceTrack, 100, 5000, 1000, UpdateMaxDistance)
    SetupSlider(SmoothnessButton, SmoothnessTrack, 0.1, 1.0, 0.3, UpdateSmoothness)
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    table.insert(connections, RunService.RenderStepped:Connect(function()
        CheckAlive()
        
        if silentaim and isAlive then
            currentTarget = GetBestTarget()
        else
            currentTarget = nil
            targetPart = nil
        end
        
        UpdateVisualizer()
        UpdateStatus()
        
        if silentaim and currentTarget and targetPart and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local targetPosition = targetPart.Position
            
            if smoothness > 0 then
                local delta = (targetPosition - lastTargetPos) * smoothness
                targetPosition = lastTargetPos + delta
            end
            
            lastTargetPos = targetPosition
            
            local cameraCFrame = camera.CFrame
            local lookVector = (targetPosition - cameraCFrame.Position).Unit
            camera.CFrame = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + lookVector)
        end
    end))
    
    TweenObject(MainFrame, {BackgroundTransparency = 0}, 0.5)
    TweenObject(TopBar, {BackgroundTransparency = 0}, 0.5)
    
    for _, child in pairs(MainFrame:GetChildren()) do
        if child:IsA("GuiObject") and child ~= TopBar then
            TweenObject(child, {BackgroundTransparency = child.BackgroundTransparency}, 0.5)
        end
    end
end

Initialize()