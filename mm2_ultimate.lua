local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.Parent = game.CoreGui
gui.Name = "MM2Ultimate"

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
loadingFrame.BackgroundTransparency = 0
loadingFrame.Parent = gui

local loadingBackground = Instance.new("ImageLabel")
loadingBackground.Size = UDim2.new(1, 0, 1, 0)
loadingBackground.Image = "rbxassetid://6062941947"
loadingBackground.BackgroundTransparency = 1
loadingBackground.ImageTransparency = 1
loadingBackground.Parent = loadingFrame

local loadingSpinner = Instance.new("ImageLabel")
loadingSpinner.Size = UDim2.new(0.2, 0, 0.2, 0)
loadingSpinner.Position = UDim2.new(0.4, 0, 0.4, 0)
loadingSpinner.Image = "rbxassetid://1234567890"
loadingSpinner.BackgroundTransparency = 1
loadingSpinner.Parent = loadingFrame

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(0.5, 0, 0.1, 0)
loadingText.Position = UDim2.new(0.25, 0, 0.65, 0)
loadingText.Text = "MM2 Ultimate Загружается..."
loadingText.TextColor3 = Color3.new(1, 1, 1)
loadingText.TextScaled = true
loadingText.BackgroundTransparency = 1
loadingText.Font = Enum.Font.Arcade
loadingText.Parent = loadingFrame

local tweenInfoFadeIn = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local tweenInfoSpinner = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
local tweenInfoFadeOut = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local bgFadeIn = TweenService:Create(loadingBackground, tweenInfoFadeIn, {ImageTransparency = 0})
local textFadeIn = TweenService:Create(loadingText, tweenInfoFadeIn, {TextTransparency = 0})
local spinnerFadeIn = TweenService:Create(loadingSpinner, tweenInfoFadeIn, {ImageTransparency = 0})
local spinnerRotate = TweenService:Create(loadingSpinner, tweenInfoSpinner, {Rotation = 360})

bgFadeIn:Play()
textFadeIn:Play()
spinnerFadeIn:Play()
spinnerRotate:Play()

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.BackgroundTransparency = 0.2
mainFrame.Visible = false
mainFrame.Parent = gui

local dragFrame = Instance.new("Frame")
dragFrame.Size = UDim2.new(1, 0, 0.1, 0)
dragFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
dragFrame.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Text = "MM2 Ultimate"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.BackgroundTransparency = 1
title.Font = Enum.Font.Arcade
title.Parent = dragFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.1, 0, 1, 0)
toggleButton.Position = UDim2.new(0.9, 0, 0, 0)
toggleButton.Text = "-"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
toggleButton.Parent = dragFrame

local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, 0, 0.9, 0)
tabsFrame.Position = UDim2.new(0, 0, 0.1, 0)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = mainFrame

local tabButtons = Instance.new("Frame")
tabButtons.Size = UDim2.new(1, 0, 0.1, 0)
tabButtons.BackgroundTransparency = 1
tabButtons.Parent = tabsFrame

local playerTabButton = Instance.new("TextButton")
playerTabButton.Size = UDim2.new(0.25, 0, 1, 0)
playerTabButton.Text = "Игрок"
playerTabButton.TextColor3 = Color3.new(1, 1, 1)
playerTabButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
playerTabButton.Parent = tabButtons

local murdererTabButton = Instance.new("TextButton")
murdererTabButton.Size = UDim2.new(0.25, 0, 1, 0)
murdererTabButton.Position = UDim2.new(0.25, 0, 0, 0)
murdererTabButton.Text = "Мардер"
murdererTabButton.TextColor3 = Color3.new(1, 1, 1)
murdererTabButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
murdererTabButton.Parent = tabButtons

local sheriffTabButton = Instance.new("TextButton")
sheriffTabButton.Size = UDim2.new(0.25, 0, 1, 0)
sheriffTabButton.Position = UDim2.new(0.5, 0, 0, 0)
sheriffTabButton.Text = "Шериф"
sheriffTabButton.TextColor3 = Color3.new(1, 1, 1)
sheriffTabButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
sheriffTabButton.Parent = tabButtons

