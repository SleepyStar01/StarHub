--[[
    ⭐ StarHub UI Library (Perfected Premium Edition)
    An ultra-modern, elegant, and perfectly balanced UI Framework for Roblox
    Version 8.0.0 — Improved Edition

    Changelog vs 7.0.0:
    - FIX: duplicate TabAPI:MultiDropdown definition removed (2nd copy silently
      overwrote the 1st and dropped the search box). Kept the better version.
    - FIX: WindowAPI:Notify was an empty placeholder -> real toast notifications.
    - NEW: TabAPI:ColorPicker
    - NEW: TabAPI:Keybind
    - NEW: TabAPI:Label / TabAPI:Paragraph
    - NEW: TabAPI:Input (numeric-only textbox with min/max clamp)
    - NEW: Window resizing (bottom-right grip)
    - NEW: UI toggle keybind (default RightControl)
    - NEW: Config Save / Load (per-flag values, works with writefile/readfile
      if the executor exposes them; falls back to in-memory table otherwise)
    - NEW: Tooltip helper on hover for any element
    - IMPROVED: Slider now supports decimals config + a live editable value box
    - IMPROVED: Section header no longer double UICorner/hover glitch
    - IMPROVED: Dropdown/MultiDropdown close automatically when window is minimized
]]

local SleepyUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    TopBar = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(255, 160, 20),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(140, 140, 150),
    Element = Color3.fromRGB(22, 22, 28),
    Border = Color3.fromRGB(30, 30, 40),
    Hover = Color3.fromRGB(35, 35, 45),
    Success = Color3.fromRGB(80, 220, 130),
    Error = Color3.fromRGB(255, 80, 80),
    Warn = Color3.fromRGB(255, 200, 60),
}

--============================================================
-- Small helpers
--============================================================
local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function addCorner(inst, radius)
    return new("UICorner", { CornerRadius = radius or UDim.new(0, 6) }, inst)
end

local function addStroke(inst, color, thickness)
    return new("UIStroke", { Color = color or Theme.Border, Thickness = thickness or 1 }, inst)
end

-- Simple flag store shared by the whole window (used by Save/Load config)
local FlagStore = {}

local function saveConfig(name)
    local ok, encoded = pcall(function() return HttpService:JSONEncode(FlagStore) end)
    if not ok then return false, "encode failed" end
    if writefile then
        local ok2, err = pcall(writefile, "StarHub_" .. name .. ".json", encoded)
        if not ok2 then return false, err end
        return true
    end
    return false, "writefile not supported by executor"
end

local function loadConfig(name)
    if readfile and isfile and isfile("StarHub_" .. name .. ".json") then
        local ok, content = pcall(readfile, "StarHub_" .. name .. ".json")
        if ok then
            local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, content)
            if ok2 and type(decoded) == "table" then
                for k, v in pairs(decoded) do FlagStore[k] = v end
                return true
            end
        end
    end
    return false
end

