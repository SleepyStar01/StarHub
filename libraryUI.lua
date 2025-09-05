-- StarHub UI Library
-- Clone of Nathub UI with StarHub branding
-- By: SleepyStar01

local StarHub = {}
StarHub.__index = StarHub

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Theme Colors (Nathub-like colors)
local ThemeColors = {
    Background = Color3.fromRGB(30, 30, 40),
    TopBar = Color3.fromRGB(25, 25, 35),
    TabBar = Color3.fromRGB(35, 35, 45),
    Element = Color3.fromRGB(40, 40, 50),
    ElementHover = Color3.fromRGB(50, 50, 60),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(180, 180, 180),
    Outline = Color3.fromRGB(60, 60, 70)
}

-- Utility functions
local function Create(class, properties)
    local instance = Instance.new(class)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function RoundedCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

local function ApplyStroke(instance, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness
    stroke.Color = color or ThemeColors.Outline
    stroke.Parent = instance
    return stroke
end

-- Main Window Creation
function StarHub:CreateWindow(options)
    options = options or {}
    local self = setmetatable({}, StarHub)
    
    self.Title = options.Title or "StarHub"
    self.Icon = options.Icon or ""
    self.Author = options.Author or "StarHub"
    self.Folder = options.Folder or "StarHub"
    self.Size = options.Size or UDim2.fromOffset(550, 350)
    self.Transparent = options.Transparent or false
    self.Theme = options.Theme or "Dark"
    self.SideBarWidth = options.SideBarWidth or 160
    self.HasOutline = options.HasOutline or true
    
    -- Create ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = self.Folder,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game:GetService("CoreGui")
    })
    
    -- Main Window Frame
    self.MainFrame = Create("Frame", {
        Name = "MainWindow",
        Size = self.Size,
        Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = ThemeColors.Background,
        ClipsDescendants = true,
        Parent = self.ScreenGui
    })
    
    RoundedCorners(self.MainFrame, 8)
    if self.HasOutline then
        ApplyStroke(self.MainFrame, 2)
    end
    
    -- Top Bar
    self.TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = ThemeColors.TopBar,
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    -- Title
    self.TitleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = ThemeColors.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TopBar
    })
    
    -- Icon
    if self.Icon ~= "" then
        self.IconImage = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 10, 0.5, -12),
            BackgroundTransparency = 1,
            Image = self.Icon,
            Parent = self.TopBar
        })
    end
    
    -- Close Button
    self.CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = "X",
        TextColor3 = ThemeColors.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = self.TopBar
    })
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)
    
    -- Side Bar (Tabs)
    self.SideBar = Create("Frame", {
        Name = "SideBar",
        Size = UDim2.new(0, self.SideBarWidth, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = ThemeColors.TabBar,
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    -- Tab Buttons Container
    self.TabButtons = Create("ScrollingFrame", {
        Name = "TabButtons",
        Size = UDim2.new(1, 0, 1, -30),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.SideBar
    })
    
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = self.TabButtons
    })
    
    -- Author Label
    self.AuthorLabel = Create("TextLabel", {
        Name = "Author",
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 1, -25),
        BackgroundTransparency = 1,
        Text = self.Author,
        TextColor3 = ThemeColors.SubText,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.SideBar
    })
    
    -- Content Area
    self.ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -self.SideBarWidth, 1, -40),
        Position = UDim2.new(0, self.SideBarWidth, 0, 40),
        BackgroundColor3 = ThemeColors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.MainFrame
    })
    
    -- Tabs management
    self.Tabs = {}
    self.CurrentTab = nil
    
    return self
end

