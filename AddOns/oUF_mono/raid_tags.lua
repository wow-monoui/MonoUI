local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local L = {
	--priest
  ["Prayer of Mending"] = 33076,
  ["Renew"] = 139,
  ["Power Word: Shield"] = 17,
  ["Weakened Soul"] = 6788,
  ["Power Word: Fortitude"] = 21562,
  ["Fear Ward"] = 6346,
  ["Clarity of Will"] = 152118,
	--druid
  ["Lifebloom"] = 33763,
  ["Rejuvenation"] = 774,
  ["Rejuvenation (Germination)"] = 155777,
  ["Regrowth"] = 8936,
  ["Wild Growth"] = 48438,
  ["Mark of the Wild"] = 1126, -- bok/legacy
	--warrior
  ["Battle Shout"] = 6673,
  ["Commanding Shout"] = 469,
  ['Shield Wall'] = 871,
	--paladin
  ["Beacon of Light"] = 53563,
  ["Blessing of Sacrifice"] = 6940,
  ["Blessing of Freedom"] = 1044,
  ["Blessing of Protection"] = 1022,
  ["Forbearance"] = 25771,
	--shaman
  ['Earth Shield'] = 974,
  ['Riptide'] = 61295,
	--monk
  ["Legacy of the White Tiger"] = 116781,
  ["Legacy of the Emperor"] = 115921,
  ["Enveloping Mist"] = 124682,
  ["Renewing Mist"] = 119611,
  ["Life Cocoon"] = 116849,
	--rogue
  ["Tricks of the Trade"] = 57934,
	--warlock
  ["Soulstone"] = 20707,
	--mage
  ["Dalaran Brilliance"] = 61316,
  ["Arcane Brilliance"] = 1459,
  --demon hunter
  ["Soul Fragments"] = 203981,
}
local x = "M"

local getTime = function(expirationTime)
	local expire = -1*(GetTime()-expirationTime)
	local timeleft = format("%.0f", expire)
	if expire > 0.5 then
		local spellTimer = "|cffffff00"..timeleft.."|r"
		return spellTimer
	end
end

local function CalcDebuff(uid, debuff) -- to fill some information gaps of ns.lib.UnitDebuff()
	local name, icon, count, dur, expirationTime, caster, sdur, timeleft, start, dname

		dname = GetSpellInfo(debuff);
		if not dname then dname = debuff; end

	name, _, icon, count, _, dur, expirationTime, caster = ns.lib.UnitDebuff(uid, dname);
	if (name == dname) then
		if dur and dur > 0 then
			sdur = dur;
			start = expirationTime - dur;
			timeleft = GetTime() - start;
		else
			sdur = 0;
			ftimeleft = 0;
			start = 0;
		end
	end
	return name, count, icon, start, sdur, caster, timeleft;
end

-----------------[[ GENERAL TAGS ]]-----------------
oUF.Tags.Methods['raid:wrack'] = function(u) -- Sinestra's specific debuff
	local name,_,_,_,dur,_,remaining = CalcDebuff(u,92956) -- 57724 debug
	if not (name and remaining) then return end
	if remaining > 14 then -- FOAD
		return "|cffFF0000"..x.."|r"
	elseif remaining > 10 then -- criticall! dispel now!
		return "|cffFFCC00"..x.."|r"
	elseif remaining > 8 then -- start thinking about dispel!
		return "|cff00FF00"..x.."|r"
	else
		return "|cffB1C4B9"..x.."|r"
	end
end
oUF.Tags.Events['raid:wrack'] = "UNIT_AURA"

oUF.Tags.Methods['raid:aggro'] = function(u)
	local s = UnitThreatSituation(u) if s == 2 or s == 3 then return "|cffFF0000"..x.."|r" end end
oUF.Tags.Events['raid:aggro'] = "UNIT_THREAT_SITUATION_UPDATE"

