local StarHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/SleepyStar01/StarHubUI/main/library.lua"))()
local Window = StarHub:CreateWindow({
    Title = "StarHub - NathubUI",
    Icon = "rbxassetid://105415760153827",
    Author = "discord.gg/starhub",
    Folder = "StarHub",
    Size = UDim2.fromOffset(560, 400),
    Theme = "Dark"
})

local Tabs = {}
Tabs.Farming    = Window:Tab({ Title = "Farming", Icon = "fish" })
Tabs.Teleport   = Window:Tab({ Title = "Teleport", Icon = "navigation" })
Tabs.Shop       = Window:Tab({ Title = "Shop", Icon = "shopping-bag" })
Tabs.Settings   = Window:Tab({ Title = "Settings", Icon = "settings" })

local statusParagraph = Tabs.Farming:Paragraph({
    Title = "Status: Idle",
    Desc = "Menunggu auto fishing dijalankan..."
})

local fishingSection = Tabs.Farming:Section({
    Title = "Fishing",
    Default = false
})

local equipRodConnection = nil
Tabs.Farming:Toggle({
    Title = "Equip Rod",
    Desc = "Automatically equip fishing rod",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()

        local function equipRod()
            local hasRod = character:FindFirstChildOfClass("Tool")
            if not hasRod then
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Packages")
                    :WaitForChild("_Index")
                    :WaitForChild("sleitnick_net@0.2.0")
                    :WaitForChild("net")
                    :WaitForChild("RE/EquipToolFromHotbar")
                    :FireServer(1) 
            end
        end

        if state then
            equipRod()
            equipRodConnection = character.ChildRemoved:Connect(function(child)
                if child:IsA("Tool") then
                    task.wait(0.2)
                    equipRod()
                end
            end)
        else
            if equipRodConnection then
                equipRodConnection:Disconnect()
                equipRodConnection = nil
            end
            game:GetService("ReplicatedStorage")
                :WaitForChild("Packages")
                :WaitForChild("_Index")
                :WaitForChild("sleitnick_net@0.2.0")
                :WaitForChild("net")
                :WaitForChild("RE/UnequipToolFromHotbar")
                :FireServer()
        end
    end,
    Section = fishingSection
})

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RE_RequestFishing = ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0").net:FindFirstChild("RF/RequestFishingMinigameStarted")
local Old
local perfectEnabled = false

function EnablePerfect()
    if perfectEnabled then return end
    perfectEnabled = true
    Old = hookmetamethod(game, "__namecall", function(Self, ...)
        local Method = getnamecallmethod()
        local Args = {...}
        if Self == RE_RequestFishing and Method == "InvokeServer" then
            Args[2] = 1
            return Old(Self, table.unpack(Args))
        end
        return Old(Self, ...)
    end)
end

function DisablePerfect()
    if not perfectEnabled then return end
    perfectEnabled = false
    if Old then
        hookmetamethod(game, "__namecall", Old)
        Old = nil
    end
end

Tabs.Farming:Dropdown({
    Title = "Perfect Mode",
    Values = { "Normal", "Perfect" },
    Default = "Normal",
    Callback = function(selected)
        if selected == "Perfect" then
            EnablePerfect()
        else
            DisablePerfect()
        end
    end,
    Section = fishingSection
})

local delayBeforeComplete = 1.4
local delayAfterComplete = 0.5
local delayBetweenCycles = 0.1
local delayBetweenLoops = 0.18

Tabs.Farming:Input({
    Title = "Delay 1 (Narik)",
    Desc = "Jeda (detik) antara 'Mulai' dan 'Selesai'.",
    Default = tostring(delayBeforeComplete), 
    Callback = function(text)
        local num = tonumber(text)
        if num then delayBeforeComplete = num end
    end,
    Section = fishingSection
})

Tabs.Farming:Input({
    Title = "Delay 2 (Reset)",
    Desc = "Jeda (detik) antara 'Selesai' dan 'Cancel'.",
    Default = tostring(delayAfterComplete), 
    Callback = function(text)
        local num = tonumber(text)
        if num then delayAfterComplete = num end
    end,
    Section = fishingSection
})

Tabs.Farming:Input({
    Title = "Delay 3 (Jeda Total)",
    Desc = "Jeda (detik) setelah siklus selesai sebelum mengulang.",
    Default = tostring(delayBetweenCycles), 
    Callback = function(text)
        local num = tonumber(text)
        if num then delayBetweenCycles = num end
    end,
    Section = fishingSection
})

Tabs.Farming:Input({
    Title = "Delay 4 (Jeda Step)",
    Desc = "Jeda (detik) antara Pancingan 1 dan Pancingan 2.",
    Default = tostring(delayBetweenLoops), 
    Callback = function(text)
        local num = tonumber(text)
        if num then delayBetweenLoops = num end
    end,
    Section = fishingSection
})

