local miscRef = gui.Reference("RAGEBOT")
local nxzAA = gui.Tab(miscRef, "nxzAA", "nxzAA")
local miscGroup = gui.Groupbox(nxzAA, "AA Settings", 16,16,296,100)
local miscGroup2 = gui.Groupbox(nxzAA, "Misc Settings", 328,16,296,100)
local miscGroup3 = gui.Groupbox(nxzAA, "Fakelag Settings", 16, 390, 296, 100)

local idealTickCheckBox = gui.Checkbox(miscGroup, "idealTick", "Ideal Tick", false)
local idealTickMinDmg = gui.Slider(miscGroup, "idealTickMinDmg", "idealTick Min Dmg", 1, 1, 130)
local lagSyncCheckBox = gui.Checkbox(miscGroup, "lagsync", "LagSync V1", false)
local lagSyncCheckBox2 = gui.Checkbox(miscGroup, "lagsync2", "LagSync V2", false)
local lowDeltaCheckBox = gui.Checkbox(miscGroup, "lowDelta", "Low Delta", false)
local lowDeltaInvertCheckBox = gui.Checkbox(miscGroup, "lowDeltaInvert", "Invert Low Delta", false)

local sniperXHair = gui.Checkbox(miscGroup2, "sniperxhair", "Sniper Crosshair", false)
local killEffect = gui.Checkbox(miscGroup2, "killEffect", "Kill Effect", false)
local killEffectTime = gui.Slider(miscGroup2, "killEffectTime", "Kill Effect Time", 3, 3, 10)
local engineGrenadePred = gui.Checkbox(miscGroup2, "grenPred", "Engine Grenade Prediction", false)
local forceBaimCheckBox = gui.Checkbox(miscGroup2, "forceBaim", "Force Baim", false)
local forceBaimComboBox = gui.Combobox(miscGroup2, "forceBaimOptions", "Force Baim Strength", "Normal", "Strong", "Super Strong (Will cause you to shoot slower)")

local nxzLagCheckBox = gui.Checkbox(miscGroup3, "nxzLag", "nxzLag", false)
local adaptiveJitterCheckBox = gui.Checkbox(miscGroup3, "adaptiveJitter", "Adaptive Jitter", false)

lagSyncCheckBox:SetDescription("LagSync with wide jitter")
lagSyncCheckBox2:SetDescription("LagSync with smaller jitter")
lowDeltaCheckBox:SetDescription("Low Delta AA")
lowDeltaInvertCheckBox:SetDescription("Invert Low Delta")
idealTickCheckBox:SetDescription("Teleport back to cover when peaking")
sniperXHair:SetDescription("Forces engine crosshair on snipers")
killEffect:SetDescription("Healthshot overlay on kill")
killEffectTime:SetDescription("Healthshot duration")
engineGrenadePred:SetDescription("Forces engine grenade prediction")
nxzLagCheckBox:SetDescription("beste p100 fakelag math.random")
adaptiveJitterCheckBox:SetDescription("Switch FL on slowwalk & standing. Adaptive on move")

local devMode = "[DEV]"
local userName = client.GetConVar( "name" )
local indFont = draw.CreateFont(Verdana, 26, 800)

local function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function draw.Rect(x,y,w,h)
    draw.FilledRect(x,y, x + w, y + h)
end

local function Getserver()
    if (engine.GetServerIP() == "loopback") then return "Local Server" 
    elseif (engine.GetServerIP() == nil) then return "Main Menu"
    else return engine.GetServerIP();        
    end
end

cache = {}

--[[Watermark Start]]--

function watermark()

    local Localplayer, LocalplayerIndex, LocalplayerVALID = entities.GetLocalPlayer(), client.GetLocalPlayerIndex(), false;
    if (Localplayer ~= nil) then LocalplayerVALID = true; end

    local Latency = LocalplayerVALID and 
        tostring(entities.GetPlayerResources():GetPropInt("m_iPing", LocalplayerIndex)) 
        or "0";

    local Velocity = LocalplayerVALID and 
        Round(math.sqrt(Localplayer:GetPropFloat("localdata", "m_vecVelocity[0]") ^ 2 + Localplayer:GetPropFloat("localdata", "m_vecVelocity[1]") ^ 2), 0)
        or "0";

    nxzTextSize = draw.GetTextSize("nxz")
    nxzAATextSize = draw.GetTextSize("nxzAA")
    fullStringSize = draw.GetTextSize(" | " .. userName .. " | Latency: " .. Latency .. "ms" .. " | Velocity: " .. Velocity .. " | " .. Getserver())
    draw.Color(5,5,5,255)
    draw.Rect(5, 5, fullStringSize + nxzAATextSize + 22, 31)
    draw.Color(60,60,60,255)
    draw.Rect(6, 6, fullStringSize + nxzAATextSize + 20, 29)
    draw.Color(40,40,40,255)
    draw.Rect(7, 7, fullStringSize + nxzAATextSize + 18, 26)
    draw.Color(60,60,60,255)
    draw.Rect(9, 9, fullStringSize + nxzAATextSize + 14, 22)
    draw.Color(17,17,17,255)
    draw.Rect(10, 10, fullStringSize + nxzAATextSize + 12, 20)
    draw.Color(255, 255, 255)
    draw.TextShadow(15, 14, "nxz")
    draw.Color(252, 166, 255)
    draw.TextShadow(16 + nxzTextSize, 14, "AA")
    draw.Color(255, 255, 255)
    fullString = draw.TextShadow(16 + nxzAATextSize, 14, " | " .. userName .. " | Latency: " .. Latency .. "ms" .. " | Velocity: " .. Velocity .. " | " .. Getserver())
