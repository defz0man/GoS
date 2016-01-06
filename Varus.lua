if GetObjectName(GetMyHero()) ~= "Varus" then return end

require("Inspired")
require("OpenPredict")

-- Menu
VMenu = Menu("Varus", "Varus")
VMenu:SubMenu("c", "Combo")
VMenu.c:Boolean("Q", "Use Q", true)
VMenu.c:Slider("sQ", "Stacks to use Q", 0, 0, 3, 1)
VMenu.c:Boolean("E", "Use E", true)
VMenu.c:Slider("sE", "Stacks to use E", 1, 0, 3, 1)
VMenu.c:Boolean("R", "Use R", true)
VMenu.c:Slider("RE", "Enemies around for R", 3, 1, 5, 1)

VMenu:SubMenu("ks", "Killsteal")
VMenu.ks:Boolean("KSS","Smart Killsteal", true)
VMenu.ks:Boolean("KSQ","Killsteal with Q", true)
VMenu.ks:Boolean("KSE","Killsteal with E", true)
VMenu.ks:Boolean("KSR","Killsteal with R", true)

VMenu:SubMenu("p", "Prediction")
VMenu.p:Slider("hQ", "HitChance Q", 20, 0, 100, 1)
VMenu.p:Slider("hE", "HitChance E", 20, 0, 100, 1)
VMenu.p:Slider("hR", "HitChance R", 20, 0, 100, 1)

VMenu:SubMenu("d", "Draw")
VMenu.d:Boolean("dD","Draw Damage", true)
VMenu.d:Boolean("dQ","Draw Q", true)
VMenu.d:Boolean("dW","Draw W", true)
VMenu.d:Boolean("dE","Draw E", true)
VMenu.d:Boolean("dR","Draw R", true)

--Var
qTime = 0
qCharge = false
qRange = 0
VarusE = { delay = 0.1, speed = 1700, width = 55, range = 925, radius = 275 }
VarusR = { delay = 0.1, speed = 1850, width = 120, range = 1075}

wTrack = {}
DelayAction( function()
	for _,i in pairs(GetEnemyHeroes()) do
		wTrack[GetObjectName(i)]=0
	end
end,1)


-- Start
OnTick(function(myHero)
	if not IsDead(myHero) then
		local unit = GetCurrentTarget()
		ks()
		combo(unit)
	end
end)

OnDraw(function(myHero)
	for i,unit in pairs(GetEnemyHeroes()) do
		if ValidTarget(unit,2000) and VMenu.d.dD:Value() then
			local DmgDraw=0
			if Ready(_Q) and VMenu.d.dQ:Value() then
				DmgDraw = DmgDraw + CalcDamage(myHero, unit, GetCastLevel(myHero,_Q)*55-40+GetBonusDmg(unit)*1.6 ,0)
			end
			if Ready(_Q) or Ready(_E) and VMenu.d.dW:Value() then
				DmgDraw = DmgDraw + StackDamage(unit)
			end
			if Ready(_E) and VMenu.d.dE:Value() then
				DmgDraw = DmgDraw + CalcDamage(myHero, unit, GetCastLevel(myHero,_E)*35+30+GetBonusDmg(unit)*.6 ,0)
			end
			if Ready(_R) and VMenu.d.dR:Value() then
				DmgDraw = DmgDraw + CalcDamage(myHero, unit, 0 ,GetCastLevel(myHero,_R)*75+25+GetBonusAP(unit))
			end
			if DmgDraw > GetCurrentHP(unit) then
				DmgDraw = GetCurrentHP(unit)
			end
			DrawDmgOverHpBar(unit,GetCurrentHP(unit),DmgDraw,0,0xffffffff)
		end
	end
end)

function combo(unit)
	if qCharge and (1000 + (GetTickCount() - qTime) * 0.4) < 1625 then
		qRange = 1000 + (GetTickCount() - qTime) * 0.4
	elseif not qCharge then
		qRange = 900
	end
	
	if IOW:Mode() == "Combo" then
		--Q1
		if VMenu.c.Q:Value() and Ready(_Q) and ValidTarget(unit, 1500) and not qCharge and wTrack[GetObjectName(unit)] >= VMenu.c.sQ:Value() then
			CastSkillShot(_Q,GetOrigin(myHero))	
		end
		
		--Q2
		if VMenu.c.Q:Value() and Ready(_Q) and ValidTarget(unit, qRange) and qCharge then
			local VarusQ = { delay = 0.1, speed = 1850, width = 70, range = qRange }
			local QPred = GetPrediction(unit, VarusQ)
			--DrawCircle(GetOrigin(myHero),qRange,0,3,0xffffff00)
			
			if QPred and QPred.hitChance >= (VMenu.p.hQ:Value()/100) then
				CastSkillShot2(_Q, QPred.castPos)
			end
		end
		
		--E
		if Ready(_E) and VMenu.c.E:Value() and ValidTarget(unit, GetCastRange(myHero,_E)) and wTrack[GetObjectName(unit)] >= VMenu.c.sE:Value() then
			local EPred=GetCircularAOEPrediction(unit, VarusE)
			if EPred and EPred.hitChance >= (VMenu.p.hE:Value()/100) then
				CastSkillShot(_E,EPred.castPos)
			end
		end		
		
		--R
		if Ready(_R) and VMenu.c.R:Value() and ValidTarget(unit, 1075) and EnemiesAround(GetOrigin(unit), 600) >= VMenu.c.RE:Value() then
			local RPred=GetPrediction(unit, VarusR)
			if RPred and RPred.hitChance >= (VMenu.p.hR:Value()/100) then
				CastSkillShot(_R,RPred.castPos)
			end
		end		
	end
