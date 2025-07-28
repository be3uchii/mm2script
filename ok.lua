local RayfieldLibrary = {
	Theme = {
		Default = {
			TextColor = Color3.fromRGB(240, 240, 240),
			Background = Color3.fromRGB(25, 25, 25),
			Topbar = Color3.fromRGB(34, 34, 34),
			Shadow = Color3.fromRGB(20, 20, 20),
			TabBackground = Color3.fromRGB(80, 80, 80),
			TabStroke = Color3.fromRGB(85, 85, 85),
			TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
			TabTextColor = Color3.fromRGB(240, 240, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
			ElementBackground = Color3.fromRGB(35, 35, 35),
			ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
			SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
			ElementStroke = Color3.fromRGB(50, 50, 50),
			SecondaryElementStroke = Color3.fromRGB(40, 40, 40)
		}
	}
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Rayfield = Instance.new("ScreenGui")
Rayfield.Name = "Rayfield"
Rayfield.DisplayOrder = 100
Rayfield.Parent = gethui and gethui() or CoreGui

local minSize = Vector2.new(1024, 768)
local useMobileSizing = Rayfield.AbsoluteSize.X < minSize.X and Rayfield.AbsoluteSize.Y < minSize.Y
local dragOffset = useMobileSizing and 150 or 255
local Minimised = false
local Hidden = false
local Debounce = false
local searchOpen = false

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = Rayfield
Main.Size = UDim2.new(0, 390, 0, 90)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = RayfieldLibrary.Theme.Default.Background
Main.ClipsDescendants = true

local Drag = Instance.new("Frame")
Drag.Name = "Drag"
Drag.Parent = Rayfield
Drag.Size = UDim2.new(0, 100, 0, 4)
Drag.Position = UDim2.new(0.5, 0, 0.5, dragOffset)
Drag.BackgroundColor3 = RayfieldLibrary.Theme.Default.TextColor
Drag.BackgroundTransparency = 0.7

local DragInteract = Instance.new("TextButton")
DragInteract.Name = "Interact"
DragInteract.Parent = Drag
DragInteract.Size = UDim2.new(1, 0, 1, 0)
DragInteract.BackgroundTransparency = 1
DragInteract.Text = ""

local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Parent = Main
Topbar.Size = UDim2.new(1, 0, 0, 30)
Topbar.BackgroundColor3 = RayfieldLibrary.Theme.Default.Topbar
Topbar.BackgroundTransparency = 1

local CornerRepair = Instance.new("Frame")
CornerRepair.Name = "CornerRepair"
CornerRepair.Parent = Topbar
CornerRepair.Size = UDim2.new(1, 0, 0, 5)
CornerRepair.Position = UDim2.new(0, 0, 1, 0)
CornerRepair.BackgroundColor3 = RayfieldLibrary.Theme.Default.Topbar
CornerRepair.BackgroundTransparency = 1

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Topbar
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Интерфейс Rayfield"
Title.TextColor3 = RayfieldLibrary.Theme.Default.TextColor
Title.TextTransparency = 1
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Parent = Topbar
Divider.Size = UDim2.new(0, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 1, 0)
Divider.BackgroundColor3 = RayfieldLibrary.Theme.Default.ElementStroke

local Search = Instance.new("ImageButton")
Search.Name = "Search"
Search.Parent = Topbar
Search.Size = UDim2.new(0, 20, 0, 20)
Search.Position = UDim2.new(1, -90, 0.5, -10)
Search.BackgroundTransparency = 1
Search.Image = "rbxassetid://3944680095"
Search.ImageColor3 = RayfieldLibrary.Theme.Default.TextColor
Search.ImageTransparency = 1

local Settings = Instance.new("ImageButton")
Settings.Name = "Settings"
Settings.Parent = Topbar
Settings.Size = UDim2.new(0, 20, 0, 20)
Settings.Position = UDim2.new(1, -120, 0.5, -10)
Settings.BackgroundTransparency = 1
Settings.Image = "rbxassetid://3944680095"
Settings.ImageColor3 = RayfieldLibrary.Theme.Default.TextColor
Settings.ImageTransparency = 1

local ChangeSize = Instance.new("ImageButton")
ChangeSize.Name = "ChangeSize"
ChangeSize.Parent = Topbar
ChangeSize.Size = UDim2.new(0, 20, 0, 20)
ChangeSize.Position = UDim2.new(1, -60, 0.5, -10)
ChangeSize.BackgroundTransparency = 1
ChangeSize.Image = "rbxassetid://3944680095"
ChangeSize.ImageColor3 = RayfieldLibrary.Theme.Default.TextColor
ChangeSize.ImageTransparency = 1

local Hide = Instance.new("ImageButton")
Hide.Name = "Hide"
Hide.Parent = Topbar
Hide.Size = UDim2.new(0, 20, 0, 20)
Hide.Position = UDim2.new(1, -30, 0.5, -10)
Hide.BackgroundTransparency = 1
Hide.Image = "rbxassetid://3944680095"
Hide.ImageColor3 = RayfieldLibrary.Theme.Default.TextColor
Hide.ImageTransparency = 1

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = Main
Shadow.Size = UDim2.new(1, 50, 1, 50)
Shadow.Position = UDim2.new(0, -25, 0, -25)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://3944680095"
Shadow.ImageColor3 = RayfieldLibrary.Theme.Default.Shadow
Shadow.ImageTransparency = 0.6

local Elements = Instance.new("Frame")
Elements.Name = "Elements"
Elements.Parent = Main
Elements.Size = UDim2.new(1, 0, 1, -30)
Elements.Position = UDim2.new(0, 0, 0, 30)
Elements.BackgroundTransparency = 1
Elements.ClipsDescendants = true

local UIPageLayout = Instance.new("UIPageLayout")
UIPageLayout.Parent = Elements
UIPageLayout.EasingStyle = Enum.EasingStyle.Exponential
UIPageLayout.TweenTime = 0.5

local TabList = Instance.new("Frame")
TabList.Name = "TabList"
TabList.Parent = Main
TabList.Size = UDim2.new(1, 0, 0, 30)
TabList.Position = UDim2.new(0, 0, 0, 0)
TabList.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = TabList
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Parent = Main
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundTransparency = 1

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Name = "Title"
LoadingTitle.Parent = LoadingFrame
LoadingTitle.Size = UDim2.new(1, 0, 0, 30)
LoadingTitle.Position = UDim2.new(0, 0, 0.3, 0)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Text = "Интерфейс Rayfield"
LoadingTitle.TextColor3 = RayfieldLibrary.Theme.Default.TextColor
LoadingTitle.TextSize = 20
LoadingTitle.Font = Enum.Font.SourceSansBold
LoadingTitle.TextTransparency = 0

local LoadingSubtitle = Instance.new("TextLabel")
LoadingSubtitle.Name = "Subtitle"
LoadingSubtitle.Parent = LoadingFrame
LoadingSubtitle.Size = UDim2.new(1, 0, 0, 20)
LoadingSubtitle.Position = UDim2.new(0, 0, 0.4, 0)
LoadingSubtitle.BackgroundTransparency = 1
LoadingSubtitle.Text = "от Sirius"
LoadingSubtitle.TextColor3 = RayfieldLibrary.Theme.Default.TextColor
LoadingSubtitle.TextSize = 15
LoadingSubtitle.Font = Enum.Font.SourceSans
LoadingSubtitle.TextTransparency = 0

local LoadingVersion = Instance.new("TextLabel")
LoadingVersion.Name = "Version"
LoadingVersion.Parent = LoadingFrame
LoadingVersion.Size = UDim2.new(1, 0, 0, 20)
LoadingVersion.Position = UDim2.new(0, 0, 0.5, 0)
LoadingVersion.BackgroundTransparency = 1
LoadingVersion.Text = "Версия 1.68"
LoadingVersion.TextColor3 = RayfieldLibrary.Theme.Default.TextColor
LoadingVersion.TextSize = 12
LoadingVersion.Font = Enum.Font.SourceSans
LoadingVersion.TextTransparency = 0

local SearchFrame = Instance.new("Frame")
SearchFrame.Name = "Search"
SearchFrame.Parent = Main
SearchFrame.Size = UDim2.new(1, 0, 0, 80)
SearchFrame.Position = UDim2.new(0.5, 0, 0, 70)
SearchFrame.BackgroundColor3 = RayfieldLibrary.Theme.Default.TextColor
SearchFrame.BackgroundTransparency = 1
SearchFrame.Visible = false

local SearchShadow = Instance.new("ImageLabel")
SearchShadow.Name = "Shadow"
SearchShadow.Parent = SearchFrame
SearchShadow.Size = UDim2.new(1, 50, 1, 50)
SearchShadow.Position = UDim2.new(0, -25, 0, -25)
SearchShadow.BackgroundTransparency = 1
SearchShadow.Image = "rbxassetid://3944680095"
SearchShadow.ImageColor3 = RayfieldLibrary.Theme.Default.TextColor
SearchShadow.ImageTransparency = 1

local SearchInput = Instance.new("TextBox")
SearchInput.Name = "Input"
SearchInput.Parent = SearchFrame
SearchInput.Size = UDim2.new(1, -40, 0, 30)
SearchInput.Position = UDim2.new(0, 40, 0, 5)
SearchInput.BackgroundTransparency = 1
SearchInput.TextColor3 = RayfieldLibrary.Theme.Default.TextColor
SearchInput.PlaceholderColor3 = RayfieldLibrary.Theme.Default.TextColor
SearchInput.TextTransparency = 1
SearchInput.TextSize = 14
SearchInput.Font = Enum.Font.SourceSans
SearchInput.TextXAlignment = Enum.TextXAlignment.Left

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Name = "Search"
SearchIcon.Parent = SearchFrame
SearchIcon.Size = UDim2.new(0, 20, 0, 20)
SearchIcon.Position = UDim2.new(0, 10, 0.5, -10)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Image = "rbxassetid://3944680095"
SearchIcon.ImageColor3 = RayfieldLibrary.Theme.Default.TextColor
SearchIcon.ImageTransparency = 1

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Parent = SearchFrame
SearchStroke.Color = RayfieldLibrary.Theme.Default.SecondaryElementStroke
SearchStroke.Transparency = 1

local Prompt = Instance.new("Frame")
Prompt.Name = "Prompt"
Prompt.Parent = Rayfield
Prompt.Size = UDim2.new(0, 100, 0, 30)
Prompt.Position = UDim2.new(0.5, 0, 0.5, -50)
Prompt.BackgroundColor3 = RayfieldLibrary.Theme.Default.Background
Prompt.BackgroundTransparency = 1
Prompt.Visible = UserInputService.TouchEnabled

local PromptInteract = Instance.new("TextButton")
PromptInteract.Name = "Interact"
PromptInteract.Parent = Prompt
PromptInteract.Size = UDim2.new(1, 0, 1, 0)
PromptInteract.BackgroundTransparency = 1
PromptInteract.Text = ""

local PromptText = Instance.new("TextLabel")
PromptText.Name = "Text"
PromptText.Parent = Prompt
PromptText.Size = UDim2.new(1, 0, 1, 0)
PromptText.BackgroundTransparency = 1
PromptText.Text = "Открыть"
PromptText.TextColor3 = RayfieldLibrary.Theme.Default.TextColor
PromptText.TextTransparency = 1
PromptText.TextSize = 14
PromptText.Font = Enum.Font.SourceSans

local function makeDraggable(object, dragObject, enableTaptic, tapticOffset)
	local dragging = false
	local relative = nil
	local offset = Vector2.zero
	local screenGui = object:FindFirstAncestorWhichIsA("ScreenGui")
	if screenGui and screenGui.IgnoreGuiInset then
		offset = game:GetService("GuiService"):GetGuiInset()
	end

	if dragObject and enableTaptic then
		dragObject.MouseEnter:Connect(function()
			if not dragging and not Hidden then
				TweenService:Create(dragObject, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5, Size = UDim2.new(0, 120, 0, 4)}):Play()
			end
		end)

		dragObject.MouseLeave:Connect(function()
			if not dragging and not Hidden then
				TweenService:Create(dragObject, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7, Size = UDim2.new(0, 100, 0, 4)}):Play()
			end
		end)
	end

	dragObject.InputBegan:Connect(function(input, processed)
		if processed then return end
		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = true
			relative = object.AbsolutePosition + object.AbsoluteSize * object.AnchorPoint - UserInputService:GetMouseLocation()
			if enableTaptic and not Hidden then
				TweenService:Create(dragObject, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 110, 0, 4), BackgroundTransparency = 0}):Play()
			end
		end
	end)

	local inputEnded = UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end
		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = false
			if enableTaptic and not Hidden then
				TweenService:Create(dragObject, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.7}):Play()
			end
		end
	end)

	local renderStepped = RunService.RenderStepped:Connect(function()
		if dragging and not Hidden then
			local position = UserInputService:GetMouseLocation() + relative + offset
			TweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y)}):Play()
			TweenService:Create(dragObject.Parent, TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y + (useMobileSizing and tapticOffset[2] or tapticOffset[1]))}):Play()
		end
	end)

	object.Destroying:Connect(function()
		if inputEnded then inputEnded:Disconnect() end
		if renderStepped then renderStepped:Disconnect() end
	end)