-- Tab Creation
function StarHub:Tab(options)
    options = options or {}
    local title = options.Title or "Tab"
    local icon = options.Icon or ""
    
    local tab = {}
    
    -- Tab Button
    local tabButton = Create("TextButton", {
        Name = title .. "TabButton",
        Size = UDim2.new(1, -10, 0, 40),
        BackgroundColor3 = ThemeColors.Element,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = #self.Tabs,
        Parent = self.TabButtons
    })
    
    RoundedCorners(tabButton, 6)
    
    -- Tab Icon
    if icon ~= "" then
        local tabIcon = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 10, 0.5, -12),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = ThemeColors.Text,
            Parent = tabButton
        })
    end
    
    -- Tab Text
    local tabText = Create("TextLabel", {
        Name = "Text",
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = ThemeColors.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabButton
    })
    
    -- Tab Content
    local tabContent = Create("ScrollingFrame", {
        Name = title .. "Content",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = ThemeColors.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.ContentArea
    })
    
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = tabContent
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 15),
        PaddingTop = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        Parent = tabContent
    })
    
    -- Tab Selection
    tabButton.MouseButton1Click:Connect(function()
        if self.CurrentTab then
            self.CurrentTab.Visible = false
        end
        tabContent.Visible = true
        self.CurrentTab = tabContent
        
        -- Update tab buttons
        for _, btn in pairs(self.TabButtons:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = ThemeColors.Element
                btn:FindFirstChild("Text").TextColor3 = ThemeColors.Text
                if btn:FindFirstChild("Icon") then
                    btn.Icon.ImageColor3 = ThemeColors.Text
                end
            end
        end
        
        tabButton.BackgroundColor3 = ThemeColors.Accent
        tabText.TextColor3 = Color3.new(1, 1, 1)
        if tabButton:FindFirstChild("Icon") then
            tabButton.Icon.ImageColor3 = Color3.new(1, 1, 1)
        end
    end)
    
    -- Button Element
    function tab:Button(options)
        options = options or {}
        local text = options.Text or "Button"
        local callback = options.Callback or function() end
        
        local button = Create("TextButton", {
            Name = text,
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = ThemeColors.Element,
            AutoButtonColor = false,
            Text = "",
            Parent = tabContent
        })
        
        RoundedCorners(button, 6)
        ApplyStroke(button, 1)
        
        local buttonText = Create("TextLabel", {
            Name = "Text",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = ThemeColors.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Parent = button
        })
        
        -- Hover effects
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = ThemeColors.ElementHover}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = ThemeColors.Element}):Play()
        end)
        
        button.MouseButton1Click:Connect(function()
            callback()
        end)
        
        return button
    end
    
    -- Toggle Element
    function tab:Toggle(options)
        options = options or {}
        local text = options.Text or "Toggle"
        local default = options.Default or false
        local callback = options.Callback or function() end
        
        local toggle = Create("Frame", {
            Name = text,
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Parent = tabContent
        })
        
        local toggleButton = Create("TextButton", {
            Name = "ToggleButton",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = toggle
        })
        
        local toggleBackground = Create("Frame", {
            Name = "Background",
            Size = UDim2.new(0, 50, 0, 24),
            Position = UDim2.new(1, -55, 0.5, -12),
            BackgroundColor3 = ThemeColors.Element,
            Parent = toggle
        })
        
        RoundedCorners(toggleBackground, 12)
        ApplyStroke(toggleBackground, 1)
        
        local toggleDot = Create("Frame", {
            Name = "Dot",
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 3, 0.5, -9),
            BackgroundColor3 = ThemeColors.Text,
            Parent = toggleBackground
        })
        
        RoundedCorners(toggleDot, 9)
        
        local toggleText = Create("TextLabel", {
            Name = "Text",
            Size = UDim2.new(1, -60, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = ThemeColors.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = toggle
        })
        
        local state = default
        
        local function updateToggle()
            if state then
                TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                    Position = UDim2.new(0, 29, 0.5, -9),
                    BackgroundColor3 = ThemeColors.Accent
                }):Play()
                TweenService:Create(toggleBackground, TweenInfo.new(0.2), {
                    BackgroundColor3 = ThemeColors.Accent
                }):Play()
            else
                TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                    Position = UDim2.new(0, 3, 0.5, -9),
                    BackgroundColor3 = ThemeColors.Text
                }):Play()
                TweenService:Create(toggleBackground, TweenInfo.new(0.2), {
                    BackgroundColor3 = ThemeColors.Element
                }):Play()
            end
            callback(state)
        end
        
        toggleButton.MouseButton1Click:Connect(function()
            state = not state
            updateToggle()
        end)
        
        updateToggle()
        
        return toggle
    end
    
    -- Slider Element
    function tab:Slider(options)
        options = options or {}
        local text = options.Text or "Slider"
        local min = options.Min or 0
        local max = options.Max or 100
        local default = options.Default or 50
        local callback = options.Callback or function() end
        
        local slider = Create("Frame", {
            Name = text,
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundTransparency = 1,
            Parent = tabContent
        })
        
        local sliderText = Create("TextLabel", {
            Name = "Text",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = ThemeColors.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = slider
        })
        
        local sliderValue = Create("TextLabel", {
            Name = "Value",
            Size = UDim2.new(0, 50, 0, 20),
            Position = UDim2.new(1, -50, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(default),
            TextColor3 = ThemeColors.SubText,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = slider
        })
        
        local sliderTrack = Create("Frame", {
            Name = "Track",
            Size = UDim2.new(1, 0, 0, 5),
            Position = UDim2.new(0, 0, 0, 35),
            BackgroundColor3 = ThemeColors.Element,
            Parent = slider
        })
        
        RoundedCorners(sliderTrack, 3)
        
        local sliderFill = Create("Frame", {
            Name = "Fill",
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = ThemeColors.Accent,
            Parent = sliderTrack
        })
        
        RoundedCorners(sliderFill, 3)
        
        local sliderButton = Create("TextButton", {
            Name = "Button",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new((default - min) / (max - min), -10, 0, 25),
            BackgroundColor3 = ThemeColors.Text,
            Text = "",
            Parent = slider
        })
        
        RoundedCorners(sliderButton, 10)
        
        local dragging = false
        
        local function updateSlider(value)
            value = math.clamp(value, min, max)
            local percent = (value - min) / (max - min)
            
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderButton.Position = UDim2.new(percent, -10, 0, 25)
            sliderValue.Text = tostring(math.floor(value))
            
            callback(value)
        end
        
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = sliderTrack.AbsolutePosition
                local size = sliderTrack.AbsoluteSize
                local percent = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                local value = min + (max - min) * percent
                
                updateSlider(value)
            end
        end)
        
        updateSlider(default)
        
        return slider
    end
    
    -- Label Element
    function tab:Label(options)
        options = options or {}
        local text = options.Text or "Label"
        
        local label = Create("TextLabel", {
            Name = text,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = ThemeColors.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabContent
        })
        
        return label
    end
    
    -- Separator Element
    function tab:Separator(options)
        options = options or {}
        local text = options.Text or nil
        
        local separator = Create("Frame", {
            Name = "Separator",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Parent = tabContent
        })
        
        local line = Create("Frame", {
            Name = "Line",
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = ThemeColors.Outline,
            BorderSizePixel = 0,
            Parent = separator
        })
        
        if text then
            line.Size = UDim2.new(0.5, -30, 0, 1)
            
            local rightLine = Create("Frame", {
                Name = "RightLine",
                Size = UDim2.new(0.5, -30, 0, 1),
                Position = UDim2.new(0.5, 30, 0.5, 0),
                BackgroundColor3 = ThemeColors.Outline,
                BorderSizePixel = 0,
                Parent = separator
            })
            
            local textLabel = Create("TextLabel", {
                Name = "Text",
                Size = UDim2.new(0, 60, 1, 0),
                Position = UDim2.new(0.5, -30, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = ThemeColors.SubText,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                Parent = separator
            })
        end
        
        return separator
    end
    
    table.insert(self.Tabs, tab)
    return tab
end

-- Select Tab
function StarHub:SelectTab(index)
    if self.Tabs[index] then
        local tabButton = self.TabButtons:FindFirstChild(self.Tabs[index].Title .. "TabButton")
        if tabButton then
            tabButton:MouseButton1Click()
        end
    end
end

-- Set Toggle Key
function StarHub:SetToggleKey(key)
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == key then
            self.MainFrame.Visible = not self.MainFrame.Visible
        end
    end)
end

-- Edit Open Button (placeholder)
function StarHub:EditOpenButton(options)
    -- Implementation for open button if needed
end

return StarHub