local generalTabButton = Instance.new("TextButton")
generalTabButton.Size = UDim2.new(0.25, 0, 1, 0)
generalTabButton.Position = UDim2.new(0.75, 0, 0, 0)
generalTabButton.Text = "Общее"
generalTabButton.TextColor3 = Color3.new(1, 1, 1)
generalTabButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
generalTabButton.Parent = tabButtons

local playerTab = Instance.new("Frame")
playerTab.Size = UDim2.new(1, 0, 0.9, 0)
playerTab.Position = UDim2.new(0, 0, 0.1, 0)
playerTab.BackgroundTransparency = 1
playerTab.Visible = true
playerTab.Parent = tabsFrame

local murdererTab = Instance.new("Frame")
murdererTab.Size = UDim2.new(1, 0, 0.9, 0)
murdererTab.Position = UDim2.new(0, 0, 0.1, 0)
murdererTab.BackgroundTransparency = 1
murdererTab.Visible = false
murdererTab.Parent = tabsFrame

local sheriffTab = Instance.new("Frame")
sheriffTab.Size = UDim2.new(1, 0, 0.9, 0)
sheriffTab.Position = UDim2.new(0, 0, 0.1, 0)
sheriffTab.BackgroundTransparency = 1
sheriffTab.Visible = false
sheriffTab.Parent = tabsFrame

local generalTab = Instance.new("Frame")
generalTab.Size = UDim2.new(1, 0, 0.9, 0)
generalTab.Position = UDim2.new(0, 0, 0.1, 0)
generalTab.BackgroundTransparency = 1
generalTab.Visible = false
generalTab.Parent = tabsFrame

local function createToggle(parent, text, position, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.9, 0, 0.1, 0)
	frame.Position = position
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Arcade
	label.Parent = frame

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.2, 0, 1, 0)
	button.Position = UDim2.new(0.8, 0, 0, 0)
	button.Text = "Выкл"
	button.TextColor3 = Color3.new(1, 1, 1)
	button.BackgroundColor3 = Color3.new(0.5, 0, 0)
	button.Parent = frame

	local state = false
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = state and "Вкл" or "Выкл"
		button.BackgroundColor3 = state and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
		callback(state)
	end)
	return button
end

local function createSlider(parent, text, position, min, max, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.9, 0, 0.1, 0)
	frame.Position = position
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Arcade
	label.Parent = frame

	local slider = Instance.new("TextBox")
	slider.Size = UDim2.new(0.2, 0, 1, 0)
	slider.Position = UDim2.new(0.8, 0, 0, 0)
	slider.Text = tostring(min)
	slider.TextColor3 = Color3.new(1, 1, 1)
	slider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
	slider.Parent = frame

	slider.FocusLost:Connect(function()
		local value = tonumber(slider.Text) or min
		value = math.clamp(value, min, max)
		slider.Text = tostring(value)
		callback(value)
	end–
	return slider
end

local espEnabled = false
local espNames = false
local espDistance = false
local espMurderer = false
local espSheriff = false
local espInnocent = false
local espData = {}

local function getPlayerRole(player)
	local backpack = player:FindFirstChild("Backpack")
	local character = player.Character
	if backpack and character then
		if backpack:FindFirstChild("Knife") or (character and character:FindFirstChild("Knife")) then
			return "Murderer"
		elseif backpack:FindFirstChild("Gun") or (character and character:FindFirstChild("Gun")) then
			return "Sheriff"
		end
	end
	return "Innocent"
end

local function createESP(player)
	if player == LocalPlayer then return end
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = character.HumanoidRootPart
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = game.CoreGui

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.Text = player.Name
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextScaled = true
	nameLabel.Parent = billboard

	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
	distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
	distanceLabel.Text = "0m"
	distanceLabel.TextColor3 = Color3.new(1, 1, 1)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.TextScaled = true
	distanceLabel.Parent = billboard

	local highlight = Instance.new("Highlight")
	highlight.Adornee = character
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = character

	espData[player] = {billboard = billboard, highlight = highlight, nameLabel = nameLabel, distanceLabel = distanceLabel}
end

local function updateESP()
	for player, data in pairs(espData) do
		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			data.billboard:Destroy()
			data.highlight:Destroy()
			espData[player] = nil
		else
			local role = getPlayerRole(player)
			local color = (role == "Murderer" and Color3.new(1, 0, 0)) or (role == "Sheriff" and Color3.new(0, 0, 1)) or Color3.new(0, 1, 0)
			if (role == "Murderer" and not espMurderer) or (role == "Sheriff" and not espSheriff) or (role == "Innocent" and not espInnocent) then
				data.billboard.Enabled = false
				data.highlight.Enabled = false
			else
				data.billboard.Enabled = espEnabled
				data.highlight.Enabled = espEnabled
				data.highlight.FillColor = color
				data.nameLabel.Text = espNames and player.Name or ""
				local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude / 3
				data.distanceLabel.Text = espDistance and string.format("%.1f м", distance) or ""
			end
		end
	end
end

for _, player in pairs(Players:GetPlayers()) do
	createESP(player)
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(player)
	if espData[player] then
		espData[player].billboard:Destroy()
		espData[player].highlight:Destroy()
		espData[player] = nil
	end
end)