-----------------[[ CLASS SPECIFIC TAGS ]]-----------------
--priest
oUF.Tags.Methods['raid:rnw'] = function(u)
    local name, _,_,_,_,_, expirationTime, fromwho = ns.lib.UnitAura(u, L["Renew"])
    if(fromwho == "player") then
        local spellTimer = GetTime()-expirationTime
        if spellTimer > -2 then
            return "|cffFF0000"..x.."|r"
        elseif spellTimer > -4 then
            return "|cffFF9900"..x.."|r"
        else
            return "|cff33FF33"..x.."|r"
        end
    end
end
oUF.Tags.Events['raid:rnw'] = "UNIT_AURA"
-- rnwtime
oUF.Tags.Methods['raid:rnwTime'] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = ns.lib.UnitAura(u, L["Renew"])
  if (fromwho == "player") then return getTime(expirationTime) end
end
oUF.Tags.Events['raid:rnwTime'] = "UNIT_AURA"
oUF.Tags.Methods['raid:pws'] = function(u) if ns.lib.UnitAura(u, L["Power Word: Shield"]) then return "|cff33FF33"..x.."|r" end end
oUF.Tags.Events['raid:pws'] = "UNIT_AURA"
oUF.Tags.Methods['raid:ws'] = function(u) if ns.lib.UnitDebuff(u, L["Weakened Soul"]) then return "|cffFF9900"..x.."|r" end end
oUF.Tags.Events['raid:ws'] = "UNIT_AURA"
oUF.Tags.Methods['raid:clow'] = function(u) if ns.lib.UnitAura(u, L["Clarity of Will"]) then return "|cff33FFFF"..x.."|r" end end
oUF.Tags.Events['raid:clow'] = "UNIT_AURA"
oUF.Tags.Methods['raid:fw'] = function(u) if ns.lib.UnitAura(u, L["Fear Ward"]) then return "|cff8B4513"..x.."|r" end end
oUF.Tags.Events['raid:fw'] = "UNIT_AURA"
oUF.Tags.Methods['raid:fort'] = function(u) local c = ns.lib.UnitAura(u, L["Power Word: Fortitude"]) or ns.lib.UnitAura(u, L["Commanding Shout"]) if not c then return "|cff00A1DE"..x.."|r" end end
oUF.Tags.Events['raid:fort'] = "UNIT_AURA"
oUF.Tags.Methods['raid:wsTime'] = function(u)
  local name, _,_,_,_,_, expirationTime = ns.lib.UnitDebuff(u, L["Weakened Soul"])
  if ns.lib.UnitDebuff(u, L["Weakened Soul"]) then return getTime(expirationTime) end
end
oUF.Tags.Events['raid:wsTime'] = "UNIT_AURA"

--druid
oUF.Tags.Methods['raid:rejuv'] = function(u)
  local name, _,_,_,_,_,_, fromwho,_ = ns.lib.UnitAura(u, L["Rejuvenation"])
  if not (fromwho == "player") then return end
  if ns.lib.UnitAura(u, L["Rejuvenation"]) then return "|cff00FEBF"..x.."|r" end end
oUF.Tags.Events['raid:rejuv'] = "UNIT_AURA"
-- rejuvtime
oUF.Tags.Methods['raid:rejuvTime'] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = ns.lib.UnitAura(u, L["Rejuvenation"])
  if (fromwho == "player") then return getTime(expirationTime) end
end
oUF.Tags.Events['raid:rejuvTime'] = "UNIT_AURA"
oUF.Tags.Methods['raid:regrow'] = function(u) if ns.lib.UnitAura(u, L["Regrowth"]) then return "|cff00FF10"..x.."|r" end end
oUF.Tags.Events['raid:regrow'] = "UNIT_AURA"
oUF.Tags.Methods['raid:wg'] = function(u) if ns.lib.UnitAura(u, L["Wild Growth"]) then return "|cff33FF33"..x.."|r" end end
oUF.Tags.Events['raid:wg'] = "UNIT_AURA"
oUF.Tags.Methods['raid:motw'] = function(u) if not(ns.lib.UnitAura(u, L["Mark of the Wild"]) or ns.lib.UnitAura(u,L["Blessing of Kings"]) or ns.lib.UnitAura(u,L["Legacy of the White Tiger"]) or ns.lib.UnitAura(u,L["Legacy of the Emperor"])) then return "|cff00A1DE"..x.."|r" end end
oUF.Tags.Events['raid:motw'] = "UNIT_AURA"

