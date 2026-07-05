--[[
    ⭐ StarHub UI Library (Perfected Premium Edition)
    An ultra-modern, elegant, and perfectly balanced UI Framework for Roblox
    Version 7.0.0
]]

local SleepyUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Theme = {
    Background = Color3.fromRGB(15, 15, 20), -- Deep dark, similar to Wishub
    TopBar = Color3.fromRGB(15, 15, 20), 
    Sidebar = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(255, 160, 20), -- Star Gold
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(140, 140, 150),
    Element = Color3.fromRGB(22, 22, 28), -- Darker elements
    Border = Color3.fromRGB(30, 30, 40), -- Very subtle border
    Hover = Color3.fromRGB(35, 35, 45)
}

function SleepyUI:CreateWindow(config)
    local title = config.Title or config.Name or "discord.gg/starhub"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StarHubUI"
    local parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui
    if RunService:IsStudio() then parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    
    for _, v in pairs(parent:GetChildren()) do
        if v.Name == ScreenGui.Name then v:Destroy() end
    end
    ScreenGui.Parent = parent

    local Overlay = Instance.new("Frame")
    Overlay.Name = "DropdownOverlay"
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.ZIndex = 100
    Overlay.Visible = false
    Overlay.Parent = ScreenGui

    -- Minimize Icon
    local MinIcon = Instance.new("ImageButton")
    MinIcon.Size = UDim2.new(0, 48, 0, 48)
    MinIcon.Position = UDim2.new(0.5, -24, 0, 20)
    MinIcon.BackgroundColor3 = Theme.Accent
    MinIcon.Visible = false
    MinIcon.ZIndex = 150
    MinIcon.Parent = ScreenGui
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0.25, 0)
    MinCorner.Parent = MinIcon
    
    local MinStar = Instance.new("TextLabel")
    MinStar.Size = UDim2.new(1, 0, 1, 0)
    MinStar.BackgroundTransparency = 1
    MinStar.Text = "⭐"
    MinStar.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinStar.TextSize = 22
    MinStar.Font = Enum.Font.GothamBold
    MinStar.Parent = MinIcon
    
    local dragMin, dragMinInput, dragMinStart, startMinPos
    MinIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragMin = true
            dragMinStart = input.Position
            startMinPos = MinIcon.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragMin = false end
            end)
        end
    end)
    MinIcon.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragMinInput = input end
    end)

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 380) -- Perfect balanced size
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -190)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BackgroundTransparency = 0.02
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Parent = MainFrame

    -- TOP BAR
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundTransparency = 1
    TopBar.ZIndex = 10
    TopBar.Parent = MainFrame
    
    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(0, 30, 1, 0)
    Logo.Position = UDim2.new(0, 12, 0, 0)
    Logo.BackgroundTransparency = 1
    Logo.Text = "⭐"
    Logo.TextColor3 = Theme.Accent
    Logo.TextSize = 18
    Logo.Font = Enum.Font.GothamBold
    Logo.ZIndex = 10
    Logo.Parent = TopBar
    
    local TitlePill = Instance.new("Frame")
    TitlePill.Size = UDim2.new(0, 160, 0, 26)
    TitlePill.Position = UDim2.new(0, 46, 0.5, -13)
    TitlePill.BackgroundColor3 = Theme.Element
    TitlePill.ZIndex = 10
    TitlePill.Parent = TopBar
    local PillCorner = Instance.new("UICorner")
    PillCorner.CornerRadius = UDim.new(1, 0)
    PillCorner.Parent = TitlePill
    local PillStroke = Instance.new("UIStroke")
    PillStroke.Color = Theme.Border
    PillStroke.Thickness = 1
    PillStroke.Parent = TitlePill
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 11
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.ZIndex = 10
    TitleLabel.Parent = TitlePill
    
    -- Window Controls
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Theme.TextDim
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.ZIndex = 10
    CloseBtn.Parent = TopBar
    CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play() end)
    CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play() end)
    
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 1, 0)
    MinBtn.Position = UDim2.new(1, -60, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Theme.TextDim
    MinBtn.TextSize = 14
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.ZIndex = 10
    MinBtn.Parent = TopBar
    MinBtn.MouseEnter:Connect(function() TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play() end)
    MinBtn.MouseLeave:Connect(function() TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play() end)
    
    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        Overlay.Visible = false
        MinIcon.Visible = true
    end)
    
    MinIcon.MouseButton1Click:Connect(function()
        if not dragMin then
            MainFrame.Visible = true
            MinIcon.Visible = false
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        if input == dragMinInput and dragMin then
            local delta = input.Position - dragMinStart
            MinIcon.Position = UDim2.new(startMinPos.X.Scale, startMinPos.X.Offset + delta.X, startMinPos.Y.Scale, startMinPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, -42)
    Sidebar.Position = UDim2.new(0, 0, 0, 42)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, -20, 1, -20)
    TabContainer.Position = UDim2.new(0, 10, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 4)
    TabList.Parent = TabContainer

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -150, 1, -42)
    ContentArea.Position = UDim2.new(0, 150, 0, 42)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local TopContentBar = Instance.new("Frame")
    TopContentBar.Size = UDim2.new(1, 0, 0, 38)
    TopContentBar.BackgroundTransparency = 1
    TopContentBar.Parent = ContentArea

    local ContentTitle = Instance.new("TextLabel")
    ContentTitle.Size = UDim2.new(1, -16, 1, 0)
    ContentTitle.Position = UDim2.new(0, 16, 0, 0)
    ContentTitle.BackgroundTransparency = 1
    ContentTitle.Text = "Home"
    ContentTitle.TextColor3 = Theme.Text
    ContentTitle.TextSize = 20
    ContentTitle.Font = Enum.Font.GothamBold
    ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
    ContentTitle.Parent = TopContentBar

    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1, 0, 1, -38)
    Pages.Position = UDim2.new(0, 0, 0, 38)
    Pages.BackgroundTransparency = 1
    Pages.Parent = ContentArea

    local function ShowPage(page, titleText)
        for _, p in pairs(Pages:GetChildren()) do
            if p:IsA("ScrollingFrame") then p.Visible = false end
        end
        page.Visible = true
        ContentTitle.Text = titleText
    end

    local WindowAPI = {}
    local activeTab = nil
    
    function WindowAPI:Tab(tabConfig)
        local tabTitle = tabConfig.Title or "Tab"
        local tabIcon = tabConfig.Icon or "◈"

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Theme.Accent
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabContainer
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabBtn

        local IconLabel = Instance.new("TextLabel")
        IconLabel.Size = UDim2.new(0, 30, 1, 0)
        IconLabel.Position = UDim2.new(0, 8, 0, 0)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = tabIcon
        IconLabel.TextColor3 = Theme.TextDim
        IconLabel.TextSize = 14
        IconLabel.Font = Enum.Font.Gotham
        IconLabel.Parent = TabBtn

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Size = UDim2.new(1, -38, 1, 0)
        TextLabel.Position = UDim2.new(0, 38, 0, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = tabTitle
        TextLabel.TextColor3 = Theme.TextDim
        TextLabel.TextSize = 12
        TextLabel.Font = Enum.Font.Gotham
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -20, 1, -10)
        Page.Position = UDim2.new(0, 10, 0, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Visible = false
        Page.Parent = Pages

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = Page
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if activeTab then
                TweenService:Create(activeTab.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                activeTab.Icon.TextColor3 = Theme.TextDim
                activeTab.Text.TextColor3 = Theme.TextDim
                activeTab.Text.Font = Enum.Font.Gotham
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85}):Play()
            IconLabel.TextColor3 = Theme.Accent
            TextLabel.TextColor3 = Theme.Text
            TextLabel.Font = Enum.Font.GothamBold
            activeTab = {Btn = TabBtn, Icon = IconLabel, Text = TextLabel}
            ShowPage(Page, tabTitle)
        end)

        if not activeTab then
            TabBtn.BackgroundTransparency = 0.85
            IconLabel.TextColor3 = Theme.Accent
            TextLabel.TextColor3 = Theme.Text
            TextLabel.Font = Enum.Font.GothamBold
            activeTab = {Btn = TabBtn, Icon = IconLabel, Text = TextLabel}
            Page.Visible = true
            ContentTitle.Text = tabTitle
        end

        local TabAPI = {}
        
        function TabAPI:Section(secConfig)
            local secTitle = secConfig.Title or "Section"
            local isDefault = secConfig.Default

            local AccFrame = Instance.new("Frame")
            AccFrame.Size = UDim2.new(1, 0, 0, 38)
            AccFrame.BackgroundColor3 = Theme.Background
            AccFrame.BackgroundTransparency = 1
            AccFrame.ClipsDescendants = true
            AccFrame.Parent = Page
            
            local AccBtn = Instance.new("TextButton")
            AccBtn.Size = UDim2.new(1, 0, 0, 38)
            AccBtn.BackgroundColor3 = Theme.Element
            AccBtn.BackgroundTransparency = 1 -- Wishub sections are just text with no bg, wait, Wishub sections HAVE a dark bg. Let's make it transparent to be clean, or use element.
            AccBtn.Text = ""
            AccBtn.Parent = AccFrame
            
            local AccDivider = Instance.new("Frame")
            AccDivider.Size = UDim2.new(1, 0, 0, 1)
            AccDivider.Position = UDim2.new(0, 0, 1, -1)
            AccDivider.BackgroundColor3 = Theme.Border
            AccDivider.BorderSizePixel = 0
            AccDivider.Parent = AccBtn

            local AccTitle = Instance.new("TextLabel")
            AccTitle.Size = UDim2.new(1, -40, 1, 0)
            AccTitle.Position = UDim2.new(0, 10, 0, 0)
            AccTitle.BackgroundTransparency = 1
            AccTitle.Text = secTitle
            AccTitle.TextColor3 = Theme.Text
            AccTitle.TextSize = 13
            AccTitle.Font = Enum.Font.GothamBold
            AccTitle.TextXAlignment = Enum.TextXAlignment.Left
            AccTitle.Parent = AccBtn

            local AccArrow = Instance.new("TextLabel")
            AccArrow.Size = UDim2.new(0, 30, 1, 0)
            AccArrow.Position = UDim2.new(1, -30, 0, 0)
            AccArrow.BackgroundTransparency = 1
            AccArrow.Text = "v"
            AccArrow.TextColor3 = Theme.TextDim
            AccArrow.TextSize = 12
            AccArrow.Font = Enum.Font.GothamBold
            AccArrow.Parent = AccBtn

            local ContentFrame = Instance.new("Frame")
            ContentFrame.Size = UDim2.new(1, 0, 0, 0)
            ContentFrame.Position = UDim2.new(0, 0, 0, 38)
            ContentFrame.BackgroundTransparency = 1
            ContentFrame.Parent = AccFrame

            local CLayout = Instance.new("UIListLayout")
            CLayout.SortOrder = Enum.SortOrder.LayoutOrder
            CLayout.Padding = UDim.new(0, 2) -- Tighter padding for elements
            CLayout.Parent = ContentFrame
            
            local isOpen = false

            local function updateSize()
                if isOpen then
                    AccFrame.Size = UDim2.new(1, 0, 0, 38 + CLayout.AbsoluteContentSize.Y + 8)
                else
                    AccFrame.Size = UDim2.new(1, 0, 0, 38)
                end
                ContentFrame.Size = UDim2.new(1, 0, 0, CLayout.AbsoluteContentSize.Y)
            end

            CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

            AccBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                AccArrow.Text = isOpen and "^" or "v"
                TweenService:Create(AccFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = isOpen and UDim2.new(1, 0, 0, 38 + CLayout.AbsoluteContentSize.Y + 8) or UDim2.new(1, 0, 0, 38)
                }):Play()
            end)
            
            if isDefault then
                isOpen = true
                AccArrow.Text = "^"
                AccFrame.Size = UDim2.new(1, 0, 0, 38 + CLayout.AbsoluteContentSize.Y + 8)
            end

            return { ContentFrame = ContentFrame, AccFrame = AccFrame, Clear = function()
                for _, v in pairs(ContentFrame:GetChildren()) do
                    if not v:IsA("UIListLayout") then v:Destroy() end
                end
            end}
        end

        local function CreateElementFrame(config)
            local targetParent = config.Section and config.Section.ContentFrame or Page
            local EFrame = Instance.new("Frame")
            EFrame.Size = UDim2.new(1, 0, 0, config.Desc and 48 or 40)
            EFrame.BackgroundColor3 = Theme.Background
            EFrame.BackgroundTransparency = 1 -- Transparent so elements blend with page
            EFrame.Parent = targetParent
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -160, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, config.Desc and 6 or 10)
            Label.BackgroundTransparency = 1
            Label.Text = config.Title or "Element"
            Label.TextColor3 = Theme.Text
            Label.TextSize = 13
            Label.Font = Enum.Font.GothamBold
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = EFrame
            
            if config.Desc then
                local Desc = Instance.new("TextLabel")
                Desc.Size = UDim2.new(1, -160, 0, 14)
                Desc.Position = UDim2.new(0, 10, 0, 26)
                Desc.BackgroundTransparency = 1
                Desc.Text = config.Desc
                Desc.TextColor3 = Theme.TextDim
                Desc.TextSize = 10
                Desc.Font = Enum.Font.Gotham
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.Parent = EFrame
            end
            
            return EFrame
        end

        function TabAPI:Toggle(config)
            local EFrame = CreateElementFrame(config)
            local state = config.Default or false
            
            local TogBtn = Instance.new("TextButton")
            TogBtn.Size = UDim2.new(0, 42, 0, 22)
            TogBtn.Position = UDim2.new(1, -52, 0.5, -11)
            TogBtn.BackgroundColor3 = state and Theme.Accent or Theme.Element
            TogBtn.Text = ""
            TogBtn.Parent = EFrame
            local TogCorner = Instance.new("UICorner")
            TogCorner.CornerRadius = UDim.new(1, 0)
            TogCorner.Parent = TogBtn
            local TogStroke = Instance.new("UIStroke")
            TogStroke.Color = Theme.Border
            TogStroke.Thickness = 1
            TogStroke.Parent = TogBtn
            
            local TogCircle = Instance.new("Frame")
            TogCircle.Size = UDim2.new(0, 16, 0, 16)
            TogCircle.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            TogCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TogCircle.Parent = TogBtn
            local CircCorner = Instance.new("UICorner")
            CircCorner.CornerRadius = UDim.new(1, 0)
            CircCorner.Parent = TogCircle
            
            TogBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(TogBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Theme.Element}):Play()
                TweenService:Create(TogCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
                if config.Callback then pcall(config.Callback, state) end
            end)
        end
        
        function TabAPI:Button(config)
            local EFrame = CreateElementFrame(config)
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0, 120, 0, 26)
            Btn.Position = UDim2.new(1, -130, 0.5, -13)
            Btn.BackgroundColor3 = Theme.Element
            Btn.Text = "Execute"
            Btn.TextColor3 = Theme.Text
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 12
            Btn.Parent = EFrame
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = Btn
            local UIStroke = Instance.new("UIStroke")
            UIStroke.Color = Theme.Border
            UIStroke.Thickness = 1
            UIStroke.Parent = Btn
            
            Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover}):Play() end)
            Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play() end)
            
            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 114, 0, 24), Position = UDim2.new(1, -127, 0.5, -12)}):Play()
                task.wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 120, 0, 26), Position = UDim2.new(1, -130, 0.5, -13)}):Play()
                if config.Callback then pcall(config.Callback) end
            end)
        end
        
        function TabAPI:Cycle(config)
            local EFrame = CreateElementFrame(config)
            local selected = config.Default or (config.Values and config.Values[1]) or ""
            
            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(0, 150, 0, 26)
            DropBtn.Position = UDim2.new(1, -160, 0.5, -13)
            DropBtn.BackgroundColor3 = Theme.Element
            DropBtn.Text = selected
            DropBtn.TextColor3 = Theme.TextDim
            DropBtn.TextSize = 11
            DropBtn.Font = Enum.Font.Gotham
            DropBtn.Parent = EFrame
            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 4)
            DropCorner.Parent = DropBtn
            local UIStroke = Instance.new("UIStroke")
            UIStroke.Color = Theme.Border
            UIStroke.Thickness = 1
            UIStroke.Parent = DropBtn
            
            DropBtn.MouseButton1Click:Connect(function()
                if not config.Values or #config.Values == 0 then return end
                local nextIdx = 1
                for i, v in ipairs(config.Values) do if v == selected then nextIdx = i + 1 break end end
                if nextIdx > #config.Values then nextIdx = 1 end
                selected = config.Values[nextIdx]
                DropBtn.Text = selected
                if config.Callback then pcall(config.Callback, selected) end
            end)
        end
        
        function TabAPI:Dropdown(config)
            local EFrame = CreateElementFrame(config)
            local selected = config.Default or (config.Values and config.Values[1]) or ""
            local isOpen = false
            
            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(0, 150, 0, 26)
            DropBtn.Position = UDim2.new(1, -160, 0.5, -13)
            DropBtn.BackgroundColor3 = Theme.Element
            DropBtn.Text = selected
            DropBtn.TextColor3 = Theme.TextDim
            DropBtn.TextSize = 11
            DropBtn.Font = Enum.Font.Gotham
            DropBtn.Parent = EFrame
            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 4)
            DropCorner.Parent = DropBtn
            local UIStroke = Instance.new("UIStroke")
            UIStroke.Color = Theme.Border
            UIStroke.Thickness = 1
            UIStroke.Parent = DropBtn
            
            local DropIcon = Instance.new("TextLabel")
            DropIcon.Size = UDim2.new(0, 24, 1, 0)
            DropIcon.Position = UDim2.new(1, -24, 0, 0)
            DropIcon.BackgroundTransparency = 1
            DropIcon.Text = "v"
            DropIcon.TextColor3 = Theme.TextDim
            DropIcon.TextSize = 11
            DropIcon.Font = Enum.Font.GothamBold
            DropIcon.Parent = DropBtn

            -- Floating List
            local OptionList = Instance.new("ScrollingFrame")
            OptionList.BackgroundColor3 = Theme.Element
            OptionList.BorderSizePixel = 0
            OptionList.ScrollBarThickness = 2
            OptionList.ScrollBarImageColor3 = Theme.Accent
            OptionList.Visible = false
            OptionList.ZIndex = 101
            OptionList.Parent = Overlay

            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 4)
            ListCorner.Parent = OptionList
            
            local ListStroke = Instance.new("UIStroke")
            ListStroke.Color = Theme.Border
            ListStroke.Thickness = 1
            ListStroke.Parent = OptionList
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = OptionList
            
            local function RefreshOptions(newValues)
                for _, child in pairs(OptionList:GetChildren()) do
                    if not child:IsA("UIListLayout") then child:Destroy() end
                end
                
                config.Values = newValues or config.Values
                if not config.Values then config.Values = {} end
                
                local totalHeight = 0
                for _, val in ipairs(config.Values) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 26)
                    OptBtn.BackgroundColor3 = Theme.Hover
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = "  " .. val
                    OptBtn.TextColor3 = val == selected and Theme.Accent or Theme.TextDim
                    OptBtn.TextSize = 11
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.ZIndex = 102
                    OptBtn.Parent = OptionList
                    
                    totalHeight = totalHeight + 26
                    
                    OptBtn.MouseEnter:Connect(function() TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play() end)
                    OptBtn.MouseLeave:Connect(function() TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        selected = val
                        DropBtn.Text = selected
                        isOpen = false
                        DropIcon.Text = "v"
                        Overlay.Visible = false
                        OptionList.Visible = false
                        for _, ob in pairs(OptionList:GetChildren()) do
                            if ob:IsA("TextButton") then
                                ob.TextColor3 = ob.Text:sub(3) == selected and Theme.Accent or Theme.TextDim
                            end
                        end
                        if config.Callback then pcall(config.Callback, selected) end
                    end)
                end
                OptionList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
                OptionList.Size = UDim2.new(0, 150, 0, math.min(totalHeight, 156))
            end
            
            DropBtn.MouseButton1Click:Connect(function()
                if not config.Values or #config.Values == 0 then return end
                isOpen = not isOpen
                DropIcon.Text = isOpen and "^" or "v"
                
                if isOpen then
                    Overlay.Visible = true
                    OptionList.Visible = true
                    local absPos = DropBtn.AbsolutePosition
                    OptionList.Position = UDim2.new(0, absPos.X, 0, absPos.Y + 30)
                else
                    Overlay.Visible = false
                    OptionList.Visible = false
                end
            end)
            
            Overlay.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isOpen = false
                    DropIcon.Text = "v"
                    Overlay.Visible = false
                    OptionList.Visible = false
                end
            end)
            
            RefreshOptions()
            
            return {
                Refresh = function(newValues)
                    selected = (newValues and newValues[1]) or "None"
                    DropBtn.Text = selected
                    RefreshOptions(newValues)
                    if config.Callback then pcall(config.Callback, selected) end
                end
            }
        end

        function TabAPI:Slider(config)
            local EFrame = CreateElementFrame(config)
            local min = config.Min or 0
            local max = config.Max or 100
            local val = config.Default or min
            
            local SliderBg = Instance.new("Frame")
            SliderBg.Size = UDim2.new(0, 150, 0, 6)
            SliderBg.Position = UDim2.new(1, -160, 0.5, -3)
            SliderBg.BackgroundColor3 = Theme.Element
            SliderBg.Parent = EFrame
            local BgCorner = Instance.new("UICorner")
            BgCorner.CornerRadius = UDim.new(1, 0)
            BgCorner.Parent = SliderBg
            local BgStroke = Instance.new("UIStroke")
            BgStroke.Color = Theme.Border
            BgStroke.Thickness = 1
            BgStroke.Parent = SliderBg
            
            local SliderFill = Instance.new("Frame")
            local pct = (val - min) / (max - min)
            SliderFill.Size = UDim2.new(pct, 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Accent
            SliderFill.Parent = SliderBg
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = SliderFill
            
            local Thumb = Instance.new("Frame")
            Thumb.Size = UDim2.new(0, 12, 0, 12)
            Thumb.Position = UDim2.new(pct, -6, 0.5, -6)
            Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Thumb.Parent = SliderBg
            local ThumbCorner = Instance.new("UICorner")
            ThumbCorner.CornerRadius = UDim.new(1, 0)
            ThumbCorner.Parent = Thumb
            
            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0, 30, 0, 20)
            ValLabel.Position = UDim2.new(1, -200, 0.5, -10)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(val)
            ValLabel.TextColor3 = Theme.TextDim
            ValLabel.TextSize = 11
            ValLabel.Font = Enum.Font.Gotham
            ValLabel.Parent = EFrame
            
            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 1, 10)
            clickBtn.Position = UDim2.new(0, 0, 0.5, -5)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""
            clickBtn.Parent = SliderBg
            
            local dragging = false
            clickBtn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local mx = inp.Position.X
                    local sx = SliderBg.AbsolutePosition.X
                    local sw = SliderBg.AbsoluteSize.X
                    local p = math.clamp((mx - sx) / sw, 0, 1)
                    SliderFill.Size = UDim2.new(p, 0, 1, 0)
                    Thumb.Position = UDim2.new(p, -6, 0.5, -6)
                    local current = min + p * (max - min)
                    current = math.floor(current * 10) / 10
                    ValLabel.Text = tostring(current)
                    if config.Callback then pcall(config.Callback, current) end
                end
            end)
        end
        
        return TabAPI
    end
    
    function WindowAPI:Notify(title, text, duration)
        -- Notification placeholder
    end
    
    return WindowAPI
end

return SleepyUI
