--[[
    🌙 SleepyUI Library (Premium Data-Driven Edition)
    An ultra-modern, elegant, and smooth UI Framework for Roblox
    Version 3.0.0 (Nathub Style)
]]

local SleepyUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Theme = {
    Background = Color3.fromRGB(20, 18, 25),
    Sidebar = Color3.fromRGB(15, 13, 20),
    Accent = Color3.fromRGB(120, 80, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 150),
    Element = Color3.fromRGB(25, 23, 30),
    Border = Color3.fromRGB(35, 33, 45)
}

function SleepyUI:CreateWindow(config)
    local title = config.Title or config.Name or "SleepyUI v3"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SleepyUIV3"
    local parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui
    if RunService:IsStudio() then parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    
    for _, v in pairs(parent:GetChildren()) do
        if v.Name == ScreenGui.Name then v:Destroy() end
    end
    ScreenGui.Parent = parent

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 560, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -200)
    MainFrame.BackgroundColor3 = Theme.Background
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

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 8)
    SidebarCorner.Parent = Sidebar
    
    local SidebarCover = Instance.new("Frame")
    SidebarCover.Size = UDim2.new(0, 8, 1, 0)
    SidebarCover.Position = UDim2.new(1, -8, 0, 0)
    SidebarCover.BackgroundColor3 = Theme.Sidebar
    SidebarCover.BorderSizePixel = 0
    SidebarCover.Parent = Sidebar

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = Sidebar

    local DiscordIcon = Instance.new("TextLabel")
    DiscordIcon.Size = UDim2.new(0, 45, 1, 0)
    DiscordIcon.BackgroundTransparency = 1
    DiscordIcon.Text = "👾"
    DiscordIcon.TextColor3 = Theme.Accent
    DiscordIcon.TextSize = 20
    DiscordIcon.Font = Enum.Font.GothamBold
    DiscordIcon.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -45, 1, 0)
    TitleLabel.Position = UDim2.new(0, 35, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 12
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -20, 0, 26)
    SearchBox.Position = UDim2.new(0, 10, 0, 45)
    SearchBox.BackgroundColor3 = Theme.Element
    SearchBox.Text = "  🔍 Search"
    SearchBox.TextColor3 = Theme.TextDim
    SearchBox.TextSize = 12
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.Parent = Sidebar
    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBox
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -80)
    TabContainer.Position = UDim2.new(0, 0, 0, 80)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabContainer

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -160, 1, 0)
    ContentArea.Position = UDim2.new(0, 160, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local TopContentBar = Instance.new("Frame")
    TopContentBar.Size = UDim2.new(1, 0, 0, 45)
    TopContentBar.BackgroundTransparency = 1
    TopContentBar.Parent = ContentArea

    local ContentTitle = Instance.new("TextLabel")
    ContentTitle.Size = UDim2.new(1, -20, 1, 0)
    ContentTitle.Position = UDim2.new(0, 20, 0, 0)
    ContentTitle.BackgroundTransparency = 1
    ContentTitle.Text = "Home"
    ContentTitle.TextColor3 = Theme.Text
    ContentTitle.TextSize = 16
    ContentTitle.Font = Enum.Font.GothamBold
    ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
    ContentTitle.Parent = TopContentBar

    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1, 0, 1, -45)
    Pages.Position = UDim2.new(0, 0, 0, 45)
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
    
    function WindowAPI:SelectTab(index)
        -- Can be implemented if needed
    end

    function WindowAPI:Tab(tabConfig)
        local tabTitle = tabConfig.Title or "Tab"
        local tabIcon = tabConfig.Icon or "◈"

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -10, 0, 35)
        TabBtn.Position = UDim2.new(0, 5, 0, 0)
        TabBtn.BackgroundColor3 = Theme.Element
        TabBtn.BackgroundTransparency = 1 -- Transparent initially
        TabBtn.Text = ""
        TabBtn.Parent = TabContainer
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabBtn

        local IconLabel = Instance.new("TextLabel")
        IconLabel.Size = UDim2.new(0, 30, 1, 0)
        IconLabel.Position = UDim2.new(0, 10, 0, 0)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = tabIcon
        IconLabel.TextColor3 = Theme.TextDim
        IconLabel.TextSize = 14
        IconLabel.Font = Enum.Font.Gotham
        IconLabel.Parent = TabBtn

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Size = UDim2.new(1, -40, 1, 0)
        TextLabel.Position = UDim2.new(0, 35, 0, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = tabTitle
        TextLabel.TextColor3 = Theme.TextDim
        TextLabel.TextSize = 13
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
        PageLayout.Padding = UDim.new(0, 5)
        PageLayout.Parent = Page
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.Btn.BackgroundTransparency = 1
                activeTab.Icon.TextColor3 = Theme.TextDim
                activeTab.Text.TextColor3 = Theme.TextDim
            end
            TabBtn.BackgroundTransparency = 0
            IconLabel.TextColor3 = Theme.Accent
            TextLabel.TextColor3 = Theme.Text
            activeTab = {Btn = TabBtn, Icon = IconLabel, Text = TextLabel}
            ShowPage(Page, tabTitle)
        end)

        if not activeTab then
            TabBtn.BackgroundTransparency = 0
            IconLabel.TextColor3 = Theme.Accent
            TextLabel.TextColor3 = Theme.Text
            activeTab = {Btn = TabBtn, Icon = IconLabel, Text = TextLabel}
            Page.Visible = true
            ContentTitle.Text = tabTitle
        end

        local TabAPI = {}
        
        function TabAPI:Section(secConfig)
            local secTitle = secConfig.Title or "Section"
            local isDefault = secConfig.Default

            local AccFrame = Instance.new("Frame")
            AccFrame.Size = UDim2.new(1, 0, 0, 45)
            AccFrame.BackgroundTransparency = 1
            AccFrame.ClipsDescendants = true
            AccFrame.Parent = Page

            local AccBtn = Instance.new("TextButton")
            AccBtn.Size = UDim2.new(1, 0, 0, 45)
            AccBtn.BackgroundTransparency = 1
            AccBtn.Text = ""
            AccBtn.Parent = AccFrame

            local AccIcon = Instance.new("TextLabel")
            AccIcon.Size = UDim2.new(0, 30, 1, 0)
            AccIcon.BackgroundTransparency = 1
            AccIcon.Text = "❖"
            AccIcon.TextColor3 = Theme.Accent
            AccIcon.TextSize = 12
            AccIcon.Font = Enum.Font.Gotham
            AccIcon.Parent = AccBtn

            local AccTitle = Instance.new("TextLabel")
            AccTitle.Size = UDim2.new(1, -60, 1, 0)
            AccTitle.Position = UDim2.new(0, 30, 0, 0)
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
            ContentFrame.Position = UDim2.new(0, 0, 0, 45)
            ContentFrame.BackgroundTransparency = 1
            ContentFrame.Parent = AccFrame

            local CLayout = Instance.new("UIListLayout")
            CLayout.SortOrder = Enum.SortOrder.LayoutOrder
            CLayout.Padding = UDim.new(0, 5)
            CLayout.Parent = ContentFrame
            
            local isOpen = false

            local function updateSize()
                if isOpen then
                    AccFrame.Size = UDim2.new(1, 0, 0, 45 + CLayout.AbsoluteContentSize.Y)
                else
                    AccFrame.Size = UDim2.new(1, 0, 0, 45)
                end
                ContentFrame.Size = UDim2.new(1, 0, 0, CLayout.AbsoluteContentSize.Y)
            end

            CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

            AccBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                AccArrow.Text = isOpen and "^" or "v"
                TweenService:Create(AccFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = isOpen and UDim2.new(1, 0, 0, 45 + CLayout.AbsoluteContentSize.Y) or UDim2.new(1, 0, 0, 45)
                }):Play()
            end)
            
            if isDefault then
                isOpen = true
                AccArrow.Text = "^"
                AccFrame.Size = UDim2.new(1, 0, 0, 45 + CLayout.AbsoluteContentSize.Y)
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
            EFrame.Size = UDim2.new(1, 0, 0, config.Desc and 50 or 40)
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
            Label.Position = UDim2.new(0, config.Section and 25 or 10, 0, config.Desc and 8 or 10)
            Label.BackgroundTransparency = 1
            Label.Text = config.Title or "Element"
            Label.TextColor3 = Theme.Text
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = EFrame
            
            if config.Desc then
                local Desc = Instance.new("TextLabel")
                Desc.Size = UDim2.new(1, -100, 0, 15)
                Desc.Position = UDim2.new(0, config.Section and 25 or 10, 0, 26)
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
            TogBtn.Size = UDim2.new(0, 40, 0, 20)
            TogBtn.Position = UDim2.new(1, -50, 0.5, -10)
            TogBtn.BackgroundColor3 = state and Theme.Accent or Theme.Element
            TogBtn.Text = ""
            TogBtn.Parent = EFrame
            local TogCorner = Instance.new("UICorner")
            TogCorner.CornerRadius = UDim.new(1, 0)
            TogCorner.Parent = TogBtn
            
            local TogCircle = Instance.new("Frame")
            TogCircle.Size = UDim2.new(0, 16, 0, 16)
            TogCircle.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            TogCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TogCircle.Parent = TogBtn
            local CircCorner = Instance.new("UICorner")
            CircCorner.CornerRadius = UDim.new(1, 0)
            CircCorner.Parent = TogCircle
            
            TogBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(TogBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Theme.Element}):Play()
                TweenService:Create(TogCircle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                if config.Callback then pcall(config.Callback, state) end
            end)
        end
        
        function TabAPI:Button(config)
            local EFrame = CreateElementFrame(config)
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0, 100, 0, 26)
            Btn.Position = UDim2.new(1, -110, 0.5, -13)
            Btn.BackgroundColor3 = Theme.Element
            Btn.Text = "Execute"
            Btn.TextColor3 = Theme.Text
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 12
            Btn.Parent = EFrame
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Btn
            
            local UIStroke = Instance.new("UIStroke")
            UIStroke.Color = Theme.Border
            UIStroke.Thickness = 1
            UIStroke.Parent = Btn
            
            Btn.MouseButton1Click:Connect(function()
                if config.Callback then pcall(config.Callback) end
            end)
        end
        
        function TabAPI:Cycle(config)
            local EFrame = CreateElementFrame(config)
            local selected = config.Default or (config.Values and config.Values[1]) or ""
            
            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(0, 180, 0, 26)
            DropBtn.Position = UDim2.new(1, -190, 0.5, -13)
            DropBtn.BackgroundColor3 = Theme.Background
            DropBtn.Text = selected
            DropBtn.TextColor3 = Theme.Text
            DropBtn.TextSize = 12
            DropBtn.Font = Enum.Font.Gotham
            DropBtn.Parent = EFrame
            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 4)
            DropCorner.Parent = DropBtn
            local UIStroke = Instance.new("UIStroke")
            UIStroke.Color = Theme.Accent
            UIStroke.Thickness = 1
            UIStroke.Parent = DropBtn
            
            DropBtn.MouseButton1Click:Connect(function()
                -- Simplified dropdown click logic for now
                local nextIdx = 1
                for i, v in ipairs(config.Values) do if v == selected then nextIdx = i + 1 break end end
                if nextIdx > #config.Values then nextIdx = 1 end
                if not config.Values or #config.Values == 0 then return end
                selected = config.Values[nextIdx]
                DropBtn.Text = selected
                if config.Callback then pcall(config.Callback, selected) end
            end)
            
            return {
                Refresh = function(newValues)
                    config.Values = newValues
                    selected = newValues[1] or "None"
                    DropBtn.Text = selected
                    if config.Callback then pcall(config.Callback, selected) end
                end
            }
        end
        

        function TabAPI:Dropdown(config)
            local targetParent = config.Section and config.Section.ContentFrame or Page
            local EFrame = Instance.new("Frame")
            EFrame.Size = UDim2.new(1, 0, 0, config.Desc and 50 or 40)
            EFrame.BackgroundColor3 = Theme.Element
            EFrame.ClipsDescendants = true
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
            Label.Position = UDim2.new(0, config.Section and 25 or 10, 0, config.Desc and 8 or 10)
            Label.BackgroundTransparency = 1
            Label.Text = config.Title or "Element"
            Label.TextColor3 = Theme.Text
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = EFrame
            
            if config.Desc then
                local Desc = Instance.new("TextLabel")
                Desc.Size = UDim2.new(1, -100, 0, 15)
                Desc.Position = UDim2.new(0, config.Section and 25 or 10, 0, 26)
                Desc.BackgroundTransparency = 1
                Desc.Text = config.Desc
                Desc.TextColor3 = Theme.TextDim
                Desc.TextSize = 11
                Desc.Font = Enum.Font.Gotham
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.Parent = EFrame
            end

            local selected = config.Default or (config.Values and config.Values[1]) or ""
            local isOpen = false
            local baseHeight = config.Desc and 50 or 40
            
            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(0, 180, 0, 26)
            DropBtn.Position = UDim2.new(1, -190, 0, (baseHeight - 26) / 2)
            DropBtn.BackgroundColor3 = Theme.Background
            DropBtn.Text = selected
            DropBtn.TextColor3 = Theme.Text
            DropBtn.TextSize = 12
            DropBtn.Font = Enum.Font.Gotham
            DropBtn.Parent = EFrame
            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 4)
            DropCorner.Parent = DropBtn
            local UIStroke = Instance.new("UIStroke")
            UIStroke.Color = Theme.Accent
            UIStroke.Thickness = 1
            UIStroke.Parent = DropBtn
            
            local DropIcon = Instance.new("TextLabel")
            DropIcon.Size = UDim2.new(0, 20, 1, 0)
            DropIcon.Position = UDim2.new(1, -20, 0, 0)
            DropIcon.BackgroundTransparency = 1
            DropIcon.Text = "v"
            DropIcon.TextColor3 = Theme.TextDim
            DropIcon.TextSize = 12
            DropIcon.Font = Enum.Font.GothamBold
            DropIcon.Parent = DropBtn
            
            local OptionList = Instance.new("ScrollingFrame")
            OptionList.Size = UDim2.new(0, 180, 0, 0)
            OptionList.Position = UDim2.new(1, -190, 0, baseHeight)
            OptionList.BackgroundColor3 = Theme.Background
            OptionList.BorderSizePixel = 0
            OptionList.ScrollBarThickness = 2
            OptionList.ScrollBarImageColor3 = Theme.Accent
            OptionList.Parent = EFrame
            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 4)
            ListCorner.Parent = OptionList
            
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
                    OptBtn.BackgroundColor3 = Theme.Background
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = "  " .. val
                    OptBtn.TextColor3 = val == selected and Theme.Accent or Theme.TextDim
                    OptBtn.TextSize = 12
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.Parent = OptionList
                    
                    totalHeight = totalHeight + 26
                    
                    OptBtn.MouseEnter:Connect(function() TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = Theme.Element}):Play() end)
                    OptBtn.MouseLeave:Connect(function() TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, BackgroundColor3 = Theme.Background}):Play() end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        selected = val
                        DropBtn.Text = selected
                        isOpen = false
                        DropIcon.Text = "v"
                        TweenService:Create(EFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, baseHeight)}):Play()
                        for _, ob in pairs(OptionList:GetChildren()) do
                            if ob:IsA("TextButton") then
                                ob.TextColor3 = ob.Text:sub(3) == selected and Theme.Accent or Theme.TextDim
                            end
                        end
                        if config.Callback then pcall(config.Callback, selected) end
                    end)
                end
                OptionList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
                OptionList.Size = UDim2.new(0, 180, 0, math.min(totalHeight, 120))
                
                if isOpen then
                    EFrame.Size = UDim2.new(1, 0, 0, baseHeight + OptionList.Size.Y.Offset + 5)
                end
            end
            
            DropBtn.MouseButton1Click:Connect(function()
                if not config.Values or #config.Values == 0 then return end
                isOpen = not isOpen
                DropIcon.Text = isOpen and "^" or "v"
                TweenService:Create(EFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = isOpen and UDim2.new(1, 0, 0, baseHeight + OptionList.Size.Y.Offset + 5) or UDim2.new(1, 0, 0, baseHeight)
                }):Play()
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
            SliderBg.Size = UDim2.new(0, 180, 0, 6)
            SliderBg.Position = UDim2.new(1, -190, 0.5, -3)
            SliderBg.BackgroundColor3 = Theme.Element
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
            
            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0, 30, 0, 20)
            ValLabel.Position = UDim2.new(1, -230, 0.5, -10)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(val)
            ValLabel.TextColor3 = Theme.TextDim
            ValLabel.TextSize = 12
            ValLabel.Font = Enum.Font.Gotham
            ValLabel.Parent = EFrame
            
            -- Simplified slider click interaction
            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
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
        -- Notification logic
    end
    
    return WindowAPI
end

return SleepyUI
