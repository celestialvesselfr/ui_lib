local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local CONFIG = {
    WindowSize = UDim2.new(0, 420, 0, 650),
    MinWindowSize = Vector2.new(380, 450),
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
    SidebarExpandedWidth = 180,
    SidebarCompactWidth = 50,
    SidebarAnimationSpeed = 0.25,
    
    CornerRadius = 12,
    ShadowTransparency = 0.85,
    GlassTransparency = 0.15,
}

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
    }
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
    local sg = Instance.new("ScreenGui")
    sg.Name = "UILibrary"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 999999999
    sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.ScreenGui = sg
    
    local win = CreateRoundedFrame(sg, "MainWindow")
    win.Size = CONFIG.WindowSize
    win.Position = UDim2.new(0.5, 0, 0.5, 0)
    win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.BackgroundColor3 = CONFIG.BackgroundColor
    win.BackgroundTransparency = CONFIG.GlassTransparency
    self.Window = win
    
    task.spawn(function()
        task.wait(0.1)
        CreateTween(win, {Size = CONFIG.WindowSize}, 0.5):Play()
    end)
    
    local tbar = CreateRoundedFrame(win, "TitleBar")
    tbar.Size = UDim2.new(1, 0, 0, 44)
    tbar.Position = UDim2.new(0, 0, 0, 0)
    tbar.BackgroundColor3 = CONFIG.SurfaceColor
    tbar.BackgroundTransparency = 0.3
    self.TitleBar = tbar
    
    local ctrl = Instance.new("Frame")
    ctrl.Name = "Controls"
    ctrl.Size = UDim2.new(0, 60, 1, 0)
    ctrl.Position = UDim2.new(0, 0, 0, 0)
    ctrl.BackgroundTransparency = 1
    ctrl.Parent = tbar
    
    local controls = {"Close", "Minimize"}
    local ccol = {
        Color3.fromRGB(255, 95, 87),
        Color3.fromRGB(255, 189, 68)
    }
    
    for i, name in ipairs(controls) do
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 12, 0, 12)
        btn.Position = UDim2.new(0, 12 + (i - 1) * 20, 0.5, 0)
        btn.AnchorPoint = Vector2.new(0, 0.5)
        btn.BackgroundColor3 = ccol[i]
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = ctrl
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            CreateTween(btn, {BackgroundColor3 = ccol[i]:Lerp(Color3.new(1, 1, 1), 0.2)}, 0.25):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            CreateTween(btn, {BackgroundColor3 = ccol[i]}, 0.25):Play()
        end)
        
        self["Control" .. name] = btn
    end
    
    local tlabel = CreateTextLabel(tbar, self.Title, 15)
    tlabel.Name = "TitleLabel"
    tlabel.Size = UDim2.new(1, -140, 1, 0)
    local tx0 = (CONFIG.SidebarCompactWidth + 70) / 2
    tlabel.Position = UDim2.new(0, tx0, 0, 0)
    tlabel.TextXAlignment = Enum.TextXAlignment.Center
    tlabel.Font = Enum.Font.GothamBold
    
    local sbar = Instance.new("Frame")
    sbar.Name = "TabBar"
    sbar.Size = UDim2.new(0, CONFIG.SidebarCompactWidth, 1, -44)
    sbar.Position = UDim2.new(0, 0, 0, 44)
    sbar.BackgroundColor3 = CONFIG.SurfaceColor
    sbar.BackgroundTransparency = 0.5
    sbar.BorderSizePixel = 0
    sbar.ClipsDescendants = true
    sbar.Parent = win
    self.TabBar = sbar
    self.SidebarExpanded = false
    
    local pill = Instance.new("Frame")
    pill.Name = "HoverPill"
    pill.Size = UDim2.new(0, 34, 0, 34)
    pill.Position = UDim2.new(0, 8, 0, 1)
    pill.BackgroundColor3 = CONFIG.AccentColor
    pill.BackgroundTransparency = 0.2
    pill.BorderSizePixel = 0
    pill.ZIndex = 0
    pill.Parent = sbar
    local pcorner = Instance.new("UICorner")
    pcorner.CornerRadius = UDim.new(1, 0)
    pcorner.Parent = pill
    self.HoverPill = pill
    
    local tcont = Instance.new("ScrollingFrame")
    tcont.Name = "TabContainer"
    tcont.Size = UDim2.new(0, CONFIG.SidebarExpandedWidth - 12, 1, -12)
    tcont.Position = UDim2.new(0, 6, 0, 6)
    tcont.BackgroundTransparency = 1
    tcont.BorderSizePixel = 0
    tcont.ScrollBarThickness = 4
    tcont.ScrollBarImageColor3 = CONFIG.AccentColor
    tcont.CanvasSize = UDim2.new(0, 0, 0, 0)
    tcont.Parent = sbar
    self.TabContainer = tcont
    local tl = Instance.new("UIListLayout")
    tl.SortOrder = Enum.SortOrder.LayoutOrder
    tl.Padding = UDim.new(0, 4)
    tl.Parent = tcont
    
    local carea = Instance.new("Frame")
    carea.Name = "ContentArea"
    carea.Size = UDim2.new(1, -CONFIG.SidebarCompactWidth - 12, 1, -56)
    carea.Position = UDim2.new(0, CONFIG.SidebarCompactWidth + 6, 0, 50)
    carea.BackgroundTransparency = 1
    carea.BorderSizePixel = 0
    carea.Parent = win
    self.ContentArea = carea
    
    self.TitleLabel = tlabel
    self.ControlsFrame = ctrl
    
    self:SetupSidebarCollapse()