end

local function CreateTab(TabSettings)
	local TabPage = Instance.new("Frame")
	TabPage.Name = TabSettings.Name
	TabPage.Parent = Elements
	TabPage.Size = UDim2.new(1, 0, 1, 0)
	TabPage.BackgroundTransparency = 1
	TabPage.Visible = false

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = TabPage
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 5)

	local TabButton = Instance.new("Frame")
	TabButton.Name = TabSettings.Name
	TabButton.Parent = TabList
	TabButton.Size = UDim2.new(0, 100, 1, 0)
	TabButton.BackgroundColor3 = RayfieldLibrary.Theme.Default.TabBackground
	TabButton.BackgroundTransparency = 0.7

	local TabButtonTitle = Instance.new("TextLabel")
	TabButtonTitle.Name = "Title"
	TabButtonTitle.Parent = TabButton
	TabButtonTitle.Size = UDim2.new(1, -30, 1, 0)
	TabButtonTitle.Position = UDim2.new(0, 30, 0, 0)
	TabButtonTitle.BackgroundTransparency = 1
	TabButtonTitle.Text = TabSettings.Name
	TabButtonTitle.TextColor3 = RayfieldLibrary.Theme.Default.TabTextColor
	TabButtonTitle.TextTransparency = 0.2
	TabButtonTitle.TextSize = 14
	TabButtonTitle.Font = Enum.Font.SourceSans
	TabButtonTitle.TextXAlignment = Enum.TextXAlignment.Left

	local TabButtonImage = Instance.new("ImageLabel")
	TabButtonImage.Name = "Image"
	TabButtonImage.Parent = TabButton
	TabButtonImage.Size = UDim2.new(0, 20, 0, 20)
	TabButtonImage.Position = UDim2.new(0, 5, 0.5, -10)
	TabButtonImage.BackgroundTransparency = 1
	TabButtonImage.Image = TabSettings.Image or "rbxassetid://0"
	TabButtonImage.ImageColor3 = RayfieldLibrary.Theme.Default.TabTextColor
	TabButtonImage.ImageTransparency = 0.2

	local TabButtonStroke = Instance.new("UIStroke")
	TabButtonStroke.Parent = TabButton
	TabButtonStroke.Color = RayfieldLibrary.Theme.Default.TabStroke
	TabButtonStroke.Transparency = 0.5

	local TabButtonInteract = Instance.new("TextButton")
	TabButtonInteract.Name = "Interact"
	TabButtonInteract.Parent = TabButton
	TabButtonInteract.Size = UDim2.new(1, 0, 1, 0)
	TabButtonInteract.BackgroundTransparency = 1
	TabButtonInteract.Text = ""

	TabButtonInteract.MouseButton1Click:Connect(function()
		for _, otherTab in ipairs(Elements:GetChildren()) do
			if otherTab ~= TabPage and otherTab:IsA("Frame") then
				otherTab.Visible = false
				local otherButton = TabList:FindFirstChild(otherTab.Name)
				if otherButton then
					TweenService:Create(otherButton, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = RayfieldLibrary.Theme.Default.TabBackground, BackgroundTransparency = 0.7}):Play()
					TweenService:Create(otherButton.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextColor3 = RayfieldLibrary.Theme.Default.TabTextColor, TextTransparency = 0.2}):Play()
					TweenService:Create(otherButton.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageColor3 = RayfieldLibrary.Theme.Default.TabTextColor, ImageTransparency = 0.2}):Play()
					TweenService:Create(otherButton.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
				end
			end
		end
		TabPage.Visible = true
		TweenService:Create(TabButton, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = RayfieldLibrary.Theme.Default.TabBackgroundSelected, BackgroundTransparency = 0}):Play()
		TweenService:Create(TabButton.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextColor3 = RayfieldLibrary.Theme.Default.SelectedTabTextColor, TextTransparency = 0}):Play()
		TweenService:Create(TabButton.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageColor3 = RayfieldLibrary.Theme.Default.SelectedTabTextColor, ImageTransparency = 0}):Play()
		TweenService:Create(TabButton.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		UIPageLayout:JumpTo(TabPage)
	end)

	return TabPage
