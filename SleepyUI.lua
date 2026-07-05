--[[
    ⭐ StarHub UI Library (Exclusive Premium Edition)
    An ultra-modern, elegant, and unique UI Framework for Roblox
    Version 6.0.0
]]

local SleepyUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Theme = {
    Background = Color3.fromRGB(13, 15, 22), -- Deep cosmic blue/black
    Sidebar = Color3.fromRGB(18, 20, 28),
    TopBar = Color3.fromRGB(18, 20, 28),
    Accent = Color3.fromRGB(255, 170, 0), -- Star Gold
    AccentHover = Color3.fromRGB(255, 200, 50),
    Text = Color3.fromRGB(245, 245, 250),
    TextDim = Color3.fromRGB(150, 155, 165),
    Element = Color3.fromRGB(25, 28, 38), 
    Border = Color3.fromRGB(38, 42, 55)
}

function SleepyUI:CreateWindow(config)
    local title = config.Title or config.Name or "StarHub Premium"
    
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

    -- Floating Minimize Icon (Star shape/circle)
    local MinIcon = Instance.new("ImageButton")
    MinIcon.Size = UDim2.new(0, 48, 0, 48)
    MinIcon.Position = UDim2.new(0.5, -24, 0, 20)
    MinIcon.BackgroundColor3 = Theme.Sidebar
    MinIcon.Visible = false
    MinIcon.ZIndex = 150
    MinIcon.Parent = ScreenGui
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(1, 0) -- Perfect circle
    MinCorner.Parent = MinIcon
    local MinStroke = Instance.new("UIStroke")
    MinStroke.Color = Theme.Accent
    MinStroke.Thickness = 2
    MinStroke.Parent = MinIcon
    
    local MinStar = Instance.new("TextLabel")
    MinStar.Size = UDim2.new(1, 0, 1, 0)
    MinStar.BackgroundTransparency = 1
    MinStar.Text = "⭐"
    MinStar.TextColor3 = Theme.Accent
    MinStar.TextSize = 24
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
    MainFrame.Size = UDim2.new(0, 620, 0, 420) -- Larger size
    MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Parent = MainFrame

    -- TOP BAR
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 46)
    TopBar.BackgroundColor3 = Theme.TopBar
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 10
    TopBar.Parent = MainFrame
    
    local TopDivider = Instance.new("Frame")
    TopDivider.Size = UDim2.new(1, 0, 0, 1)
    TopDivider.Position = UDim2.new(0, 0, 1, 0)
    TopDivider.BackgroundColor3 = Theme.Border
    TopDivider.BorderSizePixel = 0
    TopDivider.ZIndex = 10
    TopDivider.Parent = TopBar
    
    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(0, 30, 1, 0)
    Logo.Position = UDim2.new(0, 16, 0, 0)
    Logo.BackgroundTransparency = 1
    Logo.Text = "⭐"
    Logo.TextColor3 = Theme.Accent
    Logo.TextSize = 20
    Logo.Font = Enum.Font.GothamBold
    Logo.ZIndex = 10
    Logo.Parent = TopBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 50, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 10
    TitleLabel.Parent = TopBar
    
    -- Window Controls
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 1, 0)
    CloseBtn.Position = UDim2.new(1, -40, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Theme.TextDim
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.ZIndex = 10
    CloseBtn.Parent = TopBar
    CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play() end)
    CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play() end)
    
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 40, 1, 0)
    MinBtn.Position = UDim2.new(1, -80, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Theme.TextDim
    MinBtn.TextSize = 16
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
    Sidebar.Size = UDim2.new(0, 160, 1, -46)
    Sidebar.Position = UDim2.new(0, 0, 0, 46)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
    SidebarDivider.BackgroundColor3 = Theme.Border
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.Parent = Sidebar

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -20)
    TabContainer.Position = UDim2.new(0, 0, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 6)
    TabList.Parent = TabContainer

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -161, 1, -46)
    ContentArea.Position = UDim2.new(0, 161, 0, 46)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local TopContentBar = Instance.new("Frame")
    TopContentBar.Size = UDim2.new(1, 0, 0, 46)
    TopContentBar.BackgroundTransparency = 1
    TopContentBar.Parent = ContentArea

    local ContentTitle = Instance.new("TextLabel")
    ContentTitle.Size = UDim2.new(1, -24, 1, 0)
    ContentTitle.Position = UDim2.new(0, 24, 0, 0)
    ContentTitle.BackgroundTransparency = 1
    ContentTitle.Text = "Home"
    ContentTitle.TextColor3 = Theme.Text
    ContentTitle.TextSize = 22
    ContentTitle.Font = Enum.Font.GothamBold
    ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
    ContentTitle.Parent = TopContentBar

    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1, 0, 1, -46)
    Pages.Position = UDim2.new(0, 0, 0, 46)
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
        TabBtn.Size = UDim2.new(1, -24, 0, 36)
        TabBtn.Position = UDim2.new(0, 12, 0, 0)
        TabBtn.BackgroundColor3 = Theme.Element
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabContainer
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabBtn
        
        local ActiveIndicator = Instance.new("Frame")
        ActiveIndicator.Size = UDim2.new(0, 3, 0, 18)
        ActiveIndicator.Position = UDim2.new(0, -12, 0.5, -9)
        ActiveIndicator.BackgroundColor3 = Theme.Accent
        ActiveIndicator.Parent = TabBtn
        local IndCorner = Instance.new("UICorner")
        IndCorner.CornerRadius = UDim.new(1, 0)
        IndCorner.Parent = ActiveIndicator

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
        TextLabel.Size = UDim2.new(1, -40, 1, 0)
        TextLabel.Position = UDim2.new(0, 40, 0, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = tabTitle
        TextLabel.TextColor3 = Theme.TextDim
        TextLabel.TextSize = 13
        TextLabel.Font = Enum.Font.Gotham
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -30, 1, -10)
        Page.Position = UDim2.new(0, 15, 0, 0)
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
                TweenService:Create(activeTab.Ind, TweenInfo.new(0.2), {Position = UDim2.new(0, -12, 0.5, -9)}):Play()
                activeTab.Icon.TextColor3 = Theme.TextDim
                activeTab.Text.TextColor3 = Theme.TextDim
                activeTab.Text.Font = Enum.Font.Gotham
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
            TweenService:Create(ActiveIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0.5, -9)}):Play()
            IconLabel.TextColor3 = Theme.Accent
            TextLabel.TextColor3 = Theme.Text
            TextLabel.Font = Enum.Font.GothamBold
            activeTab = {Btn = TabBtn, Icon = IconLabel, Text = TextLabel, Ind = ActiveIndicator}
            ShowPage(Page, tabTitle)
        end)

        if not activeTab then
            TabBtn.BackgroundTransparency = 0.5
            ActiveIndicator.Position = UDim2.new(0, 0, 0.5, -9)
            IconLabel.TextColor3 = Theme.Accent
            TextLabel.TextColor3 = Theme.Text
            TextLabel.Font = Enum.Font.GothamBold
            activeTab = {Btn = TabBtn, Icon = IconLabel, Text = TextLabel, Ind = ActiveIndicator}
            Page.Visible = true
            ContentTitle.Text = tabTitle
        end

        local TabAPI = {}
        
        function TabAPI:Section(secConfig)
            local secTitle = secConfig.Title or "Section"
            local isDefault = secConfig.Default

            local AccFrame = Instance.new("Frame")
            AccFrame.Size = UDim2.new(1, 0, 0, 42)
            AccFrame.BackgroundColor3 = Theme.Element
            AccFrame.BackgroundTransparency = 0.3
            AccFrame.ClipsDescendants = true
            AccFrame.Parent = Page
            local AccCorner = Instance.new("UICorner")
            AccCorner.CornerRadius = UDim.new(0, 8)
            AccCorner.Parent = AccFrame
            
            local AccStroke = Instance.new("UIStroke")
            AccStroke.Color = Theme.Border
            AccStroke.Thickness = 1
            AccStroke.Parent = AccFrame
            
            local AccBtn = Instance.new("TextButton")
            AccBtn.Size = UDim2.new(1, 0, 0, 42)
            AccBtn.BackgroundTransparency = 1
            AccBtn.Text = ""
            AccBtn.Parent = AccFrame

            local AccTitle = Instance.new("TextLabel")
            AccTitle.Size = UDim2.new(1, -40, 1, 0)
            AccTitle.Position = UDim2.new(0, 15, 0, 0)
            AccTitle.BackgroundTransparency = 1
            AccTitle.Text = secTitle
            AccTitle.TextColor3 = Theme.Accent
            AccTitle.TextSize = 14
            AccTitle.Font = Enum.Font.GothamBold
            AccTitle.TextXAlignment = Enum.TextXAlignment.Left
            AccTitle.Parent = AccBtn

            local AccArrow = Instance.new("TextLabel")
            AccArrow.Size = UDim2.new(0, 30, 1, 0)
            AccArrow.Position = UDim2.new(1, -40, 0, 0)
            AccArrow.BackgroundTransparency = 1
            AccArrow.Text = "+"
            AccArrow.TextColor3 = Theme.TextDim
            AccArrow.TextSize = 18
            AccArrow.Font = Enum.Font.GothamBold
            AccArrow.Parent = AccBtn

            local ContentFrame = Instance.new("Frame")
            ContentFrame.Size = UDim2.new(1, 0, 0, 0)
            ContentFrame.Position = UDim2.new(0, 0, 0, 42)
            ContentFrame.BackgroundTransparency = 1
            ContentFrame.Parent = AccFrame

            local CLayout = Instance.new("UIListLayout")
            CLayout.SortOrder = Enum.SortOrder.LayoutOrder
            CLayout.Padding = UDim.new(0, 8)
            CLayout.Parent = ContentFrame
            
            local isOpen = false

            local function updateSize()
                if isOpen then
                    AccFrame.Size = UDim2.new(1, 0, 0, 42 + CLayout.AbsoluteContentSize.Y + 12)
                else
                    AccFrame.Size = UDim2.new(1, 0, 0, 42)
                end
                ContentFrame.Size = UDim2.new(1, -20, 0, CLayout.AbsoluteContentSize.Y)
                ContentFrame.Position = UDim2.new(0, 10, 0, 42)
            end

            CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

            AccBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                AccArrow.Text = isOpen and "-" or "+"
                TweenService:Create(AccFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = isOpen and UDim2.new(1, 0, 0, 42 + CLayout.AbsoluteContentSize.Y + 12) or UDim2.new(1, 0, 0, 42)
                }):Play()
            end)
            
            if isDefault then
                isOpen = true
                AccArrow.Text = "-"
                AccFrame.Size = UDim2.new(1, 0, 0, 42 + CLayout.AbsoluteContentSize.Y + 12)
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
            EFrame.Size = UDim2.new(1, 0, 0, config.Desc and 54 or 42)
            EFrame.BackgroundColor3 = Theme.Element
            EFrame.Parent = targetParent
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = EFrame
            
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Theme.Border
            Stroke.Thickness = 1
            Stroke.Parent = EFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -100, 0, 20)
            Label.Position = UDim2.new(0, 15, 0, config.Desc and 8 or 11)
            Label.BackgroundTransparency = 1
            Label.Text = config.Title or "Element"
            Label.TextColor3 = Theme.Text
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = EFrame
            
            if config.Desc then
                local Desc = Instance.new("TextLabel")
                Desc.Size = UDim2.new(1, -100, 0, 16)
                Desc.Position = UDim2.new(0, 15, 0, 28)
                Desc.BackgroundTransparency = 1
                Desc.Text = config.Desc
                Desc.TextColor3 = Theme.TextDim
                Desc.TextSize = 11
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
            TogBtn.Size = UDim2.new(0, 44, 0, 22)
            TogBtn.Position = UDim2.new(1, -55, 0.5, -11)
            TogBtn.BackgroundColor3 = state and Theme.Accent or Theme.Background
            TogBtn.Text = ""
            TogBtn.Parent = EFrame
            local TogCorner = Instance.new("UICorner")
            TogCorner.CornerRadius = UDim.new(1, 0)
            TogCorner.Parent = TogBtn
            local TogStroke = Instance.new("UIStroke")
            TogStroke.Color = Theme.Border
            TogStroke.Thickness = 1
            TogStroke.Transparency = state and 1 or 0
            TogStroke.Parent = TogBtn
            
            local TogCircle = Instance.new("Frame")
            TogCircle.Size = UDim2.new(0, 16, 0, 16)
            TogCircle.Position = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            TogCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TogCircle.Parent = TogBtn
            local CircCorner = Instance.new("UICorner")
            CircCorner.CornerRadius = UDim.new(1, 0)
            CircCorner.Parent = TogCircle
            
            TogBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(TogBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Theme.Background}):Play()
                TweenService:Create(TogStroke, TweenInfo.new(0.2), {Transparency = state and 1 or 0}):Play()
                TweenService:Create(TogCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
                if config.Callback then pcall(config.Callback, state) end
            end)
        end
        
        function TabAPI:Button(config)
            local EFrame = CreateElementFrame(config)
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0, 110, 0, 26)
            Btn.Position = UDim2.new(1, -125, 0.5, -13)
            Btn.BackgroundColor3 = Theme.Background
            Btn.Text = "Execute"
            Btn.TextColor3 = Theme.Accent
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 12
            Btn.Parent = EFrame
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Btn
            local UIStroke = Instance.new("UIStroke")
            UIStroke.Color = Theme.Border
            UIStroke.Thickness = 1
            UIStroke.Parent = Btn
            
            Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Sidebar}):Play() end)
            Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background}):Play() end)
            
            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 100, 0, 22), Position = UDim2.new(1, -120, 0.5, -11)}):Play()
                task.wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0, 110, 0, 26), Position = UDim2.new(1, -125, 0.5, -13)}):Play()
                if config.Callback then pcall(config.Callback) end
            end)
        end
        
        function TabAPI:Cycle(config)
            local EFrame = CreateElementFrame(config)
            local selected = config.Default or (config.Values and config.Values[1]) or ""
            
            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(0, 150, 0, 26)
            DropBtn.Position = UDim2.new(1, -165, 0.5, -13)
            DropBtn.BackgroundColor3 = Theme.Background
            DropBtn.Text = selected
            DropBtn.TextColor3 = Theme.Text
            DropBtn.TextSize = 12
            DropBtn.Font = Enum.Font.Gotham
            DropBtn.Parent = EFrame
            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 6)
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
            DropBtn.Position = UDim2.new(1, -165, 0.5, -13)
            DropBtn.BackgroundColor3 = Theme.Background
            DropBtn.Text = selected
            DropBtn.TextColor3 = Theme.Text
            DropBtn.TextSize = 12
            DropBtn.Font = Enum.Font.Gotham
            DropBtn.Parent = EFrame
            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 6)
            DropCorner.Parent = DropBtn
            local UIStroke = Instance.new("UIStroke")
            UIStroke.Color = Theme.Border
            UIStroke.Thickness = 1
            UIStroke.Parent = DropBtn
            
            local DropIcon = Instance.new("TextLabel")
            DropIcon.Size = UDim2.new(0, 24, 1, 0)
            DropIcon.Position = UDim2.new(1, -24, 0, 0)
            DropIcon.BackgroundTransparency = 1
            DropIcon.Text = "▼"
            DropIcon.TextColor3 = Theme.Accent
            DropIcon.TextSize = 10
            DropIcon.Font = Enum.Font.GothamBold
            DropIcon.Parent = DropBtn

            -- Floating List
            local OptionList = Instance.new("ScrollingFrame")
            OptionList.BackgroundColor3 = Theme.Element
            OptionList.BorderSizePixel = 0
            OptionList.ScrollBarThickness = 3
            OptionList.ScrollBarImageColor3 = Theme.Accent
            OptionList.Visible = false
            OptionList.ZIndex = 101
            OptionList.Parent = Overlay

            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 6)
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
                    OptBtn.BackgroundColor3 = Theme.Sidebar
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = "  " .. val
                    OptBtn.TextColor3 = val == selected and Theme.Accent or Theme.TextDim
                    OptBtn.TextSize = 12
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
                        DropIcon.Text = "▼"
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
                DropIcon.Text = isOpen and "▲" or "▼"
                
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
                    DropIcon.Text = "▼"
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
            SliderBg.Position = UDim2.new(1, -165, 0.5, -3)
            SliderBg.BackgroundColor3 = Theme.Background
            SliderBg.Parent = EFrame
            local BgCorner = Instance.new("UICorner")
            BgCorner.CornerRadius = UDim.new(1, 0)
            BgCorner.Parent = SliderBg
            
            local SliderFill = Instance.new("Frame")
            local pct = (val - min) / (max - min)
            SliderFill.Size = UDim2.new(pct, 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Accent
            SliderFill.Parent = SliderBg
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = SliderFill
            
            local Thumb = Instance.new("Frame")
            Thumb.Size = UDim2.new(0, 14, 0, 14)
            Thumb.Position = UDim2.new(pct, -7, 0.5, -7)
            Thumb.BackgroundColor3 = Theme.Text
            Thumb.Parent = SliderBg
            local ThumbCorner = Instance.new("UICorner")
            ThumbCorner.CornerRadius = UDim.new(1, 0)
            ThumbCorner.Parent = Thumb
            
            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0, 30, 0, 20)
            ValLabel.Position = UDim2.new(1, -205, 0.5, -10)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(val)
            ValLabel.TextColor3 = Theme.TextDim
            ValLabel.TextSize = 12
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
                    Thumb.Position = UDim2.new(p, -7, 0.5, -7)
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
