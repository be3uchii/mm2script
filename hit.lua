local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")

local Enabled = false
local HeadSize = 50
local DamageEvent = game:GetService("ReplicatedStorage").Remotes.Attacks.hit

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player.PlayerGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 100, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Text = "HITBOX: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 12
ToggleButton.Parent = ScreenGui

local function clearHitboxes()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v.Character then
            local humanoidRootPart = v.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.Size = Vector3.new(2, 2, 1)
                humanoidRootPart.Transparency = 1
                humanoidRootPart.CanCollide = true
                
                local selectionBox = humanoidRootPart:FindFirstChild("HitboxVisual")
                if selectionBox then
                    selectionBox:Destroy()
                end
            end
        end
    end
end

local function updateHitboxes()
    if not Enabled then return end

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character then
            local humanoidRootPart = v.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.Size = Vector3.new(HeadSize, HeadSize, HeadSize)
                humanoidRootPart.Transparency = 1
                humanoidRootPart.CanCollide = false
                
                if not humanoidRootPart:FindFirstChild("HitboxVisual") then
                    local selectionBox = Instance.new("SelectionBox")
                    selectionBox.Name = "HitboxVisual"
                    selectionBox.Adornee = humanoidRootPart
                    selectionBox.Parent = humanoidRootPart
                    selectionBox.Color3 = Color3.fromRGB(0, 100, 255)
                    selectionBox.LineThickness = 0.05
                end
            end
        end
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "HITBOX: ON"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "HITBOX: OFF"
        clearHitboxes()
    end
end)

RunService.RenderStepped:Connect(updateHitboxes)

Mouse.Button1Down:Connect(function()
    if not Enabled then return end
    
    for i, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character then
            local targetHRP = v.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = v.Character:FindFirstChild("Humanoid")
            
            if targetHRP and humanoid then
                local distance = (targetHRP.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                if distance < 50 then
                    DamageEvent:FireServer(humanoid)
                end
            end
        end
    end
end)

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(updateHitboxes)
end)

game.Players.PlayerRemoving:Connect(updateHitboxes)

for _, player in pairs(game.Players:GetPlayers()) do
    player.CharacterAdded:Connect(updateHitboxes)
end

clearHitboxes()