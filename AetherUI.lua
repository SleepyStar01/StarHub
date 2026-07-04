--[[
    🌟 AetherUI - Modern Roblox UI Library
    Created for SleepyHub
    Version: 1.0.0
    
    Features:
    - Dark/Light theme support
    - Smooth animations
    - Modern components
    - Easy to use API
    - Responsive design
    - Custom notifications
]]

local AetherUI = {}
AetherUI.__index = AetherUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Default Theme
AetherUI.DefaultTheme = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 48),
        Surface = Color3.fromRGB(45, 45, 60),
        Primary = Color3.fromRGB(88, 101, 242),
        Accent = Color3.fromRGB(114, 137, 218),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Danger = Color3.fromRGB(240, 71, 71),
        Text = Color3.fromRGB(220, 221, 232),
        TextSecondary = Color3.fromRGB(142, 146, 162),
        Border = Color3.fromRGB(60, 62, 78),
        ScrollBar = Color3.fromRGB(88, 101, 242)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Secondary = Color3.fromRGB(255, 255, 255),
        Surface = Color3.fromRGB(245, 245, 250),
        Primary = Color3.fromRGB(88, 101, 242),
        Accent = Color3.fromRGB(114, 137, 218),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Danger = Color3.fromRGB(240, 71, 71),
        Text = Color3.fromRGB(30, 30, 40),
        TextSecondary = Color3.fromRGB(100, 100, 110),
        Border = Color3.fromRGB(200, 200, 210),
        ScrollBar = Color3.fromRGB(88, 101, 242)
    }
}

-- Animation Presets
AetherUI.AnimationPresets = {
    Spring = {
        Style = Enum.EasingStyle.Elastic,
        Direction = Enum.EasingDirection.Out,
        Duration = 0.8
    },
    Smooth = {
        Style = Enum.EasingStyle.Quart,
        Direction = Enum.EasingDirection.Out,
        Duration = 0.3
    },
    Bouncy = {
        Style = Enum.EasingStyle.Back,
        Direction = Enum.EasingDirection.Out,
        Duration = 0.5
    },
    Linear = {
        Style = Enum.EasingStyle.Linear,
        Direction = Enum.EasingDirection.Out,
        Duration = 0.2
    }
}

-- Constructor
function AetherUI.new(config)
    local self = setmetatable({}, AetherUI)
    
    -- Default configuration
    self.Name = config.Name or "AetherUI"
    self.Theme = config.Theme or "Dark"
    self.Size = config.Size or UDim2.new(0, 550, 0, 600)
    self.Position = config.Position or UDim2.new(0.5, -275, 0.5, -300)
    self.Draggable = config.Draggable ~= false
    self.Resizable = config.Resizable or false
    self.AnimationSpeed = config.AnimationSpeed or "Smooth"
    
    -- Load theme colors
    self.Colors = AetherUI.DefaultTheme[self.Theme]
    
    -- Create main container
    self:CreateMainWindow()
    
    -- Storage
    self.Tabs = {}
    self.Notifications = {}
    self.Modals = {}
    
    return self
end

-- Helper: Create Tween
function AetherUI:Tween(instance, properties, customPreset)
    local preset = AetherUI.AnimationPresets[customPreset or self.AnimationSpeed]
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(preset.Duration, preset.Style, preset.Direction),
        properties
    )
    tween:Play()
    return tween
end

-- Helper: Create UICorner
function AetherUI:AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = instance
    return corner
end

-- Helper: Create UIStroke
function AetherUI:AddStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or self.Colors.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = instance
    return stroke
end

-- Helper: Create UIGradient
function AetherUI:AddGradient(instance, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors or {
        ColorSequenceKeypoint.new(0, self.Colors.Primary),
        ColorSequenceKeypoint.new(1, self.Colors.Accent)
    })
    gradient.Rotation = rotation or 90
    gradient.Parent = instance
    return gradient
end

