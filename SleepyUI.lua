--[[
    ◆ PulseUI — Roblox UI Framework
    Built from scratch. Version 1.0.0 (Final)

    A complete, self-contained UI library with its own visual identity
    ("Indigo Pulse": near-black base + violet -> magenta gradient accent).

    ELEMENTS
      Window : Tab, Notify, SaveConfig, LoadConfig, SetWatermark, Destroy
      Tab    : Section, Divider, Label/Paragraph, Button, Toggle, ToggleGroup,
               Slider, Dropdown, MultiDropdown, TextBox, Input (numeric),
               Keybind, ColorPicker, ProgressBar, Image

    QUICK START (see full example at the very bottom of this file)
        local PulseUI = loadstring(game:HttpGet("...PulseUI.lua"))()
        local Window = PulseUI:CreateWindow({ Title = "My Hub" })
        local Tab = Window:Tab({ Title = "Main", Icon = "◈" })
        Tab:Button({ Title = "Say Hi", Callback = function() print("hi") end })

    NOTES
      - Every element accepts an optional `Flag = "uniqueName"` — its value is
        auto-tracked and restored by Window:SaveConfig() / Window:LoadConfig().
      - Every element accepts an optional `Tooltip = "text"` shown on hover.
      - Every element accepts an optional `Section = sectionHandle` to nest it
        inside a collapsible section returned by Tab:Section(...).
]]

local PulseUI = {}
PulseUI.__index = PulseUI

--============================================================
-- Services
--============================================================
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")

--============================================================
-- Theme — "Indigo Pulse"
-- Change these values to re-skin the entire library.
--============================================================
local Theme = {
    Background      = Color3.fromRGB(8, 9, 14),
    Panel           = Color3.fromRGB(8, 9, 14),
    Element         = Color3.fromRGB(17, 18, 27),
    ElementAlt      = Color3.fromRGB(13, 14, 21),
    Border          = Color3.fromRGB(28, 30, 42),
    Hover           = Color3.fromRGB(24, 26, 37),
    Text            = Color3.fromRGB(236, 236, 245),
    TextDim         = Color3.fromRGB(132, 133, 150),
    AccentA         = Color3.fromRGB(140, 95, 255),   -- violet
    AccentB         = Color3.fromRGB(255, 80, 190),   -- magenta
    Success         = Color3.fromRGB(85, 220, 140),
    Error           = Color3.fromRGB(255, 95, 105),
    Warn            = Color3.fromRGB(255, 195, 70),
}

--============================================================
-- Small helpers
--============================================================
local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function tw(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function corner(inst, radius)
    return new("UICorner", { CornerRadius = radius or UDim.new(0, 6) }, inst)
end

local function stroke(inst, color, thickness)
    return new("UIStroke", { Color = color or Theme.Border, Thickness = thickness or 1 }, inst)
end

local function gradient(inst, rotation, colorA, colorB)
    return new("UIGradient", {
        Color = ColorSequence.new(colorA or Theme.AccentA, colorB or Theme.AccentB),
        Rotation = rotation or 45,
    }, inst)
end

local function padding(inst, l, r, t, b)
    return new("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or l or 0),
        PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or t or 0),
    }, inst)
end

--============================================================
-- Config persistence (per-flag store, JSON to file if supported)
--============================================================
local FlagStore = {}

local function saveConfig(name)
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, FlagStore)
    if not ok then return false, "encode failed" end
    if writefile then
        local ok2, err = pcall(writefile, "PulseUI_" .. name .. ".json", encoded)
        if not ok2 then return false, err end
        return true
    end
    return false, "writefile unsupported"
end

local function loadConfig(name)
    if readfile and isfile and isfile("PulseUI_" .. name .. ".json") then
        local ok, content = pcall(readfile, "PulseUI_" .. name .. ".json")
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