end

--[[Watermark End]]--

--[[idealTick Start]]--

cache2 = {}
local function cache_fn()
    cache2.scoutMinDmg = gui.GetValue("rbot.accuracy.weapon.scout.mindmg")
    cache2.awpMinDmg = gui.GetValue("rbot.accuracy.weapon.sniper.mindmg")
    cache2.hpistolMinDmg = gui.GetValue("rbot.accuracy.weapon.hpistol.mindmg")
    cache2.fakeLatency = gui.GetValue("misc.fakelatency.enable")
    cache2.fakeLatencyAmount = gui.GetValue("misc.fakelatency.amount")
    cache2.fakeLag = gui.GetValue("misc.fakelag.enable")
    cache2.fakeLagAmount = gui.GetValue("misc.fakelag.factor")
end

cache_fn()

local overriden = false
local manaully_changing = false

function idealTick()
    local quickPeakKey = gui.GetValue("rbot.accuracy.movement.autopeekkey")
	if quickPeakKey ~= 0 and input.IsButtonDown(quickPeakKey) and not overriden and idealTickCheckBox:GetValue() then
        gui.SetValue("misc.fakelatency.enable", true)
        gui.SetValue("misc.fakelatency.amount", 120)
        gui.SetValue("misc.fakelag.enable", false)
        gui.SetValue("misc.fakelag.factor", 1)
        gui.SetValue("rbot.accuracy.weapon.sniper.doublefire", 2)
        gui.SetValue("rbot.accuracy.weapon.scout.doublefire", 2)
        gui.SetValue("rbot.accuracy.weapon.hpistol.doublefire", 2)
        gui.SetValue("rbot.accuracy.weapon.sniper.mindmg", idealTickMinDmg:GetValue())
        gui.SetValue("rbot.accuracy.weapon.scout.mindmg", idealTickMinDmg:GetValue())
        gui.SetValue("rbot.accuracy.weapon.hpistol.mindmg", idealTickMinDmg:GetValue())
        overriden = true
		manaully_changing = true
	end
	
	if quickPeakKey ~= 0 and input.IsButtonReleased(quickPeakKey) and overriden then
        gui.SetValue("misc.fakelatency.enable", cache2.fakeLatency)
        gui.SetValue("misc.fakelatency.amount", cache2.fakeLatencyAmount)
        gui.SetValue("misc.fakelag.enable", cache2.fakeLag)
        gui.SetValue("misc.fakelag.factor", cache2.fakeLagAmount)
        gui.SetValue("rbot.accuracy.weapon.sniper.doublefire", 0)
        gui.SetValue("rbot.accuracy.weapon.scout.doublefire", 0)
        gui.SetValue("rbot.accuracy.weapon.hpistol.doublefire", 0)
        gui.SetValue("rbot.accuracy.weapon.scout.mindmg", cache2.scoutMinDmg)
        gui.SetValue("rbot.accuracy.weapon.sniper.mindmg", cache2.awpMinDmg)
        gui.SetValue("rbot.accuracy.weapon.hpistol.mindmg", cache2.hpistolMinDmg)
		overriden = false
		manaully_changing = false
	end
	
	if not manaully_changing then
		cache_fn()
	end
	
end

--[[idealTick End]]--


--[[lagSync Start]]--

local function lagSync()
    if lagSyncCheckBox:GetValue() == true then  
        gui.SetValue("rbot.antiaim.base", math.random(160, 180))
        gui.SetValue("misc.fakelag.factor", math.random(4, 11))
        gui.SetValue("rbot.antiaim.base.rotation", math.random(-15, 15))
    else
        return
    end
