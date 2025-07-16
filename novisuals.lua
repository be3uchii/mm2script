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
Title.Text = "ТАНЦЫ И ТРАНСФОРМАЦИИ"
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

local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 40)
TabButtons.Position = UDim2.new(0, 0, 0, 30)
TabButtons.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabButtons.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -10, 1, -80)
ContentFrame.Position = UDim2.new(0, 5, 0, 70)
ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ContentFrame.Parent = MainFrame

local Dances = {
    ["Танец 1"] = 5917459365,
    ["Танец 2"] = 5918726674
}

local Transformations = {
    ["Скорость"] = {Speed = 30},
    ["Карлик"] = {Scale = 0.7},
    ["Гигант"] = {Scale = 1.5}
}

local Tabs = {"Танцы", "Трансформации"}
local CurrentAnimation
local isMinimized = false
local originalSize = MainFrame.Size
local OriginalSizes = {}
local OriginalHumanoidProps = {}

local function SaveOriginalSizes(character)
    OriginalSizes[character] = {}
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            OriginalSizes[character][part] = part.Size
        end
    end
end

local function SaveOriginalHumanoidProps(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        OriginalHumanoidProps[character] = {
            WalkSpeed = humanoid.WalkSpeed,
            HipHeight = humanoid.HipHeight
        }
    end
end

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
    
    if not OriginalSizes[character] then
        SaveOriginalSizes(character)
        SaveOriginalHumanoidProps(character)
    end
    
    if transformData.Speed then
        humanoid.WalkSpeed = transformData.Speed
    end
    
    if transformData.Scale then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                local originalSize = OriginalSizes[character][part] or part.Size
                part.Size = originalSize * transformData.Scale
                if part:IsA("Part") and part.Name == "HumanoidRootPart" then
                    local hrp = part
                    hrp.Position = hrp.Position + Vector3.new(0, (transformData.Scale - 1) * 2, 0)
                end
            end
        end
        humanoid.HipHeight = OriginalHumanoidProps[character].HipHeight * transformData.Scale
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local currentCFrame = humanoidRootPart.CFrame
            humanoidRootPart.Size = OriginalSizes[character][humanoidRootPart] * transformData.Scale
            humanoidRootPart.CFrame = currentCFrame
        end
    end
    
    RemoteEvent:FireServer("Transform", transformationName)
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
            end
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

Player.CharacterAdded:Connect(function(character)
    OriginalSizes[character] = nil
    OriginalHumanoidProps[character] = nil
end)

CreateTabButtons()

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
        
        if not OriginalSizes[character] then
            SaveOriginalSizes(character)
            SaveOriginalHumanoidProps(character)
        end
        
        if transformData.Speed then
            humanoid.WalkSpeed = transformData.Speed
        end
        
        if transformData.Scale then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local originalSize = OriginalSizes[character][part] or part.Size
                    part.Size = originalSize * transformData.Scale
                    if part:IsA("Part") and part.Name == "HumanoidRootPart" then
                        local hrp = part
                        hrp.Position = hrp.Position + Vector3.new(0, (transformData.Scale - 1) * 2, 0)
                    end
                end
            end
            humanoid.HipHeight = OriginalHumanoidProps[character].HipHeight * transformData.Scale
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local currentCFrame = humanoidRootPart.CFrame
                humanoidRootPart.Size = OriginalSizes[character][humanoidRootPart] * transformData.Scale
                humanoidRootPart.CFrame = currentCFrame
            end
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