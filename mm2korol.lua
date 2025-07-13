local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

-- Создание основного GUI
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.Parent = game.CoreGui
gui.Name = "MM2Ultimate"

-- Улучшенная анимация загрузки
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
loadingFrame.BackgroundTransparency = 0
loadingFrame.Parent = gui

local loadingContainer = Instance.new("Frame")
loadingContainer.Size = UDim2.new(0.6, 0, 0.2, 0)
loadingContainer.Position = UDim2.new(0.2, 0, 0.4, 0)
loadingContainer.BackgroundTransparency = 1
loadingContainer.Parent = loadingFrame

local loadingBarBackground = Instance.new("Frame")
loadingBarBackground.Size = UDim2.new(1, 0, 0.2, 0)
loadingBarBackground.Position = UDim2.new(0, 0, 0.8, 0)
loadingBarBackground.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
loadingBarBackground.BorderSizePixel = 0
loadingBarBackground.Parent = loadingContainer

local loadingBar = Instance.new("Frame")
loadingBar.Size = UDim2.new(0, 0, 1, 0)
loadingBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
loadingBar.BorderSizePixel = 0
loadingBar.Parent = loadingBarBackground

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 0.7, 0)
loadingText.Position = UDim2.new(0, 0, 0, 0)
loadingText.Text = "MM2 Ultimate"
loadingText.TextColor3 = Color3.new(1, 1, 1)
loadingText.TextScaled = true
loadingText.Font = Enum.Font.GothamBold
loadingText.BackgroundTransparency = 1
loadingText.Parent = loadingContainer

local loadingSubText = Instance.new("TextLabel")
loadingSubText.Size = UDim2.new(1, 0, 0.3, 0)
loadingSubText.Position = UDim2.new(0, 0, 0.7, 0)
loadingSubText.Text = "Загрузка..."
loadingSubText.TextColor3 = Color3.new(0.8, 0.8, 0.8)
loadingSubText.TextScaled = true
loadingSubText.Font = Enum.Font.Gotham
loadingSubText.BackgroundTransparency = 1
loadingSubText.Parent = loadingContainer

-- Анимация загрузки
local loadingTween = TweenService:Create(loadingBar, TweenInfo.new(2.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Size = UDim2.new(1, 0, 1, 0)})
loadingTween:Play()

-- Создание основного меню (пока скрыто)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.BackgroundTransparency = 0.3
mainFrame.Visible = false
mainFrame.Parent = gui

local dragFrame = Instance.new("Frame")
dragFrame.Size = UDim2.new(1, 0, 0.1, 0)
dragFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
dragFrame.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Text = "MM2 Ultimate"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = dragFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.1, 0, 1, 0)
toggleButton.Position = UDim2.new(0.9, 0, 0, 0)
toggleButton.Text = "-"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
toggleButton.Font = Enum.Font.GothamBold
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
playerTabButton.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
playerTabButton.Font = Enum.Font.Gotham
playerTabButton.Parent = tabButtons

local murdererTabButton = Instance.new("TextButton")
murdererTabButton.Size = UDim2.new(0.25, 0, 1, 0)
murdererTabButton.Position = UDim2.new(0.25, 0, 0, 0)
murdererTabButton.Text = "Убийца"
murdererTabButton.TextColor3 = Color3.new(1, 1, 1)
murdererTabButton.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
murdererTabButton.Font = Enum.Font.Gotham
murdererTabButton.Parent = tabButtons

local sheriffTabButton = Instance.new("TextButton")
sheriffTabButton.Size = UDim2.new(0.25, 0, 1, 0)
sheriffTabButton.Position = UDim2.new(0.5, 0, 0, 0)
sheriffTabButton.Text = "Шериф"
sheriffTabButton.TextColor3 = Color3.new(1, 1, 1)
sheriffTabButton.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
sheriffTabButton.Font = Enum.Font.Gotham
sheriffTabButton.Parent = tabButtons

local generalTabButton = Instance.new("TextButton")
generalTabButton.Size = UDim2.new(0.25, 0, 1, 0)
generalTabButton.Position = UDim2.new(0.75, 0, 0, 0)
generalTabButton.Text = "Общее"
generalTabButton.TextColor3 = Color3.new(1, 1, 1)
generalTabButton.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
generalTabButton.Font = Enum.Font.Gotham
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

-- Функция для создания переключателей
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
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = frame

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.2, 0, 0.8, 0)
	button.Position = UDim2.new(0.8, 0, 0.1, 0)
	button.Text = "Выкл"
	button.TextColor3 = Color3.new(1, 1, 1)
	button.BackgroundColor3 = Color3.new(0.5, 0, 0)
	button.Font = Enum.Font.GothamBold
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