local NetFolder = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local autofishingState = false
local autofishingStopping = false
local autofishingLoop = nil

local function UpdateStatus(msg)
    statusParagraph:SetTitle("Status: " .. msg)
end

local function WaitUntil(targetTime)
    local now = tick()
    if targetTime > now then
        task.wait(targetTime - now)
    end
end

local autofishingToggle = Tabs.Farming:Toggle({
    Title = "Auto Fishing (Ultimate)", 
    Desc = "Double Sequential dengan Timer Anti-Drift (Paling Stabil)",
    Default = false,
    Callback = function(state)
        if state then 
            autofishingState = true
            autofishingStopping = false
            
            autofishingLoop = task.spawn(function()
                local RFChargeFishingRod = NetFolder:WaitForChild("RF/ChargeFishingRod")
                local RFRequestFishingMinigameStarted = NetFolder:WaitForChild("RF/RequestFishingMinigameStarted")
                local RFCancelFishingInputs = NetFolder:WaitForChild("RF/CancelFishingInputs")
                local REFishingCompleted = NetFolder:WaitForChild("RE/FishingCompleted")

                local nextActionTime = tick()

                while autofishingState or autofishingStopping do
                    
                    UpdateStatus("Pancing 1: Mulai...")
                    task.spawn(function()
                        RFChargeFishingRod:InvokeServer(tick(), 0)
                        RFRequestFishingMinigameStarted:InvokeServer(tick(), 0)
                    end)
                    
                    nextActionTime = nextActionTime + delayBeforeComplete
                    WaitUntil(nextActionTime)
                    
                    UpdateStatus("Pancing 1: Menarik...")
                    REFishingCompleted:FireServer()
                    
                    nextActionTime = nextActionTime + delayAfterComplete
                    WaitUntil(nextActionTime)

                    task.spawn(function() RFCancelFishingInputs:InvokeServer() end)

                    nextActionTime = nextActionTime + delayBetweenLoops
                    WaitUntil(nextActionTime)
                    
                    if not autofishingState then break end

                    UpdateStatus("Pancing 2: Mulai...")
                    task.spawn(function()
                        RFChargeFishingRod:InvokeServer(tick(), 0)
                        RFRequestFishingMinigameStarted:InvokeServer(tick(), 0)
                    end)
                    
                    nextActionTime = nextActionTime + delayBeforeComplete
                    WaitUntil(nextActionTime)
                    
                    UpdateStatus("Pancing 2: Menarik...")
                    REFishingCompleted:FireServer()

                    nextActionTime = nextActionTime + delayAfterComplete
                    WaitUntil(nextActionTime)
                    
                    task.spawn(function() RFCancelFishingInputs:InvokeServer() end)
                    
                    nextActionTime = nextActionTime + delayBetweenCycles
                    WaitUntil(nextActionTime)

                    if not autofishingState and autofishingStopping then
                        autofishingStopping = false
                        break
                    end
                end
                UpdateStatus("Idle (Berhenti)")
            end)
        else
            autofishingState = false
            autofishingStopping = true
            UpdateStatus("Menghentikan...")
        end
    end,
    Section = fishingSection 
})

local autoSellAllState = false
local autoSellAllLoop = nil

