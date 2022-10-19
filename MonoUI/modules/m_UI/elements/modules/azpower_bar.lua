local addon, ns = ...
local cfg = ns.cfg
if not cfg.modules.azpower_bar.enable then return end

-- create and position the main frame
local mAZPower = CreateFrame("Frame", "mAZPower", UIParent)
mAZPower:SetPoint(unpack(cfg.modules.azpower_bar.position))
-- creating indicators
local indMain = mAZPower:CreateTexture(nil, "OVERLAY")
indMain:SetWidth(1)
local ind1 = mAZPower:CreateTexture(nil, "OVERLAY")
ind1:SetWidth(1)
local ind2 = mAZPower:CreateTexture(nil, "OVERLAY")
ind2:SetWidth(1)
-- making font strings
local font = CreateFont("mAZPowerFont")
font:SetFontObject(GameFontHighlightSmall)
font:SetShadowOffset(1, -1)
local tM = mAZPower:CreateFontString(nil, "OVERLAY")
tM:SetPoint("LEFT", indMain, "RIGHT", 10, 0)
tM:SetFontObject("mAZPowerFont")
local tTR = mAZPower:CreateFontString(nil, "OVERLAY")
tTR:SetPoint("BOTTOMRIGHT", mAZPower, "TOPRIGHT",0,0)
tTR:SetFontObject(font)
local tTL = mAZPower:CreateFontString(nil, "OVERLAY",0,0)
tTL:SetPoint("BOTTOMLEFT", mAZPower, "TOPLEFT")
tTL:SetFontObject(font)
local tBR = mAZPower:CreateFontString(nil, "OVERLAY")
tBR:SetPoint("TOPRIGHT", mAZPower, "BOTTOMRIGHT")
tBR:SetFontObject(font)
local tBL = mAZPower:CreateFontString(nil, "OVERLAY")
tBL:SetPoint("TOPLEFT", mAZPower, "BOTTOMLEFT")
tBL:SetFontObject(font)

-- set indicators' position
function mAZPower:Set(ind, per)
	ind:ClearAllPoints()
	ind:SetPoint("TOPLEFT", cfg.modules.azpower_bar.width*per, 0)
end
-- abbreviate large values
local LargeValue = function(val)
	if (val >= 1e6) then
		return string.format("|cffffffff%.0f|rm", val / 1e6)
	elseif(val > 999 or val < -999) then
		return string.format("|cffffffff%.0f|rk", val / 1e3)
	else
		return "|cffffffff"..val.."|r"
	end
end
-- generate simple gradient pnls

function mAZPower:ShouldBeVisible()
	local isMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel();
	if isMaxLevel then
		return false;
	end
	return C_AzeriteItem.HasActiveAzeriteItem();
end