end

function UILibrary:SetupSidebarCollapse()
    local expand = function()
        if self.SidebarExpanded then return end
        self.SidebarExpanded = true
        
        CreateTween(self.TabBar, {Size = UDim2.new(0, CONFIG.SidebarExpandedWidth, 1, -44)}, CONFIG.SidebarAnimationSpeed):Play()
        
        CreateTween(self.ContentArea, {
            Size = UDim2.new(1, -CONFIG.SidebarExpandedWidth - 12, 1, -56),
            Position = UDim2.new(0, CONFIG.SidebarExpandedWidth + 6, 0, 50)
        }, CONFIG.SidebarAnimationSpeed):Play()
        
        local tx = (CONFIG.SidebarExpandedWidth + 70) / 2
        CreateTween(self.TitleLabel, {
            Position = UDim2.new(0, tx, 0, 0)
        }, CONFIG.SidebarAnimationSpeed):Play()
        
        for _, tab in ipairs(self.Tabs) do
            if tab.Label then
                CreateTween(tab.Label, {TextTransparency = 0}, CONFIG.SidebarAnimationSpeed):Play()
            end
        end
        
        CreateTween(self.HoverPill, {Size = UDim2.new(1, -16, 0, 36)}, CONFIG.SidebarAnimationSpeed):Play()
        
        if self.CurrentTab and self.CurrentTab.Button then
            local ty = self.CurrentTab.Button.AbsolutePosition.Y - self.TabBar.AbsolutePosition.Y
            CreateTween(self.HoverPill, {
                Position = UDim2.new(0, 8, 0, ty)
            }, CONFIG.SidebarAnimationSpeed):Play()
        end
    end
    
    local compact = function()
        if not self.SidebarExpanded then return end
        self.SidebarExpanded = false
        
        CreateTween(self.TabBar, {Size = UDim2.new(0, CONFIG.SidebarCompactWidth, 1, -44)}, CONFIG.SidebarAnimationSpeed):Play()
        
        CreateTween(self.ContentArea, {
            Size = UDim2.new(1, -CONFIG.SidebarCompactWidth - 12, 1, -56),
            Position = UDim2.new(0, CONFIG.SidebarCompactWidth + 6, 0, 50)
        }, CONFIG.SidebarAnimationSpeed):Play()
        
        local tx = (CONFIG.SidebarCompactWidth + 70) / 2
        CreateTween(self.TitleLabel, {
            Position = UDim2.new(0, tx, 0, 0)
        }, CONFIG.SidebarAnimationSpeed):Play()
        
        for _, tab in ipairs(self.Tabs) do
            if tab.Label then
                CreateTween(tab.Label, {TextTransparency = 1}, CONFIG.SidebarAnimationSpeed):Play()
            end
        end
        
        CreateTween(self.HoverPill, {Size = UDim2.new(0, 34, 0, 34)}, CONFIG.SidebarAnimationSpeed):Play()
        
        if self.CurrentTab and self.CurrentTab.Button then
            local ty = self.CurrentTab.Button.AbsolutePosition.Y - self.TabBar.AbsolutePosition.Y
            CreateTween(self.HoverPill, {
                Position = UDim2.new(0, 8, 0, ty + 1)
            }, CONFIG.SidebarAnimationSpeed):Play()
        end
    end
    
    self.TabBar.MouseEnter:Connect(expand)
    self.TabBar.MouseLeave:Connect(compact)