end

--[[lagSync End]]--

--[[lagSync2 Start]]--

local function lagSync2()
    if lagSyncCheckBox2:GetValue() == true then  
        gui.SetValue("rbot.antiaim.base", math.random(170, 180))
        gui.SetValue("misc.fakelag.factor", math.random(7, 14))
        gui.SetValue("rbot.antiaim.base.rotation", math.random(-12, 30))
    else
        return
    end
end

--[[lagSync2 End]]--

--[[SNIPER CROSSHAIR START]]--
callbacks.Register('Draw', function()
    if sniperXHair:GetValue() then 
        client.SetConVar( "weapon_debug_spread_show", 3, true )
    else
        client.SetConVar( "weapon_debug_spread_show", 0, true )
    end
     
end)
--[[SNIPER CROSSHAIR END]]--

--[[KILL EFFECT START]]--
function Kill_Effect( Event )
    if killEffect:GetValue() == true then
        if ( Event:GetName() == 'player_death' ) then
            local ME = client.GetLocalPlayerIndex();

            local INT_UID = Event:GetInt( 'userid' );
            local INT_ATTACKER = Event:GetInt( 'attacker' );

            local INDEX_Victim = client.GetPlayerIndexByUserID( INT_UID );
            local INDEX_Attacker = client.GetPlayerIndexByUserID( INT_ATTACKER );

            if ( INDEX_Attacker == ME and INDEX_Victim ~= ME ) then
                entities.GetLocalPlayer():SetPropFloat(globals.CurTime() + (gui.GetValue( "rbot.nxzAA.killEffectTime" ) * 0.1), "m_flHealthShotBoostExpirationTime");
            else
                return;
            end
        end
    end
end

client.AllowListener( 'player_death' );

callbacks.Register('FireGameEvent', 'AWKS', Kill_Effect);
--[[KILL EFFECT END]]--

--[[GRENADE PRED START]]--
local function engineNadePred()
    if engineGrenadePred:GetValue() == true then
        if gui.GetValue("esp.world.nadetracer.local") == true then
            gui.SetValue("esp.world.nadetracer.local", 0)
            client.SetConVar("cl_grenadepreview", 1, 1)
        else
            client.SetConVar("cl_grenadepreview", 1, 1)
        end
    else
        client.SetConVar("cl_grenadepreview", 0, 1)
    end
end
--[[GRENADE PRED END]]--

--[[FakeLag Start]]--

local function nxzLag()
    if nxzLagCheckBox:GetValue() == true then
        gui.SetValue("misc.fakelag.type", math.random(0, 2))
        gui.SetValue("misc.fakelag.factor", math.random(6, 14))
        gui.SetValue("misc.slidewalk", math.random(0, 1))
    else
        return
    end
end

local function adaptiveJitter()
    if adaptiveJitterCheckBox:GetValue() == true then
        local Localplayer, LocalplayerIndex, LocalplayerVALID = entities.GetLocalPlayer(), client.GetLocalPlayerIndex(), false;
        if (Localplayer ~= nil) then LocalplayerVALID = true; end
        local Velocity = LocalplayerVALID and 
        Round(math.sqrt(Localplayer:GetPropFloat("localdata", "m_vecVelocity[0]") ^ 2 + Localplayer:GetPropFloat("localdata", "m_vecVelocity[1]") ^ 2), 0)
        or "0";

        if tonumber(Velocity) <= 131 then
            gui.SetValue("misc.fakelag.type", 3)
            gui.SetValue("misc.fakelag.factor", math.random(11, 15))
            gui.SetValue("misc.slidewalk", math.random(0, 1))
        elseif tonumber(Velocity) >= 132 then
            gui.SetValue("misc.fakelag.type", 1)
            gui.SetValue("misc.fakelag.factor", math.random(8, 12))
            gui.SetValue("misc.slidewalk", 0)
        end
    else
        return
    end
end

--[[FakeLag End]]--

--[[Force Baim Start]]--

cache3 = {}
local function cache_fn()
    cache3.scoutHitPoints = gui.GetValue("rbot.hitscan.points.scout.scale")
    cache3.sniperHitPoints = gui.GetValue("rbot.hitscan.points.sniper.scale")
    cache3.asniperHitPoints = gui.GetValue("rbot.hitscan.points.asniper.scale")
    cache3.hpistolHitPoints = gui.GetValue("rbot.hitscan.points.hpistol.scale")
    cache3.pistolHitPoints = gui.GetValue("rbot.hitscan.points.pistol.scale")

    cache3.scoutBaim = gui.GetValue("rbot.hitscan.mode.scout.bodyaim.force")
    cache3.sniperBaim = gui.GetValue("rbot.hitscan.mode.sniper.bodyaim.force")
    cache3.asniperBaim = gui.GetValue("rbot.hitscan.mode.asniper.bodyaim.force")
    cache3.hpistolBaim = gui.GetValue("rbot.hitscan.mode.hpistol.bodyaim.force")
    cache3.pistolBaim = gui.GetValue("rbot.hitscan.mode.pistol.bodyaim.force")