--============================================================
-- CreateWindow
--============================================================
function PulseUI:CreateWindow(config)
    config = config or {}
    local title       = config.Title or "PulseUI"
    local subtitle     = config.SubTitle or config.SubTitle
    local toggleKey    = config.ToggleKey or Enum.KeyCode.RightControl
    local configName   = config.ConfigName or "default"
    local startSize    = config.Size or UDim2.new(0, 620, 0, 400)

    --------------------------------------------------------
    -- Root
    --------------------------------------------------------
    local ScreenGui = new("ScreenGui", { Name = "PulseUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    local parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui
    if RunService:IsStudio() then parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    for _, v in pairs(parent:GetChildren()) do
        if v.Name == ScreenGui.Name then v:Destroy() end
    end
    ScreenGui.Parent = parent

    local Overlay = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 100, Visible = false,
    }, ScreenGui)

    -- Toast container (top-right)
    local ToastHolder = new("Frame", {
        Size = UDim2.new(0, 280, 1, -20), Position = UDim2.new(1, -300, 0, 10),
        BackgroundTransparency = 1, ZIndex = 250,
    }, ScreenGui)
    new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right,
    }, ToastHolder)

    -- Watermark (off by default)
    local Watermark = new("Frame", {
        Size = UDim2.new(0, 0, 0, 26), AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.15, Visible = false, ZIndex = 150,
    }, ScreenGui)
    corner(Watermark, UDim.new(0, 6))
    stroke(Watermark)
    padding(Watermark, 10, 10, 0, 0)
    local WatermarkLabel = new("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text,
        TextSize = 12, Font = Enum.Font.GothamBold, ZIndex = 151,
    }, Watermark)

    -- Minimized floating icon
    local MinIcon = new("ImageButton", {
        Size = UDim2.new(0, 46, 0, 46), Position = UDim2.new(0.5, -23, 0, 20),
        BackgroundColor3 = Theme.AccentA, Visible = false, ZIndex = 150,
    }, ScreenGui)
    corner(MinIcon, UDim.new(0.3, 0))
    gradient(MinIcon, 60)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "◆",
        TextColor3 = Color3.new(1, 1, 1), TextSize = 20, Font = Enum.Font.GothamBold,
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

    --------------------------------------------------------
    -- Main window
    --------------------------------------------------------
    local MainFrame = new("Frame", {
        Size = startSize, Position = UDim2.new(0.5, -startSize.X.Offset / 2, 0.5, -startSize.Y.Offset / 2),
        BackgroundColor3 = Theme.Background, BorderSizePixel = 0, ClipsDescendants = true, Active = true,
    }, ScreenGui)
    corner(MainFrame, UDim.new(0, 12))
    stroke(MainFrame)

    -- Top bar
    local TopBar = new("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, ZIndex = 10 }, MainFrame)

    local LogoBadge = new("Frame", {
        Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, 12, 0.5, -13),
        BackgroundColor3 = Theme.AccentA, ZIndex = 10,
    }, TopBar)
    corner(LogoBadge, UDim.new(0.3, 0))
    gradient(LogoBadge, 60)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "◆",
        TextColor3 = Color3.new(1, 1, 1), TextSize = 13, Font = Enum.Font.GothamBold, ZIndex = 11,
    }, LogoBadge)

    local TitleBlock = new("Frame", { Size = UDim2.new(0, 220, 0, 30), Position = UDim2.new(0, 48, 0.5, -15), BackgroundTransparency = 1, ZIndex = 10 }, TopBar)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = title,
        TextColor3 = Theme.Text, TextSize = 13, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
    }, TitleBlock)
    if subtitle then
        new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 0, 16),
            BackgroundTransparency = 1, Text = subtitle, TextColor3 = Theme.TextDim,
            TextSize = 10, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        }, TitleBlock)
    end

    local CloseBtn = new("TextButton", {
        Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1,
        Text = "✕", TextColor3 = Theme.TextDim, TextSize = 14, Font = Enum.Font.GothamBold, ZIndex = 10,
    }, TopBar)
    CloseBtn.MouseEnter:Connect(function() tw(CloseBtn, TweenInfo.new(0.2), { TextColor3 = Theme.Error }) end)
    CloseBtn.MouseLeave:Connect(function() tw(CloseBtn, TweenInfo.new(0.2), { TextColor3 = Theme.TextDim }) end)

    local MinBtn = new("TextButton", {
        Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -60, 0, 0), BackgroundTransparency = 1,
        Text = "—", TextColor3 = Theme.TextDim, TextSize = 14, Font = Enum.Font.GothamBold, ZIndex = 10,
    }, TopBar)
    MinBtn.MouseEnter:Connect(function() tw(MinBtn, TweenInfo.new(0.2), { TextColor3 = Theme.Text }) end)
    MinBtn.MouseLeave:Connect(function() tw(MinBtn, TweenInfo.new(0.2), { TextColor3 = Theme.TextDim }) end)

    local function closeOverlays()
        Overlay.Visible = false
        for _, v in pairs(Overlay:GetChildren()) do
            if v:IsA("ScrollingFrame") or v:IsA("Frame") then v.Visible = false end
        end
    end

    local function hideWindow()
        MainFrame.Visible = false
        closeOverlays()
        MinIcon.Visible = true
    end
    local function showWindow()
        MainFrame.Visible = true
        MinIcon.Visible = false
    end

    MinBtn.MouseButton1Click:Connect(hideWindow)
    MinIcon.MouseButton1Click:Connect(function() if not dragMin then showWindow() end end)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            if MainFrame.Visible then hideWindow() else showWindow() end
        end
    end)

    -- Window dragging
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

    -- Window resizing
    local ResizeGrip = new("TextButton", {
        Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -18, 1, -18),
        BackgroundTransparency = 1, Text = "◢", TextColor3 = Theme.TextDim,
        TextSize = 14, Font = Enum.Font.GothamBold, ZIndex = 20,
    }, MainFrame)
    local resizing, resizeStart, startSize2
    ResizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize2 = MainFrame.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
        if input == dragMinInput and dragMin then
            local d = input.Position - dragMinStart
            MinIcon.Position = UDim2.new(startMinPos.X.Scale, startMinPos.X.Offset + d.X, startMinPos.Y.Scale, startMinPos.Y.Offset + d.Y)
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
            local d = input.Position - resizeStart
            local nx = math.clamp(startSize2.X.Offset + d.X, 480, 940)
            local ny = math.clamp(startSize2.Y.Offset + d.Y, 320, 720)
            MainFrame.Size = UDim2.new(0, nx, 0, ny)
        end
    end)

    --------------------------------------------------------
    -- Sidebar (search + tab list)
    --------------------------------------------------------
    local Sidebar = new("Frame", { Size = UDim2.new(0, 170, 1, -46), Position = UDim2.new(0, 0, 0, 46), BackgroundTransparency = 1 }, MainFrame)

    local SearchBg = new("Frame", {
        Size = UDim2.new(1, -20, 0, 32), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Theme.Element,
    }, Sidebar)
    corner(SearchBg, UDim.new(0, 8))
    stroke(SearchBg)
    new("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1,
        Text = "🔍", TextSize = 11, Font = Enum.Font.Gotham, TextColor3 = Theme.TextDim,
    }, SearchBg)
    local SearchBox = new("TextBox", {
        Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 28, 0, 0), BackgroundTransparency = 1,
        Text = "", PlaceholderText = "Search", TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextDim,
        TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
    }, SearchBg)

    local TabContainer = new("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -52), Position = UDim2.new(0, 10, 0, 48),
        BackgroundTransparency = 1, ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, Sidebar)
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, TabContainer)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = SearchBox.Text:lower()
        for _, child in pairs(TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                local lbl = child:FindFirstChild("__TabLabel")
                local text = lbl and lbl.Text:lower() or ""
                child.Visible = (q == "" or text:find(q, 1, true) ~= nil)
            end
        end
    end)

    --------------------------------------------------------
    -- Content area
    --------------------------------------------------------
    local ContentArea = new("Frame", { Size = UDim2.new(1, -170, 1, -46), Position = UDim2.new(0, 170, 0, 46), BackgroundTransparency = 1 }, MainFrame)
    local TopContentBar = new("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1 }, ContentArea)
    local ContentTitle = new("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 16, 0, 0), BackgroundTransparency = 1,
        Text = "Home", TextColor3 = Theme.Text, TextSize = 19, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, TopContentBar)

    local Pages = new("Frame", { Size = UDim2.new(1, 0, 1, -38), Position = UDim2.new(0, 0, 0, 38), BackgroundTransparency = 1 }, ContentArea)

    local function showPage(page, titleText)
        for _, p in pairs(Pages:GetChildren()) do
            if p:IsA("ScrollingFrame") then p.Visible = false end
        end
        page.Visible = true
        ContentTitle.Text = titleText
    end

    --------------------------------------------------------
    -- Tooltip (shared)
    --------------------------------------------------------
    local Tooltip = new("Frame", { BackgroundColor3 = Theme.Element, Visible = false, ZIndex = 300, AutomaticSize = Enum.AutomaticSize.XY }, ScreenGui)
    corner(Tooltip, UDim.new(0, 4))
    stroke(Tooltip)
    padding(Tooltip, 8, 8, 4, 4)
    local TooltipLabel = new("TextLabel", {
        BackgroundTransparency = 1, Text = "", TextColor3 = Theme.Text, TextSize = 11,
        Font = Enum.Font.Gotham, AutomaticSize = Enum.AutomaticSize.XY,
    }, Tooltip)

    local function attachTooltip(inst, text)
        if not text or text == "" then return end
        inst.MouseEnter:Connect(function() TooltipLabel.Text = text; Tooltip.Visible = true end)
        inst.MouseMoved:Connect(function(x, y) Tooltip.Position = UDim2.new(0, x + 14, 0, y + 14) end)
        inst.MouseLeave:Connect(function() Tooltip.Visible = false end)
    end

    --------------------------------------------------------
    -- Notifications
    --------------------------------------------------------
    local function notify(titleText, text, duration, kind)
        duration = duration or 4
        local color = Theme.AccentA
        if kind == "success" then color = Theme.Success
        elseif kind == "error" then color = Theme.Error
        elseif kind == "warn" then color = Theme.Warn end

        local Toast = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Background, BackgroundTransparency = 1, ZIndex = 250, ClipsDescendants = true,
        }, ToastHolder)
        corner(Toast, UDim.new(0, 8))
        local st = stroke(Toast)
        local Bar = new("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = color, BackgroundTransparency = 1, ZIndex = 251 }, Toast)
        padding(Toast, 14, 10, 10, 10)

        local TTitle = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = titleText or "Notification",
            TextColor3 = Theme.Text, TextSize = 13, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 251,
        }, Toast)
        local TText = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0, 0, 0, 18),
            BackgroundTransparency = 1, Text = text or "", TextColor3 = Theme.TextDim, TextSize = 11,
            Font = Enum.Font.Gotham, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1, ZIndex = 251,
        }, Toast)

        tw(Toast, TweenInfo.new(0.25), { BackgroundTransparency = 0.05 })
        tw(Bar, TweenInfo.new(0.25), { BackgroundTransparency = 0 })
        tw(TTitle, TweenInfo.new(0.25), { TextTransparency = 0 })
        tw(TText, TweenInfo.new(0.25), { TextTransparency = 0 })

        task.delay(duration, function()
            if not Toast or not Toast.Parent then return end
            tw(Toast, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
            tw(Bar, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
            tw(TTitle, TweenInfo.new(0.25), { TextTransparency = 1 })
            tw(TText, TweenInfo.new(0.25), { TextTransparency = 1 })
            task.wait(0.25)
            Toast:Destroy()
        end)
    end

    --------------------------------------------------------
    -- Window API
    --------------------------------------------------------
    local Window = {}
    local activeTab = nil

    function Window:Notify(t, text, duration, kind) notify(t, text, duration, kind) end

    function Window:SetWatermark(text, visible)
        if text then WatermarkLabel.Text = text end
        if visible ~= nil then Watermark.Visible = visible else Watermark.Visible = true end
    end

    function Window:SaveConfig()
        local ok, err = saveConfig(configName)
        notify("Config", ok and "Configuration saved." or ("Save failed: " .. tostring(err)), 3, ok and "success" or "error")
        return ok
    end

    function Window:LoadConfig()
        local ok = loadConfig(configName)
        notify("Config", ok and "Configuration loaded." or "No saved configuration found.", 3, ok and "success" or "warn")
        return ok
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    --------------------------------------------------------
    -- Tab
    --------------------------------------------------------
    function Window:Tab(tabConfig)
        tabConfig = tabConfig or {}
        local tabTitle = tabConfig.Title or "Tab"
        local tabIcon = tabConfig.Icon or "◈"

        local TabBtn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 1, Text = "", ClipsDescendants = true,
        }, TabContainer)
        corner(TabBtn, UDim.new(0, 7))

        local AccentBar = new("Frame", {
            Size = UDim2.new(0, 3, 0.6, 0), Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Theme.AccentA, BackgroundTransparency = 1,
        }, TabBtn)
        corner(AccentBar, UDim.new(1, 0))
        gradient(AccentBar, 90)

        local IconLabel = new("TextLabel", {
            Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1,
            Text = tabIcon, TextColor3 = Theme.TextDim, TextSize = 14, Font = Enum.Font.Gotham,
        }, TabBtn)

        local TextLabel = new("TextLabel", {
            Name = "__TabLabel", Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 40, 0, 0),
            BackgroundTransparency = 1, Text = tabTitle, TextColor3 = Theme.TextDim, TextSize = 12,
            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        }, TabBtn)

        local Page = new("ScrollingFrame", {
            Size = UDim2.new(1, -20, 1, -10), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.AccentA, Visible = false, CanvasSize = UDim2.new(0, 0, 0, 0),
        }, Pages)
        local PageLayout = new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }, Page)
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pcall(function()
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
            end)
        end)

        local function setActive(entry, active)
            tw(entry.Btn, TweenInfo.new(0.2), { BackgroundTransparency = active and 0.88 or 1 })
            tw(entry.Bar, TweenInfo.new(0.2), { BackgroundTransparency = active and 0 or 1 })
            entry.Icon.TextColor3 = active and Theme.AccentA or Theme.TextDim
            entry.Text.TextColor3 = active and Theme.Text or Theme.TextDim
            entry.Text.Font = active and Enum.Font.GothamBold or Enum.Font.Gotham
        end

        TabBtn.MouseButton1Click:Connect(function()
            if activeTab then setActive(activeTab, false) end
            activeTab = { Btn = TabBtn, Icon = IconLabel, Text = TextLabel, Bar = AccentBar }
            setActive(activeTab, true)
            showPage(Page, tabTitle)
        end)

        if not activeTab then
            activeTab = { Btn = TabBtn, Icon = IconLabel, Text = TextLabel, Bar = AccentBar }
            setActive(activeTab, true)
            Page.Visible = true
            ContentTitle.Text = tabTitle
        end

        local Tab = {}

        --------------------------------------------------------
        -- Section
        --------------------------------------------------------
        function Tab:Section(secConfig)
            secConfig = secConfig or {}
            local secTitle = secConfig.Title or "Section"
            local isDefault = secConfig.Default

            local AccFrame = new("Frame", {
                Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 0.4, ClipsDescendants = true,
            }, Page)
            corner(AccFrame, UDim.new(0, 8))
            stroke(AccFrame)

            local AccBtn = new("TextButton", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = "" }, AccFrame)
            new("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1,
                Text = secTitle, TextColor3 = Theme.Text, TextSize = 13, Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, AccBtn)
            local AccArrow = new("TextLabel", {
                Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1,
                Text = "v", TextColor3 = Theme.TextDim, TextSize = 12, Font = Enum.Font.GothamBold,
            }, AccBtn)

            local ContentFrame = new("Frame", { Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 40), BackgroundTransparency = 1 }, AccFrame)
            local CLayout = new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, ContentFrame)

            local isOpen = false
            CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                pcall(function()
                    if isOpen then AccFrame.Size = UDim2.new(1, 0, 0, 40 + CLayout.AbsoluteContentSize.Y + 8) end
                    ContentFrame.Size = UDim2.new(1, 0, 0, CLayout.AbsoluteContentSize.Y)
                end)
            end)

            AccBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                AccArrow.Text = isOpen and "^" or "v"
                tw(AccFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = isOpen and UDim2.new(1, 0, 0, 40 + CLayout.AbsoluteContentSize.Y + 8) or UDim2.new(1, 0, 0, 40)
                })
            end)

            if isDefault then
                isOpen = true
                AccArrow.Text = "^"
                AccFrame.Size = UDim2.new(1, 0, 0, 40 + CLayout.AbsoluteContentSize.Y + 8)
            end

            return {
                ContentFrame = ContentFrame,
                Clear = function()
                    for _, v in pairs(ContentFrame:GetChildren()) do
                        if not v:IsA("UIListLayout") then v:Destroy() end
                    end
                end,
            }
        end

        --------------------------------------------------------
        -- Divider / Label
        --------------------------------------------------------
        function Tab:Divider()
            new("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Border, BorderSizePixel = 0 }, Page)
        end

        function Tab:Label(cfg)
            local text = type(cfg) == "string" and cfg or (cfg.Text or "Label")
            local Holder = new("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1 }, Page)
            local Lbl = new("TextLabel", {
                Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1,
                Text = text, TextColor3 = Theme.TextDim, TextSize = 12, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
            }, Holder)
            return { SetText = function(t) Lbl.Text = t end }
        end
        Tab.Paragraph = Tab.Label

        --------------------------------------------------------
        -- Element frame builder (shared by most controls)
        --------------------------------------------------------
        local function elementFrame(cfg)
            local targetParent = cfg.Section and cfg.Section.ContentFrame or Page
            local EFrame = new("Frame", { Size = UDim2.new(1, 0, 0, cfg.Desc and 48 or 40), BackgroundTransparency = 1 }, targetParent)
            local Label = new("TextLabel", {
                Size = UDim2.new(1, -160, 0, 20), Position = UDim2.new(0, 10, 0, cfg.Desc and 6 or 10),
                BackgroundTransparency = 1, Text = cfg.Title or "Element", TextColor3 = Theme.Text,
                TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
            }, EFrame)
            if cfg.Desc then
                new("TextLabel", {
                    Size = UDim2.new(1, -160, 0, 14), Position = UDim2.new(0, 10, 0, 26), BackgroundTransparency = 1,
                    Text = cfg.Desc, TextColor3 = Theme.TextDim, TextSize = 10, Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, EFrame)
            end
            if cfg.Tooltip then attachTooltip(EFrame, cfg.Tooltip) end
            return EFrame, Label
        end

        --------------------------------------------------------
        -- Button
        --------------------------------------------------------
        function Tab:Button(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local Btn = new("TextButton", {
                Size = UDim2.new(0, 120, 0, 26), Position = UDim2.new(1, -130, 0.5, -13),
                BackgroundColor3 = Theme.Element, Text = cfg.ButtonText or "Execute",
                TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
            }, EFrame)
            corner(Btn, UDim.new(0, 4))
            stroke(Btn)
            Btn.MouseEnter:Connect(function() tw(Btn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Hover }) end)
            Btn.MouseLeave:Connect(function() tw(Btn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Element }) end)
            Btn.MouseButton1Click:Connect(function()
                tw(Btn, TweenInfo.new(0.1), { Size = UDim2.new(0, 114, 0, 24), Position = UDim2.new(1, -127, 0.5, -12) })
                task.wait(0.1)
                tw(Btn, TweenInfo.new(0.1), { Size = UDim2.new(0, 120, 0, 26), Position = UDim2.new(1, -130, 0.5, -13) })
                if cfg.Callback then pcall(cfg.Callback) end
            end)
        end

        --------------------------------------------------------
        -- Toggle
        --------------------------------------------------------
        function Tab:Toggle(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local state = cfg.Default or false
            if cfg.Flag and FlagStore[cfg.Flag] ~= nil then state = FlagStore[cfg.Flag] end

            local TogBtn = new("TextButton", {
                Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -52, 0.5, -11),
                BackgroundColor3 = state and Theme.AccentA or Theme.Element, Text = "",
            }, EFrame)
            corner(TogBtn, UDim.new(1, 0))
            stroke(TogBtn)
            local TogCircle = new("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = Color3.new(1, 1, 1),
            }, TogBtn)
            corner(TogCircle, UDim.new(1, 0))

            local function setState(newState, fire)
                state = newState
                tw(TogBtn, TweenInfo.new(0.2), { BackgroundColor3 = state and Theme.AccentA or Theme.Element })
                tw(TogCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                })
                if cfg.Flag then FlagStore[cfg.Flag] = state end
                if fire ~= false and cfg.Callback then pcall(cfg.Callback, state) end
            end

            TogBtn.MouseButton1Click:Connect(function() setState(not state) end)
            if cfg.Flag and FlagStore[cfg.Flag] ~= nil then setState(FlagStore[cfg.Flag], true) end

            return { Set = setState, Get = function() return state end }
        end

        --------------------------------------------------------
        -- ToggleGroup (radio-style, pick exactly one)
        --------------------------------------------------------
        function Tab:ToggleGroup(cfg)
            cfg = cfg or {}
            local values = cfg.Values or {}
            local selected = cfg.Default or values[1]
            if cfg.Flag and FlagStore[cfg.Flag] then selected = FlagStore[cfg.Flag] end

            local Holder = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, (cfg.Section and cfg.Section.ContentFrame) or Page)
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, Holder)

            local buttons = {}
            local function refresh()
                for val, btn in pairs(buttons) do
                    local on = (val == selected)
                    btn.Dot.BackgroundColor3 = on and Theme.AccentA or Theme.Element
                    btn.Label.TextColor3 = on and Theme.Text or Theme.TextDim
                end
            end

            for _, val in ipairs(values) do
                local Row = new("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1 }, Holder)
                local Btn = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, Row)
                local Dot = new("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 10, 0.5, -7), BackgroundColor3 = Theme.Element }, Row)
                corner(Dot, UDim.new(1, 0))
                stroke(Dot)
                local Lbl = new("TextLabel", {
                    Size = UDim2.new(1, -34, 1, 0), Position = UDim2.new(0, 32, 0, 0), BackgroundTransparency = 1,
                    Text = val, TextColor3 = Theme.TextDim, TextSize = 12, Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, Row)
                buttons[val] = { Dot = Dot, Label = Lbl }

                Btn.MouseButton1Click:Connect(function()
                    selected = val
                    refresh()
                    if cfg.Flag then FlagStore[cfg.Flag] = selected end
                    if cfg.Callback then pcall(cfg.Callback, selected) end
                end)
            end
            refresh()

            return { Get = function() return selected end, Set = function(v) selected = v; refresh() end }
        end

        --------------------------------------------------------
        -- Slider
        --------------------------------------------------------
        function Tab:Slider(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local min, max = cfg.Min or 0, cfg.Max or 100
            local decimals = cfg.Decimals
            if decimals == nil then
                if max - min <= 10 then
                    decimals = 2 -- Auto 2 decimals for small ranges
                else
                    decimals = 0
                end
            end
            
            local val = cfg.Default or min
            if cfg.Flag and FlagStore[cfg.Flag] then val = FlagStore[cfg.Flag] end

            local SliderBg = new("Frame", { Size = UDim2.new(0, 130, 0, 6), Position = UDim2.new(1, -160, 0.5, -3), BackgroundColor3 = Theme.Element }, EFrame)
            corner(SliderBg, UDim.new(1, 0))
            stroke(SliderBg)
            local pct = (val - min) / (max - min)
            local Fill = new("Frame", { Size = UDim2.new(pct, 0, 1, 0), BackgroundColor3 = Theme.AccentA }, SliderBg)
            corner(Fill, UDim.new(1, 0))
            gradient(Fill, 0)
            local Thumb = new("Frame", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(pct, -6, 0.5, -6), BackgroundColor3 = Color3.new(1, 1, 1) }, SliderBg)
            corner(Thumb, UDim.new(1, 0))
            local ValLabel = new("TextLabel", {
                Size = UDim2.new(0, 26, 0, 20), Position = UDim2.new(1, -26, 0.5, -10), BackgroundTransparency = 1,
                TextColor3 = Theme.TextDim, TextSize = 11, Font = Enum.Font.Gotham,
            }, EFrame)

            local function fmt(n)
                if decimals <= 0 then return tostring(math.floor(n)) end
                local m = 10 ^ decimals
                return tostring(math.floor(n * m) / m)
            end

            local function setValue(newVal, fire)
                newVal = math.clamp(newVal, min, max)
                if decimals <= 0 then
                    newVal = math.floor(newVal)
                else
                    local m = 10 ^ decimals
                    newVal = math.floor(newVal * m) / m
                end
                
                local p = (max == min) and 0 or (newVal - min) / (max - min)
                Fill.Size = UDim2.new(p, 0, 1, 0)
                Thumb.Position = UDim2.new(p, -6, 0.5, -6)
                val = newVal
                ValLabel.Text = fmt(val)
                if cfg.Flag then FlagStore[cfg.Flag] = val end
                if fire ~= false and cfg.Callback then pcall(cfg.Callback, val) end
            end
            setValue(val, false)

            local clickBtn = new("TextButton", { Size = UDim2.new(1, 0, 1, 10), Position = UDim2.new(0, 0, 0.5, -5), BackgroundTransparency = 1, Text = "" }, SliderBg)
            local dragging = false
            clickBtn.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
            UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = math.clamp((inp.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    setValue(min + p * (max - min))
                end
            end)

            return { Set = setValue, Get = function() return val end }
        end

        --------------------------------------------------------
        -- ProgressBar (display-only, driven by :Set(percent))
        --------------------------------------------------------
        function Tab:ProgressBar(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local pct = cfg.Default or 0

            local Track = new("Frame", { Size = UDim2.new(0, 150, 0, 10), Position = UDim2.new(1, -160, 0.5, -5), BackgroundColor3 = Theme.Element }, EFrame)
            corner(Track, UDim.new(1, 0))
            stroke(Track)
            local Fill = new("Frame", { Size = UDim2.new(pct / 100, 0, 1, 0), BackgroundColor3 = Theme.AccentA }, Track)
            corner(Fill, UDim.new(1, 0))
            gradient(Fill, 0)

            local function set(p)
                pct = math.clamp(p, 0, 100)
                tw(Fill, TweenInfo.new(0.25), { Size = UDim2.new(pct / 100, 0, 1, 0) })
            end
            return { Set = set, Get = function() return pct end }
        end

        --------------------------------------------------------
        -- Image (banner / icon display)
        --------------------------------------------------------
        function Tab:Image(cfg)
            cfg = cfg or {}
            local Holder = new("Frame", {
                Size = UDim2.new(1, 0, 0, cfg.Height or 120), BackgroundColor3 = Theme.Element,
            }, (cfg.Section and cfg.Section.ContentFrame) or Page)
            corner(Holder, UDim.new(0, 8))
            stroke(Holder)
            local Img = new("ImageLabel", {
                Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4),
                BackgroundTransparency = 1, Image = cfg.Image or "", ScaleType = Enum.ScaleType.Fit,
            }, Holder)
            return { SetImage = function(id) Img.Image = id end }
        end

        --------------------------------------------------------
        -- TextBox (free text)
        --------------------------------------------------------
        function Tab:TextBox(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local val = cfg.Default or ""
            if cfg.Flag and FlagStore[cfg.Flag] then val = FlagStore[cfg.Flag] end

            local Bg = new("Frame", { Size = UDim2.new(0, 150, 0, 26), Position = UDim2.new(1, -160, 0.5, -13), BackgroundColor3 = Theme.Element }, EFrame)
            corner(Bg, UDim.new(0, 4))
            local st = stroke(Bg)
            local Box = new("TextBox", {
                Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1,
                Text = tostring(val), PlaceholderText = cfg.Placeholder or "", TextColor3 = Theme.TextDim,
                TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
            }, Bg)
            Box.Focused:Connect(function() tw(st, TweenInfo.new(0.2), { Color = Theme.AccentA }); Box.TextColor3 = Theme.Text end)
            Box.FocusLost:Connect(function()
                tw(st, TweenInfo.new(0.2), { Color = Theme.Border })
                Box.TextColor3 = Theme.TextDim
                if cfg.Flag then FlagStore[cfg.Flag] = Box.Text end
                if cfg.Callback then pcall(cfg.Callback, Box.Text) end
            end)
            return { SetText = function(t) Box.Text = tostring(t) end, GetText = function() return Box.Text end }
        end

        --------------------------------------------------------
        -- Input (numeric, min/max clamp)
        --------------------------------------------------------
        function Tab:Input(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local min, max = cfg.Min, cfg.Max
            local val = cfg.Default or 0
            if cfg.Flag and FlagStore[cfg.Flag] then val = FlagStore[cfg.Flag] end

            local Bg = new("Frame", { Size = UDim2.new(0, 150, 0, 26), Position = UDim2.new(1, -160, 0.5, -13), BackgroundColor3 = Theme.Element }, EFrame)
            corner(Bg, UDim.new(0, 4))
            local st = stroke(Bg)
            local Box = new("TextBox", {
                Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1,
                Text = tostring(val), PlaceholderText = cfg.Placeholder or "0", TextColor3 = Theme.Text,
                TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
            }, Bg)
            Box.Focused:Connect(function() tw(st, TweenInfo.new(0.2), { Color = Theme.AccentA }) end)
            Box.FocusLost:Connect(function()
                tw(st, TweenInfo.new(0.2), { Color = Theme.Border })
                local num = tonumber(Box.Text)
                if not num then Box.Text = tostring(val); return end
                if min then num = math.max(num, min) end
                if max then num = math.min(num, max) end
                val = num
                Box.Text = tostring(val)
                if cfg.Flag then FlagStore[cfg.Flag] = val end
                if cfg.Callback then pcall(cfg.Callback, val) end
            end)
            return { Set = function(n) val = n; Box.Text = tostring(n) end, Get = function() return val end }
        end

        --------------------------------------------------------
        -- Keybind
        --------------------------------------------------------
        function Tab:Keybind(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local current = cfg.Default
            if cfg.Flag and FlagStore[cfg.Flag] then
                current = Enum.KeyCode[FlagStore[cfg.Flag]]
            end
            local listening = false

            local KeyBtn = new("TextButton", {
                Size = UDim2.new(0, 100, 0, 26), Position = UDim2.new(1, -110, 0.5, -13),
                BackgroundColor3 = Theme.Element, Text = current and current.Name or "None",
                TextColor3 = Theme.TextDim, TextSize = 11, Font = Enum.Font.Gotham,
            }, EFrame)
            corner(KeyBtn, UDim.new(0, 4))
            stroke(KeyBtn)

            KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "..."
                KeyBtn.TextColor3 = Theme.AccentA
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    current = input.KeyCode
                    KeyBtn.Text = current.Name
                    KeyBtn.TextColor3 = Theme.TextDim
                    listening = false
                    if cfg.Flag then FlagStore[cfg.Flag] = current.Name end
                    if cfg.Callback then pcall(cfg.Callback, current) end
                elseif not gpe and current and input.KeyCode == current and cfg.OnPress then
                    pcall(cfg.OnPress)
                end
            end)

            return { Get = function() return current end, Set = function(kc) current = kc; KeyBtn.Text = kc and kc.Name or "None" end }
        end

        --------------------------------------------------------
        -- ColorPicker
        --------------------------------------------------------
        function Tab:ColorPicker(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local color = cfg.Default or Color3.fromRGB(140, 95, 255)
            local isOpen = false

            local Swatch = new("TextButton", { Size = UDim2.new(0, 40, 0, 22), Position = UDim2.new(1, -50, 0.5, -11), BackgroundColor3 = color, Text = "" }, EFrame)
            corner(Swatch, UDim.new(0, 4))
            stroke(Swatch)

            local Popup = new("Frame", { Size = UDim2.new(0, 180, 0, 150), BackgroundColor3 = Theme.Element, Visible = false, ZIndex = 150 }, Overlay)
            corner(Popup, UDim.new(0, 6))
            stroke(Popup)
            padding(Popup, 10, 10, 10, 10)
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, Popup)

            local function channelSlider(label, initial, onChange)
                local Row = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 }, Popup)
                new("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = label,
                    TextColor3 = Theme.TextDim, TextSize = 10, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
                }, Row)
                local Track = new("Frame", { Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 18), BackgroundColor3 = Theme.Background }, Row)
                corner(Track, UDim.new(1, 0))
                local Fill = new("Frame", { Size = UDim2.new(initial / 255, 0, 1, 0), BackgroundColor3 = Theme.AccentA }, Track)
                corner(Fill, UDim.new(1, 0))
                local Btn = new("TextButton", { Size = UDim2.new(1, 0, 1, 10), Position = UDim2.new(0, 0, 0.5, -5), BackgroundTransparency = 1, Text = "" }, Track)
                local dragging = false
                Btn.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local p = math.clamp((inp.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        Fill.Size = UDim2.new(p, 0, 1, 0)
                        onChange(math.floor(p * 255))
                    end
                end)
            end

            local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
            local function update()
                color = Color3.fromRGB(r, g, b)
                Swatch.BackgroundColor3 = color
                if cfg.Flag then FlagStore[cfg.Flag] = { r, g, b } end
                if cfg.Callback then pcall(cfg.Callback, color) end
            end
            channelSlider("R", r, function(v) r = v; update() end)
            channelSlider("G", g, function(v) g = v; update() end)
            channelSlider("B", b, function(v) b = v; update() end)

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
                    local mp = UserInputService:GetMouseLocation()
                    
                    local sp = Swatch.AbsolutePosition
                    local ss = Swatch.AbsoluteSize
                    local mPos = input.Position
                    if mPos.X >= sp.X and mPos.X <= sp.X + ss.X and mPos.Y >= sp.Y and mPos.Y <= sp.Y + ss.Y then
                        return -- Let Swatch handle it
                    end

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

        --------------------------------------------------------
        -- Shared floating list builder for Dropdown / MultiDropdown
        --------------------------------------------------------
        local function floatingList()
            local OptionList = new("ScrollingFrame", {
                BackgroundColor3 = Theme.Element, BorderSizePixel = 0, ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.AccentA, Visible = false, ZIndex = 101,
            }, Overlay)
            corner(OptionList, UDim.new(0, 4))
            stroke(OptionList)
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, OptionList)

            local SearchBox2 = new("TextBox", {
                Size = UDim2.new(1, -10, 0, 26), Position = UDim2.new(0, 5, 0, 0), BackgroundColor3 = Theme.Background,
                BackgroundTransparency = 0.5, Text = "", PlaceholderText = "  🔍 Search...", TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.TextDim, TextSize = 11, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = -1,
            }, OptionList)
            corner(SearchBox2, UDim.new(0, 4))

            SearchBox2:GetPropertyChangedSignal("Text"):Connect(function()
                local q = SearchBox2.Text:lower()
                for _, child in pairs(OptionList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.Visible = (q == "" or child.Text:lower():find(q, 1, true) ~= nil)
                    end
                end
            end)
            return OptionList, SearchBox2
        end

        --------------------------------------------------------
        -- Dropdown (single select)
        --------------------------------------------------------
        function Tab:Dropdown(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local selected = cfg.Default or (cfg.Values and cfg.Values[1]) or ""
            if cfg.Flag and FlagStore[cfg.Flag] then selected = FlagStore[cfg.Flag] end
            local isOpen = false

            local DropBtn = new("TextButton", {
                Size = UDim2.new(0, 150, 0, 26), Position = UDim2.new(1, -160, 0.5, -13), BackgroundColor3 = Theme.Element,
                Text = selected, TextColor3 = Theme.TextDim, TextSize = 11, Font = Enum.Font.Gotham,
            }, EFrame)
            corner(DropBtn, UDim.new(0, 4))
            stroke(DropBtn)
            local DropIcon = new("TextLabel", {
                Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(1, -24, 0, 0), BackgroundTransparency = 1,
                Text = "v", TextColor3 = Theme.TextDim, TextSize = 11, Font = Enum.Font.GothamBold,
            }, DropBtn)

            local OptionList, SearchBox2 = floatingList()

            local function refreshOptions(newValues)
                for _, child in pairs(OptionList:GetChildren()) do
                    if child:IsA("TextButton") and child ~= SearchBox2 then child:Destroy() end
                end
                cfg.Values = newValues or cfg.Values or {}
                local totalHeight = 26
                for _, val in ipairs(cfg.Values) do
                    local OptBtn = new("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Theme.Hover, BackgroundTransparency = 1,
                        Text = "  " .. val, TextColor3 = val == selected and Theme.AccentA or Theme.TextDim,
                        TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102,
                    }, OptionList)
                    totalHeight = totalHeight + 26
                    OptBtn.MouseEnter:Connect(function() tw(OptBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0 }) end)
                    OptBtn.MouseLeave:Connect(function() tw(OptBtn, TweenInfo.new(0.2), { BackgroundTransparency = 1 }) end)
                    OptBtn.MouseButton1Click:Connect(function()
                        selected = val
                        DropBtn.Text = selected
                        isOpen = false
                        DropIcon.Text = "v"
                        Overlay.Visible = false
                        OptionList.Visible = false
                        for _, ob in pairs(OptionList:GetChildren()) do
                            if ob:IsA("TextButton") then ob.TextColor3 = ob.Text:sub(3) == selected and Theme.AccentA or Theme.TextDim end
                        end
                        if cfg.Flag then FlagStore[cfg.Flag] = selected end
                        if cfg.Callback then pcall(cfg.Callback, selected) end
                    end)
                end
                OptionList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
                OptionList.Size = UDim2.new(0, 150, 0, math.min(totalHeight, 130))
            end

            local lastToggle = 0
            DropBtn.MouseButton1Click:Connect(function()
                if tick() - lastToggle < 0.1 then return end
                lastToggle = tick()
                if not cfg.Values or #cfg.Values == 0 then return end
                isOpen = not isOpen
                DropIcon.Text = isOpen and "^" or "v"
                if isOpen then
                    SearchBox2.Text = ""
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
                    local mPos = input.Position
                    
                    local dPos = DropBtn.AbsolutePosition
                    local dSize = DropBtn.AbsoluteSize
                    if mPos.X >= dPos.X and mPos.X <= dPos.X + dSize.X and
                       mPos.Y >= dPos.Y and mPos.Y <= dPos.Y + dSize.Y then
                        return -- Let DropBtn handle its own click
                    end

                    local oPos = OptionList.AbsolutePosition
                    local oSize = OptionList.AbsoluteSize
                    if OptionList.Visible and mPos.X >= oPos.X and mPos.X <= oPos.X + oSize.X and
                       mPos.Y >= oPos.Y and mPos.Y <= oPos.Y + oSize.Y then
                        return -- Do not close if clicking inside the Dropdown (e.g. SearchBox)
                    end
                    
                    lastToggle = tick()
                    isOpen = false
                    DropIcon.Text = "v"
                    Overlay.Visible = false
                    OptionList.Visible = false
                end
            end)

            refreshOptions()

            return {
                Refresh = function(newValues)
                    selected = (newValues and newValues[1]) or "None"
                    DropBtn.Text = selected
                    refreshOptions(newValues)
                    if cfg.Callback then pcall(cfg.Callback, selected) end
                end,
                SetValues = function(newValues) cfg.Values = newValues; refreshOptions(newValues) end,
                SetValue = function(val)
                    selected = val
                    DropBtn.Text = selected
                    for _, ob in pairs(OptionList:GetChildren()) do
                        if ob:IsA("TextButton") then ob.TextColor3 = ob.Text:sub(3) == selected and Theme.AccentA or Theme.TextDim end
                    end
                end,
            }
        end

        --------------------------------------------------------
        -- MultiDropdown (multi select, with checkboxes)
        --------------------------------------------------------
        function Tab:MultiDropdown(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local selected = cfg.Default or {}
            if type(selected) ~= "table" then selected = { selected } end
            if cfg.Flag and FlagStore[cfg.Flag] then selected = FlagStore[cfg.Flag] end
            local isOpen = false

            local function selectedText()
                if #selected == 0 then return "Select Options" end
                return table.concat(selected, ", ")
            end

            local DropBtn = new("TextButton", {
                Size = UDim2.new(0, 150, 0, 26), Position = UDim2.new(1, -160, 0.5, -13), BackgroundColor3 = Theme.Element,
                Text = selectedText(), TextColor3 = Theme.TextDim, TextSize = 11, Font = Enum.Font.Gotham,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, EFrame)
            corner(DropBtn, UDim.new(0, 4))
            stroke(DropBtn)
            local DropIcon = new("TextLabel", {
                Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(1, -24, 0, 0), BackgroundTransparency = 1,
                Text = "v", TextColor3 = Theme.TextDim, TextSize = 11, Font = Enum.Font.GothamBold,
            }, DropBtn)

            local OptionList, SearchBox2 = floatingList()

            local function refreshOptions(newValues)
                for _, child in pairs(OptionList:GetChildren()) do
                    if child:IsA("TextButton") and child ~= SearchBox2 then child:Destroy() end
                end
                cfg.Values = newValues or cfg.Values or {}
                local totalHeight = 26
                for _, val in ipairs(cfg.Values) do
                    local isSel = table.find(selected, val) ~= nil
                    local OptBtn = new("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Theme.Hover, BackgroundTransparency = 1,
                        Text = "  " .. val, TextColor3 = isSel and Theme.AccentA or Theme.TextDim, TextSize = 11,
                        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102,
                    }, OptionList)
                    totalHeight = totalHeight + 26
                    OptBtn.MouseEnter:Connect(function() tw(OptBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0 }) end)
                    OptBtn.MouseLeave:Connect(function() tw(OptBtn, TweenInfo.new(0.2), { BackgroundTransparency = 1 }) end)
                    OptBtn.MouseButton1Click:Connect(function()
                        local idx = table.find(selected, val)
                        if idx then
                            table.remove(selected, idx)
                            OptBtn.TextColor3 = Theme.TextDim
                        else
                            table.insert(selected, val)
                            OptBtn.TextColor3 = Theme.AccentA
                        end
                        DropBtn.Text = selectedText()
                        if cfg.Flag then FlagStore[cfg.Flag] = selected end
                        if cfg.Callback then pcall(cfg.Callback, selected) end
                    end)
                end
                OptionList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
                OptionList.Size = UDim2.new(0, 150, 0, math.min(totalHeight, 130))
            end

            local lastToggle = 0
            DropBtn.MouseButton1Click:Connect(function()
                if tick() - lastToggle < 0.1 then return end
                lastToggle = tick()
                if not cfg.Values or #cfg.Values == 0 then return end
                isOpen = not isOpen
                DropIcon.Text = isOpen and "^" or "v"
                if isOpen then
                    SearchBox2.Text = ""
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
                    local mPos = input.Position
                    
                    local dPos = DropBtn.AbsolutePosition
                    local dSize = DropBtn.AbsoluteSize
                    if mPos.X >= dPos.X and mPos.X <= dPos.X + dSize.X and
                       mPos.Y >= dPos.Y and mPos.Y <= dPos.Y + dSize.Y then
                        return -- Let DropBtn handle its own click
                    end

                    local oPos = OptionList.AbsolutePosition
                    local oSize = OptionList.AbsoluteSize
                    if OptionList.Visible and mPos.X >= oPos.X and mPos.X <= oPos.X + oSize.X and
                       mPos.Y >= oPos.Y and mPos.Y <= oPos.Y + oSize.Y then
                        return -- Do not close if clicking inside the Dropdown (e.g. SearchBox)
                    end
                    
                    lastToggle = tick()
                    isOpen = false
                    DropIcon.Text = "v"
                    Overlay.Visible = false
                    OptionList.Visible = false
                end
            end)

            refreshOptions()

            return {
                Refresh = function(newValues)
                    selected = cfg.Default or {}
                    if type(selected) ~= "table" then selected = { selected } end
                    DropBtn.Text = selectedText()
                    refreshOptions(newValues)
                    if cfg.Callback then pcall(cfg.Callback, selected) end
                end,
                Get = function() return selected end,
            }
        end

        return Tab
    end

    return Window
end

return PulseUI

--[[
================================================================
FULL USAGE EXAMPLE (copy into your own script, not executed here)
================================================================

local PulseUI = loadstring(game:HttpGet("https://yourhost.com/PulseUI.lua"))()

local Window = PulseUI:CreateWindow({
    Title = "PulseUI Demo",
    SubTitle = "example.gg/pulse",
    ToggleKey = Enum.KeyCode.RightControl,
    ConfigName = "demo_config",
})

Window:SetWatermark("PulseUI Demo | 60 FPS", true)

local Main = Window:Tab({ Title = "Main", Icon = "◈" })
local Combat = Window:Tab({ Title = "Combat", Icon = "⚔" })
local Settings = Window:Tab({ Title = "Settings", Icon = "⚙" })

-- Section + basic controls
local farmSection = Main:Section({ Title = "Auto Farm", Default = true })
Main:Toggle({ Section = farmSection, Title = "Enabled", Flag = "AutoFarm", Callback = function(v) end })
Main:Slider({ Section = farmSection, Title = "Farm Radius", Min = 10, Max = 200, Default = 50, Flag = "FarmRadius" })
Main:Dropdown({ Section = farmSection, Title = "Target", Values = {"Nearest", "Weakest", "Strongest"}, Flag = "FarmTarget" })

-- Standalone controls
Main:Button({ Title = "Teleport Home", ButtonText = "Go", Callback = function() end })
Main:MultiDropdown({ Title = "Item Whitelist", Values = {"Sword", "Shield", "Potion"}, Flag = "Whitelist" })
Main:Input({ Title = "Max Distance", Min = 0, Max = 1000, Default = 100, Flag = "MaxDist" })
Main:ProgressBar({ Title = "Farm Progress" })
Main:Label("This is an informational line of text.")
Main:Divider()

-- Combat tab
Combat:Toggle({ Title = "Auto Parry", Flag = "AutoParry" })
Combat:Keybind({ Title = "Parry Key", Default = Enum.KeyCode.F, Flag = "ParryKey", OnPress = function() end })
Combat:ColorPicker({ Title = "ESP Color", Flag = "ESPColor" })
Combat:ToggleGroup({ Title = "Fight Mode", Values = {"Passive", "Balanced", "Aggressive"}, Default = "Balanced", Flag = "FightMode" })

-- Settings tab
Settings:Button({ Title = "Save Config", ButtonText = "Save", Callback = function() Window:SaveConfig() end })
Settings:Button({ Title = "Load Config", ButtonText = "Load", Callback = function() Window:LoadConfig() end })

Window:Notify("Welcome", "PulseUI loaded successfully.", 4, "success")
================================================================
]]
