--[[
    🌙 SleepyUI Library (Premium Edition)
    An ultra-modern, elegant, and smooth UI Framework for Roblox
    Version 2.0.0
]]

local SleepyUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Default Settings
local Settings = {
    Theme = {
        Background = Color3.fromRGB(15, 15, 20), -- Deeper dark
        Sidebar = Color3.fromRGB(22, 22, 28),
        Element = Color3.fromRGB(30, 30, 38),
        ElementHover = Color3.fromRGB(42, 42, 52),
        Accent = Color3.fromRGB(114, 137, 218), -- Discord Blurple
        AccentHover = Color3.fromRGB(130, 150, 230),
        Text = Color3.fromRGB(250, 250, 250),
        TextMuted = Color3.fromRGB(140, 140, 150),
        Border = Color3.fromRGB(45, 45, 55),
        Success = Color3.fromRGB(67, 181, 129),
        Danger = Color3.fromRGB(240, 71, 71)
    },
    Font = Enum.Font.GothamMedium,
    TitleFont = Enum.Font.GothamBold,
    CornerRadius = UDim.new(0, 8), -- General corner
    PillRadius = UDim.new(1, 0) -- For toggles
}

-- Utility: Tweening
local function CreateTween(instance, properties, duration, style)
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Quart
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Settings.CornerRadius
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Settings.Theme.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function MakeDraggable(topbarobject, object)
    local Dragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        end
    end)
end

