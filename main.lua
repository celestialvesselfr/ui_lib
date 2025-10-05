local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local openColorPickerPopup = nil
local currentTheme = nil

local CONFIG = {

	WindowSize = UDim2.new(0, 650, 0, 500),
	MinWindowSize = Vector2.new(450, 350),
	AnimationSpeed = 0.3,

	BackgroundColor = Color3.fromRGB(30, 30, 30),
	SurfaceColor = Color3.fromRGB(44, 44, 46),
	AccentColor = Color3.fromRGB(10, 132, 255),
	SecondaryTextColor = Color3.fromRGB(152, 152, 157),
	TextColor = Color3.fromRGB(255, 255, 255),
	BorderColor = Color3.fromRGB(58, 58, 60),

	Padding = 12,
	ElementHeight = 40,
	ElementSpacing = 8,

	TabIcons = {
		Enabled = true,
		DefaultIcon = "rbxassetid://6022668888",
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0, 8, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5)
	},

	CornerRadius = 12,
	ShadowTransparency = 0.85,
	GlassTransparency = 0.15,

	NotificationCountdownDirection = "downwards",
}

local ICON_ASSETS = {
	Load = "rbxassetid://6031097220",
	Save = "rbxassetid://6031071052",
	Delete = "rbxassetid://10747384394",
	Success = "rbxassetid://6031068426"
}

-- Allow overriding default icons
function SetIconAssets(icons)
	if icons.Load then ICON_ASSETS.Load = icons.Load end
	if icons.Save then ICON_ASSETS.Save = icons.Save end
	if icons.Delete then ICON_ASSETS.Delete = icons.Delete end
	if icons.Success then ICON_ASSETS.Success = icons.Success end
end

local THEME_PRESETS = {
	["dark mode"] = {
		BackgroundColor = Color3.fromRGB(30, 30, 30),
		SurfaceColor = Color3.fromRGB(44, 44, 46),
		AccentColor = Color3.fromRGB(10, 132, 255),
		TextColor = Color3.fromRGB(255, 255, 255),
		SecondaryTextColor = Color3.fromRGB(152, 152, 157),
		BorderColor = Color3.fromRGB(58, 58, 60)
	},
	["light mode"] = {
		BackgroundColor = Color3.fromRGB(245, 245, 247),
		SurfaceColor = Color3.fromRGB(255, 255, 255),
		AccentColor = Color3.fromRGB(0, 122, 255),
		TextColor = Color3.fromRGB(28, 28, 30),
		SecondaryTextColor = Color3.fromRGB(142, 142, 147),
		BorderColor = Color3.fromRGB(209, 209, 214)
	},
	["vs code dark"] = {
		BackgroundColor = Color3.fromRGB(30, 30, 30),
		SurfaceColor = Color3.fromRGB(37, 37, 38),
		AccentColor = Color3.fromRGB(0, 122, 204),
		TextColor = Color3.fromRGB(212, 212, 212),
		SecondaryTextColor = Color3.fromRGB(140, 140, 140),
		BorderColor = Color3.fromRGB(60, 60, 60)
	},
	["dracula"] = {
		BackgroundColor = Color3.fromRGB(40, 42, 54),
		SurfaceColor = Color3.fromRGB(68, 71, 90),
		AccentColor = Color3.fromRGB(189, 147, 249),
		TextColor = Color3.fromRGB(248, 248, 242),
		SecondaryTextColor = Color3.fromRGB(98, 114, 164),
		BorderColor = Color3.fromRGB(68, 71, 90)
	},
	["nord"] = {
		BackgroundColor = Color3.fromRGB(46, 52, 64),
		SurfaceColor = Color3.fromRGB(59, 66, 82),
		AccentColor = Color3.fromRGB(136, 192, 208),
		TextColor = Color3.fromRGB(236, 239, 244),
		SecondaryTextColor = Color3.fromRGB(216, 222, 233),
		BorderColor = Color3.fromRGB(76, 86, 106)
	},
	["monokai"] = {
		BackgroundColor = Color3.fromRGB(39, 40, 34),
		SurfaceColor = Color3.fromRGB(73, 72, 62),
		AccentColor = Color3.fromRGB(249, 38, 114),
		TextColor = Color3.fromRGB(248, 248, 242),
		SecondaryTextColor = Color3.fromRGB(117, 113, 94),
		BorderColor = Color3.fromRGB(73, 72, 62)
	},
	["monkeytype dark"] = {
		BackgroundColor = Color3.fromRGB(50, 52, 55),
		SurfaceColor = Color3.fromRGB(44, 46, 49),
		AccentColor = Color3.fromRGB(226, 183, 20),
		TextColor = Color3.fromRGB(209, 208, 197),
		SecondaryTextColor = Color3.fromRGB(136, 140, 145),
		BorderColor = Color3.fromRGB(58, 61, 65)
	},
	["monkeytype light"] = {
		BackgroundColor = Color3.fromRGB(246, 245, 244),
		SurfaceColor = Color3.fromRGB(255, 255, 255),
		AccentColor = Color3.fromRGB(226, 183, 20),
		TextColor = Color3.fromRGB(44, 46, 49),
		SecondaryTextColor = Color3.fromRGB(107, 108, 110),
		BorderColor = Color3.fromRGB(224, 222, 217)
	},
	["monkeytype 9009"] = {
		BackgroundColor = Color3.fromRGB(237, 232, 225),
		SurfaceColor = Color3.fromRGB(218, 210, 202),
		AccentColor = Color3.fromRGB(180, 139, 125),
		TextColor = Color3.fromRGB(75, 74, 71),
		SecondaryTextColor = Color3.fromRGB(127, 125, 122),
		BorderColor = Color3.fromRGB(200, 193, 186)
	},
	["monkeytype bento"] = {
		BackgroundColor = Color3.fromRGB(245, 240, 230),
		SurfaceColor = Color3.fromRGB(255, 239, 210),
		AccentColor = Color3.fromRGB(255, 122, 144),
		TextColor = Color3.fromRGB(62, 47, 45),
		SecondaryTextColor = Color3.fromRGB(138, 111, 104),
		BorderColor = Color3.fromRGB(231, 213, 189)
	},
	["monkeytype bento dark"] = {
		BackgroundColor = Color3.fromRGB(38, 34, 32),
		SurfaceColor = Color3.fromRGB(58, 46, 44),
		AccentColor = Color3.fromRGB(255, 122, 144),
		TextColor = Color3.fromRGB(235, 220, 210),
		SecondaryTextColor = Color3.fromRGB(173, 150, 144),
		BorderColor = Color3.fromRGB(80, 62, 58)
	},
	["soft pastel"] = {
		BackgroundColor = Color3.fromRGB(249, 245, 250),
		SurfaceColor = Color3.fromRGB(255, 250, 255),
		AccentColor = Color3.fromRGB(203, 166, 247),
		TextColor = Color3.fromRGB(88, 76, 95),
		SecondaryTextColor = Color3.fromRGB(158, 143, 165),
		BorderColor = Color3.fromRGB(232, 220, 238)
	},
	["soft pastel dark"] = {
		BackgroundColor = Color3.fromRGB(42, 38, 50),
		SurfaceColor = Color3.fromRGB(58, 52, 70),
		AccentColor = Color3.fromRGB(203, 166, 247),
		TextColor = Color3.fromRGB(236, 225, 245),
		SecondaryTextColor = Color3.fromRGB(184, 170, 198),
		BorderColor = Color3.fromRGB(82, 74, 96)
	},
	["soft mint"] = {
		BackgroundColor = Color3.fromRGB(244, 250, 248),
		SurfaceColor = Color3.fromRGB(250, 255, 252),
		AccentColor = Color3.fromRGB(134, 205, 186),
		TextColor = Color3.fromRGB(75, 95, 88),
		SecondaryTextColor = Color3.fromRGB(143, 165, 158),
		BorderColor = Color3.fromRGB(220, 238, 232)
	},
	["soft mint dark"] = {
		BackgroundColor = Color3.fromRGB(34, 48, 44),
		SurfaceColor = Color3.fromRGB(46, 62, 57),
		AccentColor = Color3.fromRGB(134, 205, 186),
		TextColor = Color3.fromRGB(214, 235, 228),
		SecondaryTextColor = Color3.fromRGB(158, 190, 180),
		BorderColor = Color3.fromRGB(74, 102, 94)
	},
	["soft lavender"] = {
		BackgroundColor = Color3.fromRGB(248, 246, 255),
		SurfaceColor = Color3.fromRGB(255, 251, 255),
		AccentColor = Color3.fromRGB(186, 157, 255),
		TextColor = Color3.fromRGB(82, 72, 110),
		SecondaryTextColor = Color3.fromRGB(146, 135, 173),
		BorderColor = Color3.fromRGB(228, 221, 250)
	},
	["soft lavender dark"] = {
		BackgroundColor = Color3.fromRGB(43, 38, 59),
		SurfaceColor = Color3.fromRGB(58, 52, 78),
		AccentColor = Color3.fromRGB(186, 157, 255),
		TextColor = Color3.fromRGB(230, 223, 255),
		SecondaryTextColor = Color3.fromRGB(180, 170, 208),
		BorderColor = Color3.fromRGB(84, 75, 115)
	},
	["soft blue"] = {
		BackgroundColor = Color3.fromRGB(242, 248, 255),
		SurfaceColor = Color3.fromRGB(250, 254, 255),
		AccentColor = Color3.fromRGB(132, 176, 255),
		TextColor = Color3.fromRGB(68, 92, 128),
		SecondaryTextColor = Color3.fromRGB(132, 156, 189),
		BorderColor = Color3.fromRGB(212, 225, 245)
	},
	["soft blue dark"] = {
		BackgroundColor = Color3.fromRGB(32, 42, 58),
		SurfaceColor = Color3.fromRGB(44, 56, 74),
		AccentColor = Color3.fromRGB(132, 176, 255),
		TextColor = Color3.fromRGB(217, 230, 255),
		SecondaryTextColor = Color3.fromRGB(162, 184, 214),
		BorderColor = Color3.fromRGB(66, 84, 112)
	}
}

local PROTECTED_PRESETS = {
	["dark mode"] = true,
	["light mode"] = true,
	["vs code dark"] = true,
	["dracula"] = true,
	["nord"] = true,
	["monokai"] = true,
	["monkeytype dark"] = true,
	["monkeytype light"] = true,
	["monkeytype 9009"] = true,
	["monkeytype bento"] = true,
	["monkeytype bento dark"] = true,
	["soft pastel"] = true,
	["soft pastel dark"] = true,
	["soft mint"] = true,
	["soft mint dark"] = true,
	["soft lavender"] = true,
	["soft lavender dark"] = true,
	["soft blue"] = true,
	["soft blue dark"] = true
}

local function CreateTween(instance, properties, duration, easingStyle, easingDirection)
	local tweenInfo = TweenInfo.new(
		duration or CONFIG.AnimationSpeed,
		easingStyle or Enum.EasingStyle.Quint,
		easingDirection or Enum.EasingDirection.Out
	)
	return TweenService:Create(instance, tweenInfo, properties)
end

local function CreateRoundedFrame(parent, name)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = CONFIG.SurfaceColor
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, CONFIG.CornerRadius)
	corner.Parent = frame

	return frame
end

local function CreateTextLabel(parent, text, size)
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Text = text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = size
	label.TextColor3 = CONFIG.TextColor
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = parent
	return label
end

local UILibrary = {}
UILibrary.__index = UILibrary

function UILibrary.new(title)
	local self = setmetatable({}, UILibrary)

	self.Title = title
	self.Tabs = {}
	self.CurrentTab = nil
	self.IsMinimized = false
	self.IsDragging = false
	self.IsResizing = false

	self:CreateUI()
	self:SetupInteractions()

	return self
end