end

OnUpdateBuff(function(unit,buffProc)
	if unit == myHero and buffProc.Name == "varusqlaunch" then 
		qCharge = true
		qTime = GetTickCount()
	elseif unit ~= myHero and buffProc.Name == "varuswdebuff" then
		wTrack[GetObjectName(unit)]=buffProc.Count
	end
end)

OnRemoveBuff(function(unit,buffProc)
	if unit == myHero and buffProc.Name == "varusqlaunch" then 
		qCharge = false
	elseif unit ~= myHero and buffProc.Name == "varuswdebuff" then
		wTrack[GetObjectName(unit)]=0
	end
end)

function ks()
	for i,unit in pairs(GetEnemyHeroes()) do
		
		--Smark KS
		if VMenu.ks.KSS:Value() and ValidTarget(unit, 1075) and Ready(_R) then
			if Ready(_Q) and VMenu.ks.KSQ:Value() and (GetCurrentHP(unit)+GetDmgShield(unit)) < CalcDamage(myHero, unit, GetCastLevel(myHero,_Q) * 50 - 40 + GetBonusDmg(unit) * 1.5 , GetCastLevel(myHero,_R) * 75 + 25 + GetBonusAP(unit) + 3 * GetMaxHP(unit) * ((1.25 + GetCastLevel(myHero,_W) * 0.75) + GetBonusAP(unit) * 0.02) *.01) and GetCurrentHP(unit)+GetDmgShield(unit) > CalcDamage(myHero, unit, GetCastLevel(myHero,_Q) * 50 - 40 + GetBonusDmg(unit) * 1.5,GetMaxHP(unit) * ((1.25 + GetCastLevel(myHero,_W) * 0.75) + GetBonusAP(unit) * 0.02) * .01* wTrack[GetObjectName(unit)]) then
				local RPred=GetPrediction(unit, VarusR)
				local VarusQ = { delay = 0.1, speed = 1850, width = 70, range = qRange }
				local QPred = GetPrediction(unit, VarusQ)
				if RPred and RPred.hitChance >= (VMenu.p.hR:Value()/100) and QPred and QPred.hitChance >= (VMenu.p.hQ:Value()/100) then
					CastSkillShot(_R,RPred.castPos)
					DelayAction( function()
						CastSkillShot(_Q,GetOrigin(myHero))	
							DelayAction( function()
								CastSkillShot2(_Q, GetOrigin(unit)) 
							end,50)
					end,50)
				end
			end
		end
	
		--Q1
		if VMenu.ks.KSQ:Value() and Ready(_Q) and ValidTarget(unit,1500) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, GetCastLevel(myHero,_Q) * 50 - 40 + GetBonusDmg(unit) * 1.5 ,0) + StackDamage(unit) then 
			if not qCharge then
				CastSkillShot(_Q,GetOrigin(myHero))	
		--Q2
			elseif qCharge then
				local VarusQ = { delay = 0.1, speed = 1850, width = 70, range = qRange }
				local QPred = GetPrediction(unit, VarusQ)
					if QPred and QPred.hitChance >= (VMenu.p.hQ:Value()/100) then
						CastSkillShot2(_Q, QPred.castPos)
					end
			end
		end
		
		--E
		if VMenu.ks.KSE:Value() and Ready(_E) and ValidTarget(unit,GetCastRange(myHero,_E)) and GetCurrentHP(unit)+GetDmgShield(unit) <  CalcDamage(myHero, unit, GetCastLevel(myHero,_E)*35+30+GetBonusDmg(unit)*.6 ,0) + StackDamage(unit) then 
			local EPred=GetCircularAOEPrediction(unit, VarusE)
			if EPred and EPred.hitChance >= (VMenu.p.hE:Value()/100) then
				CastSkillShot(_E,EPred.castPos)
			end
		end
		
		--R
		if VMenu.ks.KSR:Value() and Ready(_R) and ValidTarget(unit,1075) and GetCurrentHP(unit)+GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 ,GetCastLevel(myHero,_R)*75+25+GetBonusAP(unit)) then 
			local RPred=GetPrediction(unit, VarusR)
			if RPred and RPred.hitChance >= (VMenu.p.hR:Value()/100) then
				CastSkillShot(_R,RPred.castPos)
			end
		end
	end
end

function StackDamage(unit)
	if wTrack[GetObjectName(unit)] then
		local wDmg = GetMaxHP(unit)*((1.25+GetCastLevel(myHero,_W)*0.75)+GetBonusAP(unit)*0.02)*.01
		return CalcDamage(myHero, unit, 0, wDmg*wTrack[GetObjectName(unit)])
	else
		return 0
	end
end

PrintChat("Varus Loaded - Enjoy your game - Logge")
