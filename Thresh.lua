if GetObjectName(GetMyHero()) ~= "Thresh" then return end

require("Inspired")
local myHero=GetMyHero()
local delay=0



E_ON = {
["Ahri"]		= {0,_R},
["Akali"]		= {0,_R},
["Alistar"]		= {0,_W},
["Amumu"]		= {0,_E},
["Azir"]		= {0,_E},
["Caitlyn"]		= {0,_E},
["Diana"]		= {0,_R},
["Ekko"]		= {0,_E},
["Gnar"]		= {0,_E},
["Gragas"]		= {0,_E},
["Graves"]		= {0,_E},
["Irelia"]		= {0,_Q},
["JarvanIV"]	= {0,"JarvanIVEQ"},
["Jax"]		= {0,_Q},
["Kindred"]		= {0,_Q},
["KhaZix"]		= {0,_E},
["LeeSin"]		= {0,_Q}, --Q2
["Lucian"]		= {0,_E},
["Pantheon"]		= {0,_W},
["Quinn"]		= {0,_E},
["RekSai"]		= {0,_E},			--tunnelname
["Sejuani"]		= {0,_Q},
["Shyvana"]		= {0,_R},
["Shen"]		= {0,_E},
--["Thresh"]		= {0,_Q},	--Q2
["Tryndamere"]		= {0,_E},
["Vayne"]		= {0,_Q},
["Vi"]			= {0,_Q},
["Tristana"]		= {100,_W},
["Yasuo"]		= {0,_E},
["Riven"]		= {0,_E},
["XinZaho"]		= {0,_E},
["MokneyKing"]		= {0,_E}
}

flay={}

DelayAction(function ()
	for _,hero in pairs(GetEnemyHeroes()) do
		flay[GetObjectName(hero)]=false
		print(GetObjectName(hero).." checked")
	end
end,1000)

-- Menu
local Config = Menu("Thresh", "Thresh")
Config:SubMenu("c", "Combo")
Config.c:Boolean("AW", "Auto W", true)

Config:SubMenu("E","E config")
Config.E:Boolean("AE1","Use Anti-Gapcloser E",true)
Config.E:Boolean("AE2","Use Anti-Escape E",true)

Config:SubMenu("m", "Misc")
Config.m:Boolean("AL","AutoLevel", false)
--Config.m:Boolean("It","Items", true)
--Config.m:Boolean("Debug","Print Messages",true)

-- Menu for spells



-- Start
OnLoop(function(myHero)
	if not IsDead(myHero) then
		local unit = GetCurrentTarget()
		ALvL()
		AutoFlay()
	end
end)


OnProcessSpell(function(unit, spellProc)
	if not IsDead(myHero) and GetTeam(unit) ~= GetTeam(myHero) and GetObjectType(unit) == Obj_AI_Hero and CanUseSpell(myHero,_E) == READY and E_ON[GetObjectName(unit)] then
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
			if spell~=nil and spell==spellProc.name then
			flay[GetObjectName(unit)]=true
			--MOVE TO ONLOOP
				local myPos=GetOrigin(myHero)
				local unitPos=GetOrigin(unit)
				if GetDistance(myPos,unitPos)<GetDistance(myPos,spellProc.target) and Config.E.AE1:Value() then 
					local EPosx=myPos.x+myPos.x-unitPos.x
					local EPosy=myPos.y+myPos.y-unitPos.y
					local EPosz=myPos.z+myPos.z-unitPos.z
					DelayAction( function()
					CastSkillShot(_E,EPosx,EPosy,EPosz)
					end
					, delay)
				elseif Config.E.AE2:Value() then
					DelayAction( function()
					CastSkillShot(_E,unitPos.x,unitPos.y,unitPos.z)
					end
					, delay)
				else
					print("Can't decide :fappa:")
				end
			end
		end
	end
end)

OnUpdateBuff(function(Object,buffProc)
	AW(Object,buffProc)
end)

function AutoFlay()
	for _,hero in pairs(GetEnemyHeroes()) do
		if ValidTarget(hero,GetCastRange(myHero,_E)) and flay[GetObjectName(hero)] then
			print("Flay")
		end
	end
end

function AW(ally,buffProc)
	if Config.c.AW:Value() and CanUseSpell(myHero,_W) == READY and ally~=myHero and GetTeam(ally) == GetTeam(myHero) and GetObjectType(ally) == Obj_AI_Hero then
		local enemy=GetCurrentTarget()
		if enemy and GetDistance(GetOrigin(myHero),GetOrigin(enemy))>GetDistance(GetOrigin(ally),GetOrigin(myHero)) then
			local BType=buffProc.Type
			if BType5==5 or BType==8 or BType==9 or BType==11 or BType==21 or BType==22 or BType==24 then
				print("GOTBUFF")
				local AllyPos=GetOrigin(ally)
				CastSkillShot(_W,AllyPos.x,AllyPos.y,AllyPos.z)
			end
		end
	end
end

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