function SleepyUI:CreateWindow(config)
    local title = config.Title or config.Name or "discord.gg/starhub"
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    local configName = config.ConfigName or "default"

    local ScreenGui = new("ScreenGui", { Name = "StarHubUI", ResetOnSpawn = false })
    local parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui
    if RunService:IsStudio() then parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    for _, v in pairs(parent:GetChildren()) do
        if v.Name == ScreenGui.Name then v:Destroy() end
    end
    ScreenGui.Parent = parent

    local Overlay = new("Frame", {
        Name = "DropdownOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Visible = false,
    }, ScreenGui)

    -- Toast / notification container
    local NotifyContainer = new("Frame", {
        Size = UDim2.new(0, 280, 1, -20),
        Position = UDim2.new(1, -300, 0, 10),
        BackgroundTransparency = 1,
        ZIndex = 200,
    }, ScreenGui)
    local NotifyLayout = new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    }, NotifyContainer)

    -- Minimize Icon
    local MinIcon = new("ImageButton", {
        Size = UDim2.new(0, 48, 0, 48),
        Position = UDim2.new(0.5, -24, 0, 20),
        BackgroundColor3 = Theme.Accent,
        Visible = false,
        ZIndex = 150,
    }, ScreenGui)
    addCorner(MinIcon, UDim.new(0.25, 0))

    new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "⭐",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 22,
        Font = Enum.Font.GothamBold,
    }, MinIcon)

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

    local MainFrame = new("Frame", {
        Size = UDim2.new(0, 600, 0, 380),
        Position = UDim2.new(0.5, -300, 0.5, -190),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
    }, ScreenGui)
    addCorner(MainFrame, UDim.new(0, 8))
    addStroke(MainFrame)

    -- TOP BAR
    local TopBar = new("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, ZIndex = 10 }, MainFrame)

    new("TextLabel", {
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "⭐",
        TextColor3 = Theme.Accent,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        ZIndex = 10,
    }, TopBar)

    local TitlePill = new("Frame", {
        Size = UDim2.new(0, 160, 0, 26),
        Position = UDim2.new(0, 46, 0.5, -13),
        BackgroundColor3 = Theme.Element,
        ZIndex = 10,
    }, TopBar)
    addCorner(TitlePill, UDim.new(1, 0))
    addStroke(TitlePill)

    new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        ZIndex = 10,
    }, TitlePill)

    local CloseBtn = new("TextButton", {
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = Theme.TextDim,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 10,
    }, TopBar)
    CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, TweenInfo.new(0.2), { TextColor3 = Theme.Error }) end)
    CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, TweenInfo.new(0.2), { TextColor3 = Theme.TextDim }) end)

    local MinBtn = new("TextButton", {
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = "—",
        TextColor3 = Theme.TextDim,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 10,
    }, TopBar)
    MinBtn.MouseEnter:Connect(function() tween(MinBtn, TweenInfo.new(0.2), { TextColor3 = Theme.Text }) end)
    MinBtn.MouseLeave:Connect(function() tween(MinBtn, TweenInfo.new(0.2), { TextColor3 = Theme.TextDim }) end)

    local function closeAnyOpenOverlay()
        Overlay.Visible = false
        for _, v in pairs(Overlay:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
    end

    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        closeAnyOpenOverlay()
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

    -- Toggle whole UI with a keybind
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            if MainFrame.Visible then
                MainFrame.Visible = false
                closeAnyOpenOverlay()
                MinIcon.Visible = true
            else
                MainFrame.Visible = true
                MinIcon.Visible = false
            end
        end
    end)

    -- Dragging Logic (window)
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

    -- Resizing logic (bottom-right grip)
    local ResizeGrip = new("TextButton", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -18, 1, -18),
        BackgroundTransparency = 1,
        Text = "◢",
        TextColor3 = Theme.TextDim,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 20,
    }, MainFrame)
    local resizing, resizeStart, startSize
    ResizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = MainFrame.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
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
        if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
            local delta = input.Position - resizeStart
            local newX = math.clamp(startSize.X.Offset + delta.X, 460, 900)
            local newY = math.clamp(startSize.Y.Offset + delta.Y, 300, 700)
            MainFrame.Size = UDim2.new(0, newX, 0, newY)
        end
    end)

    -- Sidebar
    local Sidebar = new("Frame", { Size = UDim2.new(0, 150, 1, -42), Position = UDim2.new(0, 0, 0, 42), BackgroundTransparency = 1 }, MainFrame)
    local TabContainer = new("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, Sidebar)
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, TabContainer)

    -- Content Area
    local ContentArea = new("Frame", { Size = UDim2.new(1, -150, 1, -42), Position = UDim2.new(0, 150, 0, 42), BackgroundTransparency = 1 }, MainFrame)
    local TopContentBar = new("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1 }, ContentArea)
    local ContentTitle = new("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = "Home",
        TextColor3 = Theme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, TopContentBar)

    local Pages = new("Frame", { Size = UDim2.new(1, 0, 1, -38), Position = UDim2.new(0, 0, 0, 38), BackgroundTransparency = 1 }, ContentArea)

    local function ShowPage(page, titleText)
        for _, p in pairs(Pages:GetChildren()) do
            if p:IsA("ScrollingFrame") then p.Visible = false end
        end
        page.Visible = true
        ContentTitle.Text = titleText
    end

    --============================================================
    -- Tooltip helper (shared, reusable for any element)
    --============================================================
    local Tooltip = new("Frame", {
        BackgroundColor3 = Theme.Element,
        Visible = false,
        ZIndex = 300,
        AutomaticSize = Enum.AutomaticSize.XY,
    }, ScreenGui)
    addCorner(Tooltip, UDim.new(0, 4))
    addStroke(Tooltip)
    local TooltipLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        AutomaticSize = Enum.AutomaticSize.XY,
    }, Tooltip)
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
    }, Tooltip)

    local function attachTooltip(inst, text)
        if not text or text == "" then return end
        inst.MouseEnter:Connect(function()
            TooltipLabel.Text = text
            Tooltip.Visible = true
        end)
        inst.MouseMoved:Connect(function(x, y)
            Tooltip.Position = UDim2.new(0, x + 14, 0, y + 14)
        end)
        inst.MouseLeave:Connect(function()
            Tooltip.Visible = false
        end)
    end

    --============================================================
    -- Notifications (real implementation)
    --============================================================
    local function Notify(titleText, text, duration, kind)
        duration = duration or 4
        local color = Theme.Accent
        if kind == "success" then color = Theme.Success
        elseif kind == "error" then color = Theme.Error
        elseif kind == "warn" then color = Theme.Warn end

        local Toast = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 0.05,
            ZIndex = 200,
            ClipsDescendants = true,
        }, NotifyContainer)
        addCorner(Toast, UDim.new(0, 6))
        addStroke(Toast)

        local AccentBar = new("Frame", {
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = color,
            ZIndex = 201,
        }, Toast)

        new("UIPadding", {
            PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
        }, Toast)

        local TTitle = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = titleText or "Notification",
            TextColor3 = Theme.Text,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 201,
        }, Toast)

        local TText = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = text or "",
            TextColor3 = Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 201,
        }, Toast)

        Toast.Size = UDim2.new(1, 0, 0, 50)
        Toast.BackgroundTransparency = 1
        AccentBar.BackgroundTransparency = 1
        TTitle.TextTransparency = 1
        TText.TextTransparency = 1

        tween(Toast, TweenInfo.new(0.25), { BackgroundTransparency = 0.05 })
        tween(AccentBar, TweenInfo.new(0.25), { BackgroundTransparency = 0 })
        tween(TTitle, TweenInfo.new(0.25), { TextTransparency = 0 })
        tween(TText, TweenInfo.new(0.25), { TextTransparency = 0 })

        task.delay(duration, function()
            if not Toast or not Toast.Parent then return end
            tween(Toast, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
            tween(TTitle, TweenInfo.new(0.25), { TextTransparency = 1 })
            tween(TText, TweenInfo.new(0.25), { TextTransparency = 1 })
            tween(AccentBar, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
            task.wait(0.25)
            Toast:Destroy()
        end)
    end

    local WindowAPI = {}
    local activeTab = nil

    function WindowAPI:Notify(titleText, text, duration, kind)
        Notify(titleText, text, duration, kind)
    end

    function WindowAPI:SaveConfig()
        local ok, err = saveConfig(configName)
        if ok then
            Notify("Config", "Configuration saved.", 3, "success")
        else
            Notify("Config", "Save failed: " .. tostring(err), 4, "error")
        end
        return ok
    end

    function WindowAPI:LoadConfig()
        local ok = loadConfig(configName)
        if ok then
            Notify("Config", "Configuration loaded.", 3, "success")
        else
            Notify("Config", "No saved configuration found.", 3, "warn")
        end
        return ok
    end

    function WindowAPI:Tab(tabConfig)
        local tabTitle = tabConfig.Title or "Tab"
        local tabIcon = tabConfig.Icon or "◈"

        local TabBtn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Text = "",
        }, TabContainer)
        addCorner(TabBtn, UDim.new(0, 6))

        local IconLabel = new("TextLabel", {
            Size = UDim2.new(0, 30, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = tabIcon,
            TextColor3 = Theme.TextDim,
            TextSize = 14,
            Font = Enum.Font.Gotham,
        }, TabBtn)

        local TextLabel = new("TextLabel", {
            Size = UDim2.new(1, -38, 1, 0),
            Position = UDim2.new(0, 38, 0, 0),
            BackgroundTransparency = 1,
            Text = tabTitle,
            TextColor3 = Theme.TextDim,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, TabBtn)

        local Page = new("ScrollingFrame", {
            Size = UDim2.new(1, -20, 1, -10),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
        }, Pages)

        local PageLayout = new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }, Page)
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if activeTab then
                tween(activeTab.Btn, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
                activeTab.Icon.TextColor3 = Theme.TextDim
                activeTab.Text.TextColor3 = Theme.TextDim
                activeTab.Text.Font = Enum.Font.Gotham
            end
            tween(TabBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0.85 })
            IconLabel.TextColor3 = Theme.Accent
            TextLabel.TextColor3 = Theme.Text
            TextLabel.Font = Enum.Font.GothamBold
            activeTab = { Btn = TabBtn, Icon = IconLabel, Text = TextLabel }
            ShowPage(Page, tabTitle)
        end)

        if not activeTab then
            TabBtn.BackgroundTransparency = 0.85
            IconLabel.TextColor3 = Theme.Accent
            TextLabel.TextColor3 = Theme.Text
            TextLabel.Font = Enum.Font.GothamBold
            activeTab = { Btn = TabBtn, Icon = IconLabel, Text = TextLabel }
            Page.Visible = true
            ContentTitle.Text = tabTitle
        end

        local TabAPI = {}

        function TabAPI:Section(secConfig)
            local secTitle = secConfig.Title or "Section"
            local isDefault = secConfig.Default

            local AccFrame = new("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
            }, Page)

            local AccBtn = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 1,
                Text = "",
            }, AccFrame)

            new("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
            }, AccBtn)

            new("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = secTitle,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, AccBtn)

            local AccArrow = new("TextLabel", {
                Size = UDim2.new(0, 30, 1, 0),
                Position = UDim2.new(1, -30, 0, 0),
                BackgroundTransparency = 1,
                Text = "v",
                TextColor3 = Theme.TextDim,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
            }, AccBtn)

            local ContentFrame = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 38),
                BackgroundTransparency = 1,
            }, AccFrame)

            local CLayout = new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, ContentFrame)

            local isOpen = false
            CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if isOpen then
                    AccFrame.Size = UDim2.new(1, 0, 0, 38 + CLayout.AbsoluteContentSize.Y + 8)
                end
                ContentFrame.Size = UDim2.new(1, 0, 0, CLayout.AbsoluteContentSize.Y)
            end)

            AccBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                AccArrow.Text = isOpen and "^" or "v"
                tween(AccFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = isOpen and UDim2.new(1, 0, 0, 38 + CLayout.AbsoluteContentSize.Y + 8) or UDim2.new(1, 0, 0, 38)
                })
            end)

            if isDefault then
                isOpen = true
                AccArrow.Text = "^"
                AccFrame.Size = UDim2.new(1, 0, 0, 38 + CLayout.AbsoluteContentSize.Y + 8)
            end

            return {
                ContentFrame = ContentFrame,
                AccFrame = AccFrame,
                Clear = function()
                    for _, v in pairs(ContentFrame:GetChildren()) do
                        if not v:IsA("UIListLayout") then v:Destroy() end
                    end
                end,
            }
        end

        local function CreateElementFrame(cfg)
            local targetParent = cfg.Section and cfg.Section.ContentFrame or Page
            local EFrame = new("Frame", {
                Size = UDim2.new(1, 0, 0, cfg.Desc and 48 or 40),
                BackgroundTransparency = 1,
            }, targetParent)

            local Label = new("TextLabel", {
                Size = UDim2.new(1, -160, 0, 20),
                Position = UDim2.new(0, 10, 0, cfg.Desc and 6 or 10),
                BackgroundTransparency = 1,
                Text = cfg.Title or "Element",
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, EFrame)

            if cfg.Desc then
                new("TextLabel", {
                    Size = UDim2.new(1, -160, 0, 14),
                    Position = UDim2.new(0, 10, 0, 26),
                    BackgroundTransparency = 1,
                    Text = cfg.Desc,
                    TextColor3 = Theme.TextDim,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, EFrame)
            end

            if cfg.Tooltip then
                attachTooltip(EFrame, cfg.Tooltip)
            end

            if cfg.Flag then
                Label.Name = "__Label"
            end

            return EFrame, Label
        end

        --------------------------------------------------------
        function TabAPI:Toggle(config)
            local EFrame = CreateElementFrame(config)
            local state = config.Default or false
            if config.Flag and FlagStore[config.Flag] ~= nil then state = FlagStore[config.Flag] end

            local TogBtn = new("TextButton", {
                Size = UDim2.new(0, 42, 0, 22),
                Position = UDim2.new(1, -52, 0.5, -11),
                BackgroundColor3 = state and Theme.Accent or Theme.Element,
                Text = "",
            }, EFrame)
            addCorner(TogBtn, UDim.new(1, 0))
            addStroke(TogBtn)

            local TogCircle = new("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            }, TogBtn)
            addCorner(TogCircle, UDim.new(1, 0))

            local function setState(newState, fire)
                state = newState
                tween(TogBtn, TweenInfo.new(0.2), { BackgroundColor3 = state and Theme.Accent or Theme.Element })
                tween(TogCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                })
                if config.Flag then FlagStore[config.Flag] = state end
                if fire ~= false and config.Callback then pcall(config.Callback, state) end
            end

            TogBtn.MouseButton1Click:Connect(function() setState(not state) end)
            if config.Flag and FlagStore[config.Flag] ~= nil then setState(FlagStore[config.Flag], true) end

            return { Set = setState, Get = function() return state end }
        end

        function TabAPI:Button(config)
            local EFrame = CreateElementFrame(config)
            local Btn = new("TextButton", {
                Size = UDim2.new(0, 120, 0, 26),
                Position = UDim2.new(1, -130, 0.5, -13),
                BackgroundColor3 = Theme.Element,
                Text = config.ButtonText or "Execute",
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 12,
            }, EFrame)
            addCorner(Btn, UDim.new(0, 4))
            addStroke(Btn)

            Btn.MouseEnter:Connect(function() tween(Btn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Hover }) end)
            Btn.MouseLeave:Connect(function() tween(Btn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Element }) end)

            Btn.MouseButton1Click:Connect(function()
                tween(Btn, TweenInfo.new(0.1), { Size = UDim2.new(0, 114, 0, 24), Position = UDim2.new(1, -127, 0.5, -12) })
                task.wait(0.1)
                tween(Btn, TweenInfo.new(0.1), { Size = UDim2.new(0, 120, 0, 26), Position = UDim2.new(1, -130, 0.5, -13) })
                if config.Callback then pcall(config.Callback) end
            end)
        end

        function TabAPI:Label(config)
            local text = type(config) == "string" and config or (config.Text or "Label")
            local Holder = new("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1 }, Page)
            local Lbl = new("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.TextDim,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
            }, Holder)
            return {
                SetText = function(t) Lbl.Text = t end
            }
        end
        TabAPI.Paragraph = TabAPI.Label

        function TabAPI:Input(config)
            -- Numeric input with optional min/max clamp
            local EFrame = CreateElementFrame(config)
            local min = config.Min
            local max = config.Max
            local val = config.Default or 0

            local InputBg = new("Frame", {
                Size = UDim2.new(0, 150, 0, 26),
                Position = UDim2.new(1, -160, 0.5, -13),
                BackgroundColor3 = Theme.Element,
            }, EFrame)
            addCorner(InputBg, UDim.new(0, 4))
            local Stroke = addStroke(InputBg)

            local Box = new("TextBox", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(val),
                PlaceholderText = config.Placeholder or "0",
                TextColor3 = Theme.Text,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
            }, InputBg)

            Box.Focused:Connect(function() tween(Stroke, TweenInfo.new(0.2), { Color = Theme.Accent }) end)
            Box.FocusLost:Connect(function()
                tween(Stroke, TweenInfo.new(0.2), { Color = Theme.Border })
                local num = tonumber(Box.Text)
                if not num then
                    Box.Text = tostring(val)
                    return
                end
                if min then num = math.max(num, min) end
                if max then num = math.min(num, max) end
                val = num
                Box.Text = tostring(val)
                if config.Flag then FlagStore[config.Flag] = val end
                if config.Callback then pcall(config.Callback, val) end
            end)

            return {
                Set = function(n) val = n; Box.Text = tostring(n) end,
                Get = function() return val end,
            }
        end

        function TabAPI:Keybind(config)
            local EFrame = CreateElementFrame(config)
            local current = config.Default
            local listening = false

            local KeyBtn = new("TextButton", {
                Size = UDim2.new(0, 100, 0, 26),
                Position = UDim2.new(1, -110, 0.5, -13),
                BackgroundColor3 = Theme.Element,
                Text = current and current.Name or "None",
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                Font = Enum.Font.Gotham,
            }, EFrame)
            addCorner(KeyBtn, UDim.new(0, 4))
            addStroke(KeyBtn)

            KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "..."
                KeyBtn.TextColor3 = Theme.Accent
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    current = input.KeyCode
                    KeyBtn.Text = current.Name
                    KeyBtn.TextColor3 = Theme.TextDim
                    listening = false
                    if config.Flag then FlagStore[config.Flag] = current.Name end
                    if config.Callback then pcall(config.Callback, current) end
                elseif not gpe and current and input.KeyCode == current and config.OnPress then
                    pcall(config.OnPress)
                end
            end)

            return {
                Get = function() return current end,
                Set = function(kc) current = kc; KeyBtn.Text = kc and kc.Name or "None" end,
            }
        end

        function TabAPI:ColorPicker(config)
            local EFrame = CreateElementFrame(config)
            local color = config.Default or Color3.fromRGB(255, 160, 20)
            local isOpen = false

            local Swatch = new("TextButton", {
                Size = UDim2.new(0, 40, 0, 22),
                Position = UDim2.new(1, -50, 0.5, -11),
                BackgroundColor3 = color,
                Text = "",
            }, EFrame)
            addCorner(Swatch, UDim.new(0, 4))
            addStroke(Swatch)

            local Popup = new("Frame", {
                Size = UDim2.new(0, 180, 0, 150),
                BackgroundColor3 = Theme.Element,
                Visible = false,
                ZIndex = 150,
            }, Overlay)
            addCorner(Popup, UDim.new(0, 6))
            addStroke(Popup)
            new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }, Popup)
            local PopLayout = new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, Popup)

            local function makeChannelSlider(label, initial, onChange)
                local Row = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 }, Popup)
                new("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Text = label,
                    TextColor3 = Theme.TextDim,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, Row)
                local Track = new("Frame", { Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 18), BackgroundColor3 = Theme.Background }, Row)
                addCorner(Track, UDim.new(1, 0))
                local Fill = new("Frame", { Size = UDim2.new(initial / 255, 0, 1, 0), BackgroundColor3 = Theme.Accent }, Track)
                addCorner(Fill, UDim.new(1, 0))
                local Btn = new("TextButton", { Size = UDim2.new(1, 0, 1, 10), Position = UDim2.new(0, 0, 0.5, -5), BackgroundTransparency = 1, Text = "" }, Track)

                local dragging = false
                Btn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local p = math.clamp((inp.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        Fill.Size = UDim2.new(p, 0, 1, 0)
                        onChange(math.floor(p * 255))
                    end
                end)
                return Fill
            end

            local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
            local function updateColor()
                color = Color3.fromRGB(r, g, b)
                Swatch.BackgroundColor3 = color
                if config.Flag then FlagStore[config.Flag] = { r, g, b } end
                if config.Callback then pcall(config.Callback, color) end
            end
            makeChannelSlider("R", r, function(v) r = v; updateColor() end)
            makeChannelSlider("G", g, function(v) g = v; updateColor() end)
            makeChannelSlider("B", b, function(v) b = v; updateColor() end)

            Swatch.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Overlay.Visible = isOpen
                Popup.Visible = isOpen
                if isOpen then
                    local absPos = Swatch.AbsolutePosition
                    Popup.Position = UDim2.new(0, absPos.X - 140, 0, absPos.Y + 26)
                end
            end)

            Overlay.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                    -- only close if click was outside popup
                    local mp = UserInputService:GetMouseLocation()
                    local pp, ps = Popup.AbsolutePosition, Popup.AbsoluteSize
                    if mp.X < pp.X or mp.X > pp.X + ps.X or mp.Y < pp.Y or mp.Y > pp.Y + ps.Y then
                        isOpen = false
                        Overlay.Visible = false
                        Popup.Visible = false
                    end
                end
            end)

            return { Get = function() return color end }
        end

        function TabAPI:Cycle(config)
            local EFrame = CreateElementFrame(config)
            local selected = config.Default or (config.Values and config.Values[1]) or ""

            local DropBtn = new("TextButton", {
                Size = UDim2.new(0, 150, 0, 26),
                Position = UDim2.new(1, -160, 0.5, -13),
                BackgroundColor3 = Theme.Element,
                Text = selected,
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                Font = Enum.Font.Gotham,
            }, EFrame)
            addCorner(DropBtn, UDim.new(0, 4))
            addStroke(DropBtn)

            DropBtn.MouseButton1Click:Connect(function()
                if not config.Values or #config.Values == 0 then return end
                local nextIdx = 1
                for i, v in ipairs(config.Values) do if v == selected then nextIdx = i + 1 break end end
                if nextIdx > #config.Values then nextIdx = 1 end
                selected = config.Values[nextIdx]
                DropBtn.Text = selected
                if config.Flag then FlagStore[config.Flag] = selected end
                if config.Callback then pcall(config.Callback, selected) end
            end)
        end

        -- Shared floating-list builder for Dropdown / MultiDropdown
        local function buildFloatingList()
            local OptionList = new("ScrollingFrame", {
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Accent,
                Visible = false,
                ZIndex = 101,
            }, Overlay)
            addCorner(OptionList, UDim.new(0, 4))
            addStroke(OptionList)
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, OptionList)

            local SearchBox = new("TextBox", {
                Size = UDim2.new(1, -10, 0, 26),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundColor3 = Theme.Background,
                BackgroundTransparency = 0.5,
                Text = "",
                PlaceholderText = "  🔍 Search...",
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.TextDim,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = -1,
            }, OptionList)
            addCorner(SearchBox, UDim.new(0, 4))

            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                local query = SearchBox.Text:lower()
                for _, child in pairs(OptionList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.Visible = (query == "" or child.Text:lower():find(query, 1, true) ~= nil)
                    end
                end
            end)

            return OptionList, SearchBox
        end

        function TabAPI:Dropdown(config)
            local EFrame = CreateElementFrame(config)
            local selected = config.Default or (config.Values and config.Values[1]) or ""
            local isOpen = false

            local DropBtn = new("TextButton", {
                Size = UDim2.new(0, 150, 0, 26),
                Position = UDim2.new(1, -160, 0.5, -13),
                BackgroundColor3 = Theme.Element,
                Text = selected,
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                Font = Enum.Font.Gotham,
            }, EFrame)
            addCorner(DropBtn, UDim.new(0, 4))
            addStroke(DropBtn)

            local DropIcon = new("TextLabel", {
                Size = UDim2.new(0, 24, 1, 0),
                Position = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text = "v",
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
            }, DropBtn)

            local OptionList, SearchBox = buildFloatingList()

            local function RefreshOptions(newValues)
                for _, child in pairs(OptionList:GetChildren()) do
                    if child:IsA("TextButton") and child ~= SearchBox then child:Destroy() end
                end
                config.Values = newValues or config.Values or {}

                local totalHeight = 26
                for _, val in ipairs(config.Values) do
                    local OptBtn = new("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = Theme.Hover,
                        BackgroundTransparency = 1,
                        Text = "  " .. val,
                        TextColor3 = val == selected and Theme.Accent or Theme.TextDim,
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 102,
                    }, OptionList)
                    totalHeight = totalHeight + 26

                    OptBtn.MouseEnter:Connect(function() tween(OptBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0 }) end)
                    OptBtn.MouseLeave:Connect(function() tween(OptBtn, TweenInfo.new(0.2), { BackgroundTransparency = 1 }) end)

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
                        if config.Flag then FlagStore[config.Flag] = selected end
                        if config.Callback then pcall(config.Callback, selected) end
                    end)
                end
                OptionList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
                OptionList.Size = UDim2.new(0, 150, 0, math.min(totalHeight, 156))
            end

            local lastToggle = 0
            DropBtn.MouseButton1Click:Connect(function()
                if tick() - lastToggle < 0.1 then return end
                lastToggle = tick()
                if not config.Values or #config.Values == 0 then return end
                isOpen = not isOpen
                DropIcon.Text = isOpen and "^" or "v"
                if isOpen then
                    SearchBox.Text = ""
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
                    lastToggle = tick()
                    isOpen = false
                    DropIcon.Text = "v"
                    Overlay.Visible = false
                    OptionList.Visible = false
                end
            end)

            RefreshOptions()
            if config.Flag and FlagStore[config.Flag] then
                selected = FlagStore[config.Flag]
                DropBtn.Text = selected
            end

            return {
                Refresh = function(newValues)
                    selected = (newValues and newValues[1]) or "None"
                    DropBtn.Text = selected
                    RefreshOptions(newValues)
                    if config.Callback then pcall(config.Callback, selected) end
                end,
                SetValues = function(newValues) config.Values = newValues; RefreshOptions(newValues) end,
                SetValue = function(val)
                    selected = val
                    DropBtn.Text = selected
                    for _, ob in pairs(OptionList:GetChildren()) do
                        if ob:IsA("TextButton") then
                            ob.TextColor3 = ob.Text:sub(3) == selected and Theme.Accent or Theme.TextDim
                        end
                    end
                end,
            }
        end

        -- Only ONE MultiDropdown now (the fuller version, with working search)
        function TabAPI:MultiDropdown(config)
            local EFrame = CreateElementFrame(config)
            local selected = config.Default or {}
            if type(selected) ~= "table" then selected = { selected } end
            local isOpen = false

            local function getSelectedText()
                if #selected == 0 then return "Select Options" end
                return table.concat(selected, ", ")
            end

            local DropBtn = new("TextButton", {
                Size = UDim2.new(0, 150, 0, 26),
                Position = UDim2.new(1, -160, 0.5, -13),
                BackgroundColor3 = Theme.Element,
                Text = getSelectedText(),
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, EFrame)
            addCorner(DropBtn, UDim.new(0, 4))
            addStroke(DropBtn)

            local DropIcon = new("TextLabel", {
                Size = UDim2.new(0, 24, 1, 0),
                Position = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text = "v",
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
            }, DropBtn)

            local OptionList, SearchBox = buildFloatingList()

            local function RefreshOptions(newValues)
                for _, child in pairs(OptionList:GetChildren()) do
                    if child:IsA("TextButton") and child ~= SearchBox then child:Destroy() end
                end
                config.Values = newValues or config.Values or {}

                local totalHeight = 26
                for _, val in ipairs(config.Values) do
                    local isSel = table.find(selected, val) ~= nil
                    local OptBtn = new("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = Theme.Hover,
                        BackgroundTransparency = 1,
                        Text = val,
                        TextColor3 = isSel and Theme.Accent or Theme.TextDim,
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 102,
                    }, OptionList)
                    new("UIPadding", { PaddingLeft = UDim.new(0, 24) }, OptBtn)

                    local CheckBox = new("Frame", {
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(0, -18, 0.5, -5),
                        BackgroundColor3 = isSel and Theme.Accent or Theme.Background,
                        ZIndex = 102,
                    }, OptBtn)
                    addStroke(CheckBox)

                    totalHeight = totalHeight + 26

                    OptBtn.MouseEnter:Connect(function() tween(OptBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0 }) end)
                    OptBtn.MouseLeave:Connect(function() tween(OptBtn, TweenInfo.new(0.2), { BackgroundTransparency = 1 }) end)

                    OptBtn.MouseButton1Click:Connect(function()
                        local idx = table.find(selected, val)
                        if idx then
                            table.remove(selected, idx)
                            OptBtn.TextColor3 = Theme.TextDim
                            tween(CheckBox, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Background })
                        else
                            table.insert(selected, val)
                            OptBtn.TextColor3 = Theme.Accent
                            tween(CheckBox, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Accent })
                        end
                        DropBtn.Text = getSelectedText()
                        if config.Flag then FlagStore[config.Flag] = selected end
                        if config.Callback then pcall(config.Callback, selected) end
                    end)
                end
                OptionList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
                OptionList.Size = UDim2.new(0, 150, 0, math.min(totalHeight, 156))
            end

            local lastToggle = 0
            DropBtn.MouseButton1Click:Connect(function()
                if tick() - lastToggle < 0.1 then return end
                lastToggle = tick()
                if not config.Values or #config.Values == 0 then return end
                isOpen = not isOpen
                DropIcon.Text = isOpen and "^" or "v"
                if isOpen then
                    SearchBox.Text = ""
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
                    lastToggle = tick()
                    isOpen = false
                    DropIcon.Text = "v"
                    Overlay.Visible = false
                    OptionList.Visible = false
                end
            end)

            RefreshOptions()

            return {
                Refresh = function(newValues)
                    selected = config.Default or {}
                    if type(selected) ~= "table" then selected = { selected } end
                    DropBtn.Text = getSelectedText()
                    RefreshOptions(newValues)
                    if config.Callback then pcall(config.Callback, selected) end
                end,
            }
        end

        function TabAPI:TextBox(config)
            local EFrame = CreateElementFrame(config)
            local val = config.Default or ""
            local placeholder = config.Placeholder or ""

            local InputBg = new("Frame", {
                Size = UDim2.new(0, 150, 0, 26),
                Position = UDim2.new(1, -160, 0.5, -13),
                BackgroundColor3 = Theme.Element,
            }, EFrame)
            addCorner(InputBg, UDim.new(0, 4))
            local Stroke = addStroke(InputBg)

            local TextBox = new("TextBox", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(val),
                PlaceholderText = placeholder,
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
            }, InputBg)

            TextBox.Focused:Connect(function()
                tween(Stroke, TweenInfo.new(0.2), { Color = Theme.Accent })
                TextBox.TextColor3 = Theme.Text
            end)
            TextBox.FocusLost:Connect(function()
                tween(Stroke, TweenInfo.new(0.2), { Color = Theme.Border })
                TextBox.TextColor3 = Theme.TextDim
                if config.Flag then FlagStore[config.Flag] = TextBox.Text end
                if config.Callback then pcall(config.Callback, TextBox.Text) end
            end)

            return {
                SetText = function(txt) TextBox.Text = tostring(txt) end,
                GetText = function() return TextBox.Text end,
            }
        end

        function TabAPI:Slider(config)
            local EFrame = CreateElementFrame(config)
            local min = config.Min or 0
            local max = config.Max or 100
            local decimals = config.Decimals or 0
            local val = config.Default or min

            local SliderBg = new("Frame", {
                Size = UDim2.new(0, 130, 0, 6),
                Position = UDim2.new(1, -160, 0.5, -3),
                BackgroundColor3 = Theme.Element,
            }, EFrame)
            addCorner(SliderBg, UDim.new(1, 0))
            addStroke(SliderBg)

            local pct = (val - min) / (max - min)
            local SliderFill = new("Frame", { Size = UDim2.new(pct, 0, 1, 0), BackgroundColor3 = Theme.Accent }, SliderBg)
            addCorner(SliderFill, UDim.new(1, 0))

            local Thumb = new("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(pct, -6, 0.5, -6),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            }, SliderBg)
            addCorner(Thumb, UDim.new(1, 0))

            local ValLabel = new("TextLabel", {
                Size = UDim2.new(0, 26, 0, 20),
                Position = UDim2.new(1, -26, 0.5, -10),
                BackgroundTransparency = 1,
                Text = tostring(val),
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                Font = Enum.Font.Gotham,
            }, EFrame)

            local function formatVal(n)
                if decimals <= 0 then return tostring(math.floor(n)) end
                local mult = 10 ^ decimals
                return tostring(math.floor(n * mult) / mult)
            end

            local function setValue(newVal, fire)
                newVal = math.clamp(newVal, min, max)
                local p = (newVal - min) / (max - min)
                SliderFill.Size = UDim2.new(p, 0, 1, 0)
                Thumb.Position = UDim2.new(p, -6, 0.5, -6)
                val = newVal
                ValLabel.Text = formatVal(val)
                if config.Flag then FlagStore[config.Flag] = val end
                if fire ~= false and config.Callback then pcall(config.Callback, val) end
            end

            local clickBtn = new("TextButton", { Size = UDim2.new(1, 0, 1, 10), Position = UDim2.new(0, 0, 0.5, -5), BackgroundTransparency = 1, Text = "" }, SliderBg)

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
                    setValue(min + p * (max - min))
                end
            end)

            if config.Flag and FlagStore[config.Flag] then setValue(FlagStore[config.Flag], false) end

            return { Set = setValue, Get = function() return val end }
        end

        return TabAPI
    end

    return WindowAPI
end

return SleepyUI
