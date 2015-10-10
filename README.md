if GetObjectName(GetMyHero()) ~= "Thresh" then return end

require("Inspired")
require("IOW")

local myHero=GetMyHero()
local delay=0

--FORMAT:
--Delay,spelltype,Hotkey/Name
--spelltype: 0 Normal
--spelltype: 1 Targeted
--spelltype: 2 Nuke
--spelltype: 3 Gapcloser
E_ON = {
["Ahri"]		= {0,_R},
["Akali"]		= {0,_R},
["Alistar"]		= {0,_W},
["Azir"]		= {0,_E},
["Caitlyn"]		= {0,_E},
["Diana"]		= {0,_R},
["Gnar"]		= {0,_E},
["Gragas"]		= {0,_E},
["Graves"]		= {0,_E},
["JarvanIV"]	= {0,"JarvanIVEQ"},
["KhaZix"]		= {0,_E},
["LeeSin"]		= {0,_Q}, --Q2
["Lucian"]		= {0,_E},
["Pantheon"]		= {0,_W},
["Quinn"]		= {0,_E},
["RekSai"]		= {0,_E},			--tunnelname
["Sejuani"]		= {0,_Q},
["Shen"]		= {0,_E},
--["Thresh"]		= {0,_Q},	--Q2
["Tryndamere"]		= {0,_E},
["Vayne"]		= {0,_Q},
["Vi"]			= {0,_Q},
["Tristana"]		= {100,_W},
["Yasuo"]		= {0,_E},
["Riven"]		= {0,_E},
["Jax"]		= {0,_Q}
}

-- Menu
local Config = Menu("Thresh", "Thresh")
Config:SubMenu("c", "Combo")
--Config.c:Boolean("W", "Auto W", true)

Config:SubMenu("E","E config")
Config.E:Boolean("AE","Use awesome E",true)

Config:SubMenu("m", "Misc")
Config.m:Boolean("AL","AutoLevel", true)
--Config.m:Boolean("It","Items", true)
Config.m:Boolean("Debug","Print Messages",true)

-- Menu for spells



-- Start
OnLoop(function(myHero)
	if not IsDead(myHero) then
		local unit = GetCurrentTarget()
		ALvL()
	end
end)


OnProcessSpell(function(unit, spellProc)
	if not IsDead(myHero) and Config.E.AE:Value() and GetTeam(unit) ~= GetTeam(myHero) and GetObjectType(unit) == Obj_AI_Hero and CanUseSpell(myHero,_E) == READY and E_ON[GetObjectName(unit)] then
	spell=nil
	slot=nil
		for n,slot in pairs(E_ON[GetObjectName(unit)]) do
			if n%2==1 then
				delay=slot
			elseif n%2==0 then
				spell=slot
				if tonumber(slot) then
					spell=GetCastName(unit,slot)
				end
			end
			if spell~=nil and GoS:ValidTarget(unit,GetCastRange(myHero,_E)) and spell==spellProc.name then
				local myPos=GetOrigin(myHero)
				local unitPos=GetOrigin(unit)
				if GoS:GetDistance(myPos,unitPos)<GoS:GetDistance(myPos,spellProc.target) then 
					local EPosx=myPos.x+myPos.x-unitPos.x
					local EPosy=myPos.y+myPos.y-unitPos.y
					local EPosz=myPos.z+myPos.z-unitPos.z
					--print("X: "..EPosx)
					--print("Y: "..EPosy)
					--print("Z: "..EPosz)
					GoS:DelayAction( function()
					CastSkillShot(_E,EPosx,EPosy,EPosz)
					end
					, delay)
				else
					GoS:DelayAction( function()
					CastSkillShot(_E,unitPos.x,unitPos.y,unitPos.z)
					end
					, delay)
				end
			end
		end
	end
end)

LvLSeq={_E,_Q,_W,_E,_E,_R,_Q,_Q,_Q,_E,_R,_E,_Q,_W,_W,_R,_W,_W}
--Q,E,W; 1R,2Q,3E,4W
function ALvL()
	if Config.m.AL:Value() then
		if GetLevel(myHero)==3 then --ARAM AutoLvL
			if LevelSpell(LvLSeq[3]) then
				LevelSpell(LvLSeq[1])
				LevelSpell(LvLSeq[2])
				end
		else
			LevelSpell(LvLSeq[GetLevel(myHero)])
		end
	end
end



PrintChat("Thresh Loaded - Enjoy your game - Logge")