function UILibrary:CreateUI()

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UILibrary"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 999999999
	screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	self.ScreenGui = screenGui

	local window = CreateRoundedFrame(screenGui, "MainWindow")
	window.Size = CONFIG.WindowSize
	window.Position = UDim2.new(0.5, 0, 0.5, 0)
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.BackgroundColor3 = CONFIG.BackgroundColor
	window.BackgroundTransparency = CONFIG.GlassTransparency

	window.Size = UDim2.new(0, 0, 0, 0)
	self.Window = window

	task.spawn(function()
		task.wait(0.1)
		CreateTween(window, {Size = CONFIG.WindowSize}, 0.5):Play()
	end)

	local titleBar = CreateRoundedFrame(window, "TitleBar")
	titleBar.Size = UDim2.new(1, 0, 0, 44)
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.BackgroundColor3 = CONFIG.SurfaceColor
	titleBar.BackgroundTransparency = 0.3
	self.TitleBar = titleBar

	local controlsFrame = Instance.new("Frame")
	controlsFrame.Name = "Controls"
	controlsFrame.Size = UDim2.new(0, 60, 1, 0)
	controlsFrame.BackgroundTransparency = 1
	controlsFrame.Parent = titleBar

	local controls = {"Close", "Minimize", "Maximize"}
	local controlColors = {
		Color3.fromRGB(255, 95, 87),
		Color3.fromRGB(255, 189, 68),
		Color3.fromRGB(40, 205, 65)
	}

	for i, name in ipairs(controls) do
		local button = Instance.new("TextButton")
		button.Name = name
		button.Size = UDim2.new(0, 12, 0, 12)
		button.Position = UDim2.new(0, 12 + (i - 1) * 20, 0.5, 0)
		button.AnchorPoint = Vector2.new(0, 0.5)
		button.BackgroundColor3 = controlColors[i]
		button.BorderSizePixel = 0
		button.Text = ""
		button.AutoButtonColor = false
		button.Parent = controlsFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = button

		button.MouseEnter:Connect(function()
			CreateTween(button, {BackgroundColor3 = controlColors[i]:Lerp(Color3.new(1, 1, 1), 0.2)}, 0.25):Play()
		end)
		button.MouseLeave:Connect(function()
			CreateTween(button, {BackgroundColor3 = controlColors[i]}, 0.25):Play()
		end)
		self["Control" .. name] = button
	end

	local titleLabel = CreateTextLabel(titleBar, self.Title, 15)
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -140, 1, 0)
	titleLabel.Position = UDim2.new(0, 70, 0, 0)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.Font = Enum.Font.GothamBold

	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(0, 180, 1, -44)
	tabBar.Position = UDim2.new(0, 0, 0, 44)
	tabBar.BackgroundColor3 = CONFIG.SurfaceColor
	tabBar.BackgroundTransparency = 0.5
	tabBar.BorderSizePixel = 0
	tabBar.Parent = window
	self.TabBar = tabBar

	local tabContainer = Instance.new("ScrollingFrame")
	tabContainer.Name = "TabContainer"
	tabContainer.Size = UDim2.new(1, -12, 1, -12)
	tabContainer.Position = UDim2.new(0, 6, 0, 6)
	tabContainer.BackgroundTransparency = 1
	tabContainer.BorderSizePixel = 0
	tabContainer.ScrollBarThickness = 4
	tabContainer.ScrollBarImageColor3 = CONFIG.AccentColor
	tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabContainer.Parent = tabBar
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.Parent = tabContainer

	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, -192, 1, -56)
	contentArea.Position = UDim2.new(0, 186, 0, 50)
	contentArea.BackgroundTransparency = 1
	contentArea.BorderSizePixel = 0
	contentArea.Parent = window
	self.ContentArea = contentArea

	local resizeHandle = Instance.new("ImageButton")
	resizeHandle.Name = "ResizeHandle"
	resizeHandle.Size = UDim2.new(0, 20, 0, 20)
	resizeHandle.Position = UDim2.new(1, -20, 1, -20)
	resizeHandle.BackgroundTransparency = 1
	resizeHandle.Image = ""
	resizeHandle.Parent = window
	self.ResizeHandle = resizeHandle
end

function UILibrary:SetupInteractions()
	local dragging = false
	local dragStart
	local startPos

	self.TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = Vector2.new(input.Position.X, input.Position.Y)
			startPos = self.Window.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
			CreateTween(self.Window, {
				Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			}, 0.05):Play()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	self.ControlClose.MouseButton1Click:Connect(function()

		if self.TabBar then self.TabBar:Destroy() end
		if self.ContentArea then self.ContentArea:Destroy() end
		if self.ResizeHandle then self.ResizeHandle:Destroy() end

		CreateTween(self.Window, {Size = UDim2.new(0, 0, 0, 0)}, 0.3):Play()
		task.wait(0.3)
		self.ScreenGui:Destroy()
	end)

	self.ControlMinimize.MouseButton1Click:Connect(function()
		self:ToggleMinimize()
	end)

	self.ControlMaximize.MouseButton1Click:Connect(function()
		self:ToggleMaximize()
	end)

	local resizing = false
	local resizeStart: Vector2
	local originalSize: UDim2

	self.ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStart = Vector2.new(input.Position.X, input.Position.Y)
			originalSize = self.Window.Size
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - resizeStart
			local newWidth = math.max(CONFIG.MinWindowSize.X, originalSize.X.Offset + delta.X)
			local newHeight = math.max(CONFIG.MinWindowSize.Y, originalSize.Y.Offset + delta.Y)

			self.Window.Size = UDim2.new(0, newWidth, 0, newHeight)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
		end
	end)
end

function UILibrary:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    if self.IsMinimized then

        self.SizeBeforeMinimize = self.Window.Size

        CreateTween(self.Window, {Size = UDim2.new(0, 50, 0, 32)}, CONFIG.AnimationSpeed):Play()

        CreateTween(self.Window, {BackgroundTransparency = 1}, CONFIG.AnimationSpeed):Play()
        CreateTween(self.TitleBar, {BackgroundTransparency = 0.2}, CONFIG.AnimationSpeed):Play()
        CreateTween(self.TitleBar, {Size = UDim2.new(1, 0, 1, 0)}, CONFIG.AnimationSpeed):Play()

        self.TabBar.Visible = false
        self.ContentArea.Visible = false
        self.ResizeHandle.Visible = false

        if self.TitleBar:FindFirstChild("TitleLabel") then
            self.TitleBar.TitleLabel.Visible = false
        end
        self.ControlMinimize.Visible = false

        self.ControlClose.Position = UDim2.new(0, 8, 0.5, 0)
        self.ControlMaximize.Position = UDim2.new(0, 28, 0.5, 0)
    else

        local targetSize = self.SizeBeforeMinimize or CONFIG.WindowSize
        CreateTween(self.Window, {Size = targetSize}, CONFIG.AnimationSpeed):Play()

        CreateTween(self.Window, {BackgroundTransparency = 0.1}, CONFIG.AnimationSpeed):Play()
        CreateTween(self.TitleBar, {BackgroundTransparency = 0}, CONFIG.AnimationSpeed):Play()
        CreateTween(self.TitleBar, {Size = UDim2.new(1, 0, 0, 44)}, CONFIG.AnimationSpeed):Play()

        self.TabBar.Visible = true
        self.ContentArea.Visible = true
        self.ResizeHandle.Visible = true

        if self.TitleBar:FindFirstChild("TitleLabel") then
            self.TitleBar.TitleLabel.Visible = true
        end
        self.ControlMinimize.Visible = true

        self.ControlClose.Position = UDim2.new(0, 12, 0.5, 0)
        self.ControlMinimize.Position = UDim2.new(0, 32, 0.5, 0)
        self.ControlMaximize.Position = UDim2.new(0, 52, 0.5, 0)
    end
end

function UILibrary:ToggleMaximize()

	if self.IsMinimized then
		self:ToggleMinimize()
		return
	end

	if self.Window.Size == CONFIG.WindowSize then

		self.SizeBeforeMaximize = self.Window.Size

		CreateTween(self.Window, {
			Size = UDim2.new(0.95, 0, 0.95, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}, CONFIG.AnimationSpeed):Play()
	else
		CreateTween(self.Window, {
			Size = CONFIG.WindowSize,
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}, CONFIG.AnimationSpeed):Play()
	end
end

function UILibrary:AddTab(name, icon)
	local tab = {}
	tab.Name = name
	tab.Icon = icon or CONFIG.TabIcons.DefaultIcon
	tab.Elements = {}

	local tabButton = Instance.new("TextButton")
	local corner = Instance.new("UICorner")

	local tabIcon = nil
	if CONFIG.TabIcons.Enabled then
		tabIcon = Instance.new("ImageLabel")
		tabIcon.Name = "Icon"
		tabIcon.Size = CONFIG.TabIcons.Size
		tabIcon.Position = CONFIG.TabIcons.Position
		tabIcon.AnchorPoint = CONFIG.TabIcons.AnchorPoint
		tabIcon.BackgroundTransparency = 1
		tabIcon.Image = tab.Icon
		tabIcon.ImageColor3 = CONFIG.TextColor
		tabIcon.Parent = tabButton
	end

	local tabLabel = CreateTextLabel(tabButton, name, 14)

	tabButton.Name = name
	tabButton.Size = UDim2.new(1, -8, 0, 36)
	tabButton.BackgroundColor3 = CONFIG.SurfaceColor
	tabButton.BackgroundTransparency = 0.8
	tabButton.BorderSizePixel = 0
	tabButton.Text = ""
	tabButton.AutoButtonColor = false
	tabButton.Parent = self.TabBar.TabContainer
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = tabButton

	if tabIcon then
		tabLabel.Size = UDim2.new(1, -CONFIG.TabIcons.Size.X.Offset - 16, 1, 0)
		tabLabel.Position = UDim2.new(0, CONFIG.TabIcons.Size.X.Offset + 12, 0, 0)
	else
		tabLabel.Size = UDim2.new(1, -16, 1, 0)
		tabLabel.Position = UDim2.new(0, 8, 0, 0)
	end
	tabLabel.Font = Enum.Font.Gotham

	local contentLayout = Instance.new("UIListLayout")
	local tabContent = Instance.new("ScrollingFrame")
	local contentPadding = Instance.new("UIPadding")

	tabContent.Name = name .. "Content"
	tabContent.Size = UDim2.new(1, 0, 1, 0)
	tabContent.BackgroundTransparency = 1
	tabContent.BorderSizePixel = 0
	tabContent.ScrollBarThickness = 4
	tabContent.ScrollBarImageColor3 = CONFIG.AccentColor
	tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabContent.Visible = false
	tabContent.Parent = self.ContentArea
	tabContent.ClipsDescendants = true
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, CONFIG.ElementSpacing)
	contentLayout.Parent = tabContent
	contentPadding.PaddingLeft = UDim.new(0, CONFIG.Padding)
	contentPadding.PaddingRight = UDim.new(0, CONFIG.Padding)
	contentPadding.PaddingTop = UDim.new(0, CONFIG.Padding)
	contentPadding.PaddingBottom = UDim.new(0, CONFIG.Padding)
	contentPadding.Parent = tabContent

	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + CONFIG.Padding * 2)
	end)

	tab.Button = tabButton
	tab.Content = tabContent

	tabButton.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	tabButton.MouseEnter:Connect(function()
		if self.CurrentTab ~= tab then
			CreateTween(tabButton, {BackgroundTransparency = 0.6}, 0.25):Play()
		end
	end)

	tabButton.MouseLeave:Connect(function()
		if self.CurrentTab ~= tab then
			CreateTween(tabButton, {BackgroundTransparency = 0.8}, 0.25):Play()
		end
	end)

	table.insert(self.Tabs, tab)

	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end

	tab.AddToggle = function(_, name, default, callback)
		return self:CreateToggle(tab, name, default, callback)
	end

	tab.AddSlider = function(_, name, min, max, default, callback, allowDecimals)
		return self:CreateSlider(tab, name, min, max, default, callback, allowDecimals)
	end

	tab.AddButton = function(_, name, callback)
		return self:CreateButton(tab, name, callback)
	end

	tab.AddConfigCard = function(_, configName, lastUsed, callbacks)
		return self:CreateConfigCard(tab, configName, lastUsed, callbacks)
	end

	tab.AddInput = function(_, name, placeholder, callback)
		return self:CreateInput(tab, name, placeholder, callback)
	end

	tab.AddColorPicker = function(_, name, default, callback)
		return self:CreateColorPicker(tab, name, default, callback)
	end

	tab.AddDropdown = function(_, name, options, default, callback)
		return self:CreateDropdown(tab, name, options, default, callback)
	end

	tab.AddLabel = function(_, text)
		return self:CreateLabel(tab, text)
	end

	tab.AddKeybind = function(_, name, default, callback)
		return self:CreateKeybind(tab, name, default, callback)
	end

	return tab
end

function UILibrary:SelectTab(tab)

	if self.CurrentTab then
		CreateTween(self.CurrentTab.Button, {BackgroundTransparency = 0.8}, 0.2):Play()
		CreateTween(self.CurrentTab.Content, {Position = UDim2.new(0, -20, 0, 0)}, 0.2):Play()
		task.wait(0.1)
		self.CurrentTab.Content.Visible = false
	end

	self.CurrentTab = tab
	CreateTween(tab.Button, {BackgroundTransparency = 0.2}, 0.2):Play()
	tab.Content.Visible = true
	tab.Content.Position = UDim2.new(0, 20, 0, 0)
	CreateTween(tab.Content, {Position = UDim2.new(0, 0, 0, 0)}, 0.3):Play()
