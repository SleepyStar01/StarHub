-- // StarHub UI Library
-- Mirip seperti contoh link ThanHub/Fluent

local StarHub = {}
StarHub.__index = StarHub

-- Buat Window
function StarHub:CreateWindow(options)
    options = options or {}

    local Window = {}
    setmetatable(Window, self)

    -- Setting default
    Window.Title = options.Title or "StarHub"
    Window.Icon = options.Icon or ""
    Window.Author = options.Author or "Unknown"
    Window.Folder = options.Folder or "StarHub"
    Window.Size = options.Size or UDim2.fromOffset(560, 400)
    Window.Transparent = options.Transparent or false
    Window.Theme = options.Theme or "Dark"
    Window.SideBarWidth = options.SideBarWidth or 170
    Window.HasOutline = (options.HasOutline ~= nil and options.HasOutline or true)

    -- Buat ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = Window.Folder
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    -- Main container
    local Main = Instance.new("Frame")
    Main.Size = Window.Size
    Main.Position = UDim2.new(0.5, -Window.Size.X.Offset/2, 0.5, -Window.Size.Y.Offset/2)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    if Window.Transparent then
        Main.BackgroundTransparency = 0.2
    end

    if Window.HasOutline then
        local Outline = Instance.new("UIStroke")
        Outline.Thickness = 2
        Outline.Color = Color3.fromRGB(100, 100, 100)
        Outline.Parent = Main
    end

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 40, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Window.Title .. " | " .. Window.Author
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.Parent = TitleBar

    if Window.Icon ~= "" then
        local IconImage = Instance.new("ImageLabel")
        IconImage.Size = UDim2.fromOffset(24, 24)
        IconImage.Position = UDim2.new(0, 5, 0.5, -12)
        IconImage.BackgroundTransparency = 1
        IconImage.Image = Window.Icon
        IconImage.Parent = TitleBar
    end

    -- Sidebar
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, Window.SideBarWidth, 1, -35)
    SideBar.Position = UDim2.new(0, 0, 0, 35)
    SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SideBar.BorderSizePixel = 0
    SideBar.Parent = Main

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = SideBar

    -- Tabs holder
    local TabsFolder = Instance.new("Frame")
    TabsFolder.Size = UDim2.new(1, -Window.SideBarWidth, 1, -35)
    TabsFolder.Position = UDim2.new(0, Window.SideBarWidth, 0, 35)
    TabsFolder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabsFolder.BorderSizePixel = 0
    TabsFolder.Parent = Main

    Window.Gui = ScreenGui
    Window.Main = Main
    Window.SideBar = SideBar
    Window.TabsFolder = TabsFolder
    Window.Tabs = {}

    return Window
end

-- Buat Tab
function StarHub:Tab(options)
    options = options or {}

    local Tab = {}
    setmetatable(Tab, self)

    Tab.Title = options.Title or "Tab"
    Tab.Icon = options.Icon or ""

    -- Button di sidebar
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.Text = Tab.Title
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 13
    Button.Parent = self.SideBar

    -- Container untuk isi tab
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, 0, 1, 0)
    Container.BackgroundTransparency = 1
    Container.Visible = false
    Container.ScrollBarThickness = 6
    Container.Parent = self.TabsFolder

    Button.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Container.Visible = false
        end
        Container.Visible = true
    end)

    Tab.Button = Button
    Tab.Container = Container

    table.insert(self.Tabs, Tab)
    if #self.Tabs == 1 then
        Container.Visible = true
    end

    return Tab
end

return StarHub
