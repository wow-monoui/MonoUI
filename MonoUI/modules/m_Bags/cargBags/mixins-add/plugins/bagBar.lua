--[[
    cargBags: An inventory framework addon for World of Warcraft

    Copyright (C) 2010  Constantin "Cargor" Schomburg <xconstruct@gmail.com>

    cargBags is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    cargBags is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with cargBags; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

DESCRIPTION
    A collection of buttons for the bags.

    The buttons are not positioned automatically, use the standard-
    function :LayoutButtons() for this

DEPENDENCIES
    mixins/api-common
    mixins/parseBags (optional)
    base-add/filters.sieve.lua (optional)

CALLBACKS
    BagButton:OnCreate(bagID)
]]

local addon, ns = ...
local cargBags = ns.cargBags
local Implementation = cargBags.classes.Implementation

function Implementation:GetBagButtonClass()
    return self:GetClass("BagButton", true, "BagButton")
end

local BagButton = cargBags:NewClass("BagButton", nil, "CheckButton")

-- Default attributes
BagButton.checkedTex = [[Interface\AddOns\cargBags_Neav\media\BagHighlight]]
BagButton.bgTex = [[Interface\AddOns\cargBags_Neav\media\BagSlot]]
BagButton.itemFadeAlpha = 0.2

local buttonNum = 0
local bankBagSlotIDs = {
    [5] = 1,
    [6] = 2,
    [7] = 3,
    [8] = 4,
    [9] = 5,
    [10] = 6,
    [11] = 7,
}

function BagButton:Create(bagID)
    buttonNum = buttonNum+1
    local name = addon.."BagButton"..buttonNum

    local button = setmetatable(CreateFrame("ItemButton", name, nil), self.__index)

    local invID = ContainerIDToInventoryID(bagID)
    button.invID = invID
    button.bagID = bagID
    button.isBag = 1

    if ( button.bagID <= 4 ) then
        -- Inventory
        button:SetID(invID)
        button.UpdateTooltip = BagSlotButton_OnEnter
    elseif ( button.bagID >= 5 ) then
        -- Bank
        invID = BankButtonIDToInvSlotID(button.bagID, button.isBag)
        -- button:SetID(invID - 67) -- bank IDs don't use the actual invID
        button:SetID(bankBagSlotIDs[bagID])
        button.GetInventorySlot = ButtonInventorySlot
        button.UpdateTooltip = BankFrameItemButton_OnEnter
    end

    button:RegisterForDrag("LeftButton", "RightButton")
    button:RegisterForClicks("anyUp")
    -- button:SetCheckedTexture(self.checkedTex, "ADD")

    button:SetSize(32, 32)

    button.Icon =       _G[name.."IconTexture"]
    button.Count =      _G[name.."Count"]
    button.Cooldown =   _G[name.."Cooldown"]
    button.Quest =      _G[name.."IconQuestTexture"]
    button.Border =     _G[name.."NormalTexture"]

    button.bg = CreateFrame("Frame", nil, button, "BackdropTemplate")
    button.bg:SetAllPoints(button)
    button.bg:SetBackdrop({
        bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
        edgeFile = [[Interface\Buttons\WHITE8x8]],
        tile = false, tileSize = 16, edgeSize = 1,
    })
    button.bg:SetBackdropColor(1, 1, 1, 0)
    button.bg:SetBackdropBorderColor(0, 0, 0, 1)

    button.Icon:SetTexCoord(.08, .92, .08, .92)
    button.Icon:SetVertexColor(0.8, 0.8, 0.8)
    button.Border:SetAlpha(0)

    cargBags.SetScriptHandlers(button, "OnClick", "OnReceiveDrag", "OnEnter", "OnLeave", "OnDragStart")

    if ( button.OnCreate ) then button:OnCreate(bagID) end

    return button
end

function BagButton:Update()
    local icon = GetInventoryItemTexture("player", self.invID)
    self.Icon:SetTexture(icon or self.bgTex)
    self.Icon:SetDesaturated(IsInventoryItemLocked(self.invID))

    if ( self.bagID > NUM_BAG_SLOTS ) then
        if ( self.bagID-NUM_BAG_SLOTS <= GetNumBankSlots() ) then
            self.Icon:SetVertexColor(1, 1, 1)
            self.tooltipText = BANK_BAG
            self.notBought = false
        else
            self.Icon:SetVertexColor(1, 0, 0)
            self.tooltipText = BANK_BAG_PURCHASE
            self.notBought = true
        end
    end

    -- self:SetChecked(not self.hidden and not self.notBought)

    if ( self.OnUpdate ) then self:OnUpdate() end
