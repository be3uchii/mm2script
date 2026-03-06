local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local Mouse = localPlayer:GetMouse()
local DamageEvent = ReplicatedStorage.Remotes.Attacks.hit

local enabled = false
local headSize = 50
local renderConnection = nil

local defaultSize = Vector3.new(2, 2, 1)
local expandedSize = Vector3.new(headSize, headSize, headSize)

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer.PlayerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 30)
button.Position = UDim2.new(0, 10, 0, 10)
button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
button.Text = "HITBOX: OFF"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 12
button.Parent = screenGui

local function clearHitboxes()
	for _, v in Players:GetPlayers() do
		local char = v.Character
		if not char then continue end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end
		hrp.Size = defaultSize
		hrp.Transparency = 1
		hrp.CanCollide = true
		local box = hrp:FindFirstChild("HitboxVisual")
		if box then box:Destroy() end
	end
end

local function updateHitboxes()
	for _, v in Players:GetPlayers() do
		if v == localPlayer then continue end
		local char = v.Character
		if not char then continue end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end
		hrp.Size = expandedSize
		hrp.Transparency = 1
		hrp.CanCollide = false
		if not hrp:FindFirstChild("HitboxVisual") then
			local box = Instance.new("SelectionBox")
			box.Name = "HitboxVisual"
			box.Adornee = hrp
			box.Color3 = Color3.fromRGB(0, 100, 255)
			box.LineThickness = 0.05
			box.Parent = hrp
		end
	end
end

button.MouseButton1Click:Connect(function()
	enabled = not enabled
	button.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	button.Text = enabled and "HITBOX: ON" or "HITBOX: OFF"
	if enabled then
		renderConnection = RunService.RenderStepped:Connect(updateHitboxes)
	else
		if renderConnection then renderConnection:Disconnect() renderConnection = nil end
		clearHitboxes()
	end
end)

Mouse.Button1Down:Connect(function()
	if not enabled then return end
	local myChar = localPlayer.Character
	if not myChar then return end
	local myHRP = myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	for _, v in Players:GetPlayers() do
		if v == localPlayer then continue end
		local char = v.Character
		if not char then continue end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChild("Humanoid")
		if hrp and hum and (hrp.Position - myHRP.Position).Magnitude < 50 then
			DamageEvent:FireServer(hum)
		end
	end
end)

local function onCharacterAdded()
	if enabled then updateHitboxes() end
end

for _, player in Players:GetPlayers() do
	player.CharacterAdded:Connect(onCharacterAdded)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(onCharacterAdded)
end)

Players.PlayerRemoving:Connect(function()
	if enabled then updateHitboxes() end
end)

clearHitboxes()
