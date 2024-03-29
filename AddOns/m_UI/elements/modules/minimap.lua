local addon, ns = ...
local cfg = ns.cfg
local A = ns.A
if not cfg.modules.minimap.enable then return end
-- Config
local Scale = cfg.modules.minimap.scale				-- Minimap scale
local ClassColorBorder = false	-- Should border around minimap be classcolored? Enabling it disables color settings below
local r, g, b, a = 0, 0, 0, .7	-- Border colors and alhpa. More info: http://www.wowwiki.com/API_Frame_SetBackdropColor
local BGThickness = cfg.modules.minimap.border_size           -- Border thickness in pixels
local zoneTextYOffset = 10		-- Zone text position

-- Shape, location and scale
function GetMinimapShape() return "SQUARE" end
Minimap:ClearAllPoints()
Minimap:SetPoint(cfg.modules.minimap.position[1], cfg.modules.minimap.position[2], cfg.modules.minimap.position[3], cfg.modules.minimap.position[4] / Scale, cfg.modules.minimap.position[5] / Scale)
MinimapCluster:SetScale(Scale)
--Minimap:SetFrameStrata("BACKGROUND")
Minimap:SetFrameLevel(10)

-- Mask texture hint => addon will work with Carbonite
local hint = CreateFrame("Frame")
local total = 0
local SetTextureTrick = function(self, elapsed)
    total = total + elapsed
    if(total > 2) then
        Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
        hint:SetScript("OnUpdate", nil)
    end
end

hint:RegisterEvent("PLAYER_LOGIN")
hint:SetScript("OnEvent", function()
    hint:SetScript("OnUpdate", SetTextureTrick)
end)

-- Background 
local minimap_backdrop = CreateFrame("Frame", nil, Minimap, BackdropTemplateMixin and "BackdropTemplate")
minimap_backdrop:SetAllPoints(true)
minimap_backdrop:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -1, 1)
minimap_backdrop:SetFrameStrata("BACKGROUND")
minimap_backdrop:SetBackdrop(
    {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground", 
        insets = {
            top = -BGThickness,
            left = -BGThickness,
            bottom = -BGThickness,
            right = -BGThickness
        }
    }
)
if(ClassColorBorder==true) then
    local _, class = UnitClass("player")
    local t = RAID_CLASS_COLORS[class]
    minimap_backdrop:SetBackdropColor(t.r, t.g, t.b, a)
else
    minimap_backdrop:SetBackdropColor(r, g, b, a)
end

-- Mousewheel zoom
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(_, zoom)
    if zoom > 0 then
        Minimap_ZoomIn()
    else
        Minimap_ZoomOut()
    end
end)

-- Hiding ugly things
local dummy = function() end
local _G = getfenv(0)

local frames = {
    -- "GameTimeFrame",
    "MinimapBorderTop",
    "MinimapNorthTag",
    "MinimapBorder",
    "MinimapZoneTextButton",
    "MinimapZoomOut",
    "MinimapZoomIn",
    -- "MiniMapVoiceChatFrame",
    "MiniMapWorldMapButton",
    "MiniMapMailBorder",
-- "GarrisonLandingPageMinimapButton",
-- "MiniMapBattlefieldBorder",
-- "FeedbackUIButton",
--	"MinimapBackdrop",
}

for i in pairs(frames) do
    _G[frames[i]]:Hide()
    _G[frames[i]].Show = dummy
end
MinimapCluster:EnableMouse(false)

-- Tracking
MiniMapTrackingBackground:SetAlpha(0)
MiniMapTrackingButton:SetAlpha(0)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("BOTTOMLEFT", Minimap, -5, -7)

-- BG icon
--MiniMapBattlefieldFrame:ClearAllPoints()
--MiniMapBattlefieldFrame:SetPoint("TOP", Minimap, "TOP", 2, 8)

-- LFG icon
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("TOP", Minimap, "TOP", 1, 8)
QueueStatusMinimapButtonBorder:Hide()
-- QueueStatusMinimapButtonBorder:SetFrameStrata("MEDIUM")

-- Garrison Icon
hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(self)
    local button = _G.GarrisonLandingPageMinimapButton
	if button then
		local scale, pos = 0.75, "BOTTOMRIGHT"
		button:ClearAllPoints()
		button:SetPoint(pos, Minimap, pos, 36, -36)
		button:SetScale(scale)

		local box = _G.GarrisonLandingPageTutorialBox
		if box then
			box:SetScale(1/scale)
			box:SetClampedToScreen(true)
		end
	end
end)

-- Instance Difficulty flag
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 2, 2)
MiniMapInstanceDifficulty:SetScale(0.75)
MiniMapInstanceDifficulty:SetFrameStrata("LOW")