-- Create Main Window
function AetherUI:CreateMainWindow()
    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = self.Name
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = CoreGui
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = self.Size
    self.MainFrame.Position = self.Position
    self.MainFrame.BackgroundColor3 = self.Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui
    
    self:AddCorner(self.MainFrame, 12)
    self:AddStroke(self.MainFrame, self.Colors.Border, 1)
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, 45)
    self.TitleBar.BackgroundColor3 = self.Colors.Secondary
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame
    
    self:AddCorner(self.TitleBar, 12)
    
    -- Title Label
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.TextColor3 = self.Colors.Text
    self.TitleLabel.Text = self.Name
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextSize = 16
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar
    
    -- Close Button
    self:CreateWindowControls()
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(1, 0, 0, 40)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 45)
    self.TabContainer.BackgroundColor3 = self.Colors.Secondary
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainFrame
    
    self:AddStroke(self.TabContainer, self.Colors.Border:Lerp(Color3.fromRGB(0,0,0), 0.8), 0.5)
    
    -- Content Container
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Size = UDim2.new(1, 0, 1, -85)
    self.ContentContainer.Position = UDim2.new(0, 0, 0, 85)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent = self.MainFrame
    
    -- Draggable
    if self.Draggable then
        self:MakeDraggable(self.TitleBar)
    end
end

-- Window Controls
function AetherUI:CreateWindowControls()
    -- Minimize Button
    self.MinimizeBtn = Instance.new("TextButton")
    self.MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    self.MinimizeBtn.Position = UDim2.new(1, -105, 0, 7)
    self.MinimizeBtn.BackgroundColor3 = self.Colors.Surface
    self.MinimizeBtn.TextColor3 = self.Colors.Text
    self.MinimizeBtn.Text = "—"
    self.MinimizeBtn.Font = Enum.Font.GothamBold
    self.MinimizeBtn.TextSize = 16
    self.MinimizeBtn.Parent = self.TitleBar
    self:AddCorner(self.MinimizeBtn, 6)
    
    -- Maximize Button
    self.MaximizeBtn = Instance.new("TextButton")
    self.MaximizeBtn.Size = UDim2.new(0, 30, 0, 30)
    self.MaximizeBtn.Position = UDim2.new(1, -70, 0, 7)
    self.MaximizeBtn.BackgroundColor3 = self.Colors.Surface
    self.MaximizeBtn.TextColor3 = self.Colors.Text
    self.MaximizeBtn.Text = "□"
    self.MaximizeBtn.Font = Enum.Font.GothamBold
    self.MaximizeBtn.TextSize = 16
    self.MaximizeBtn.Parent = self.TitleBar
    self:AddCorner(self.MaximizeBtn, 6)
    
    -- Close Button
    self.CloseBtn = Instance.new("TextButton")
    self.CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    self.CloseBtn.Position = UDim2.new(1, -35, 0, 7)
    self.CloseBtn.BackgroundColor3 = self.Colors.Danger
    self.CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.CloseBtn.Text = "✕"
    self.CloseBtn.Font = Enum.Font.GothamBold
    self.CloseBtn.TextSize = 16
    self.CloseBtn.Parent = self.TitleBar
    self:AddCorner(self.CloseBtn, 6)
    
    -- Close functionality
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
end

