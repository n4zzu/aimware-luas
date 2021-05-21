cacheScopeFade = {}

local function cacheScopeFadeFunc()
    cacheScopeFade.chamType = gui.GetValue("esp.chams.local.visible")
    cacheScopeFade.chamColourR, cacheScopeFade.chamColourG, cacheScopeFade.chamColourB, cacheScopeFade.chamColourA = gui.GetValue("esp.chams.local.visible.clr")
end

cacheScopeFadeFunc()

local overriden = false
local manaully_changing = false

local function scopeFade()
    local weapon = entities.GetLocalPlayer():GetPropEntity("m_hActiveWeapon")
    local is_scoped = weapon:GetPropBool("m_zoomLevel")
    if is_scoped == true and not overriden then
        gui.SetValue("esp.chams.local.visible", 2)
        gui.SetValue("esp.chams.local.visible.clr", 112, 109, 103, 119)
        overriden = true
        manaully_changing = true
    end
    if is_scoped == false  and overriden then
        gui.SetValue("esp.chams.local.visible", cacheScopeFade.chamType)
        gui.SetValue("esp.chams.local.visible.clr", cacheScopeFade.chamColourR, cacheScopeFade.chamColourG, cacheScopeFade.chamColourB, cacheScopeFade.chamColourA)
        overriden = false
        manaully_changing = false
    end
    if not manaully_changing then
        cacheScopeFadeFunc()
    end
end

callbacks.Register("Draw", scopeFade)