--warrior
oUF.Tags.Methods['raid:bsh'] = function(u) if ns.lib.UnitAura(u, L["Battle Shout"]) or ns.lib.UnitAura(u, L["Horn of Winter"]) then return "|cffff0000"..x.."|r" end end
oUF.Tags.Events['raid:bsh'] = "UNIT_AURA"
--oUF.Tags.Methods['raid:csh'] = function(u) if ns.lib.UnitAura(u, L["Power Word: Fortitude"]) or ns.lib.UnitAura(u, L["Commanding Shout"]) then return "|cffffff00"..x.."|r" end end
--oUF.Tags.Events['raid:csh'] = "UNIT_AURA"
oUF.Tags.Methods['raid:SW'] = function(u) if ns.lib.UnitAura(u, L['Shield Wall']) then return "|cff9900FF"..x.."|r" end end
oUF.Tags.Events['raid:SW'] = "UNIT_AURA"

--rogue
oUF.Tags.Methods['raid:tricks'] = function(u) if ns.lib.UnitAura(u, L["Tricks of the Trade"]) then return "|cff33FF33"..x.."|r" end end
oUF.Tags.Events['raid:tricks'] = "UNIT_AURA"

--demon hunter
oUF.Tags.Methods['raid:sf'] = function(u) if ns.lib.UnitAura(u, L["Soul Fragments"]) then return "|cff33FF33"..x.."|r" end end
oUF.Tags.Events['raid:sf'] = "UNIT_AURA"

--paladin
oUF.Tags.Events['raid:beaconTime'] = "UNIT_AURA"
oUF.Tags.Methods['raid:HoS'] = function(u) if ns.lib.UnitAura(u, L["Blessing of Sacrifice"]) then return "|cffEB2175"..x.."|r" end end
oUF.Tags.Events['raid:HoS'] = "UNIT_AURA"
oUF.Tags.Methods['raid:HoF'] = function(u) if ns.lib.UnitAura(u, L["Blessing of Freedom"]) then return "|cffA7EB21"..x.."|r" end end
oUF.Tags.Events['raid:HoF'] = "UNIT_AURA"
oUF.Tags.Methods['raid:HoP'] = function(u) if ns.lib.UnitAura(u, L["Blessing of Protection"]) then return "|cff96470F"..x.."|r" end end
oUF.Tags.Events['raid:HoP'] = "UNIT_AURA"
oUF.Tags.Methods['raid:beacon'] = function(u)
    local name, _,_,_,_,_, expirationTime, fromwho = ns.lib.UnitAura(u, L["Beacon of Light"])
    if not name then return end
    if(fromwho == "player") then
		return "|cffFFCC00"..x.."|r"
    else
		return "|cff996600"..x.."|r" -- other pally's beacon
    end
end
oUF.Tags.Events['raid:beacon'] = "UNIT_AURA"
oUF.Tags.Methods['raid:forb'] = function(u) if ns.lib.UnitDebuff(u, L["Forbearance"]) then return "|cffFF0000"..x.."|r" end end
oUF.Tags.Events['raid:forb'] = "UNIT_AURA"

--shaman
oUF.Tags.Methods['raid:rip'] = function(u)
	local name, _,_,_,_,_,_, fromwho,_ = ns.lib.UnitAura(u, L['Riptide'])
	if not (fromwho == 'player') then return end
	if ns.lib.UnitAura(u, L['Riptide']) then return '|cff00FEBF'..x..'|r' end end
oUF.Tags.Events['raid:rip'] = 'UNIT_AURA'
oUF.Tags.Methods['raid:ripTime'] = function(u)
	local name, _,_,_,_,_, expirationTime, fromwho,_ = ns.lib.UnitAura(u, L['Riptide'])
	if (fromwho == "player") then return getTime(expirationTime) end
