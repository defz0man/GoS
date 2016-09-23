--Simple Auto Ignite
if GetCastName(myHero,SUMMONER_1):lower() == "summonerdot" then
	Ignite = SUMMONER_1
elseif GetCastName(myHero,SUMMONER_2):lower() == "summonerdot" then
	Ignite = SUMMONER_2
else
	return
end

require('OpenPredict')	--Needed for HealthPred
local IMenu = Menu("Ignite","Ignite")
IMenu:KeyBinding("I", "Enable Ignite", string.byte("U"), true)
IMenu:Boolean("P", "Use Health Prediction", true)
IMenu:SubMenu("E","Ignite Selector")
IMenu:Boolean("D", "Draw Ignite Damage", true)

DelayAction(function()
	for _,i in pairs(GetEnemyHeroes()) do
		IMenu.E:Boolean(i.networkID, i.charName, true)
	end
end,.001)

OnTick(function()
	if IMenu.I:Value() and IsReady(Ignite) then
 		for _,enemy in pairs(GetEnemyHeroes()) do
  			if 20*myHero.level+50 > (IMenu.P:Value() and GetHealthPrediction(enemy, 5) or enemy.health)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) and IMenu.E and IMenu.E[enemy.networkID] and IMenu.E[enemy.networkID]:Value() then
				CastTargetSpell(enemy, Ignite)
			end
		end
	end
end)

OnDraw(function()
	if Ready(Ignite) and IMenu.D:Value() then
		for _,i in pairs(GetEnemyHeroes()) do 
			if i.valid and i.visible and i.distance < 3000 then
				DrawDmgOverHpBar(i,i.health,20*myHero.level+50,0,GoS.Red)
			end
		end
	end
end)
