--[[ 
    RLWSCRIPTS - Short Example Usage
    Replace the URL below with your actual raw link!
]]

-- 1. Load the Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/therlw/Leaf-Framework/refs/heads/main/lumin.lua"))()

-- 2. Create Window
local Window = Library:Window({
    Name = "RLWSCRIPTS", 
    Version = "v1.2",
    Key = Enum.KeyCode.RightShift -- Toggle UI key
})

-- 3. Create Tab
local MainTab = Window:Tab("Auto Tap Farm", "rbxassetid://97273128833557")

-- 4. Create Section
local FarmSection = MainTab:Section("Auto Farm")

-- 5. Add Elements
FarmSection:Toggle("Enabled", false, function(value)
    print("Auto Farm is now:", value)
end)

FarmSection:Slider("Speed", 16, 200, 50, function(value)
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

-- DROPDOWN EXAMPLE
FarmSection:Dropdown("Farm Method", {"Tween", "Teleport", "Walk"}, "Tween", function(selected)
    print("Selected Method:", selected)
end)

FarmSection:Button("Kill All", function()
    print("Killed everyone!")
end)

-- Another Tab example
local VisualTab = Window:Tab("Egg Farm", "rbxassetid://82791574919596")
local EspSection = VisualTab:Section("ESP")

EspSection:Toggle("Box ESP", true, function(v) end)

-- TEXTBOX EXAMPLE
EspSection:Textbox("Target Player", "Enter name...", function(text)
    print("Target set to:", text)
end)

-- Notify User
Library:Notify("Success", "Script Loaded!", "success")
