-- StarHub UI Library
-- discord.gg/starhub

local StarHub = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Theme Colors
StarHub.Theme = {
    Primary = Color3.fromRGB(25, 35, 70),
    Secondary = Color3.fromRGB(35, 45, 80),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(220, 220, 255),
    Border = Color3.fromRGB(50, 70, 120),
    DarkOverlay = Color3.fromRGB(0, 0, 0),
    Notification = Color3.fromRGB(30, 40, 75)
}

-- Tween Presets
StarHub.TweenInfo = {
    Global = {
        Duration = 0.25,
        EasingStyle = Enum.EasingStyle.Quart,
        EasingDirection = Enum.EasingDirection.Out
    },
    Notification = {
        Duration = 0.5,
        EasingStyle = Enum.EasingStyle.Back,
        EasingDirection = Enum.EasingDirection.Out
    }
}

-- Utility Functions
function StarHub:CreateTween(instance, properties, tweenInfo)
    local info = TweenInfo.new(
        tweenInfo.Duration or 0.25,
        tweenInfo.EasingStyle or Enum.EasingStyle.Quart,
        tweenInfo.EasingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function StarHub:CreateInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

-- Main UI Creation
function StarHub:CreateWindow(options)
    local windowOptions = {
        Title = options.Title or "StarHub",
        Icon = options.Icon or "rbxassetid://131711698212719",
        Size = options.Size or UDim2.fromOffset(560, 400),
        Theme = options.Theme or StarHub.Theme,
        ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    }
    
    -- Create ScreenGui
    local screenGui = self:CreateInstance("ScreenGui", {
        Name = "StarHubUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Apply protection
    if protect_gui then
        protect_gui(screenGui)
    elseif gethui then
        screenGui.Parent = gethui()
    elseif pcall(function() game.CoreGui:GetChildren() end) then
        screenGui.Parent = game:GetService("CoreGui")
    else
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Window Frame
    local mainWindow = self:CreateInstance("Frame", {
        Name = "MainWindow",
        Size = windowOptions.Size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = windowOptions.Theme.Primary,
        BorderColor3 = windowOptions.Theme.Border,
        BorderSizePixel = 2,
        ClipsDescendants = true
    })
    
    local windowCorner = self:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = mainWindow
    })
    
    local windowStroke = self:CreateInstance("UIStroke", {
        Color = Color3.fromRGB(80, 100, 160),
        Thickness = 1.5,
        Transparency = 0.5,
        Parent = mainWindow
    })
    
    -- Top Bar
    local topBar = self:CreateInstance("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = windowOptions.Theme.Primary,
        BorderSizePixel = 0
    })
    
    local topBarCorner = self:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = topBar
    })
    
    local topBarStroke = self:CreateInstance("UIStroke", {
        Color = windowOptions.Theme.Border,
        Thickness = 1.5,
        Parent = topBar
    })
    
    -- Window Icon
    local icon = self:CreateInstance("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = windowOptions.Icon,
        Parent = topBar
    })
    
    -- Window Title
    local title = self:CreateInstance("TextLabel", {
        Name = "Title",
        Text = windowOptions.Title,
        TextColor3 = windowOptions.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = topBar
    })
    
    -- Close Button
    local closeButton = self:CreateInstance("ImageButton", {
        Name = "Close",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -15, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://132453323679056",
        ImageColor3 = windowOptions.Theme.Text,
        Parent = topBar
    })
    
    -- Tab Buttons Area
    local tabButtons = self:CreateInstance("Frame", {
        Name = "TabButtons",
        Size = UDim2.new(0, 165, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundColor3 = windowOptions.Theme.Primary,
        BorderSizePixel = 0
    })
    
    local tabButtonsCorner = self:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = tabButtons
    })
    
    -- Tabs Area
    local tabsArea = self:CreateInstance("Frame", {
        Name = "Tabs",
        Size = UDim2.new(1, -165, 1, -35),
        Position = UDim2.new(0, 165, 0, 35),
        BackgroundColor3 = windowOptions.Theme.Secondary,
        BorderSizePixel = 0
    })
    
    local tabsCorner = self:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = tabsArea
    })
    
    -- Add elements to main window
    topBar.Parent = mainWindow
    tabButtons.Parent = mainWindow
    tabsArea.Parent = mainWindow
    mainWindow.Parent = screenGui
    
    -- Window functionality
    local isVisible = false
    local isDragging = false
    local dragStart, startPos
    
    -- Make window draggable
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = mainWindow.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)
    
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
            local delta = input.Position - dragStart
            mainWindow.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Toggle visibility
    local function toggleVisibility()
        isVisible = not isVisible
        mainWindow.Visible = isVisible
    end
    
    -- Keybind to toggle window
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == windowOptions.ToggleKey then
            toggleVisibility()
        end
    end)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        mainWindow.Visible = false
        isVisible = false
    end)
    
    -- Initially hide the window
    mainWindow.Visible = false
    
    -- Window API
    local windowAPI = {}
    
    function windowAPI:Toggle()
        toggleVisibility()
    end
    
    function windowAPI:CreateTab(tabName, tabIcon)
        -- Tab button creation
        local tabButton = self:CreateInstance("TextButton", {
            Name = tabName,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Text = "",
            Parent = tabButtons
        })
        
        local tabIconLabel = self:CreateInstance("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 12, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Image = tabIcon or "rbxassetid://113216930555884",
            ImageColor3 = windowOptions.Theme.Text,
            Parent = tabButton
        })
        
        local tabText = self:CreateInstance("TextLabel", {
            Name = "Text",
            Text = tabName,
            TextColor3 = windowOptions.Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 42, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Parent = tabButton
        })
        
        -- Tab content area
        local tabContent = self:CreateInstance("ScrollingFrame", {
            Name = tabName,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = windowOptions.Theme.Border,
            Visible = false,
            Parent = tabsArea
        })
        
        local tabLayout = self:CreateInstance("UIListLayout", {
            Padding = UDim.new(0, 15),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabContent
        })
        
        local tabPadding = self:CreateInstance("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = tabContent
        })
        
        -- Tab selection functionality
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, child in ipairs(tabsArea:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            
            -- Show selected tab
            tabContent.Visible = true
        end)
        
        -- Tab API
        local tabAPI = {}
        
        function tabAPI:AddButton(buttonOptions)
            local button = self:CreateInstance("TextButton", {
                Name = buttonOptions.Text,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = windowOptions.Theme.Secondary,
                AutoButtonColor = false,
                Text = "",
                Parent = tabContent
            })
            
            local buttonCorner = self:CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = button
            })
            
            local buttonStroke = self:CreateInstance("UIStroke", {
                Color = windowOptions.Theme.Border,
                Thickness = 1.5,
                Parent = button
            })
            
            local buttonText = self:CreateInstance("TextLabel", {
                Text = buttonOptions.Text,
                TextColor3 = windowOptions.Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = button
            })
            
            -- Button functionality
            button.MouseEnter:Connect(function()
                self:CreateTween(buttonStroke, {Color = windowOptions.Theme.Accent}, self.TweenInfo.Global)
            end)
            
            button.MouseLeave:Connect(function()
                self:CreateTween(buttonStroke, {Color = windowOptions.Theme.Border}, self.TweenInfo.Global)
            end)
            
            button.MouseButton1Click:Connect(function()
                if buttonOptions.Callback then
                    buttonOptions.Callback()
                end
            end)
            
            return button
        end
        
        return tabAPI
    end
    
    function windowAPI:Notify(notificationOptions)
        -- Notification implementation would go here
        -- Similar to NatHub's notification system but with star theme
    end
    
    return windowAPI
end

return StarHub