end

function UILibrary:CreateToggle(tab, name, default, callback)
	local container = CreateRoundedFrame(tab.Content, "Toggle_" .. name)
	container.Size = UDim2.new(1, 0, 0, CONFIG.ElementHeight)
	container.BackgroundTransparency = 0.3

	local label = CreateTextLabel(container, name, 14)
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.new(0, CONFIG.Padding, 0, 0)

	local switch = Instance.new("Frame")
	switch.Name = "Switch"
	switch.Size = UDim2.new(0, 44, 0, 24)
	switch.Position = UDim2.new(1, -52, 0.5, 0)
	switch.AnchorPoint = Vector2.new(0, 0.5)
	switch.BackgroundColor3 = CONFIG.BorderColor
	switch.BorderSizePixel = 0
	switch.Parent = container

	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(1, 0)
	switchCorner.Parent = switch

	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.Size = UDim2.new(0, 20, 0, 20)
	knob.Position = UDim2.new(0, 2, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.Parent = switch

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local enabled = default

	local function updateToggle(animate)
		local targetColor = enabled and CONFIG.AccentColor or CONFIG.BorderColor
		local targetPos = enabled and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)

		if animate then
			CreateTween(switch, {BackgroundColor3 = targetColor}, 0.2):Play()
			CreateTween(knob, {Position = targetPos}, 0.2):Play()
		else
			switch.BackgroundColor3 = targetColor
			knob.Position = targetPos
		end
	end

	updateToggle(false)

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.Parent = container

	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		updateToggle(true)
		callback(enabled)
	end)

	-- Return table object with SetValue method
	local toggleObject = {
		Container = container,
		SetValue = function(value)
			enabled = value
			updateToggle(false)
		end
	}

	return toggleObject
end

function UILibrary:CreateSlider(tab, name, min, max, default, callback, allowDecimals)
	allowDecimals = allowDecimals or false

	local container = CreateRoundedFrame(tab.Content, "Slider_" .. name)
	container.Size = UDim2.new(1, 0, 0, CONFIG.ElementHeight + 12)
	container.BackgroundTransparency = 0.3

	local label = CreateTextLabel(container, name, 14)
	label.Size = UDim2.new(0.7, 0, 0, 20)
	label.Position = UDim2.new(0, CONFIG.Padding, 0, 8)

	local valueBox = Instance.new("TextBox")
	valueBox.Name = "ValueBox"
	valueBox.Size = UDim2.new(0.3, -CONFIG.Padding, 0, 20)
	valueBox.Position = UDim2.new(0.7, 0, 0, 8)
	valueBox.BackgroundTransparency = 1
	valueBox.Text = tostring(default)
	valueBox.TextColor3 = CONFIG.AccentColor
	valueBox.TextXAlignment = Enum.TextXAlignment.Right
	valueBox.Font = Enum.Font.GothamBold
	valueBox.TextSize = 14
	valueBox.ClearTextOnFocus = false
	valueBox.Parent = container

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(1, -CONFIG.Padding * 2, 0, 4)
	track.Position = UDim2.new(0, CONFIG.Padding, 1, -14)
	track.AnchorPoint = Vector2.new(0, 0)
	track.BackgroundColor3 = CONFIG.BorderColor
	track.BorderSizePixel = 0
	track.Parent = container

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = CONFIG.AccentColor
	fill.BorderSizePixel = 0
	fill.Parent = track

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local thumb = Instance.new("Frame")
	thumb.Name = "Thumb"
	thumb.Size = UDim2.new(0, 16, 0, 16)
	thumb.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.BackgroundColor3 = Color3.new(1, 1, 1)
	thumb.BorderSizePixel = 0
	thumb.Parent = track

	local thumbCorner = Instance.new("UICorner")
	thumbCorner.CornerRadius = UDim.new(1, 0)
	thumbCorner.Parent = thumb

	local thumbShadow = Instance.new("UIStroke")
	thumbShadow.Name = "ThumbStroke"
	thumbShadow.Color = CONFIG.AccentColor
	thumbShadow.Thickness = 2
	thumbShadow.Transparency = 0.5
	thumbShadow.Parent = thumb

	local dragging = false
	local currentValue = default

	local function updateSlider(inputPosition)
		local relativeX = math.clamp((inputPosition - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)

		if allowDecimals then
			currentValue = min + (max - min) * relativeX
			currentValue = math.floor(currentValue * 100 + 0.5) / 100
		else
			currentValue = math.floor(min + (max - min) * relativeX)
		end

		local targetPos = UDim2.new(relativeX, 0, 0.5, 0)
		local targetFill = UDim2.new(relativeX, 0, 1, 0)

		CreateTween(thumb, {Position = targetPos}, 0.1):Play()
		CreateTween(fill, {Size = targetFill}, 0.1):Play()

		valueBox.Text = tostring(currentValue)
		callback(currentValue)
	end

	local function updateFromValue(value)
		currentValue = math.clamp(value, min, max)
		if not allowDecimals then
			currentValue = math.floor(currentValue)
		end

		local relativeX = (currentValue - min) / (max - min)
		local targetPos = UDim2.new(relativeX, 0, 0.5, 0)
		local targetFill = UDim2.new(relativeX, 0, 1, 0)

		CreateTween(thumb, {Position = targetPos}, 0.1):Play()
		CreateTween(fill, {Size = targetFill}, 0.1):Play()

		valueBox.Text = tostring(currentValue)
		callback(currentValue)
	end

	thumb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			CreateTween(thumb, {Size = UDim2.new(0, 20, 0, 20)}, 0.1):Play()
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
			dragging = false
			CreateTween(thumb, {Size = UDim2.new(0, 16, 0, 16)}, 0.1):Play()
		end
	end)

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateSlider(input.Position.X)
		end
	end)

	valueBox.FocusLost:Connect(function(enterPressed)
		local inputValue = tonumber(valueBox.Text)
		if inputValue then
			updateFromValue(inputValue)
		else
			valueBox.Text = tostring(currentValue)
		end
	end)

	valueBox.Focused:Connect(function()
		valueBox.SelectionStart = 1
		valueBox.CursorPosition = #valueBox.Text + 1
	end)

	-- Return table object with SetValue method
	local sliderObject = {
		Container = container,
		SetValue = function(value)
			updateFromValue(value)
		end
	}

	return sliderObject
end

function UILibrary:CreateButton(tab, name, callback)
	local button = CreateRoundedFrame(tab.Content, "Button_" .. name)
	button.Size = UDim2.new(1, 0, 0, CONFIG.ElementHeight)
	button.BackgroundColor3 = CONFIG.AccentColor
	button.BackgroundTransparency = 0
	local label = CreateTextLabel(button, name, 15)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)

	local clickButton = Instance.new("TextButton")
	clickButton.Size = UDim2.new(1, 0, 1, 0)
	clickButton.BackgroundTransparency = 1
	clickButton.Text = ""
	clickButton.Parent = button

	clickButton.MouseButton1Click:Connect(function()
		CreateTween(button, {Size = UDim2.new(1, -4, 0, CONFIG.ElementHeight - 2)}, 0.1):Play()
		task.wait(0.1)
		CreateTween(button, {Size = UDim2.new(1, 0, 0, CONFIG.ElementHeight)}, 0.1):Play()
		callback()
	end)

	clickButton.MouseEnter:Connect(function()
		CreateTween(button, {BackgroundColor3 = CONFIG.AccentColor:Lerp(Color3.new(1, 1, 1), 0.15)}, 0.2):Play()
	end)

	clickButton.MouseLeave:Connect(function()
		CreateTween(button, {BackgroundColor3 = CONFIG.AccentColor}, 0.2):Play()
	end)

	return button
end

function UILibrary:CreateConfigCard(tab, configName, lastUsed, callbacks)
	local container = CreateRoundedFrame(tab.Content, "ConfigCard_" .. configName)
	container.Size = UDim2.new(1, 0, 0, 70)
	container.BackgroundColor3 = CONFIG.SurfaceColor
	container.BackgroundTransparency = 0

	local nameLabel = CreateTextLabel(container, configName, 16)
	nameLabel.Size = UDim2.new(1, -100, 0, 25)
	nameLabel.Position = UDim2.new(0, CONFIG.Padding, 0, 8)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left

	local dateLabel = CreateTextLabel(container, lastUsed or "Never used", 12)
	dateLabel.Size = UDim2.new(1, -100, 0, 20)
	dateLabel.Position = UDim2.new(0, CONFIG.Padding, 0, 33)
	dateLabel.TextXAlignment = Enum.TextXAlignment.Left
	dateLabel.TextColor3 = CONFIG.TextColor:Lerp(CONFIG.BackgroundColor, 0.3)

	local actionsContainer = Instance.new("Frame")
	actionsContainer.Size = UDim2.new(0, 80, 1, -16)
	actionsContainer.Position = UDim2.new(1, -88, 0, 8)
	actionsContainer.BackgroundTransparency = 1
	actionsContainer.Parent = container

	local tooltip = Instance.new("Frame")
	tooltip.Size = UDim2.new(0, 100, 0, 30)
	tooltip.BackgroundColor3 = CONFIG.BackgroundColor
	tooltip.BorderSizePixel = 0
	tooltip.Visible = false
	tooltip.ZIndex = 1000
	tooltip.Parent = container

	local tooltipCorner = Instance.new("UICorner")
	tooltipCorner.CornerRadius = UDim.new(0, 6)
	tooltipCorner.Parent = tooltip

	local tooltipStroke = Instance.new("UIStroke")
	tooltipStroke.Color = CONFIG.BorderColor
	tooltipStroke.Thickness = 1
	tooltipStroke.Transparency = 0.5
	tooltipStroke.Parent = tooltip

	local tooltipLabel = CreateTextLabel(tooltip, "", 12)
	tooltipLabel.Size = UDim2.new(1, -8, 1, 0)
	tooltipLabel.Position = UDim2.new(0, 4, 0, 0)
	tooltipLabel.TextXAlignment = Enum.TextXAlignment.Center

	local function createActionButton(iconId, position, holdCallback, tooltipText, successIconId)
		successIconId = successIconId or ICON_ASSETS.Success
		local defaultIcon = iconId

		local btn = Instance.new("ImageButton")
		btn.Size = UDim2.new(0, 24, 0, 24)
		btn.Position = position
		btn.BackgroundTransparency = 1
		btn.Image = iconId
		btn.ImageColor3 = CONFIG.TextColor
		btn.Parent = actionsContainer

		-- Create proximity prompt style progress circle
		local progressCircle = Instance.new("ImageLabel")
		progressCircle.Size = UDim2.new(0, 36, 0, 36)
		progressCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
		progressCircle.AnchorPoint = Vector2.new(0.5, 0.5)
		progressCircle.BackgroundTransparency = 1
		progressCircle.Image = "rbxasset://textures/ui/Controls/RadialFill.png"
		progressCircle.ImageColor3 = CONFIG.AccentColor
		progressCircle.ImageTransparency = 1
		progressCircle.ZIndex = btn.ZIndex + 1
		progressCircle.Parent = btn
		
		local gradient = Instance.new("UIGradient")
		gradient.Rotation = 90  -- Start gradient at 12 o'clock
		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.0001, 0),
			NumberSequenceKeypoint.new(1, 0)
		})
		gradient.Parent = progressCircle

		local holding = false
		local holdTime = 0
		local holdDuration = 0.8  -- Slightly faster for smoother feel
		local holdConnection
		local completeTween

		btn.MouseEnter:Connect(function()
			tooltip.Visible = true
			tooltipLabel.Text = tooltipText
			local btnAbsPos = btn.AbsolutePosition
			local btnAbsSize = btn.AbsoluteSize
			tooltip.Position = UDim2.new(0, btnAbsPos.X - container.AbsolutePosition.X + btnAbsSize.X / 2 - 50, 0, btnAbsPos.Y - container.AbsolutePosition.Y - 35)
		end)

		btn.MouseLeave:Connect(function()
			tooltip.Visible = false
			holding = false
			holdTime = 0
			if holdConnection then
				holdConnection:Disconnect()
			end
			if completeTween then
				completeTween:Cancel()
			end
			-- Smooth fade out and reset
			CreateTween(progressCircle, {ImageTransparency = 1}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
			gradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.0001, 0),
				NumberSequenceKeypoint.new(1, 0)
			})
			btn.Image = defaultIcon
		end)

		btn.MouseButton1Down:Connect(function()
			holding = true
			holdTime = 0
			btn.Image = defaultIcon
			progressCircle.Size = UDim2.new(0, 36, 0, 36)

			if holdConnection then
				holdConnection:Disconnect()
			end
			if completeTween then
				completeTween:Cancel()
			end

			holdConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
				if holding then
					holdTime = holdTime + dt
					local progress = math.min(holdTime / holdDuration, 1)

					-- Create expanding circle effect from 12 o'clock
					-- Update gradient transparency to reveal more of the circle
					local cutoff = progress  -- 0 to 1
					gradient.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(math.max(0.0001, cutoff), 0),
						NumberSequenceKeypoint.new(math.min(1, cutoff + 0.0001), 1),
						NumberSequenceKeypoint.new(1, 1)
					})

					-- Smooth fade in with easing
					local fadeProgress = progress ^ 0.5  -- Square root for smooth ease in
					progressCircle.ImageTransparency = 1 - (fadeProgress * 0.5)

					if progress >= 1 then
						holding = false
						if holdConnection then
							holdConnection:Disconnect()
						end

						-- Complete animation: fade out
						btn.Image = successIconId
						
						local fadeOutTween = CreateTween(progressCircle, {
							ImageTransparency = 1
						}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
						fadeOutTween:Play()
						completeTween = fadeOutTween

						task.wait(0.15)
						holdCallback()

						task.wait(0.25)

						btn.Image = defaultIcon
						gradient.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.0001, 0),
							NumberSequenceKeypoint.new(1, 0)
						})
					end
				end
			end)
		end)

		btn.MouseButton1Up:Connect(function()
			holding = false
			holdTime = 0
			if holdConnection then
				holdConnection:Disconnect()
			end
			if completeTween then
				completeTween:Cancel()
			end
			-- Smooth reset animation
			CreateTween(progressCircle, {ImageTransparency = 1}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
			gradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.0001, 0),
				NumberSequenceKeypoint.new(1, 0)
			})
			btn.Image = defaultIcon
		end)

		return btn
	end

	local loadIcon = callbacks.loadIcon or ICON_ASSETS.Load
	local saveIcon = callbacks.saveIcon or ICON_ASSETS.Save
	local deleteIcon = callbacks.deleteIcon or ICON_ASSETS.Delete
	local successIcon = callbacks.successIcon or ICON_ASSETS.Success

	createActionButton(loadIcon, UDim2.new(0, 0, 0.5, -12), callbacks.onLoad, "Hold to load", successIcon)

	createActionButton(saveIcon, UDim2.new(0, 28, 0.5, -12), callbacks.onSave, "Hold to save", successIcon)

	createActionButton(deleteIcon, UDim2.new(0, 56, 0.5, -12), callbacks.onDelete, "Hold to delete", successIcon)

	return container