end

local function openSearch()
	searchOpen = true
	SearchFrame.BackgroundTransparency = 1
	SearchShadow.ImageTransparency = 1
	SearchInput.TextTransparency = 1
	SearchIcon.ImageTransparency = 1
	SearchStroke.Transparency = 1
	SearchFrame.Size = UDim2.new(1, 0, 0, 80)
	SearchFrame.Position = UDim2.new(0.5, 0, 0, 70)
	SearchFrame.Visible = true

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			tabbtn.Interact.Visible = false
			TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
			TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
			TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
			TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		end
	end

	SearchInput:CaptureFocus()
	TweenService:Create(SearchShadow, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {ImageTransparency = 0.95}):Play()
	TweenService:Create(SearchFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0, 57), BackgroundTransparency = 0.9}):Play()
	TweenService:Create(SearchStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.8}):Play()
	TweenService:Create(SearchInput, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
	TweenService:Create(SearchIcon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.5}):Play()
	TweenService:Create(SearchFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -35, 0, 35)}):Play()
end

local function closeSearch()
	searchOpen = false
	TweenService:Create(SearchFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundTransparency = 1, Size = UDim2.new(1, -55, 0, 30)}):Play()
	TweenService:Create(SearchIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	TweenService:Create(SearchShadow, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	TweenService:Create(SearchStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
	TweenService:Create(SearchInput, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			tabbtn.Interact.Visible = true
			if Elements.UIPageLayout.CurrentPage == tabbtn.Parent:FindFirstChild(tabbtn.Name) then
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			else
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
			end
		end
	end
end

local function Minimise()
	if Debounce then return end
	Debounce = true
	Minimised = true
	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 390, 0, 90)}):Play()
	TweenService:Create(Drag, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0.5, dragOffset)}):Play()
	Elements.Visible = false
	Topbar.Visible = false
	task.wait(0.7)
	Debounce = false
