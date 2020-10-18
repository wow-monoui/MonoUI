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
    Item keys for the Blizz equipment sets

DEPENDENCIES
    mixins-add/itemkeys/basic.lua
]]
local parent, ns = ...
local cargBags = ns.cargBags

local ItemKeys = cargBags.itemKeys

local setItems

local function UpdateSets()
    setItems = setItems or {}
    for key in pairs(setItems) do
        setItems[key] = nil
    end

    local setIDs = C_EquipmentSet.GetEquipmentSetIDs()

    for i=1, #setIDs do
        local setID = setIDs[i]
        local items = C_EquipmentSet.GetItemIDs(setID)

        for slot, id in pairs(items) do
            setItems[id] = setID
        end
    end
end

local function InitUpdater()
    local updater = CreateFrame("Frame")
    updater:RegisterEvent("EQUIPMENT_SETS_CHANGED")
    updater:RegisterEvent("PLAYER_ALIVE")
    updater:SetScript("OnEvent", function()
        UpdateSets()
        cargBags:FireEvent("BAG_UPDATE")
    end)

    UpdateSets()
end

ItemKeys["setID"] = function(item)
    if ( not setItems ) then
        InitUpdater()
    end

    return setItems[item.id]
end

ItemKeys["set"] = function(item)
    return item.setID and C_EquipmentSet.GetEquipmentSetInfo(item.setID)
end