-- Make Draggable
function AetherUI:MakeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Create Tab
function AetherUI:CreateTab(name, icon)
    local tab = {
        Name = name,
        Icon = icon or "📄",
        Parent = self,
        Active = #self.Tabs == 0
    }
    
    -- Tab Button
    local buttonWidth = math.min(1 / math.max(#self.Tabs + 1, 1), 0.25)
    
    tab.Button = Instance.new("TextButton")
    tab.Button.Size = UDim2.new(0, 120, 1, 0)
    tab.Button.Position = UDim2.new(0, #self.Tabs * 122 + 5, 0, 0)
    tab.Button.BackgroundTransparency = 1
    tab.Button.TextColor3 = tab.Active and self.Colors.Text or self.Colors.TextSecondary
    tab.Button.Text = (icon or "") .. " " .. name
    tab.Button.Font = Enum.Font.GothamMedium
    tab.Button.TextSize = 12
    tab.Button.Parent = self.TabContainer
    
    -- Tab Content
    tab.Content = Instance.new("ScrollingFrame")
    tab.Content.Size = UDim2.new(1, -20, 1, -20)
    tab.Content.Position = UDim2.new(0, 10, 0, 10)
    tab.Content.BackgroundTransparency = 1
    tab.Content.BorderSizePixel = 0
    tab.Content.ScrollBarThickness = 3
    tab.Content.ScrollBarImageColor3 = self.Colors.ScrollBar
    tab.Content.Visible = tab.Active
    tab.Content.Parent = self.ContentContainer
    
    -- Content Layout
    tab.Layout = Instance.new("UIListLayout")
    tab.Layout.Padding = UDim.new(0, 8)
    tab.Layout.Parent = tab.Content
    
    tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab Click Handler
    tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    return tab
end

-- Switch Tab
function AetherUI:SwitchTab(tab)
    for _, t in ipairs(self.Tabs) do
        local isActive = t == tab
        t.Active = isActive
        t.Content.Visible = isActive
        self:Tween(t.Button, {
            TextColor3 = isActive and self.Colors.Text or self.Colors.TextSecondary
        })
    end
end

-- Create Section
function AetherUI:CreateSection(tab, name)
    local section = {
        Name = name,
        Parent = tab
    }
    
    -- Section Container
    section.Container = Instance.new("Frame")
    section.Container.Size = UDim2.new(1, 0, 0, 30)
    section.Container.BackgroundTransparency = 1
    section.Container.Parent = tab.Content
    
    -- Section Line
    section.Line = Instance.new("Frame")
    section.Line.Size = UDim2.new(0, 3, 0, 18)
    section.Line.Position = UDim2.new(0, 0, 0.5, -9)
    section.Line.BackgroundColor3 = self.Colors.Primary
    section.Line.Parent = section.Container
    self:AddCorner(section.Line, 2)
    
    -- Section Label
    section.Label = Instance.new("TextLabel")
    section.Label.Size = UDim2.new(1, -10, 1, 0)
    section.Label.Position = UDim2.new(0, 10, 0, 0)
    section.Label.BackgroundTransparency = 1
    section.Label.TextColor3 = self.Colors.TextSecondary
    section.Label.Text = name
    section.Label.Font = Enum.Font.GothamBold
    section.Label.TextSize = 12
    section.Label.TextXAlignment = Enum.TextXAlignment.Left
    section.Label.Parent = section.Container
    
    return section
end

-- Create Button
function AetherUI:CreateButton(tab, config)
    local button = {
        Name = config.Name or "Button",
        Callback = config.Callback or function() end,
        Color = config.Color or self.Colors.Primary,
        Icon = config.Icon or "▶"
    }
    
    button.Instance = Instance.new("TextButton")
    button.Instance.Size = UDim2.new(1, 0, 0, config.Height or 38)
    button.Instance.BackgroundColor3 = button.Color
    button.Instance.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Instance.Text = button.Icon .. " " .. button.Name
    button.Instance.Font = Enum.Font.GothamBold
    button.Instance.TextSize = config.FontSize or 13
    button.Instance.Parent = tab.Content
    
    self:AddCorner(button.Instance, 6)
    
    -- Hover effects
    button.Instance.MouseEnter:Connect(function()
        self:Tween(button.Instance, {
            BackgroundColor3 = button.Color:Lerp(Color3.fromRGB(255, 255, 255), 0.15)
        })
    end)
    
    button.Instance.MouseLeave:Connect(function()
        self:Tween(button.Instance, {
            BackgroundColor3 = button.Color
        })
    end)
    
    -- Click handler
    button.Instance.MouseButton1Click:Connect(function()
        self:Tween(button.Instance, {
            BackgroundColor3 = button.Color:Lerp(Color3.fromRGB(0, 0, 0), 0.2)
        })
        task.wait(0.1)
        self:Tween(button.Instance, {
            BackgroundColor3 = button.Color
        })
        button.Callback()
    end)
    
    return button
end

-- Create Toggle
function AetherUI:CreateToggle(tab, config)
    local toggle = {
        Name = config.Name or "Toggle",
        State = config.Default or false,
        Callback = config.Callback or function() end,
        Color = config.Color or self.Colors.Success
    }
    
    -- Container
    toggle.Container = Instance.new("Frame")
    toggle.Container.Size = UDim2.new(1, 0, 0, 45)
    toggle.Container.BackgroundColor3 = self.Colors.Surface
    toggle.Container.BorderSizePixel = 0
    toggle.Container.Parent = tab.Content
    
    self:AddCorner(toggle.Container, 6)
    
    -- Icon
    toggle.Icon = Instance.new("TextLabel")
    toggle.Icon.Size = UDim2.new(0, 25, 0, 25)
    toggle.Icon.Position = UDim2.new(0, 12, 0.5, -12)
    toggle.Icon.BackgroundTransparency = 1
    toggle.Icon.Text = config.Icon or "🔹"
    toggle.Icon.TextSize = 16
    toggle.Icon.Parent = toggle.Container
    
    -- Label
    toggle.Label = Instance.new("TextLabel")
    toggle.Label.Size = UDim2.new(0.6, -45, 1, 0)
    toggle.Label.Position = UDim2.new(0, 45, 0, 0)
    toggle.Label.BackgroundTransparency = 1
    toggle.Label.TextColor3 = self.Colors.Text
    toggle.Label.Text = toggle.Name
    toggle.Label.Font = Enum.Font.GothamSemibold
    toggle.Label.TextSize = 13
    toggle.Label.TextXAlignment = Enum.TextXAlignment.Left
    toggle.Label.Parent = toggle.Container
    
    -- Toggle Button
    toggle.Button = Instance.new("TextButton")
    toggle.Button.Size = UDim2.new(0, 48, 0, 24)
    toggle.Button.Position = UDim2.new(1, -60, 0.5, -12)
    toggle.Button.BackgroundColor3 = toggle.State and toggle.Color or Color3.fromRGB(60, 62, 78)
    toggle.Button.Text = ""
    toggle.Button.Parent = toggle.Container
    
    self:AddCorner(toggle.Button, 12)
    
    -- Toggle Dot
    toggle.Dot = Instance.new("Frame")
    toggle.Dot.Size = UDim2.new(0, 18, 0, 18)
    toggle.Dot.Position = toggle.State and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    toggle.Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Dot.Parent = toggle.Button
    
    self:AddCorner(toggle.Dot, 9)
    
    -- Status Label
    toggle.StatusLabel = Instance.new("TextLabel")
    toggle.StatusLabel.Size = UDim2.new(0, 35, 1, 0)
    toggle.StatusLabel.Position = UDim2.new(1, -115, 0, 0)
    toggle.StatusLabel.BackgroundTransparency = 1
    toggle.StatusLabel.TextColor3 = toggle.State and toggle.Color or self.Colors.TextSecondary
    toggle.StatusLabel.Text = toggle.State and "ON" or "OFF"
    toggle.StatusLabel.Font = Enum.Font.GothamBold
    toggle.StatusLabel.TextSize = 10
    toggle.StatusLabel.Parent = toggle.Container
    
    -- Toggle Function
    local function updateToggle()
        toggle.State = not toggle.State
        local targetColor = toggle.State and toggle.Color or Color3.fromRGB(60, 62, 78)
        local targetPos = toggle.State and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        
        self:Tween(toggle.Button, {BackgroundColor3 = targetColor})
        self:Tween(toggle.Dot, {Position = targetPos})
        toggle.StatusLabel.TextColor3 = toggle.State and toggle.Color or self.Colors.TextSecondary
        toggle.StatusLabel.Text = toggle.State and "ON" or "OFF"
        
        toggle.Callback(toggle.State)
    end
    
    toggle.Button.MouseButton1Click:Connect(updateToggle)
    toggle.Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateToggle()
        end
    end)
    
    return toggle
end

-- Create Slider
function AetherUI:CreateSlider(tab, config)
    local slider = {
        Name = config.Name or "Slider",
        Min = config.Min or 0,
        Max = config.Max or 100,
        Default = config.Default or 50,
        Callback = config.Callback or function() end,
        Color = config.Color or self.Colors.Primary
    }
    
    slider.Value = slider.Default
    
    -- Container
    slider.Container = Instance.new("Frame")
    slider.Container.Size = UDim2.new(1, 0, 0, 60)
    slider.Container.BackgroundColor3 = self.Colors.Surface
    slider.Container.BorderSizePixel = 0
    slider.Container.Parent = tab.Content
    
    self:AddCorner(slider.Container, 6)
    
    -- Label
    slider.Label = Instance.new("TextLabel")
    slider.Label.Size = UDim2.new(1, -20, 0, 20)
    slider.Label.Position = UDim2.new(0, 10, 0, 5)
    slider.Label.BackgroundTransparency = 1
    slider.Label.TextColor3 = self.Colors.Text
    slider.Label.Text = slider.Name
    slider.Label.Font = Enum.Font.GothamSemibold
    slider.Label.TextSize = 12
    slider.Label.TextXAlignment = Enum.TextXAlignment.Left
    slider.Label.Parent = slider.Container
    
    -- Slider Background
    slider.SliderBg = Instance.new("Frame")
    slider.SliderBg.Size = UDim2.new(1, -80, 0, 6)
    slider.SliderBg.Position = UDim2.new(0, 10, 0, 35)
    slider.SliderBg.BackgroundColor3 = self.Colors.Background
    slider.SliderBg.BorderSizePixel = 0
    slider.SliderBg.Parent = slider.Container
    
    self:AddCorner(slider.SliderBg, 3)
    
    -- Slider Fill
    local fillPercent = (slider.Value - slider.Min) / (slider.Max - slider.Min)
    slider.SliderFill = Instance.new("Frame")
    slider.SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    slider.SliderFill.BackgroundColor3 = slider.Color
    slider.SliderFill.BorderSizePixel = 0
    slider.SliderFill.Parent = slider.SliderBg
    
    self:AddCorner(slider.SliderFill, 3)
    
    -- Slider Button
    slider.SliderBtn = Instance.new("TextButton")
    slider.SliderBtn.Size = UDim2.new(0, 18, 0, 18)
    slider.SliderBtn.Position = UDim2.new(fillPercent, -9, 0.5, -9)
    slider.SliderBtn.BackgroundColor3 = slider.Color
    slider.SliderBtn.Text = ""
    slider.SliderBtn.Parent = slider.SliderBg
    
    self:AddCorner(slider.SliderBtn, 9)
    self:AddStroke(slider.SliderBtn, Color3.fromRGB(255,255,255), 2)
    
    -- Value Label
    slider.ValueLabel = Instance.new("TextLabel")
    slider.ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    slider.ValueLabel.Position = UDim2.new(1, -60, 0, 30)
    slider.ValueLabel.BackgroundTransparency = 1
    slider.ValueLabel.TextColor3 = self.Colors.Text
    slider.ValueLabel.Text = tostring(slider.Value)
    slider.ValueLabel.Font = Enum.Font.GothamBold
    slider.ValueLabel.TextSize = 12
    slider.ValueLabel.Parent = slider.Container
    
    -- Slider Interaction
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - slider.SliderBg.AbsolutePosition.X) / slider.SliderBg.AbsoluteSize.X, 0, 1)
        slider.Value = math.floor(slider.Min + (slider.Max - slider.Min) * relativeX)
        
        self:Tween(slider.SliderFill, {Size = UDim2.new(relativeX, 0, 1, 0)})
        self:Tween(slider.SliderBtn, {Position = UDim2.new(relativeX, -9, 0.5, -9)})
        
        slider.ValueLabel.Text = tostring(slider.Value)
        slider.Callback(slider.Value)
    end
    
    local sliding = false
    
    slider.SliderBtn.MouseButton1Down:Connect(function()
        sliding = true
    end)
    
    slider.SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return slider
