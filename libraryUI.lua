--// StarHub UI Library (Base)
-- Dibuat dari nol, mirip gaya Fluent/ThanHub

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local StarHub = {}
StarHub.__index = StarHub

-- // CreateWindow
function StarHub:CreateWindow(options)
    options = options or {}

    local Window = {}
    setmetatable(Window, self)

    -- Default Settings
    Window.Title = options.Title or "StarHub"
    Window.Size = options.Size or UDim2.fromOffset(500, 350)
    Window.Theme = options.Theme or "Dark"
    Window.SideBarWidth = options.SideBarWidth or 150
    Window.HasOutline = (options.HasOutline ~= nil and options.HasOutline or true)

    -- Buat ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = Window.Title
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    -- Buat main frame
    local Main = Instance.new("Frame")
    Main.Size = Window.Size
    Main.Position = UDim2.new(0.5, -Window.Size.X.Offset/2, 0.5, -Window.Size.Y.Offset/2)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    if Window.HasOutline then
        local Outline = Instance.new("UIStroke")
        Outline.Thickness = 2
        Outline.Color = Color3.fromRGB(100, 100, 100)
        Outline.Parent = Main
    end

    -- Title bar
    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.Text = "  " .. Window.Title
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.TextXAlignment = Enum.TextXAlignment.Left
    TitleBar.Parent = Main

    -- Sidebar
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, Window.SideBarWidth, 1, -30)
    SideBar.Position = UDim2.new(0, 0, 0, 30)
    SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SideBar.BorderSizePixel = 0
    SideBar.Parent = Main

    -- Tab holder
    local TabsFolder = Instance.new("Frame")
    TabsFolder.Size = UDim2.new(1, -Window.SideBarWidth, 1, -30)
    TabsFolder.Position = UDim2.new(0, Window.SideBarWidth, 0, 30)
    TabsFolder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabsFolder.BorderSizePixel = 0
    TabsFolder.Parent = Main

    -- Simpan instance
    Window.Gui = ScreenGui
    Window.Main = Main
    Window.SideBar = SideBar
    Window.TabsFolder = TabsFolder
    Window.Tabs = {}

    return Window
end

-- // Tab
function StarHub:Tab(options)
    options = options or {}

    local Tab = {}
    setmetatable(Tab, self)

    Tab.Title = options.Title or "Tab"
    Tab.Icon = options.Icon or "rbxassetid://0"

    -- Buat tombol di sidebar
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.Text = Tab.Title
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Parent = self.SideBar

    -- Buat container untuk tab
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