Tabs.Farming:Toggle({
    Title = "Auto Sell All",
    Desc = "Automatically sells all fish",
    Default = false,
    Callback = function(state)
        autoSellAllState = state
        if state then
            autoSellAllLoop = task.spawn(function()
                local SellAll = game:GetService("ReplicatedStorage")
                    :WaitForChild("Packages")
                    :WaitForChild("_Index")
                    :WaitForChild("sleitnick_net@0.2.0")
                    :WaitForChild("net")
                    :WaitForChild("RF/SellAllItems")

                while autoSellAllState do
                    SellAll:InvokeServer()
                    task.wait(3)
                end
            end)
        else
            if autoSellAllLoop then
                task.cancel(autoSellAllLoop)
                autoSellAllLoop = nil 
            end
        end
    end
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer

Tabs.Teleport:Button({
    Title = "Salin Lokasi & Arah Saat Ini",
    Icon = "copy",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local cf = character.HumanoidRootPart.CFrame
            local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:GetComponents()
            local locationString = string.format("CFrame.new(%.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f)", 
                x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
            setclipboard(locationString)
            StarHub:Notify({ Title = "Lokasi Disalin", Content = "CFrame lengkap tersalin.", Icon = "copy", Duration = 4 })
        else
            StarHub:Notify({ Title = "Error", Content = "Karakter tidak ditemukan.", Icon = "triangle-alert" })
        end
    end
})

Tabs.Teleport:Button({
    Title = "Stingray Shores",
    Icon = "map-pin",
    Callback = function()
        local c = player.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = CFrame.new(33.172035, 9.784896, 2812.972167)
        end
        StarHub:Notify({ Title = "Teleport", Content = "Tiba di Stingray Shores.", Icon = "navigation" })
    end
})

Tabs.Teleport:Button({
    Title = "Tropical Grove",
    Icon = "map-pin",
    Callback = function()
        local c = player.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = CFrame.new(-2049.1499, 6.2690, 3660.3999)
        end
        StarHub:Notify({ Title = "Teleport", Content = "Tiba di Tropical Grove.", Icon = "navigation" })
    end
})

Tabs.Teleport:Button({
    Title = "Kohana Volcana",
    Icon = "map-pin",
    Callback = function()
        local c = player.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = CFrame.new(-588.8510, 47.7704, 205.9920)
        end
        StarHub:Notify({ Title = "Teleport", Content = "Tiba di Kohana Volcana.", Icon = "navigation" })
    end
})

Tabs.Teleport:Button({
    Title = "Lost Isle",
    Icon = "map-pin",
    Callback = function()
        local c = player.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = CFrame.new(-3694.536, -135.574, -1039.203)
        end
        StarHub:Notify({ Title = "Teleport", Content = "Tiba di Lost Isle.", Icon = "navigation" })
    end
})

Tabs.Teleport:Button({
    Title = "Ancient Jungle",
    Icon = "map-pin",
    Callback = function()
        local c = player.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = CFrame.new(1504.6920, 3.8005, -422.9402, 0.8671, 0.0000, -0.4981, 0.0000, 1.0000, 0.0000, 0.4981, 0.0000, 0.8671)
        end
        StarHub:Notify({ Title = "Teleport", Content = "Tiba di Ancient Jungle.", Icon = "navigation" })
    end
})

Tabs.Teleport:Button({
    Title = "Temple",
    Icon = "map-pin",
    Callback = function()
        local c = player.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = CFrame.new(6050.9502, -538.9001, 4370.8809)
        end
        StarHub:Notify({ Title = "Teleport", Content = "Tiba di Temple.", Icon = "navigation" })
    end
})

local systemSection = Tabs.Settings:Section({
    Title = "System",
    Default = true
})

local disableNotifState = false
local disableNotifLoop = nil

Tabs.Settings:Toggle({
    Title = "Disable Game Notifications",
    Desc = "Menyembunyikan notifikasi pop-up di game.",
    Default = false,
    Callback = function(state)
        disableNotifState = state
        local player = game.Players.LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui")
        
        if state then
            StarHub:Notify({ Title = "Notifikasi", Content = "Disembunyikan.", Icon = "eye-off", Duration = 2 })
            disableNotifLoop = task.spawn(function()
                while disableNotifState do
                    local notifGui = playerGui:FindFirstChild("Small Notification")
                    if notifGui and notifGui:FindFirstChild("Display") then
                        notifGui.Display.Visible = false
                    end
                    task.wait(0.5) 
                end
            end)
        else
            if disableNotifLoop then
                task.cancel(disableNotifLoop)
                disableNotifLoop = nil
            end
            local notifGui = playerGui:FindFirstChild("Small Notification")
            if notifGui and notifGui:FindFirstChild("Display") then
                notifGui.Display.Visible = true
            end
            StarHub:Notify({ Title = "Notifikasi", Content = "Ditampilkan kembali.", Icon = "eye", Duration = 2 })
        end
    end,
    Section = systemSection
})

local antiAfkState = false
local antiAfkLoop = nil

Tabs.Settings:Toggle({
    Title = "Anti-AFK",
    Desc = "Mencegah AFK Kick dengan melompat.",
    Default = true,
    Callback = function(state)
        antiAfkState = state
        if state then
            StarHub:Notify({ Title = "Anti-AFK", Content = "Aktif.", Icon = "shield-check" })
            antiAfkLoop = task.spawn(function()
                while antiAfkState do
                    task.wait(60) 
                    if antiAfkState then
                        local c = game.Players.LocalPlayer.Character
                        if c and c:FindFirstChild("Humanoid") then c.Humanoid.Jump = true end
                    end
                end
            end)
        else
            if antiAfkLoop then task.cancel(antiAfkLoop); antiAfkLoop = nil end
            StarHub:Notify({ Title = "Anti-AFK", Content = "Nonaktif.", Icon = "shield-off" })
        end
    end,
    Section = systemSection
})

Window:SelectTab(1)
Window:EditOpenButton({ Enabled = false })
Window:SetToggleKey(Enum.KeyCode.RightControl)
