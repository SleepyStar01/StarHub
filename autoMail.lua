if game.PlaceId ~= 97598239454123 then
    warn("Script ini hanya untuk Grow a Garden 2!")
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Networking = require(ReplicatedStorage.SharedModules.Networking)
local PlayerStateClient = require(ReplicatedStorage.ClientModules.PlayerStateClient)
local MailboxItemCatalog = require(LocalPlayer.PlayerScripts.Controllers.MailboxController.MailboxItemCatalog)
local FruitValueCalc = require(ReplicatedStorage.SharedModules.FruitValueCalc)

local GUI_NAME = "SleepyMailScannerGUI"
if PlayerGui:FindFirstChild(GUI_NAME) then
    PlayerGui[GUI_NAME]:Destroy()
end

-- State
local availableItems = {} -- Array of items {Id/ItemKey, Category, Name, Count, DisplayText, IsFruit, FilterGroup}
local selectedItems = {} -- [ItemKey or Id] = true/false
local isSending = false
local currentFilter = "All" -- "All", "Fruits", "Seeds", "Gears", "Pets"

local MAX_ITEM_PER_SLOT = 99999
local SEND_BATCH_SIZE = 20

-- GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 560)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = " 📦 Advanced Multi-Select Mail Sender"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)
local TitlePadding = Instance.new("UIPadding")
TitlePadding.PaddingLeft = UDim.new(0, 15)
TitlePadding.Parent = Title

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 100, 100)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Title
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local TargetBox = Instance.new("TextBox")
TargetBox.Size = UDim2.new(0.9, 0, 0, 35)
TargetBox.Position = UDim2.new(0.05, 0, 0, 50)
TargetBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetBox.PlaceholderText = "Username Tujuan..."
TargetBox.Text = ""
TargetBox.Font = Enum.Font.Gotham
TargetBox.TextSize = 13
TargetBox.ClearTextOnFocus = false
TargetBox.Parent = MainFrame
Instance.new("UICorner", TargetBox).CornerRadius = UDim.new(0, 5)

-- Toolbar (Select All, Clear, Refresh)
local ToolBar = Instance.new("Frame")
ToolBar.Size = UDim2.new(0.9, 0, 0, 30)
ToolBar.Position = UDim2.new(0.05, 0, 0, 95)
ToolBar.BackgroundTransparency = 1
ToolBar.Parent = MainFrame

local function createMiniBtn(text, color, pos, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.31, 0, 1, 0)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

local RefreshBtn = createMiniBtn("Refresh", Color3.fromRGB(60, 60, 80), UDim2.new(0, 0, 0, 0), ToolBar)
local SelectAllBtn = createMiniBtn("Pilih Semua", Color3.fromRGB(50, 120, 70), UDim2.new(0.345, 0, 0, 0), ToolBar)
local ClearBtn = createMiniBtn("Batal Pilih", Color3.fromRGB(150, 50, 50), UDim2.new(0.69, 0, 0, 0), ToolBar)

-- Category Filters
local FilterBar = Instance.new("Frame")
FilterBar.Size = UDim2.new(0.9, 0, 0, 25)
FilterBar.Position = UDim2.new(0.05, 0, 0, 135)
FilterBar.BackgroundTransparency = 1
FilterBar.Parent = MainFrame

local filterBtns = {}
local filterNames = {"All", "Fruits", "Seeds", "Gears", "Pets"}
local renderList -- forward declare

