if GetObjectName(GetMyHero()) ~= "LeeSin" then return end

require("Inspired")
require("DamageLib")


-- Menu
Config = Menu("LeeSin", "LeeSin")
Config:SubMenu("c", "Combo")
Config.c:Boolean("Q1", "Use Q1", true)
Config.c:Boolean("Q2", "Use Q2", true)
Config.c:Slider("Q2P", "%HP for Q", 10, 0, 100, 5)
--Config.c:Boolean("W1", "Use W1", true)
--Config.c:Boolean("W2", "Use W2", true)
Config.c:Boolean("E1", "Use E1", true)
Config.c:Boolean("E2", "Use E2", true)


Config:SubMenu("ks", "Killsteal")
Config.ks:Boolean("KSQ1","Killsteal with Q1", true)
Config.ks:Boolean("KSR","Killsteal with R", true)

Config:SubMenu("m", "misc")
Config.m:Info("blubb","nothing here :P")

-- Start
OnTick(function(myHero)
	if not IsDead(myHero) then
		local unit = GetCurrentTarget()
		combo(unit)
		ks()
	end
end)

OnDraw(function(myHero)
	for i,unit in pairs(GetEnemyHeroes()) do
		if ValidTarget(unit,1000) then
			if Ready(_R) then
				DrawDmgOverHpBar(unit,GetCurrentHP(unit),getdmg("R",unit ,myHero),0,0xffffffff)
			end
		end
	end
end)

function combo(unit)
	if IOW:Mode() == "Combo" then
		if GetCastName(myHero,0)=="BlindMonkQOne" and Config.c.Q1:Value() and ValidTarget(unit, GetCastRange(myHero,_Q)) then
			local QPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),1780,250,1000,70,true,false)
			if QPred.HitChance==1 then
				CastSkillShot(_Q,QPred.PredPos)
			end
		end
		if GetCastName(myHero,0)~="BlindMonkQOne" and Config.c.Q2:Value() and ValidTarget(unit, 1300) then
			CastSpell(_Q)
		end
		if GetCastName(myHero,2)=="BlindMonkEOne" and Config.c.E1:Value() and ValidTarget(unit, GetCastRange(myHero,_E)) then
			CastSpell(_E)
		end		
		if GetCastName(myHero,2)~="BlindMonkEOne" and Config.c.E2:Value() and ValidTarget(unit, 500) then
			CastSpell(_E)
		end
	end
end



function jump2creep()
	creep=ClosestMinion(GetOrigin(myHero), MINION_ALLY)
	if GetDistance(creep,myHero)<GetCastRange(myHero,_W) then
		CastTargetSpell(creep,_W)
	end
end


function ks()
	for i,unit in pairs(GetEnemyHeroes()) do
		if Config.ks.KSR:Value() and Ready(_R) and ValidTarget(unit,GetCastRange(myHero,_R)) and GetCurrentHP(unit)+GetDmgShield(unit) < getdmg("R",unit ,myHero) then 
			CastTargetSpell(unit,_R)
		end
		local QPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),1780,250,1000,70,true,false)
		if Config.ks.KSQ1:Value() and Ready(_Q) and ValidTarget(unit,GetCastRange(myHero,_Q)) and GetCurrentHP(unit)+GetDmgShield(unit) < getdmg("Q",unit ,myHero) then 
			CastSkillShot(_Q,QPred.PredPos)
		end
	end
end




PrintChat("Lee Loaded - Enjoy your game - Logge")
PrintChat("Unofficial Script - No support - stop asking in Requests fgts")
