-- StarHub UI Library v1.0
-- Dibuat khusus untuk Faris ✨

local StarHub = {}

-- Helper function buat Instance
local function Create(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props) do
        inst[k] = v
    end
    return inst
end

-- Fungsi buat Window
function StarHub:CreateWindow(config)
    local Window = {}
    config = config or {}

    local ScreenGui = Create("ScreenGui", {
        Name = "StarHubUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game:GetService("CoreGui")
    })

    -- Frame utama
    local MainFrame = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 560, 0, 400),
        Position = UDim2.new(0.5, -280, 0.5, -200),
        BackgroundColor3 = Color3.fromRGB(15, 20, 35), -- biru gelap
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 12) })
    Create("UIStroke", { Parent = MainFrame, Color = Color3.fromRGB(0, 120, 255), Thickness = 2, Transparency = 0.3 })

    -- Title
    local TitleBar = Create("TextLabel", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = config.Title or "StarHub",
        TextColor3 = Color3.fromRGB(180, 200, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 20
    })

    -- Sidebar (tab holder)
    local TabHolder = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(0, 150, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    })
    Create("UICorner", { Parent = TabHolder, CornerRadius = UDim.new(0, 8) })
    Create("UIListLayout", { Parent = TabHolder, SortOrder = Enum.SortOrder.LayoutOrder })

    -- Content frame
    local ContentFrame = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -150, 1, -40),
        Position = UDim2.new(0, 150, 0, 40),
        BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    })
    Create("UICorner", { Parent = ContentFrame, CornerRadius = UDim.new(0, 8) })

    local Tabs = {}

    function Window:Tab(tabConfig)
        local TabButton = Create("TextButton", {
            Parent = TabHolder,
            Size = UDim2.new(1, 0, 0, 35),
            Text = tabConfig.Title or "Tab",
            BackgroundColor3 = Color3.fromRGB(15, 20, 35),
            TextColor3 = Color3.fromRGB(200, 210, 255),
            Font = Enum.Font.Gotham,
            TextSize = 14
        })
        Create("UICorner", { Parent = TabButton, CornerRadius = UDim.new(0, 6) })

        local TabPage = Create("ScrollingFrame", {
            Parent = ContentFrame,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0,0,0,0),
            ScrollBarThickness = 4,
            Visible = false,
            BackgroundTransparency = 1
        })
        local List = Create("UIListLayout", { Parent = TabPage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6) })

        TabButton.MouseButton1Click:Connect(function()
            for _,t in pairs(Tabs) do t.Page.Visible = false end
            TabPage.Visible = true
        end)

        local Elements = {}

        -- Button
        function Elements:Button(bConfig)
            local Btn = Create("TextButton", {
                Parent = TabPage,
                Size = UDim2.new(0, 200, 0, 30),
                Text = bConfig.Title or "Button",
                BackgroundColor3 = Color3.fromRGB(25, 35, 65),
                TextColor3 = Color3.fromRGB(220, 230, 255),
                Font = Enum.Font.Gotham,
                TextSize = 14
            })
            Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 6) })

            Btn.MouseButton1Click:Connect(function()
                if bConfig.Callback then bConfig.Callback() end
            end)
        end

        -- Toggle
        function Elements:Toggle(tConfig)
            local State = tConfig.Default or false
            local ToggleBtn = Create("TextButton", {
                Parent = TabPage,
                Size = UDim2.new(0, 200, 0, 30),
                Text = (State and "[ON] " or "[OFF] ") .. (tConfig.Title or "Toggle"),
                BackgroundColor3 = Color3.fromRGB(25, 35, 65),
                TextColor3 = Color3.fromRGB(220, 230, 255),
                Font = Enum.Font.Gotham,
                TextSize = 14
            })
            Create("UICorner", { Parent = ToggleBtn, CornerRadius = UDim.new(0, 6) })

            ToggleBtn.MouseButton1Click:Connect(function()
                State = not State
                ToggleBtn.Text = (State and "[ON] " or "[OFF] ") .. (tConfig.Title or "Toggle")
                if tConfig.Callback then tConfig.Callback(State) end
            end)
        end

        -- Slider
        function Elements:Slider(sConfig)
            local Frame = Create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(0, 200, 0, 40),
                BackgroundTransparency = 1
            })

            local Label = Create("TextLabel", {
                Parent = Frame,
                Size = UDim2.new(1, 0, 0, 20),
                Text = (sConfig.Title or "Slider") .. ": " .. (sConfig.Default or 0),
                TextColor3 = Color3.fromRGB(220, 230, 255),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextSize = 14
            })

            local SliderBtn = Create("TextButton", {
                Parent = Frame,
                Size = UDim2.new(1, 0, 0, 15),
                Position = UDim2.new(0,0,0,20),
                BackgroundColor3 = Color3.fromRGB(25, 35, 65),
                Text = "",
            })
            Create("UICorner", { Parent = SliderBtn, CornerRadius = UDim.new(0, 6) })

            local Fill = Create("Frame", {
                Parent = SliderBtn,
                Size = UDim2.new((sConfig.Default or 0)/(sConfig.Max or 100),0,1,0),
                BackgroundColor3 = Color3.fromRGB(0, 120, 255),
                BorderSizePixel = 0
            })

            local Value = sConfig.Default or 0

            SliderBtn.MouseButton1Down:Connect(function()
                local uis = game:GetService("UserInputService")
                local conn
                conn = uis.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = math.clamp((input.Position.X - SliderBtn.AbsolutePosition.X)/SliderBtn.AbsoluteSize.X,0,1)
                        Value = math.floor((sConfig.Min or 0) + ((sConfig.Max or 100)-(sConfig.Min or 0))*rel)
                        Fill.Size = UDim2.new(rel,0,1,0)
                        Label.Text = (sConfig.Title or "Slider")..": "..Value
                        if sConfig.Callback then sConfig.Callback(Value) end
                    end
                end)
                uis.InputEnded:Wait()
                conn:Disconnect()
            end)
        end

        -- Dropdown
        function Elements:Dropdown(dConfig)
            local Btn = Create("TextButton", {
                Parent = TabPage,
                Size = UDim2.new(0, 200, 0, 30),
                Text = dConfig.Title or "Dropdown",
                BackgroundColor3 = Color3.fromRGB(25, 35, 65),
                TextColor3 = Color3.fromRGB(220, 230, 255),
                Font = Enum.Font.Gotham,
                TextSize = 14
            })
            Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 6) })

            Btn.MouseButton1Click:Connect(function()
                for _,opt in pairs(dConfig.Options or {}) do
                    print("Pilih:", opt)
                end
            end)
        end

        Tabs[#Tabs+1] = { Page = TabPage }
        if #Tabs == 1 then TabPage.Visible = true end
        return Elements
    end

    return Window
end

return StarHub
