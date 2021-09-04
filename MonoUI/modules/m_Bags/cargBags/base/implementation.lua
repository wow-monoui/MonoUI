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
]]
local addon, ns = ...
local cargBags = ns.cargBags

--[[!
    @class Implementation
        The Implementation-class serves as the basis for your cargBags-instance, handling
        item-data-fetching and dispatching events for containers and items.
]]
local Implementation = cargBags:NewClass("Implementation", nil, "Button")
Implementation.instances = {}
Implementation.itemKeys = {}

local toBagSlot = cargBags.ToBagSlot

--[[!
    Creates a new instance of the class
    @param name <string>
    @return impl <Implementation>
]]
function Implementation:New(name)
    if ( self.instances[name] ) then
        return error(("cargBags: Implementation '%s' already exists!"):format(name))
    end

    if ( _G[name] ) then
        return error(("cargBags: Global '%s' for Implementation is already used!"):format(name))
    end

    local impl = setmetatable(CreateFrame("Button", name, UIParent), self.__index)
    impl.name = name

    impl:SetAllPoints()
    impl:EnableMouse(nil)
    impl:Hide()

    cargBags.SetScriptHandlers(impl, "OnEvent", "OnShow", "OnHide")

    impl.contByID = {} --! @property contByID <table> Holds all child-Containers by index
    impl.contByName = {} --!@ property contByName <table> Holds all child-Containers by name
    impl.buttons = {} -- @property buttons <table> Holds all ItemButtons by bagSlot
    impl.events = {} -- @property events <table> Holds all event callbacks
    impl.notInited = true -- @property notInited <bool>

    tinsert(UISpecialFrames, name)

    self.instances[name] = impl

    return impl
end

--[[!
    Script handler, inits and updates the Implementation when shown
    @callback OnOpen
]]
function Implementation:OnShow()
    if ( self.notInited ) then
        if ( not InCombatLockdown() ) then
            self:Init()
        else
            return
        end
    end

    PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
    if ( self.OnOpen ) then self:OnOpen() end
    self:OnEvent("BAG_UPDATE")
end

--[[!
    Script handler, closes the Implementation when hidden
    @callback OnClose
]]
function Implementation:OnHide()
    if ( self.notInited ) then
        return
    end

    PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
    if ( self.OnClose ) then self:OnClose() end
    if ( self:AtBank() ) then CloseBankFrame() end
end

--[[!
    Toggles the implementation
    @param forceopen <bool> Only open it
]]
function Implementation:Toggle(forceopen)
    if ( not forceopen and self:IsShown() ) then
        self:Hide()
    else
        self:Show()
    end
end

--[[!
    Fetches an implementation by name
    @param name <string>
    @return impl <Implementation>
]]
function Implementation:Get(name)
    return self.instances[name]
end

--[[!
    Fetches a child-Container by name
    @param name <string>
    @return container <Container>
]]
function Implementation:GetContainer(name)
    return self.contByName[name]
end

--[[!
    Fetches a implementation-owned class by relative name

    The relative class names are prefixed by the name of the implementation
    e.g. :GetClass("Button") -> ImplementationButton
    It is just to prevent people from overwriting each others classes

    @param name <string> The relative class name
    @param create <bool> Creates it, if it doesn't exist
    @param ... Arguments to pass to cargBags:NewClass(name, ...) when creating
    @return class <table> The class prototype
]]
function Implementation:GetClass(name, create, ...)
    if ( not name ) then
        return
    end

    name = self.name..name
    local class = cargBags.classes[name]

    if ( class or not create ) then
        return class
    end

    class = cargBags:NewClass(name, ...)
    class.implementation = self
    return class
end

--[[!
    Wrapper for :GetClass() using a Container
    @note Container-classes have the full name "ImplementationNameContainer"
    @param name <string> The relative container class name
    @return class <table> The class prototype
]]
function Implementation:GetContainerClass(name)
    return self:GetClass((name or "").."Container", true, "Container")
end

--[[!
    Wrapper for :GetClass() using an ItemButton
    @note ItemButton-Classes have the full name "ImplementationNameItemButton"
    @param name <string> The relative itembutton class name
    @return class <table> The class prototype
]]
function Implementation:GetItemButtonClass(name)
    return self:GetClass((name or "").."ItemButton", true, "ItemButton")
end

--[[!
    Sets the ItemButton class to use for spawning new buttons
    @param name <string> The relative itembutton class name
    @return class <table> The newly set class
]]
function Implementation:SetDefaultItemButtonClass(name)
    self.buttonClass = self:GetItemButtonClass(name)
    return self.buttonClass
end

--[[!
    Registers the implementation to overwrite Blizzards Bag-Toggle-Functions
    @note This function only works before PLAYER_LOGIN and can be overwritten by other Implementations
]]
function Implementation:RegisterBlizzard()
    cargBags:RegisterBlizzard(self)