end
oUF.Tags.Events['raid:ripTime'] = 'UNIT_AURA'

--monk
oUF.Tags.Methods['raid:rmTime'] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = ns.lib.UnitAura(u, L["Renewing Mist"])
  if (fromwho == "player") then return getTime(expirationTime) end
end
oUF.Tags.Events['raid:rmTime'] = "UNIT_AURA"
oUF.Tags.Methods['raid:em'] = function(u) if ns.lib.UnitAura(u, L["Enveloping Mist"]) then return "|cff33FF33"..x.."|r" end end
oUF.Tags.Events['raid:em'] = "UNIT_AURA"
oUF.Tags.Methods['raid:lc'] = function(u) if ns.lib.UnitAura(u, L["Life Cocoon"]) then return "|cffA7EB21"..x.."|r" end end
oUF.Tags.Events['raid:lc'] = "UNIT_AURA"

--warlock
oUF.Tags.Methods['raid:ss'] = function(u) if ns.lib.UnitAura(u, L["Soulstone"]) then return "|cff33FF33"..x.."|r" end end
oUF.Tags.Events['raid:ss'] = "UNIT_AURA"

--mage
oUF.Tags.Methods['raid:brill'] = function(u) local c = ns.lib.UnitAura(u, L["Dalaran Brilliance"]) or ns.lib.UnitAura(u, L["Arcane Brilliance"]) if not c then return "|cff00A1DE"..x.."|r" end end
oUF.Tags.Events['raid:brill'] = "UNIT_AURA"

oUF.classIndicators={
	["DRUID"] = {
			["TL"] = "[raid:regrow][raid:wg]",
			["TR"] = "[raid:lb]",
			["BL"] = "",
			["BR"] = "[raid:motw]",
			["Cen"] = "[raid:rejuvTime]",
	},
	["PRIEST"] = {
			["TL"] = "[raid:pws][raid:ws][raid:clow]",
			["TR"] = "[raid:pom]",
			["BL"] = "[raid:fw]",
			["BR"] = "[raid:fort]",
			["Cen"] = "[raid:rnwTime]",
	},
	["PALADIN"] = {
			["TL"] = "[raid:HoS][raid:HoF][raid:HoP][raid:forb]",
			["BL"] = "[raid:beacon]",

	},
	["WARLOCK"] = {
			["TL"] = "[raid:ss]",
			["TR"] = "",
			["BL"] = "",
			["BR"] = "",
			["Cen"] = "",
	},
	["WARRIOR"] = {
			["TL"] = "",
			["TR"] = "",
			["BL"] = "",
			["BR"] = "[raid:fort][raid:bsh]",
			["Cen"] = "",
	},
	["DEATHKNIGHT"] = {
			["TL"] = "",
			["TR"] = "",
			["BL"] = "",
			["Cen"] = "",
	},
	["SHAMAN"] = {
			["TL"] = "",
			["TR"] = "[raid:earth]",
			["BL"] = "[raid:wrack]",
			["BR"] = "",
			["Cen"] = "[raid:ripTime]",
	},
	["HUNTER"] = {
			["TL"] = "",
			["TR"] = "",
			["BL"] = "",
			["BR"] = "",
			["Cen"] = "",
	},
	["ROGUE"] = {
			["TL"] = "[raid:tricks]",
			["TR"] = "",
			["BL"] = "",
			["BR"] = "",
			["Cen"] = "",
	},
	["MAGE"] = {
			["TL"] = "",
			["TR"] = "",
			["BL"] = "",
			["BR"] = "[raid:brill]",
			["Cen"] = "",
	},
	["MONK"] = {
			["TL"] = "[raid:em]",
			["TR"] = "",
			["BL"] = "[raid:lc]",
			["BR"] = "[raid:motw]",
			["Cen"] = "[raid:rmTime]",
	},
	["DEMONHUNTER"] = {
		["TL"] = "",
		["TR"] = "",
		["BL"] = "",
		["BR"] = "",
		["Cen"] = "",
	},
}
