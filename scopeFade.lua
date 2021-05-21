local cacheScopeFade = {}
local weaponsWithScope = {
    ["weapon_awp"] = true,
    ["weapon_g3sg1"] = true,
    ["weapon_scar20"] = true,
    ["weapon_ssg08"] = true,
} 

local function cacheScopeFadeFunc()
    cacheScopeFade.chamType = gui.GetValue("esp.chams.local.visible")
    cacheScopeFade.chamColourR, cacheScopeFade.chamColourG, cacheScopeFade.chamColourB, cacheScopeFade.chamColourA = gui.GetValue("esp.chams.local.visible.clr")
end

local function canScope(weapon)
    return weaponsWithScope[tostring(weapon)] or false
end
cacheScopeFadeFunc()

local overriden = false
local manaullyChanging = false

local function override()
    gui.SetValue("esp.chams.local.visible", 2)
    gui.SetValue("esp.chams.local.visible.clr", 112, 109, 103, 119)
    overriden = true
    manaullyChanging = true
end

local function undo()
    gui.SetValue("esp.chams.local.visible", cacheScopeFade.chamType)
    gui.SetValue("esp.chams.local.visible.clr", cacheScopeFade.chamColourR, cacheScopeFade.chamColourG, cacheScopeFade.chamColourB, cacheScopeFade.chamColourA)
    overriden = false
    manaullyChanging = false
end

local function scopeFade(e)
    if e:GetName() ~= "weapon_zoom" and e:GetName() ~= "item_equip" then return end
    local weapon = entities.GetLocalPlayer():GetPropEntity("m_hActiveWeapon")
    if not canScope(weapon) then if overriden then undo() end return end
    local isScoped = weapon:GetPropBool("m_zoomLevel")
    if isScoped and not overriden then
        override()
    elseif not isScoped and overriden then
        undo()
    end
    if not manaullyChanging then
        cacheScopeFadeFunc()
    end
end

callbacks.Register("FireGameEvent", scopeFade)
client.AllowListener("weapon_zoom")
client.AllowListener("item_equip")
