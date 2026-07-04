--[[
    🌙 SleepyUI Library (Winhub Exact Replica Edition)
    An ultra-modern, elegant, accordion-based UI Framework for Roblox
    Version 4.0.0
]]

local SleepyUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Settings = {
    Theme = {
        Background = Color3.fromRGB(16, 15, 20),
        Sidebar = Color3.fromRGB(12, 11, 15),
        Element = Color3.fromRGB(25, 24, 30),
        ElementHover = Color3.fromRGB(35, 34, 40),
        Accent = Color3.fromRGB(130, 90, 240), -- Winhub Purple
        AccentHover = Color3.fromRGB(150, 110, 255),
        Text = Color3.fromRGB(240, 240, 240),
        TextMuted = Color3.fromRGB(130, 130, 140),
        Border = Color3.fromRGB(35, 35, 45),
        Success = Color3.fromRGB(130, 90, 240), -- Purple for success
        Danger = Color3.fromRGB(240, 71, 71)
    },
    Font = Enum.Font.GothamMedium,
    TitleFont = Enum.Font.GothamBold,
    CornerRadius = UDim.new(0, 6),
    PillRadius = UDim.new(1, 0)
}

local function CreateTween(instance, properties, duration, style)
    duration = duration or 0.2
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
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
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
    local TitleText = config.Name or "discord.gg/winhubx"
    local Theme = config.Theme or Settings.Theme

    local UITarget = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    if UITarget:FindFirstChild("SleepyUI_Lib") then UITarget["SleepyUI_Lib"]:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SleepyUI_Lib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = UITarget

    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(0, 750, 0, 550)
    Shadow.Position = UDim2.new(0.5, -375, 0.5, -270)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.3
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.Parent = ScreenGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 700, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    AddCorner(MainFrame, UDim.new(0, 8))
    AddStroke(MainFrame, Theme.Border, 1)

    MainFrame:GetPropertyChangedSignal("Position"):Connect(function()
        Shadow.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset - 25, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset - 20)
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    AddStroke(Sidebar, Theme.Border, 1) -- Add border right

    -- Discord / Title Header
    local TitleArea = Instance.new("Frame")
    TitleArea.Size = UDim2.new(1, 0, 0, 50)
    TitleArea.BackgroundTransparency = 1
    TitleArea.Parent = Sidebar
    MakeDraggable(TitleArea, MainFrame)
    MakeDraggable(Sidebar, MainFrame)

    local DiscordIcon = Instance.new("TextLabel")
    DiscordIcon.Size = UDim2.new(0, 24, 0, 24)
    DiscordIcon.Position = UDim2.new(0, 15, 0.5, -12)
    DiscordIcon.BackgroundTransparency = 1
    DiscordIcon.Text = "👾" -- Placeholder for discord logo
    DiscordIcon.TextColor3 = Theme.Accent
    DiscordIcon.TextSize = 16
    DiscordIcon.Parent = TitleArea

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -50, 1, 0)
    TitleLbl.Position = UDim2.new(0, 45, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = TitleText
    TitleLbl.TextColor3 = Theme.Text
    TitleLbl.Font = Settings.TitleFont
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TitleArea
    
    -- Search Bar
    local SearchBG = Instance.new("Frame")
    SearchBG.Size = UDim2.new(1, -30, 0, 30)
    SearchBG.Position = UDim2.new(0, 15, 0, 50)
    SearchBG.BackgroundColor3 = Theme.Element
    SearchBG.Parent = Sidebar
    AddCorner(SearchBG, UDim.new(0, 4))
    
    local SearchIcon = Instance.new("TextLabel")
    SearchIcon.Size = UDim2.new(0, 25, 1, 0)
    SearchIcon.Position = UDim2.new(0, 5, 0, 0)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Text = "🔍"
    SearchIcon.TextColor3 = Theme.TextMuted
    SearchIcon.TextSize = 12
    SearchIcon.Parent = SearchBG
    
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -35, 1, 0)
    SearchBox.Position = UDim2.new(0, 30, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = "Search"
    SearchBox.TextColor3 = Theme.TextMuted
    SearchBox.Font = Settings.Font
    SearchBox.TextSize = 12
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.Parent = SearchBG

    -- Tabs Container
    local TabList = Instance.new("ScrollingFrame")
    TabList.Size = UDim2.new(1, 0, 1, -95)
    TabList.Position = UDim2.new(0, 0, 0, 95)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 0
    TabList.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 2)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Parent = TabList
    
    local Spacer = Instance.new("Frame")
    Spacer.Size = UDim2.new(1,0,0,5)
    Spacer.BackgroundTransparency = 1
    Spacer.Parent = TabList

    -- Page Container
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -200, 1, 0)
    PageContainer.Position = UDim2.new(0, 200, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame
    MakeDraggable(PageContainer, MainFrame)
    
    local ContentTitle = Instance.new("TextLabel")
    ContentTitle.Size = UDim2.new(1, -40, 0, 50)
    ContentTitle.Position = UDim2.new(0, 20, 0, 10)
    ContentTitle.BackgroundTransparency = 1
    ContentTitle.Text = "Info"
    ContentTitle.TextColor3 = Theme.Text
    ContentTitle.Font = Settings.TitleFont
    ContentTitle.TextSize = 22
    ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
    ContentTitle.Parent = PageContainer

    local WindowState = {
        CurrentTab = nil,
        Tabs = {}
    }

    local WindowAPI = {}

    local function CreateComponentAPI(ParentFrame)
        local API = {}
        
        function API:CreateSection(text)
            local Sec = Instance.new("TextLabel")
            Sec.Size = UDim2.new(1, -20, 0, 35)
            Sec.Position = UDim2.new(0, 10, 0, 0)
            Sec.BackgroundTransparency = 1
            Sec.Text = text
            Sec.TextColor3 = Theme.Accent
            Sec.Font = Settings.TitleFont
            Sec.TextSize = 12
            Sec.TextXAlignment = Enum.TextXAlignment.Left
            Sec.Parent = ParentFrame
        end

        function API:CreateButton(text, callback)
            local BtnFrame = Instance.new("Frame")
            BtnFrame.Size = UDim2.new(1, -20, 0, 40)
            BtnFrame.Position = UDim2.new(0, 10, 0, 0)
            BtnFrame.BackgroundTransparency = 1
            BtnFrame.Parent = ParentFrame

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundColor3 = Theme.Element
            Btn.Text = " " .. text
            Btn.TextColor3 = Theme.Text
            Btn.Font = Settings.Font
            Btn.TextSize = 13
            Btn.AutoButtonColor = false
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Parent = BtnFrame
            AddCorner(Btn, UDim.new(0, 4))
            
            local BtnStroke = AddStroke(Btn, Theme.Border, 1)

            Btn.MouseEnter:Connect(function() CreateTween(Btn, {BackgroundColor3 = Theme.ElementHover}, 0.2) end)
            Btn.MouseLeave:Connect(function() CreateTween(Btn, {BackgroundColor3 = Theme.Element}, 0.2) end)
            Btn.MouseButton1Down:Connect(function() CreateTween(BtnStroke, {Color = Theme.Accent}, 0.1) end)
            Btn.MouseButton1Up:Connect(function() 
                CreateTween(BtnStroke, {Color = Theme.Border}, 0.1)
                if callback then pcall(callback) end 
            end)
        end

        function API:CreateToggle(text, default, callback)
            local ToggleState = default or false

            local TogFrame = Instance.new("TextButton")
            TogFrame.Size = UDim2.new(1, -20, 0, 36)
            TogFrame.Position = UDim2.new(0, 10, 0, 0)
            TogFrame.BackgroundTransparency = 1
            TogFrame.Text = ""
            TogFrame.Parent = ParentFrame

            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(1, -70, 1, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = Theme.TextMuted
            Lbl.Font = Settings.Font
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = TogFrame

            local SwitchBG = Instance.new("Frame")
            SwitchBG.Size = UDim2.new(0, 40, 0, 20)
            SwitchBG.Position = UDim2.new(1, -40, 0.5, -10)
            SwitchBG.BackgroundColor3 = ToggleState and Theme.Success or Theme.Element
            SwitchBG.Parent = TogFrame
            AddCorner(SwitchBG, Settings.PillRadius)
            local SwitchStroke = AddStroke(SwitchBG, Theme.Border, 1)

            local SwitchCircle = Instance.new("Frame")
            SwitchCircle.Size = UDim2.new(0, 14, 0, 14)
            SwitchCircle.Position = UDim2.new(0, ToggleState and 23 or 3, 0.5, -7)
            SwitchCircle.BackgroundColor3 = Theme.Text
            SwitchCircle.Parent = SwitchBG
            AddCorner(SwitchCircle, Settings.PillRadius)

            local function FireToggle()
                ToggleState = not ToggleState
                if ToggleState then
                    CreateTween(SwitchBG, {BackgroundColor3 = Theme.Success}, 0.25)
                    CreateTween(SwitchCircle, {Position = UDim2.new(0, 23, 0.5, -7)}, 0.25, Enum.EasingStyle.Back)
                    CreateTween(SwitchStroke, {Transparency = 1}, 0.3)
                    CreateTween(Lbl, {TextColor3 = Theme.Text}, 0.3)
                else
                    CreateTween(SwitchBG, {BackgroundColor3 = Theme.Element}, 0.25)
                    CreateTween(SwitchCircle, {Position = UDim2.new(0, 3, 0.5, -7)}, 0.25, Enum.EasingStyle.Back)
                    CreateTween(SwitchStroke, {Transparency = 0}, 0.3)
                    CreateTween(Lbl, {TextColor3 = Theme.TextMuted}, 0.3)
                end
                if callback then pcall(callback, ToggleState) end
            end

            TogFrame.MouseButton1Click:Connect(FireToggle)
            if default then 
                SwitchStroke.Transparency = 1
                Lbl.TextColor3 = Theme.Text
                if callback then pcall(callback, default) end 
            end
            
            return {
                Set = function(self, state)
                    if state ~= ToggleState then FireToggle() end
                end
            }
        end
        
        function API:CreateSlider(text, min, max, default, callback)
            local SliderValue = default or min
            SliderValue = math.floor(SliderValue * 10) / 10
            
            local SFrame = Instance.new("Frame")
            SFrame.Size = UDim2.new(1, -20, 0, 36)
            SFrame.Position = UDim2.new(0, 10, 0, 0)
            SFrame.BackgroundTransparency = 1
            SFrame.Parent = ParentFrame
            
            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(0.5, 0, 1, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = Theme.TextMuted
            Lbl.Font = Settings.Font
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = SFrame
            
            local RightContainer = Instance.new("Frame")
            RightContainer.Size = UDim2.new(0.5, 0, 1, 0)
            RightContainer.Position = UDim2.new(0.5, 0, 0, 0)
            RightContainer.BackgroundTransparency = 1
            RightContainer.Parent = SFrame
            
            local ValBoxBG = Instance.new("Frame")
            ValBoxBG.Size = UDim2.new(0, 35, 0, 22)
            ValBoxBG.Position = UDim2.new(1, -35, 0.5, -11)
            ValBoxBG.BackgroundColor3 = Theme.Element
            ValBoxBG.Parent = RightContainer
            AddCorner(ValBoxBG, UDim.new(0, 4))
            AddStroke(ValBoxBG, Theme.Border, 1)

            local ValBox = Instance.new("TextBox")
            ValBox.Size = UDim2.new(1, 0, 1, 0)
            ValBox.BackgroundTransparency = 1
            ValBox.Text = tostring(SliderValue)
            ValBox.TextColor3 = Theme.Text
            ValBox.Font = Settings.Font
            ValBox.TextSize = 12
            ValBox.Parent = ValBoxBG
            
            local SliderBG = Instance.new("Frame")
            SliderBG.Size = UDim2.new(1, -45, 0, 4)
            SliderBG.Position = UDim2.new(0, 0, 0.5, -2)
            SliderBG.BackgroundColor3 = Theme.Element
            SliderBG.Parent = RightContainer
            AddCorner(SliderBG, Settings.PillRadius)
            
            local SliderFill = Instance.new("Frame")
            local startScale = math.clamp((SliderValue - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(startScale, 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Accent
            SliderFill.Parent = SliderBG
            AddCorner(SliderFill, Settings.PillRadius)
            
            local Thumb = Instance.new("Frame")
            Thumb.Size = UDim2.new(0, 12, 0, 12)
            Thumb.Position = UDim2.new(startScale, -6, 0.5, -6)
            Thumb.BackgroundColor3 = Theme.Text
            Thumb.Parent = SliderBG
            AddCorner(Thumb, Settings.PillRadius)

            local SliderBtn = Instance.new("TextButton")
            SliderBtn.Size = UDim2.new(1, 0, 1, 20)
            SliderBtn.Position = UDim2.new(0, 0, 0.5, -10)
            SliderBtn.BackgroundTransparency = 1
            SliderBtn.Text = ""
            SliderBtn.Parent = SliderBG
            
            local Dragging = false
            
            local function UpdateSliderVisuals()
                local actualPos = math.clamp((SliderValue - min) / (max - min), 0, 1)
                CreateTween(SliderFill, {Size = UDim2.new(actualPos, 0, 1, 0)}, 0.1)
                CreateTween(Thumb, {Position = UDim2.new(actualPos, -6, 0.5, -6)}, 0.1)
                ValBox.Text = tostring(SliderValue)
            end

            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                local rawValue = min + ((max - min) * pos)
                SliderValue = math.floor(rawValue * 10) / 10
                UpdateSliderVisuals()
                if callback then pcall(callback, SliderValue) end
            end
            
            SliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    CreateTween(Thumb, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(Thumb.Position.X.Scale, -8, 0.5, -8)}, 0.15)
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
                        UpdateSliderVisuals()
                        CreateTween(Thumb, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(Thumb.Position.X.Scale, -6, 0.5, -6)}, 0.15)
                    end
                end
            end)
            
            ValBox.FocusLost:Connect(function()
                local num = tonumber(ValBox.Text)
                if num then
                    num = math.clamp(num, min, max)
                    SliderValue = math.floor(num * 10) / 10
                    UpdateSliderVisuals()
                    if callback then pcall(callback, SliderValue) end
                else
                    ValBox.Text = tostring(SliderValue)
                end
            end)
            
            if default and callback then pcall(callback, default) end
        end

        function API:CreateDropdown(text, options, default, callback)
            local CurrentSelection = default or options[1]
            local DropdownOpen = false

            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, -20, 0, 36)
            DropFrame.Position = UDim2.new(0, 10, 0, 0)
            DropFrame.BackgroundTransparency = 1
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = ParentFrame

            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(1, 0, 0, 36)
            DropBtn.BackgroundTransparency = 1
            DropBtn.Text = ""
            DropBtn.Parent = DropFrame

            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(0.5, -20, 1, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = Theme.TextMuted
            Lbl.Font = Settings.Font
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = DropBtn

            local SelectedBox = Instance.new("Frame")
            SelectedBox.Size = UDim2.new(0.4, 0, 0, 26)
            SelectedBox.Position = UDim2.new(0.6, 0, 0.5, -13)
            SelectedBox.BackgroundColor3 = Theme.Element
            SelectedBox.Parent = DropBtn
            AddCorner(SelectedBox, UDim.new(0, 4))
            local SelStroke = AddStroke(SelectedBox, Theme.Border, 1)
            
            local SelectedLbl = Instance.new("TextLabel")
            SelectedLbl.Size = UDim2.new(1, -25, 1, 0)
            SelectedLbl.Position = UDim2.new(0, 5, 0, 0)
            SelectedLbl.BackgroundTransparency = 1
            SelectedLbl.Text = CurrentSelection or "Select Options"
            SelectedLbl.TextColor3 = Theme.TextMuted
            SelectedLbl.Font = Settings.Font
            SelectedLbl.TextSize = 12
            SelectedLbl.TextXAlignment = Enum.TextXAlignment.Left
            SelectedLbl.Parent = SelectedBox

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 20, 1, 0)
            Arrow.Position = UDim2.new(1, -20, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = Theme.TextMuted
            Arrow.Font = Enum.Font.Gotham
            Arrow.TextSize = 10
            Arrow.Parent = SelectedBox

            local OptionContainer = Instance.new("ScrollingFrame")
            OptionContainer.Size = UDim2.new(0.4, 0, 0, 0)
            OptionContainer.Position = UDim2.new(0.6, 0, 0, 36)
            OptionContainer.BackgroundColor3 = Theme.Element
            OptionContainer.BorderSizePixel = 0
            OptionContainer.ScrollBarThickness = 2
            OptionContainer.Parent = DropFrame
            AddCorner(OptionContainer, UDim.new(0,4))
            AddStroke(OptionContainer, Theme.Border, 1)
            
            local OptLayout = Instance.new("UIListLayout")
            OptLayout.Parent = OptionContainer

            local function RefreshOptions()
                for _, child in ipairs(OptionContainer:GetChildren()) do
                    if not child:IsA("UIListLayout") then child:Destroy() end
                end
                
                local totalHeight = 0
                for _, opt in ipairs(options) do
                    local OBtn = Instance.new("TextButton")
                    OBtn.Size = UDim2.new(1, 0, 0, 26)
                    OBtn.BackgroundColor3 = Theme.ElementHover
                    OBtn.BackgroundTransparency = 1
                    OBtn.Text = "  " .. opt
                    OBtn.TextColor3 = (opt == CurrentSelection) and Theme.Accent or Theme.TextMuted
                    OBtn.Font = Settings.Font
                    OBtn.TextSize = 12
                    OBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OBtn.Parent = OptionContainer
                    
                    totalHeight = totalHeight + 26

                    OBtn.MouseEnter:Connect(function() CreateTween(OBtn, {BackgroundTransparency=0}, 0.2) end)
                    OBtn.MouseLeave:Connect(function() CreateTween(OBtn, {BackgroundTransparency=1}, 0.2) end)

                    OBtn.MouseButton1Click:Connect(function()
                        CurrentSelection = opt
                        SelectedLbl.Text = opt
                        SelectedLbl.TextColor3 = Theme.Text
                        DropdownOpen = false
                        CreateTween(DropFrame, {Size = UDim2.new(1, -20, 0, 36)}, 0.3)
                        CreateTween(Arrow, {Rotation = 0}, 0.3)
                        CreateTween(SelStroke, {Color = Theme.Border}, 0.3)
                        RefreshOptions()
                        if callback then pcall(callback, opt) end
                    end)
                end
                OptionContainer.Size = UDim2.new(0.4, 0, 0, math.min(totalHeight, 120))
                OptionContainer.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
                
                if DropdownOpen then
                    CreateTween(DropFrame, {Size = UDim2.new(1, -20, 0, 36 + OptionContainer.Size.Y.Offset + 5)}, 0.3)
                end
            end
            
            DropBtn.MouseButton1Click:Connect(function()
                DropdownOpen = not DropdownOpen
                if DropdownOpen then
                    CreateTween(DropFrame, {Size = UDim2.new(1, -20, 0, 36 + OptionContainer.Size.Y.Offset + 5)}, 0.3)
                    CreateTween(Arrow, {Rotation = 180}, 0.3)
                    CreateTween(SelStroke, {Color = Theme.Accent}, 0.3)
                else
                    CreateTween(DropFrame, {Size = UDim2.new(1, -20, 0, 36)}, 0.3)
                    CreateTween(Arrow, {Rotation = 0}, 0.3)
                    CreateTween(SelStroke, {Color = Theme.Border}, 0.3)
                end
            end)

            RefreshOptions()
            if default then 
                SelectedLbl.TextColor3 = Theme.Text
                if callback then pcall(callback, default) end 
            end
        end

        return API
    end

    function WindowAPI:CreateTab(tabName, iconId)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName
        TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        TabBtn.BackgroundColor3 = Theme.Element
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabList
        AddCorner(TabBtn, UDim.new(0, 6))

        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(0, 20, 1, 0)
        Icon.Position = UDim2.new(0, 15, 0, 0)
        Icon.BackgroundTransparency = 1
        Icon.Text = iconId or "◈"
        Icon.TextColor3 = Theme.TextMuted
        Icon.Font = Settings.TitleFont
        Icon.TextSize = 14
        Icon.Parent = TabBtn

        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -45, 1, 0)
        Lbl.Position = UDim2.new(0, 40, 0, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = tabName
        Lbl.TextColor3 = Theme.TextMuted
        Lbl.Font = Settings.Font
        Lbl.TextSize = 13
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, -70)
        Page.Position = UDim2.new(0, 0, 0, 70)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 0
        Page.Visible = false
        Page.Parent = PageContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        local function ActivateTab()
            if WindowState.CurrentTab == tabName then return end
            for name, data in pairs(WindowState.Tabs) do
                CreateTween(data.Btn, {BackgroundTransparency = 1}, 0.3)
                CreateTween(data.Icon, {TextColor3 = Theme.TextMuted}, 0.3)
                CreateTween(data.Lbl, {TextColor3 = Theme.TextMuted}, 0.3)
                data.Page.Visible = false
            end
            WindowState.CurrentTab = tabName
            ContentTitle.Text = tabName
            CreateTween(TabBtn, {BackgroundTransparency = 0}, 0.3)
            CreateTween(Icon, {TextColor3 = Theme.Text}, 0.3)
            CreateTween(Lbl, {TextColor3 = Theme.Text}, 0.3)
            Page.Visible = true
            Page.CanvasPosition = Vector2.new(0,0)
        end

        TabBtn.MouseButton1Click:Connect(ActivateTab)

        TabBtn.MouseEnter:Connect(function()
            if WindowState.CurrentTab ~= tabName then
                CreateTween(Icon, {TextColor3 = Theme.Text}, 0.2)
                CreateTween(Lbl, {TextColor3 = Theme.Text}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowState.CurrentTab ~= tabName then
                CreateTween(Icon, {TextColor3 = Theme.TextMuted}, 0.2)
                CreateTween(Lbl, {TextColor3 = Theme.TextMuted}, 0.2)
            end
        end)

        WindowState.Tabs[tabName] = {Btn = TabBtn, Icon = Icon, Lbl = Lbl, Page = Page}
        if WindowState.CurrentTab == nil then ActivateTab() end

        local TabAPI = CreateComponentAPI(Page)

        function TabAPI:Clear()
            for _, child in ipairs(Page:GetChildren()) do
                if not child:IsA("UIListLayout") then child:Destroy() end
            end
        end

        function TabAPI:CreateAccordion(accordionName, iconStr)
            local AccOpen = false

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
            AccIcon.Position = UDim2.new(0, 20, 0, 0)
            AccIcon.BackgroundTransparency = 1
            AccIcon.Text = iconStr or "❖"
            AccIcon.TextColor3 = Theme.Accent
            AccIcon.Font = Settings.TitleFont
            AccIcon.TextSize = 14
            AccIcon.Parent = AccBtn

            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(1, -60, 1, 0)
            Lbl.Position = UDim2.new(0, 55, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = accordionName
            Lbl.TextColor3 = Theme.Text
            Lbl.Font = Settings.TitleFont
            Lbl.TextSize = 14
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = AccBtn

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 20, 1, 0)
            Arrow.Position = UDim2.new(1, -40, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "›"
            Arrow.TextColor3 = Theme.TextMuted
            Arrow.Font = Settings.TitleFont
            Arrow.TextSize = 20
            Arrow.Parent = AccBtn

            local ContentFrame = Instance.new("Frame")
            ContentFrame.Size = UDim2.new(1, 0, 0, 0)
            ContentFrame.Position = UDim2.new(0, 0, 0, 45)
            ContentFrame.BackgroundTransparency = 1
            ContentFrame.Parent = AccFrame
            
            local CLayout = Instance.new("UIListLayout")
            CLayout.Parent = ContentFrame

            local function UpdateAccordionSize()
                if AccOpen then
                    CreateTween(AccFrame, {Size = UDim2.new(1, 0, 0, 45 + CLayout.AbsoluteContentSize.Y)}, 0.3)
                else
                    CreateTween(AccFrame, {Size = UDim2.new(1, 0, 0, 45)}, 0.3)
                end
            end

            CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateAccordionSize)

            AccBtn.MouseButton1Click:Connect(function()
                AccOpen = not AccOpen
                if AccOpen then
                    CreateTween(Arrow, {Rotation = 90}, 0.3)
                else
                    CreateTween(Arrow, {Rotation = 0}, 0.3)
                end
                UpdateAccordionSize()
            end)

            local AccAPI = CreateComponentAPI(ContentFrame)
            
            function AccAPI:Clear()
                for _, child in ipairs(ContentFrame:GetChildren()) do
                    if not child:IsA("UIListLayout") then child:Destroy() end
                end
            end
            
            return AccAPI
        end

        return TabAPI
    end

    function WindowAPI:Notify(title, desc, duration)
        duration = duration or 3
        
        local NotifContainer = ScreenGui:FindFirstChild("NotifContainer")
        if not NotifContainer then
            NotifContainer = Instance.new("Frame")
            NotifContainer.Name = "NotifContainer"
            NotifContainer.Size = UDim2.new(0, 280, 1, -20)
            NotifContainer.Position = UDim2.new(1, -300, 0, 10)
            NotifContainer.BackgroundTransparency = 1
            NotifContainer.Parent = ScreenGui
            
            local UIList = Instance.new("UIListLayout")
            UIList.Padding = UDim.new(0, 12)
            UIList.VerticalAlignment = Enum.VerticalAlignment.Bottom
            UIList.Parent = NotifContainer
        end
        
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.new(1, 0, 0, 75)
        NotifFrame.BackgroundColor3 = Theme.Element
        NotifFrame.BackgroundTransparency = 1
        NotifFrame.Position = UDim2.new(1, 50, 0, 0)
        NotifFrame.Parent = NotifContainer
        AddCorner(NotifFrame, Settings.CornerRadius)
        
        local Stroke = AddStroke(NotifFrame, Theme.Border, 1)
        Stroke.Transparency = 1
        
        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(0, 4, 1, -24)
        Line.Position = UDim2.new(0, 12, 0.5, 0)
        Line.AnchorPoint = Vector2.new(0, 0.5)
        Line.BackgroundColor3 = Theme.Accent
        Line.BackgroundTransparency = 1
        Line.Parent = NotifFrame
        AddCorner(Line, Settings.PillRadius)
        
        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -40, 0, 20)
        TitleLbl.Position = UDim2.new(0, 26, 0, 14)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Theme.Text
        TitleLbl.TextTransparency = 1
        TitleLbl.Font = Settings.TitleFont
        TitleLbl.TextSize = 14
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.Parent = NotifFrame
        
        local DescLbl = Instance.new("TextLabel")
        DescLbl.Size = UDim2.new(1, -40, 0, 20)
        DescLbl.Position = UDim2.new(0, 26, 0, 36)
        DescLbl.BackgroundTransparency = 1
        DescLbl.Text = desc
        DescLbl.TextColor3 = Theme.TextMuted
        DescLbl.TextTransparency = 1
        DescLbl.Font = Settings.Font
        DescLbl.TextSize = 13
        DescLbl.TextXAlignment = Enum.TextXAlignment.Left
        DescLbl.TextWrapped = true
        DescLbl.Parent = NotifFrame
        
        CreateTween(NotifFrame, {BackgroundTransparency = 0, Position = UDim2.new(0,0,0,0)}, 0.4, Enum.EasingStyle.Back)
        CreateTween(Stroke, {Transparency = 0}, 0.4)
        CreateTween(Line, {BackgroundTransparency = 0}, 0.4)
        CreateTween(TitleLbl, {TextTransparency = 0}, 0.4)
        CreateTween(DescLbl, {TextTransparency = 0}, 0.4)
        
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
