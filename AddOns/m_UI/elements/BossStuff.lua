local addon, ns = ...
local cfg = ns.cfg

-- Paragons catalyst
local function pc_announce(txt, sound)
  SendChatMessage(txt, "SAY")
  SendChatMessage(txt, "WHISPER", nil, UnitName("player"))
  PlaySoundFile(sound,"Master")
end
local gr_t, gr_s = "{triangle}Catalyst: GREEN!{triangle}","Sound\\Creature\\ProfessorPutricide\\IC_Putricide_SlimeFlow01.wav"
local or_t, or_s = "{circle}Catalyst: ORANGE!{circle}","Sound\\Creature\\Festergut\\IC_Festergut_ExpungeBlight01.wav"
local pu_t, pu_s = "{diamond}Catalyst: PURPLE!{diamond}","Sound\\Creature\\XT002Deconstructor\\UR_XT002_Special01.wav"

-- Handle the cast.
local pc_green_casting = 0
local pc_orange_casting = 0
local pc_purple_casting = 0

local function PC_OnEvent(event,...)

  local pc_event = select(3,...)
  local pc_spell_cast = select(14,...)

  if pc_event == "SPELL_CAST_START" then
    if pc_spell_cast == "Catalyst: Green" then
		pc_green_casting = 1
		if UnitDebuff("player", "Toxin: Blue") or UnitDebuff("player", "Toxin: Yellow") then pc_announce(gr_t, gr_s) end
    end
    if pc_spell_cast == "Catalyst: Orange" then
		pc_orange_casting = 1
		if UnitDebuff("player", "Toxin: Red") or UnitDebuff("player", "Toxin: Yellow") then  pc_announce(or_t, or_s) end
    end
    if pc_spell_cast == "Catalyst: Purple" then
		pc_purple_casting = 1
		if UnitDebuff("player", "Toxin: Red") or UnitDebuff("player", "Toxin: Blue") then pc_announce(pu_t, pu_s) end
    end
  end

  if pc_event == "SPELL_CAST_SUCCESS" then
    if pc_spell_cast == "Catalyst: Green"  then  pc_green_casting = 0 end
    if pc_spell_cast == "Catalyst: Orange" then  pc_orange_casting = 0 end
    if pc_spell_cast == "Catalyst: Purple" then  pc_purple_casting = 0 end
  end
end

local PC_Casts = CreateFrame("Frame")
PC_Casts:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
PC_Casts:SetScript("OnEvent", PC_OnEvent)

-- Handle the debuff.
local pc_toxin_red = 0
local pc_toxin_blue = 0
local pc_toxin_yellow = 0

local function onUpdate_debuff(self,elapsed)

  -- save old values
  local pc_toxin_red_old = pc_toxin_red
  local pc_toxin_blue_old = pc_toxin_blue
  local pc_toxin_yellow_old = pc_toxin_yellow

  -- get new values
  if UnitDebuff("player", "Toxin: Red") ~= nil    then pc_toxin_red = 1    else pc_toxin_red = 0    end
  if UnitDebuff("player", "Toxin: Blue") ~= nil   then pc_toxin_blue = 1   else pc_toxin_blue = 0   end
  if UnitDebuff("player", "Toxin: Yellow") ~= nil then pc_toxin_yellow = 1 else pc_toxin_yellow = 0 end

  -- compare old values with new values
  if pc_toxin_red_old < pc_toxin_red then -- player just gained "Toxic: Red" debuff
    if pc_orange_casting == 1 then  pc_announce(or_t, or_s)  end -- gained red debuff during orange cast
    if pc_purple_casting == 1 then  pc_announce(pu_t, pu_s)  end -- gained red debuff during purple cast
  end

  if pc_toxin_blue_old < pc_toxin_blue then -- player just gained "Toxic: Blue" debuff
    if pc_green_casting == 1  then  pc_announce(gr_t, gr_s)   end -- gained blue debuff during green cast
    if pc_purple_casting == 1 then  pc_announce(pu_t, pu_s)  end -- gained blue debuff during purple cast
  end
  
  if pc_toxin_yellow_old < pc_toxin_yellow then -- player just gained "Toxic: Yellow" debuff
    if pc_green_casting == 1  then  pc_announce(gr_t, gr_s)   end -- gained yellow debuff during green cast
    if pc_orange_casting == 1 then  pc_announce(or_t, or_s)  end -- gained yellow debuff during orange cast
  end
  
end

local pc_handle_debuff = CreateFrame("frame")
pc_handle_debuff:SetScript("OnUpdate", onUpdate_debuff) 

-- Garrosh Malicious Blast.
local mb_debuff_new = 0

local function onUpdate_mb(self,elapsed)
  -- save old value
  local mb_debuff_old = mb_debuff_new
  -- get new value
  _, _, _, _, _, _, mb_debuff_new = UnitDebuff("player", "Malicious Blast")
  if mb_debuff_new == nil then mb_debuff_new = 0 end
  -- compare old value with new value
  if mb_debuff_new > mb_debuff_old + 0.5 then -- player just gained "Malicious Blast" debuff, or it was refreshed
    PlaySoundFile("Sound\\Creature\\Mimiron\\UR_Mimiron_TankSlay01.wav","Master")
  end
end

local pc_malice_debuff = CreateFrame("frame")
pc_malice_debuff:SetScript("OnUpdate", onUpdate_mb)