end

function UILibrary:SetupInteractions()
    local drag = false
    local dstart
    local pstart
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dstart = Vector2.new(input.Position.X, input.Position.Y)
            pstart = self.Window.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dstart
            CreateTween(self.Window, {
                Position = UDim2.new(
                    pstart.X.Scale, pstart.X.Offset + delta.X,
                    pstart.Y.Scale, pstart.Y.Offset + delta.Y
                )
            }, 0.05):Play()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
        end
    end)
    
    self.ControlClose.MouseButton1Click:Connect(function()
        CreateTween(self.Window, {
            Size = UDim2.new(0, 200, 0, 200),
            Position = UDim2.new(0.5, -100, 0.5, -100),
            BackgroundTransparency = 1
        }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
        
        task.wait(0.28)
        self.ScreenGui:Destroy()
    end)
    
    self.ControlMinimize.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
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
        
        if self.TitleBar:FindFirstChild("TitleLabel") then
            self.TitleBar.TitleLabel.Visible = false
        end
        self.ControlMinimize.Visible = false
        
        self.ControlClose.Position = UDim2.new(0, 8, 0.5, 0)
    else
        local targetSize = self.SizeBeforeMinimize or CONFIG.WindowSize
        CreateTween(self.Window, {Size = targetSize}, CONFIG.AnimationSpeed):Play()
        
        CreateTween(self.Window, {BackgroundTransparency = 0.1}, CONFIG.AnimationSpeed):Play()
        CreateTween(self.TitleBar, {BackgroundTransparency = 0}, CONFIG.AnimationSpeed):Play()
        CreateTween(self.TitleBar, {Size = UDim2.new(1, 0, 0, 44)}, CONFIG.AnimationSpeed):Play()
        
        self.TabBar.Visible = true
        self.ContentArea.Visible = true
        
        if self.TitleBar:FindFirstChild("TitleLabel") then
            self.TitleBar.TitleLabel.Visible = true
        end
        self.ControlMinimize.Visible = true
        
        self.ControlClose.Position = UDim2.new(0, 12, 0.5, 0)
    end
end

function UILibrary:AddTab(name, icon)
    local tab = {}
    tab.Name = name
    tab.IconPath = icon or CONFIG.TabIcons.DefaultIcon
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
        tabIcon.Image = tab.IconPath
        tabIcon.ImageColor3 = CONFIG.TextColor
        tabIcon.Parent = tabButton
    end
    
    local tabLabel = CreateTextLabel(tabButton, name, 14)
    
    tabButton.Name = name
    tabButton.Size = UDim2.new(1, -8, 0, 36)
    tabButton.BackgroundColor3 = CONFIG.SurfaceColor
    tabButton.BackgroundTransparency = 1
    tabButton.BorderSizePixel = 0
    tabButton.Text = ""
    tabButton.AutoButtonColor = false
    tabButton.Parent = self.TabContainer
    tabButton.ZIndex = 2
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
    tabLabel.TextTransparency = 1
    
    tab.Label = tabLabel
    tab.Icon = tabIcon
    
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
        local targetY = tabButton.AbsolutePosition.Y - self.TabBar.AbsolutePosition.Y
        local pillX = 8
        local yOff = self.SidebarExpanded and 0 or 1
        CreateTween(self.HoverPill, {
            Position = UDim2.new(0, pillX, 0, targetY + yOff),
            BackgroundTransparency = 0.15
        }, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
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
    
    return tab
end

function UILibrary:SelectTab(tab)
    if self.CurrentTab then
        CreateTween(self.CurrentTab.Content, {Position = UDim2.new(0, -20, 0, 0)}, 0.2):Play()
        task.wait(0.1)
        self.CurrentTab.Content.Visible = false
    end
    
    self.CurrentTab = tab
    tab.Content.Visible = true
    tab.Content.Position = UDim2.new(0, 20, 0, 0)
    CreateTween(tab.Content, {Position = UDim2.new(0, 0, 0, 0)}, 0.3):Play()
    
    local targetY = tab.Button.AbsolutePosition.Y - self.TabBar.AbsolutePosition.Y
    local pillX = 8
    local yOff = self.SidebarExpanded and 0 or 1
    CreateTween(self.HoverPill, {
        Position = UDim2.new(0, pillX, 0, targetY + yOff),
        BackgroundTransparency = 0.2
    }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
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
            currentValue = math.clamp(inputValue, min, max)
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
        else
            valueBox.Text = tostring(currentValue)
        end
    end)
    
    local sliderObject = {
        Container = container,
        SetValue = function(value)
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
    
    local inputObject = {
        Container = container,
        SetValue = function(value)
            input.Text = value
        end
    }
    
    return inputObject
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

function UILibrary:CreateColorPicker(tab, name, default, callback)
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
    
    previewBtn.MouseButton1Click:Connect(function()
        CreateTween(colorPreview, {BackgroundTransparency = 0.5}, 0.07):Play()
        task.wait(0.07)
        CreateTween(colorPreview, {BackgroundTransparency = 0}, 0.12):Play()
        callback(currentColor)
    end)
    
    local colorPickerObject = {
        Container = container,
        SetColor = function(color)
            if not color or typeof(color) ~= "Color3" then
                warn("[UILibrary] SetColor received invalid color:", color)
                return
            end
            currentColor = color
            colorPreview.BackgroundColor3 = color
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
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = dropdownButton
    
    button.MouseButton1Click:Connect(function()
        if not dropdownOpen then
            dropdownOpen = true
            CreateTween(arrow, {Rotation = 180}, 0.2):Play()
            
            local dropdownWrapper = Instance.new("Frame")
            dropdownWrapper.Name = "DropdownWrapper"
            dropdownWrapper.Size = UDim2.new(1, -CONFIG.Padding * 2, 0, math.min(#options * 32, 200))
            dropdownWrapper.Position = UDim2.new(0, CONFIG.Padding, 0, 68)
            dropdownWrapper.BackgroundColor3 = CONFIG.SurfaceColor
            dropdownWrapper.BorderSizePixel = 0
            dropdownWrapper.ZIndex = 10000
            dropdownWrapper.ClipsDescendants = true
            dropdownWrapper.Parent = container
            
            local wrapperCorner = Instance.new("UICorner")
            wrapperCorner.CornerRadius = UDim.new(0, CONFIG.CornerRadius)
            wrapperCorner.Parent = dropdownWrapper
            
            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Parent = dropdownWrapper
            
            for i, option in ipairs(options) do
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
                optionButton.Parent = dropdownWrapper
                
                optionLabel.Size = UDim2.new(1, -16, 1, 0)
                optionLabel.Position = UDim2.new(0, 8, 0, 0)
                optionLabel.ZIndex = 10002
                optionCorner.CornerRadius = UDim.new(0, CONFIG.CornerRadius)
                optionCorner.Parent = optionButton
                
                optionButton.MouseButton1Click:Connect(function()
                    currentSelection = option
                    selectedLabel.Text = option
                    
                    CreateTween(dropdownWrapper, {Size = UDim2.new(1, -CONFIG.Padding * 2, 0, 0)}, 0.15):Play()
                    CreateTween(arrow, {Rotation = 0}, 0.2):Play()
                    task.wait(0.15)
                    dropdownWrapper:Destroy()
                    dropdownOpen = false
                    
                    callback(option)
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
        else
            if container:FindFirstChild("DropdownWrapper") then
                local dropdownWrapper = container.DropdownWrapper
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
        end
    }
    
    return dropdownObject
end

function UILibrary:UpdateTheme(themeConfig)
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
    
    if self.HoverPill then
        CreateTween(self.HoverPill, {BackgroundColor3 = CONFIG.AccentColor}, 0.3):Play()
    end
end

function UILibrary:ApplyPreset(presetName)
    if THEME_PRESETS[presetName] then
        local preset = THEME_PRESETS[presetName]
        self:UpdateTheme(preset)
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

return UILibrary
