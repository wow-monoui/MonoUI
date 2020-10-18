--[[
LICENSE
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
    Provides a Scaffold that generates a default Blizz" ContainerButton

DEPENDENCIES
    mixins/api-common.lua
]]
local addon, ns = ...
local cargBags = ns.cargBags
local cfg = ns.cfg

local modf = math.modf
local CreateColor = CreateColor
local LE_ITEM_QUALITY_COMMON = Enum.ItemQuality.Common

local gradientColor = {
    [0] = CreateColor(1, 0, 0, 1),
    [1] = CreateColor(1, 1, 0, 1),
    [2] = CreateColor(0, 1, 0, 1)
}

local function ItemColorGradient(perc, colors)
    if ( not colors ) then
        colors = gradientColor
    end

    local num = #colors

    if ( perc >= 1 ) then
        return colors[num]
    elseif ( perc <= 0 ) then
        return colors[0]
    end

    local segment, relperc = modf(perc*num)

    local r1, g1, b1, r2, g2, b2
    r1, g1, b1 = colors[segment]:GetRGB()
    r2, g2, b2 = colors[segment+1]:GetRGB()

    if ( not r2 or not g2 or not b2 ) then
        return colors[0]
    else
        local r = r1 + (r2-r1)*relperc
        local g = g1 + (g2-g1)*relperc
        local b = b1 + (b2-b1)*relperc

        return CreateColor(r, g, b, 1)
    end
end

local function CreateInfoString(button, position)
    local fontString = button:CreateFontString(nil, "ARTWORK")

    if ( position == "TOP" ) then
        fontString:SetJustifyH("LEFT")
        fontString:SetPoint("TOPLEFT", button, "TOPLEFT", 1.5, -1.5)
    else
        fontString:SetJustifyH("RIGHT")
        fontString:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1.5, 1.5)
    end

    fontString:SetFont(unpack(ns.options.fonts.itemCount))

    return fontString
end

local function ItemButton_Scaffold(self)
    self:SetSize(34, 34)

    local name = self:GetName()
    self.Icon = _G[name.."IconTexture"]
    self.Count = _G[name.."Count"]
    self.Cooldown = _G[name.."Cooldown"]
    self.Quest = _G[name.."IconQuestTexture"]
    self.Border = _G[name.."NormalTexture"]
    self.upgradeArrow = _G[name].UpgradeIcon
    self.flashAnim = _G[name].flashAnim
    self.newItemAnim = _G[name].newitemglowAnim

    self.Cooldown:ClearAllPoints()
    self.Cooldown:SetPoint("TOPRIGHT", self.Icon, -3, -3.5)
    self.Cooldown:SetPoint("BOTTOMLEFT", self.Icon, 3, 3)
    self.Cooldown:SetHideCountdownNumbers(false)

    if ( self.upgradeArrow ) then
        self.upgradeArrow:ClearAllPoints()
        self.upgradeArrow:SetSize(15, 15)
        self.upgradeArrow:SetPoint("BOTTOMLEFT", self.Icon, -1, 0)
    end

    if ( self.NewItemTexture ) then
        self.NewItemTexture:ClearAllPoints()
        self.NewItemTexture:SetAllPoints(self.Icon)
    end

    self.TopString = CreateInfoString(self, "TOP")
    self.BottomString = CreateInfoString(self, "BOTTOM")
end

--[[!
    Update the button with new item-information
    @param item <table>, see Implementation:GetItemInfo()
    @callback OnUpdate(item)
]]

local function ItemButton_Update(self, item)
    self:UpdateIcon(item.texture)
    self:UpdateItemCount(item.count)
    self:UpdateItemLevel(item.inventoryType, item.quality, item.level)
    self:UpdateNewItemTexture(item.quality)
    self:UpdateUpgradeArrow(item.inventoryType)
    self:UpdateQuest(item.quality)
    self:UpdateDurability()
    self:UpdateLock()
    self:UpdateCooldown()

    if ( self.OnUpdate ) then self:OnUpdate(item) end
end

local function ItemButton_UpdateIcon(self, texture)
    if ( not self ) then
        return
    end

    local icon = self.Icon

    if ( texture ) then
        icon:SetTexture(texture)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    else
        if ( ns.options.CompressEmpty and self.bgTex ) then
            icon:SetTexture(self.bgTex)
            icon:SetTexCoord(0, 1, 0, 1)
        else
            icon:SetColorTexture(1, 1, 1, 0.1)
            icon:SetTexCoord(0, 1, 0, 1)
        end
    end
end

local function ItemButton_UpdateNewItemTexture(button, quality)
    if ( not self ) then
        return
    end

    local newItemTexture = self.NewItemTexture

    if ( not newItemTexture ) then
        return
    end

    local isNewItem = C_NewItems.IsNewItem(self.bagID, self.slotID)
    local flashAnim = self.flashAnim
    local newItemAnim = self.newItemAnim

    if ( isNewItem ) then
        local isBattlePayItem = IsBattlePayItem(self.bagID, self.slotID)

        if ( isBattlePayItem ) then
            newItemTexture:Hide()
        else
            if ( quality and NEW_ITEM_ATLAS_BY_QUALITY[quality] ) then
                newItemTexture:SetAtlas(NEW_ITEM_ATLAS_BY_QUALITY[quality])
            else
                newItemTexture:SetAtlas("bags-glow-white")
            end
            newItemTexture:Show()
        end

        if ( not flashAnim:IsPlaying() and not newItemAnim:IsPlaying() ) then
            flashAnim:Play()
            newItemAnim:Play()
        end
    else
        newItemTexture:Hide()

        if ( flashAnim:IsPlaying() or newItemAnim:IsPlaying() ) then
            flashAnim:Stop()
            newItemAnim:Stop()
        end
    end