for i, fName in ipairs(filterNames) do
    local fBtn = Instance.new("TextButton")
    fBtn.Size = UDim2.new(1 / #filterNames - 0.02, 0, 1, 0)
    fBtn.Position = UDim2.new((i - 1) / #filterNames, 0, 0, 0)
    fBtn.BackgroundColor3 = (fName == "All") and Color3.fromRGB(100, 150, 200) or Color3.fromRGB(40, 40, 50)
    fBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fBtn.Text = fName
    fBtn.Font = Enum.Font.GothamMedium
    fBtn.TextSize = 10
    fBtn.Parent = FilterBar
    Instance.new("UICorner", fBtn).CornerRadius = UDim.new(0, 4)
    filterBtns[fName] = fBtn
    
    fBtn.MouseButton1Click:Connect(function()
        currentFilter = fName
        for k, b in pairs(filterBtns) do
            b.BackgroundColor3 = (k == currentFilter) and Color3.fromRGB(100, 150, 200) or Color3.fromRGB(40, 40, 50)
        end
        renderList()
    end)
end

-- Item List
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0.9, 0, 0, 180)
ScrollFrame.Position = UDim2.new(0.05, 0, 0, 170)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.Parent = MainFrame
Instance.new("UICorner", ScrollFrame).CornerRadius = UDim.new(0, 5)

local ScrollList = Instance.new("UIListLayout")
ScrollList.Padding = UDim.new(0, 4)
ScrollList.Parent = ScrollFrame

-- Send Button
local SendBtn = Instance.new("TextButton")
SendBtn.Size = UDim2.new(0.9, 0, 0, 40)
SendBtn.Position = UDim2.new(0.05, 0, 0, 360)
SendBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.Text = "KIRIM ITEM TERPILIH"
SendBtn.Font = Enum.Font.GothamBold
SendBtn.TextSize = 14
SendBtn.Parent = MainFrame
Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0, 5)

-- Logs
local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(0.9, 0, 0, 135)
LogScroll.Position = UDim2.new(0.05, 0, 0, 410)
LogScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LogScroll.BorderSizePixel = 0
LogScroll.ScrollBarThickness = 4
LogScroll.Parent = MainFrame
Instance.new("UICorner", LogScroll).CornerRadius = UDim.new(0, 5)

local LogList = Instance.new("UIListLayout")
LogList.Padding = UDim.new(0, 2)
LogList.Parent = LogScroll

local function addLog(msg, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -5, 0, 15)
    lbl.BackgroundTransparency = 1
    lbl.Text = " " .. msg
    lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = LogScroll
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogList.AbsoluteContentSize.Y)
    LogScroll.CanvasPosition = Vector2.new(0, LogList.AbsoluteContentSize.Y)
end

function renderList()
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local count = 0
    for _, item in ipairs(availableItems) do
        if currentFilter == "All" or item.FilterGroup == currentFilter then
            local Row = Instance.new("Frame")
            Row.Size = UDim2.new(1, -5, 0, 28)
            Row.BackgroundColor3 = selectedItems[item.Id] and Color3.fromRGB(45, 45, 60) or Color3.fromRGB(30, 30, 35)
            Row.BorderSizePixel = 0
            Row.Parent = ScrollFrame
            Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 4)

            local Check = Instance.new("TextLabel")
            Check.Size = UDim2.new(0, 25, 1, 0)
            Check.BackgroundTransparency = 1
            Check.Text = selectedItems[item.Id] and "☑" or "☐"
            Check.TextColor3 = selectedItems[item.Id] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(150, 150, 150)
            Check.TextSize = 18
            Check.Parent = Row

            local NameLbl = Instance.new("TextLabel")
            NameLbl.Size = UDim2.new(1, -100, 1, 0)
            NameLbl.Position = UDim2.new(0, 30, 0, 0)
            NameLbl.BackgroundTransparency = 1
            NameLbl.Text = item.DisplayText
            NameLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            NameLbl.TextSize = 11
            NameLbl.Font = Enum.Font.GothamMedium
            NameLbl.TextXAlignment = Enum.TextXAlignment.Left
            NameLbl.Parent = Row

            local AmtBox = Instance.new("TextBox")
            AmtBox.Size = UDim2.new(0, 60, 0, 20)
            AmtBox.Position = UDim2.new(1, -65, 0.5, -10)
            AmtBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            AmtBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            AmtBox.Text = tostring(item.SendAmount or item.Count)
            AmtBox.Font = Enum.Font.Code
            AmtBox.TextSize = 11
            AmtBox.PlaceholderText = "Jumlah"
            AmtBox.Parent = Row
            Instance.new("UICorner", AmtBox).CornerRadius = UDim.new(0, 4)
            
            AmtBox.FocusLost:Connect(function()
                local num = tonumber((AmtBox.Text:gsub("%D", "")))
                if num and num > 0 then
                    item.SendAmount = math.min(num, item.Count)
                else
                    item.SendAmount = item.Count
                end
                AmtBox.Text = tostring(item.SendAmount)
            end)

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -70, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = Row

            Btn.MouseButton1Click:Connect(function()
                selectedItems[item.Id] = not selectedItems[item.Id]
                renderList()
            end)
            count = count + 1
        end
    end

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 32)
end

