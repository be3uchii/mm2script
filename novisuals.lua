local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = "CharacterActions"
RemoteEvent.Parent = ReplicatedStorage

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ActionMenu"
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.15, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ТАНЦЫ И ДЕЙСТВИЯ"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 14
MinimizeButton.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

local Tabs = {"Танцы", "Трансформации", "Движения"}

local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 40)
TabButtons.Position = UDim2.new(0, 0, 0, 30)
TabButtons.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabButtons.Parent = MainFrame

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -10, 1, -80)
ContentFrame.Position = UDim2.new(0, 5, 0, 70)
ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ContentFrame.ScrollBarThickness = 5
ContentFrame.Parent = MainFrame

local Dances = {
    ["Танец 1"] = 5917459365,
    ["Танец 2"] = 5918726674,
    ["Танец 3"] = 6161636824,
    ["Танец 4"] = 6161680872,
    ["Танец 5"] = 6161704337,
    ["Танец 6"] = 6161721565,
    ["Танец 7"] = 6161743543,
    ["Танец 8"] = 6161774512,
    ["Танец 9"] = 6161798456,
    ["Танец 10"] = 6161823345,
    ["Танец 11"] = 6161845678,
    ["Танец 12"] = 6161876543
}

local Transformations = {
    ["Гигант"] = {Scale = 1.5},
    ["Карлик"] = {Scale = 0.7},
    ["Невидимка"] = {Transparency = 0.9},
    ["Призрак"] = {Transparency = 0.7},
    ["Тяжелый"] = {Gravity = 2},
    ["Легкий"] = {Gravity = 0.5},
    ["Быстрый"] = {Speed = 30},
    ["Медленный"] = {Speed = 10}
}

local Movements = {
    ["Бег"] = {Speed = 30},
    ["Прыжки"] = {Jump = 100},
    ["Плавание"] = {Swim = 50},
    ["Полёт"] = {Gravity = 0},
    ["Супер прыжок"] = {Jump = 150},
    ["Медленный бег"] = {Speed = 15}
}

local CurrentAnimation
local isMinimized = false
local originalSize = MainFrame.Size

local function PlayDance(danceName)
    if CurrentAnimation then
        CurrentAnimation:Stop()
    end
    
    local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and Dances[danceName] then
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://"..Dances[danceName]
        CurrentAnimation = humanoid:LoadAnimation(animation)
        CurrentAnimation:Play()
        RemoteEvent:FireServer("PlayDance", Dances[danceName])
    end
end

local function Transform(transformationName)
    local transformData = Transformations[transformationName]
    if not transformData then return end
    
    local character = Player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if transformData.Scale then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * transformData.Scale
            end
        end
    end
    
    if transformData.Transparency then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = transformData.Transparency
            end
        end
    end
    
    if transformData.Gravity then
        humanoid.Gravity = transformData.Gravity
    end
    
    if transformData.Speed then
        humanoid.WalkSpeed = transformData.Speed
    end
    
    RemoteEvent:FireServer("Transform", transformationName)
end

local function ChangeMovement(movementName)
    local movementData = Movements[movementName]
    if not movementData then return end
    
    local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if movementData.Speed then
        humanoid.WalkSpeed = movementData.Speed
    end
    
    if movementData.Jump then
        humanoid.JumpPower = movementData.Jump
    end
    
    if movementData.Swim then
        humanoid.SwimSpeed = movementData.Swim
    end
    
    if movementData.Gravity then
        humanoid.Gravity = movementData.Gravity
    end
    
    RemoteEvent:FireServer("ChangeMovement", movementName)
end

local function CreateTabButtons()
    for i, tabName in ipairs(Tabs) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1/#Tabs, -2, 1, 0)
        button.Position = UDim2.new((i-1)/#Tabs, 0, 0, 0)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.Text = tabName
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.Gotham
        button.TextSize = 12
        button.Parent = TabButtons
        
        button.MouseButton1Click:Connect(function()
            ContentFrame:ClearAllChildren()
            local yOffset = 5
            
            if tabName == "Танцы" then
                for danceName in pairs(Dances) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -10, 0, 30)
                    btn.Position = UDim2.new(0, 5, 0, yOffset)
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Text = danceName
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 12
                    btn.Parent = ContentFrame
                    
                    btn.MouseButton1Click:Connect(function()
                        PlayDance(danceName)
                    end)
                    
                    yOffset = yOffset + 35
                end
            
            elseif tabName == "Трансформации" then
                for transformName in pairs(Transformations) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -10, 0, 30)
                    btn.Position = UDim2.new(0, 5, 0, yOffset)
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Text = transformName
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 12
                    btn.Parent = ContentFrame
                    
                    btn.MouseButton1Click:Connect(function()
                        Transform(transformName)
                    end)
                    
                    yOffset = yOffset + 35
                end
            
            elseif tabName == "Движения" then
                for movementName in pairs(Movements) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -10, 0, 30)
                    btn.Position = UDim2.new(0, 5, 0, yOffset)
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Text = movementName
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 12
                    btn.Parent = ContentFrame
                    
                    btn.MouseButton1Click:Connect(function()
                        ChangeMovement(movementName)
                    end)
                    
                    yOffset = yOffset + 35
                end
            end
            
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
        end)
    end
end

MinimizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        MainFrame.Size = originalSize
        ContentFrame.Visible = true
        TabButtons.Visible = true
    else
        originalSize = MainFrame.Size
        MainFrame.Size = UDim2.new(0, 300, 0, 30)
        ContentFrame.Visible = false
        TabButtons.Visible = false
    end
    isMinimized = not isMinimized
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

CreateTabButtons()
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

RemoteEvent.OnClientEvent:Connect(function(action, data, senderId)
    local sender = game:GetService("Players"):GetPlayerByUserId(senderId)
    if not sender or sender == Player then return end
    
    if action == "PlayDance" and sender.Character then
        local humanoid = sender.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local animation = Instance.new("Animation")
            animation.AnimationId = "rbxassetid://"..data
            local track = humanoid:LoadAnimation(animation)
            track:Play()
        end
    
    elseif action == "Transform" and sender.Character then
        local transformData = Transformations[data]
        if not transformData then return end
        
        local character = sender.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        if transformData.Scale then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * transformData.Scale
                end
            end
        end
        
        if transformData.Transparency then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = transformData.Transparency
                end
            end
        end
        
        if transformData.Gravity then
            humanoid.Gravity = transformData.Gravity
        end
        
        if transformData.Speed then
            humanoid.WalkSpeed = transformData.Speed
        end
    
    elseif action == "ChangeMovement" and sender.Character then
        local movementData = Movements[data]
        if not movementData then return end
        
        local humanoid = sender.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        if movementData.Speed then
            humanoid.WalkSpeed = movementData.Speed
        end
        
        if movementData.Jump then
            humanoid.JumpPower = movementData.Jump
        end
        
        if movementData.Swim then
            humanoid.SwimSpeed = movementData.Swim
        end
        
        if movementData.Gravity then
            humanoid.Gravity = movementData.Gravity
        end
    end
end)

if game:GetService("RunService"):IsServer() then
    local Players = game:GetService("Players")
    
    RemoteEvent.OnServerEvent:Connect(function(player, action, data)
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                RemoteEvent:FireClient(otherPlayer, action, data, player.UserId)
            end
        end
    end)
end