end

function UILibrary:CreateInput(tab, name, placeholder, callback)
	local container = CreateRoundedFrame(tab.Content, "Input_" .. name)
	container.Size = UDim2.new(1, 0, 0, CONFIG.ElementHeight + 32)
	container.BackgroundTransparency = 0.3

	local label = CreateTextLabel(container, name, 14)
	label.Size = UDim2.new(1, -CONFIG.Padding * 2, 0, 20)
	label.Position = UDim2.new(0, CONFIG.Padding, 0, 8)

	local inputBox = CreateRoundedFrame(container, "InputBox")
	inputBox.Size = UDim2.new(1, -CONFIG.Padding * 2, 0, 32)
	inputBox.Position = UDim2.new(0, CONFIG.Padding, 0, 32)
	inputBox.BackgroundColor3 = CONFIG.SurfaceColor

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(1, -16, 1, 0)
	input.Position = UDim2.new(0, 8, 0, 0)
	input.BackgroundTransparency = 1
	input.Text = ""
	input.PlaceholderText = placeholder
	input.Font = Enum.Font.Gotham
	input.TextSize = 14
	input.TextColor3 = CONFIG.TextColor
	input.PlaceholderColor3 = CONFIG.SecondaryTextColor
	input.TextXAlignment = Enum.TextXAlignment.Left
	input.ClearTextOnFocus = false
	input.Parent = inputBox

	input:GetPropertyChangedSignal("Text"):Connect(function()
		callback(input.Text)
	end)

	input.FocusLost:Connect(function(enterPressed)
		callback(input.Text)
		CreateTween(inputBox, {BackgroundColor3 = CONFIG.SurfaceColor}, 0.2):Play()
	end)

	input.Focused:Connect(function()
		CreateTween(inputBox, {BackgroundColor3 = CONFIG.SurfaceColor:Lerp(CONFIG.AccentColor, 0.1)}, 0.2):Play()
	end)

	-- Return table object with SetValue method
	local inputObject = {
		Container = container,
		SetValue = function(value)
			input.Text = value
		end
	}

	return inputObject
end