game:GetService("ReplicatedStorage").ChildAdded:Connect(function(child)
	if child.Name == "GameEvents" then
		child.ChildAdded:Connect(function(event)
			if event.Name == "RoundEnded" then
				espData = {}
				for _, player in pairs(Players:GetPlayers()) do
					if espData[player] then
						espData[player].billboard:Destroy()
						espData[player].highlight:Destroy()
						espData[player] = nil
					end
					createESP(player)
				end
			end
		end)
	end
end)

createToggle(playerTab, "Включить ESP", UDim2.new(0.05, 0, 0.05, 0), function(state)
	espEnabled = state
	updateESP()
end)
createToggle(playerTab, "Показывать имена", UDim2.new(0.05, 0, 0.15, 0), function(state)
	espNames = state
	updateESP()
end)
createToggle(playerTab, "Показывать расстояние", UDim2.new(0.05, 0, 0.25, 0), function(state)
	espDistance = state
	updateESP()
end)
createToggle(playerTab, "Показывать мардера", UDim2.new(0.05, 0, 0.35, 0), function(state)
	espMurderer = state
	updateESP()
end)
createToggle(playerTab, "Показывать шерифа", UDim2.new(0.05, 0, 0.45, 0), function(state)
	espSheriff = state
	updateESP()
end)
createToggle(playerTab, "Показывать игроков", UDim2.new(0.05, 0, 0.55, 0), function(state)
	espInnocent = state
	updateESP()
end)

local killAuraEnabled = false
local killAuraRange = 10
local function killAura()
	if not killAuraEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	local role = getPlayerRole(LocalPlayer)
	if role ~= "Murderer" then return end
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
			local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
			if distance <= killAuraRange then
				local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
				if knife then
					knife:Activate()
				end
			end
		end
	end
end

createToggle(murdererTab, "Включить киллауру", UDim2.new(0.05, 0, 0.05, 0), function(state)
	killAuraEnabled = state
end)
createSlider(murdererTab, "Дистанция киллауры", UDim2.new(0.05, 0, 0.15, 0), 5, 50, function(value)
	killAuraRange = value
end)

local fovEnabled = false
local fovSize = 100
local autoShootEnabled = false
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, fovSize, 0, fovSize)
fovCircle.Position = UDim2.new(0.5, -fovSize/2, 0.5, -fovSize/2)
fovCircle.BackgroundColor3 = Color3.new(0, 0, 1)
fovCircle.BackgroundTransparency = 0.8
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false
fovCircle.Parent = gui
fovCircle.ZIndex = 10

local function updateFOV()
	fovCircle.Size = UDim2.new(0, fovSize, 0, fovSize)
	fovCircle.Position = UDim2.new(0.5, -fovSize/2, 0.5, -fovSize/2)
	fovCircle.Visible = fovEnabled
end

local function autoShoot()
	if not autoShootEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	local role = getPlayerRole(LocalPlayer)
	if role ~= "Sheriff" then return end
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
			local role = getPlayerRole(player)
			if role == "Murderer" then
				local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
				if onScreen then
					local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
					local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					if distance <= fovSize / 2 then
						local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
						if gun then
							gun:Activate()
						end
					end
				end
			end
		end
	end
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and autoShootEnabled then
		autoShoot()
	end
end)