end

cache_fn()

local overriden = false
local manaully_changing = false

local function forceBaim()
    if forceBaimCheckBox:GetValue() == true and forceBaimComboBox:GetValue() == 0 and not overriden then
        gui.SetValue("rbot.hitscan.mode.scout.bodyaim.force", true)
        gui.SetValue("rbot.hitscan.mode.asniper.bodyaim.force", true)
        gui.SetValue("rbot.hitscan.mode.sniper.bodyaim.force", true)
        gui.SetValue("rbot.hitscan.mode.pistol.bodyaim.force", true)
        gui.SetValue("rbot.hitscan.mode.hpistol.bodyaim.force", true)
        overriden = true
        manaully_changing = true
    end
    if forceBaimCheckBox:GetValue() == false and forceBaimComboBox:GetValue() == 0 and overriden then
        gui.SetValue("rbot.hitscan.mode.scout.bodyaim.force", cache3.scoutBaim)
        gui.SetValue("rbot.hitscan.mode.asniper.bodyaim.force", cache3.asniperBaim)
        gui.SetValue("rbot.hitscan.mode.sniper.bodyaim.force", cache3.sniperBaim)
        gui.SetValue("rbot.hitscan.mode.pistol.bodyaim.force", cache3.pistolBaim)
        gui.SetValue("rbot.hitscan.mode.hpistol.bodyaim.force", cache3.hpistolBaim)
        overriden = false
        manaully_changing = false
    end
    if forceBaimCheckBox:GetValue() == true and forceBaimComboBox:GetValue() == 1 and not overriden then
        gui.SetValue("rbot.hitscan.mode.scout.bodyaim.force", true)
        gui.SetValue("rbot.hitscan.mode.asniper.bodyaim.force", true)
        gui.SetValue("rbot.hitscan.mode.sniper.bodyaim.force", true)
        gui.SetValue("rbot.hitscan.mode.pistol.bodyaim.force", true)
        gui.SetValue("rbot.hitscan.mode.hpistol.bodyaim.force", true)
        gui.Command("rbot.hitscan.points.scout.scale 0 2 0 2 2 0 0 0 ")
        gui.Command("rbot.hitscan.points.sniper.scale 0 2 0 2 2 0 0 0 ")
        gui.Command("rbot.hitscan.points.asniper.scale 0 2 0 2 2 0 0 0 ")
        gui.Command("rbot.hitscan.points.pistol.scale 0 2 0 2 2 0 0 0 ")
        gui.Command("rbot.hitscan.points.hpistol.scale 0 2 0 2 2 0 0 0 ")
        overriden = true
        manaully_changing = true
    end
    if forceBaimCheckBox:GetValue() == false and forceBaimComboBox:GetValue() == 1 and overriden then
        gui.SetValue("rbot.hitscan.mode.scout.bodyaim.force", false)
        gui.SetValue("rbot.hitscan.mode.asniper.bodyaim.force", false)
        gui.SetValue("rbot.hitscan.mode.sniper.bodyaim.force", false)
        gui.SetValue("rbot.hitscan.mode.pistol.bodyaim.force", false)
        gui.SetValue("rbot.hitscan.mode.hpistol.bodyaim.force", false)
        gui.SetValue("rbot.hitscan.points.scout.scale", cache3.scoutHitPoints)
        gui.SetValue("rbot.hitscan.points.sniper.scale", cache3.sniperHitPoints)
        gui.SetValue("rbot.hitscan.points.asniper.scale", cache3.asniperHitPoints)
        gui.SetValue("rbot.hitscan.points.pistol.scale", cache3.pistolHitPoints)
        gui.SetValue("rbot.hitscan.points.hpistol.scale", cache3.hpistolHitPoints)
        overriden = false
        manaully_changing = false
    end
    if forceBaimCheckBox:GetValue() == true and forceBaimComboBox:GetValue() == 2 and not overriden then
        gui.SetValue("rbot.hitscan.mode.scout.bodyaim.force", true)
        gui.SetValue("rbot.hitscan.mode.asniper.bodyaim.force", true)
        gui.SetValue("rbot.hitscan.mode.sniper.bodyaim.force", true)
        gui.SetValue("rbot.hitscan.mode.pistol.bodyaim.force", true)
        gui.SetValue("rbot.hitscan.mode.hpistol.bodyaim.force", true)
        gui.Command("rbot.hitscan.points.scout.scale 0 3 0 4 4 0 0 0 ")
        gui.Command("rbot.hitscan.points.sniper.scale 0 3 0 4 4 0 0 0 ")
        gui.Command("rbot.hitscan.points.asniper.scale 0 3 0 4 4 0 0 0 ")
        gui.Command("rbot.hitscan.points.pistol.scale 0 3 0 4 4 0 0 0 ")
        gui.Command("rbot.hitscan.points.hpistol.scale 0 3 0 4 4 0 0 0 ")
        overriden = true
        manaully_changing = true
    end
    if forceBaimCheckBox:GetValue() == false and forceBaimComboBox:GetValue() == 2 and overriden then
        gui.SetValue("rbot.hitscan.mode.scout.bodyaim.force", false)
        gui.SetValue("rbot.hitscan.mode.asniper.bodyaim.force", false)
        gui.SetValue("rbot.hitscan.mode.sniper.bodyaim.force", false)
        gui.SetValue("rbot.hitscan.mode.pistol.bodyaim.force", false)
        gui.SetValue("rbot.hitscan.mode.hpistol.bodyaim.force", false)
        gui.SetValue("rbot.hitscan.points.scout.scale", cache3.scoutHitPoints)
        gui.SetValue("rbot.hitscan.points.sniper.scale", cache3.sniperHitPoints)
        gui.SetValue("rbot.hitscan.points.asniper.scale", cache3.asniperHitPoints)
        gui.SetValue("rbot.hitscan.points.pistol.scale", cache3.pistolHitPoints)
        gui.SetValue("rbot.hitscan.points.hpistol.scale", cache3.hpistolHitPoints)
        overriden = false
        manaully_changing = false
    end
    if not manaully_changing then
		cache_fn()
	end
