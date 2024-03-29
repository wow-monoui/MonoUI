local _, ns = ...
local oUF = ns.oUF or oUF

local function GetAuras()
	return {
		-- Spell Name			Priority (higher = more priority)
		-- Crowd control
		--[GetSpellInfo(61295)] 	= 3, 	-- Riptide(debug)
		
		[GetSpellInfo(33786)] 	= 3, 	-- Cyclone
		[GetSpellInfo(55041)] 	= 3, 	-- Freezing Trap Effect
		[GetSpellInfo(6770)]	= 3, 	-- Sap
		[GetSpellInfo(2094)]	= 3, 	-- Blind
		[GetSpellInfo(5782)]	= 3, 	-- Fear
		[GetSpellInfo(6789)]	= 3,	-- Death Coil Warlock
		[GetSpellInfo(6358)] 	= 3, 	-- Seduction
		[GetSpellInfo(5484)] 	= 3, 	-- Howl of Terror
		[GetSpellInfo(5246)] 	= 3, 	-- Intimidating Shout
		[GetSpellInfo(8122)] 	= 3,	-- Psychic Scream
		[GetSpellInfo(118)] 	= 3,	-- Polymorph
		[GetSpellInfo(28272)] 	= 3,	-- Polymorph pig
		[GetSpellInfo(28271)] 	= 3,	-- Polymorph turtle
		[GetSpellInfo(61305)] 	= 3,	-- Polymorph black cat
		[GetSpellInfo(61025)] 	= 3,	-- Polymorph serpent
		[GetSpellInfo(51514)]	= 3,	-- Hex
		[GetSpellInfo(710)]		= 3,	-- Banish
		
		-- Roots
		[GetSpellInfo(339)] 	= 3, 	-- Entangling Roots
		[GetSpellInfo(122)]		= 3,	-- Frost Nova
		[GetSpellInfo(16979)] 	= 3, 	-- Feral Charge
		[GetSpellInfo(13809)] 	= 1, 	-- Frost Trap
		
		-- Stuns and incapacitates
		[GetSpellInfo(5211)] 	= 3, 	-- Bash
		[GetSpellInfo(1833)] 	= 3,	-- Cheap Shot
		[GetSpellInfo(408)] 	= 3, 	-- Kidney Shot
		[GetSpellInfo(1776)]	= 3, 	-- Gouge
		[GetSpellInfo(19386)]	= 3, 	-- Wyvern Sting
		[GetSpellInfo(22570)]	= 3, 	-- Maim
		[GetSpellInfo(853)]		= 3, 	-- Hammer of Justice
		[GetSpellInfo(20066)] 	= 3, 	-- Repentance
		[GetSpellInfo(46968)] 	= 3, 	-- Shockwave
		--[GetSpellInfo(49203)] 	= 3,	-- Hungering Cold
		[GetSpellInfo(47481)]	= 3,	-- Gnaw (dk pet stun)
		
		-- Silences
		--[GetSpellInfo(18469)] 	= 1,	-- Improved Counterspell
		[GetSpellInfo(15487)] 	= 1, 	-- Silence
		--[GetSpellInfo(18425)]	= 1,	-- Improved Kick
		[GetSpellInfo(47476)]	= 1,	-- Strangulate
		
		-- Buffs
		[GetSpellInfo(1022)] 	= 1,	-- Blessing of Protection
		[GetSpellInfo(1044)] 	= 1, 	-- Blessing of Freedom
		[GetSpellInfo(2825)] 	= 1, 	-- Bloodlust
		[GetSpellInfo(32182)] 	= 1, 	-- Heroism
		[GetSpellInfo(33206)] 	= 1, 	-- Pain Suppression
		--[GetSpellInfo(18708)]  	= 1,	-- Fel Domination
		[GetSpellInfo(31821)]	= 1,	-- Devotion Aura
		
		-- Turtling abilities
		[GetSpellInfo(871)]	= 1,	-- Shield Wall
		[GetSpellInfo(48707)]	= 1,	-- Anti-Magic Shell
		[GetSpellInfo(31224)]	= 1,	-- Cloak of Shadows
		[GetSpellInfo(19263)]	= 1,	-- Deterrence
		
		-- Immunities
		[GetSpellInfo(45438)] 	= 2, 	-- Ice Block
		[GetSpellInfo(642)] 	= 2,	-- Divine Shield
		
	}
end

local function Update(object, event, unit)

	if object.unit ~= unit  then return end

	local auraList = GetAuras()
	local priority = 0
	local auraName, auraIcon, auraExpTime
	local index = 1

	--Buffs
	while ( true ) do
		local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
		nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, _ = UnitAura(unit, index, "HELPFUL")
		if ( not name ) then break end
		
		if ( auraList[name] and auraList[name] >= priority ) then
			priority = auraList[name]
			auraName = name
			auraIcon = icon
			auraExpTime = expirationTime
		end
		
		index = index+1
	end
	
	index = 1
	
	--Debuffs 
	while ( true ) do
		local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
		nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, _ = UnitAura(unit, index, "HARMFUL")
		if ( not name ) then break end
		
		if ( auraList[name] and auraList[name] >= priority ) then
			priority = auraList[name]
			auraName = name
			auraIcon = icon
			auraExpTime = expirationTime
		end
		
		index = index+1	
	end
	
	if ( auraName ) then -- If an aura is found, display it and set the time left!
		--frame.portrait:SetAlpha(0)
		object.AuraTracker.icon:SetTexture(auraIcon)
		--object.AuraTracker.text:SetFormattedText("%.1f", (auraExpTime-GetTime()))
		object.AuraTracker.timeleft = (auraExpTime-GetTime())
		object.AuraTracker.active = true
--	elseif ( not auraName and frame.CCFrame.auraActive ) then -- No aura found and one is shown? Kill it since it's no longer active!

	elseif ( not auraName ) then -- No aura found and one is shown? Kill it since it's no longer active!
		--frame.portrait:SetAlpha(1)
		object.AuraTracker.icon:SetTexture("")
		object.AuraTracker.text:SetText("")
		object.AuraTracker.active = false
	end
end

local function Enable(object)
	-- if we're not highlighting this unit return
	if not object.AuraTracker then return end

	-- make sure aura scanning is active for this object
	object:RegisterEvent("UNIT_AURA", Update)

	return true
end

local function Disable(object)
	if object.AuraTracker then
		object:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement('AuraTracker', Update, Enable, Disable)
