if GetObjectName(GetMyHero()) ~= "MasterYi" then return
else

castQ=false

Q_ON = {
["Aatrox"]		= {0,_R},
["Ahri"]		= {0,_E},
["Akali"]		= {0,_Q},
["Alistar"]		= {0,_Q,_W},
["Amumu"]	= {0,_R},
["Anivia"]		= {0,_E},
["Annie"]		= {0,_R},
["Ashe"]		= {0,_R},
["Azir"]		= {0,_R},
["Blitzcrank"]	= {0,_Q},
["Brand"]		= {0,_R},
["Caitlyn"]		= {0,_R},
["Cassiopeia"]	= {0,_R},
["Darius"]		= {0,_R},
["Draven"]	= {0,_R},
["Elise"]		= {0,_E},
["Fizz"]		= {0,_R},
["Garen"]		= {0,_R},
["Gragas"]	= {0,_E},
["Graves"]	= {0,_R},
["Hecarim"]	= {0,_R},
["JarvanIV"]	= {0,_R},
["Jinx"]		= {0,_R},
["Kassadin"]	= {0,_R},
["Katarina"]	= {0,_Q},
["KhaZix"]		= {0,_E},
["LeeSin"]		= {0,_R},
["Lissandra"]	= {0,_R},
["Lulu"]		= {0,_W},
["Lucian"]		= {0,_E},
["Lux"]		= {0,_Q},
["Malphite"]	= {0,_R},
["Malzahar"]	= {0,_R},
["Morgana"]	= {0,_R},
["Nautilus"]	= {0,_R},
["Orianna"]	= {0,_R},
["Pantheon"]	= {0,_W},
["Quinn"]		= {0,_Q,_E},
["Rammus"]	= {0,_E},
["RekSai"]	= {0,_E},
["Renekton"]	= {0,_W},
["Rumble"]	= {0,_R},
["Ryze"]		= {0,_W},
["Sejuani"]	= {0,_R},
["Shaco"]		= {0,_Q},
["Shen"]		= {0,_E},
["Singed"]		= {0,_E},
["Skarner"]	= {0,_R},
["Sona"]		= {0,_R},
["Syndra"]		= {20,_R},
["Talon"]		= {0,_R},
["Taric"]		= {0,_E},
["Teemo"]		= {0,_Q},		--FUCK YOU
["Thresh"]		= {0,_E},
["Tryndamere"]	= {0,_E},
["TwistedFate"]	= {0,"goldcardpreattack"},		--special 
["Urgot"]		= {0,_R},
["Varus"]		= {0,_R},
["Vayne"]		= {0,_E},
["Veigar"]		= {0,_R},
["Vi"]			= {0,_R},
["Vladimir"]	= {0,_R},
["Warwick"]	= {0,_R},
["Xerath"]		= {0,_E},
["Trundle"]	= {0,_R},
["Tristana"]	= {0,_W},
["Yasuo"]		= {0,"yasuoq3","yasuoq3w"},		--special
["Zyra"]		= {0,_E},
["Riven"]		= {0,"rivenizunablade"}

--Plz rework me \|/
--["Nocturne"]	= {0,_R},
--["Karthus"]		= {3000,_R},
--["Zed"]			= {0,_R},
--["Jax"]			= {1000,_E},
--["Rengar"]		= {0,_Q}
}

-- Menu
Config = scriptConfig("Yi", "Yi")
Config.addParam("Q", "Use awesome Q", SCRIPT_PARAM_ONOFF, true)
Config.addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.addParam("KSQ", "Killsteal with Q", SCRIPT_PARAM_ONOFF, false)


-- Start
OnLoop(function(myHero)
	local unit = GetTarget(1500, DAMAGE_NORMAL)
	ks()
	if not IsImmune(unit) then 
		if delay and delay<=GetTickCount() and ValidTarget(unit,GetCastRange(myHero,_Q)) and castQ and Config.Q and CanUseSpell(myHero, _Q)==READY  then
			PrintChat("USED Q")
			CastTargetSpell(unit,_Q)
			castQ=false
		end
		if ValidTarget(unit,GetCastRange(myHero,_E)) and CanUseSpell(myHero, _E)==READY and Config.E then
			CastSpell(_E)
		end
	end
delay=false
end)


OnProcessSpell(function(unit, spellProc)
	if GetTeam(unit) ~= GetTeam(myHero) and GetObjectType(unit) == Obj_AI_Hero and Q_ON[GetObjectName(unit)] and ValidTarget(unit,GetCastRange(myHero,_Q)*1.5) then
--		PrintChat(GetObjectType(unit)..":"..spellProc.name)						--DEBUG
		
		for n,slot in pairs(Q_ON[GetObjectName(unit)]) do
			if n==1 then
				delay=slot
			elseif n>1 then
				if slot==_Q or slot==_W or slot==_E or slot==_R then
	--				PrintChat("Looking for "..GetCastName(unit,slot))			--DEBUG
					if spellProc.name==GetCastName(unit,slot) then
						PrintChat("Q'd on "..spellProc.name.." with "..delay.."ms delay")
						castQ=true
						delay=GetTickCount()+delay	
					end
				else
					if	spellProc.name==slot then
						castQ=true
						delay=GetTickCount()
					end
				end
			end

		end
	end
end)

function ks()
	for i,unit in pairs(GetEnemyHeroes()) do
		if CanUseSpell(myHero,_Q) == READY and ValidTarget(unit,GetCastRange(myHero,_Q))and GetCurrentHP(unit) < CalcDamage(myHero, unit, 0, (35*GetCastLevel(myHero,_Q)-5+GetBonusAD(myHero))) then 
				CastSpell(unit,Q)
		end
	end
end

PrintChat("Yi Loaded - Enjoy your game - Logge")
end -- End script