end

--[[Force Baim Start]]--

--[[Low Delta Start]]--

local function lowDelta()
    rotation = 6
    lby = -68
    if lowDeltaInvertCheckBox:GetValue() == true then
        rotation = -6
        lby = 68
    else
        rotation = 6
        lby = -68
    end
    if lowDeltaCheckBox:GetValue() == true then
        gui.SetValue("rbot.antiaim.base.rotation", rotation)
        gui.SetValue("rbot.antiaim.base.lby", lby)  
    end
end

--[[Low Delta End]]--

--[[Indicators Start]]--

local function indicators()
    local quickPeakKey = gui.GetValue("rbot.accuracy.movement.autopeekkey")
    if quickPeakKey ~= 0 and input.IsButtonDown(quickPeakKey) and idealTickCheckBox:GetValue() then
        draw.Color(23, 255, 23)
        draw.SetFont(indFont)
        draw.TextShadow(5, 800, "IT")
    elseif idealTickCheckBox:GetValue() then
        draw.Color(255, 23, 23)
        draw.SetFont(indFont)
        draw.TextShadow(5, 800, "IT")
    end

    if forceBaimCheckBox:GetValue() == true then
        draw.Color(23, 255, 23)
        draw.SetFont(indFont)
        draw.TextShadow(5, 825, "BAIM")
    else
        return
    end
end

local function ldInd()
    if lowDeltaCheckBox:GetValue() == true and lowDeltaInvertCheckBox:GetValue() == true then
        print("swaggin")
        draw.Color(23, 255, 23)
        draw.SetFont(indFont)
        draw.TextShadow(5, 850, "LD <")
    elseif lowDeltaCheckBox:GetValue() == true and lowDeltaInvertCheckBox:GetValue() == false then
        print("swaggin")
        draw.Color(23, 255, 23)
        draw.SetFont(indFont)
        draw.TextShadow(5, 850, "LD >")
    else
        return
    end
end

--[[Indicators End]]--
callbacks.Register("Draw", ldInd)
callbacks.Register("Draw", lagSync)
callbacks.Register("Draw", lagSync2)
callbacks.Register("Draw", lowDelta)
callbacks.Register("Draw", idealTick)
callbacks.Register("Draw", watermark)
callbacks.Register("Draw", indicators)
callbacks.Register("Draw", engineNadePred)
callbacks.Register("Draw", nxzLag)
callbacks.Register("Draw", adaptiveJitter)
callbacks.Register("Draw", forceBaim)
callbacks.Register("FireGameEvent", "nadePredict", engineNadePred)
callbacks.Register("Draw", function() killEffectTime:SetInvisible(killEffect:GetValue() == false) end)
