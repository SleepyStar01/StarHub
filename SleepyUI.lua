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
    Background      = Color3.fromRGB(22, 22, 26),
    Sidebar         = Color3.fromRGB(15, 15, 18),
    Panel           = Color3.fromRGB(22, 22, 26),
    Element         = Color3.fromRGB(32, 32, 38),
    ElementAlt      = Color3.fromRGB(26, 26, 30),
    Border          = Color3.fromRGB(45, 45, 52),
    Hover           = Color3.fromRGB(38, 38, 44),
    Text            = Color3.fromRGB(255, 255, 255),
    TextDim         = Color3.fromRGB(150, 150, 160),
    AccentA         = Color3.fromRGB(160, 110, 255),   -- lighter purple
    AccentB         = Color3.fromRGB(130, 80, 255),    -- deeper purple
    Success         = Color3.fromRGB(85, 220, 140),
    Error           = Color3.fromRGB(255, 95, 105),
    Warn            = Color3.fromRGB(255, 195, 70),
}

--============================================================
-- Lucide Icons
--============================================================
local Lucide = {
    Spritesheets = {
                ['1'] = 'rbxassetid://131526378523863',
                ['10'] = 'rbxassetid://98656588890340',
                ['11'] = 'rbxassetid://122516128999742',
                ['12'] = 'rbxassetid://136045238860745',
                ['13'] = 'rbxassetid://138056954680929',
                ['14'] = 'rbxassetid://139241675471365',
                ['15'] = 'rbxassetid://120281540002144',
                ['16'] = 'rbxassetid://122481504913348',
                ['2'] = 'rbxassetid://125136326597802',
                ['3'] = 'rbxassetid://132619645919851',
                ['4'] = 'rbxassetid://124546836680911',
                ['5'] = 'rbxassetid://138714413596023',
                ['6'] = 'rbxassetid://95318701976229',
                ['7'] = 'rbxassetid://87465848394141',
                ['8'] = 'rbxassetid://77771201330939',
                ['9'] = 'rbxassetid://126006375824005'
            },
            Icons = {['a-arrow-down'] = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['a-arrow-up'] = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['a-large-small'] = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },accessibility = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },activity = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['air-vent'] = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },airplay = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['alarm-clock-check'] = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['alarm-clock-minus'] = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['alarm-clock-off'] = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['alarm-clock-plus'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['alarm-clock'] = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['alarm-smoke'] = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },album = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-center-horizontal'] = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-center-vertical'] = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-center'] = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-end-horizontal'] = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-end-vertical'] = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-horizontal-distribute-center'] = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-horizontal-distribute-end'] = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-horizontal-distribute-start'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-horizontal-justify-center'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-horizontal-justify-end'] = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-horizontal-justify-start'] = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-horizontal-space-around'] = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-horizontal-space-between'] = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-justify'] = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-left'] = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-right'] = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-start-horizontal'] = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-start-vertical'] = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-vertical-distribute-center'] = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-vertical-distribute-end'] = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-vertical-distribute-start'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-vertical-justify-center'] = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-vertical-justify-end'] = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-vertical-justify-start'] = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-vertical-space-around'] = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['align-vertical-space-between'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },ambulance = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },ampersand = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },ampersands = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },amphora = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },anchor = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },angry = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },annoyed = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },antenna = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },anvil = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },aperture = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['app-window-mac'] = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['app-window'] = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },apple = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['archive-restore'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['archive-x'] = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },archive = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },armchair = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-big-down-dash'] = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-big-down'] = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-big-left-dash'] = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-big-left'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-big-right-dash'] = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-big-right'] = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-big-up-dash'] = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-big-up'] = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down-0-1'] = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down-1-0'] = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down-a-z'] = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down-from-line'] = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down-left'] = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down-narrow-wide'] = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down-right'] = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down-to-dot'] = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down-to-line'] = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down-up'] = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down-wide-narrow'] = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down-z-a'] = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-down'] = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-left-from-line'] = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-left-right'] = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-left-to-line'] = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-left'] = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-right-from-line'] = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-right-left'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-right-to-line'] = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-right'] = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up-0-1'] = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up-1-0'] = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up-a-z'] = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up-down'] = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up-from-dot'] = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up-from-line'] = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up-left'] = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up-narrow-wide'] = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up-right'] = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up-to-line'] = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up-wide-narrow'] = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up-z-a'] = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrow-up'] = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },['arrows-up-from-line'] = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 1
                },asterisk = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['at-sign'] = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },atom = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['audio-lines'] = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['audio-waveform'] = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },award = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },axe = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['axis-3d'] = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },baby = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },backpack = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-alert'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-cent'] = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-check'] = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-dollar-sign'] = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-euro'] = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-help'] = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-indian-rupee'] = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-info'] = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-japanese-yen'] = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-minus'] = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-percent'] = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-plus'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-pound-sterling'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-russian-ruble'] = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-swiss-franc'] = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['badge-x'] = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },badge = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['baggage-claim'] = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },ban = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },banana = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bandage = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },banknote = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },barcode = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },baseline = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bath = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['battery-charging'] = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['battery-full'] = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['battery-low'] = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['battery-medium'] = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['battery-plus'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['battery-warning'] = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },battery = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },beaker = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['bean-off'] = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bean = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['bed-double'] = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['bed-single'] = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bed = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },beef = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['beer-off'] = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },beer = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['bell-dot'] = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['bell-electric'] = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['bell-minus'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['bell-off'] = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['bell-plus'] = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['bell-ring'] = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bell = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['between-horizontal-end'] = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['between-horizontal-start'] = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['between-vertical-end'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['between-vertical-start'] = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['biceps-flexed'] = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bike = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },binary = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },binoculars = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },biohazard = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bird = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bitcoin = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },blend = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },blinds = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },blocks = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['bluetooth-connected'] = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['bluetooth-off'] = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['bluetooth-searching'] = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bluetooth = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bold = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bolt = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bomb = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },bone = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-a'] = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-audio'] = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-check'] = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-copy'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-dashed'] = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-down'] = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-headphones'] = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-heart'] = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-image'] = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-key'] = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-lock'] = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-marked'] = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-minus'] = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-open-check'] = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-open-text'] = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-open'] = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-plus'] = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-text'] = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-type'] = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-up-2'] = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 2
                },['book-up'] = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['book-user'] = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['book-x'] = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },book = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['bookmark-check'] = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['bookmark-minus'] = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['bookmark-plus'] = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['bookmark-x'] = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },bookmark = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['boom-box'] = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['bot-message-square'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['bot-off'] = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },bot = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },box = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },boxes = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },braces = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },brackets = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['brain-circuit'] = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['brain-cog'] = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },brain = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['brick-wall'] = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['briefcase-business'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['briefcase-conveyor-belt'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['briefcase-medical'] = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },briefcase = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['bring-to-front'] = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },brush = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['bug-off'] = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['bug-play'] = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },bug = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['building-2'] = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },building = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['bus-front'] = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },bus = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['cable-car'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },cable = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['cake-slice'] = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },cake = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },calculator = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-1'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-arrow-down'] = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-arrow-up'] = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-check-2'] = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-check'] = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-clock'] = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-cog'] = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-days'] = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-fold'] = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-heart'] = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-minus-2'] = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-minus'] = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-off'] = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-plus-2'] = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-plus'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-range'] = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-search'] = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-sync'] = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-x-2'] = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['calendar-x'] = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },calendar = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['camera-off'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },camera = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['candy-cane'] = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['candy-off'] = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },candy = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },cannabis = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['captions-off'] = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },captions = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['car-front'] = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['car-taxi-front'] = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },car = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },caravan = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },carrot = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['case-lower'] = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['case-sensitive'] = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['case-upper'] = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['cassette-tape'] = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },cast = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },castle = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },cat = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },cctv = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-area'] = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-bar-big'] = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-bar-decreasing'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-bar-increasing'] = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-bar-stacked'] = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-bar'] = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-candlestick'] = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-column-big'] = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-column-decreasing'] = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-column-increasing'] = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-column-stacked'] = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-column'] = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-gantt'] = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-line'] = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-network'] = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-no-axes-column-decreasing'] = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-no-axes-column-increasing'] = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-no-axes-column'] = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-no-axes-combined'] = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 3
                },['chart-no-axes-gantt'] = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chart-pie'] = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chart-scatter'] = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chart-spline'] = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['check-check'] = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },check = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chef-hat'] = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },cherry = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevron-down'] = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevron-first'] = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevron-last'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevron-left'] = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevron-right'] = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevron-up'] = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevrons-down-up'] = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevrons-down'] = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevrons-left-right-ellipsis'] = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevrons-left-right'] = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevrons-left'] = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevrons-right-left'] = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevrons-right'] = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevrons-up-down'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['chevrons-up'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },chrome = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },church = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['cigarette-off'] = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },cigarette = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-alert'] = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-arrow-down'] = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-arrow-left'] = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-arrow-out-down-left'] = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-arrow-out-down-right'] = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-arrow-out-up-left'] = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-arrow-out-up-right'] = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-arrow-right'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-arrow-up'] = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-check-big'] = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-check'] = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-chevron-down'] = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-chevron-left'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-chevron-right'] = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-chevron-up'] = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-dashed'] = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-divide'] = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-dollar-sign'] = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-dot-dashed'] = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-dot'] = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-ellipsis'] = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-equal'] = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-fading-arrow-up'] = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-fading-plus'] = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-gauge'] = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-help'] = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-minus'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-off'] = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-parking-off'] = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-parking'] = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-pause'] = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-percent'] = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-play'] = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-plus'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-power'] = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-slash-2'] = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-slash'] = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-stop'] = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-user-round'] = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-user'] = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circle-x'] = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },circle = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['circuit-board'] = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },citrus = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },clapperboard = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clipboard-check'] = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clipboard-copy'] = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clipboard-list'] = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clipboard-minus'] = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clipboard-paste'] = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clipboard-pen-line'] = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clipboard-pen'] = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clipboard-plus'] = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clipboard-type'] = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clipboard-x'] = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },clipboard = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-1'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-10'] = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-11'] = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-12'] = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-2'] = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-3'] = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-4'] = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-5'] = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-6'] = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-7'] = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-8'] = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-9'] = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-alert'] = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-arrow-down'] = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['clock-arrow-up'] = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },clock = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['cloud-alert'] = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 4
                },['cloud-cog'] = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-download'] = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-drizzle'] = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-fog'] = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-hail'] = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-lightning'] = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-moon-rain'] = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-moon'] = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-off'] = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-rain-wind'] = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-rain'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-snow'] = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-sun-rain'] = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-sun'] = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cloud-upload'] = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },cloud = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },cloudy = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },clover = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },club = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['code-xml'] = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },code = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },codepen = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },codesandbox = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },coffee = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },cog = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },coins = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['columns-2'] = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['columns-3'] = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['columns-4'] = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },combine = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },command = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },compass = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },component = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },computer = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['concierge-bell'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },cone = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },construction = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['contact-round'] = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },contact = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },container = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },contrast = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },cookie = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cooking-pot'] = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['copy-check'] = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['copy-minus'] = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['copy-plus'] = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['copy-slash'] = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['copy-x'] = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },copy = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },copyleft = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },copyright = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['corner-down-left'] = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['corner-down-right'] = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['corner-left-down'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['corner-left-up'] = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['corner-right-down'] = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['corner-right-up'] = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['corner-up-left'] = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['corner-up-right'] = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },cpu = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['creative-commons'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['credit-card'] = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },croissant = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },crop = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },cross = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },crosshair = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },crown = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },cuboid = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['cup-soda'] = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },currency = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },cylinder = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },dam = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['database-backup'] = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['database-zap'] = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },database = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },delete = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },dessert = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },diameter = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['diamond-minus'] = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['diamond-percent'] = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['diamond-plus'] = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },diamond = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['dice-1'] = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['dice-2'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['dice-3'] = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['dice-4'] = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['dice-5'] = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['dice-6'] = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },dices = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },diff = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['disc-2'] = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['disc-3'] = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['disc-album'] = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },disc = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },divide = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['dna-off'] = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },dna = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },dock = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },dog = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },['dollar-sign'] = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 5
                },donut = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['door-closed'] = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['door-open'] = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },dot = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },download = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['drafting-compass'] = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },drama = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },dribbble = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },drill = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['droplet-off'] = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },droplet = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },droplets = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },drum = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },drumstick = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },dumbbell = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['ear-off'] = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },ear = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['earth-lock'] = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },earth = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },eclipse = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['egg-fried'] = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['egg-off'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },egg = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['ellipsis-vertical'] = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },ellipsis = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['equal-approximately'] = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['equal-not'] = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },equal = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },eraser = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['ethernet-port'] = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },euro = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },expand = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['external-link'] = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['eye-closed'] = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['eye-off'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },eye = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },facebook = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },factory = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },fan = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['fast-forward'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },feather = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },fence = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['ferris-wheel'] = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },figma = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-archive'] = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-audio-2'] = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-audio'] = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-axis-3d'] = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-badge-2'] = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-badge'] = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-box'] = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-chart-column-increasing'] = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-chart-column'] = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-chart-line'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-chart-pie'] = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-check-2'] = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-check'] = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-clock'] = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-code-2'] = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-code'] = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-cog'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-diff'] = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-digit'] = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-down'] = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-heart'] = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-image'] = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-input'] = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-json-2'] = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-json'] = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-key-2'] = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-key'] = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-lock-2'] = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-lock'] = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-minus-2'] = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-minus'] = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-music'] = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-output'] = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-pen-line'] = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-pen'] = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-plus-2'] = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-plus'] = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-question'] = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-scan'] = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-search-2'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-search'] = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-sliders'] = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-spreadsheet'] = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-stack'] = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-symlink'] = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-terminal'] = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-text'] = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-type-2'] = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-type'] = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-up'] = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-user'] = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-video-2'] = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-video'] = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-volume-2'] = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-volume'] = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-warning'] = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 6
                },['file-x-2'] = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['file-x'] = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },file = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },files = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },film = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['filter-x'] = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },filter = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },fingerprint = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['fire-extinguisher'] = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['fish-off'] = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['fish-symbol'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },fish = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flag-off'] = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flag-triangle-left'] = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flag-triangle-right'] = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },flag = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flame-kindling'] = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },flame = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flashlight-off'] = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },flashlight = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flask-conical-off'] = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flask-conical'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flask-round'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flip-horizontal-2'] = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flip-horizontal'] = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flip-vertical-2'] = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flip-vertical'] = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['flower-2'] = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },flower = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },focus = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['fold-horizontal'] = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['fold-vertical'] = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-archive'] = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-check'] = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-clock'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-closed'] = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-code'] = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-cog'] = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-dot'] = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-down'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-git-2'] = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-git'] = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-heart'] = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-input'] = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-kanban'] = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-key'] = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-lock'] = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-minus'] = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-open-dot'] = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-open'] = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-output'] = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-pen'] = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-plus'] = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-root'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-search-2'] = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-search'] = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-symlink'] = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-sync'] = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-tree'] = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-up'] = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['folder-x'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },folder = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },folders = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },footprints = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },forklift = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },forward = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },frame = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },framer = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },frown = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },fuel = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },fullscreen = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['gallery-horizontal-end'] = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['gallery-horizontal'] = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['gallery-thumbnails'] = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['gallery-vertical-end'] = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['gallery-vertical'] = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['gamepad-2'] = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },gamepad = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },gauge = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },gavel = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },gem = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },ghost = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },gift = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-branch-plus'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-branch'] = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-commit-horizontal'] = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-commit-vertical'] = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-compare-arrows'] = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-compare'] = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-fork'] = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-graph'] = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-merge'] = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-pull-request-arrow'] = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-pull-request-closed'] = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-pull-request-create-arrow'] = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-pull-request-create'] = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-pull-request-draft'] = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['git-pull-request'] = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },github = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },gitlab = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 7
                },['glass-water'] = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },glasses = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['globe-lock'] = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },globe = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },goal = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },grab = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['graduation-cap'] = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },grape = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['grid-2x2-check'] = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['grid-2x2-plus'] = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['grid-2x2-x'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['grid-2x2'] = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['grid-3x3'] = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['grip-horizontal'] = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['grip-vertical'] = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },grip = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },group = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },guitar = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },ham = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },hammer = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['hand-coins'] = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['hand-heart'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['hand-helping'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['hand-metal'] = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['hand-platter'] = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },hand = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },handshake = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['hard-drive-download'] = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['hard-drive-upload'] = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['hard-drive'] = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['hard-hat'] = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },hash = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },haze = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['hdmi-port'] = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['heading-1'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['heading-2'] = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['heading-3'] = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['heading-4'] = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['heading-5'] = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['heading-6'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },heading = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['headphone-off'] = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },headphones = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },headset = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['heart-crack'] = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['heart-handshake'] = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['heart-off'] = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['heart-pulse'] = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },heart = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },heater = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },hexagon = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },highlighter = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },history = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['hop-off'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },hop = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },hospital = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },hotel = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },hourglass = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['house-plug'] = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['house-plus'] = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['house-wifi'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },house = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['ice-cream-bowl'] = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['ice-cream-cone'] = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['id-card'] = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['image-down'] = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['image-minus'] = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['image-off'] = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['image-play'] = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['image-plus'] = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['image-up'] = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['image-upscale'] = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },image = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },images = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },import = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },inbox = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['indent-decrease'] = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['indent-increase'] = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['indian-rupee'] = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },infinity = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },info = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['inspection-panel'] = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },instagram = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },italic = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['iteration-ccw'] = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['iteration-cw'] = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['japanese-yen'] = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },joystick = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },kanban = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['key-round'] = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['key-square'] = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },key = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['keyboard-music'] = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['keyboard-off'] = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },keyboard = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['lamp-ceiling'] = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['lamp-desk'] = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['lamp-floor'] = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['lamp-wall-down'] = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },['lamp-wall-up'] = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 8
                },lamp = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['land-plot'] = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },landmark = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },languages = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['laptop-minimal-check'] = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['laptop-minimal'] = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },laptop = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['lasso-select'] = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },lasso = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },laugh = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['layers-2'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },layers = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['layout-dashboard'] = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['layout-grid'] = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['layout-list'] = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['layout-panel-left'] = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['layout-panel-top'] = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['layout-template'] = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },leaf = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['leafy-green'] = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },lectern = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['letter-text'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['library-big'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },library = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['life-buoy'] = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },ligature = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['lightbulb-off'] = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },lightbulb = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['link-2-off'] = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['link-2'] = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },link = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },linkedin = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-check'] = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-checks'] = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-collapse'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-end'] = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-filter-plus'] = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-filter'] = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-minus'] = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-music'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-ordered'] = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-plus'] = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-restart'] = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-start'] = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-todo'] = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-tree'] = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-video'] = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['list-x'] = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },list = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['loader-circle'] = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['loader-pinwheel'] = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },loader = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['locate-fixed'] = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['locate-off'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },locate = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['lock-keyhole-open'] = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['lock-keyhole'] = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['lock-open'] = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },lock = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['log-in'] = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['log-out'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },logs = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },lollipop = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },luggage = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },magnet = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['mail-check'] = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['mail-minus'] = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['mail-open'] = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['mail-plus'] = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['mail-question'] = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['mail-search'] = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['mail-warning'] = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['mail-x'] = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },mail = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },mailbox = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },mails = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-pin-check-inside'] = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-pin-check'] = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-pin-house'] = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-pin-minus-inside'] = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-pin-minus'] = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-pin-off'] = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-pin-plus-inside'] = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-pin-plus'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-pin-x-inside'] = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-pin-x'] = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-pin'] = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-pinned'] = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['map-plus'] = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },map = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },martini = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['maximize-2'] = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },maximize = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },medal = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['megaphone-off'] = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },megaphone = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },meh = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['memory-stick'] = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },menu = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },merge = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 9
                },['message-circle-code'] = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-circle-dashed'] = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-circle-heart'] = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-circle-more'] = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-circle-off'] = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-circle-plus'] = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-circle-question'] = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-circle-reply'] = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-circle-warning'] = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-circle-x'] = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-circle'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-code'] = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-dashed'] = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-diff'] = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-dot'] = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-heart'] = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-lock'] = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-more'] = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-off'] = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-plus'] = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-quote'] = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-reply'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-share'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-text'] = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-warning'] = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square-x'] = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['message-square'] = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['messages-square'] = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['mic-off'] = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['mic-vocal'] = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },mic = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },microchip = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },microscope = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },microwave = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },milestone = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['milk-off'] = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },milk = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['minimize-2'] = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },minimize = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },minus = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['monitor-check'] = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['monitor-cog'] = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['monitor-dot'] = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['monitor-down'] = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['monitor-off'] = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['monitor-pause'] = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['monitor-play'] = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['monitor-smartphone'] = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['monitor-speaker'] = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['monitor-stop'] = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['monitor-up'] = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['monitor-x'] = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },monitor = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['moon-star'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },moon = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['mountain-snow'] = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },mountain = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['mouse-off'] = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['mouse-pointer-2'] = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['mouse-pointer-ban'] = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['mouse-pointer-click'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['mouse-pointer'] = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },mouse = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-3d'] = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-diagonal-2'] = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-diagonal'] = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-down-left'] = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-down-right'] = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-down'] = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-horizontal'] = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-left'] = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-right'] = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-up-left'] = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-up-right'] = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-up'] = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['move-vertical'] = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },move = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['music-2'] = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['music-3'] = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['music-4'] = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },music = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['navigation-2-off'] = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['navigation-2'] = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['navigation-off'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },navigation = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },network = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },newspaper = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },nfc = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['notebook-pen'] = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['notebook-tabs'] = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['notebook-text'] = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },notebook = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['notepad-text-dashed'] = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['notepad-text'] = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['nut-off'] = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },nut = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['octagon-alert'] = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['octagon-minus'] = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['octagon-pause'] = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },['octagon-x'] = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 10
                },octagon = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },omega = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },option = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },orbit = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },origami = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['package-2'] = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['package-check'] = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['package-minus'] = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['package-open'] = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['package-plus'] = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['package-search'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['package-x'] = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },package = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['paint-bucket'] = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['paint-roller'] = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['paintbrush-vertical'] = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },paintbrush = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },palette = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-bottom-close'] = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-bottom-dashed'] = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-bottom-open'] = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-bottom'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-left-close'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-left-dashed'] = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-left-open'] = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-left'] = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-right-close'] = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-right-dashed'] = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-right-open'] = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-right'] = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-top-close'] = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-top-dashed'] = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-top-open'] = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panel-top'] = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panels-left-bottom'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panels-right-bottom'] = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['panels-top-left'] = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },paperclip = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },parentheses = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['parking-meter'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['party-popper'] = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pause = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['paw-print'] = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pc-case'] = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pen-line'] = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pen-off'] = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pen-tool'] = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pen = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pencil-line'] = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pencil-off'] = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pencil-ruler'] = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pencil = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pentagon = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },percent = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['person-standing'] = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['philippine-peso'] = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['phone-call'] = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['phone-forwarded'] = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['phone-incoming'] = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['phone-missed'] = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['phone-off'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['phone-outgoing'] = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },phone = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pi = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },piano = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pickaxe = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['picture-in-picture-2'] = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['picture-in-picture'] = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['piggy-bank'] = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pilcrow-left'] = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pilcrow-right'] = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pilcrow = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pill-bottle'] = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pill = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pin-off'] = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pin = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pipette = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pizza = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['plane-landing'] = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['plane-takeoff'] = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },plane = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },play = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['plug-2'] = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['plug-zap'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },plug = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },plus = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pocket-knife'] = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pocket = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },podcast = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pointer-off'] = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },pointer = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },popcorn = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },popsicle = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['pound-sterling'] = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['power-off'] = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },power = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },presentation = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },['printer-check'] = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },printer = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },projector = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 11
                },proportions = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },puzzle = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },pyramid = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['qr-code'] = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },quote = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },rabbit = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },radar = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },radiation = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },radical = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['radio-receiver'] = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['radio-tower'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },radio = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },radius = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rail-symbol'] = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },rainbow = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },rat = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },ratio = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['receipt-cent'] = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['receipt-euro'] = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['receipt-indian-rupee'] = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['receipt-japanese-yen'] = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['receipt-pound-sterling'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['receipt-russian-ruble'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['receipt-swiss-franc'] = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['receipt-text'] = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },receipt = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rectangle-ellipsis'] = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rectangle-horizontal'] = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rectangle-vertical'] = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },recycle = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['redo-2'] = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['redo-dot'] = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },redo = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['refresh-ccw-dot'] = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['refresh-ccw'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['refresh-cw-off'] = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['refresh-cw'] = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },refrigerator = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },regex = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['remove-formatting'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['repeat-1'] = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['repeat-2'] = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['repeat'] = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['replace-all'] = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },replace = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['reply-all'] = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },reply = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },rewind = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },ribbon = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },rocket = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rocking-chair'] = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['roller-coaster'] = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rotate-3d'] = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rotate-ccw-square'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rotate-ccw'] = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rotate-cw-square'] = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rotate-cw'] = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['route-off'] = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },route = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },router = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rows-2'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rows-3'] = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['rows-4'] = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },rss = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },ruler = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['russian-ruble'] = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },sailboat = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },salad = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },sandwich = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['satellite-dish'] = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },satellite = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['save-all'] = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['save-off'] = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },save = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['scale-3d'] = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },scale = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },scaling = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['scan-barcode'] = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['scan-eye'] = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['scan-face'] = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['scan-heart'] = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['scan-line'] = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['scan-qr-code'] = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['scan-search'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['scan-text'] = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },scan = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },school = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['scissors-line-dashed'] = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },scissors = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['screen-share-off'] = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['screen-share'] = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['scroll-text'] = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },scroll = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['search-check'] = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['search-code'] = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['search-slash'] = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['search-x'] = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },search = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },section = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['send-horizontal'] = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 12
                },['send-to-back'] = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },send = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['separator-horizontal'] = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['separator-vertical'] = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['server-cog'] = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['server-crash'] = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['server-off'] = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },server = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['settings-2'] = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },settings = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },shapes = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['share-2'] = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },share = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },sheet = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },shell = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shield-alert'] = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shield-ban'] = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shield-check'] = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shield-ellipsis'] = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shield-half'] = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shield-minus'] = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shield-off'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shield-plus'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shield-question'] = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shield-x'] = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },shield = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['ship-wheel'] = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },ship = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },shirt = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shopping-bag'] = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shopping-basket'] = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shopping-cart'] = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },shovel = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['shower-head'] = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },shrink = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },shrub = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },shuffle = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },sigma = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['signal-high'] = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['signal-low'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['signal-medium'] = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['signal-zero'] = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },signal = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },signature = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['signpost-big'] = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },signpost = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },siren = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['skip-back'] = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['skip-forward'] = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },skull = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },slack = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },slash = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },slice = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['sliders-horizontal'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['sliders-vertical'] = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['smartphone-charging'] = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['smartphone-nfc'] = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },smartphone = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['smile-plus'] = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },smile = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },snail = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },snowflake = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },sofa = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },soup = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },space = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },spade = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },sparkle = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },sparkles = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },speaker = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },speech = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['spell-check-2'] = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['spell-check'] = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },spline = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },split = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['spray-can'] = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },sprout = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-activity'] = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-arrow-down-left'] = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-arrow-down-right'] = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-arrow-down'] = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-arrow-left'] = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-arrow-out-down-left'] = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-arrow-out-down-right'] = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-arrow-out-up-left'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-arrow-out-up-right'] = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-arrow-right'] = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-arrow-up-left'] = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-arrow-up-right'] = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-arrow-up'] = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-asterisk'] = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-bottom-dashed-scissors'] = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-chart-gantt'] = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-check-big'] = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-check'] = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-chevron-down'] = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-chevron-left'] = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-chevron-right'] = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-chevron-up'] = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-code'] = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-dashed-bottom-code'] = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 13
                },['square-dashed-bottom'] = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-dashed-kanban'] = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-dashed-mouse-pointer'] = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-dashed'] = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-divide'] = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-dot'] = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-equal'] = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-function'] = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-kanban'] = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-library'] = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-m'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-menu'] = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-minus'] = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-mouse-pointer'] = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-parking-off'] = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-parking'] = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-pen'] = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-percent'] = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-pi'] = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-pilcrow'] = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-play'] = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-plus'] = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-power'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-radical'] = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-scissors'] = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-sigma'] = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-slash'] = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-split-horizontal'] = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-split-vertical'] = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-square'] = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-stack'] = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-terminal'] = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-user-round'] = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-user'] = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['square-x'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },square = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },squircle = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },squirrel = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },stamp = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['star-half'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['star-off'] = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },star = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['step-back'] = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['step-forward'] = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },stethoscope = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },sticker = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['sticky-note'] = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },store = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['stretch-horizontal'] = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['stretch-vertical'] = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },strikethrough = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },subscript = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['sun-dim'] = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['sun-medium'] = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['sun-moon'] = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['sun-snow'] = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },sun = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },sunrise = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },sunset = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },superscript = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['swatch-book'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['swiss-franc'] = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['switch-camera'] = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },sword = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },swords = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },syringe = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['table-2'] = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['table-cells-merge'] = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['table-cells-split'] = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['table-columns-split'] = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['table-of-contents'] = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['table-properties'] = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['table-rows-split'] = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },table = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['tablet-smartphone'] = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },tablet = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },tablets = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },tag = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },tags = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['tally-1'] = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['tally-2'] = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['tally-3'] = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['tally-4'] = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['tally-5'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },tangent = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },target = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },telescope = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['tent-tree'] = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },tent = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },terminal = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['test-tube-diagonal'] = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['test-tube'] = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['test-tubes'] = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['text-cursor-input'] = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['text-cursor'] = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['text-quote'] = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['text-search'] = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['text-select'] = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },text = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },theater = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 14
                },['thermometer-snowflake'] = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['thermometer-sun'] = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },thermometer = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['thumbs-down'] = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['thumbs-up'] = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['ticket-check'] = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['ticket-minus'] = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['ticket-percent'] = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['ticket-plus'] = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['ticket-slash'] = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['ticket-x'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },ticket = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['tickets-plane'] = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },tickets = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['timer-off'] = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['timer-reset'] = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },timer = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['toggle-left'] = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['toggle-right'] = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },toilet = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },tornado = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },torus = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['touchpad-off'] = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },touchpad = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['tower-control'] = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['toy-brick'] = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },tractor = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['traffic-cone'] = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['train-front-tunnel'] = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['train-front'] = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['train-track'] = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['tram-front'] = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['trash-2'] = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },trash = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['tree-deciduous'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['tree-palm'] = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['tree-pine'] = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },trees = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },trello = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['trending-down'] = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['trending-up-down'] = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['trending-up'] = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['triangle-alert'] = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['triangle-dashed'] = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['triangle-right'] = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },triangle = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },trophy = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },truck = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },turtle = {
                    ImageRectPosition = Vector2.new(768, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['tv-minimal-play'] = {
                    ImageRectPosition = Vector2.new(864, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['tv-minimal'] = {
                    ImageRectPosition = Vector2.new(0, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },tv = {
                    ImageRectPosition = Vector2.new(96, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },twitch = {
                    ImageRectPosition = Vector2.new(192, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },twitter = {
                    ImageRectPosition = Vector2.new(288, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['type-outline'] = {
                    ImageRectPosition = Vector2.new(384, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },type = {
                    ImageRectPosition = Vector2.new(480, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['umbrella-off'] = {
                    ImageRectPosition = Vector2.new(576, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },umbrella = {
                    ImageRectPosition = Vector2.new(672, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },underline = {
                    ImageRectPosition = Vector2.new(768, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['undo-2'] = {
                    ImageRectPosition = Vector2.new(864, 480),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['undo-dot'] = {
                    ImageRectPosition = Vector2.new(0, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },undo = {
                    ImageRectPosition = Vector2.new(96, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['unfold-horizontal'] = {
                    ImageRectPosition = Vector2.new(192, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['unfold-vertical'] = {
                    ImageRectPosition = Vector2.new(288, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },ungroup = {
                    ImageRectPosition = Vector2.new(384, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },university = {
                    ImageRectPosition = Vector2.new(480, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['unlink-2'] = {
                    ImageRectPosition = Vector2.new(576, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },unlink = {
                    ImageRectPosition = Vector2.new(672, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },unplug = {
                    ImageRectPosition = Vector2.new(768, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },upload = {
                    ImageRectPosition = Vector2.new(864, 576),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },usb = {
                    ImageRectPosition = Vector2.new(0, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-check'] = {
                    ImageRectPosition = Vector2.new(96, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-cog'] = {
                    ImageRectPosition = Vector2.new(192, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-minus'] = {
                    ImageRectPosition = Vector2.new(288, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-pen'] = {
                    ImageRectPosition = Vector2.new(384, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-plus'] = {
                    ImageRectPosition = Vector2.new(480, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-round-check'] = {
                    ImageRectPosition = Vector2.new(576, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-round-cog'] = {
                    ImageRectPosition = Vector2.new(672, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-round-minus'] = {
                    ImageRectPosition = Vector2.new(768, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-round-pen'] = {
                    ImageRectPosition = Vector2.new(864, 672),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-round-plus'] = {
                    ImageRectPosition = Vector2.new(0, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-round-search'] = {
                    ImageRectPosition = Vector2.new(96, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-round-x'] = {
                    ImageRectPosition = Vector2.new(192, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-round'] = {
                    ImageRectPosition = Vector2.new(288, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-search'] = {
                    ImageRectPosition = Vector2.new(384, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['user-x'] = {
                    ImageRectPosition = Vector2.new(480, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },user = {
                    ImageRectPosition = Vector2.new(576, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['users-round'] = {
                    ImageRectPosition = Vector2.new(672, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },users = {
                    ImageRectPosition = Vector2.new(768, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['utensils-crossed'] = {
                    ImageRectPosition = Vector2.new(864, 768),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },utensils = {
                    ImageRectPosition = Vector2.new(0, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['utility-pole'] = {
                    ImageRectPosition = Vector2.new(96, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },variable = {
                    ImageRectPosition = Vector2.new(192, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },vault = {
                    ImageRectPosition = Vector2.new(288, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },vegan = {
                    ImageRectPosition = Vector2.new(384, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['venetian-mask'] = {
                    ImageRectPosition = Vector2.new(480, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['vibrate-off'] = {
                    ImageRectPosition = Vector2.new(576, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },vibrate = {
                    ImageRectPosition = Vector2.new(672, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },['video-off'] = {
                    ImageRectPosition = Vector2.new(768, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },video = {
                    ImageRectPosition = Vector2.new(864, 864),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 15
                },videotape = {
                    ImageRectPosition = Vector2.new(0, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },view = {
                    ImageRectPosition = Vector2.new(96, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },voicemail = {
                    ImageRectPosition = Vector2.new(192, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },volleyball = {
                    ImageRectPosition = Vector2.new(288, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['volume-1'] = {
                    ImageRectPosition = Vector2.new(384, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['volume-2'] = {
                    ImageRectPosition = Vector2.new(480, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['volume-off'] = {
                    ImageRectPosition = Vector2.new(576, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['volume-x'] = {
                    ImageRectPosition = Vector2.new(672, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },volume = {
                    ImageRectPosition = Vector2.new(768, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },vote = {
                    ImageRectPosition = Vector2.new(864, 0),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['wallet-cards'] = {
                    ImageRectPosition = Vector2.new(0, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['wallet-minimal'] = {
                    ImageRectPosition = Vector2.new(96, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },wallet = {
                    ImageRectPosition = Vector2.new(192, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },wallpaper = {
                    ImageRectPosition = Vector2.new(288, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['wand-sparkles'] = {
                    ImageRectPosition = Vector2.new(384, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },wand = {
                    ImageRectPosition = Vector2.new(480, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },warehouse = {
                    ImageRectPosition = Vector2.new(576, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['washing-machine'] = {
                    ImageRectPosition = Vector2.new(672, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },watch = {
                    ImageRectPosition = Vector2.new(768, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['waves-ladder'] = {
                    ImageRectPosition = Vector2.new(864, 96),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },waves = {
                    ImageRectPosition = Vector2.new(0, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },waypoints = {
                    ImageRectPosition = Vector2.new(96, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },webcam = {
                    ImageRectPosition = Vector2.new(192, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['webhook-off'] = {
                    ImageRectPosition = Vector2.new(288, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },webhook = {
                    ImageRectPosition = Vector2.new(384, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },weight = {
                    ImageRectPosition = Vector2.new(480, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['wheat-off'] = {
                    ImageRectPosition = Vector2.new(576, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },wheat = {
                    ImageRectPosition = Vector2.new(672, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['whole-word'] = {
                    ImageRectPosition = Vector2.new(768, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['wifi-high'] = {
                    ImageRectPosition = Vector2.new(864, 192),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['wifi-low'] = {
                    ImageRectPosition = Vector2.new(0, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['wifi-off'] = {
                    ImageRectPosition = Vector2.new(96, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['wifi-zero'] = {
                    ImageRectPosition = Vector2.new(192, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },wifi = {
                    ImageRectPosition = Vector2.new(288, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['wind-arrow-down'] = {
                    ImageRectPosition = Vector2.new(384, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },wind = {
                    ImageRectPosition = Vector2.new(480, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['wine-off'] = {
                    ImageRectPosition = Vector2.new(576, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },wine = {
                    ImageRectPosition = Vector2.new(672, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },workflow = {
                    ImageRectPosition = Vector2.new(768, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },worm = {
                    ImageRectPosition = Vector2.new(864, 288),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['wrap-text'] = {
                    ImageRectPosition = Vector2.new(0, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },wrench = {
                    ImageRectPosition = Vector2.new(96, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },x = {
                    ImageRectPosition = Vector2.new(192, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },youtube = {
                    ImageRectPosition = Vector2.new(288, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['zap-off'] = {
                    ImageRectPosition = Vector2.new(384, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },zap = {
                    ImageRectPosition = Vector2.new(480, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['zoom-in'] = {
                    ImageRectPosition = Vector2.new(576, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                },['zoom-out'] = {
                    ImageRectPosition = Vector2.new(672, 384),
                    ImageRectSize = Vector2.new(96, 96),
                    Image = 16
                }}
        
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
-- Core Framework (Replaces everything from line 6318 onwards)
--============================================================

-- Global debug flag
PulseUI.Debug = false

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok and PulseUI.Debug then
        warn("[PulseUI] Callback error: " .. tostring(err))
    end
end

-- Cached game name for getConfigPath
local _cachedGameName = nil

local function getConfigPath(name)
    if not isfolder or not makefolder then return "", "" end
    if not _cachedGameName then
        local success, info = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        end)
        if success and info and info.Name then
            _cachedGameName = info.Name:gsub("[^%w%s]", ""):gsub("%s+", "")
        else
            _cachedGameName = tostring(game.GameId)
        end
    end
    
    local basePath = "PulseUI"
    local gamePath = basePath .. "/" .. _cachedGameName
    if not isfolder(basePath) then pcall(makefolder, basePath) end
    if not isfolder(gamePath) then pcall(makefolder, gamePath) end
    return gamePath .. "/" .. name .. ".json", gamePath
end

-- Config helpers (Stateless parts)
local function getConfigsList()
    local list = {}
    if listfiles then
        local _, gamePath = getConfigPath("")
        local s, files = pcall(listfiles, gamePath)
        if s and type(files) == "table" then
            for _, file in ipairs(files) do
                if file:match("%.json$") then
                    local name = file:match("([^/\\]+)%.json$")
                    if name then table.insert(list, name) end
                end
            end
        end
    end
    return list
end

--============================================================
-- CreateWindow
--============================================================
function PulseUI:CreateWindow(config)
    config = config or {}
    local Window = {}
    
    local _destroyed = false
    local _connections = {}
    local FlagStore = {}
    local ComponentsRegistry = {}
    
    local function addConnection(conn)
        table.insert(_connections, conn)
        return conn
    end
    
    local function disconnectAll()
        for _, conn in ipairs(_connections) do
            pcall(function() conn:Disconnect() end)
        end
        table.clear(_connections)
    end
    
    -- Shared Input Handling
    local _activeDragger = nil
    
    local dragInput, dragStart, startPos
    local dragging = false
    
    local dragMinInput, dragMinStart, startMinPos
    local dragMin = false
    
    local resizing = false
    local resizeStart, startSize
    
    addConnection(UserInputService.InputChanged:Connect(function(input)
        local isMove = (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
        
        -- Active slider / colorpicker
        if _activeDragger and isMove then
            _activeDragger(input)
        end
        
        -- Window drag
        if dragging and isMove then
            local delta = input.Position - dragStart
            tw(Window.MainFrame, TweenInfo.new(0.1), { Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) })
        end
        
        -- MinIcon drag
        if dragMin and isMove then
            local delta = input.Position - dragMinStart
            tw(Window.MinIcon, TweenInfo.new(0.1), { Position = UDim2.new(startMinPos.X.Scale, startMinPos.X.Offset + delta.X, startMinPos.Y.Scale, startMinPos.Y.Offset + delta.Y) })
        end
        
        -- Window resize
        if resizing and isMove then
            local delta = input.Position - resizeStart
            local newX = math.clamp(startSize.X.Offset + delta.X, 400, 1000)
            local newY = math.clamp(startSize.Y.Offset + delta.Y, 250, 800)
            tw(Window.MainFrame, TweenInfo.new(0.1), { Size = UDim2.new(0, newX, 0, newY) })
        end
    end))
    
    addConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _activeDragger = nil
            dragging = false
            dragMin = false
            resizing = false
        end
    end))
    
    -- UI hierarchy creation
    local ScreenGui = new("ScreenGui", { Name = "PulseUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui:FindFirstChild("RobloxGui") or CoreGui)
    local Overlay = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 100, Visible = false, Text = "", AutoButtonColor = false }, ScreenGui)
    
    -- Overlay click logic (shared)
    local _overlayClickHandler = nil
    addConnection(Overlay.MouseButton1Click:Connect(function()
        if _overlayClickHandler then _overlayClickHandler() end
    end))
    
    local function openOverlay(handler)
        _overlayClickHandler = handler
        Overlay.Visible = true
    end
    
    local function closeOverlays()
        Overlay.Visible = false
        _overlayClickHandler = nil
        for _, child in ipairs(Overlay:GetChildren()) do
            if child:IsA("Frame") then child.Visible = false end
        end
    end
    
    local ToastHolder = new("Frame", { Size = UDim2.new(0, 300, 1, -20), Position = UDim2.new(1, -320, 0, 20), BackgroundTransparency = 1 }, ScreenGui)
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom }, ToastHolder)
    
    local Watermark = new("Frame", { Size = UDim2.new(0, 200, 0, 30), Position = UDim2.new(0, 20, 0, -40), BackgroundColor3 = Theme.Element, Visible = false }, ScreenGui)
    corner(Watermark, UDim.new(0, 6))
    stroke(Watermark)
    local wmText = new("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.BuilderSansMedium, TextSize = 13 }, Watermark)
    
    local MinIcon = new("ImageButton", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0.5, -20, 0, -50), BackgroundColor3 = Theme.Element, AutoButtonColor = false, Visible = false }, ScreenGui)
    corner(MinIcon, UDim.new(1, 0))
    stroke(MinIcon)
    local miImage = new("ImageLabel", { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0.5, -12, 0.5, -12), BackgroundTransparency = 1, Image = "rbxassetid://10709798164", ImageColor3 = Theme.AccentA }, MinIcon)
    
    local MainFrame = new("Frame", { Size = UDim2.new(0, 620, 0, 400), Position = UDim2.new(0.5, -310, 0.5, -200), BackgroundColor3 = Theme.Background, ClipsDescendants = true }, ScreenGui)
    corner(MainFrame, UDim.new(0, 8))
    stroke(MainFrame)
    Window.MainFrame = MainFrame
    Window.MinIcon = MinIcon
    
    local TopBar = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Sidebar }, MainFrame)
    local tbLine = new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Theme.Border, ZIndex = 2 }, TopBar)
    local TitleLbl = new("TextLabel", { Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = config.Title or "PulseUI", TextColor3 = Theme.Text, TextSize = 14, Font = Enum.Font.BuilderSansBold, TextXAlignment = Enum.TextXAlignment.Left }, TopBar)
    local subtitle = config.SubTitle or config.Subtitle
    if subtitle then
        TitleLbl.Position = UDim2.new(0, 15, 0, -6)
        new("TextLabel", { Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 15, 0, 8), BackgroundTransparency = 1, Text = subtitle, TextColor3 = Theme.AccentA, TextSize = 11, Font = Enum.Font.BuilderSansMedium, TextXAlignment = Enum.TextXAlignment.Left }, TopBar)
    end
    
    local CloseBtn = new("ImageButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0.5, -15), BackgroundTransparency = 1, Image = "rbxassetid://10747384394", ImageColor3 = Theme.TextDim }, TopBar)
    local MinBtn = new("ImageButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -65, 0.5, -15), BackgroundTransparency = 1, Image = "rbxassetid://10734896206", ImageColor3 = Theme.TextDim }, TopBar)
    
    local isMinimized = false
    local function hideWindow()
        isMinimized = true
        tw(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, 620, 0, 0) })
        task.delay(0.3, function() MainFrame.Visible = false end)
        MinIcon.Visible = true
        tw(MinIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, -20, 0, 20) })
        closeOverlays()
    end
    local function showWindow()
        isMinimized = false
        MainFrame.Visible = true
        tw(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, 620, 0, 400) })
        tw(MinIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(0.5, -20, 0, -50) })
        task.delay(0.3, function() MinIcon.Visible = false end)
    end
    
    MinBtn.MouseButton1Click:Connect(hideWindow)
    CloseBtn.MouseButton1Click:Connect(function() Window:Destroy() end)
    
    local totalDragDist = 0
    addConnection(MinIcon.InputBegan:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragMin = true
            dragMinStart = input.Position
            startMinPos = MinIcon.Position
            dragMinInput = input
            totalDragDist = 0
        end
    end))
    addConnection(MinIcon.InputChanged:Connect(function(input)
        if dragMin and input == dragMinInput then
            local delta = input.Position - dragMinStart
            totalDragDist = delta.Magnitude
        end
    end))
    addConnection(MinIcon.InputEnded:Connect(function(input)
        if input == dragMinInput then
            dragMin = false
            if totalDragDist < 5 then showWindow() end
        end
    end))
    
    addConnection(TopBar.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            dragInput = input
        end
    end))
    addConnection(TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
    
    local ResizeBtn = new("Frame", { Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new(1, -15, 1, -15), BackgroundTransparency = 1, ZIndex = 10 }, MainFrame)
    local resIcon = new("ImageLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = "rbxassetid://10734924532", ImageColor3 = Theme.TextDim }, ResizeBtn)
    
    addConnection(ResizeBtn.InputBegan:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = MainFrame.Size
        end
    end))
    addConnection(ResizeBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end))
    
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    addConnection(UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == toggleKey then
            if isMinimized then showWindow() else hideWindow() end
        end
        -- Handle Keybind logic
        if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
            for _, component in pairs(ComponentsRegistry) do
                if component.Type == 'Keybind' and component.IsListening and component.IsListening() then
                    component.Func(input.KeyCode, false) -- NOT silent, triggers callback
                end
            end
        end
    end))
    
    -- Sidebar
    local Sidebar = new("Frame", { Size = UDim2.new(0, 160, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundColor3 = Theme.Sidebar }, MainFrame)
    local sbLine = new("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = Theme.Border, ZIndex = 2 }, Sidebar)
    
    local SearchBox = new("TextBox", { Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Theme.Element, Text = "", PlaceholderText = "Search...", TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextDim, Font = Enum.Font.BuilderSansMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false }, Sidebar)
    padding(SearchBox, 28, 5, 0, 0)
    corner(SearchBox, UDim.new(0, 4))
    stroke(SearchBox)
    local sIcon = new("ImageLabel", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 8, 0.5, -7), BackgroundTransparency = 1, Image = "rbxassetid://10727918021", ImageColor3 = Theme.TextDim }, SearchBox)
    
    local TabContainer = new("ScrollingFrame", { Size = UDim2.new(1, -10, 1, -58), Position = UDim2.new(0, 5, 0, 48), BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0) }, Sidebar)
    local TabUIList = new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, TabContainer)
    
    addConnection(SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for _, tabBtn in ipairs(TabContainer:GetChildren()) do
            if tabBtn:IsA("TextButton") then
                local txt = tabBtn:GetAttribute("TabName"):lower()
                tabBtn.Visible = txt:find(query) ~= nil
            end
        end
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabUIList.AbsoluteContentSize.Y)
    end))
    
    local ContentArea = new("Frame", { Size = UDim2.new(1, -160, 1, -40), Position = UDim2.new(0, 160, 0, 40), BackgroundTransparency = 1 }, MainFrame)
    local PagesFolder = new("Folder", { Name = "Pages" }, ContentArea)
    local PageTitle = new("TextLabel", { Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 15, 0, 10), BackgroundTransparency = 1, Text = "Tab Name", TextColor3 = Theme.Text, TextSize = 18, Font = Enum.Font.BuilderSansBold, TextXAlignment = Enum.TextXAlignment.Left }, ContentArea)
    local pageLine = new("Frame", { Size = UDim2.new(1, -30, 0, 1), Position = UDim2.new(0, 15, 0, 45), BackgroundColor3 = Theme.Border }, ContentArea)
    
    local activeTab = nil
    local function showPage(page, titleText)
        for _, p in ipairs(PagesFolder:GetChildren()) do p.Visible = false end
        page.Visible = true
        PageTitle.Text = titleText
    end
    
    -- Tooltip
    local Tooltip = new("Frame", { Size = UDim2.new(0, 0, 0, 24), BackgroundColor3 = Theme.Sidebar, ZIndex = 150, Visible = false, AutomaticSize = Enum.AutomaticSize.X }, ScreenGui)
    corner(Tooltip, UDim.new(0, 4))
    stroke(Tooltip)
    local ttLbl = new("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", TextColor3 = Theme.Text, TextSize = 11, Font = Enum.Font.BuilderSansMedium, AutomaticSize = Enum.AutomaticSize.X }, Tooltip)
    padding(ttLbl, 8, 8, 0, 0)
    
    local function attachTooltip(inst, text)
        if not text or text == "" then return end
        addConnection(inst.MouseEnter:Connect(function()
            ttLbl.Text = text
            Tooltip.Visible = true
            local pos = UserInputService:GetMouseLocation()
            Tooltip.Position = UDim2.new(0, pos.X + 15, 0, pos.Y - 25)
        end))
        addConnection(inst.MouseMoved:Connect(function()
            local pos = UserInputService:GetMouseLocation()
            Tooltip.Position = UDim2.new(0, pos.X + 15, 0, pos.Y - 25)
        end))
        addConnection(inst.MouseLeave:Connect(function() Tooltip.Visible = false end))
    end
    
    local function notify(titleText, text, duration, kind)
        duration = duration or 3
        kind = kind or "info"
        local accent = Theme.AccentA
        local icon = "rbxassetid://10727915598"
        if kind == "success" then accent = Theme.Success icon = "rbxassetid://10709798164"
        elseif kind == "error" then accent = Theme.Error icon = "rbxassetid://10734896206"
        elseif kind == "warn" then accent = Theme.Warn icon = "rbxassetid://10727932626" end
        
        local Toast = new("Frame", { Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Theme.Element, BackgroundTransparency = 1 }, ToastHolder)
        corner(Toast, UDim.new(0, 6))
        local s = stroke(Toast, Theme.Border)
        s.Transparency = 1
        
        local Ico = new("ImageLabel", { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 15, 0, 15), BackgroundTransparency = 1, Image = icon, ImageColor3 = accent, ImageTransparency = 1 }, Toast)
        local T = new("TextLabel", { Size = UDim2.new(1, -50, 0, 16), Position = UDim2.new(0, 45, 0, 12), BackgroundTransparency = 1, Text = titleText, TextColor3 = Theme.Text, TextSize = 13, Font = Enum.Font.BuilderSansBold, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1 }, Toast)
        local D = new("TextLabel", { Size = UDim2.new(1, -50, 0, 14), Position = UDim2.new(0, 45, 0, 32), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextDim, TextSize = 11, Font = Enum.Font.BuilderSansMedium, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top }, Toast)
        
        tw(Toast, TweenInfo.new(0.3), { BackgroundTransparency = 0 })
        tw(s, TweenInfo.new(0.3), { Transparency = 0 })
        tw(Ico, TweenInfo.new(0.3), { ImageTransparency = 0 })
        tw(T, TweenInfo.new(0.3), { TextTransparency = 0 })
        tw(D, TweenInfo.new(0.3), { TextTransparency = 0 })
        
        task.delay(duration, function()
            if not Toast.Parent then return end
            tw(Toast, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
            tw(s, TweenInfo.new(0.3), { Transparency = 1 })
            tw(Ico, TweenInfo.new(0.3), { ImageTransparency = 1 })
            tw(T, TweenInfo.new(0.3), { TextTransparency = 1 })
            tw(D, TweenInfo.new(0.3), { TextTransparency = 1 })
            task.delay(0.3, function() Toast:Destroy() end)
        end)
    end
    
    function Window:Notify(t, text, duration, kind) notify(t, text, duration, kind) end
    function Window:SetWatermark(text, visible)
        wmText.Text = text
        Watermark.Visible = visible
        tw(Watermark, TweenInfo.new(0.3), { Position = visible and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 20, 0, -40) })
    end
    
    -- Config Logic per-window
    local isCurrentlyLoading = false
    function Window:SaveConfig(cName)
        if not writefile then return notify("Error", "Your executor does not support saving files.", 3, "error") end
        cName = cName or config.ConfigName
        if not cName or cName == "" then return notify("Error", "Invalid config name.", 3, "error") end
        
        local ok, err = pcall(function()
            local path = getConfigPath(cName)
            if path == "" then error("Failed to get config path") end
            local data = HttpService:JSONEncode(FlagStore)
            writefile(path, data)
        end)
        if ok then notify("Config", "Saved config: " .. cName, 2, "success")
        else notify("Config Error", "Failed to save config: " .. tostring(err), 3, "error") end
    end
    
    function Window:LoadConfig(cName)
        if not readfile or not isfile then return notify("Error", "Your executor does not support reading files.", 3, "error") end
        cName = cName or config.ConfigName
        if not cName or cName == "" then return notify("Error", "Invalid config name.", 3, "error") end
        
        local path = getConfigPath(cName)
        if path == "" or not isfile(path) then return notify("Error", "Config not found: " .. cName, 3, "error") end
        
        local ok, err = pcall(function()
            local data = readfile(path)
            local parsed = HttpService:JSONDecode(data)
            isCurrentlyLoading = true
            
            -- Phase 0: Update FlagStore
            for k, v in pairs(parsed) do FlagStore[k] = v end
            
            -- Phase 1: Load Raw Data Components
            for flag, val in pairs(parsed) do
                local comp = ComponentsRegistry[flag]
                if comp and comp.Type ~= 'Toggle' and comp.Type ~= 'Radio' and comp.Type ~= 'Keybind' then
                    safeCall(comp.Func, val)
                end
            end
            
            -- Phase 2: Load Action Components
            for flag, val in pairs(parsed) do
                local comp = ComponentsRegistry[flag]
                if comp and (comp.Type == 'Toggle' or comp.Type == 'Radio' or comp.Type == 'Keybind') then
                    safeCall(comp.Func, val)
                end
            end
            isCurrentlyLoading = false
        end)
        
        if not isCurrentlyLoading then isCurrentlyLoading = false end
        if ok then notify("Config", "Loaded config: " .. cName, 2, "success")
        else notify("Config Error", "Failed to load config: " .. tostring(err), 3, "error") end
    end
    
    function Window:DeleteConfig(cName)
        if not delfile or not isfile then return notify("Error", "Your executor does not support deleting files.", 3, "error") end
        local path = getConfigPath(cName)
        if path ~= "" and isfile(path) then
            pcall(delfile, path)
            notify("Config", "Deleted config: " .. cName, 2, "success")
        end
    end
    
    function Window:GetConfigs()
        return getConfigsList()
    end
    
    function Window:Destroy()
        if _destroyed then return end
        _destroyed = true
        disconnectAll()
        table.clear(ComponentsRegistry)
        table.clear(FlagStore)
        if ScreenGui and ScreenGui.Parent then
            ScreenGui:Destroy()
        end
    end
    
    local _firstUserTab = nil
    
    function Window:Tab(tabConfig)
        tabConfig = tabConfig or {}
        local title = tabConfig.Title or "Tab"
        local Tab = {}
        
        local TabBtn = new("TextButton", { Size = UDim2.new(1, -4, 0, 32), Position = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, TabContainer)
        TabBtn:SetAttribute("TabName", title)
        local tbBg = new("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Theme.Hover, BackgroundTransparency = 1 }, TabBtn)
        corner(tbBg, UDim.new(0, 4))
        local tbInd = new("Frame", { Size = UDim2.new(0, 3, 0, 16), Position = UDim2.new(0, 6, 0.5, -8), BackgroundColor3 = Theme.AccentA, BackgroundTransparency = 1 }, TabBtn)
        corner(tbInd, UDim.new(1, 0))
        local Ico = new("ImageLabel", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 15, 0.5, -8), BackgroundTransparency = 1, ImageColor3 = Theme.TextDim }, TabBtn)
        local iconName = tabConfig.Icon or "list"
        if Lucide and Lucide.Icons and Lucide.Icons[iconName] then
            local iconData = Lucide.Icons[iconName]
            local sheet = Lucide.Spritesheets[tostring(iconData.Image)]
            Ico.Image = sheet
            Ico.ImageRectOffset = iconData.ImageRectPosition
            Ico.ImageRectSize = iconData.ImageRectSize
        else Ico.Image = "rbxassetid://10727915598" end
        local Lbl = new("TextLabel", { Size = UDim2.new(1, -45, 1, 0), Position = UDim2.new(0, 38, 0, 0), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.TextDim, TextSize = 12, Font = Enum.Font.BuilderSansMedium, TextXAlignment = Enum.TextXAlignment.Left }, TabBtn)
        
        local Page = new("ScrollingFrame", { Size = UDim2.new(1, -10, 1, -60), Position = UDim2.new(0, 5, 0, 55), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Border, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false }, PagesFolder)
        local PUIList = new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, Page)
        new("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10) }, Page)
        
        addConnection(PUIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PUIList.AbsoluteContentSize.Y + 15)
        end))
        
        local function setActive(entry, active)
            tw(tbBg, TweenInfo.new(0.2), { BackgroundTransparency = active and 0 or 1 })
            tw(tbInd, TweenInfo.new(0.2), { BackgroundTransparency = active and 0 or 1 })
            tw(Ico, TweenInfo.new(0.2), { ImageColor3 = active and Theme.Text or Theme.TextDim })
            tw(Lbl, TweenInfo.new(0.2), { TextColor3 = active and Theme.Text or Theme.TextDim })
            Lbl.Font = active and Enum.Font.BuilderSansBold or Enum.Font.BuilderSansMedium
        end
        
        addConnection(TabBtn.MouseEnter:Connect(function() if activeTab ~= Tab then tw(tbBg, TweenInfo.new(0.2), { BackgroundTransparency = 0.5 }) end end))
        addConnection(TabBtn.MouseLeave:Connect(function() if activeTab ~= Tab then tw(tbBg, TweenInfo.new(0.2), { BackgroundTransparency = 1 }) end end))
        addConnection(TabBtn.MouseButton1Click:Connect(function()
            if activeTab == Tab then return end
            if activeTab and activeTab.Deselect then activeTab.Deselect() end
            activeTab = Tab
            setActive(TabBtn, true)
            showPage(Page, title)
            closeOverlays()
        end))
        
        Tab.Deselect = function() setActive(TabBtn, false) end
        
        addConnection(TabContainer.ChildAdded:Connect(function() TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabUIList.AbsoluteContentSize.Y) end))
        
        -- Note: Do not auto-select the config tab if it's deferred
        if not _firstUserTab and not tabConfig.IsConfigTab then
            _firstUserTab = Tab
            activeTab = Tab
            setActive(TabBtn, true)
            showPage(Page, title)
        end
        
        function Tab:Section(secConfig)
            secConfig = secConfig or {}
            local secTitle = secConfig.Title or "Section"
            local open = secConfig.Default == nil and true or secConfig.Default
            
            local SecHolder = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.ElementAlt, ClipsDescendants = true }, Page)
            corner(SecHolder, UDim.new(0, 6))
            stroke(SecHolder)
            
            local Top = new("TextButton", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, SecHolder)
            local SLbl = new("TextLabel", { Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = secTitle, TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.BuilderSansBold, TextXAlignment = Enum.TextXAlignment.Left }, Top)
            local Arr = new("ImageLabel", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -22, 0.5, -8), BackgroundTransparency = 1, Image = "rbxassetid://10709790948", ImageColor3 = Theme.TextDim, Rotation = open and 180 or 0 }, Top)
            
            local Content = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, Visible = open }, SecHolder)
            local CList = new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, Content)
            new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, Content)
            
            addConnection(Top.MouseButton1Click:Connect(function()
                open = not open
                tw(Arr, TweenInfo.new(0.2), { Rotation = open and 180 or 0 })
                Content.Visible = open
            end))
            
            return { ContentFrame = Content, Clear = function() for _, c in ipairs(Content:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end end }
        end
        
        function Tab:Divider(cfg)
            cfg = cfg or {}
            local targetParent = (type(cfg) == "table" and cfg.Section and cfg.Section.ContentFrame) or Page
            local holder = new("Frame", { Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1 }, targetParent)
            new("Frame", { Size = UDim2.new(1, -20, 0, 1), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Border }, holder)
        end
        
        function Tab:Label(cfg)
            local text = type(cfg) == "string" and cfg or (cfg.Text or "Label")
            local targetParent = (type(cfg) == "table" and cfg.Section and cfg.Section.ContentFrame) or Page
            local Holder = new("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1 }, targetParent)
            local Lbl = new("TextLabel", { Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextDim, TextSize = 12, Font = Enum.Font.BuilderSansMedium, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, Holder)
            
            local comp = {
                Set = function(t) Lbl.Text = t end,
                Destroy = function() Holder:Destroy() end
            }
            comp.SetText = comp.Set
            return comp
        end
        Tab.Paragraph = Tab.Label
        
        local function elementFrame(cfg)
            local targetParent = (cfg.Section and cfg.Section.ContentFrame) or Page
            local f = new("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Element }, targetParent)
            corner(f, UDim.new(0, 6))
            stroke(f)
            local title = new("TextLabel", { Size = UDim2.new(1, -150, 0, 16), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Text = cfg.Title or "Element", TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.BuilderSansMedium, TextXAlignment = Enum.TextXAlignment.Left }, f)
            if cfg.Desc or cfg.Description then
                title.Position = UDim2.new(0, 10, 0, 5)
                new("TextLabel", { Size = UDim2.new(1, -150, 0, 14), Position = UDim2.new(0, 10, 0, 20), BackgroundTransparency = 1, Text = cfg.Desc or cfg.Description, TextColor3 = Theme.TextDim, TextSize = 11, Font = Enum.Font.BuilderSansMedium, TextXAlignment = Enum.TextXAlignment.Left }, f)
            end
            attachTooltip(f, cfg.Tooltip)
            return f
        end
        
        local function unregister(cfg)
            if cfg.Flag then
                if PulseUI.Debug and ComponentsRegistry[cfg.Flag] ~= nil then
                    warn("[PulseUI] Duplicate flag overwritten: " .. tostring(cfg.Flag))
                end
                FlagStore[cfg.Flag] = nil
                ComponentsRegistry[cfg.Flag] = nil
            end
        end
        
        local function registerFlag(cfg, typeName, setFunc, isListeningFunc)
            if cfg.Flag then
                if PulseUI.Debug and ComponentsRegistry[cfg.Flag] ~= nil then
                    warn("[PulseUI] Duplicate flag overwritten: " .. tostring(cfg.Flag))
                end
                ComponentsRegistry[cfg.Flag] = { 
                    Type = typeName, 
                    Func = function(v) setFunc(v, true) end,
                    IsListening = isListeningFunc
                }
            end
        end
        
        function Tab:Button(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local Btn = new("TextButton", { Size = UDim2.new(0, 150, 0, 30), Position = UDim2.new(1, -164, 0.5, -15), BackgroundColor3 = Theme.ElementAlt, Text = cfg.ButtonText or "Execute", TextColor3 = Theme.Text, Font = Enum.Font.BuilderSansMedium, TextSize = 12 }, EFrame)
            corner(Btn, UDim.new(0, 4))
            stroke(Btn)
            addConnection(Btn.MouseEnter:Connect(function() tw(Btn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Hover }) end))
            addConnection(Btn.MouseLeave:Connect(function() tw(Btn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.ElementAlt }) end))
            
            local function fire()
                tw(Btn, TweenInfo.new(0.1), { Size = UDim2.new(0, 134, 0, 28), Position = UDim2.new(1, -151, 0.5, -14) })
                task.delay(0.1, function()
                    tw(Btn, TweenInfo.new(0.1), { Size = UDim2.new(0, 150, 0, 30), Position = UDim2.new(1, -164, 0.5, -15) })
                end)
                if cfg.Callback then safeCall(cfg.Callback) end
            end
            
            addConnection(Btn.MouseButton1Click:Connect(fire))
            
            return {
                Fire = fire,
                Destroy = function() EFrame:Destroy() end
            }
        end
        
        function Tab:Toggle(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local state = cfg.Default or false
            if cfg.Flag and FlagStore[cfg.Flag] ~= nil then state = FlagStore[cfg.Flag] end
            
            local ToggleBtn = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 2 }, EFrame)
            local Bg = new("Frame", { Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = state and Theme.AccentA or Theme.ElementAlt }, EFrame)
            corner(Bg, UDim.new(1, 0))
            stroke(Bg)
            local Dot = new("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.Text }, Bg)
            corner(Dot, UDim.new(1, 0))
            
            local function setState(newState, silent)
                state = newState
                tw(Bg, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = state and Theme.AccentA or Theme.ElementAlt })
                tw(Dot, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) })
                if cfg.Flag then FlagStore[cfg.Flag] = state end
                if silent ~= true and cfg.Callback then safeCall(cfg.Callback, state) end
            end
            
            addConnection(ToggleBtn.MouseButton1Click:Connect(function() setState(not state, false) end))
            registerFlag(cfg, 'Toggle', setState)
            
            return {
                Set = function(v, silent) setState(v, silent) end,
                Get = function() return state end,
                Destroy = function() unregister(cfg) EFrame:Destroy() end
            }
        end
        
        function Tab:ToggleGroup(cfg)
            cfg = cfg or {}
            local values = cfg.Values or {}
            local selected = cfg.Default or values[1]
            if cfg.Flag and FlagStore[cfg.Flag] ~= nil then selected = FlagStore[cfg.Flag] end
            
            local Holder = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, (cfg.Section and cfg.Section.ContentFrame) or Page)
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, Holder)
            
            local buttons = {}
            local function refresh()
                for val, btn in pairs(buttons) do
                    local on = (val == selected)
                    btn.Dot.BackgroundColor3 = on and Theme.AccentA or Theme.ElementAlt
                    btn.Label.TextColor3 = on and Theme.Text or Theme.TextDim
                end
            end
            
            local function setGroup(val, silent)
                selected = val
                refresh()
                if cfg.Flag then FlagStore[cfg.Flag] = selected end
                if silent ~= true and cfg.Callback then safeCall(cfg.Callback, selected) end
            end
            
            for _, val in ipairs(values) do
                local Row = new("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1 }, Holder)
                local Btn = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, Row)
                local Dot = new("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 10, 0.5, -7), BackgroundColor3 = Theme.ElementAlt }, Row)
                corner(Dot, UDim.new(1, 0))
                stroke(Dot)
                local Lbl = new("TextLabel", { Size = UDim2.new(1, -34, 1, 0), Position = UDim2.new(0, 32, 0, 0), BackgroundTransparency = 1, Text = tostring(val), TextColor3 = Theme.TextDim, TextSize = 12, Font = Enum.Font.BuilderSansMedium, TextXAlignment = Enum.TextXAlignment.Left }, Row)
                buttons[val] = { Dot = Dot, Label = Lbl }
                
                addConnection(Btn.MouseButton1Click:Connect(function() setGroup(val, false) end))
            end
            refresh()
            
            registerFlag(cfg, 'Radio', setGroup)
            
            return {
                Set = function(v, silent) setGroup(v, silent) end,
                Get = function() return selected end,
                Destroy = function() unregister(cfg) Holder:Destroy() end
            }
        end
        
        function Tab:Slider(cfg)
            cfg = cfg or {}
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            if min > max then min, max = max, min end
            local EFrame = elementFrame(cfg)
            local val = cfg.Default or min
            if cfg.Flag and FlagStore[cfg.Flag] ~= nil then val = FlagStore[cfg.Flag] end
            val = math.clamp(val, min, max)
            
            local SliderBg = new("Frame", { Size = UDim2.new(0, 150, 0, 6), Position = UDim2.new(1, -214, 0.5, -3), BackgroundColor3 = Theme.ElementAlt }, EFrame)
            corner(SliderBg, UDim.new(1, 0))
            stroke(SliderBg)
            
            local pct = (val - min) / (max - min)
            local Fill = new("Frame", { Size = UDim2.new(pct, 0, 1, 0), BackgroundColor3 = Theme.AccentA }, SliderBg)
            corner(Fill, UDim.new(1, 0))
            
            local ValBox = new("TextBox", { Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, 10, 0.5, -10), BackgroundColor3 = Theme.ElementAlt, Text = tostring(val), TextColor3 = Theme.Text, Font = Enum.Font.BuilderSansMedium, TextSize = 11 }, SliderBg)
            corner(ValBox, UDim.new(0, 4))
            stroke(ValBox)
            
            local function fmt(n) return string.format(cfg.Decimals and ("%."..cfg.Decimals.."f") or "%d", n) end
            
            local function setValue(newVal, silent)
                val = math.clamp(newVal, min, max)
                local p = (val - min) / (max - min)
                tw(Fill, TweenInfo.new(0.1), { Size = UDim2.new(p, 0, 1, 0) })
                ValBox.Text = fmt(val)
                if cfg.Flag then FlagStore[cfg.Flag] = val end
                if silent ~= true and cfg.Callback then safeCall(cfg.Callback, val) end
            end
            
            setValue(val, true)
            
            local function updateDrag(input)
                local relX = math.clamp(input.Position.X - SliderBg.AbsolutePosition.X, 0, SliderBg.AbsoluteSize.X)
                local perc = relX / SliderBg.AbsoluteSize.X
                setValue(min + ((max - min) * perc), false)
            end
            
            local trigger = new("TextButton", { Size = UDim2.new(1, 0, 1, 14), Position = UDim2.new(0, 0, 0.5, -7), BackgroundTransparency = 1, Text = "" }, SliderBg)
            addConnection(trigger.InputBegan:Connect(function(input, gpe)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    _activeDragger = updateDrag
                    updateDrag(input)
                end
            end))
            
            addConnection(ValBox.FocusLost:Connect(function()
                local n = tonumber(ValBox.Text)
                if n then setValue(n, false) else ValBox.Text = fmt(val) end
            end))
            
            registerFlag(cfg, 'Slider', setValue)
            
            return {
                Set = function(v, silent) setValue(v, silent) end,
                Get = function() return val end,
                Destroy = function() unregister(cfg) EFrame:Destroy() end
            }
        end
        
        function Tab:ProgressBar(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local bg = new("Frame", { Size = UDim2.new(0, 150, 0, 10), Position = UDim2.new(1, -164, 0.5, -5), BackgroundColor3 = Theme.ElementAlt }, EFrame)
            corner(bg, UDim.new(1, 0))
            stroke(bg)
            local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.AccentA }, bg)
            corner(fill, UDim.new(1, 0))
            local function set(p) tw(fill, TweenInfo.new(0.2), { Size = UDim2.new(math.clamp(p,0,1), 0, 1, 0) }) end
            return {
                Set = set,
                Get = function() return fill.Size.X.Scale end,
                Destroy = function() EFrame:Destroy() end
            }
        end
        
        function Tab:Image(cfg)
            cfg = cfg or {}
            local f = new("Frame", { Size = UDim2.new(1, 0, 0, cfg.Height or 100), BackgroundColor3 = Theme.Element }, (cfg.Section and cfg.Section.ContentFrame) or Page)
            corner(f, UDim.new(0, 6))
            stroke(f)
            local img = new("ImageLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = cfg.Image or "", ScaleType = Enum.ScaleType.Crop }, f)
            corner(img, UDim.new(0, 6))
            local comp = {
                Set = function(id) img.Image = id end,
                Destroy = function() f:Destroy() end
            }
            comp.SetImage = comp.Set
            return comp
        end
        
        function Tab:TextBox(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local val = cfg.Default or ""
            if cfg.Flag and FlagStore[cfg.Flag] ~= nil then val = FlagStore[cfg.Flag] end
            
            local Box = new("TextBox", { Size = UDim2.new(0, 150, 0, 26), Position = UDim2.new(1, -164, 0.5, -13), BackgroundColor3 = Theme.ElementAlt, Text = val, PlaceholderText = cfg.Placeholder or "Enter text...", TextColor3 = Theme.Text, PlaceholderColor3 = Theme.TextDim, Font = Enum.Font.BuilderSansMedium, TextSize = 12, ClearTextOnFocus = false }, EFrame)
            corner(Box, UDim.new(0, 4))
            stroke(Box)
            
            local function setVal(t, silent)
                val = t
                Box.Text = val
                if cfg.Flag then FlagStore[cfg.Flag] = val end
                if silent ~= true and cfg.Callback then safeCall(cfg.Callback, val) end
            end
            
            addConnection(Box.FocusLost:Connect(function() setVal(Box.Text, false) end))
            
            registerFlag(cfg, 'TextBox', setVal)
            
            local comp = {
                Set = function(v, silent) setVal(v, silent) end,
                Get = function() return val end,
                Destroy = function() unregister(cfg) EFrame:Destroy() end
            }
            comp.SetText = comp.Set
            comp.GetText = comp.Get
            return comp
        end
        
        function Tab:Input(cfg)
            cfg = cfg or {}
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            if min > max then min, max = max, min end
            local EFrame = elementFrame(cfg)
            local val = cfg.Default or min
            if cfg.Flag and FlagStore[cfg.Flag] ~= nil then val = FlagStore[cfg.Flag] end
            val = math.clamp(val, min, max)
            
            local Box = new("TextBox", { Size = UDim2.new(0, 150, 0, 26), Position = UDim2.new(1, -164, 0.5, -13), BackgroundColor3 = Theme.ElementAlt, Text = tostring(val), PlaceholderText = "Number...", TextColor3 = Theme.Text, Font = Enum.Font.BuilderSansMedium, TextSize = 12 }, EFrame)
            corner(Box, UDim.new(0, 4))
            stroke(Box)
            
            local function setVal(v, silent)
                val = math.clamp(tonumber(v) or min, min, max)
                Box.Text = tostring(val)
                if cfg.Flag then FlagStore[cfg.Flag] = val end
                if silent ~= true and cfg.Callback then safeCall(cfg.Callback, val) end
            end
            
            addConnection(Box.FocusLost:Connect(function() setVal(Box.Text, false) end))
            
            registerFlag(cfg, 'Input', setVal)
            
            return {
                Set = function(v, silent) setVal(v, silent) end,
                Get = function() return val end,
                Destroy = function() unregister(cfg) EFrame:Destroy() end
            }
        end
        
        function Tab:Keybind(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local current = cfg.Default or Enum.KeyCode.E
            if cfg.Flag and FlagStore[cfg.Flag] ~= nil then
                local ok, kc = pcall(function() return Enum.KeyCode[FlagStore[cfg.Flag]] end)
                if ok and kc then current = kc end
            end
            
            local listening = false
            local KeyBtn = new("TextButton", { Size = UDim2.new(0, 150, 0, 26), Position = UDim2.new(1, -164, 0.5, -13), BackgroundColor3 = Theme.ElementAlt, Text = current.Name, TextColor3 = Theme.TextDim, Font = Enum.Font.BuilderSansMedium, TextSize = 12 }, EFrame)
            corner(KeyBtn, UDim.new(0, 4))
            stroke(KeyBtn)
            
            local function setKey(k, silent)
                if type(k) == "string" then
                    local ok, kc = pcall(function() return Enum.KeyCode[k] end)
                    if ok and kc then current = kc end
                elseif typeof(k) == "EnumItem" then
                    current = k
                end
                KeyBtn.Text = current and current.Name or "None"
                KeyBtn.TextColor3 = Theme.TextDim
                listening = false
                if cfg.Flag then FlagStore[cfg.Flag] = current and current.Name or "None" end
                if silent ~= true and cfg.Callback then safeCall(cfg.Callback, current) end
            end
            
            addConnection(KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "..."
                KeyBtn.TextColor3 = Theme.AccentA
            end))
            
            registerFlag(cfg, 'Keybind', setKey, function() return listening end)
            
            return {
                Set = function(k, silent) setKey(k, silent) end,
                Get = function() return current end,
                Destroy = function() unregister(cfg) EFrame:Destroy() end
            }
        end
        
        function Tab:ColorPicker(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local color = cfg.Default or Color3.fromRGB(255, 255, 255)
            if cfg.Flag and FlagStore[cfg.Flag] ~= nil then
                local st = FlagStore[cfg.Flag]
                if type(st) == "table" then color = Color3.fromRGB(st[1] or st.r or 0, st[2] or st.g or 0, st[3] or st.b or 0)
                elseif type(st) == "string" then pcall(function() color = Color3.fromHex(st) end) end
            end
            
            local r, g, b = math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)
            
            local Swatch = new("TextButton", { Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = color, Text = "" }, EFrame)
            corner(Swatch, UDim.new(0, 4))
            stroke(Swatch)
            
            local Popup = new("Frame", { Size = UDim2.new(0, 200, 0, 150), BackgroundColor3 = Theme.Sidebar, Visible = false, ZIndex = 110 }, Overlay)
            corner(Popup, UDim.new(0, 6))
            stroke(Popup)
            
            local function updateSwatch() Swatch.BackgroundColor3 = color end
            
            local function setColor(c3, silent)
                r, g, b = math.floor(c3.R*255), math.floor(c3.G*255), math.floor(c3.B*255)
                color = c3
                updateSwatch()
                -- Update popup visuals if it's open
                if Popup.Visible then
                    for _, child in ipairs(Popup:GetChildren()) do
                        if child:IsA("Frame") and child.Name:match("Channel") then
                            local ch = child.Name:sub(8,8)
                            local val = ch == "R" and r or ch == "G" and g or b
                            local fill = child.SliderBg.Fill
                            local tbox = child.SliderBg.ValBox
                            fill.Size = UDim2.new(val/255, 0, 1, 0)
                            tbox.Text = tostring(val)
                        end
                    end
                end
                if cfg.Flag then FlagStore[cfg.Flag] = { r=r, g=g, b=b } end
                if silent ~= true and cfg.Callback then safeCall(cfg.Callback, color) end
            end
            
            local function channelSlider(label, initial, onChange)
                local row = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Name = "Channel" .. label }, Popup)
                local Lbl = new("TextLabel", { Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = label, TextColor3 = Theme.TextDim, Font = Enum.Font.BuilderSansMedium, TextSize = 12 }, row)
                local SliderBg = new("Frame", { Size = UDim2.new(1, -80, 0, 6), Position = UDim2.new(0, 30, 0.5, -3), BackgroundColor3 = Theme.ElementAlt, Name = "SliderBg" }, row)
                corner(SliderBg, UDim.new(1, 0))
                stroke(SliderBg)
                local Fill = new("Frame", { Size = UDim2.new(initial/255, 0, 1, 0), BackgroundColor3 = label == "R" and Color3.fromRGB(255,100,100) or label == "G" and Color3.fromRGB(100,255,100) or Color3.fromRGB(100,100,255), Name = "Fill" }, SliderBg)
                corner(Fill, UDim.new(1, 0))
                local ValBox = new("TextBox", { Size = UDim2.new(0, 35, 0, 20), Position = UDim2.new(1, 5, 0.5, -10), BackgroundColor3 = Theme.ElementAlt, Text = tostring(initial), TextColor3 = Theme.Text, Font = Enum.Font.BuilderSansMedium, TextSize = 11, Name = "ValBox" }, SliderBg)
                corner(ValBox, UDim.new(0, 4))
                stroke(ValBox)
                
                local function updateDrag(input)
                    local relX = math.clamp(input.Position.X - SliderBg.AbsolutePosition.X, 0, SliderBg.AbsoluteSize.X)
                    local perc = relX / SliderBg.AbsoluteSize.X
                    local v = math.floor(perc * 255)
                    Fill.Size = UDim2.new(perc, 0, 1, 0)
                    ValBox.Text = tostring(v)
                    onChange(v)
                end
                
                local btn = new("TextButton", { Size = UDim2.new(1, 0, 1, 14), Position = UDim2.new(0, 0, 0.5, -7), BackgroundTransparency = 1, Text = "" }, SliderBg)
                addConnection(btn.InputBegan:Connect(function(input, gpe)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        _activeDragger = updateDrag
                        updateDrag(input)
                    end
                end))
                addConnection(ValBox.FocusLost:Connect(function()
                    local n = tonumber(ValBox.Text)
                    if n then 
                        n = math.clamp(n, 0, 255)
                        Fill.Size = UDim2.new(n/255, 0, 1, 0)
                        ValBox.Text = tostring(n)
                        onChange(n)
                    end
                end))
                return row
            end
            
            local function update() setColor(Color3.fromRGB(r, g, b), false) end
            local rRow = channelSlider("R", r, function(v) r = v update() end)
            local gRow = channelSlider("G", g, function(v) g = v update() end)
            local bRow = channelSlider("B", b, function(v) b = v update() end)
            rRow.Position = UDim2.new(0, 0, 0, 10)
            gRow.Position = UDim2.new(0, 0, 0, 50)
            bRow.Position = UDim2.new(0, 0, 0, 90)
            
            addConnection(Swatch.MouseButton1Click:Connect(function()
                openOverlay(function() Popup.Visible = false end)
                local abs = Swatch.AbsolutePosition
                Popup.Position = UDim2.new(0, abs.X - 160, 0, abs.Y + 30)
                Popup.Visible = true
            end))
            
            if cfg.Flag then
                ComponentsRegistry[cfg.Flag] = { 
                    Type = 'ColorPicker', 
                    Func = function(v)
                        if type(v) == "table" then setColor(Color3.fromRGB(v[1] or v.r or 0, v[2] or v.g or 0, v[3] or v.b or 0), true)
                        elseif type(v) == "string" then pcall(function() setColor(Color3.fromHex(v), true) end) end
                    end
                }
            end
            
            return {
                Set = function(c, silent) setColor(c, silent) end,
                Get = function() return color end,
                Destroy = function() unregister(cfg) EFrame:Destroy() Popup:Destroy() end
            }
        end
        
        local function floatingList()
            local Frame = new("Frame", { Size = UDim2.new(0, 150, 0, 150), BackgroundColor3 = Theme.Sidebar, Visible = false, ZIndex = 110, ClipsDescendants = true, Active = true }, Overlay)
            corner(Frame, UDim.new(0, 6))
            stroke(Frame)
            local Search = new("TextBox", { Size = UDim2.new(1, -12, 0, 26), Position = UDim2.new(0, 6, 0, 6), BackgroundColor3 = Theme.Element, Text = "", PlaceholderText = "Search...", TextColor3 = Theme.Text, Font = Enum.Font.BuilderSansMedium, TextSize = 12, ClearTextOnFocus = false }, Frame)
            corner(Search, UDim.new(0, 4))
            stroke(Search)
            local Scroll = new("ScrollingFrame", { Size = UDim2.new(1, -12, 1, -44), Position = UDim2.new(0, 6, 0, 38), BackgroundTransparency = 1, ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 0) }, Frame)
            local UIList = new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, Scroll)
            addConnection(UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
                Frame.Size = UDim2.new(0, 150, 0, math.clamp(UIList.AbsoluteContentSize.Y + 50, 50, 200))
            end))
            return Frame, Search, Scroll
        end
        
        function Tab:Dropdown(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local values = cfg.Values or {}
            local selected = cfg.Default or ""
            if cfg.Flag and FlagStore[cfg.Flag] ~= nil then selected = FlagStore[cfg.Flag] end
            
            local Btn = new("TextButton", { Size = UDim2.new(0, 150, 0, 26), Position = UDim2.new(1, -164, 0.5, -13), BackgroundColor3 = Theme.ElementAlt, Text = "", AutoButtonColor = false }, EFrame)
            corner(Btn, UDim.new(0, 4))
            stroke(Btn)
            local Lbl = new("TextLabel", { Size = UDim2.new(1, -25, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = tostring(selected), TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.BuilderSansMedium, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, Btn)
            local Arr = new("ImageLabel", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -20, 0.5, -7), BackgroundTransparency = 1, Image = "rbxassetid://10709790948", ImageColor3 = Theme.TextDim }, Btn)
            
            local List, Search, Scroll = floatingList()
            local optionPool = {}
            
            local function setVal(v, silent)
                selected = v
                Lbl.Text = tostring(selected)
                if cfg.Flag then FlagStore[cfg.Flag] = selected end
                if silent ~= true and cfg.Callback then safeCall(cfg.Callback, selected) end
                List.Visible = false
            end
            
            local function refreshOptions(newValues)
                values = newValues or values
                for _, b in ipairs(optionPool) do b.Visible = false end
                
                local i = 1
                for _, val in ipairs(values) do
                    local strVal = tostring(val)
                    local obtn = optionPool[i]
                    if not obtn then
                        obtn = new("TextButton", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "", Name = "Opt" }, Scroll)
                        local ol = new("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.TextDim, TextSize = 12, Font = Enum.Font.BuilderSansMedium, TextXAlignment = Enum.TextXAlignment.Left }, obtn)
                        local mark = new("Frame", { Size = UDim2.new(0, 2, 0, 12), Position = UDim2.new(0, 4, 0.5, -6), BackgroundColor3 = Theme.AccentA, BackgroundTransparency = 1 }, obtn)
                        corner(mark, UDim.new(1, 0))
                        
                        addConnection(obtn.MouseEnter:Connect(function() if Lbl.Text ~= ol.Text then tw(ol, TweenInfo.new(0.2), { TextColor3 = Theme.Text }) end end))
                        addConnection(obtn.MouseLeave:Connect(function() if Lbl.Text ~= ol.Text then tw(ol, TweenInfo.new(0.2), { TextColor3 = Theme.TextDim }) end end))
                        addConnection(obtn.MouseButton1Click:Connect(function() setVal(ol.Text, false) end))
                        table.insert(optionPool, obtn)
                    end
                    
                    local ol = obtn:FindFirstChildOfClass("TextLabel")
                    local mark = obtn:FindFirstChildOfClass("Frame")
                    ol.Text = strVal
                    obtn.Visible = true
                    
                    local isSel = (strVal == tostring(selected))
                    ol.TextColor3 = isSel and Theme.AccentA or Theme.TextDim
                    mark.BackgroundTransparency = isSel and 0 or 1
                    i = i + 1
                end
            end
            
            refreshOptions(values)
            
            addConnection(Search:GetPropertyChangedSignal("Text"):Connect(function()
                local q = Search.Text:lower()
                for _, b in ipairs(optionPool) do
                    if b.Visible or b.Name == "Opt" then
                        local txt = b:FindFirstChildOfClass("TextLabel").Text:lower()
                        b.Visible = (txt:find(q) ~= nil) and true or false
                    end
                end
            end))
            
            addConnection(Btn.MouseButton1Click:Connect(function()
                refreshOptions(values)
                Search.Text = ""
                openOverlay(function() List.Visible = false end)
                local abs = Btn.AbsolutePosition
                List.Position = UDim2.new(0, abs.X, 0, abs.Y + 30)
                List.Visible = true
            end))
            
            registerFlag(cfg, 'Dropdown', setVal)
            
            local comp = {
                Set = function(v, silent) setVal(v, silent) end,
                Get = function() return selected end,
                SetValues = function(t) refreshOptions(t) end,
                Destroy = function() unregister(cfg) EFrame:Destroy() List:Destroy() end
            }
            comp.SetValue = comp.Set
            comp.Refresh = comp.SetValues
            return comp
        end
        
        function Tab:MultiDropdown(cfg)
            cfg = cfg or {}
            local EFrame = elementFrame(cfg)
            local values = cfg.Values or {}
            local selected = cfg.Default or {}
            if type(selected) ~= "table" then selected = {} end
            
            if cfg.Flag and FlagStore[cfg.Flag] ~= nil then
                local st = FlagStore[cfg.Flag]
                if type(st) == "table" then
                    selected = {}
                    for _, v in pairs(st) do table.insert(selected, tostring(v)) end
                end
            end
            
            local Btn = new("TextButton", { Size = UDim2.new(0, 150, 0, 26), Position = UDim2.new(1, -164, 0.5, -13), BackgroundColor3 = Theme.ElementAlt, Text = "", AutoButtonColor = false }, EFrame)
            corner(Btn, UDim.new(0, 4))
            stroke(Btn)
            local Lbl = new("TextLabel", { Size = UDim2.new(1, -25, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "Select...", TextColor3 = Theme.Text, TextSize = 12, Font = Enum.Font.BuilderSansMedium, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, Btn)
            local Arr = new("ImageLabel", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -20, 0.5, -7), BackgroundTransparency = 1, Image = "rbxassetid://10709790948", ImageColor3 = Theme.TextDim }, Btn)
            
            local List, Search, Scroll = floatingList()
            local optionPool = {}
            
            local function selectedText()
                if #selected == 0 then return "None" end
                return table.concat(selected, ", ")
            end
            Lbl.Text = selectedText()
            
            local function setVals(t, silent)
                if type(t) ~= "table" then t = {} end
                selected = {}
                for _, v in pairs(t) do table.insert(selected, tostring(v)) end
                Lbl.Text = selectedText()
                if cfg.Flag then FlagStore[cfg.Flag] = selected end
                if silent ~= true and cfg.Callback then safeCall(cfg.Callback, selected) end
                -- don't close list for multi select
            end
            
            local function refreshOptions(newValues)
                values = newValues or values
                for _, b in ipairs(optionPool) do b.Visible = false end
                
                local i = 1
                for _, val in ipairs(values) do
                    local strVal = tostring(val)
                    local obtn = optionPool[i]
                    if not obtn then
                        obtn = new("TextButton", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "", Name = "Opt" }, Scroll)
                        local box = new("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 8, 0.5, -7), BackgroundColor3 = Theme.ElementAlt }, obtn)
                        corner(box, UDim.new(0, 3))
                        stroke(box)
                        local chk = new("ImageLabel", { Size = UDim2.new(1, -4, 1, -4), Position = UDim2.new(0, 2, 0, 2), BackgroundTransparency = 1, Image = "rbxassetid://10709798164", ImageColor3 = Theme.AccentA, ImageTransparency = 1 }, box)
                        local ol = new("TextLabel", { Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.TextDim, TextSize = 12, Font = Enum.Font.BuilderSansMedium, TextXAlignment = Enum.TextXAlignment.Left }, obtn)
                        
                        addConnection(obtn.MouseButton1Click:Connect(function()
                            local txt = ol.Text
                            local idx = table.find(selected, txt)
                            if idx then table.remove(selected, idx) else table.insert(selected, txt) end
                            setVals(selected, false)
                            local isSel = table.find(selected, txt) ~= nil
                            tw(chk, TweenInfo.new(0.2), { ImageTransparency = isSel and 0 or 1 })
                            ol.TextColor3 = isSel and Theme.Text or Theme.TextDim
                        end))
                        table.insert(optionPool, obtn)
                    end
                    
                    local ol = obtn:FindFirstChildOfClass("TextLabel")
                    local box = obtn:FindFirstChildOfClass("Frame")
                    local chk = box:FindFirstChildOfClass("ImageLabel")
                    ol.Text = strVal
                    obtn.Visible = true
                    
                    local isSel = table.find(selected, strVal) ~= nil
                    chk.ImageTransparency = isSel and 0 or 1
                    ol.TextColor3 = isSel and Theme.Text or Theme.TextDim
                    i = i + 1
                end
            end
            
            refreshOptions(values)
            
            addConnection(Search:GetPropertyChangedSignal("Text"):Connect(function()
                local q = Search.Text:lower()
                for _, b in ipairs(optionPool) do
                    if b.Visible or b.Name == "Opt" then
                        local txt = b:FindFirstChildOfClass("TextLabel").Text:lower()
                        b.Visible = (txt:find(q) ~= nil) and true or false
                    end
                end
            end))
            
            addConnection(Btn.MouseButton1Click:Connect(function()
                refreshOptions(values)
                Search.Text = ""
                openOverlay(function() List.Visible = false end)
                local abs = Btn.AbsolutePosition
                List.Position = UDim2.new(0, abs.X, 0, abs.Y + 30)
                List.Visible = true
            end))
            
            registerFlag(cfg, 'MultiDropdown', setVals)
            
            local comp = {
                Set = function(t, silent) setVals(t, silent) end,
                Get = function() return selected end,
                SetValues = function(t) refreshOptions(t) end,
                Destroy = function() unregister(cfg) EFrame:Destroy() List:Destroy() end
            }
            comp.Refresh = comp.SetValues
            return comp
        end
        
        return Tab
    end
    
    if config.EnableConfigTab then
        task.defer(function()
            if _destroyed then return end
            local TabConfig = Window:Tab({ Title = "Config", Icon = "settings", IsConfigTab = true })
            local configName = config.ConfigName or "default_config"
            local configDropdown
            
            TabConfig:TextBox({
                Title = "Config Name",
                Desc = "Type a name for the config",
                Placeholder = "farm_config",
                Callback = function(text) configName = text end
            })
            
            configDropdown = TabConfig:Dropdown({
                Title = "Saved Configs",
                Desc = "Select a saved config",
                Values = Window:GetConfigs(),
                Callback = function(val) configName = val end
            })
            
            TabConfig:Toggle({
                Title = "Auto Load",
                Desc = "Load this config automatically on startup",
                Flag = "AutoLoadConfig",
                Default = false,
                Callback = function(val)
                    if isCurrentlyLoading then return end
                    local _, gamePath = getConfigPath("")
                    local autoPath = gamePath .. "/AutoLoad.txt"
                    if val then
                        if writefile then writefile(autoPath, configName) end
                        Window:SaveConfig(configName)
                    else
                        if isfile and isfile(autoPath) and delfile then delfile(autoPath)
                        elseif writefile then writefile(autoPath, "") end
                        Window:SaveConfig(configName)
                    end
                end
            })
            
            TabConfig:Divider()
            TabConfig:Button({ Title = "Refresh Configs", ButtonText = "Refresh", Callback = function()
                if configDropdown and configDropdown.SetValues then
                    configDropdown.SetValues(Window:GetConfigs())
                    Window:Notify("Config", "Config list refreshed.", 2, "success")
                end
            end})
            TabConfig:Button({ Title = "Save Config", ButtonText = "Save", Callback = function()
                if configName == "" then return end
                Window:SaveConfig(configName)
                if configDropdown and configDropdown.SetValues then configDropdown.SetValues(Window:GetConfigs()) end
            end})
            TabConfig:Button({ Title = "Load Config", ButtonText = "Load", Callback = function()
                if configName == "" then return end
                Window:LoadConfig(configName)
            end})
            TabConfig:Button({ Title = "Delete Config", ButtonText = "Delete", Callback = function()
                if configName == "" then return end
                Window:DeleteConfig(configName)
                if configDropdown and configDropdown.SetValues then configDropdown.SetValues(Window:GetConfigs()) end
            end})
            TabConfig:Divider()
            TabConfig:Button({ Title = "Unload UI", ButtonText = "Unload", Callback = function() Window:Destroy() end })
        end)
    end
    
    task.spawn(function()
        task.wait(0.5)
        if _destroyed then return end
        if readfile and isfile then
            local _, gamePath = getConfigPath("")
            local autoPath = gamePath .. "/AutoLoad.txt"
            if isfile(autoPath) then
                local s, cName = pcall(readfile, autoPath)
                if s and type(cName) == "string" and cName ~= "" then
                    local path = gamePath .. "/" .. cName .. ".json"
                    if isfile(path) then Window:LoadConfig(cName) end
                end
            end
        end
    end)
    
    return Window
end

return PulseUI

--[[
================================================================
FULL USAGE EXAMPLE
================================================================
]]