function SleepyUI:CreateWindow(config)
    config = config or {}
    local TitleText = config.Name or "SleepyUI Premium"
    local Theme = config.Theme or Settings.Theme

    -- UI Target
    local UITarget = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    if UITarget:FindFirstChild("SleepyUI_Lib") then
        UITarget["SleepyUI_Lib"]:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SleepyUI_Lib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = UITarget

    -- Drop Shadow (Fake)
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(0, 680, 0, 480)
    Shadow.Position = UDim2.new(0.5, -340, 0.5, -235) -- Centered slightly offset for depth
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.Parent = ScreenGui

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 650, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    AddCorner(MainFrame, UDim.new(0, 10))
    AddStroke(MainFrame, Theme.Border, 1)

    -- Update shadow position on drag
    MainFrame:GetPropertyChangedSignal("Position"):Connect(function()
        Shadow.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset - 15, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset - 10)
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, 0, 0, 0)
    SidebarLine.BackgroundColor3 = Theme.Border
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = Sidebar

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 0, 60)
    Title.Position = UDim2.new(0, 20, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = TitleText
    Title.TextColor3 = Theme.Accent
    Title.Font = Settings.TitleFont
    Title.TextSize = 17
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Sidebar

    MakeDraggable(Title, MainFrame)
    MakeDraggable(Sidebar, MainFrame)

    -- Tab Container (Buttons)
    local TabList = Instance.new("ScrollingFrame")
    TabList.Size = UDim2.new(1, 0, 1, -80)
    TabList.Position = UDim2.new(0, 0, 0, 70)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 0
    TabList.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Parent = TabList

    -- Page Container
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -180, 1, 0)
    PageContainer.Position = UDim2.new(0, 180, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame
    MakeDraggable(PageContainer, MainFrame)

    local WindowState = {
        CurrentTab = nil,
        Tabs = {}
    }

    local WindowAPI = {}

    function WindowAPI:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName
        TabBtn.Size = UDim2.new(0.85, 0, 0, 40)
        TabBtn.BackgroundColor3 = Theme.Element
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "  " .. tabName
        TabBtn.TextColor3 = Theme.TextMuted
        TabBtn.Font = Settings.Font
        TabBtn.TextSize = 14
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabList
        AddCorner(TabBtn, UDim.new(0, 8))

        local TabIndicator = Instance.new("Frame")
        TabIndicator.Size = UDim2.new(0, 4, 0, 0)
        TabIndicator.Position = UDim2.new(0, -6, 0.5, 0)
        TabIndicator.AnchorPoint = Vector2.new(0, 0.5)
        TabIndicator.BackgroundColor3 = Theme.Accent
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Parent = TabBtn
        AddCorner(TabIndicator, Settings.PillRadius)

        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "_Page"
        Page.Size = UDim2.new(1, -30, 1, -30)
        Page.Position = UDim2.new(0, 15, 0, 15)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Visible = false
        Page.Parent = PageContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10) -- Breathable padding
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        -- Tab Switching Logic
        local function ActivateTab()
            if WindowState.CurrentTab == tabName then return end
            
            -- Deactivate all
            for name, data in pairs(WindowState.Tabs) do
                CreateTween(data.Btn, {BackgroundTransparency = 1}, 0.3)
                CreateTween(data.Btn, {TextColor3 = Theme.TextMuted}, 0.3)
                CreateTween(data.Indicator, {Size = UDim2.new(0, 4, 0, 0)}, 0.3)
                data.Page.Visible = false
            end
            
            -- Activate this
            WindowState.CurrentTab = tabName
            CreateTween(TabBtn, {BackgroundTransparency = 0.8}, 0.3)
            CreateTween(TabBtn, {TextColor3 = Theme.Text}, 0.3)
            CreateTween(TabIndicator, {Size = UDim2.new(0, 4, 0.6, 0)}, 0.3)
            Page.Visible = true
            Page.CanvasPosition = Vector2.new(0,0)
        end

        TabBtn.MouseButton1Click:Connect(ActivateTab)

        TabBtn.MouseEnter:Connect(function()
            if WindowState.CurrentTab ~= tabName then
                CreateTween(TabBtn, {TextColor3 = Theme.Text, BackgroundTransparency = 0.9}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowState.CurrentTab ~= tabName then
                CreateTween(TabBtn, {TextColor3 = Theme.TextMuted, BackgroundTransparency = 1}, 0.2)
            end
        end)

        WindowState.Tabs[tabName] = {Btn = TabBtn, Indicator = TabIndicator, Page = Page}
        
        if WindowState.CurrentTab == nil then
            ActivateTab()
        end

        local TabAPI = {}

        function TabAPI:Clear()
            for _, child in ipairs(Page:GetChildren()) do
                if not child:IsA("UIListLayout") then
                    child:Destroy()
                end
            end
        end

        function TabAPI:CreateSection(text)
            local Sec = Instance.new("TextLabel")
            Sec.Size = UDim2.new(1, 0, 0, 30)
            Sec.BackgroundTransparency = 1
            Sec.Text = text
            Sec.TextColor3 = Theme.Accent
            Sec.Font = Settings.TitleFont
            Sec.TextSize = 13
            Sec.TextXAlignment = Enum.TextXAlignment.Left
            Sec.Parent = Page
            
            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(1, 0, 0, 1)
            Line.Position = UDim2.new(0, 0, 1, -5)
            Line.BackgroundColor3 = Theme.Border
            Line.BorderSizePixel = 0
            Line.Parent = Sec
        end

        function TabAPI:CreateButton(text, callback)
            local BtnFrame = Instance.new("Frame")
            BtnFrame.Size = UDim2.new(1, -10, 0, 42)
            BtnFrame.BackgroundColor3 = Theme.Element
            BtnFrame.Parent = Page
            AddCorner(BtnFrame, Settings.CornerRadius)
            
            local BtnStroke = AddStroke(BtnFrame, Theme.Border, 1)

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = text
            Btn.TextColor3 = Theme.Text
            Btn.Font = Settings.Font
            Btn.TextSize = 14
            Btn.AutoButtonColor = false
            Btn.Parent = BtnFrame

            Btn.MouseEnter:Connect(function()
                CreateTween(BtnFrame, {BackgroundColor3 = Theme.ElementHover}, 0.2)
                CreateTween(BtnStroke, {Color = Theme.Accent}, 0.2)
            end)
            Btn.MouseLeave:Connect(function()
                CreateTween(BtnFrame, {BackgroundColor3 = Theme.Element}, 0.2)
                CreateTween(BtnStroke, {Color = Theme.Border}, 0.2)
            end)
            Btn.MouseButton1Down:Connect(function()
                CreateTween(BtnFrame, {BackgroundColor3 = Theme.AccentHover}, 0.1)
            end)
            Btn.MouseButton1Up:Connect(function()
                CreateTween(BtnFrame, {BackgroundColor3 = Theme.ElementHover}, 0.1)
                if callback then pcall(callback) end
            end)
        end

        function TabAPI:CreateToggle(text, default, callback)
            local ToggleState = default or false

            local TogFrame = Instance.new("TextButton")
            TogFrame.Size = UDim2.new(1, -10, 0, 42)
            TogFrame.BackgroundColor3 = Theme.Element
            TogFrame.AutoButtonColor = false
            TogFrame.Text = ""
            TogFrame.Parent = Page
            AddCorner(TogFrame, Settings.CornerRadius)
            local TogStroke = AddStroke(TogFrame, Theme.Border, 1)

            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(1, -70, 1, 0)
            Lbl.Position = UDim2.new(0, 15, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = Theme.Text
            Lbl.Font = Settings.Font
            Lbl.TextSize = 14
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = TogFrame

            -- Pill Switch Background
            local SwitchBG = Instance.new("Frame")
            SwitchBG.Size = UDim2.new(0, 46, 0, 24)
            SwitchBG.Position = UDim2.new(1, -60, 0.5, -12)
            SwitchBG.BackgroundColor3 = ToggleState and Theme.Success or Theme.Background
            SwitchBG.Parent = TogFrame
            AddCorner(SwitchBG, Settings.PillRadius)
            
            local SwitchStroke = AddStroke(SwitchBG, Theme.Border, 1)

            -- Circle Thumb
            local SwitchCircle = Instance.new("Frame")
            SwitchCircle.Size = UDim2.new(0, 18, 0, 18)
            SwitchCircle.Position = UDim2.new(0, ToggleState and 25 or 3, 0.5, -9)
            SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SwitchCircle.Parent = SwitchBG
            AddCorner(SwitchCircle, Settings.PillRadius)

            local function FireToggle()
                ToggleState = not ToggleState
                if ToggleState then
                    CreateTween(SwitchBG, {BackgroundColor3 = Theme.Success}, 0.25)
                    CreateTween(SwitchCircle, {Position = UDim2.new(0, 25, 0.5, -9)}, 0.25, Enum.EasingStyle.Back)
                    CreateTween(TogStroke, {Color = Theme.Success}, 0.3)
                else
                    CreateTween(SwitchBG, {BackgroundColor3 = Theme.Background}, 0.25)
                    CreateTween(SwitchCircle, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.25, Enum.EasingStyle.Back)
                    CreateTween(TogStroke, {Color = Theme.Border}, 0.3)
                end
                if callback then pcall(callback, ToggleState) end
            end

            TogFrame.MouseButton1Click:Connect(FireToggle)
            
            if default and callback then pcall(callback, default) end
        end
        
        function TabAPI:CreateSlider(text, min, max, default, callback)
            local SliderValue = default or min
            -- Round to 1 decimal initial
            SliderValue = math.floor(SliderValue * 10) / 10
            
            local SFrame = Instance.new("Frame")
            SFrame.Size = UDim2.new(1, -10, 0, 60)
            SFrame.BackgroundColor3 = Theme.Element
            SFrame.Parent = Page
            AddCorner(SFrame, Settings.CornerRadius)
            AddStroke(SFrame, Theme.Border, 1)
            
            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(0.7, 0, 0, 30)
            Lbl.Position = UDim2.new(0, 15, 0, 5)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = Theme.Text
            Lbl.Font = Settings.Font
            Lbl.TextSize = 14
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = SFrame
            
            local ValLbl = Instance.new("TextLabel")
            ValLbl.Size = UDim2.new(0.3, -15, 0, 30)
            ValLbl.Position = UDim2.new(0.7, 0, 0, 5)
            ValLbl.BackgroundTransparency = 1
            ValLbl.Text = tostring(SliderValue)
            ValLbl.TextColor3 = Theme.Accent
            ValLbl.Font = Settings.TitleFont
            ValLbl.TextSize = 14
            ValLbl.TextXAlignment = Enum.TextXAlignment.Right
            ValLbl.Parent = SFrame
            
            local SliderBG = Instance.new("Frame")
            SliderBG.Size = UDim2.new(1, -30, 0, 6)
            SliderBG.Position = UDim2.new(0, 15, 0, 42)
            SliderBG.BackgroundColor3 = Theme.Background
            SliderBG.Parent = SFrame
            AddCorner(SliderBG, Settings.PillRadius)
            
            local SliderFill = Instance.new("Frame")
            local startScale = math.clamp((SliderValue - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(startScale, 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Accent
            SliderFill.Parent = SliderBG
            AddCorner(SliderFill, Settings.PillRadius)
            
            -- Slider Thumb
            local Thumb = Instance.new("Frame")
            Thumb.Size = UDim2.new(0, 14, 0, 14)
            Thumb.Position = UDim2.new(startScale, -7, 0.5, -7)
            Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Thumb.Parent = SliderBG
            AddCorner(Thumb, Settings.PillRadius)

            local SliderBtn = Instance.new("TextButton")
            SliderBtn.Size = UDim2.new(1, 0, 1, 24)
            SliderBtn.Position = UDim2.new(0, 0, 0.5, -12)
            SliderBtn.BackgroundTransparency = 1
            SliderBtn.Text = ""
            SliderBtn.Parent = SliderBG
            
            local Dragging = false
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                local rawValue = min + ((max - min) * pos)
                -- 0.1 precision
                SliderValue = math.floor(rawValue * 10) / 10
                
                -- Recalculate physical scale based on snapped value
                local actualPos = math.clamp((SliderValue - min) / (max - min), 0, 1)
                
                CreateTween(SliderFill, {Size = UDim2.new(actualPos, 0, 1, 0)}, 0.1)
                CreateTween(Thumb, {Position = UDim2.new(actualPos, -7, 0.5, -7)}, 0.1)
                ValLbl.Text = tostring(SliderValue)
                if callback then pcall(callback, SliderValue) end
            end
            
            SliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    CreateTween(Thumb, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(Thumb.Position.X.Scale, -9, 0.5, -9)}, 0.15)
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if Dragging then
                        Dragging = false
                        local actualPos = math.clamp((SliderValue - min) / (max - min), 0, 1)
                        CreateTween(Thumb, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(actualPos, -7, 0.5, -7)}, 0.15)
                    end
                end
            end)
            
            if default and callback then pcall(callback, default) end
        end

        return TabAPI
    end

    -- Global Notification Function
    function WindowAPI:Notify(title, desc, duration)
        duration = duration or 3
        
        local NotifContainer = ScreenGui:FindFirstChild("NotifContainer")
        if not NotifContainer then
            NotifContainer = Instance.new("Frame")
            NotifContainer.Name = "NotifContainer"
            NotifContainer.Size = UDim2.new(0, 260, 1, -20)
            NotifContainer.Position = UDim2.new(1, -280, 0, 10)
            NotifContainer.BackgroundTransparency = 1
            NotifContainer.Parent = ScreenGui
            
            local UIList = Instance.new("UIListLayout")
            UIList.Padding = UDim.new(0, 12)
            UIList.VerticalAlignment = Enum.VerticalAlignment.Bottom
            UIList.Parent = NotifContainer
        end
        
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.new(1, 0, 0, 70)
        NotifFrame.BackgroundColor3 = Theme.Element
        NotifFrame.BackgroundTransparency = 1
        NotifFrame.Position = UDim2.new(1, 50, 0, 0)
        NotifFrame.Parent = NotifContainer
        AddCorner(NotifFrame, Settings.CornerRadius)
        
        local Stroke = AddStroke(NotifFrame, Theme.Border, 1)
        Stroke.Transparency = 1
        
        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(0, 4, 1, -20)
        Line.Position = UDim2.new(0, 10, 0.5, 0)
        Line.AnchorPoint = Vector2.new(0, 0.5)
        Line.BackgroundColor3 = Theme.Accent
        Line.BackgroundTransparency = 1
        Line.Parent = NotifFrame
        AddCorner(Line, Settings.PillRadius)
        
        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -35, 0, 20)
        TitleLbl.Position = UDim2.new(0, 22, 0, 12)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Theme.Text
        TitleLbl.TextTransparency = 1
        TitleLbl.Font = Settings.TitleFont
        TitleLbl.TextSize = 14
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.Parent = NotifFrame
        
        local DescLbl = Instance.new("TextLabel")
        DescLbl.Size = UDim2.new(1, -35, 0, 20)
        DescLbl.Position = UDim2.new(0, 22, 0, 34)
        DescLbl.BackgroundTransparency = 1
        DescLbl.Text = desc
        DescLbl.TextColor3 = Theme.TextMuted
        DescLbl.TextTransparency = 1
        DescLbl.Font = Settings.Font
        DescLbl.TextSize = 13
        DescLbl.TextXAlignment = Enum.TextXAlignment.Left
        DescLbl.TextWrapped = true
        DescLbl.Parent = NotifFrame
        
        -- Animation IN
        CreateTween(NotifFrame, {BackgroundTransparency = 0, Position = UDim2.new(0,0,0,0)}, 0.4, Enum.EasingStyle.Back)
        CreateTween(Stroke, {Transparency = 0}, 0.4)
        CreateTween(Line, {BackgroundTransparency = 0}, 0.4)
        CreateTween(TitleLbl, {TextTransparency = 0}, 0.4)
        CreateTween(DescLbl, {TextTransparency = 0}, 0.4)
        
        -- Animation OUT
        task.delay(duration, function()
            CreateTween(NotifFrame, {BackgroundTransparency = 1, Position = UDim2.new(1,50,0,0)}, 0.4)
            CreateTween(Stroke, {Transparency = 1}, 0.4)
            CreateTween(Line, {BackgroundTransparency = 1}, 0.4)
            CreateTween(TitleLbl, {TextTransparency = 1}, 0.4)
            CreateTween(DescLbl, {TextTransparency = 1}, 0.4)
            task.wait(0.4)
            NotifFrame:Destroy()
        end)
    end

    return WindowAPI
end

return SleepyUI