function UILibrary:CreateColorPicker(tab, name, default, callback)

	local sliderFills = {}
	local sliderThumbs = {}
	local sliderTracks = {}
	local rgbInputs = {}
	local rgbDragging = {false, false, false}
	local rgb = {0, 0, 0}

	local container = CreateRoundedFrame(tab.Content, "ColorPicker_" .. name)
	container.Size = UDim2.new(1, 0, 0, CONFIG.ElementHeight)
	container.BackgroundTransparency = 0.3
	container.ClipsDescendants = false

	local label = CreateTextLabel(container, name, 14)
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.new(0, CONFIG.Padding, 0, 0)

	local colorPreview = CreateRoundedFrame(container, "ColorPreview")
	colorPreview.Size = UDim2.new(0, 40, 0, 28)
	colorPreview.Position = UDim2.new(1, -48, 0.5, 0)
	colorPreview.AnchorPoint = Vector2.new(0, 0.5)
	colorPreview.BackgroundColor3 = default

	local previewBtn = Instance.new("TextButton")
	previewBtn.Size = UDim2.new(1, 0, 1, 0)
	previewBtn.Position = UDim2.new(0, 0, 0, 0)
	previewBtn.BackgroundTransparency = 1
	previewBtn.BorderSizePixel = 0
	previewBtn.Text = ""
	previewBtn.ZIndex = colorPreview.ZIndex + 1
	previewBtn.Parent = colorPreview

	local currentColor = default
	local pickerOpen = false

	local function RGBtoHSV(color)
		local r, g, b = color.R, color.G, color.B
		local max, min = math.max(r, g, b), math.min(r, g, b)
		local h, s, v = 0, 0, max
		local d = max - min
		s = max == 0 and 0 or d / max

		if max ~= min then
			if max == r then
				h = (g - b) / d + (g < b and 6 or 0)
			elseif max == g then
				h = (b - r) / d + 2
			else
				h = (r - g) / d + 4
			end
			h = h / 6
		end

		return h, s, v
	end

	local function HSVtoRGB(h, s, v)
		local r, g, b

		local i = math.floor(h * 6)
		local f = h * 6 - i
		local p = v * (1 - s)
		local q = v * (1 - f * s)
		local t = v * (1 - (1 - f) * s)

		i = i % 6

		if i == 0 then r, g, b = v, t, p
		elseif i == 1 then r, g, b = q, v, p
		elseif i == 2 then r, g, b = p, v, t
		elseif i == 3 then r, g, b = p, q, v
		elseif i == 4 then r, g, b = t, p, v
		elseif i == 5 then r, g, b = v, p, q
		end

		return Color3.new(r, g, b)
	end

	local function ColorToHex(color)
		return string.format("#%02X%02X%02X",
			math.floor(color.R * 255),
			math.floor(color.G * 255),
			math.floor(color.B * 255))
	end

	local function HexToColor(hex)
		hex = hex:gsub("#", "")
		if #hex == 6 then
			local r = tonumber(hex:sub(1, 2), 16) or 0
			local g = tonumber(hex:sub(3, 4), 16) or 0
			local b = tonumber(hex:sub(5, 6), 16) or 0
			return Color3.fromRGB(r, g, b)
		end
		return nil
	end

	previewBtn.MouseButton1Click:Connect(function()
		print("preview btn clicked")
		CreateTween(colorPreview, {BackgroundTransparency = 0.5}, 0.07):Play()
		task.wait(0.07)
		CreateTween(colorPreview, {BackgroundTransparency = 0}, 0.12):Play()

		if pickerOpen then

			if container:FindFirstChild("ColorPickerPopup") then
				local popup = container.ColorPickerPopup

				for _, child in ipairs(popup:GetChildren()) do
					if not child:IsA("UICorner") then
						child:Destroy()
					end
				end

				local closeTween = CreateTween(popup, {
					Size = UDim2.new(0, 280, 0, 0),
					BackgroundTransparency = 1
				}, 0.25)
				closeTween:Play()
				task.wait(0.25)
				popup:Destroy()
				if openColorPickerPopup == popup then
					openColorPickerPopup = nil
				end

				if container.Parent then
					container.Parent.ClipsDescendants = true
				end
			end
			pickerOpen = false
		else

			if openColorPickerPopup and openColorPickerPopup.Parent then
				local otherPopup = openColorPickerPopup

				for _, child in ipairs(otherPopup:GetChildren()) do
					if not child:IsA("UICorner") then
						child:Destroy()
					end
				end

				local closeTween = CreateTween(otherPopup, {
					Size = UDim2.new(0, 280, 0, 0),
					BackgroundTransparency = 1
				}, 0.25)
				closeTween:Play()
				task.wait(0.25)
				otherPopup:Destroy()
			end

			pickerOpen = true

			local popup = CreateRoundedFrame(container, "ColorPickerPopup")
			openColorPickerPopup = popup
			container.ClipsDescendants = false

			if container.Parent then
				container.Parent.ClipsDescendants = false
			end

			popup.Size = UDim2.new(0, 280, 0, 0)
			popup.Position = UDim2.new(1, 10, 0, 0)
			popup.BackgroundColor3 = CONFIG.SurfaceColor
			popup.BackgroundTransparency = 1
			popup.ClipsDescendants = false
			popup.ZIndex = 10000

			local dragBar = Instance.new("Frame")
			dragBar.Name = "DragBar"
			dragBar.Size = UDim2.new(1, 0, 0, 30)
			dragBar.Position = UDim2.new(0, 0, 0, 0)
			dragBar.BackgroundColor3 = CONFIG.SurfaceColor:Lerp(CONFIG.BackgroundColor, 0.3)
			dragBar.BorderSizePixel = 0
			dragBar.ZIndex = 10001
			dragBar.Active = true
			dragBar.Parent = popup

			local dragBarCorner = Instance.new("UICorner")
			dragBarCorner.CornerRadius = UDim.new(0, CONFIG.CornerRadius)
			dragBarCorner.Parent = dragBar

			local trafficLightColors = {
				Color3.fromRGB(255, 95, 87),
				Color3.fromRGB(255, 189, 68)
			}

			for i, color in ipairs(trafficLightColors) do
				local button = Instance.new("TextButton")
				button.Name = "TrafficLight" .. i
				button.Size = UDim2.new(0, 10, 0, 10)
				button.Position = UDim2.new(0, 8 + (i - 1) * 16, 0.5, 0)
				button.AnchorPoint = Vector2.new(0, 0.5)
				button.BackgroundColor3 = color
				button.BorderSizePixel = 0
				button.Text = ""
				button.AutoButtonColor = false
				button.ZIndex = 10002
				button.Parent = dragBar

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(1, 0)
				corner.Parent = button

				button.MouseEnter:Connect(function()
					CreateTween(button, {BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.2)}, 0.25):Play()
				end)

				button.MouseLeave:Connect(function()
					CreateTween(button, {BackgroundColor3 = color}, 0.25):Play()
				end)

				button.MouseButton1Click:Connect(function()

					for _, child in ipairs(popup:GetChildren()) do
						if not child:IsA("UICorner") then
							child:Destroy()
						end
					end

					local closeTween = CreateTween(popup, {
						Size = UDim2.new(0, 280, 0, 0),
						BackgroundTransparency = 1
					}, 0.25)
					closeTween:Play()
					task.wait(0.25)
					popup:Destroy()
					pickerOpen = false
					openColorPickerPopup = nil

					if container.Parent then
						container.Parent.ClipsDescendants = true
					end
				end)
			end

			local dragBarLabel = CreateTextLabel(dragBar, "Color Picker", 12)
			dragBarLabel.Size = UDim2.new(1, 0, 1, 0)
			dragBarLabel.Position = UDim2.new(0, 0, 0, 0)
			dragBarLabel.TextXAlignment = Enum.TextXAlignment.Center
			dragBarLabel.Font = Enum.Font.GothamBold
			dragBarLabel.ZIndex = 10002

			local dragging = false
			local dragStart = nil
			local startPos = nil

			dragBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					dragStart = UserInputService:GetMouseLocation()
					startPos = popup.Position

					local moveConnection
					moveConnection = UserInputService.InputChanged:Connect(function(input)
						if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
							local currentPos = UserInputService:GetMouseLocation()
							local delta = currentPos - dragStart
							popup.Position = UDim2.new(
								startPos.X.Scale,
								startPos.X.Offset + delta.X,
								startPos.Y.Scale,
								startPos.Y.Offset + delta.Y
							)
						end
					end)

					local releaseConnection
					releaseConnection = UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							dragging = false
							moveConnection:Disconnect()
							releaseConnection:Disconnect()
						end
					end)
				end
			end)

			task.defer(function()
				for _, child in ipairs(popup:GetDescendants()) do
					if child:IsA("GuiObject") then
						child.ZIndex = 10001
					end
				end
			end)

			local openTween = CreateTween(popup, {
				Size = UDim2.new(0, 280, 0, 450),
				BackgroundTransparency = 0
			}, 0.3)
			openTween:Play()

			callback(currentColor)

			local h, s, v = RGBtoHSV(currentColor)
			local rgb = {currentColor.R * 255, currentColor.G * 255, currentColor.B * 255}

			local gradientFrame = Instance.new("Frame")
			gradientFrame.Size = UDim2.new(1, -20, 0, 180)
			gradientFrame.Position = UDim2.new(0, 10, 0, 40)
			gradientFrame.BackgroundColor3 = Color3.new(1, 1, 1)
			gradientFrame.BorderSizePixel = 0
			gradientFrame.Parent = popup

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = gradientFrame

			local saturationGradient = Instance.new("UIGradient")
			saturationGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), HSVtoRGB(h, 1, 1))
			saturationGradient.Parent = gradientFrame

			local valueOverlay = Instance.new("Frame")
			valueOverlay.Size = UDim2.new(1, 0, 1, 0)
			valueOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
			valueOverlay.BackgroundTransparency = 0
			valueOverlay.BorderSizePixel = 0
			valueOverlay.Parent = gradientFrame

			local valueGradient = Instance.new("UIGradient")
			valueGradient.Rotation = 90
			valueGradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0)
			}
			valueGradient.Parent = valueOverlay

			local pickerCursor = Instance.new("Frame")
			pickerCursor.Size = UDim2.new(0, 12, 0, 12)
			pickerCursor.Position = UDim2.new(s, 0, 1 - v, 0)
			pickerCursor.AnchorPoint = Vector2.new(0.5, 0.5)
			pickerCursor.BackgroundColor3 = Color3.new(1, 1, 1)
			pickerCursor.BorderSizePixel = 2
			pickerCursor.BorderColor3 = Color3.new(0, 0, 0)
			pickerCursor.ZIndex = 11
			pickerCursor.Parent = gradientFrame

			local cursorCorner = Instance.new("UICorner")
			cursorCorner.CornerRadius = UDim.new(1, 0)
			cursorCorner.Parent = pickerCursor

			local hueSliderLabel = CreateTextLabel(popup, "Hue", 13)
			hueSliderLabel.Size = UDim2.new(0, 30, 0, 20)
			hueSliderLabel.Position = UDim2.new(0, 10, 0, 230)

			local hueSlider = Instance.new("Frame")
			hueSlider.Size = UDim2.new(1, -60, 0, 20)
			hueSlider.Position = UDim2.new(0, 50, 0, 230)
			hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
			hueSlider.BorderSizePixel = 0
			hueSlider.Parent = popup

			local hueCorner = Instance.new("UICorner")
			hueCorner.CornerRadius = UDim.new(0, 4)
			hueCorner.Parent = hueSlider

			local hueGradient = Instance.new("UIGradient")
			hueGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
			}
			hueGradient.Parent = hueSlider

			local hueThumb = Instance.new("Frame")
			hueThumb.Size = UDim2.new(0, 8, 1, 8)
			hueThumb.Position = UDim2.new(h, 0, 0.5, 0)
			hueThumb.AnchorPoint = Vector2.new(0.5, 0.5)
			hueThumb.BackgroundColor3 = Color3.new(1, 1, 1)
			hueThumb.BorderSizePixel = 2
			hueThumb.BorderColor3 = Color3.new(0, 0, 0)
			hueThumb.Parent = hueSlider

			local hueThumbCorner = Instance.new("UICorner")
			hueThumbCorner.CornerRadius = UDim.new(1, 0)
			hueThumbCorner.Parent = hueThumb

			local rgbY = 260
			local colors = {"R", "G", "B"}
			local colorValues = {Color3.new(1, 0, 0), Color3.new(0, 1, 0), Color3.new(0, 0, 1)}

			local function updateColor(newColor, source)
				currentColor = newColor
				colorPreview.BackgroundColor3 = newColor
				callback(newColor)

				h, s, v = RGBtoHSV(newColor)
				rgb = {newColor.R * 255, newColor.G * 255, newColor.B * 255}

				if source ~= "gradient" then
					pickerCursor.Position = UDim2.new(s, 0, 1 - v, 0)
				end

				hueThumb.Position = UDim2.new(h, 0, 0.5, 0)
				saturationGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), HSVtoRGB(h, 1, 1))

				if source ~= "rgb" then
					for i = 1, 3 do
						rgbInputs[i].Text = tostring(math.floor(rgb[i]))
					end
				end

				if source ~= "hex" and hexInput then
					hexInput.Text = ColorToHex(newColor)
				end

				for i = 1, 3 do
					if sliderFills[i] then
						sliderFills[i].Size = UDim2.new(rgb[i] / 255, 0, 1, 0)
					end
					if sliderThumbs[i] then
						sliderThumbs[i].Position = UDim2.new(rgb[i] / 255, 0, 0.5, 0)
					end
				end
			end

			local colors = {"R", "G", "B"}
			local colorValues = {Color3.new(1, 0, 0), Color3.new(0, 1, 0), Color3.new(0, 0, 1)}

			for i, colorName in ipairs(colors) do
				local sliderLabel = CreateTextLabel(popup, colorName, 13)
				sliderLabel.Size = UDim2.new(0, 15, 0, 20)
				sliderLabel.Position = UDim2.new(0, 10, 0, rgbY + (i - 1) * 30)

				local sliderTrack = Instance.new("Frame")
				sliderTrack.Size = UDim2.new(1, -120, 0, 6)
				sliderTrack.Position = UDim2.new(0, 35, 0, rgbY + 7 + (i - 1) * 30)
				sliderTrack.BackgroundColor3 = CONFIG.BorderColor
				sliderTrack.BorderSizePixel = 0
				sliderTrack.Parent = popup
				sliderTracks[i] = sliderTrack
				sliderTrack.Active = true

				local trackCorner = Instance.new("UICorner")
				trackCorner.CornerRadius = UDim.new(1, 0)
				trackCorner.Parent = sliderTrack

				local sliderFill = Instance.new("Frame")
				sliderFill.Size = UDim2.new(rgb[i] / 255, 0, 1, 0)
				sliderFill.BackgroundColor3 = colorValues[i]
				sliderFill.BorderSizePixel = 0
				sliderFill.Parent = sliderTrack
				sliderFills[i] = sliderFill

				local fillCorner = Instance.new("UICorner")
				fillCorner.CornerRadius = UDim.new(1, 0)
				fillCorner.Parent = sliderFill

				local sliderThumb = Instance.new("Frame")
				sliderThumb.Size = UDim2.new(0, 14, 0, 14)
				sliderThumb.Position = UDim2.new(rgb[i] / 255, 0, 0.5, 0)
				sliderThumb.AnchorPoint = Vector2.new(0.5, 0.5)
				sliderThumb.BackgroundColor3 = Color3.new(1, 1, 1)
				sliderThumb.BorderSizePixel = 2
				sliderThumb.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
				sliderThumb.Parent = sliderTrack
				sliderThumbs[i] = sliderThumb
				sliderThumb.Active = true

				local thumbCorner = Instance.new("UICorner")
				thumbCorner.CornerRadius = UDim.new(1, 0)
				thumbCorner.Parent = sliderThumb

				sliderThumb.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						rgbDragging[i] = true
					end
				end)

				sliderTrack.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						rgbDragging[i] = true
						if not sliderTrack.AbsolutePosition or not sliderTrack.AbsoluteSize then
							print("sliderTrack not ready!", sliderTrack, sliderTrack.Parent)
							return
						end
						local relativeX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
						rgb[i] = math.floor(relativeX * 255)
						updateColor(Color3.fromRGB(rgb[1], rgb[2], rgb[3]), "rgb")
					end
				end)

				local inputBox = Instance.new("TextBox")
				inputBox.Size = UDim2.new(0, 50, 0, 24)
				inputBox.Position = UDim2.new(1, -60, 0, rgbY - 2 + (i - 1) * 30)
				inputBox.BackgroundColor3 = CONFIG.BackgroundColor
				inputBox.BorderSizePixel = 0
				inputBox.Text = tostring(math.floor(rgb[i]))
				inputBox.Font = Enum.Font.Gotham
				inputBox.TextSize = 12
				inputBox.TextColor3 = CONFIG.TextColor
				inputBox.Parent = popup

				local inputCorner = Instance.new("UICorner")
				inputCorner.CornerRadius = UDim.new(0, 4)
				inputCorner.Parent = inputBox

				rgbInputs[i] = inputBox
			end

			UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					for i = 1, 3 do
						if rgbDragging[i] then
							local track = sliderTracks[i]
							local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
							rgb[i] = math.floor(relativeX * 255)

							rgbInputs[i].Text = tostring(math.floor(rgb[i]))

							sliderFills[i].Size = UDim2.new(rgb[i] / 255, 0, 1, 0)
							sliderThumbs[i].Position = UDim2.new(rgb[i] / 255, 0, 0.5, 0)

							local newColor = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
							currentColor = newColor
							colorPreview.BackgroundColor3 = newColor
							callback(newColor)

							h, s, v = RGBtoHSV(newColor)
							pickerCursor.Position = UDim2.new(s, 0, 1 - v, 0)
							hueThumb.Position = UDim2.new(h, 0, 0.5, 0)
							saturationGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), HSVtoRGB(h, 1, 1))
							hexInput.Text = ColorToHex(newColor)
						end
					end
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					for i = 1, 3 do
						rgbDragging[i] = false
					end
				end
			end)

			local hexLabel = CreateTextLabel(popup, "Hex", 13)
			hexLabel.Size = UDim2.new(0, 30, 0, 20)
			hexLabel.Position = UDim2.new(0, 10, 0, 360)

			hexInput = Instance.new("TextBox")
			hexInput.Size = UDim2.new(1, -50, 0, 28)
			hexInput.Position = UDim2.new(0, 50, 0, 357)
			hexInput.BackgroundColor3 = CONFIG.BackgroundColor
			hexInput.BorderSizePixel = 0
			hexInput.Text = ColorToHex(currentColor)
			hexInput.Font = Enum.Font.GothamMedium
			hexInput.TextSize = 13
			hexInput.TextColor3 = CONFIG.TextColor
			hexInput.PlaceholderText = "#FFFFFF"
			hexInput.Parent = popup

			local hexCorner = Instance.new("UICorner")
			hexCorner.CornerRadius = UDim.new(0, 6)
			hexCorner.Parent = hexInput

			local gradientDragging = false
			local hueDragging = false
			local rgbDragging = {false, false, false}

			gradientFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					gradientDragging = true
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if gradientDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local relativeX = math.clamp((input.Position.X - gradientFrame.AbsolutePosition.X) / gradientFrame.AbsoluteSize.X, 0, 1)
					local relativeY = math.clamp((input.Position.Y - gradientFrame.AbsolutePosition.Y) / gradientFrame.AbsoluteSize.Y, 0, 1)

					s = relativeX
					v = 1 - relativeY

					local newColor = HSVtoRGB(h, s, v)
					updateColor(newColor, "gradient")
					pickerCursor.Position = UDim2.new(s, 0, 1-v, 0)
				end
			end)

			hueSlider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					hueDragging = true
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local relativeX = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
					h = relativeX

					local newColor = HSVtoRGB(h, s, v)
					updateColor(newColor, "hue")
				end
			end)

			for i = 1, 3 do
				rgbInputs[i].FocusLost:Connect(function()
					local value = tonumber(rgbInputs[i].Text)
					if value then
						value = math.clamp(value, 0, 255)
						rgb[i] = value
						local newColor = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
						updateColor(newColor, "rgb")
					else
						rgbInputs[i].Text = tostring(math.floor(rgb[i]))
					end
				end)
			end

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					gradientDragging = false
					hueDragging = false
					for i = 1, 3 do
						rgbDragging[i] = false
					end
				end
			end)

			hexInput.FocusLost:Connect(function()
				local newColor = HexToColor(hexInput.Text)
				if newColor then
					updateColor(newColor, "hex")
				else
					hexInput.Text = ColorToHex(currentColor)
				end
			end)

			local closeButton = CreateRoundedFrame(popup, "CloseButton")
			closeButton.Size = UDim2.new(1, -20, 0, 36)
			closeButton.Position = UDim2.new(0, 10, 1, -46)
			closeButton.BackgroundColor3 = CONFIG.AccentColor
			closeButton.Name = "DoneButton"
			local closeLabel = CreateTextLabel(closeButton, "Done", 14)
			closeLabel.Size = UDim2.new(1, 0, 1, 0)
			closeLabel.TextXAlignment = Enum.TextXAlignment.Center
			closeLabel.TextColor3 = Color3.new(1, 1, 1)
			closeLabel.Font = Enum.Font.GothamBold
			local closeBtn = Instance.new("TextButton")
			closeBtn.Name = "DoneTextButton"
			closeBtn.Size = UDim2.new(1, 0, 1, 0)
			closeBtn.BackgroundTransparency = 1
			closeBtn.Text = "Done"
			closeBtn.TextTransparency = 1
			closeBtn.Parent = closeButton
			closeBtn.MouseButton1Click:Connect(function()

				for _, child in ipairs(popup:GetChildren()) do
					if not child:IsA("UICorner") then
						child:Destroy()
					end
				end

				local closeTween = CreateTween(popup, {
					Size = UDim2.new(0, 280, 0, 0),
					BackgroundTransparency = 1
				}, 0.25)
				closeTween:Play()
				task.wait(0.25)
				popup:Destroy()
				pickerOpen = false
				openColorPickerPopup = nil

				if container.Parent then
					container.Parent.ClipsDescendants = true
				end
			end)
		end
	end)
	
	-- Return table object with SetColor method
	local colorPickerObject = {
		Container = container,
		SetColor = function(color)
			currentColor = color
			colorPreview.BackgroundColor3 = color
			rgb[1] = math.floor(color.R * 255)
			rgb[2] = math.floor(color.G * 255)
			rgb[3] = math.floor(color.B * 255)
		end
	}
	
	return colorPickerObject