-- Функция для создания слайдеров
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
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = frame

	local slider = Instance.new("TextBox")
	slider.Size = UDim2.new(0.2, 0, 0.8, 0)
	slider.Position = UDim2.new(0.8, 0, 0.1, 0)
	slider.Text = tostring(min)
	slider.TextColor3 = Color3.new(1, 1, 1)
	slider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
	slider.Font = Enum.Font.Gotham
	slider.ClearTextOnFocus = false
	slider.Parent = frame

	slider.FocusLost:Connect(function()
		local value = tonumber(slider.Text) or min
		value = math.clamp(value, min, max)
		slider.Text = tostring(value)
		callback(value)
	end)
	return slider
end

-- ESP система
local espEnabled = false
local espNames = false
local espDistance = false
local espMurderer = true
local espSheriff = true
local espInnocent = true
local espData = {}

local function createESP(player)
	if player == LocalPlayer then return end
	local character = player.Character or player.CharacterAdded:Wait()
	if not character:FindFirstChild("HumanoidRootPart") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = character.HumanoidRootPart
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = espEnabled
	billboard.Parent = gui

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.Text = espNames and player.Name or ""
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = billboard

	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
	distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
	distanceLabel.Text = ""
	distanceLabel.TextColor3 = Color3.new(1, 1, 1)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.TextScaled = true
	distanceLabel.Font = Enum.Font.Gotham
	distanceLabel.Parent = billboard

	local highlight = Instance.new("Highlight")
	highlight.Adornee = character
	highlight.FillTransparency = 0.8
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = espEnabled
	highlight.Parent = character

	espData[player] = {
		billboard = billboard, 
		highlight = highlight, 
		nameLabel = nameLabel, 
		distanceLabel = distanceLabel,
		connection = player.CharacterAdded:Connect(function(newChar)
			task.wait(1) -- Даем время для загрузки персонажа
			if espData[player] then
				espData[player].billboard:Destroy()
				espData[player].highlight:Destroy()
				createESP(player)
			end
		end)
	}
end

local function updateESP()
	if not espEnabled then return end
	
	for player, data in pairs(espData) do
		if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			if data then
				data.billboard:Destroy()
				if data.highlight and data.highlight.Parent then
					data.highlight:Destroy()
				end
				if data.connection then
					data.connection:Disconnect()
				end
				espData[player] = nil
			end
		else
			local role = player:GetAttribute("Role") or "Innocent"
			local color = Color3.new(1, 0, 0) -- По умолчанию красный (на случай ошибки)
			
			if role == "Murderer" then
				color = Color3.new(1, 0, 0) -- Красный для убийцы
			elseif role == "Sheriff" then
				color = Color3.new(0, 0, 1) -- Синий для шерифа
			else
				color = Color3.new(0, 1, 0) -- Зеленый для невинных
			end
			
			-- Проверяем, нужно ли отображать этого игрока
			local shouldShow = (role == "Murderer" and espMurderer) or 
							 (role == "Sheriff" and espSheriff) or 
							 (role == "Innocent" and espInnocent)
			
			data.billboard.Enabled = shouldShow
			data.highlight.Enabled = shouldShow
			
			if shouldShow then
				data.highlight.FillColor = color
				data.highlight.OutlineColor = color
				
				-- Обновляем расстояние
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
					data.distanceLabel.Text = espDistance and string.format("%.1fм", distance) or ""
				else
					data.distanceLabel.Text = ""
				end
				
				-- Обновляем имя
				data.nameLabel.Text = espNames and player.Name or ""
				data.nameLabel.TextColor3 = color
			end
		end
	end
end

-- Инициализация ESP для всех игроков
for _, player in pairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		createESP(player)
	end
end

Players.PlayerAdded:Connect(function(player)
	createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
	if espData[player] then
		espData[player].billboard:Destroy()
		if espData[player].highlight and espData[player].highlight.Parent then
			espData[player].highlight:Destroy()
		end
		if espData[player].connection then
			espData[player].connection:Disconnect()
		end
		espData[player] = nil
	end
end)

-- Сброс ESP при завершении раунда
game:GetService("ReplicatedStorage").GameEvents.RoundEnded:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		if espData[player] then
			espData[player].billboard:Destroy()
			if espData[player].highlight and espData[player].highlight.Parent then
				espData[player].highlight:Destroy()
			end
			if espData[player].connection then
				espData[player].connection:Disconnect()
			end
			espData[player] = nil
		end
	end
	
	task.wait(2) -- Даем время для появления новых персонажей
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			createESP(player)
		end
	end
end)

-- Создание элементов управления ESP
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
createToggle(playerTab, "Показывать убийцу", UDim2.new(0.05, 0, 0.35, 0), function(state)
	espMurderer = state
	updateESP()
end)
createToggle(playerTab, "Показывать шерифа", UDim2.new(0.05, 0, 0.45, 0), function(state)
	espSheriff = state
	updateESP()
end)
createToggle(playerTab, "Показывать невинных", UDim2.new(0.05, 0, 0.55, 0), function(state)
	espInnocent = state
	updateESP()
end)

-- Система Kill Aura
local killAuraEnabled = false
local killAuraRange = 10

