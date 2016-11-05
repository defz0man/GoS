--Permission
local temp = {}
local func = {
	["Action"] = {
		["AttackUnit"] = "Attack Units",
		["BlockCast"] = "Block Spells",
		["BlockInput"] = "Block all Input",
		["BlockOrder"] = "Block Movement",
		["BuyItem"] = "Buy Items",
		["CastEmote"] = "Use Emotes",
		["CastSpell"] = "Use Spells",
		["HoldPosition"] = "Stop",
		["Interact"] = "Interact with Objects",
		["LevelSpell"] = "Level Spells",
		["MoveToXYZ"] = "Move the Char",
		["SetCursorPos"] = "Move my Cursor"
	},
	["Visual"] = {
		["DrawCircle"] = "Draw Circles",
		["DrawLine"] = "Draw Lines",
		["DrawSprite"] = "Draw Sprites",
		["DrawText"] = "Draw Text",
	},
	["Misc"] =  {
		["CreateDir"] = "Create Folders",
		["RemoveDir"] = "Delete Folders",
		["DownloadFileAsync"] = "Download Files",
		["GetWebResultAsync"] = "Read Webpages",
		["GetUser"] = "Read your GoS Username",
		["GetGroup"] = "Read your GoS Group",
		["PlaySound"] = "Play sounds",
	},
}

local PMenu = Menu("Permission","Permission")

for cat,tab in pairs(func) do 
	PMenu:SubMenu(cat,cat)
	for funct,desc in pairs(tab) do 
		PMenu[cat]:Boolean(funct,desc,true,function(v) 
			if v and temp[funct] then
				_G[funct] = temp[funct]
			elseif not v then
				temp[funct] = _G[funct]
				_G[funct] = function() return end
			end
		end)
		if PMenu[cat][funct]:Value() and temp[funct] then
			_G[funct] = temp[funct]
		elseif not PMenu[cat][funct]:Value() then
			temp[funct] = _G[funct]
			_G[funct] = function() return end
		end
	end
end