end

function UILibrary:CreateDropdown(tab, name, options, default, callback)
	local container = CreateRoundedFrame(tab.Content, "Dropdown_" .. name)
	container.Size = UDim2.new(1, 0, 0, CONFIG.ElementHeight + 32)
	container.BackgroundTransparency = 0.3
	container.ClipsDescendants = false

	local label = CreateTextLabel(container, name, 14)
	label.Size = UDim2.new(1, -CONFIG.Padding * 2, 0, 20)
	label.Position = UDim2.new(0, CONFIG.Padding, 0, 8)

	local dropdownButton = CreateRoundedFrame(container, "DropdownButton")
	dropdownButton.Size = UDim2.new(1, -CONFIG.Padding * 2, 0, 32)
	dropdownButton.Position = UDim2.new(0, CONFIG.Padding, 0, 32)
	dropdownButton.BackgroundColor3 = CONFIG.SurfaceColor

	local selectedLabel = CreateTextLabel(dropdownButton, default, 14)
	selectedLabel.Size = UDim2.new(1, -40, 1, 0)
	selectedLabel.Position = UDim2.new(0, 8, 0, 0)
	local arrow = CreateTextLabel(dropdownButton, "▼", 12)
	arrow.Size = UDim2.new(0, 20, 1, 0)
	arrow.Position = UDim2.new(1, -28, 0, 0)
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	local currentSelection = default
	local dropdownOpen = false
	local searchQuery = ""
	local searchConnection = nil
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.Parent = dropdownButton

	button.MouseButton1Click:Connect(function()
		if not dropdownOpen then
			dropdownOpen = true
			searchQuery = ""
			CreateTween(arrow, {Rotation = 180}, 0.2):Play()

			local dropdownWrapper = Instance.new("Frame")
			dropdownWrapper.Name = "DropdownWrapper"
			dropdownWrapper.Size = UDim2.new(1, -CONFIG.Padding * 2, 0, 32)
			dropdownWrapper.Position = UDim2.new(0, CONFIG.Padding, 0, 68)
			dropdownWrapper.BackgroundColor3 = CONFIG.SurfaceColor
			dropdownWrapper.BorderSizePixel = 0
			dropdownWrapper.ZIndex = 10000
			dropdownWrapper.ClipsDescendants = true
			dropdownWrapper.Parent = container

			local wrapperCorner = Instance.new("UICorner")
			wrapperCorner.CornerRadius = UDim.new(0, CONFIG.CornerRadius)
			wrapperCorner.Parent = dropdownWrapper

			local searchContainer = Instance.new("Frame")
			searchContainer.Name = "SearchContainer"
			searchContainer.Size = UDim2.new(1, 0, 0, 32)
			searchContainer.Position = UDim2.new(0, 0, 0, 0)
			searchContainer.BackgroundTransparency = 1
			searchContainer.BorderSizePixel = 0
			searchContainer.ZIndex = 10000
			searchContainer.Parent = dropdownWrapper

			local searchBox = Instance.new("TextBox")
			searchBox.Name = "SearchBox"
			searchBox.Size = UDim2.new(1, -16, 1, 0)
			searchBox.Position = UDim2.new(0, 8, 0, 0)
			searchBox.BackgroundTransparency = 1
			searchBox.Text = ""
			searchBox.PlaceholderText = "Type to search..."
			searchBox.Font = Enum.Font.Gotham
			searchBox.TextSize = 13
			searchBox.TextColor3 = CONFIG.TextColor
			searchBox.PlaceholderColor3 = CONFIG.SecondaryTextColor
			searchBox.TextXAlignment = Enum.TextXAlignment.Left
			searchBox.ClearTextOnFocus = false
			searchBox.ZIndex = 10001
			searchBox.Parent = searchContainer

			local listContainer = Instance.new("ScrollingFrame")
			listContainer.Name = "DropdownList"
			listContainer.Size = UDim2.new(1, 0, 0, 0)
			listContainer.Position = UDim2.new(0, 0, 0, 32)
			listContainer.BackgroundTransparency = 1
			listContainer.BorderSizePixel = 0
			listContainer.ZIndex = 10000
			listContainer.ClipsDescendants = true
			listContainer.ScrollBarThickness = 4
			listContainer.ScrollBarImageColor3 = CONFIG.AccentColor
			listContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
			listContainer.Parent = dropdownWrapper
			container.ZIndex = 10000
			for _, child in ipairs(container:GetDescendants()) do
				if child:IsA("GuiObject") and child ~= listContainer and child ~= searchContainer then
					child.ZIndex = 10000
				end
			end

			local function setZIndexRecursive(instance, zindex)
				for _, child in ipairs(instance:GetDescendants()) do
					if child:IsA("GuiObject") then
						child.ZIndex = zindex
					end
				end
			end
			setZIndexRecursive(listContainer, 10001)
			setZIndexRecursive(searchContainer, 10001)

			local listLayout = Instance.new("UIListLayout")
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Parent = listContainer

			listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				listContainer.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
			end)

			local optionButtons = {}

			local function updateOptions(query)
				for _, btn in ipairs(optionButtons) do
					btn:Destroy()
				end
				optionButtons = {}

				local filteredOptions = {}
				for _, option in ipairs(options) do
					if query == "" or string.find(string.lower(option), string.lower(query), 1, true) then
						table.insert(filteredOptions, option)
					end
				end

				local expandedHeight = math.min(#filteredOptions * 32, 200)
				CreateTween(listContainer, {Size = UDim2.new(1, 0, 0, expandedHeight)}, 0.15):Play()
				CreateTween(dropdownWrapper, {Size = UDim2.new(1, -CONFIG.Padding * 2, 0, 32 + expandedHeight)}, 0.15):Play()

				for i, option in ipairs(filteredOptions) do
					local optionButton = Instance.new("TextButton")
					local optionLabel = CreateTextLabel(optionButton, option, 13)
					local optionCorner = Instance.new("UICorner")
					optionButton.Size = UDim2.new(1, -8, 0, 32)
					optionButton.BackgroundColor3 = option == currentSelection and CONFIG.AccentColor or CONFIG.SurfaceColor
					optionButton.BackgroundTransparency = option == currentSelection and 0.7 or 1
					optionButton.BorderSizePixel = 0
					optionButton.Text = ""
					optionButton.AutoButtonColor = false
					optionButton.ZIndex = 10001
					optionButton.LayoutOrder = i
					optionButton.Parent = listContainer
					optionLabel.Size = UDim2.new(1, -16, 1, 0)
					optionLabel.Position = UDim2.new(0, 8, 0, 0)
					optionLabel.ZIndex = 10002
					optionCorner.CornerRadius = UDim.new(0, CONFIG.CornerRadius)
					optionCorner.Parent = optionButton

					table.insert(optionButtons, optionButton)

					optionButton.MouseButton1Click:Connect(function()
						currentSelection = option
						selectedLabel.Text = option
						callback(option)

						if searchConnection then
							searchConnection:Disconnect()
							searchConnection = nil
						end

						container.ZIndex = 1
						for _, child in ipairs(container:GetDescendants()) do
							if child:IsA("GuiObject") then
								child.ZIndex = 1
							end
						end

						CreateTween(dropdownWrapper, {Size = UDim2.new(1, -CONFIG.Padding * 2, 0, 0)}, 0.15):Play()
						task.wait(0.15)
						dropdownWrapper:Destroy()
						dropdownOpen = false
						CreateTween(arrow, {Rotation = 0}, 0.2):Play()
					end)

					optionButton.MouseEnter:Connect(function()
						CreateTween(optionButton, {BackgroundTransparency = 0.5}, 0.15):Play()
					end)

					optionButton.MouseLeave:Connect(function()
						if option ~= currentSelection then
							CreateTween(optionButton, {BackgroundTransparency = 1}, 0.15):Play()
						else
							CreateTween(optionButton, {BackgroundTransparency = 0.7}, 0.15):Play()
						end
					end)
				end
			end

			updateOptions("")
			searchBox:GetPropertyChangedSignal("Text"):Connect(function()
				searchQuery = searchBox.Text
				updateOptions(searchQuery)
			end)

			searchConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if dropdownOpen and input.UserInputType == Enum.UserInputType.Keyboard then
					if not searchBox:IsFocused() then
						searchBox:CaptureFocus()
					end
				end
			end)
		else
			if searchConnection then
				searchConnection:Disconnect()
				searchConnection = nil
			end

			if container:FindFirstChild("DropdownWrapper") then
				local dropdownWrapper = container.DropdownWrapper
				container.ZIndex = 1
				for _, child in ipairs(container:GetDescendants()) do
					if child:IsA("GuiObject") then
						child.ZIndex = 1
					end
				end

				CreateTween(dropdownWrapper, {Size = UDim2.new(1, -CONFIG.Padding * 2, 0, 0)}, 0.15):Play()
				task.wait(0.15)
				dropdownWrapper:Destroy()
				dropdownOpen = false
				CreateTween(arrow, {Rotation = 0}, 0.2):Play()
			end
		end
	end)

	local dropdownObject = {
		Container = container,
		Options = options,
		CurrentSelection = currentSelection,
		SetValue = function(value)
			currentSelection = value
			selectedLabel.Text = value
		end,
		Refresh = function(newOptions)
			options = newOptions
			local found = false
			for _, opt in ipairs(newOptions) do
				if opt == currentSelection then
					found = true
					break
				end
			end
			if not found and #newOptions > 0 then
				currentSelection = newOptions[1]
				selectedLabel.Text = currentSelection
				callback(currentSelection)
			end
		end
	}

	return dropdownObject
end

function UILibrary:CreateLabel(tab, text)
	local label = Instance.new("TextLabel")
	local padding = Instance.new("UIPadding")
	label.Name = "Label_" .. text:sub(1, 10)
	label.Size = UDim2.new(1, 0, 0, 28)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextColor3 = CONFIG.SecondaryTextColor
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Parent = tab.Content
	padding.PaddingLeft = UDim.new(0, CONFIG.Padding)
	padding.PaddingRight = UDim.new(0, CONFIG.Padding)
	padding.Parent = label
	return label
end