end

local _registerEvent = UIParent.RegisterEvent
local _isEventRegistered = UIParent.IsEventRegistered

--[[!
    Registers an event callback - these are only called if the Implementation is currently shown
    The events do not have to be 'blizz events' - they can also be internal messages
    @param event <string> The event to register for
    @param key Something passed to the callback as arg #1, also serves as identification
    @param func <function> The function to call on the event
]]
function Implementation:RegisterEvent(event, key, func)
    local events = self.events

    if ( not events[event] ) then
        events[event] = {}
    end

    events[event][key] = func
    if ( event:upper() == event and not _isEventRegistered(self, event) ) then
        _registerEvent(self, event)
    end
end

--[[!
    Returns whether the Implementation has the specified event callback
    @param event <string> The event of the callback
    @param key The identification of the callback [optional]
]]
function Implementation:IsEventRegistered(event, key)
    return self.events[event] and (not key or self.events[event][key])
end

--[[!
    Script handler, dispatches the events
]]
function Implementation:OnEvent(event, ...)
    if ( not (self.events[event] and self:IsShown()) ) then return end

    for key, func in pairs(self.events[event]) do
        func(key, event, ...)
    end
end

--[[!
    Inits the implementation by registering events
    @callback OnInit
]]
function Implementation:Init()
    if ( not self.notInited ) then return end

     -- initialization of bags in combat taints the itembuttons within - Lars Norberg
    if ( InCombatLockdown() ) then
        local L = LibStub("gLocale-1.0"):GetLocale(addon, true)
        if ( L ) then
            UIErrorsFrame:AddMessage(L["Can't initialize bags while engaged in combat."], 1.0, 0.82, 0.0, 1.0)
            UIErrorsFrame:AddMessage(L["Please exit combat then re-open the bags!"], 1.0, 0.82, 0.0, 1.0)
        end

        return
    end

    self.notInited = nil

    if ( self.OnInit ) then self:OnInit() end

    if ( not self.buttonClass ) then
        self:SetDefaultItemButtonClass()
    end

    self:RegisterEvent("BAG_UPDATE", self, self.BAG_UPDATE)
    self:RegisterEvent("BAG_UPDATE_COOLDOWN", self, self.BAG_UPDATE_COOLDOWN)
    self:RegisterEvent("ITEM_LOCK_CHANGED", self, self.ITEM_LOCK_CHANGED)
    self:RegisterEvent("PLAYERBANKSLOTS_CHANGED", self, self.PLAYERBANKSLOTS_CHANGED)
    self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED", self, self.PLAYERREAGENTBANKSLOTS_CHANGED)
    self:RegisterEvent("UNIT_QUEST_LOG_CHANGED", self, self.UNIT_QUEST_LOG_CHANGED)
    self:RegisterEvent("QUEST_ACCEPTED", self, self.QUEST_ACCEPTED)
    self:RegisterEvent("INVENTORY_SEARCH_UPDATE", self, self.INVENTORY_SEARCH_UPDATE)
end

--[[!
    Returns whether the user is currently at the bank
    @return atBank <bool>
]]
function Implementation:AtBank()
    return cargBags.atBank
end

--[[
    Fetches a button by bagID-slotID-pair
    @param bagID <number>
    @param slotID <number>
    @return button <ItemButton>
]]
function Implementation:GetButton(bagID, slotID)
    return self.buttons[toBagSlot(bagID, slotID)]
end

--[[!
    Stores a button by bagID-slotID-pair
    @param bagID <number>
    @param slotID <number>
    @param button <ItemButton> [optional]
]]
function Implementation:SetButton(bagID, slotID, button)
    self.buttons[toBagSlot(bagID, slotID)] = button
end

--[[!
Fetches the itemInfo of the item in bagID/slotID into the table.
Uses a fake itemLocation table to avoid memory issues with Blizzards
itemLocation mixin.
@param bagID <number>
@param slotID <number>
@param item <table> [optional]
@return item <table>
]]

local itemLocation = {
        bagID = nil,
        slotIndex = nil,
}

local function SetItemLocation(bagID, slotID)
    itemLocation.bagID = bagID
    itemLocation.slotIndex = slotID
end

local defaultItem = cargBags:NewItemTable()

function Implementation:GetItemInfo(bagID, slotID, item)
    item = item or defaultItem

    for key in pairs(item) do
        item[key] = nil
    end

    item.bagID = bagID
    item.slotID = slotID

    local link = GetContainerItemLink(bagID, slotID)

    if ( not link ) then
        return item
    end

    SetItemLocation(bagID, slotID)

    local _;
    item.link = link
    item.id = GetContainerItemID(bagID, slotID)
    item.level = C_Item.GetCurrentItemLevel(itemLocation)
    item.inventoryType = C_Item.GetItemInventoryType(itemLocation)
    item.texture, item.count, _, item.quality = GetContainerItemInfo(bagID, slotID)
    _, _, _, _, _, _, _, _, _, _, item.sellPrice, item.classID, item.subclassID = GetItemInfo(item.id)
    
    return item
