  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  --ActionBars config  
  cfg.mAB = {
	size = 30,						-- setting up default buttons size
	spacing = 2, 					-- spacing between buttons
	media = {						-- MEDIA
		textures_normal = "Interface\\Addons\\m_ActionBars\\media\\icon",
		textures_pushed = "Interface\\Addons\\m_ActionBars\\media\\icon",
		textures_btbg = "Interface\\Buttons\\WHITE8x8",
		button_font = "Interface\\Addons\\m_ActionBars\\media\\font.ttf",
	},		
	}

  cfg.bars = {
	["Bar1"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 12,		
		button_size = cfg.mAB.size,		button_spacing = cfg.mAB.spacing,
		position = {a= "BOTTOM", x=	0, y= 10},
		custom_visibility_macro = false	-- set a custom visibility macro for this bar or 'false' to disable 
										-- (e.g. "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;show")
		},
	["Bar2"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 12,
		button_size = cfg.mAB.size,			button_spacing = cfg.mAB.spacing,
		position = {a= "BOTTOM", x=	0, y= 45},
		custom_visibility_macro = false
		},
	["Bar3"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 12,	
		button_size = cfg.mAB.size,			button_spacing = cfg.mAB.spacing,
		position = {a= "BOTTOM", x=	0, y= 80},
		custom_visibility_macro = false
		},
	["Bar4"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "VERTICAL",		rows = 1,					buttons = 12,	
		button_size = cfg.mAB.size,			button_spacing = cfg.mAB.spacing,
		position = {a= "RIGHT", x=	-35, y= 0},
		custom_visibility_macro = false
		},
	["Bar5"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "VERTICAL",		rows = 1,					buttons = 12,	
		button_size = cfg.mAB.size,			button_spacing = cfg.mAB.spacing,
		position = {a= "RIGHT", x=	-70, y= 0},
		custom_visibility_macro = false
		},
	["Bar6"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "VERTICAL",		rows = 1,					buttons = 12,	
		button_size = cfg.mAB.size,			button_spacing = cfg.mAB.spacing,
		position = {a= "RIGHT", x=	-105, y= 0},
		custom_visibility_macro = false
		},
	["StanceBar"] = {
		hide_bar = true,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 6,
		button_size = cfg.mAB.size,			button_spacing = cfg.mAB.spacing,
		position = {a= "BOTTOM", x=	-96, y= 115},
		custom_visibility_macro = false
		},
	["PetBar"] = {
		hide_bar = false,				show_in_combat = false,		scale = 0.8,
		show_on_mouseover = true,		bar_alpha = 1,				fadeout_alpha = 0.3,
		orientation = "HORIZONTAL",	rows = 1,					buttons = 10, 
		button_size = cfg.mAB.size,			button_spacing = cfg.mAB.spacing,
		position = {a= "BOTTOM", x=	0, y= 147},
		custom_visibility_macro = false
		},
	["MicroMenu"] = {
		hide_bar = false,				show_on_mouseover = false,	scale = 0.85,
		lock_to_CharacterFrame = true,					-- position MicroMenu bar right on top of your CharacterFrame
		position = {a= "BOTTOM", x=	65,	y= 115},	  	-- if not locked
		},
		
	["ExitVehicleButton"] = {
		disable = false,				user_placed = true,	-- if user_placed is set to false exit vehicle button will be 'docked' into bar1	
		position = {a="BOTTOM", x=-129, y=238}, 			-- only if user_placed = true
		button_size = 28,									-- only if user_placed = true
		},
	["ExtraButton"] = {
		disable = false,
		position = {a= "BOTTOM", x=	0,	y= 250},
		},

	["RaidIconBar"] = {
		hide = false,					in_group_only = true,
		show_on_mouseover = true,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "VERTICAL",		rows = 1,
		button_size = 20,				button_spacing = 3,
		position = {a= "RIGHT", x=	-10, y= -77},
		},
	["WorldMarkerBar"] = {
		hide = false,					disable_in_combat = true,	
		show_on_mouseover = true,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "VERTICAL",		rows = 1,
		button_size = 20,				button_spacing = cfg.mAB.spacing,
		position = {a= "RIGHT",    	x=	-10,	y= 122},
		},
	}
	
  --ButtonsStyler config
  cfg.buttons = {
	hide_hotkey = false,		-- remove key binding text from the bars
	hide_macro_name = true,		-- remove macro name text from the bars
	count_font_size = 12,		-- remove count text from the bars
	hotkey_font_size = 11,		-- font size for the key bindings text
	name_font_size = 8,			-- font size for the macro name text
	colors = {	--R,G,B
		   normal = {0,0,0},
		   pushed = {1,1,1},
		highlight = {.9,.8,.6},
		  checked = {.9,.8,.6},
	   outofrange = {.8,.3,.2},
		outofmana = {.3,.3,.7},
		   usable = {1,1,1},
		 unusable = {.4,.4,.4},
		 equipped = {.3,.6,.3}
	  }
  }

  
  -- HANDOVER
  ns.cfg = cfg
