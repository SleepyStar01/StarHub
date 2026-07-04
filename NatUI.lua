-- Library yang Sudah Diperbaiki (Enhanced Version)
local UserInputService = game:GetService('UserInputService')
local LocalPlayer = game:GetService('Players').LocalPlayer
local TweenService = game:GetService('TweenService')
local HttpService = game:GetService('HttpService')
local CoreGui = game:GetService('CoreGui')
local Mouse = LocalPlayer:GetMouse()

local Library = {
    connections = {};
    Flags = {};
    Enabled = true;
    slider_drag = false;
    core = nil;
    dragging = false;
    drag_position = nil;
    start_position = nil;
    ConfigPath = "NatHubUI";
    Theme = "Default" -- Bisa ditambah: "Dark", "Light", "Custom"
}

-- ============================================
-- IMPROVED CONFIG SYSTEM
-- ============================================
function Library:Initialize()
    if not isfolder(self.ConfigPath) then
        makefolder(self.ConfigPath)
    end
    
    -- Load config dengan error handling
    local success, err = pcall(function()
        self:LoadConfigs()
    end)
    
    if not success then
        warn("Failed to load configs:", err)
        self.Flags = {}
    end
    
    self:Cleanup()
end

function Library:SaveConfigs()
    if not self:Exists() then return end
    
    local success, err = pcall(function()
        local flags = HttpService:JSONEncode(self.Flags)
        writefile(self.ConfigPath .. "/" .. game.GameId .. ".json", flags)
    end)
    
    if not success then
        warn("Failed to save configs:", err)
    end
end

function Library:LoadConfigs()
    local configFile = self.ConfigPath .. "/" .. game.GameId .. ".json"
    
    if not isfile(configFile) then 
        self:SaveConfigs() 
        return 
    end
    
    local success, data = pcall(function()
        return readfile(configFile)
    end)
    
    if not success or not data then 
        self:SaveConfigs() 
        return 
    end
    
    local success2, decoded = pcall(function()
        return HttpService:JSONDecode(data)
    end)
    
    if success2 and decoded then
        self.Flags = decoded
    else
        self.Flags = {}
    end
end

-- ============================================
-- IMPROVED EVENT MANAGEMENT
-- ============================================
function Library:AddConnection(connection)
    table.insert(self.connections, connection)
    return connection
end

function Library:Disconnect()
    for i, connection in ipairs(self.connections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    self.connections = {}
end

function Library:Cleanup()
    for _, object in ipairs(CoreGui:GetChildren()) do
        if object.Name == "NatHubUI" then
            object:Destroy()
        end
    end
end

function Library:Exists()
    return self.core and self.core.Parent
end

-- ============================================
-- IMPROVED DRAG SYSTEM
-- ============================================
function Library:SetupDrag(frame, target)
    local dragConnection
    local startConnection
    
    startConnection = frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            self.dragging = true
            self.drag_position = input.Position
            self.start_position = target.Position
            
            self:AddConnection(input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.dragging = false
                end
            end))
        end
    end)
    
    self:AddConnection(startConnection)
    
    dragConnection = UserInputService.InputChanged:Connect(function(input)
        if self.dragging and 
           (input.UserInputType == Enum.UserInputType.MouseMovement or 
            input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - self.drag_position
            local newPos = UDim2.new(
                self.start_position.X.Scale, 
                self.start_position.X.Offset + delta.X, 
                self.start_position.Y.Scale, 
                self.start_position.Y.Offset + delta.Y
            )
            
            TweenService:Create(target, TweenInfo.new(0.2), {
                Position = newPos
            }):Play()
        end
    end)
    
    self:AddConnection(dragConnection)
end

-- ============================================
-- IMPROVED UI CREATION
-- ============================================
function Library:CreateWindow(title, options)
    options = options or {}
    local theme = options.Theme or self.Theme
    
    -- Container setup...
    local container = Instance.new("ScreenGui")
    container.Name = "NatHubUI"
    container.Parent = CoreGui
    container.ResetOnSpawn = false
    container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.core = container
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(0, 776, 0, 509)
    Shadow.Image = "rbxassetid://17290899982"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.Parent = container
    
    -- Main Container
    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    MainContainer.BackgroundColor3 = Color3.fromRGB(19, 20, 24)
    MainContainer.BorderSizePixel = 0
    MainContainer.ClipsDescendants = true
    MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainContainer.Size = UDim2.new(0, 699, 0, 426)
    MainContainer.Parent = container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 20)
    Corner.Parent = MainContainer
    
    -- Setup drag
    self:SetupDrag(MainContainer, MainContainer)
    
    -- Title Bar with custom font
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 39)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = MainContainer
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0.1, 0, 0.5, 0)
    TitleLabel.Size = UDim2.new(0, 100, 0, 16)
    TitleLabel.Font = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
    TitleLabel.Text = title or "NatHub"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextScaled = true
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Timer
    local TimerLabel = Instance.new("TextLabel")
    TimerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    TimerLabel.Size = UDim2.new(0, 75, 0, 16)
    TimerLabel.Font = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
    TimerLabel.Text = "00:00"
    TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimerLabel.TextScaled = true
    TimerLabel.TextSize = 13
    TimerLabel.Parent = TitleBar
    
    -- Start timer
    local startTime = os.time()
    task.spawn(function()
        while container.Parent do
            local elapsed = os.time() - startTime
            local minutes = math.floor(elapsed / 60)
            local seconds = elapsed % 60
            TimerLabel.Text = string.format("%02d:%02d", minutes, seconds)
            task.wait(1)
        end
    end)
    
    -- Return main container for further setup
    return {
        Container = MainContainer,
        Shadow = Shadow,
        ScreenGui = container
    }
end

-- Initialize library
Library:Initialize()

return Library
