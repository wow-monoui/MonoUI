local addon, ns = ...
local cfg = CreateFrame("Frame")

-- Player bags settings
cfg.bags = { 
	general = {
        textures_normal = "Interface\\Addons\\m_Bags\\media\\icon",
        textures_pushed = "Interface\\Addons\\m_Bags\\media\\icon",
        textures_btbg = "Interface\\Buttons\\WHITE8x8",
		font = "Interface\\Addons\\m_Bags\\media\\font.ttf",
		font_size = 14,
    },
    colors = {
        --R,G,B
        normal = { 0, 0, 0 },
        pushed = { 1, 1, 1 },
        highlight = { .9, .8, .6 },
        checked = { .9, .8, .6 },
        outofrange = { .8, .3, .2 },
        outofmana = { .3, .3, .7 },
        usable = { 1, 1, 1 },
        unusable = { .4, .4, .4 },
        equipped = { .3, .6, .3 }
    },
	position = {"BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -20, 215},
	columns = 10,
	scale = 0.96,
	sets = true,
	consumables = true,
}

-- Bank settings
cfg.bank = { 
	position = {"BOTTOMRIGHT", "m_BagsMain", "BOTTOMLEFT", -25, 0},
	columns = 12,
	scale = 0.96,
	sets = false,
}

options = {
    itemSlotSize = 34,
    borderSize = 1,
    
    NewItems = true,
    Restack = true,
    TradeGoods = true,
    Armor = true,
    Gem = true,
    CoolStuff = false,
    Junk = true,
    ItemSets = true,
    Consumables = true,
    Quest = true,
    Fishing = true,
    scale = 1,
    FilterBank = true,
    CompressEmpty = true,
    Unlocked = true,
    SortBags = true,
    SortBank = true,
    BankCustomBags = true,
    SellJunk = true,

    fonts = {
        -- Font to use for bag captions and other strings.
        standard = { "Interface\\Addons\\m_Bags\\media\\font.ttf", 12, "OUTLINE" },

        --Font to use for the dropdown menu
        dropdown = { "Interface\\Addons\\m_Bags\\media\\font.ttf", 13, nil },

        -- Font to use for durability and item level
        itemInfo = { "Interface\\Addons\\m_Bags\\media\\font.ttf", 9, "OUTLINE" },

        -- Font to use for number of items in a stack
        itemCount = { "Interface\\Addons\\m_Bags\\media\\font.ttf", 12, "OUTLINE" },
    },

    -- r, g, b, opacity
    colors = {
        background = {0.05, 0.05, 0.05, 0.8},
    },
}

-- handover
ns.cfg = cfg
ns.options = options