createToggle(sheriffTab, "Включить FOV", UDim2.new(0.05, 0, 0.05, 0), function(state)
	fovEnabled = state
	updateFOV()
end)
createSlider(sheriffTab, "Размер FOV", UDim2.new(0.05, 0, 0.15, 0), 50, 500, function(value)
	fovSize = value
	updateFOV()
end)
createToggle(sheriffTab, "Автострельба", UDim2.new(0.05, 0, 0.25, 0), function(state)
	autoShootEnabled = state
end)

local autoGunEnabled = false
local noclipEnabled = false
local speedHackEnabled = false
local speedValue = 50
local infJumpEnabled = false

local function autoPickupGun()
	if not autoGunEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	local gun = workspace:FindFirstChild("GunDrop")
	if gun and gun:FindFirstChild("CFrame") then
		LocalPlayer.Character.HumanoidRootPart.CFrame = gun.CFrame
		firetouchinterest(LocalPlayer.Character.HumanoidRootPart, gun, 0)
		firetouchinterest(LocalPlayer.Character.HumanoidRootPart, gun, 1)
	end
end

local function noclip()
	if not noclipEnabled or not LocalPlayer.Character then return end
	for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

local function speedHack()
	if not speedHackEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
	LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
end

local function infJump()
	if not infJumpEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end

createToggle(generalTab, "Автоподбор пистолета", UDim2.new(0.05, 0, 0.05, 0), function(state)
	autoGunEnabled = state
end)
createToggle(generalTab, "Noclip", UDim2.new(0.05, 0, 0.15, 0), function(state)
	noclipEnabled = state
end)
createToggle(generalTab, "Спидхак", UDim2.new(0.05, 0, 0.25, 0), function(state)
	speedHackEnabled = state
end)
createSlider(generalTab, "Скорость", UDim2.new(0.05, 0, 0.35, 0), 16, 200, function(value)
	speedValue = value
end)
createToggle(generalTab, "Бесконечный прыжок", UDim2.new(0.05, 0, 0.45, 0), function(state)
	infJumpEnabled = state
end)

RunService.RenderStepped:Connect(function()
	updateESP()
	killAura()
	autoPickupGun()
	noclip()
	speedHack()
	infJump()
end)

local dragging = false
local dragStart = nil
local startPos = nil

dragFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

dragFrame.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

dragFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

toggleButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
	toggleButton.Text = mainFrame.Visible and "-" or "+"
end)

playerTabButton.MouseButton1Click:Connect(function()
	playerTab.Visible = true
	murdererTab.Visible = false
	sheriffTab.Visible = false
	generalTab.Visible = false
end)

murdererTabButton.MouseButton1Click:Connect(function()
	playerTab.Visible = false
	murdererTab.Visible = true
	sheriffTab.Visible = false
	generalTab.Visible = false
end)

sheriffTabButton.MouseButton1Click:Connect(function()
	playerTab.Visible = false
	murdererTab.Visible = false
	sheriffTab.Visible = true
	generalTab.Visible = false
end)

generalTabButton.MouseButton1Click:Connect(function()
	playerTab.Visible = false
	murdererTab.Visible = false
	sheriffTab.Visible = false
	generalTab.Visible = true
end)

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.RightControl then
		mainFrame.Visible = not mainFrame.Visible
		toggleButton.Text = mainFrame.Visible and "-" or "+"
	end
end)

bgFadeIn.Completed:Connect(function()
	local bgFadeOut = TweenService:Create(loadingBackground, tweenInfoFadeOut, {ImageTransparency = 1})
	local textFadeOut = TweenService:Create(loadingText, tweenInfoFadeOut, {TextTransparency = 1})
	local spinnerFadeOut = TweenService:Create(loadingSpinner, tweenInfoFadeOut, {ImageTransparency = 1})
	bgFadeOut:Play()
	textFadeOut:Play()
	spinnerFadeOut:Play()
	spinnerRotate:Cancel()
	spinnerFadeOut.Completed:Connect(function()
		loadingFrame:Destroy()
		mainFrame.BackgroundTransparency = 1
		mainFrame.Visible = true
		local menuFadeIn = TweenService:Create(mainFrame, tweenInfoFadeIn, {BackgroundTransparency = 0.2})
		menuFadeIn:Play()
	end)
end)