local function killAura()
	if not killAuraEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	local role = LocalPlayer:GetAttribute("Role")
	if role ~= "Murderer" then return end
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
			local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
			if distance <= killAuraRange then
				game:GetService("ReplicatedStorage").GameEvents.KnifeHit:FireServer(player)
			end
		end
	end
end

createToggle(murdererTab, "Включить Kill Aura", UDim2.new(0.05, 0, 0.05, 0), function(state)
	killAuraEnabled = state
end)
createSlider(murdererTab, "Дистанция Kill Aura", UDim2.new(0.05, 0, 0.15, 0), 5, 50, function(value)
	killAuraRange = value
end)

-- Система FOV и автострельбы
local fovEnabled = false
local fovSize = 100
local autoShootEnabled = false

local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, fovSize, 0, fovSize)
fovCircle.Position = UDim2.new(0.5, -fovSize/2, 0.5, -fovSize/2)
fovCircle.BackgroundColor3 = Color3.new(0, 0.5, 1)
fovCircle.BackgroundTransparency = 0.9
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
	local role = LocalPlayer:GetAttribute("Role")
	if role ~= "Sheriff" then return end
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
			local role = player:GetAttribute("Role")
			if role == "Murderer" then
				local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
				if onScreen then
					local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
					local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					if distance <= fovSize / 2 then
						game:GetService("ReplicatedStorage").GameEvents.GunShot:FireServer(player.Character.HumanoidRootPart.Position)
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

-- Общие функции
local autoGunEnabled = false
local noclipEnabled = false
local speedHackEnabled = false
local speedValue = 16 -- Начальное значение равно стандартной скорости

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

createToggle(generalTab, "Автоподбор пистолета", UDim2.new(0.05, 0, 0.05, 0), function(state)
	autoGunEnabled = state
end)
createToggle(generalTab, "Noclip", UDim2.new(0.05, 0, 0.15, 0), function(state)
	noclipEnabled = state
end)
createToggle(generalTab, "Спидхак", UDim2.new(0.05, 0, 0.25, 0), function(state)
	speedHackEnabled = state
	if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Возвращаем стандартную скорость при отключении
	end
end)
createSlider(generalTab, "Скорость", UDim2.new(0.05, 0, 0.35, 0), 16, 200, function(value)
	speedValue = value
	if speedHackEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.WalkSpeed = value
	end
end)

-- Основной цикл
RunService.RenderStepped:Connect(function()
	updateESP()
	
	if killAuraEnabled then
		killAura()
	end
	
	if autoGunEnabled then
		autoPickupGun()
	end
	
	if noclipEnabled then
		noclip()
	end
	
	if speedHackEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		speedHack()
	end
end)

-- Перемещение GUI
local dragging = false
local dragStart = nil
local startPos = nil

dragFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		game:GetService("TweenService"):Create(dragFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)}):Play()
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
		game:GetService("TweenService"):Create(dragFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)}):Play()
	end
end)

-- Переключение вкладок
local function switchTab(tab)
	playerTab.Visible = tab == "player"
	murdererTab.Visible = tab == "murderer"
	sheriffTab.Visible = tab == "sheriff"
	generalTab.Visible = tab == "general"
	
	playerTabButton.BackgroundColor3 = tab == "player" and Color3.new(0.3, 0.3, 0.3) or Color3.new(0.25, 0.25, 0.25)
	murdererTabButton.BackgroundColor3 = tab == "murderer" and Color3.new(0.3, 0.3, 0.3) or Color3.new(0.25, 0.25, 0.25)
	sheriffTabButton.BackgroundColor3 = tab == "sheriff" and Color3.new(0.3, 0.3, 0.3) or Color3.new(0.25, 0.25, 0.25)
	generalTabButton.BackgroundColor3 = tab == "general" and Color3.new(0.3, 0.3, 0.3) or Color3.new(0.25, 0.25, 0.25)
end

playerTabButton.MouseButton1Click:Connect(function()
	switchTab("player")
end)

murdererTabButton.MouseButton1Click:Connect(function()
	switchTab("murderer")
end)

sheriffTabButton.MouseButton1Click:Connect(function()
	switchTab("sheriff")
end)

generalTabButton.MouseButton1Click:Connect(function()
	switchTab("general")
end)

-- Переключение видимости GUI
toggleButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
	toggleButton.Text = mainFrame.Visible and "-" or "+"
end)

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.RightControl then
		mainFrame.Visible = not mainFrame.Visible
		toggleButton.Text = mainFrame.Visible and "-" or "+"
	end
end)

-- Завершение анимации загрузки и показ меню
loadingTween.Completed:Connect(function()
	-- Дополнительная анимация исчезновения
	local fadeOut = TweenService:Create(loadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
	fadeOut:Play()
	
	-- Анимация появления главного меню
	mainFrame.Visible = true
	mainFrame.BackgroundTransparency = 1
	local fadeIn = TweenService:Create(mainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.3})
	fadeIn:Play()
	
	-- Удаление загрузочного экрана после анимации
	fadeOut.Completed:Connect(function()
		loadingFrame:Destroy()
	end)
end)