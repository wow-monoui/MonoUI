local _, m_ActionBars = ...
m_ActionBars = LibStub("AceAddon-3.0"):NewAddon(m_ActionBars, "m_ActionBars", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
_G.m_ActionBars = m_ActionBars

local cfg = m_ActionBars.cfg
local mAB = m_ActionBars.mAB

local _G = _G
local type, pairs, hooksecurefunc, format = type, pairs, hooksecurefunc, format

-- GLOBALS: LibStub, UIParent, PlaySound, SOUNDKIT, RegisterStateDriver, UnregisterStateDriver
-- GLOBALS: BINDING_HEADER_Bartender4, BINDING_CATEGORY_Bartender4, BINDING_NAME_TOGGLEACTIONBARLOCK, BINDING_NAME_BTTOGGLEACTIONBARLOCK
-- GLOBALS: BINDING_HEADER_BT4PET, BINDING_CATEGORY_BT4PET, BINDING_HEADER_BT4STANCE, BINDING_CATEGORY_BT4STANCE
-- GLOBALS: CreateFrame, MultiBarBottomLeft, MultiBarBottomRight, MultiBarLeft, MultiBarRight, UIPARENT_MANAGED_FRAME_POSITIONS
-- GLOBALS: MainMenuBar, OverrideActionBar, MainMenuBarArtFrame, MainMenuExpBar, MainMenuBarMaxLevelBar, ReputationWatchBar
-- GLOBALS: StanceBarFrame, PossessBarFrame, PetActionBarFrame, PlayerTalentFrame

local Frames = {
    MainMenuBar, MainMenuBarArtFrame, OverrideActionBar,
    PossessBarFrame, ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight,
    TalentMicroButtonAlert, CollectionsMicroButtonAlert, EJMicroButtonAlert, CharacterMicroButtonAlert
}

function m_ActionBars:table_to_string(tbl,depth)
    if depth and depth >= 3 then
        return '{ ... }'
    end
    local str
    for k,v in pairs(tbl) do
        if type(v) ~= 'userdata' then
            if type(v) == 'table' then
                v = table_to_string(v,(depth and depth+1 or 1))
            elseif type(v) == 'function' then
                v = 'function'
            elseif type(v) == 'string' then
                v = '"'..v..'"'
            end

            if type(k) == 'string' then
                k = '"'..k..'"'
            end

            str = (str and str..'|cff999999,|r ' or '|cff999999{|r ')..'|cffffff99['..tostring(k)..']|r |cff999999=|r |cffffffff'..tostring(v)..'|r'
        end
    end
    return (str or '{ ')..' }'
end

function m_ActionBars:OnInitialize()
    -- if not cfg.enable_action_bars then return end
    if IsAddOnLoaded("Dominos") then return end

    self:HideBlizzard()
    self:Enable()
end

-- Hides Blizzard default action bar elements
function m_ActionBars:HideBlizzard()
    -- Hidden parent frame
    local UIHider = CreateFrame("Frame")
    UIHider:Hide()
    self.UIHider = UIHider

    MultiBarBottomLeft:SetParent(UIHider)
    MultiBarBottomRight:SetParent(UIHider)
    MultiBarLeft:SetParent(UIHider)
    MultiBarRight:SetParent(UIHider)

    -- Hide MultiBar Buttons, but keep the bars alive
    local btn
    local reason = ACTION_BUTTON_SHOW_GRID_REASON_EVENT
    for i = 1, NUM_ACTIONBAR_BUTTONS do
        btn = _G[format("ActionButton%d", i)]
        btn:SetAttribute("showgrid", 1)
        btn:SetAttribute("statehidden", nil)
        ActionButton_ShowGrid(btn, reason)

        btn = _G[format("MultiBarRightButton%d", i)]
        btn:SetAttribute("showgrid", 1)
        btn:SetAttribute("statehidden", nil)
        ActionButton_ShowGrid(btn, reason)

        btn = _G[format("MultiBarBottomRightButton%d", i)]
        btn:SetAttribute("showgrid", 1)
        btn:SetAttribute("statehidden", nil)
        ActionButton_ShowGrid(btn, reason)

        btn = _G[format("MultiBarLeftButton%d", i)]
        btn:SetAttribute("showgrid", 1)
        btn:SetAttribute("statehidden", nil)
        ActionButton_ShowGrid(btn, reason)

        btn = _G[format("MultiBarBottomLeftButton%d", i)]
        btn:SetAttribute("showgrid", 1)
        btn:SetAttribute("statehidden", nil)
        ActionButton_ShowGrid(btn, reason)
    end

    UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
    UIPARENT_MANAGED_FRAME_POSITIONS["StanceBarFrame"] = nil
    UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
    UIPARENT_MANAGED_FRAME_POSITIONS["MultiCastActionBarFrame"] = nil
    UIPARENT_MANAGED_FRAME_POSITIONS["PETACTIONBAR_YPOS"] = nil

    --MainMenuBar:UnregisterAllEvents()
    --MainMenuBar:SetParent(UIHider)
    --MainMenuBar:Hide()
    MainMenuBar:EnableMouse(false)
    MainMenuBar:UnregisterEvent("DISPLAY_SIZE_CHANGED")
    MainMenuBar:UnregisterEvent("UI_SCALE_CHANGED")

    local animations = { MainMenuBar.slideOut:GetAnimations() }
    animations[1]:SetOffset(0, 0)

    if OverrideActionBar then -- classic doesn't have this
        animations = { OverrideActionBar.slideOut:GetAnimations() }
        animations[1]:SetOffset(0, 0)
    end

    MainMenuBarArtFrame.LeftEndCap:Hide()
    MainMenuBarArtFrame.RightEndCap:Hide()
    MainMenuBarArtFrame.PageNumber:Hide()
    MainMenuBarArtFrameBackground:Hide()
    ActionBarUpButton:Hide()
    ActionBarDownButton:Hide()

    if MicroButtonAndBagsBar then -- classic doesn't have this
        MicroButtonAndBagsBar:Hide()
        MicroButtonAndBagsBar:SetParent(UIHider)
    end

    if StatusTrackingBarManager then
        StatusTrackingBarManager:Hide()
        --StatusTrackingBarManager:SetParent(UIHider)
    end

    StanceBarFrame:UnregisterAllEvents()
    StanceBarFrame:Hide()
    StanceBarFrame:SetParent(UIHider)

    --BonusActionBarFrame:UnregisterAllEvents()
    --BonusActionBarFrame:Hide()
    --BonusActionBarFrame:SetParent(UIHider)

    if PossessBarFrame then -- classic doesn't have this
        --PossessBarFrame:UnregisterAllEvents()
        --PossessBarFrame:Hide()
        --PossessBarFrame:SetParent(UIHider)
    end

    if MultiCastActionBarFrame then
        MultiCastActionBarFrame:UnregisterAllEvents()
        MultiCastActionBarFrame:Hide()
        MultiCastActionBarFrame:SetParent(UIHider)
    end

    --PetActionBarFrame:UnregisterAllEvents()
    --PetActionBarFrame:Hide()
    --PetActionBarFrame:SetParent(UIHider)

    if PlayerTalentFrame then
        PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    else
        hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
    end

    if MainMenuBarPerformanceBarFrame then
        MainMenuBarPerformanceBarFrame:Hide()
        MainMenuBarPerformanceBarFrame:SetParent(UIHider)
    end

    if MainMenuExpBar then
        MainMenuExpBar:Hide()
        MainMenuExpBar:SetParent(UIHider)
    end

    if ReputationWatchBar then
        ReputationWatchBar:Hide()
        ReputationWatchBar:SetParent(UIHider)
    end
end

function m_ActionBars:Enable()
    local myclass = select(2, UnitClass("player"))

    -- compatibility
    -- for 1280*XXX, 1360*XXX, 1440*XXX resolutions
    local width, _ = string.match((({ GetScreenResolutions() })[GetCurrentResolution()] or ""), "(%d+).-(%d+)")
    if width == "1280" or width == "1360" or width == "1440" then
        if cfg.bars["Bar6"].position.a == "BOTTOMRIGHT" and cfg.bars["Bar6"].position.x == -26 and cfg.bars["Bar6"].position.y == 260 and cfg.bars["Bar6"].orientation == "HORIZONTAL" then
            cfg.bars["Bar6"].orientation = "VERTICAL"
            cfg.bars["Bar6"].position = { a = "RIGHT", x = -105, y = 0 }
        end
        if cfg.bars["Bar5"].position.a == "BOTTOMRIGHT" and cfg.bars["Bar5"].position.x == -26 and cfg.bars["Bar5"].position.y == 225 and cfg.bars["Bar5"].orientation == "HORIZONTAL" then
            cfg.bars["Bar5"].orientation = "VERTICAL"
            cfg.bars["Bar5"].position = { a = "RIGHT", x = -70, y = 0 }
        end
        if cfg.bars["Bar4"].position.a == "BOTTOMRIGHT" and cfg.bars["Bar4"].position.x == -26 and cfg.bars["Bar4"].position.y == 190 and cfg.bars["Bar4"].orientation == "HORIZONTAL" then
            cfg.bars["Bar4"].orientation = "VERTICAL"
            cfg.bars["Bar4"].position = { a = "RIGHT", x = -35, y = 0 }
        end
        if cfg.bars["StanceBar"].position.a == "BOTTOMRIGHT" and cfg.bars["StanceBar"].position.x == -218 and cfg.bars["StanceBar"].position.y == 295 and cfg.bars["StanceBar"].orientation == "HORIZONTAL" then
            cfg.bars["StanceBar"].orientation = "VERTICAL"
            cfg.bars["StanceBar"].position = { a = "BOTTOM", x = -96, y = 115 }
        end
        if cfg.bars["MicroMenu"].position.a == "BOTTOMRIGHT" and cfg.bars["MicroMenu"].position.x == -25 and cfg.bars["MicroMenu"].position.y == 300 then
            cfg.bars["MicroMenu"].position = { a = "BOTTOMRIGHT", x = -150, y = 200 }
        end
    end

    if InCombatLockdown() then return end
    local ab1, ab2, ab3, ab4 = GetActionBarToggles()
    if (not ab1 or not ab2 or not ab3 or not ab4) then
        SetActionBarToggles(1, 1, 1, 1)
        StaticPopupDialogs.SET_AB = {
            text = "m_ActionBars is loaded, enabling 4 additional default action bars. UI reload is required",
            button1 = ACCEPT,
            button2 = CANCEL,
            OnAccept = function() ReloadUI() end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = true,
            preferredIndex = 5,
        }
        StaticPopup_Show("SET_AB")
    end

    -- Modifying default action bars
    -- Creating holder frames for each bar
    local mainbar = mAB.CreateHolder("Bar1_holder", cfg.bars["Bar1"].position)
    local overridebar = mAB.CreateHolder("OverrideBar_holder", cfg.bars["Bar1"].position)
    local bottomleftbar = mAB.CreateHolder("Bar2_holder", cfg.bars["Bar2"].position)
    local bottomrightbar = mAB.CreateHolder("Bar3_holder", cfg.bars["Bar3"].position)
    local leftbar = mAB.CreateHolder("Bar4_holder", cfg.bars["Bar4"].position)
    local rightbar = mAB.CreateHolder("Bar5_holder", cfg.bars["Bar5"].position)
    local extrabar = mAB.CreateHolder("Bar6_holder", cfg.bars["Bar6"].position)
    local stancebar = mAB.CreateHolder("StanceBar_holder", cfg.bars["StanceBar"].position)
    local petbar = mAB.CreateHolder("PetBar_holder", { a = cfg.bars["PetBar"].position.a, x = cfg.bars["PetBar"].position.x * 1.25, y = cfg.bars["PetBar"].position.y * 1.25 })
    --local extrabtn = mAB.CreateHolder("ExtraBtn_holder", cfg.ExtraButton["Position"])

    -- Forging action bars
    -- parenting action buttons to our holders
    MainMenuBarArtFrame:SetParent(mainbar)
    OverrideActionBar:SetParent(overridebar)
    OverrideActionBar:EnableMouse(false)
    OverrideActionBar:SetScript("OnShow", nil)
    MultiBarBottomLeft:SetParent(bottomleftbar)
    MultiBarBottomRight:SetParent(bottomrightbar)
    MultiBarLeft:SetParent(leftbar)
    MultiBarRight:SetParent(rightbar)
    MultiBarRight:EnableMouse(false)
    PetActionBarFrame:SetParent(petbar)
    PossessBarFrame:SetParent(stancebar)
    PossessBarFrame:EnableMouse(false)
    StanceBarFrame:SetParent(stancebar)
    StanceBarFrame:SetPoint("BOTTOMLEFT", stancebar, -12, -3)
    StanceBarFrame.ignoreFramePositionManager = true

    -- set up action bars
    mAB.SetBar(mainbar, "ActionButton", NUM_ACTIONBAR_BUTTONS, "Bar1")
    mAB.SetBar(overridebar, "OverrideActionBarButton", NUM_ACTIONBAR_BUTTONS, "Bar1")
    RegisterStateDriver(overridebar, "visibility", "[petbattle] hide; [overridebar][vehicleui][possessbar,@vehicle,exists] show; hide")
    RegisterStateDriver(OverrideActionBar, "visibility", "[overridebar][vehicleui][possessbar,@vehicle,exists] show; hide")
    mAB.SetBar(bottomleftbar, "MultiBarBottomLeftButton", NUM_ACTIONBAR_BUTTONS, "Bar2")
    mAB.SetBar(bottomrightbar, "MultiBarBottomRightButton", NUM_ACTIONBAR_BUTTONS, "Bar3")
    mAB.SetBar(leftbar, "MultiBarLeftButton", NUM_ACTIONBAR_BUTTONS, "Bar4")
    mAB.SetBar(rightbar, "MultiBarRightButton", NUM_ACTIONBAR_BUTTONS, "Bar5")
    mAB.SetBar(petbar, "PetActionButton", NUM_PET_ACTION_SLOTS, "PetBar")
    petbar:SetScale(cfg.bars["PetBar"].scale or 0.80)
    RegisterStateDriver(petbar, "visibility", "[pet,novehicleui,nobonusbar:5] show; hide")
    mAB.SetStanceBar(stancebar, "StanceButton", NUM_STANCE_SLOTS)
    mAB.SetStanceBar(stancebar, "PossessButton", NUM_POSSESS_SLOTS)
    mAB.SetExtraBar(extrabar, "ExtraBarButton", cfg.bars["Bar6"].orientation, cfg.bars["Bar6"].rows, cfg.bars["Bar6"].buttons, cfg.bars["Bar6"].button_size, cfg.bars["Bar6"].button_spacing)

    -- due to new ActionBarController introduced in WoW 5.0 we have to update the extra bar independently and lock it to page 1
    extrabar:RegisterEvent("PLAYER_LOGIN")
    extrabar:SetScript("OnEvent", function(self, event, ...)
        for id = 1, NUM_ACTIONBAR_BUTTONS do
            local name = "ExtraBarButton" .. id
            self:SetFrameRef(name, _G[name])
        end
        self:Execute(([[
			buttons = table.new()
			for id = 1, %s do
				buttons[id] = self:GetFrameRef("ExtraBarButton"..id)
			end
		]]):format(NUM_ACTIONBAR_BUTTONS))
        self:SetAttribute('_onstate-page', ([[
			if not newstate then return end
			for id = 1, %s do
				buttons[id]:SetAttribute("actionpage", 1)
			end
		]]):format(NUM_ACTIONBAR_BUTTONS))
        RegisterStateDriver(self, "page", 1)
    end)

    -- apply alpha and mouseover functionality
    mAB.SetBarAlpha(mainbar, "ActionButton", NUM_ACTIONBAR_BUTTONS, "Bar1")
    mAB.SetBarAlpha(bottomleftbar, "MultiBarBottomLeftButton", NUM_ACTIONBAR_BUTTONS, "Bar2")
    mAB.SetBarAlpha(bottomrightbar, "MultiBarBottomRightButton", NUM_ACTIONBAR_BUTTONS, "Bar3")
    mAB.SetBarAlpha(leftbar, "MultiBarLeftButton", NUM_ACTIONBAR_BUTTONS, "Bar4")
    mAB.SetBarAlpha(rightbar, "MultiBarRightButton", NUM_ACTIONBAR_BUTTONS, "Bar5")
    mAB.SetBarAlpha(extrabar, "ExtraBarButton", NUM_ACTIONBAR_BUTTONS, "Bar6")
    mAB.SetBarAlpha(stancebar, "StanceButton", NUM_STANCE_SLOTS, "StanceBar")
    mAB.SetBarAlpha(petbar, "PetActionButton", NUM_PET_ACTION_SLOTS, "PetBar")

    -- apply visibility conditions
    mAB.SetVisibility("Bar1", mainbar)
    mAB.SetVisibility("Bar2", bottomleftbar)
    mAB.SetVisibility("Bar3", bottomrightbar)
    mAB.SetVisibility("Bar4", leftbar)
    mAB.SetVisibility("Bar5", rightbar)
    mAB.SetVisibility("Bar6", extrabar)
    mAB.SetVisibility("StanceBar", stancebar)
    mAB.SetVisibility("PetBar", petbar)

    local OverrideTexList = {
        "_BG",
        "EndCapL",
        "EndCapR",
        "_Border",
        "Divider1",
        "Divider2",
        "Divider3",
        "ExitBG",
        "MicroBGL",
        "MicroBGR",
        "_MicroBGMid",
        "ButtonBGL",
        "ButtonBGR",
        "_ButtonBGMid",
        "PitchOverlay",
        "PitchButtonBG",
        "PitchBG",
        "PitchMarker",
        "PitchUpUp",
        "PitchUpDown",
        "PitchUpHighlight",
        "PitchDownUp",
        "PitchDownDown",
        "PitchDownHighlight",
        "LeaveUp",
        "LeaveDown",
        "LeaveHighlight",
        "HealthBarBG",
        "HealthBarOverlay",
        "PowerBarBG",
        "PowerBarOverlay",
    }
    for _, t in pairs(OverrideTexList) do
        OverrideActionBar[t]:SetAlpha(0)
    end

    -- ExtraBar button implementation
    extrabtn = CreateFrame("Frame", "ExtraBtn_holder", UIParent)
    if not cfg.bars["ExtraButton"].disable then
        extrabtn:SetPoint(cfg.bars["ExtraButton"].position.a, cfg.bars["ExtraButton"].position.x, cfg.bars["ExtraButton"].position.y)
        extrabtn:SetSize(160, 80)

        ExtraActionBarFrame:SetParent(extrabtn)
        ExtraActionBarFrame:ClearAllPoints()
        ExtraActionBarFrame:SetPoint("CENTER", extrabtn, "CENTER", 0, 0)

        --ExtraActionButton1.noResize = true
        ExtraActionBarFrame.ignoreFramePositionManager = true
    end

    -- exit vehicle button for the lazy ones
    local ve = CreateFrame("BUTTON", "ExitVehicle_holder", UIParent, "SecureHandlerClickTemplate")
    ve:SetSize(cfg.bars["Bar1"].button_size + 10, cfg.bars["Bar1"].button_size + 10)
    if cfg.bars["ExitVehicleButton"].user_placed then
        ve:SetPoint(cfg.bars["ExitVehicleButton"].position.a, cfg.bars["ExitVehicleButton"].position.x, cfg.bars["ExitVehicleButton"].position.y)
        if cfg.bars["ExitVehicleButton"].button_size then ve:SetSize(cfg.bars["ExitVehicleButton"].button_size + 10, cfg.bars["ExitVehicleButton"].button_size + 10) end
    else
        local btn = 'ActionButton' .. cfg.bars["Bar1"].buttons
        ve:SetPoint("CENTER", btn, "CENTER", cfg.bars["Bar1"].button_spacing / 2, 0)
    end
    ve:RegisterForClicks("AnyUp")
    ve:SetScript("OnClick", function() VehicleExit() end)
    ve:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
    ve:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
    ve:SetHighlightTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
    ve:SetAlpha(0)

    -- adding border so it fits our bars general style
    local veh = CreateFrame("Frame", nil, ve)
    veh:SetAllPoints(ve)
    veh:SetParent(ve)
    veh:SetFrameLevel(31)
    veh:EnableMouse(false)
    local veb = veh:CreateTexture(cfg.mAB.media.textures_normal)
    veb:SetTexture(cfg.mAB.media.textures_normal)
    veb:SetPoint("TOPLEFT", 4, -5)
    veb:SetPoint("BOTTOMRIGHT", -6, 5)
    veb:SetVertexColor(0, 0, 0)
    ve:Hide()
    if not cfg.bars["ExitVehicleButton"].disable then
        ve:Show()
        RegisterStateDriver(ve, "visibility", "[vehicleui] show;hide")
        ve:RegisterEvent("UNIT_ENTERING_VEHICLE")
        ve:RegisterEvent("UNIT_ENTERED_VEHICLE")
        ve:RegisterEvent("UNIT_EXITING_VEHICLE")
        ve:RegisterEvent("UNIT_EXITED_VEHICLE")
        ve:RegisterEvent("VEHICLE_UPDATE");
        ve:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        ve:SetScript("OnEvent", function(self, event, ...)
            local arg1 = ...;
            if (((event == "UNIT_ENTERING_VEHICLE") or (event == "UNIT_ENTERED_VEHICLE")) and arg1 == "player") then
                ve:SetAlpha(1)
                ve:SetScript("OnEnter", function(self)
                    veb:SetVertexColor(unpack(cfg.buttons.colors.highlight))
                end)
                ve:SetScript("OnLeave", function(self) veb:SetVertexColor(unpack(cfg.buttons.colors.normal)) end)
            elseif (((event == "UNIT_EXITING_VEHICLE") or (event == "UNIT_EXITED_VEHICLE")) and arg1 == "player") or (event == "ZONE_CHANGED_NEW_AREA" and not UnitHasVehicleUI("player")) then
                ve:SetAlpha(0)
            end
        end)
    end

    local MicroMenu = mAB.CreateHolder("MicroMenu_holder", { a = cfg.bars["MicroMenu"].position.a, x = cfg.bars["MicroMenu"].position.x * (2 - cfg.bars["MicroMenu"].scale), y = cfg.bars["MicroMenu"].position.y * (2 - cfg.bars["MicroMenu"].scale) })
    MicroMenu:SetSize(305, 40)
    MicroMenu:SetScale(cfg.bars["MicroMenu"].scale)
    local MICRO_BUTTONS = MICRO_BUTTONS
    local MicroButtons = {}
    -- check the MICRO_BUTTONS table
    for _, buttonName in pairs(MICRO_BUTTONS) do
        local button = _G[buttonName]
        if button then
            tinsert(MicroButtons, button)
        end
    end
    local SetMicroButtons = function()
        for _, b in pairs(MicroButtons) do
            b:SetParent(MicroMenu)
        end
        CharacterMicroButton:ClearAllPoints();
        CharacterMicroButton:SetPoint("BOTTOMLEFT", 0, 0)
    end
    SetMicroButtons()

    -- micro menu on mouseover
    if cfg.bars["MicroMenu"].show_on_mouseover then
        local switcher = -1
        local function mmalpha(alpha)
            for _, f in pairs(MicroButtons) do
                f:SetAlpha(alpha)
                switcher = alpha
            end
        end

        MicroMenu:EnableMouse(true)
        MicroMenu:SetScript("OnEnter", function(self) mmalpha(1) end)
        MicroMenu:SetScript("OnLeave", function(self) mmalpha(0) end)
        for _, f in pairs(MicroButtons) do
            f:SetAlpha(0)
            f:HookScript("OnEnter", function(self) mmalpha(1) end)
            f:HookScript("OnLeave", function(self) mmalpha(0) end)
        end
        MicroMenu:SetScript("OnEvent", function(self)
            mmalpha(0)
        end)
        MicroMenu:RegisterEvent("PLAYER_ENTERING_WORLD")
        --fix for the talent button display while micromenu onmouseover
        local function TalentSwitchAlphaFix(self, alpha)
            if switcher ~= alpha then
                switcher = 0
                self:SetAlpha(0)
            end
            SetMicroButtons()
        end

        hooksecurefunc(TalentMicroButton, "SetAlpha", TalentSwitchAlphaFix)
    end
    if cfg.bars["MicroMenu"].hide_bar then MicroMenu:Hide() end
    if cfg.bars["MicroMenu"].lock_to_CharacterFrame then
        MicroMenu:SetParent(PaperDollFrame)
        MicroMenu:SetPoint("BOTTOMLEFT", PaperDollFrame, "TOPLEFT", 65, 2)
    end

    -- fix main bar keybind not working after a talent switch
    hooksecurefunc('TalentFrame_LoadUI', function()
        PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
    end)

    -- hiding extra bars
    local bars_visible = false
    -- making this global function to hook in my broker toggler
    m_ActionBars_Toggle_Extra_Bars = function()
        if InCombatLockdown() then return print("m_ActionBars: You can't toggle bars while in combat!") end
        if bars_visible then
            if cfg.bars["Bar1"].hide_bar then mainbar:Hide() end
            if cfg.bars["Bar2"].hide_bar then bottomleftbar:Hide() end
            if cfg.bars["Bar3"].hide_bar then bottomrightbar:Hide() end
            if cfg.bars["Bar4"].hide_bar then leftbar:Hide() end
            if cfg.bars["Bar5"].hide_bar then rightbar:Hide() end
            if cfg.bars["Bar6"].hide_bar then extrabar:Hide() end
            if cfg.bars["StanceBar"].hide_bar then stancebar:Hide() end
            if cfg.bars["MicroMenu"].hide_bar then MicroMenu:Hide() end
            if WorldMarkerBar_holder and cfg.bars["RaidIconBar"].hide_bar then WorldMarkerBar_holder:Hide() end
            if RaidIconBar_holder and cfg.bars["WorldMarkerBar"].hide_bar then RaidIconBar_holder:Hide() end
            bars_visible = false
        else
            if cfg.bars["Bar1"].hide_bar then mainbar:Show() end
            if cfg.bars["Bar2"].hide_bar then bottomleftbar:Show() end
            if cfg.bars["Bar3"].hide_bar then bottomrightbar:Show() end
            if cfg.bars["Bar4"].hide_bar then leftbar:Show() end
            if cfg.bars["Bar5"].hide_bar then rightbar:Show() end
            if cfg.bars["Bar6"].hide_bar then extrabar:Show() end
            if cfg.bars["StanceBar"].hide_bar then stancebar:Show() end
            if cfg.bars["MicroMenu"].hide_bar then MicroMenu:Show() end
            if WorldMarkerBar_holder and cfg.bars["RaidIconBar"].hide_bar then WorldMarkerBar_holder:Show() end
            if RaidIconBar_holder and cfg.bars["WorldMarkerBar"].hide_bar then RaidIconBar_holder:Show() end
            bars_visible = true
        end
    end

    -- and making slash command to show them
    SlashCmdList["EXTRA"] = function() m_ActionBars_Toggle_Extra_Bars() end
    SLASH_EXTRA1 = "/extra"
    SLASH_EXTRA2 = "/eb"

    -- adding testmode to make bar positioning easier
    local testmodeON
    m_ActionBars_Toggle_Test_Mode = function()
        local def_back = "interface\\Tooltips\\UI-Tooltip-Background"
        local backdrop_tab = {
            bgFile = def_back,
            edgeFile = nil,
            tile = false,
            tileSize = 0,
            edgeSize = 5,
            insets = { left = 0, right = 0, top = 0, bottom = 0, },
        }
        local ShowHolder = function(holder, switch)
            if not _G[holder:GetName() .. "_overlay"] then
                local f = CreateFrame("Frame", holder:GetName() .. "_overlay")
                f:SetAllPoints(holder)
                f:SetBackdrop(backdrop_tab);
                f:SetBackdropColor(.1, .1, .2, .8)
                f:SetFrameStrata("HIGH")
                local name = f:CreateFontString(nil)
                name:SetFont("Fonts\\FRIZQT__.TTF", 8)
                name:SetText(holder:GetName())
                name:SetPoint("BOTTOMLEFT", f, "TOPLEFT")
            end

            if switch then
                _G[holder:GetName() .. "_overlay"]:Show()
            else
                _G[holder:GetName() .. "_overlay"]:Hide()
            end
        end
        if testmodeON then
            testmodeON = false
        else
            testmodeON = true
        end
        local holders = {
            Bar1_holder,
            Bar2_holder,
            Bar3_holder,
            Bar4_holder,
            Bar5_holder,
            StanceBar_holder,
            PetBar_holder,
            MicroMenu_holder,
            RaidIconBar_holder,
            WorldMarkerBar_holder,
            ExitVehicle_holder,
            Bar6_holder,
            ExtraBtn_holder
        }
        for _, f in pairs(holders) do
            ShowHolder(f, testmodeON)
        end
    end
    SlashCmdList["TESTMODE"] = function() m_ActionBars_Toggle_Test_Mode() end
    SLASH_TESTMODE1 = "/mab"
end