end

local function Maximise()
	if Debounce then return end
	Debounce = true
	Minimised = false
	Topbar.Visible = true
	Elements.Visible = true
	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Size = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475)}):Play()
	TweenService:Create(Drag, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0.5, dragOffset)}):Play()
	task.wait(0.7)
	Debounce = false
end

local function Hide()
	if Debounce then return end
	Debounce = true
	Hidden = true
	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Shadow, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
	TweenService:Create(Topbar, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(CornerRepair, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Divider, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(Search, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
	TweenService:Create(Settings, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
	TweenService:Create(ChangeSize, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
	TweenService:Create(Hide, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" then
			TweenService:Create(tabbtn, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
			TweenService:Create(tabbtn.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
			TweenService:Create(tabbtn.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
			TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		end
	end
	if UserInputService.TouchEnabled then
		TweenService:Create(Prompt, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.5}):Play()
		TweenService:Create(PromptText, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	end
	TweenService:Create(Drag, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
	task.wait(0.7)
	Main.Visible = false
	Debounce = false
end

local function Unhide()
	if Debounce then return end
	Debounce = true
	Hidden = false
	Main.Visible = true
	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Shadow, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()
	TweenService:Create(Topbar, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(CornerRepair, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Divider, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	TweenService:Create(Search, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	TweenService:Create(Settings, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	TweenService:Create(ChangeSize, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	TweenService:Create(Hide, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" then
			if Elements.UIPageLayout.CurrentPage == tabbtn.Parent:FindFirstChild(tabbtn.Name) then
				TweenService:Create(tabbtn, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			else
				TweenService:Create(tabbtn, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
			end
		end
	end
	if UserInputService.TouchEnabled then
		TweenService:Create(Prompt, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
		TweenService:Create(PromptText, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	end
	TweenService:Create(Drag, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
	task.wait(0.7)
	Debounce = false
end

function RayfieldLibrary:CreateWindow(Settings)
	local Window = {}
	local Tab1 = CreateTab({Name = "Пример Вкладки 1", Image = "rbxassetid://3944680095"})
	local Tab2 = CreateTab({Name = "Пример Вкладки 2", Image = "rbxassetid://3944680095"})

	Tab1.Visible = true
	Elements.UIPageLayout.CurrentPage = Tab1

	makeDraggable(Main, DragInteract, true, {255, 150})

	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Size = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475)}):Play()
	TweenService:Create(Shadow, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()
	TweenService:Create(Topbar, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(CornerRepair, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Divider, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, 1)}):Play()
	TweenService:Create(Title, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	TweenService:Create(Search, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	TweenService:Create(Settings, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	TweenService:Create(ChangeSize, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	TweenService:Create(Hide, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	TweenService:Create(Drag, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
	TweenService:Create(LoadingFrame.Title, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

	ChangeSize.MouseButton1Click:Connect(function()
		if Debounce then return end
		if Minimised then
			Maximise()
		else
			Minimise()
		end
	end)

	Search.MouseButton1Click:Connect(function()
		if searchOpen then
			closeSearch()
		else
			openSearch()
		end
	end)

	PromptInteract.MouseButton1Click:Connect(function()
		if Debounce then return end
		if Hidden then
			Unhide()
		end
	end)

	for _, TopbarButton in ipairs(Topbar:GetChildren()) do
		if TopbarButton.ClassName == "ImageButton" and TopbarButton.Name ~= 'Icon' then
			TopbarButton.MouseEnter:Connect(function()
				TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
			end)
			TopbarButton.MouseLeave:Connect(function()
				TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
			end)
		end
	end

	return Window
end

return RayfieldLibrary