-- initial bar set up
local function Initialize()
	if not mAZPower:ShouldBeVisible() then return end
	local color = {}
	local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
	if cfg.modules.azpower_bar.class_color then 
		color = classColor 
	else 
		color.r = cfg.modules.azpower_bar.custom_color[1] 
		color.g = cfg.modules.azpower_bar.custom_color[2] 
		color.b = cfg.modules.azpower_bar.custom_color[3] 
	end
	indMain:SetTexture(color.r, color.g, color.b)
	ind1:SetTexture(color.r, color.g, color.b)
	ind2:SetTexture(color.r, color.g, color.b)
	font:SetTextColor(color.r, color.g, color.b)
	mAZPower:ApplyDimensions()
	mAZPower:SetAlpha(1)
	-- making cool gradient borders
	if not eXPRightTR then
		local def_back = "interface\\Tooltips\\UI-Tooltip-Background"
		local def_border = "interface\\Tooltips\\UI-Tooltip-Border"
		local col_max = {.15,.15,.15,0.55}
		local col_bg = {.15,.15,.15,0.9}
		local col_br = {0,0,0,1}
		local no_col = {0,0,0,0}
		local bw = cfg.modules.azpower_bar.width/2
		-- right 'bracket'
		grad_panel ("eXPRightTR",0,-2,bw,2,mAZPower,"TOPRIGHT","TOPRIGHT",mAZPower,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", no_col, col_br)
		grad_panel ("eXPRightR",0,0,2,cfg.modules.azpower_bar.height-4,eXPRightTR,"TOPLEFT","TOPRIGHT",mAZPower,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", col_br, col_br)
		grad_panel ("eXPRightBR",0,0,bw,2,eXPRightR,"BOTTOMRIGHT","BOTTOMLEFT",mAZPower,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", no_col, col_br)
		grad_panel ("eXPRightBG",0,0,bw-bw/4,eXPRightR:GetHeight()-eXPRightR:GetWidth(),eXPRightR,"RIGHT","LEFT",mAZPower,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", no_col, col_max)
		-- left 'bracket'			
		grad_panel ("eXPLeftTL",0,-2,bw,2,mAZPower,"TOPLEFT","TOPLEFT",mAZPower,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", col_br, no_col)
		grad_panel ("eXPLeftL",0,0,2,cfg.modules.azpower_bar.height-4,eXPLeftTL,"TOPRIGHT","TOPLEFT",mAZPower,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", col_br, col_br)
		grad_panel ("eXPLeftBL",0,0,bw,2,eXPLeftL,"BOTTOMLEFT","BOTTOMRIGHT",mAZPower,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", col_br, no_col)
		grad_panel ("eXPLeftBG",0,0,bw-bw/4,eXPLeftL:GetHeight()-eXPLeftL:GetWidth(),eXPLeftL,"LEFT","RIGHT",mAZPower,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", col_max, no_col)
					
--[[ 		-- pixel overlay
		grad_panel ("eXPRightOTR",1,-2,bw,1,mAZPower,"TOPRIGHT","TOPRIGHT",mAZPower,
					def_back,def_border,"BACKGROUND",{1,1,1,1},no_col, "HORIZONTAL", no_col, {1,1,1,1})
		grad_panel ("eXPRightOR",0,0,1,cfg.modules.azpower_bar.height-4,eXPRightOTR,"TOPLEFT","TOPRIGHT",mAZPower,
					def_back,def_border,"BACKGROUND",{1,1,1,1},no_col, "HORIZONTAL", {1,1,1,1}, {1,1,1,1})
		grad_panel ("eXPRightOBR",0,0,bw,1,eXPRightOR,"BOTTOMRIGHT","BOTTOMLEFT",mAZPower,
					def_back,def_border,"BACKGROUND",{1,1,1,1},no_col, "HORIZONTAL", no_col, {1,1,1,1})
		
		grad_panel ("eXPLeftOTL",-1,-2,bw,1,mAZPower,"TOPLEFT","TOPLEFT",mAZPower,
					def_back,def_border,"BACKGROUND",{1,1,1,1},no_col, "HORIZONTAL", {1,1,1,1}, no_col)
		grad_panel ("eXPLeftOL",0,0,1,cfg.modules.azpower_bar.height-4,eXPLeftOTL,"TOPRIGHT","TOPLEFT",mAZPower,
					def_back,def_border,"BACKGROUND",{1,1,1,1},no_col, "HORIZONTAL", {1,1,1,1}, {1,1,1,1})
		grad_panel ("eXPLeftOBL",0,0,bw,1,eXPLeftOL,"BOTTOMLEFT","BOTTOMRIGHT",mAZPower,
					def_back,def_border,"BACKGROUND",{1,1,1,1},no_col, "HORIZONTAL", {1,1,1,1}, no_col) ]]

	end
end
function mAZPower:ApplyDimensions()
	mAZPower:SetWidth(cfg.modules.azpower_bar.width)
	mAZPower:SetHeight(cfg.modules.azpower_bar.height)
	indMain:SetHeight(cfg.modules.azpower_bar.height)
	ind1:SetHeight(cfg.modules.azpower_bar.height/3)
	ind2:SetHeight(cfg.modules.azpower_bar.height/3)
end
function mAZPower:UpdateText()
	tTL:SetText(restXP)
	tTR:SetText(XPtolvl)
	tBL:SetText(XPbars)
	tBR:SetText(XPgain)
end
-- setting up OnEvent script
local lastXP
mAZPower:SetScript("OnEvent", function(self, event, ...)
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();

	if (not azeriteItemLocation) then
		return;
	end

	local min, max = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
	local rest = 0
	local powerToNextLevel = max - min;

	if event == "PLAYER_ENTERING_WORLD" then
		-- adjust exp bar width depends on screen resolution
		local swidth = UIParent:GetWidth()
		if swidth < 1500 and cfg.modules.azpower_bar.auto_adjust then
			cfg.modules.azpower_bar.width = swidth-860
		end
		Initialize()
		mAZPower:ApplyDimensions()
	end
	if event == "AZERITE_ITEM_EXPERIENCE_CHANGED" or event == "PLAYER_ENTERING_WORLD" or event == "CVAR_UPDATE" or event == "BAG_UPDATE" then
		mAZPower:Set(indMain, min/max)
		if(rest and rest > 0 and (min+rest) <= max) then
			ind1:Show()
			mAZPower:Set(ind1, (min+rest)/max)
		else
			ind1:Hide()
		end
		restXP = (rest and rest > 0 and format("|cffffffff%.0f|r%% rest", rest/max*100)) or ""
		
		tM:SetFormattedText("|cffffffff%.1f|r%%", min/max*100)
		XPtolvl = LargeValue(min-max)
		XPbars = format("|cffffffff%.1f|rbars", min/max*20-20)
		if(lastXP and lastXP ~= min) then
			ind2:Show()
			mAZPower:Set(ind2, lastXP/max)
			XPgain = format("|cffffffff%.0f|rx", (max-min)/(min-lastXP))
		else
			ind2:Hide()
			XPgain = ""
		end
		lastXP = min
		mAZPower:UpdateText()
	end
	if not mAZPower:ShouldBeVisible() then
		mAZPower:Hide()
	else
		mAZPower:Show()
	end
	if event and IsInRaid() then
		mAZPower:Hide()
	elseif mAZPower:ShouldBeVisible() then
		mAZPower:Show()
	end
end)
mAZPower:RegisterEvent("PLAYER_ENTERING_WORLD")
mAZPower:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
mAZPower:RegisterEvent("CVAR_UPDATE")
mAZPower:RegisterEvent("BAG_UPDATE")