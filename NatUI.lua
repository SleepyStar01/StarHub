local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ArdyBotzz/NatHub/refs/heads/master/NatLibrary/Source.lua"))()

local Window = Library:CreateWindow("My Script")

local Tab = Window:AddTab("Main")

Tab:Section({
    Title = "Combat",
    Section = "left"
})

Tab:Toggle({
    Title = "Auto Farm",
    Description = "Automatically farms",
    Flag = "auto_farm",
    Default = false,
    Section = "left",
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

Tab:Button({
    Title = "Kill All",
    Description = "Kills all enemies",
    Section = "left",
    Callback = function()
        print("Killing all!")
    end
})

Tab:Slider({
    Title = "Speed",
    Flag = "speed",
    Default = 16,
    Min = 1,
    Max = 100,
    Section = "left",
    Callback = function(value)
        print("Speed:", value)
    end
})

Tab:Dropdown({
    Title = "Select Weapon",
    Flag = "weapon",
    Options = {"Sword", "Gun", "Fist"},
    Section = "left",
    Callback = function(option)
        print("Selected:", option)
    end
})

Tab:Input({
    Title = "Custom Text",
    Flag = "custom_text",
    Value = "Hello",
    Section = "left",
    Callback = function(text)
        print("Input:", text)
    end
})

Tab:Keybind({
    Title = "Toggle Key",
    Flag = "toggle_key",
    Value = Enum.KeyCode.F,
    Section = "left",
    Callback = function(key)
        print("Key pressed:", key)
    end
})

Tab:Paragraph({
    Title = "Info",
    Content = "This is a paragraph",
    Section = "left"
})