function UILibrary:CreateKeybind(tab, name, default, callback)
	local container = CreateRoundedFrame(tab.Content, "Keybind_" .. name)
	container.Size = UDim2.new(1, 0, 0, CONFIG.ElementHeight)
	container.BackgroundTransparency = 0.3

	local label = CreateTextLabel(container, name, 14)
	label.Size = UDim2.new(0.5, -CONFIG.Padding, 1, 0)
	label.Position = UDim2.new(0, CONFIG.Padding, 0, 0)

	local keybindButton = CreateRoundedFrame(container, "KeybindButton")
	keybindButton.Size = UDim2.new(0, 100, 0, 28)
	keybindButton.Position = UDim2.new(1, -108, 0.5, 0)
	keybindButton.AnchorPoint = Vector2.new(0, 0.5)
	keybindButton.BackgroundColor3 = CONFIG.SurfaceColor

	local keybindLabel = CreateTextLabel(keybindButton, default or "not bound", 13)
	keybindLabel.Size = UDim2.new(1, -16, 1, 0)
	keybindLabel.Position = UDim2.new(0, 8, 0, 0)
	keybindLabel.TextXAlignment = Enum.TextXAlignment.Center
	keybindLabel.Font = Enum.Font.GothamMedium

	local unbindButton = Instance.new("TextButton")
	unbindButton.Name = "UnbindButton"
	unbindButton.Size = UDim2.new(0, 20, 0, 20)
	unbindButton.Position = UDim2.new(1, -24, 0.5, 0)
	unbindButton.AnchorPoint = Vector2.new(0, 0.5)
	unbindButton.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
	unbindButton.BackgroundTransparency = 1
	unbindButton.Text = "×"
	unbindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	unbindButton.Font = Enum.Font.GothamBold
	unbindButton.TextSize = 16
	unbindButton.Visible = false
	unbindButton.ZIndex = 100
	unbindButton.Parent = keybindButton

	local unbindCorner = Instance.new("UICorner")
	unbindCorner.CornerRadius = UDim.new(1, 0)
	unbindCorner.Parent = unbindButton

	local currentKey = default
	local listening = false
	local originalText = keybindLabel.Text
	local hovered = false

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -25, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.ZIndex = 50
	button.Parent = keybindButton

	local function getKeyName(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			return input.KeyCode.Name
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			return "Mouse1"
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			return "Mouse2"
		elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
			return "Mouse3"
		end
		return nil
	end

	local function updateButtonSize(text, hasUnbind)
		local textService = game:GetService("TextService")
		local textSize = textService:GetTextSize(
			text,
			13,
			Enum.Font.GothamMedium,
			Vector2.new(math.huge, 28)
		)
		local extraWidth = hasUnbind and 30 or 0
		local newWidth = math.max(100, textSize.X + 24 + extraWidth)
		CreateTween(keybindButton, {
			Size = UDim2.new(0, newWidth, 0, 28),
			Position = UDim2.new(1, -newWidth - 8, 0.5, 0)
		}, 0.2):Play()

		if hasUnbind then
			keybindLabel.Size = UDim2.new(1, -40, 1, 0)
		else
			keybindLabel.Size = UDim2.new(1, -16, 1, 0)
		end
	end

	local inputConnection
	button.MouseButton1Click:Connect(function()
		if not listening then
			listening = true
			keybindLabel.Text = "listening..."
			unbindButton.Visible = false
			updateButtonSize("listening...", false)
			CreateTween(keybindButton, {BackgroundColor3 = CONFIG.AccentColor:Lerp(CONFIG.SurfaceColor, 0.7)}, 0.2):Play()

			inputConnection = UserInputService.InputBegan:Connect(function(input)
				local keyName = getKeyName(input)
				if keyName then
					currentKey = keyName
					keybindLabel.Text = keyName
					originalText = keyName
					listening = false
					CreateTween(keybindButton, {BackgroundColor3 = CONFIG.SurfaceColor}, 0.2):Play()

					if inputConnection then
						inputConnection:Disconnect()
						inputConnection = nil
					end
					callback(keyName)
				end
			end)
		end
	end)

	unbindButton.MouseButton1Click:Connect(function()
		currentKey = nil
		keybindLabel.Text = "not bound"
		originalText = "not bound"
		unbindButton.Visible = false
		updateButtonSize("not bound", false)
		callback(nil)
	end)

	unbindButton.MouseEnter:Connect(function()
		CreateTween(unbindButton, {BackgroundTransparency = 0}, 0.25):Play()
	end)

	unbindButton.MouseLeave:Connect(function()
		CreateTween(unbindButton, {BackgroundTransparency = 1}, 0.25):Play()
	end)

	button.MouseEnter:Connect(function()
		hovered = true
		if not listening then
			if currentKey and currentKey ~= "not bound" then
				keybindLabel.Text = "click to bind"
				unbindButton.Visible = true
				updateButtonSize("click to bind", true)
			else
				keybindLabel.Text = "click to bind"
				updateButtonSize("click to bind", false)
			end
			CreateTween(keybindButton, {BackgroundColor3 = CONFIG.SurfaceColor:Lerp(CONFIG.AccentColor, 0.1)}, 0.25):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		hovered = false
		if not listening then
			keybindLabel.Text = originalText
			unbindButton.Visible = false
			updateButtonSize(originalText, false)
			CreateTween(keybindButton, {BackgroundColor3 = CONFIG.SurfaceColor}, 0.25):Play()
		end
	end)

	keybindButton.MouseEnter:Connect(function()
		if not listening and currentKey and currentKey ~= "not bound" then
			keybindLabel.Text = "click to bind"
			unbindButton.Visible = true
			updateButtonSize("click to bind", true)
			CreateTween(keybindButton, {BackgroundColor3 = CONFIG.SurfaceColor:Lerp(CONFIG.AccentColor, 0.1)}, 0.25):Play()
		end
	end)

	keybindButton.MouseLeave:Connect(function()
		if not listening then
			unbindButton.Visible = false
			keybindLabel.Text = originalText
			updateButtonSize(originalText, false)
			CreateTween(keybindButton, {BackgroundColor3 = CONFIG.SurfaceColor}, 0.25):Play()
		end
	end)

	unbindButton.MouseEnter:Connect(function()
		unbindButton.Visible = true
	end)

	-- Return table object with SetValue method
	local keybindObject = {
		Container = container,
		SetValue = function(value)
			currentKey = value
			if value and value ~= "" then
				keybindLabel.Text = value
				originalText = value
				updateButtonSize(value, false)
			else
				keybindLabel.Text = "not bound"
				originalText = "not bound"
				updateButtonSize("not bound", false)
			end
		end
	}

	return keybindObject
end

function UILibrary:UpdateTheme(themeConfig)
	currentTheme = self

	for key, value in pairs(themeConfig) do
		if CONFIG[key] then
			CONFIG[key] = value
		end
	end

	if self.Window then
		CreateTween(self.Window, {BackgroundColor3 = CONFIG.BackgroundColor}, 0.3):Play()
	end

	if self.TitleBar then
		CreateTween(self.TitleBar, {BackgroundColor3 = CONFIG.SurfaceColor}, 0.3):Play()

		if self.TitleBar:FindFirstChild("TitleLabel") then
			CreateTween(self.TitleBar.TitleLabel, {TextColor3 = CONFIG.TextColor}, 0.3):Play()
		end
	end

	if self.TabBar then
		CreateTween(self.TabBar, {BackgroundColor3 = CONFIG.SurfaceColor}, 0.3):Play()
	end

	for _, tab in ipairs(self.Tabs) do
		if tab.Content and tab.Content:IsA("ScrollingFrame") then
			tab.Content.ScrollBarImageColor3 = CONFIG.AccentColor
		end
	end

	for _, tab in ipairs(self.Tabs) do
		if tab.Button then
			CreateTween(tab.Button, {BackgroundColor3 = CONFIG.SurfaceColor}, 0.3):Play()

			for _, child in ipairs(tab.Button:GetChildren()) do
				if child:IsA("TextLabel") then
					CreateTween(child, {TextColor3 = CONFIG.TextColor}, 0.3):Play()
				elseif child:IsA("ImageLabel") then

					CreateTween(child, {ImageColor3 = CONFIG.TextColor}, 0.3):Play()
				end
			end
		end

		if tab.Content then
			for _, element in ipairs(tab.Content:GetChildren()) do
			if element:IsA("Frame") and element.Name:match("^%w+_") then

				CreateTween(element, {BackgroundColor3 = CONFIG.SurfaceColor}, 0.3):Play()

					for _, child in ipairs(element:GetDescendants()) do

						if child:IsA("TextLabel") then
							CreateTween(child, {TextColor3 = CONFIG.TextColor}, 0.3):Play()

						elseif child.Name == "InputBox" then
							CreateTween(child, {BackgroundColor3 = CONFIG.SurfaceColor}, 0.3):Play()

					elseif child.Name == "KeybindButton" then
						CreateTween(child, {BackgroundColor3 = CONFIG.SurfaceColor}, 0.3):Play()

					elseif child.Name == "DropdownButton" then
						CreateTween(child, {BackgroundColor3 = CONFIG.SurfaceColor}, 0.3):Play()

					elseif child.Name == "Track" then
						CreateTween(child, {BackgroundColor3 = CONFIG.BorderColor}, 0.3):Play()

					elseif child.Name == "Fill" and child.Parent.Name == "Track" then
						CreateTween(child, {BackgroundColor3 = CONFIG.AccentColor}, 0.3):Play()

					elseif child.Name == "Switch" then

						local knob = child:FindFirstChild("Knob")
						if knob and knob.Position.X.Scale > 0.5 then
							CreateTween(child, {BackgroundColor3 = CONFIG.AccentColor}, 0.3):Play()
						else
							CreateTween(child, {BackgroundColor3 = CONFIG.BorderColor}, 0.3):Play()
						end

						elseif child:IsA("TextButton") and child.Text == "Done" then
							CreateTween(child, {BackgroundColor3 = CONFIG.AccentColor}, 0.3):Play()
							CreateTween(child, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.3):Play()

						elseif child.Name == "DoneButton" or child.Name == "CloseButton" then
							CreateTween(child, {BackgroundColor3 = CONFIG.AccentColor}, 0.3):Play()

						elseif child:IsA("TextBox") then
							CreateTween(child, {BackgroundColor3 = CONFIG.BackgroundColor}, 0.3):Play()
							CreateTween(child, {TextColor3 = CONFIG.TextColor}, 0.3):Play()
							CreateTween(child, {PlaceholderColor3 = CONFIG.SecondaryTextColor}, 0.3):Play()

						elseif child.Name == "UnbindButton" and child:IsA("TextButton") then

							local unbindColor = CONFIG.AccentColor:Lerp(Color3.fromRGB(255, 95, 87), 0.5)
							CreateTween(child, {BackgroundColor3 = unbindColor}, 0.3):Play()
						end
					end
				end
			end
		end
	end

	for _, tab in ipairs(self.Tabs) do
		if tab.Content then
			for _, element in ipairs(tab.Content:GetChildren()) do
				if element.Name:match("^ColorPicker_") then
					local popup = element:FindFirstChild("ColorPickerPopup")
					if popup then

						CreateTween(popup, {BackgroundColor3 = CONFIG.SurfaceColor}, 0.3):Play()

						local dragBar = popup:FindFirstChild("DragBar")
						if dragBar then
							CreateTween(dragBar, {BackgroundColor3 = CONFIG.SurfaceColor:Lerp(CONFIG.BackgroundColor, 0.3)}, 0.3):Play()

							for _, child in ipairs(dragBar:GetChildren()) do
								if child:IsA("TextLabel") then
									CreateTween(child, {TextColor3 = CONFIG.TextColor}, 0.3):Play()
								end
							end
						end

						for _, child in ipairs(popup:GetDescendants()) do
							if child:IsA("TextLabel") and child.Name ~= "Label" then
								CreateTween(child, {TextColor3 = CONFIG.TextColor}, 0.3):Play()
							elseif child:IsA("TextBox") then
								CreateTween(child, {BackgroundColor3 = CONFIG.BackgroundColor}, 0.3):Play()
								CreateTween(child, {TextColor3 = CONFIG.TextColor}, 0.3):Play()
							elseif child.Name == "DoneButton" or child.Name == "CloseButton" then
								CreateTween(child, {BackgroundColor3 = CONFIG.AccentColor}, 0.3):Play()
							elseif child:IsA("Frame") and (child.Name == "Track" or child.Name:match("Slider")) then

								if child.Name == "Track" and not child.Parent.Name:match("Slider") then
									CreateTween(child, {BackgroundColor3 = CONFIG.BorderColor}, 0.3):Play()
								end
							end
						end
					end
				end
			end
		end
	end
end

function UILibrary:GetPresetList()

	local presetList = {}
	for name, _ in pairs(THEME_PRESETS) do
		table.insert(presetList, name)
	end
	return presetList
end

function UILibrary:SaveCurrentThemeAsPreset(presetName)

	if presetName and presetName ~= "" then
		THEME_PRESETS[presetName] = {
			BackgroundColor = CONFIG.BackgroundColor,
			SurfaceColor = CONFIG.SurfaceColor,
			AccentColor = CONFIG.AccentColor,
			TextColor = CONFIG.TextColor,
			SecondaryTextColor = CONFIG.SecondaryTextColor,
			BorderColor = CONFIG.BorderColor
		}
		return true
	end
	return false
end

function UILibrary:DeletePreset(presetName)
	if PROTECTED_PRESETS[presetName] then
		return false, "Cannot delete protected preset"
	end

	if THEME_PRESETS[presetName] then
		THEME_PRESETS[presetName] = nil
		return true, "Preset deleted successfully"
	end

	return false, "Preset not found"
end

function UILibrary:UpdatePreset(presetName, themeConfig)

	if PROTECTED_PRESETS[presetName] then
		return false, "Cannot edit protected preset"
	end

	if THEME_PRESETS[presetName] then
		for key, value in pairs(themeConfig) do
			if THEME_PRESETS[presetName][key] then
				THEME_PRESETS[presetName][key] = value
			end
		end
		return true, "Preset updated successfully"
	end

	return false, "Preset not found"
end

function UILibrary:ApplyPreset(presetName)
	if THEME_PRESETS[presetName] then
		local preset = THEME_PRESETS[presetName]
		self:UpdateTheme(preset)

		for _, tab in ipairs(self.Tabs) do
			if tab.Content then
				for _, element in ipairs(tab.Content:GetChildren()) do
					if element:IsA("Frame") and element.Name:match("^ColorPicker_") then
						local colorPreview = element:FindFirstChild("ColorPreview", true)
						if colorPreview then

							local colorName = element.Name:gsub("ColorPicker_", "")
							if colorName:find("background color") then
								colorPreview.BackgroundColor3 = preset.BackgroundColor
							elseif colorName:find("ui element") or colorName:find("element background") then
								colorPreview.BackgroundColor3 = preset.SurfaceColor
							elseif colorName:find("accent") then
								colorPreview.BackgroundColor3 = preset.AccentColor
							elseif colorName:find("text color") and not colorName:find("secondary") then
								colorPreview.BackgroundColor3 = preset.TextColor
							elseif colorName:find("secondary text") then
								colorPreview.BackgroundColor3 = preset.SecondaryTextColor
							elseif colorName:find("border") then
								colorPreview.BackgroundColor3 = preset.BorderColor
							end
						end
					end
				end
			end
		end
	end
end

function UILibrary:SetToggleKey(key)

	self.ToggleKey = key

	if self.ToggleKeyConnection then
		self.ToggleKeyConnection:Disconnect()
	end

	self.ToggleKeyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)

		if UserInputService:GetFocusedTextBox() then return end

		if input.KeyCode.Name == key then
			self:ToggleUI()

		elseif input.UserInputType.Name == key then
			self:ToggleUI()
		end
	end)