end

local function highlight(button, func, bagID)
    func(button, not bagID or button.bagID == bagID)
end

function BagButton:OnEnter()
    local hlFunction = self.bar.highlightFunction

    if ( hlFunction ) then
        if ( self.bar.isGlobal ) then
            for i, container in pairs(self.implementation.contByID) do
                container:ApplyToButtons(highlight, hlFunction, self.bagID)
            end
        else
            self.bar.container:ApplyToButtons(highlight, hlFunction, self.bagID)
        end
    end

    -- self:UpdateTooltip()
end

function BagButton:OnLeave()
    local hlFunction = self.bar.highlightFunction

    if ( hlFunction ) then
        if ( self.bar.isGlobal ) then
            for i, container in pairs(self.implementation.contByID) do
                container:ApplyToButtons(highlight, hlFunction)
            end
        else
            self.bar.container:ApplyToButtons(highlight, hlFunction)
        end
    end

    GameTooltip:Hide()
end

function BagButton:OnClick()
    if ( self.notBought ) then
        self:SetChecked(nil)
        BankFrame.nextSlotCost = GetBankSlotCost(GetNumBankSlots())
        return StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
    end

    if ( PutItemInBag(self.invID) ) then return end

    -- Somehow we need to disconnect this from the filter-sieve
    local container = self.bar.container
    if ( container and container.SetFilter ) then
        if ( not self.filter ) then
            local bagID = self.bagID
            self.filter = function(i) return i.bagID ~= bagID end
        end
        self.hidden = not self.hidden

        if ( self.bar.isGlobal ) then
            for i, container in pairs(container.implementation.contByID) do
                container:SetFilter(self.filter, self.hidden)
                container.implementation:OnEvent("BAG_UPDATE", self.bagID)
            end
        else
            container:SetFilter(self.filter, self.hidden)
            container.implementation:OnEvent("BAG_UPDATE", self.bagID)
        end
    end
end
BagButton.OnReceiveDrag = BagButton.OnClick

function BagButton:OnDragStart()
    PickupBagFromSlot(self.invID)
end

-- Updating the icons
local function UpdateButtons(self, event)
    for i = 1, #self.buttons do
        local button = self.buttons[i]
        button:Update()
    end
end

local function UpdateButtonLock(self, event, bagID, slotID)
    if ( bagID == -1 and slotID > NUM_BANKGENERIC_SLOTS ) then
        bagID, slotID = ContainerIDToInventoryID(slotID-NUM_BANKGENERIC_SLOTS+NUM_BAG_SLOTS)
    end

    if ( slotID ) then return end

    for i, button in ipairs(self.buttons) do
        if ( button.invID == bagID ) then
            return button:Update()
        end
    end
end

local disabled = {
    [-2] = true,
    [-1] = true,
    [0] = true,
}

-- Register the plugin
cargBags:RegisterPlugin("BagBar", function(self, bags)
    if ( cargBags.ParseBags ) then
        bags = cargBags:ParseBags(bags)
    end

    local buttonClass = self.implementation:GetBagButtonClass()
    local bar = CreateFrame("Frame",  nil, self)

    bar.buttons = {}
    bar.container = self
    bar.layouts = cargBags.classes.Container.layouts
    bar.LayoutButtons = cargBags.classes.Container.LayoutButtons

    for i=1, #bags do
        if ( not disabled[bags[i]] ) then
            local button = buttonClass:Create(bags[i])
            button:SetParent(bar)
            button.bar = bar
            table.insert(bar.buttons, button)
        end
    end

    self.implementation:RegisterEvent("BAG_UPDATE", bar, UpdateButtons)
    self.implementation:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED", bar, UpdateButtons)
    self.implementation:RegisterEvent("ITEM_LOCK_CHANGED", bar, UpdateButtonLock)

    return bar
end)
