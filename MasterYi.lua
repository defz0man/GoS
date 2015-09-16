if GetObjectName(GetMyHero()) ~= "MasterYi" then return end

require 'Inspired'
require("IOW")

local myHero=GetMyHero()
local delay=0

Q_ON = {
["Aatrox"]		= {0,_R},
["Ahri"]		= {0,_E},
["Akali"]		= {0,_Q},
["Alistar"]		= {0,_Q,0,_W},
["Amumu"]		= {0,_R},
["Anivia"]		= {0,_E},
--["Annie"]		= {0,_R},
["Ashe"]		= {0,_R},
["Azir"]		= {0,_R},
["Blitzcrank"]		= {0,_Q,0,_R},
["Brand"]		= {0,_R},
["Caitlyn"]		= {0,_E,0,_R},
["Cassiopeia"]		= {0,_R},
["Darius"]		= {0,_R},
["Draven"]		= {0,_R},
["Elise"]		= {0,_E},
["Ezreal"]		= {0,_E},
["Fizz"]		= {0,_R},
--[Fiora"]		= {0,_W},
["Garen"]		= {0,_R},
["Gragas"]		= {0,_E,0,_R},
["Graves"]		= {0,_R},
["Hecarim"]		= {0,_R},
["JarvanIV"]		= {0,_R},
["Jinx"]		= {0,_R},
["Kassadin"]		= {0,_R},
["Katarina"]		= {0,_Q},
["KhaZix"]		= {0,_E},
["LeeSin"]		= {0,_R},
["Lissandra"]		= {0,_R},
["Lulu"]		= {0,_W},
["Lucian"]		= {0,_E},
["Lux"]			= {0,_Q},
["Malphite"]		= {0,_R},
["Malzahar"]		= {0,_R},
["Morgana"]		= {0,_Q,0,_R},
["Nautilus"]		= {0,_R},
["Orianna"]		= {0,_R},
["Pantheon"]		= {0,_W},
["Quinn"]		= {0,_Q,0,_E},
["Rammus"]		= {0,_E},
["RekSai"]		= {0,_E},
--["Renekton"]		= {0,_W},
["Rumble"]		= {0,_R},
["Ryze"]		= {0,_W},
["Sejuani"]		= {0,_R},
["Shaco"]		= {0,_Q},
["Shen"]		= {0,_E},
["Singed"]		= {0,_E},
["Skarner"]		= {0,_R},
["Sona"]		= {0,_R},
["Syndra"]		= {20,_R},
["Talon"]		= {0,_R},
["Taric"]		= {0,_E},
["Teemo"]		= {0,_Q},
["Thresh"]		= {0,_E},
["Tryndamere"]		= {0,_E},
["TwistedFate"]		= {0,"goldcardpreattack"},		--special 
["Urgot"]		= {0,_R},
["Varus"]		= {0,_R},
["Vayne"]		= {0,_E},
["Veigar"]		= {0,_R},
["Vi"]			= {0,_R},
["Vladimir"]		= {0,_R},
["Warwick"]		= {0,_R},
["Xerath"]		= {0,_E},
["Trundle"]		= {0,_R},
["Tristana"]		= {0,_W,0,_R},
["Yasuo"]		= {0,"yasuoq3",0,"yasuoq3w"},		--special
["Zyra"]		= {0,_E},

["Riven"]		= {0,"rivenizunablade"},
["Rengar"]		= {0,"RengarBasicAttack",0,"RengarBasicAttack2"},
["Jax"]		= {1050,_E}

--Plz rework me \|/
--["Nocturne"]		= {0,_R},
--["Karthus"]		= {3000,_R},
--["Zed"]		= {0,_R},


}

LvLSeq={_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}
--Q,E,W; 1R,2Q,3E,4W
meeleItems={3153,3144,3142,3074,3077,3143}
--	    Botr,Bilg,Ghos,Hydr,Tiam,Rand
cleanseItems={3140,3139}
--	     Merc,QSS

-- Menu
local Config = Menu("Master Yi", "MY")
Config:SubMenu("c", "Combo")
Config.c:Boolean("AQ","Use awesome Q",true)
Config.c:Boolean("E", "Use E", true)
Config.c:Boolean("KSQ", "Killsteal with Q", false)
Config:SubMenu("m", "Misc")
Config.m:Boolean("AL","AutoLevel", true)
Config.m:Boolean("It","Items", true)

-- Start
OnLoop(function(myHero)
	if not IsDead(myHero) then
		local unit = GoS:GetTarget(1500, DAMAGE_NORMAL)
		ks()
		ALvL()
		UseItems()
	end
end)


OnProcessSpell(function(unit, spellProc)
	if not IsDead(myHero) and Config.c.AQ:Value() and GetTeam(unit) ~= GetTeam(myHero) and GetObjectType(unit) == Obj_AI_Hero and Q_ON[GetObjectName(unit)] and GoS:ValidTarget(unit,GetCastRange(myHero,_Q)*1.5) and CanUseSpell(myHero, _Q) then
--		PrintChat(GetObjectType(unit)..":"..spellProc.name)						--DEBUG
		
		for n,slot in pairs(Q_ON[GetObjectName(unit)]) do
			if n%2==1 then
				delay=slot
			elseif n>1 then
				if slot==_Q or slot==_W or slot==_E or slot==_R or spellProc.name==slot then						
					--print("Looking for "..GetCastName(unit,slot))			--DEBUG
					if (spellProc.name==GetCastName(unit,slot) or spellProc.name==slot) and GoS:ValidTarget(unit,GetCastRange(myHero,_Q)*1.5) and CanUseSpell(myHero, _Q) then
						if GetObjectName(unit)=="Rengar" and not GotBuff("RengarR") then return end
						PrintChat("Q'd on "..spellProc.name.." with "..delay.."ms delay")
						GoS:DelayAction( 
								function()
								--PrintChat("USED Q")
								CastTargetSpell(unit,_Q)
								end
							,delay)
						delay=0
					end
				end
			end
		end
	end
	if (spellProc.name:find("MasterYiBasicAttack") or spellProc.name:find("MasterYiBasicAttack2")) and Config.c.E:Value() and GoS:GetDistance(myHero,GoS:ClosestEnemy(pos))<150 and CanUseSpell(myHero, _E) then
		CastSpell(_E)
	end
end)

function ALvL()
	if Config.m.AL:Value() then
		local lvl=GetLevel(myHero)
		LevelSpell(LvLSeq[lvl])
	end
end

function ks()
	for i,unit in pairs(GoS:GetEnemyHeroes()) do
		if Config.c.KSQ:Value() and CanUseSpell(myHero,_Q) and GoS:ValidTarget(unit,GetCastRange(myHero,_Q)) and GetCurrentHP(unit) < GoS:CalcDamage(myHero, unit, 0, (35*GetCastLevel(myHero,_Q)-5+GetBonusDmg(myHero)))+GetDmgShield(unit) then 
				CastTargetSpell(unit,_Q)
		end
	end
end

function UseItems()
	if Config.m.It:Value() and IOW:Mode() == "Combo" then 
	local unit = GoS:GetTarget(1500, DAMAGE_NORMAL)
		for _,id in pairs(cleanseItems) do
			if GetItemSlot(myHero,id) > 0 and GotBuff(myHero, "rocketgrab2") > 0 or GotBuff(myHero, "charm") > 0 or GotBuff(myHero, "fear") > 0 or GotBuff(myHero, "flee") > 0 or GotBuff(myHero, "snare") > 0 or GotBuff(myHero, "taunt") > 0 or GotBuff(myHero, "suppression") > 0 or GotBuff(myHero, "stun") > 0 or GotBuff(myHero, "zedultexecute") > 0 or GotBuff(myHero, "summonerexhaust") > 0  then
				CastTargetSpell(myHero, GetItemSlot(myHero,id))
			end
		end
	
		for _,id in pairs(meeleItems) do
			if GetItemSlot(myHero,id) > 0 and GoS:ValidTarget(unit, 550) then
			CastTargetSpell(unit, GetItemSlot(myHero,id))
			end
		end
	end
end

PrintChat("Yi Loaded - Enjoy your game - Logge")
