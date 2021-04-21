local seedRef = gui.Reference("Visuals", "Skins", "Configuration", "Seed")
local stattrackRef = gui.Reference("Visuals", "Skins", "Configuration", "StatTrak")
local sliderRef = gui.Reference("Visuals", "Skins", "Configuration")
local sliderRef2 = gui.Reference("Visuals", "Skins", "Configuration", "Skin Seed")

local slider = gui.Slider(sliderRef, "swaggin", "Skin Seed", 1, 0, 999)
slider:SetDescription("Set the seed for the skin.")

function removeSeed()
    gui.Reference("Visuals", "Skins", "Configuration", "Seed"):SetInvisible(true)
    stattrackRef:SetPosY(280)
    slider:SetPosY(210)
    seedRef:SetValue(tostring(slider:GetValue()))
    print(slider:GetValue())
end

callbacks.Register("Draw", removeSeed)

callbacks.Register("Unload", function()
    gui.Reference("Visuals", "Skins", "Configuration", "Seed"):SetInvisible(false)
    gui.Reference("Visuals", "Skins", "Configuration", "Seed"):SetPosY(210)
    gui.Reference("Visuals", "Skins", "Configuration", "Seed"):SetValue("")
    gui.Reference("Visuals", "Skins", "Configuration", "StatTrak"):SetPosY(280)   
end)