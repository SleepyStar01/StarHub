-- StarHub UI Library
-- Theme: Dark Blue with Stars
-- By: SleepyStar01

local StarHub = {}

-- Colors for the theme
local ThemeColors = {
    Primary = Color3.fromRGB(25, 45, 80),
    Secondary = Color3.fromRGB(15, 30, 60),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(180, 180, 180),
    Outline = Color3.fromRGB(50, 90, 140),
    Hover = Color3.fromRGB(35, 65, 110)
}

-- Create rounded corners function
local function RoundedCorners(instance, cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius)
    corner.Parent = instance
    return corner
end

-- Create stroke function
local function ApplyStroke(instance, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness
    stroke.Color = color or ThemeColors.Outline
    stroke.Parent = instance
    return stroke
end

-- Create star decoration function
local function CreateStar(parent, position, size, transparency)
    local star = Instance.new("ImageLabel")
    star.Name = "StarDecoration"
    star.Image = "rbxassetid://10169230099" -- Simple star icon
    star.BackgroundTransparency = 1
    star.Size = UDim2.new(0, size, 0, size)
    star.Position = position
    star.ImageColor3 = ThemeColors.Accent
    star.ImageTransparency = transparency or 0.7
    star.ZIndex = 0
    star.Parent = parent
    return star
end

-- Main function to create the UI library
function StarHub:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "StarHub"
    local Icon = options.Icon or ""
    local Author = options.Author or "StarHub"
    local Folder = options.Folder or "StarHub"
    local Size = options.Size or UDim2.fromOffset(560, 400)
    local Transparent = options.Transparent or false
    local Theme = options.Theme or "Dark"
    local SideBarWidth = options.SideBarWidth or 170
    local HasOutline = options.HasOutline or true
    
    -- Create main screen GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = Folder
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Create main window frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.Size = Size
    MainFrame.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = ThemeColors.Primary
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Add outline if enabled
    if HasOutline then
        ApplyStroke(MainFrame, 2)
    end
    
    -- Add rounded corners
    RoundedCorners(MainFrame, 8)
    
    -- Add decorative stars
    CreateStar(MainFrame, UDim2.new(0, 10, 0, 10), 16, 0.8)
    CreateStar(MainFrame, UDim2.new(1, -25, 0, 15), 12, 0.6)
    CreateStar(MainFrame, UDim2.new(0, 20, 1, -30), 14, 0.9)
    CreateStar(MainFrame, UDim2.new(1, -15, 1, -20), 10, 0.7)
    
    -- Create title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = ThemeColors.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    -- Title text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "Title"
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 40, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = Title
    TitleText.TextColor3 = ThemeColors.Text
    TitleText.TextSize = 16
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Icon if provided
    if Icon ~= "" then
        local TitleIcon = Instance.new("ImageLabel")
        TitleIcon.Name = "Icon"
        TitleIcon.Size = UDim2.new(0, 24, 0, 24)
        TitleIcon.Position = UDim2.new(0, 8, 0.5, -12)
        TitleIcon.BackgroundTransparency = 1
        TitleIcon.Image = Icon
        TitleIcon.Parent = TitleBar
    end
    
    -- Close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "X"
    CloseButton.TextColor3 = ThemeColors.Text
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Create sidebar
    local SideBar = Instance.new("Frame")
    SideBar.Name = "SideBar"
    SideBar.Size = UDim2.new(0, SideBarWidth, 1, -40)
    SideBar.Position = UDim2.new(0, 0, 0, 40)
    SideBar.BackgroundColor3 = ThemeColors.Secondary
    SideBar.BorderSizePixel = 0
    SideBar.Parent = MainFrame
    
    -- Create tab container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -SideBarWidth, 1, -40)
    TabContainer.Position = UDim2.new(0, SideBarWidth, 0, 40)
    TabContainer.BackgroundColor3 = ThemeColors.Primary
    TabContainer.BorderSizePixel = 0
    TabContainer.ClipsDescendants = true
    TabContainer.Parent = MainFrame
    
    -- Create tab buttons container
    local TabButtons = Instance.new("ScrollingFrame")
    TabButtons.Name = "TabButtons"
    TabButtons.Size = UDim2.new(1, 0, 1, 0)
    TabButtons.BackgroundTransparency = 1
    TabButtons.ScrollingDirection = Enum.ScrollingDirection.Y
    TabButtons.ScrollBarThickness = 0
    TabButtons.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabButtons.Parent = SideBar
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = TabButtons
    
    -- Create author label
    local AuthorLabel = Instance.new("TextLabel")
    AuthorLabel.Name = "Author"
    AuthorLabel.Size = UDim2.new(1, -10, 0, 20)
    AuthorLabel.Position = UDim2.new(0, 5, 1, -25)
    AuthorLabel.BackgroundTransparency = 1
    AuthorLabel.Text = Author
    AuthorLabel.TextColor3 = ThemeColors.SubText
    AuthorLabel.TextSize = 12
    AuthorLabel.Font = Enum.Font.Gotham
    AuthorLabel.TextXAlignment = Enum.TextXAlignment.Left
    AuthorLabel.Parent = SideBar
    
    -- Tab management
    local Tabs = {}
    local CurrentTab = nil
    
    -- Function to create a new tab
    function self:Tab(options)
        options = options or {}
        local Title = options.Title or "Tab"
        local Icon = options.Icon or ""
        
        local Tab = {}
        local TabButton = Instance.new("TextButton")
        TabButton.Name = Title .. "TabButton"
        TabButton.Size = UDim2.new(1, -10, 0, 40)
        TabButton.Position = UDim2.new(0, 5, 0, #Tabs * 45)
        TabButton.BackgroundColor3 = ThemeColors.Primary
        TabButton.AutoButtonColor = false
        TabButton.Text = ""
        TabButton.LayoutOrder = #Tabs
        
        RoundedCorners(TabButton, 6)
        
        -- Tab icon if provided
        if Icon ~= "" then
            local TabIcon = Instance.new("ImageLabel")
            TabIcon.Name = "Icon"
            TabIcon.Size = UDim2.new(0, 24, 0, 24)
            TabIcon.Position = UDim2.new(0, 10, 0.5, -12)
            TabIcon.BackgroundTransparency = 1
            TabIcon.Image = Icon
            TabIcon.ImageColor3 = ThemeColors.Text
            TabIcon.Parent = TabButton
        end
        
        -- Tab text
        local TabText = Instance.new("TextLabel")
        TabText.Name = "Text"
        TabText.Size = UDim2.new(1, -40, 1, 0)
        TabText.Position = UDim2.new(0, 40, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Text = Title
        TabText.TextColor3 = ThemeColors.Text
        TabText.TextSize = 14
        TabText.Font = Enum.Font.Gotham
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = TabButton
        
        -- Tab content frame
        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Name = Title .. "Tab"
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.Position = UDim2.new(0, 0, 0, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.ScrollBarThickness = 5
        TabFrame.ScrollBarImageColor3 = ThemeColors.Accent
        TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabFrame.Parent = TabContainer
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, 10)
        TabLayout.Parent = TabFrame
        
        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingLeft = UDim.new(0, 15)
        TabPadding.PaddingTop = UDim.new(0, 15)
        TabPadding.PaddingRight = UDim.new(0, 15)
        TabPadding.Parent = TabFrame
        
        -- Tab selection function
        TabButton.MouseButton1Click:Connect(function()
            if CurrentTab then
                CurrentTab.Visible = false
            end
            TabFrame.Visible = true
            CurrentTab = TabFrame
            
            -- Update tab button appearance
            for _, btn in pairs(TabButtons:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = ThemeColors.Primary
                    btn:FindFirstChild("Text").TextColor3 = ThemeColors.Text
                    if btn:FindFirstChild("Icon") then
                        btn.Icon.ImageColor3 = ThemeColors.Text
                    end
                end
            end
            TabButton.BackgroundColor3 = ThemeColors.Accent
            TabText.TextColor3 = Color3.new(1, 1, 1)
            if TabButton:FindFirstChild("Icon") then
                TabButton.Icon.ImageColor3 = Color3.new(1, 1, 1)
            end
        end)
        
        TabButton.Parent = TabButtons
        
        -- Add button to tab
        function Tab:Button(options)
            options = options or {}
            local Text = options.Text or "Button"
            local Callback = options.Callback or function() end
            
            local Button = Instance.new("TextButton")
            Button.Name = Text
            Button.Size = UDim2.new(1, 0, 0, 40)
            Button.BackgroundColor3 = ThemeColors.Secondary
            Button.AutoButtonColor = false
            Button.Text = ""
            
            RoundedCorners(Button, 6)
            ApplyStroke(Button, 1)
            
            local ButtonText = Instance.new("TextLabel")
            ButtonText.Name = "Text"
            ButtonText.Size = UDim2.new(1, 0, 1, 0)
            ButtonText.BackgroundTransparency = 1
            ButtonText.Text = Text
            ButtonText.TextColor3 = ThemeColors.Text
            ButtonText.TextSize = 14
            ButtonText.Font = Enum.Font.Gotham
            ButtonText.Parent = Button
            
            -- Hover effects
            Button.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(
                    Button,
                    TweenInfo.new(0.2),
                    {BackgroundColor3 = ThemeColors.Hover}
                ):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(
                    Button,
                    TweenInfo.new(0.2),
                    {BackgroundColor3 = ThemeColors.Secondary}
                ):Play()
            end)
            
            Button.MouseButton1Click:Connect(function()
                Callback()
            end)
            
            Button.Parent = TabFrame
            return Button
        end
        
        -- Add toggle to tab
        function Tab:Toggle(options)
            options = options or {}
            local Text = options.Text or "Toggle"
            local Default = options.Default or false
            local Callback = options.Callback or function() end
            
            local Toggle = Instance.new("Frame")
            Toggle.Name = Text
            Toggle.Size = UDim2.new(1, 0, 0, 40)
            Toggle.BackgroundTransparency = 1
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Size = UDim2.new(1, 0, 1, 0)
            ToggleButton.BackgroundTransparency = 1
            ToggleButton.Text = ""
            ToggleButton.Parent = Toggle
            
            local ToggleBackground = Instance.new("Frame")
            ToggleBackground.Name = "Background"
            ToggleBackground.Size = UDim2.new(0, 50, 0, 24)
            ToggleBackground.Position = UDim2.new(1, -55, 0.5, -12)
            ToggleBackground.BackgroundColor3 = ThemeColors.Secondary
            ToggleBackground.Parent = Toggle
            
            RoundedCorners(ToggleBackground, 12)
            ApplyStroke(ToggleBackground, 1)
            
            local ToggleDot = Instance.new("Frame")
            ToggleDot.Name = "Dot"
            ToggleDot.Size = UDim2.new(0, 18, 0, 18)
            ToggleDot.Position = UDim2.new(0, 3, 0.5, -9)
            ToggleDot.BackgroundColor3 = ThemeColors.Text
            ToggleDot.Parent = ToggleBackground
            
            RoundedCorners(ToggleDot, 9)
            
            local ToggleText = Instance.new("TextLabel")
            ToggleText.Name = "Text"
            ToggleText.Size = UDim2.new(1, -60, 1, 0)
            ToggleText.BackgroundTransparency = 1
            ToggleText.Text = Text
            ToggleText.TextColor3 = ThemeColors.Text
            ToggleText.TextSize = 14
            ToggleText.Font = Enum.Font.Gotham
            ToggleText.TextXAlignment = Enum.TextXAlignment.Left
            ToggleText.Parent = Toggle
            
            local State = Default
            
            local function UpdateToggle()
                if State then
                    game:GetService("TweenService"):Create(
                        ToggleDot,
                        TweenInfo.new(0.2),
                        {Position = UDim2.new(0, 29, 0.5, -9), BackgroundColor3 = ThemeColors.Accent}
                    ):Play()
                    game:GetService("TweenService"):Create(
                        ToggleBackground,
                        TweenInfo.new(0.2),
                        {BackgroundColor3 = ThemeColors.Accent}
                    ):Play()
                else
                    game:GetService("TweenService"):Create(
                        ToggleDot,
                        TweenInfo.new(0.2),
                        {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = ThemeColors.Text}
                    ):Play()
                    game:GetService("TweenService"):Create(
                        ToggleBackground,
                        TweenInfo.new(0.2),
                        {BackgroundColor3 = ThemeColors.Secondary}
                    ):Play()
                end
                Callback(State)
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                State = not State
                UpdateToggle()
            end)
            
            UpdateToggle()
            
            Toggle.Parent = TabFrame
            return Toggle
        end
        
        -- Add slider to tab
        function Tab:Slider(options)
            options = options or {}
            local Text = options.Text or "Slider"
            local Min = options.Min or 0
            local Max = options.Max or 100
            local Default = options.Default or 50
            local Callback = options.Callback or function() end
            
            local Slider = Instance.new("Frame")
            Slider.Name = Text
            Slider.Size = UDim2.new(1, 0, 0, 60)
            Slider.BackgroundTransparency = 1
            
            local SliderText = Instance.new("TextLabel")
            SliderText.Name = "Text"
            SliderText.Size = UDim2.new(1, 0, 0, 20)
            SliderText.BackgroundTransparency = 1
            SliderText.Text = Text
            SliderText.TextColor3 = ThemeColors.Text
            SliderText.TextSize = 14
            SliderText.Font = Enum.Font.Gotham
            SliderText.TextXAlignment = Enum.TextXAlignment.Left
            SliderText.Parent = Slider
            
            local SliderValue = Instance.new("TextLabel")
            SliderValue.Name = "Value"
            SliderValue.Size = UDim2.new(0, 50, 0, 20)
            SliderValue.Position = UDim2.new(1, -50, 0, 0)
            SliderValue.BackgroundTransparency = 1
            SliderValue.Text = tostring(Default)
            SliderValue.TextColor3 = ThemeColors.SubText
            SliderValue.TextSize = 14
            SliderValue.Font = Enum.Font.Gotham
            SliderValue.TextXAlignment = Enum.TextXAlignment.Right
            SliderValue.Parent = Slider
            
            local SliderTrack = Instance.new("Frame")
            SliderTrack.Name = "Track"
            SliderTrack.Size = UDim2.new(1, 0, 0, 5)
            SliderTrack.Position = UDim2.new(0, 0, 0, 35)
            SliderTrack.BackgroundColor3 = ThemeColors.Secondary
            SliderTrack.Parent = Slider
            
            RoundedCorners(SliderTrack, 3)
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = ThemeColors.Accent
            SliderFill.Parent = SliderTrack
            
            RoundedCorners(SliderFill, 3)
            
            local SliderButton = Instance.new("TextButton")
            SliderButton.Name = "Button"
            SliderButton.Size = UDim2.new(0, 20, 0, 20)
            SliderButton.Position = UDim2.new((Default - Min) / (Max - Min), -10, 0, 25)
            SliderButton.BackgroundColor3 = ThemeColors.Text
            SliderButton.Text = ""
            SliderButton.Parent = Slider
            
            RoundedCorners(SliderButton, 10)
            
            local Dragging = false
            
            local function UpdateSlider(value)
                value = math.clamp(value, Min, Max)
                local percent = (value - Min) / (Max - Min)
                
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                SliderButton.Position = UDim2.new(percent, -10, 0, 25)
                SliderValue.Text = tostring(math.floor(value))
                
                Callback(value)
            end
            
            SliderButton.MouseButton1Down:Connect(function()
                Dragging = true
            end)
            
            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = SliderTrack.AbsolutePosition
                    local size = SliderTrack.AbsoluteSize
                    local percent = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                    local value = Min + (Max - Min) * percent
                    
                    UpdateSlider(value)
                end
            end)
            
            UpdateSlider(Default)
            
            Slider.Parent = TabFrame
            return Slider
        end
        
        -- Add label to tab
        function Tab:Label(options)
            options = options or {}
            local Text = options.Text or "Label"
            
            local Label = Instance.new("TextLabel")
            Label.Name = Text
            Label.Size = UDim2.new(1, 0, 0, 30)
            Label.BackgroundTransparency = 1
            Label.Text = Text
            Label.TextColor3 = ThemeColors.Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TabFrame
            
            return Label
        end
        
        -- Add separator to tab
        function Tab:Separator(options)
            options = options or {}
            local Text = options.Text or nil
            
            local Separator = Instance.new("Frame")
            Separator.Name = "Separator"
            Separator.Size = UDim2.new(1, 0, 0, 20)
            Separator.BackgroundTransparency = 1
            
            local Line = Instance.new("Frame")
            Line.Name = "Line"
            Line.Size = UDim2.new(1, 0, 0, 1)
            Line.Position = UDim2.new(0, 0, 0.5, 0)
            Line.BackgroundColor3 = ThemeColors.Outline
            Line.BorderSizePixel = 0
            Line.Parent = Separator
            
            if Text then
                Line.Size = UDim2.new(0.5, -30, 0, 1)
                Line.Position = UDim2.new(0, 0, 0.5, 0)
                
                local RightLine = Instance.new("Frame")
                RightLine.Name = "RightLine"
                RightLine.Size = UDim2.new(0.5, -30, 0, 1)
                RightLine.Position = UDim2.new(0.5, 30, 0.5, 0)
                RightLine.BackgroundColor3 = ThemeColors.Outline
                RightLine.BorderSizePixel = 0
                RightLine.Parent = Separator
                
                local TextLabel = Instance.new("TextLabel")
                TextLabel.Name = "Text"
                TextLabel.Size = UDim2.new(0, 60, 1, 0)
                TextLabel.Position = UDim2.new(0.5, -30, 0, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.Text = Text
                TextLabel.TextColor3 = ThemeColors.SubText
                TextLabel.TextSize = 12
                TextLabel.Font = Enum.Font.Gotham
                TextLabel.Parent = Separator
            end
            
            Separator.Parent = TabFrame
            return Separator
        end
        
        table.insert(Tabs, Tab)
        return Tab
    end
    
    -- Function to select a tab
    function self:SelectTab(index)
        if Tabs[index] then
            local tabButton = TabButtons:FindFirstChild(Tabs[index].Title .. "TabButton")
            if tabButton then
                tabButton:MouseButton1Click()
            end
        end
    end
    
    -- Function to set toggle key
    function self:SetToggleKey(key)
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.KeyCode == key then
                MainFrame.Visible = not MainFrame.Visible
            end
        end)
    end
    
    -- Function to edit open button
    function self:EditOpenButton(options)
        -- This would control the open/close button if implemented
    end
    
    -- Select first tab by default
    if #Tabs > 0 then
        self:SelectTab(1)
    end
    
    return self
end

return StarHub
