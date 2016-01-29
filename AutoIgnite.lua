--Simple Auto Ignite
require('Inspired')
if GetCastName(myHero,SUMMONER_1) == "summonerdot" then
	Ignite = SUMMONER_1
elseif GetCastName(myHero,SUMMONER_2) == "summonerdot" then
	Ignite = SUMMONER_2
else
	return
end

local IMenu = Menu("Ignite","Ignite")
IMenu:Boolean("i","Auto Ignite", true)

OnTick(function(myHero)
	if IMenu.i:Value() and IsReady(Ignite) then
 		for _,enemy in pairs(GetEnemyHeroes()) do
  			if 20*GetLevel(myHero)+50 > GetCurrentHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
				CastTargetSpell(enemy, Ignite)
			end
		end
	end
end)