end

function UILibrary:ToggleUI()
	if self.IsMinimized then
		self:ToggleMinimize()
		return
	end
	if self.Window then
		local targetVisible = not self.Window.Visible

		if targetVisible then
			self.Window.Visible = true
			self.Window.Size = UDim2.new(0, 0, 0, 0)
			CreateTween(self.Window, {Size = CONFIG.WindowSize}, 0.4):Play()
		else
			local hideTween = CreateTween(self.Window, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
			hideTween:Play()
			task.wait(0.3)
			self.Window.Visible = false
			self.Window.Size = CONFIG.WindowSize
		end
	end
end

function UILibrary:SetWatermarkVisible(visible)
	print("SetWatermarkVisible:", visible)
end

function UILibrary:SetWatermarkStyle(style)
	print("SetWatermarkStyle:", style)
end

local notificationQueue = {}
local activeNotifications = {}
local maxNotifications = 5
local notificationContainer = nil

local function createNotificationContainer()
	if notificationContainer then return notificationContainer end

	local container = Instance.new("Frame")
	container.Name = "NotificationContainer"
	container.Size = UDim2.new(0, 350, 1, 0)
	container.Position = UDim2.new(1, -360, 0, 10)
	container.BackgroundTransparency = 1
	container.ZIndex = 10000
	local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	container.Parent = playerGui:FindFirstChild("UILibrary") or playerGui

	notificationContainer = container
	return container
end

function UILibrary:SendNotification(config)

	local title = config.Title or "Notification"
	local description = config.Description or ""
	local duration = config.Duration or 3
	local icon = config.Icon or "rbxassetid://10734923214"
	local notifType = config.Type or "info"

	local typeColors = {
		info = CONFIG.AccentColor,
		success = Color3.fromRGB(52, 199, 89),
		warning = Color3.fromRGB(255, 159, 10),
		error = Color3.fromRGB(255, 69, 58)
	}
	local accentColor = typeColors[notifType] or CONFIG.AccentColor

	local container = createNotificationContainer()

	local notif = Instance.new("Frame")
	notif.Name = "Notification"
	notif.Size = UDim2.new(1, 0, 0, 0)
	notif.BackgroundColor3 = CONFIG.SurfaceColor
	notif.BorderSizePixel = 0
	notif.ClipsDescendants = true
	notif.Position = UDim2.new(1, 10, 0, 0)
	notif.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = notif

	local stroke = Instance.new("UIStroke")
	stroke.Color = CONFIG.BorderColor
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	stroke.Parent = notif

	local accentBar = Instance.new("Frame")
	accentBar.Name = "AccentBar"
	accentBar.Size = UDim2.new(0, 4, 1, -8)
	accentBar.Position = UDim2.new(0, 4, 0, 4)
	accentBar.BackgroundColor3 = accentColor
	accentBar.BorderSizePixel = 0
	accentBar.Parent = notif

	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(1, 0)
	accentCorner.Parent = accentBar

	local iconImg = Instance.new("ImageLabel")
	iconImg.Name = "Icon"
	iconImg.Size = UDim2.new(0, 24, 0, 24)
	iconImg.Position = UDim2.new(0, 16, 0, 16)
	iconImg.BackgroundTransparency = 1
	iconImg.Image = icon
	iconImg.ImageColor3 = accentColor
	iconImg.Parent = notif

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -90, 0, 20)
	titleLabel.Position = UDim2.new(0, 48, 0, 12)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = CONFIG.TextColor
	titleLabel.Font = Enum.Font.GothamSemibold
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notif

	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "Description"
	descLabel.Size = UDim2.new(1, -90, 0, 16)
	descLabel.Position = UDim2.new(0, 48, 0, 32)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = description
	descLabel.TextColor3 = CONFIG.SecondaryTextColor
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 12
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.Parent = notif

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.Position = UDim2.new(1, -40, 0, 8)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "×"
	closeBtn.TextColor3 = CONFIG.SecondaryTextColor
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 24
	closeBtn.Parent = notif

	local descHeight = game:GetService("TextService"):GetTextSize(description, 12, Enum.Font.Gotham, Vector2.new(260, 1000)).Y
	local totalHeight = math.max(64, 56 + descHeight)
	
	-- Update description label height to fit text
	descLabel.Size = UDim2.new(1, -90, 0, descHeight)

	notif.Size = UDim2.new(1, 0, 0, totalHeight)
	CreateTween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()

	table.insert(activeNotifications, notif)

	local function repositionNotifications()
		local yOffset = 0
		for i, n in ipairs(activeNotifications) do
			CreateTween(n, {Position = UDim2.new(0, 0, 0, yOffset)}, 0.3):Play()
			yOffset = yOffset + n.Size.Y.Offset + 10
		end
	end

	local function closeNotification()

		for i, n in ipairs(activeNotifications) do
			if n == notif then
				table.remove(activeNotifications, i)
				break
			end
		end

		CreateTween(notif, {Position = UDim2.new(1, 10, 0, notif.Position.Y.Offset)}, 0.3):Play()
		task.spawn(function()
			task.wait(0.3)
			notif:Destroy()
			repositionNotifications()
		end)
	end

	closeBtn.MouseButton1Click:Connect(closeNotification)

	closeBtn.MouseEnter:Connect(function()
		CreateTween(closeBtn, {TextColor3 = CONFIG.TextColor}, 0.2):Play()
	end)
	closeBtn.MouseLeave:Connect(function()
		CreateTween(closeBtn, {TextColor3 = CONFIG.SecondaryTextColor}, 0.2):Play()
	end)

	if duration > 0 then
		local direction = CONFIG.NotificationCountdownDirection
		local targetSize, targetPosition

		if direction == "downwards" then

			accentBar.AnchorPoint = Vector2.new(0, 0)
			accentBar.Position = UDim2.new(0, 4, 0, 4)
			targetSize = UDim2.new(0, 4, 0, 0)
			targetPosition = UDim2.new(0, 4, 1, -4)
		elseif direction == "upwards" then

			accentBar.AnchorPoint = Vector2.new(0, 1)
			accentBar.Position = UDim2.new(0, 4, 1, -4)
			targetSize = UDim2.new(0, 4, 0, 0)
			targetPosition = UDim2.new(0, 4, 0, 4)
		elseif direction == "center" then

			accentBar.AnchorPoint = Vector2.new(0, 0.5)
			accentBar.Position = UDim2.new(0, 4, 0.5, 0)
			targetSize = UDim2.new(0, 4, 0, 0)
			targetPosition = UDim2.new(0, 4, 0.5, 0)
		end

		CreateTween(accentBar, {Size = targetSize, Position = targetPosition}, duration, Enum.EasingStyle.Linear):Play()

		task.delay(duration, function()
			if notif and notif.Parent then
				closeNotification()
			end
		end)
	end

	repositionNotifications()

	if #activeNotifications > maxNotifications then
		local oldest = activeNotifications[1]
		if oldest then

			for i, n in ipairs(activeNotifications) do
				if n == oldest then
					table.remove(activeNotifications, i)
					break
				end
			end
			CreateTween(oldest, {Position = UDim2.new(1, 10, 0, oldest.Position.Y.Offset)}, 0.3):Play()
			task.spawn(function()
				task.wait(0.3)
				oldest:Destroy()
				repositionNotifications()
			end)
		end
	end

	return notif
end

function UILibrary:ClearNotifications()
	for _, notif in ipairs(activeNotifications) do
		if notif and notif.Parent then
			notif:Destroy()
		end
	end
	activeNotifications = {}
end

function UILibrary:GetCurrentTheme()
	return {
		BackgroundColor = CONFIG.BackgroundColor,
		SecondaryColor = CONFIG.SecondaryColor,
		AccentColor = CONFIG.AccentColor,
		TextColor = CONFIG.TextColor,
		BorderColor = CONFIG.BorderColor
	}
end

function UILibrary:ApplyTheme(theme)
	if theme.BackgroundColor then
		CONFIG.BackgroundColor = theme.BackgroundColor
	end
	if theme.SecondaryColor then
		CONFIG.SecondaryColor = theme.SecondaryColor
	end
	if theme.AccentColor then
		CONFIG.AccentColor = theme.AccentColor
	end
	if theme.TextColor then
		CONFIG.TextColor = theme.TextColor
	end
	if theme.BorderColor then
		CONFIG.BorderColor = theme.BorderColor
	end

	if self.Window then
		self.Window.BackgroundColor3 = CONFIG.BackgroundColor
	end

	if self.TopBar then
		self.TopBar.BackgroundColor3 = CONFIG.SecondaryColor
	end

	if self.TitleLabel then
		self.TitleLabel.TextColor3 = CONFIG.TextColor
	end

	if self.Tabs then
		for _, tabData in pairs(self.Tabs) do
			if tabData.Button then
				tabData.Button.BackgroundColor3 = CONFIG.SecondaryColor
				if tabData.Button:FindFirstChild("TabLabel") then
					tabData.Button.TabLabel.TextColor3 = CONFIG.TextColor
				end
			end

			if tabData.Content then
				for _, element in ipairs(tabData.Content:GetChildren()) do
					if element:IsA("GuiObject") then
						local fill = element:FindFirstChild("Fill", true)
						if fill then
							fill.BackgroundColor3 = CONFIG.AccentColor
						end

						local thumb = element:FindFirstChild("Thumb", true)
						if thumb then
							local thumbStroke = thumb:FindFirstChild("ThumbStroke")
							if thumbStroke then
								thumbStroke.Color = CONFIG.AccentColor
							end
						end

						if element.Name:match("^Button_") then
							element.BackgroundColor3 = CONFIG.AccentColor
						end
					end
				end
			end
		end
	end

	if self.SelectedTab and self.Tabs[self.SelectedTab] then
		local selectedButton = self.Tabs[self.SelectedTab].Button
		if selectedButton then
			selectedButton.BackgroundColor3 = CONFIG.AccentColor
		end
	end
end

return UILibrary
