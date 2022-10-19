local addon, ns = ...
local cfg = ns.cfg

-- Proper Ready Check sound
local ShowReadyCheckHook = function(self, initiator, timeLeft)
	if initiator ~= "player" then PlaySound(SOUNDKIT.READY_CHECK) end
end
hooksecurefunc("ShowReadyCheck", ShowReadyCheckHook)

-- setting important CVars
SetCVar("screenshotQuality", cfg.script.screenshot_quality)
SetCVar("profanityFilter",0)
SetCVar("showTutorials", 0)

-- Auto decline duels
if cfg.automation.decline_duel then
    local dd = CreateFrame("Frame")
    dd:RegisterEvent("DUEL_REQUESTED")
    dd:SetScript("OnEvent", function(self, event, name)
		HideUIPanel(StaticPopup1)
		CancelDuel()
		print(format("You have declined |cffFFC354"..name.."'s duel."))
    end)
end

-- Fix SearchLFGLeave() taint
local TaintFix = CreateFrame("Frame")
TaintFix:SetScript("OnUpdate", function(self, elapsed)
	if LFRBrowseFrame.timeToClear then
		LFRBrowseFrame.timeToClear = nil
	end
end)

-- blizzard glyph bug -> http://us.battle.net/wow/en/forum/topic/6470967787
local Load = CreateFrame("Frame")
Load:RegisterEvent("PLAYER_ENTERING_WORLD")
Load:SetScript("OnEvent", function(self, event)
	LoadAddOn("Blizzard_TalentUI")
	LoadAddOn("Blizzard_GlyphUI")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

-- Fix an issue where the GlyphUI depends on the TalentUI but doesn't always load it.
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
local function OnEvent(self, event, name)
	if event == "ADDON_LOADED" and name == "Blizzard_GlyphUI" then
		TalentFrame_LoadUI()
	end
end
f:SetScript("OnEvent",OnEvent)

--[[ local f = CreateFrame"Frame"
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("VARIABLES_LOADED")
f:SetScript("OnEvent", function(self, event)
	SetCVar("profanityFilter",0)
	--SetCVar("showAllEnemyDebuffs",1)
end) ]]

--[[ if alDamageMeterFrame then
	alDamageMeterFrame:ClearAllPoints()
	alDamageMeterFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -169, 33)
end ]]


----------------------------------------------------------------------------------------
--	Misclicks for some popups
----------------------------------------------------------------------------------------
StaticPopupDialogs.RESURRECT.hideOnEscape = nil
StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
-- StaticPopupDialogs.PARTY_INVITE_XREALM.hideOnEscape = nil
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil
PetBattleQueueReadyFrame.hideOnEscape = nil
PVPReadyDialog.leaveButton:Hide()
PVPReadyDialog.enterButton:ClearAllPoints()
PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)

----------------------------------------------------------------------------------------
--	Auto select current event boss from LFD tool(EventBossAutoSelect by Nathanyel)
----------------------------------------------------------------------------------------
local firstLFD
LFDParentFrame:HookScript("OnShow", function()
	if not firstLFD then
		firstLFD = 1
		for i = 1, GetNumRandomDungeons() do
			local id = GetLFGRandomDungeonInfo(i)
			local isHoliday = select(15, GetLFGDungeonInfo(id))
			if isHoliday and not GetLFGDungeonRewards(id) then
				LFDQueueFrame_SetType(id)
			end
		end
	end
end)

----------------------------------------------------------------------------------------
-- Learn all available skills(TrainAll by SDPhantom)
----------------------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_TrainerUI" then
		local button = CreateFrame("Button", "ClassTrainerTrainAllButton", ClassTrainerFrame, "UIPanelButtonTemplate")
		button:SetText(QUICKBUTTON_NAME_EVERYTHING)
		button:SetPoint("TOPRIGHT", ClassTrainerTrainButton, "TOPLEFT", 0, 0)
		button:SetWidth(min(50, button:GetTextWidth() + 15))
		button:SetScript("OnClick", function()
			for i = 1, GetNumTrainerServices() do
				if select(3, GetTrainerServiceInfo(i)) == "available" then
					BuyTrainerService(i)
				end
			end
		end)
		hooksecurefunc("ClassTrainerFrame_Update", function()
			for i = 1, GetNumTrainerServices() do
				if ClassTrainerTrainButton:IsEnabled() and select(3, GetTrainerServiceInfo(i)) == "available" then
					button:Enable()
					return
				end
			end
			button:Disable()
		end)
	end
end)