end

--[[!
    Updates the defined slot, creating/removing buttons as necessary
    @param bagID <number>
    @param slotID <number>
]]
function Implementation:UpdateSlot(bagID, slotID)
    local item = self:GetItemInfo(bagID, slotID)
    local button = self:GetButton(bagID, slotID)
    local container = self:GetContainerForItem(item, button)

    if ( container ) then
        if ( button ) then
            if ( container ~= button.container ) then
                button.container:RemoveButton(button)
                container:AddButton(button)
            end
        else
            button = self.buttonClass:New(bagID, slotID)
            self:SetButton(bagID, slotID, button)
            container:AddButton(button)
        end

        button:Update(item)
    elseif ( button ) then
        button.container:RemoveButton(button)
        self:SetButton(bagID, slotID, nil)
        button:Free()
    end
end

--[[!
    Updates a bag and its containing slots
    @param bagID <number>
]]
function Implementation:UpdateBag(bagID)
    if ( not self:IsShown() ) then
        return
    end

    for slotID = 1, GetContainerNumSlots(bagID) do
        self:UpdateSlot(bagID, slotID)
        C_NewItems.RemoveNewItem(bagID, slotID)
    end
end

--[[!
    Updates a set of items
    @param bagID <number> [optional]
    @param slotID <number> [optional]
    @callback Container:OnBagUpdate(bagID, slotID)
]]
function Implementation:BAG_UPDATE(event, bagID, slotID)
    if ( bagID and slotID ) then
        self:UpdateSlot(bagID, slotID)
    elseif ( bagID ) then
        self:UpdateBag(bagID)
    else
        if ( self:AtBank() ) then
            for bagID = -1, 11 do
                self:UpdateBag(bagID)
            end
        else
            for bagID = 0, NUM_BAG_FRAMES do
                self:UpdateBag(bagID)
            end
        end
    end
end

--[[!
    Fired when the item cooldowns need to be updated
    @param bagID <number> [optional]
]]
function Implementation:BAG_UPDATE_COOLDOWN(event, bagID)
    if ( bagID ) then
        for slotID=1, GetContainerNumSlots(bagID) do
            local button = self:GetButton(bagID, slotID)
            if ( button ) then
                button:UpdateCooldown(bagID, slotID)
            end
        end
    else
        for id, container in pairs(self.contByID) do
            for i, button in pairs(container.buttons) do
                button:UpdateCooldown(button.bagID, button.slotID)
            end
        end
    end
end

--[[!
    Fired when the item is picked up or released
    @param bagID <number>
    @param slotID <number> [optional]
]]
function Implementation:ITEM_LOCK_CHANGED(event, bagID, slotID)
    if ( not slotID ) then return end

    local button = self:GetButton(bagID, slotID)
    if ( button ) then
        button:UpdateLock(bagID, slotID)
    end
end

--[[!
    Fired when bank bags or slots need to be updated
    @param slotID <number>
]]
function Implementation:PLAYERBANKSLOTS_CHANGED(event, slotID)
    local bagID = BANK_CONTAINER

    if ( slotID > NUM_BANKGENERIC_SLOTS ) then
        bagID = slotID - NUM_BANKGENERIC_SLOTS
    end

    self:BAG_UPDATE(event, bagID)
end

--[[!
    Fired when reagent bank slots need to be updated
    @param bagID <number>
    @param slotID <number> [optional]
]]
function Implementation:PLAYERREAGENTBANKSLOTS_CHANGED(event, slotID)
    self:BAG_UPDATE(event, REAGENTBANK_CONTAINER, slotID)
end

--[[
    Fired when the quest log of a unit changes
]]
function Implementation:UNIT_QUEST_LOG_CHANGED(event, unit)
    if ( self:IsShown() or unit ~= "player" ) then
        return
    end

    for id, container in pairs(self.contByID) do
        for i, button in pairs(container.buttons) do
            button:UpdateQuest(button.bagID, button.slotID)
        end
    end
end

--[[
    Fired when the player accepts a quest.
]]
function Implementation:QUEST_ACCEPTED(event)
    self:UNIT_QUEST_LOG_CHANGED(event, "player")
end

--[[
    Fired when item search changes
]]
function Implementation:INVENTORY_SEARCH_UPDATE(event)
    local _, isFiltered

    for id, container in pairs(self.contByID) do
        for i, button in pairs(container.buttons) do
            _, _, _, _, _, _, _, isFiltered = GetContainerItemInfo(button.bagID, button.slotID)
            button:SetMatchesSearch(not isFiltered)
        end
    end
end