-- Guild Instance Difficulty flag
GuildInstanceDifficulty:ClearAllPoints()
GuildInstanceDifficulty:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 2, 2)
GuildInstanceDifficulty:SetScale(0.75)
GuildInstanceDifficulty:SetFrameStrata("LOW")

-- Mail icon
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -6)
MiniMapMailIcon:SetTexture(cfg.media.mail_icon)

-- Invites Icon
GameTimeCalendarInvitesTexture:ClearAllPoints()
GameTimeCalendarInvitesTexture:SetParent("Minimap")
GameTimeCalendarInvitesTexture:SetPoint("TOPRIGHT")

if FeedbackUIButton then
FeedbackUIButton:ClearAllPoints()
FeedbackUIButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 6, -6)
FeedbackUIButton:SetScale(0.8)
end

if StreamingIcon then
StreamingIcon:ClearAllPoints()
StreamingIcon:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 8, 8)
StreamingIcon:SetScale(0.8)
end

-- Creating right click menu
local menuFrame = CreateFrame("Frame", "m_MinimapRightClickMenu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
    {text = "Character",
    func = function() ToggleCharacter("PaperDollFrame") end},
    {text = "Spells",
    func = function() ToggleSpellBook("spell") end},
    {text = "Talents",
    func = function() ToggleTalentFrame() end},
    {text = "Achievements",
    func = function() ToggleAchievementFrame() end},
    {text = "Quests",
    func = function() ToggleFrame(QuestLogFrame) end},
    {text = "Friends",
    func = function() ToggleFriendsFrame(1) end},
    {text = "Guild",
    func = function() ToggleGuildFrame(1) end},
    {text = "PvP",
    func = function()
		--ToggleFrame(PVPUIFrame)
		if PVPUIFrame then
			if UnitLevel("player") >= 10 then
				if PVPUIFrame:IsShown() then
					HideUIPanel(PVPUIFrame)
				else
					ShowUIPanel(PVPUIFrame)
				end
			end
		else
			LoadAddOn("Blizzard_PVPUI")
			ShowUIPanel(PVPUIFrame)
		end
	end},
    {text = "Dungeon Finder",
    func = function() ToggleLFDParentFrame() end},
	{text = "Pets and Mounts",
    func = function() ToggleToyCollection(1) end},
    {text = "Help",
    func = function() ToggleHelpFrame() end},
    {text = "Calendar",
    func = function()
    if(not CalendarFrame) then LoadAddOn("Blizzard_Calendar") end
        Calendar_Toggle()
    end},
    {text = "Dungeon Journal",
	func = function() ToggleEncounterJournal() end},
}

-- Click func
Minimap:SetScript("OnMouseUp", function(_, btn)
    if(btn=="MiddleButton") then
        ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "cursor", 0, 0)
    elseif(btn=="RightButton") then
        EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 1)
	else
		local x, y = GetCursorPosition()
		x = x / Minimap:GetEffectiveScale()
		y = y / Minimap:GetEffectiveScale()
		local cx, cy = Minimap:GetCenter()
		x = x - cx
		y = y - cy
		if ( sqrt(x * x + y * y) < (Minimap:GetWidth() / 2) ) then
			Minimap:PingLocation(x, y)
		end
		Minimap_SetPing(x, y, 1)
	end
end)

-- Clock
if not IsAddOnLoaded("Blizzard_TimeManager") then
	LoadAddOn("Blizzard_TimeManager")
end
local clockFrame, clockTime = TimeManagerClockButton:GetRegions()
clockFrame:Hide()
clockTime:SetFont(cfg.media.font, 12, "THINOUTLINE")
clockTime:SetTextColor(1,1,1)
TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -3)
TimeManagerClockButton:SetScript("OnClick", function(_,btn)
 	if btn == "LeftButton" then
		TimeManager_Toggle()
	end
	if btn == "RightButton" then
		if not CalendarFrame then
			LoadAddOn("Blizzard_Calendar")
		end
		Calendar_Toggle()
	end
end)

-- Zone text
local zoneTextFrame = CreateFrame("Frame", nil, UIParent)
zoneTextFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, zoneTextYOffset)
zoneTextFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, zoneTextYOffset)
zoneTextFrame:SetHeight(19)
zoneTextFrame:SetAlpha(0)
MinimapZoneText:SetParent(zoneTextFrame)
MinimapZoneText:ClearAllPoints()
MinimapZoneText:SetPoint("LEFT", 2, 1)
MinimapZoneText:SetPoint("RIGHT", -2, 1)
MinimapZoneText:SetFont(cfg.media.font, 12, "THINOUTLINE")
Minimap:SetScript("OnEnter", function(self)
	UIFrameFadeIn(zoneTextFrame, 0.3, 0, 1)
end)
Minimap:SetScript("OnLeave", function(self)
	UIFrameFadeOut(zoneTextFrame, 0.3, 1, 0)
end)