end

-- Create Dropdown
function AetherUI:CreateDropdown(tab, config)
    local dropdown = {
        Name = config.Name or "Dropdown",
        Options = config.Options or {},
        Default = config.Default or "",
        Callback = config.Callback or function() end,
        Color = config.Color or self.Colors.Primary
    }
    
    dropdown.Value = dropdown.Default
    dropdown.IsOpen = false
    
    -- Container
    dropdown.Container = Instance.new("Frame")
    dropdown.Container.Size = UDim2.new(1, 0, 0, 45)
    dropdown.Container.BackgroundColor3 = self.Colors.Surface
    dropdown.Container.BorderSizePixel = 0
    dropdown.Container.ClipsDescendants = true
    dropdown.Container.Parent = tab.Content
    
    self:AddCorner(dropdown.Container, 6)
    
    -- Main Button
    dropdown.Button = Instance.new("TextButton")
    dropdown.Button.Size = UDim2.new(1, 0, 0, 45)
    dropdown.Button.BackgroundColor3 = self.Colors.Surface
    dropdown.Button.TextColor3 = self.Colors.Text
    dropdown.Button.Text = dropdown.Name .. ": " .. dropdown.Value
    dropdown.Button.Font = Enum.Font.GothamSemibold
    dropdown.Button.TextSize = 13
    dropdown.Button.TextXAlignment = Enum.TextXAlignment.Left
    dropdown.Button.Parent = dropdown.Container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.Parent = dropdown.Button
    
    -- Arrow
    dropdown.Arrow = Instance.new("TextLabel")
    dropdown.Arrow.Size = UDim2.new(0, 20, 0, 20)
    dropdown.Arrow.Position = UDim2.new(1, -30, 0.5, -10)
    dropdown.Arrow.BackgroundTransparency = 1
    dropdown.Arrow.TextColor3 = self.Colors.TextSecondary
    dropdown.Arrow.Text = "▼"
    dropdown.Arrow.TextSize = 12
    dropdown.Arrow.Parent = dropdown.Button
    
    -- Options Container
    dropdown.OptionsContainer = Instance.new("Frame")
    dropdown.OptionsContainer.Size = UDim2.new(1, 0, 0, #dropdown.Options * 35)
    dropdown.OptionsContainer.Position = UDim2.new(0, 0, 0, 45)
    dropdown.OptionsContainer.BackgroundColor3 = self.Colors.Secondary
    dropdown.OptionsContainer.BorderSizePixel = 0
    dropdown.OptionsContainer.ClipsDescendants = true
    dropdown.OptionsContainer.Parent = dropdown.Container
    
    -- Options Layout
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Parent = dropdown.OptionsContainer
    
    -- Create Options
    for i, option in ipairs(dropdown.Options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, 0, 0, 35)
        optionBtn.BackgroundColor3 = option == dropdown.Value and dropdown.Color:Lerp(Color3.fromRGB(0,0,0), 0.5) or self.Colors.Secondary
        optionBtn.TextColor3 = self.Colors.Text
        optionBtn.Text = option
        optionBtn.Font = Enum.Font.GothamMedium
        optionBtn.TextSize = 12
        optionBtn.Parent = dropdown.OptionsContainer
        
        optionBtn.MouseEnter:Connect(function()
            self:Tween(optionBtn, {BackgroundColor3 = dropdown.Color:Lerp(Color3.fromRGB(0,0,0), 0.3)})
        end)
        
        optionBtn.MouseLeave:Connect(function()
            if option ~= dropdown.Value then
                self:Tween(optionBtn, {BackgroundColor3 = self.Colors.Secondary})
            end
        end)
        
        optionBtn.MouseButton1Click:Connect(function()
            dropdown.Value = option
            dropdown.Button.Text = dropdown.Name .. ": " .. option
            dropdown:Close()
            dropdown.Callback(option)
        end)
    end
    
    -- Toggle Dropdown
    function dropdown:Open()
        dropdown.IsOpen = true
        self:Tween(dropdown.Container, {Size = UDim2.new(1, 0, 0, 45 + #dropdown.Options * 35)})
        self:Tween(dropdown.Arrow, {Rotation = 180})
        tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y + #dropdown.Options * 35 + 20)
    end
    
    function dropdown:Close()
        dropdown.IsOpen = false
        self:Tween(dropdown.Container, {Size = UDim2.new(1, 0, 0, 45)})
        self:Tween(dropdown.Arrow, {Rotation = 0})
    end
    
    dropdown.Button.MouseButton1Click:Connect(function()
        if dropdown.IsOpen then
            dropdown:Close()
        else
            dropdown:Open()
        end
    end)
    
    return dropdown
end

-- Create TextBox
function AetherUI:CreateTextBox(tab, config)
    local textbox = {
        Name = config.Name or "TextBox",
        Placeholder = config.Placeholder or "",
        Default = config.Default or "",
        Callback = config.Callback or function() end
    }
    
    -- Container
    textbox.Container = Instance.new("Frame")
    textbox.Container.Size = UDim2.new(1, 0, 0, 45)
    textbox.Container.BackgroundColor3 = self.Colors.Surface
    textbox.Container.BorderSizePixel = 0
    textbox.Container.Parent = tab.Content
    
    self:AddCorner(textbox.Container, 6)
    
    -- Label
    textbox.Label = Instance.new("TextLabel")
    textbox.Label.Size = UDim2.new(0.35, 0, 1, 0)
    textbox.Label.Position = UDim2.new(0, 12, 0, 0)
    textbox.Label.BackgroundTransparency = 1
    textbox.Label.TextColor3 = self.Colors.Text
    textbox.Label.Text = textbox.Name
    textbox.Label.Font = Enum.Font.GothamMedium
    textbox.Label.TextSize = 12
    textbox.Label.TextXAlignment = Enum.TextXAlignment.Left
    textbox.Label.Parent = textbox.Container
    
    -- Input
    textbox.Input = Instance.new("TextBox")
    textbox.Input.Size = UDim2.new(0.6, -24, 0, 30)
    textbox.Input.Position = UDim2.new(0.38, 0, 0.5, -15)
    textbox.Input.BackgroundColor3 = self.Colors.Background
    textbox.Input.TextColor3 = self.Colors.Text
    textbox.Input.PlaceholderText = textbox.Placeholder
    textbox.Input.PlaceholderColor3 = self.Colors.TextSecondary
    textbox.Input.Text = textbox.Default
    textbox.Input.Font = Enum.Font.Gotham
    textbox.Input.TextSize = 12
    textbox.Input.Parent = textbox.Container
    
    self:AddCorner(textbox.Input, 4)
    
    textbox.Input.FocusLost:Connect(function()
        textbox.Callback(textbox.Input.Text)
    end)
    
    return textbox
end

-- Create Notification
function AetherUI:CreateNotification(title, message, duration, type)
    local notif = {
        Title = title or "Notification",
        Message = message or "",
        Duration = duration or 3,
        Type = type or "info" -- "info", "success", "warning", "error"
    }
    
    local colors = {
        info = self.Colors.Primary,
        success = self.Colors.Success,
        warning = self.Colors.Warning,
        error = self.Colors.Danger
    }
    
    local color = colors[notif.Type]
    
    -- Notification Frame
    notif.Frame = Instance.new("Frame")
    notif.Frame.Size = UDim2.new(0, 300, 0, 70)
    notif.Frame.Position = UDim2.new(1, -310, 1, -80 - (#self.Notifications * 75))
    notif.Frame.BackgroundColor3 = self.Colors.Secondary
    notif.Frame.BorderSizePixel = 0
    notif.Frame.Parent = self.ScreenGui
    
    self:AddCorner(notif.Frame, 8)
    
    -- Accent Bar
    notif.Accent = Instance.new("Frame")
    notif.Accent.Size = UDim2.new(0, 4, 1, 0)
    notif.Accent.BackgroundColor3 = color
    notif.Accent.BorderSizePixel = 0
    notif.Accent.Parent = notif.Frame
    
    self:AddCorner(notif.Accent, 2)
    
    -- Title
    notif.TitleLabel = Instance.new("TextLabel")
    notif.TitleLabel.Size = UDim2.new(1, -50, 0, 25)
    notif.TitleLabel.Position = UDim2.new(0, 12, 0, 8)
    notif.TitleLabel.BackgroundTransparency = 1
    notif.TitleLabel.TextColor3 = self.Colors.Text
    notif.TitleLabel.Text = notif.Title
    notif.TitleLabel.Font = Enum.Font.GothamBold
    notif.TitleLabel.TextSize = 14
    notif.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    notif.TitleLabel.Parent = notif.Frame
    
    -- Message
    notif.MessageLabel = Instance.new("TextLabel")
    notif.MessageLabel.Size = UDim2.new(1, -50, 0, 20)
    notif.MessageLabel.Position = UDim2.new(0, 12, 0, 35)
    notif.MessageLabel.BackgroundTransparency = 1
    notif.MessageLabel.TextColor3 = self.Colors.TextSecondary
    notif.MessageLabel.Text = notif.Message
    notif.MessageLabel.Font = Enum.Font.Gotham
    notif.MessageLabel.TextSize = 12
    notif.MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    notif.MessageLabel.Parent = notif.Frame
    
    -- Close Button
    notif.CloseBtn = Instance.new("TextButton")
    notif.CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    notif.CloseBtn.Position = UDim2.new(1, -25, 0, 5)
    notif.CloseBtn.BackgroundTransparency = 1
    notif.CloseBtn.TextColor3 = self.Colors.TextSecondary
    notif.CloseBtn.Text = "✕"
    notif.CloseBtn.Font = Enum.Font.GothamBold
    notif.CloseBtn.TextSize = 12
    notif.CloseBtn.Parent = notif.Frame
    
    -- Auto Remove
    local function removeNotif()
        self:Tween(notif.Frame, {
            Position = UDim2.new(1, 10, notif.Frame.Position.Y.Scale, notif.Frame.Position.Y.Offset),
            BackgroundTransparency = 1
        })
        task.wait(0.3)
        notif.Frame:Destroy()
        
        -- Update positions
        local index = table.find(self.Notifications, notif)
        if index then
            table.remove(self.Notifications, index)
        end
    end
    
    notif.CloseBtn.MouseButton1Click:Connect(removeNotif)
    
    task.delay(notif.Duration, removeNotif)
    
    table.insert(self.Notifications, notif)
    
    -- Animate in
    notif.Frame.Position = UDim2.new(1, 10, 1, -80 - (#self.Notifications * 75))
    self:Tween(notif.Frame, {
        Position = UDim2.new(1, -310, 1, -80 - (#self.Notifications * 75))
    })
    
    return notif
end

-- Set Theme
function AetherUI:SetTheme(themeName)
    self.Theme = themeName
    self.Colors = AetherUI.DefaultTheme[themeName]
    
    -- Update all elements
    self.MainFrame.BackgroundColor3 = self.Colors.Background
    self.TitleBar.BackgroundColor3 = self.Colors.Secondary
    self.TabContainer.BackgroundColor3 = self.Colors.Secondary
    
    -- You would need to recursively update all children
    -- For brevity, this is simplified
end

-- Destroy UI
function AetherUI:Destroy()
    self:Tween(self.MainFrame, {
        Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 0),
        Position = UDim2.new(self.Position.X.Scale, self.Position.X.Offset, 0.5, 0)
    })
    task.wait(0.3)
    self.ScreenGui:Destroy()
end

-- Return Library
return AetherUI
