local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local localPlayer = Players.LocalPlayer

local enabled = false
local highlights = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 50, 0, 22)
button.Position = UDim2.new(0, 10, 0, 10)
button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
button.BackgroundTransparency = 0.3
button.Text = "OFF"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 10
button.Parent = screenGui
Instance.new("UICorner", button)

local function createHighlight(obj, color)
	if highlights[obj] then return end
	local h = Instance.new("Highlight")
	h.FillColor = color
	h.OutlineTransparency = 1
	h.FillTransparency = 0.6
	h.Adornee = obj
	h.Parent = Lighting
	highlights[obj] = h
end

local function clearAll()
	for _, h in highlights do
		h:Destroy()
	end
	table.clear(highlights)
end

local function updateESP()
	for _, player in Players:GetPlayers() do
		if player ~= localPlayer and player.Team then
			local teamName = player.Team.Name:lower()
			if teamName == "killer" or teamName == "survivors" then
				local character = player.Character
				if character and character:IsDescendantOf(workspace) then
					createHighlight(character, teamName == "killer" and Color3.new(1, 0, 0) or Color3.new(0, 1, 0))
				end
			end
		end
	end
	for _, desc in workspace:GetDescendants() do
		if desc:IsA("Model") and desc.Name:lower():find("generator") then
			createHighlight(desc, Color3.new(1, 0.5, 0))
		end
	end
end

local function toggleESP()
	enabled = not enabled
	button.BackgroundColor3 = enabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(150, 0, 0)
	button.Text = enabled and "ON" or "OFF"
	clearAll()
	if enabled then updateESP() end
end

button.MouseButton1Click:Connect(toggleESP)