end

local function ItemButton_UpdateItemCount(self, count)
    if ( not self ) then
        return
    end

    if ( not count ) then
        count = 0
    end

    local countString = self.Count
    self.count = count

    if ( count > 1 ) then

        if ( count >= 1e5 ) then
            count = "*"
        elseif ( count >= 1e3 ) then
            count = AbbreviateNumbers(count)
        end

        countString:SetText(count)
        countString:Show()
    else
        countString:Hide()
    end
end

local function ItemButton_UpdateDurability(self)
    if ( not self ) then
        return
    end

    local topString = self.TopString
    local current, total = GetContainerItemDurability(self.bagID, self.slotID)

    if ( not current or not total ) then
        topString:Hide()
        return
    end

    if ( total and total > 0 and current < total ) then
        local percent = current / total
        local color = ItemColorGradient(percent)
        topString:SetText(FormatPercentage(percent, true))
        topString:SetTextColor(color:GetRGB())
    else
        topString:Hide()
    end
end

local function ItemButton_UpdateItemLevel(self, inventoryType, quality, level)
    if ( not self ) then
        return
    end

    if ( inventoryType and inventoryType > 0 ) then
        local r, g, b = GetItemQualityColor(quality)
        self.BottomString:SetText(level)
        self.BottomString:SetTextColor(r, g, b)
        self.BottomString:Show()
    else
        self.BottomString:Hide()
    end
end

local function ItemButton_UpdateUpgradeArrow(self, inventoryType)
    if ( not self ) then
        return
    end

    local upgradeArrow = self.upgradeArrow

    if ( upgradeArrow ) then
        if ( inventoryType and inventoryType > 0 ) then
            local isUpgrade = IsContainerItemAnUpgrade(self.bagID, self.slotID)
            if ( isUpgrade ) then
                upgradeArrow:Show()
            else
                upgradeArrow:Hide()
            end
        else
            upgradeArrow:Hide()
        end
    end
end

--[[!
    Updates the buttons cooldown with new item-information
    @param bagID, slotID
]]
local function ItemButton_UpdateCooldown(self)
    if ( not self ) then
        return
    end

    local start, duration, enable = GetContainerItemCooldown(self.bagID, self.slotID)
    CooldownFrame_Set(self.Cooldown, start, duration, enable)
end

--[[!
    Updates the buttons lock with new item-information
    @param bagID, slotID
]]
local function ItemButton_UpdateLock(self)
    if ( not self ) then
        return
    end

    local _, _, locked = GetContainerItemInfo(self.bagID, self.slotID)
    self.Icon:SetDesaturated(locked)
end

local function ItemButton_UpdateQuality(self, quality)
    if ( not self ) then
        return
    end

	if ( quality ) then
        if ( quality > LE_ITEM_QUALITY_COMMON ) then
            local r, g, b = GetItemQualityColor(quality)
			self.Border:SetVertexColor(r, g, b)
		else
			self.Border:SetVertexColor(0.40, 0.40, 0.40)
		end
	else
		self.Border:SetVertexColor(0.40, 0.40, 0.40)
	end
end

--[[!
    Updates the buttons quest texture with new item information
    @param bagID, slotID
]]

local function ItemButton_UpdateQuest(self, quality)
    if ( not self ) then
        return
    end

    local questBang
    local isQuestItem, questID, isActive = GetContainerItemQuestInfo(self.bagID, self.slotID)

    local border = self.Border
    local quest = self.Quest

    if ( quest ) then
        if ( questID and not isActive ) then
            border:SetVertexColor(1, 1, 0.35)
            quest:Show()
        elseif ( questID or isQuestItem ) then
            border:SetVertexColor(1, 1, 0.35)
            quest:Hide()
        else
            self:UpdateQuality(quality)
            quest:Hide()
        end
    else
        self:UpdateQuality(quality)
    end
end

cargBags:RegisterScaffold("Default", function(self)
    self.bgTex = nil

    self.Scaffold = ItemButton_Scaffold

    self.Update = ItemButton_Update
    self.UpdateCooldown = ItemButton_UpdateCooldown
    self.UpdateLock = ItemButton_UpdateLock
    self.UpdateQuest = ItemButton_UpdateQuest
    self.UpdateIcon = ItemButton_UpdateIcon
    self.UpdateItemCount = ItemButton_UpdateItemCount
    self.UpdateItemLevel = ItemButton_UpdateItemLevel
    self.UpdateQuality = ItemButton_UpdateQuality
    self.UpdateDurability = ItemButton_UpdateDurability
    self.UpdateNewItemTexture = ItemButton_UpdateNewItemTexture
    self.UpdateUpgradeArrow = ItemButton_UpdateUpgradeArrow

    self.OnEnter = ItemButton_OnEnter
    self.OnLeave = ItemButton_OnLeave
end)
