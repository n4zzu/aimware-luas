local visualsRef = gui.Reference("Visuals")
local seedRef = gui.Reference("Visuals", "Skins", "Configuration", "Seed")
local stattrackRef = gui.Reference("Visuals", "Skins", "Configuration", "StatTrak")
local sliderRef = gui.Reference("Visuals", "Skins", "Configuration")
local sliderRef2 = gui.Reference("Visuals", "Skins", "Configuration", "Skin Seed")

local slider = gui.Slider(sliderRef, "swaggin", "Skin Seed", 1, 0, 999)
slider:SetDescription("Set the seed for the skin.")

local skinTab = gui.Tab(visualsRef, "skinTab", "Skin Seeds")
local mainGroup = gui.Groupbox(skinTab, "Skin Seeds", 16, 16, 605, 100)

gui.Text(mainGroup, "Karambit Case Hardened - seed 231 - Full Gold")
gui.Text(mainGroup, "Karambit Case Hardened - seed 442 - Playside 100% Cloudy Blue Gem")
gui.Text(mainGroup, "Karambit Doppler1 - seed 583 - Best Ruby Seed")
gui.Text(mainGroup, "M9 Bayonet Case Hardened - seed 72 - Full Gold")
gui.Text(mainGroup, "M9 Bayonet Case Hardened - seed 58 - Playside Blue Gem (75% - 80%)")
gui.Text(mainGroup, "M9 Bayonet Case Hardened - seed 601 - OCEANO")
gui.Text(mainGroup, "Butterfly Knife Case Hardened - seed 510 - Blue Gem")

function removeSeed()
    gui.Reference("Visuals", "Skins", "Configuration", "Seed"):SetInvisible(true)
    stattrackRef:SetPosY(280)
    slider:SetPosY(210)
    seedRef:SetValue(tostring(slider:GetValue()))
end

callbacks.Register("Draw", removeSeed)

callbacks.Register("Unload", function()
    gui.Reference("Visuals", "Skins", "Configuration", "Seed"):SetInvisible(false)
    gui.Reference("Visuals", "Skins", "Configuration", "Seed"):SetPosY(210)
    gui.Reference("Visuals", "Skins", "Configuration", "Seed"):SetValue("")
    gui.Reference("Visuals", "Skins", "Configuration", "StatTrak"):SetPosY(280)   
end)