local function getFilterGroup(category)
    if category == "HarvestedFruits" or category == "Crops" then return "Fruits" end
    if category == "Seeds" or category == "SeedPacks" then return "Seeds" end
    if category == "Pets" then return "Pets" end
    return "Gears" -- Segala sisanya masuk Gears
end

local function scanInventory()
    availableItems = {}
    
    -- Fetch Stock Multipliers
    local stockMultipliers = {}
    task.spawn(function()
        local ok, result = pcall(function() return Networking.FruitStock.Request:Fire() end)
        if ok and type(result) == "table" and result.entries then
            for fruitName, data in pairs(result.entries) do
                stockMultipliers[fruitName] = data.multiplier or 1
            end
        end
    end)

    local replica = PlayerStateClient:GetLocalReplica()
    if replica and replica.Data and replica.Data.Inventory then
        local inventory = replica.Data.Inventory
        
        -- Scan semua kategori langsung dari database tanpa bergantung pada Catalog
        for category, catData in pairs(inventory) do
            if typeof(catData) == "table" and category ~= "HarvestedFruits" then
                for itemKey, itemData in pairs(catData) do
                    local amount = 0
                    local actualItemKey = itemKey
                    local name = itemKey

                    if typeof(itemData) == "number" then
                        amount = itemData
                    elseif typeof(itemData) == "table" then
                        amount = itemData.Amount or itemData.Count or itemData.Value or 1
                        actualItemKey = itemData.Id or itemData.ItemKey or itemKey
                        name = itemData.Name or itemData.DisplayName or itemData.ItemName or itemKey
                        -- Skip equipped pets
                        if category == "Pets" and itemData.Equipped then
                            continue
                        end
                    end

                    if amount > 0 then
                        table.insert(availableItems, {
                            Id = actualItemKey,
                            Category = category,
                            FilterGroup = getFilterGroup(category),
                            Name = name,
                            Count = amount,
                            IsFruit = false,
                            DisplayText = string.format("[%s] %s (x%d)", category, name, amount)
                        })
                    end
                end
            end
        end
    end

    local function formatPrice(num)
        if type(num) ~= "number" then return "0" end
        if num >= 1e9 then
            return string.format("%.2fB", num / 1e9)
        elseif num >= 1e6 then
            return string.format("%.2fM", num / 1e6)
        elseif num >= 1e3 then
            return string.format("%.2fK", num / 1e3)
        else
            return tostring(math.floor(num))
        end
    end

    -- Scan Harvested Fruits from Backpack & Character
    local function scanFruitsIn(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:GetAttribute("HarvestedFruit") == true then
                local id = item:GetAttribute("Id")
                if id then
                    local weight = item:GetAttribute("Weight") or 0
                    local mutation = item:GetAttribute("Mutation")
                    local mutStr = mutation and (" | " .. mutation) or ""
                    local name = item:GetAttribute("FruitName") or item:GetAttribute("Fruit") or item.Name

                    local fruitData = {
                        Id = id,
                        Category = "HarvestedFruits",
                        FilterGroup = "Fruits",
                        Name = name,
                        Count = 1,
                        IsFruit = true,
                        DisplayText = string.format("[Fruit] %s [%.2fkg]%s", name, weight, mutStr)
                    }
                    table.insert(availableItems, fruitData)

                    -- Async fetch price to prevent freezing
                    task.spawn(function()
                        local decay = item:GetAttribute("DecayAlpha") or 0
                        local success, basePrice = pcall(function()
                            return FruitValueCalc(name, weight, mutation, item, decay)
                        end)
                        if success and type(basePrice) == "number" then
                            -- Wait briefly in case stockMultipliers is still fetching
                            if not stockMultipliers[name] then task.wait(0.5) end
                            local multi = stockMultipliers[name] or 1
                            local finalPrice = math.floor(basePrice * multi)
                            
                            fruitData.Price = finalPrice
                            fruitData.DisplayText = string.format("[Fruit] %s [%.2fkg]%s | 💰 %s", name, weight, mutStr, formatPrice(finalPrice))
                            renderList()
                        end
                    end)
                end
            end
        end
    end

    scanFruitsIn(LocalPlayer.Backpack)
    scanFruitsIn(LocalPlayer.Character)

    -- Cleanup missing items
    local validIds = {}
    for _, v in ipairs(availableItems) do validIds[v.Id] = true end
    for id, _ in pairs(selectedItems) do
        if not validIds[id] then selectedItems[id] = nil end
    end

    renderList()
    addLog(string.format("Scan selesai. Menemukan %d macam item.", #availableItems), Color3.fromRGB(100, 200, 255))
end

RefreshBtn.MouseButton1Click:Connect(scanInventory)
SelectAllBtn.MouseButton1Click:Connect(function()
    for _, item in ipairs(availableItems) do 
        if currentFilter == "All" or item.FilterGroup == currentFilter then
            selectedItems[item.Id] = true 
        end
    end
    renderList()
end)
ClearBtn.MouseButton1Click:Connect(function()
    for _, item in ipairs(availableItems) do 
        if currentFilter == "All" or item.FilterGroup == currentFilter then
            selectedItems[item.Id] = false 
        end
    end
    renderList()
end)

SendBtn.MouseButton1Click:Connect(function()
    if isSending then return end
    
    local targetUser = TargetBox.Text:match("^%s*(.-)%s*$")
    if targetUser == "" then
        addLog("ERROR: Masukkan Username tujuan!", Color3.fromRGB(255, 100, 100))
        return
    end

    local itemsToSend = {}
    for _, item in ipairs(availableItems) do
        if selectedItems[item.Id] then
            table.insert(itemsToSend, item)
        end
    end

    if #itemsToSend == 0 then
        addLog("ERROR: Tidak ada item yang dipilih!", Color3.fromRGB(255, 100, 100))
        return
    end

    isSending = true
    SendBtn.Text = "MEMPROSES PENGIRIMAN..."
    SendBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
    
    task.spawn(function()
        addLog("Mencari ID untuk " .. targetUser .. "...", Color3.fromRGB(200, 200, 100))
        local ok, targetId, displayName = pcall(function()
            return Networking.Mailbox.LookupPlayer:Fire(targetUser)
        end)

        if not ok or not targetId or targetId <= 0 then
            addLog("ERROR: Username tidak ditemukan!", Color3.fromRGB(255, 100, 100))
            isSending = false
            SendBtn.Text = "KIRIM ITEM TERPILIH"
            SendBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
            return
        end

        addLog("Target: " .. displayName .. " (" .. targetId .. ")", Color3.fromRGB(100, 255, 100))

        -- Membentuk Batch
        local batch = {}
        for _, item in ipairs(itemsToSend) do
            local amountLeft = item.SendAmount or item.Count
            while amountLeft > 0 do
                local sendAmount = math.min(amountLeft, MAX_ITEM_PER_SLOT)
                table.insert(batch, {
                    Category = item.Category,
                    ItemKey = item.Id,
                    Count = sendAmount
                })
                amountLeft = amountLeft - sendAmount
            end
        end

        local totalBatches = math.ceil(#batch / SEND_BATCH_SIZE)
        addLog(string.format("Mengirim %d slot (dalam %d batch)", #batch, totalBatches), Color3.fromRGB(200, 200, 200))

        local currentBatch = {}
        for index, bItem in ipairs(batch) do
            table.insert(currentBatch, bItem)

            if #currentBatch == SEND_BATCH_SIZE or index == #batch then
                local batchNum = math.ceil(index / SEND_BATCH_SIZE)
                local success, result = pcall(function()
                    return Networking.Mailbox.SendBatch:Fire(targetId, currentBatch, "Advanced Mail Sender")
                end)

                if success then
                    addLog(string.format("Batch %d/%d terkirim!", batchNum, totalBatches), Color3.fromRGB(100, 255, 100))
                else
                    addLog(string.format("Batch %d GAGAL: %s", batchNum, tostring(result)), Color3.fromRGB(255, 100, 100))
                end

                currentBatch = {}
                if index < #batch then
                    task.wait(6) -- delay between batches
                end
            end
        end

        addLog("Pengiriman selesai!", Color3.fromRGB(100, 255, 255))
        isSending = false
        SendBtn.Text = "KIRIM ITEM TERPILIH"
        SendBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
        
        -- Hapus item yang sudah dikirim dari selection
        for _, item in ipairs(itemsToSend) do
            selectedItems[item.Id] = nil
        end
        scanInventory()
    end)
end)

-- Initial Scan
scanInventory()
