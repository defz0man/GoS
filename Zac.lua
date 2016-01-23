if GetObjectName(GetMyHero()) ~= "Zac" then return end

require("Inspired")
if not pcall( require, "OpenPredict" ) then PrintChat("This script doesn't work without OpenPredict! Download it!") return end

local version = 1
 

-- Menu
ZMenu = Menu("Zac", "Zac")
ZMenu:SubMenu("c", "Combo")
ZMenu.c:Boolean("Q", "Use Q", true)
ZMenu.c:Boolean("W", "Use W", true)
ZMenu.c:Boolean("E", "Use E", true)
ZMenu.c:Slider("rE", "E range (cursor)", 300, 100, 500, 1)
ZMenu.c:Boolean("R", "Use R", true)


ZMenu:SubMenu("ks", "Killsteal")
ZMenu.ks:Boolean("KSQ","Killsteal with Q", true)
ZMenu.ks:Boolean("KSW","Killsteal with W", true)
ZMenu.ks:Boolean("KSR","Killsteal with R", true)

ZMenu:SubMenu("p", "Prediction")
ZMenu.p:Slider("hQ", "HitChance Q", 20, 0, 100, 1)
ZMenu.p:Slider("hE", "HitChance E", 20, 0, 100, 1)

ZMenu:SubMenu("d", "Draw Damage")
ZMenu.d:Boolean("dD","Draw Damage", true)
ZMenu.d:Boolean("dQ","Draw Q", true)
ZMenu.d:Boolean("dW","Draw W", true)
ZMenu.d:Boolean("dE","Draw E", true)
ZMenu.d:Boolean("dR","Draw R", true)

ZMenu:SubMenu("i", "Items")
ZMenu.i:Boolean("iC","Use Items only in Combo", true)
ZMenu.i:Boolean("iO","Use defensive Items", true)

ZMenu:SubMenu("a", "AutoLvl")
ZMenu.a:Boolean("aL", "Use AutoLvl", true)
ZMenu.a:DropDown("aLS", "AutoLvL", 1, {"Q-W-E","Q-E-W"})
ZMenu.a:Slider("sL", "Start AutoLvl with LvL x", 1, 1, 18, 1)
ZMenu.a:Boolean("hL", "Humanize LvLUP", true)

ZMenu:SubMenu("s","Skin")
ZMenu.s:Boolean("uS", "Use Skin", false)
ZMenu.s:Slider("sV", "Skin Number", 0, 0, 7, 1)

--Locals
eTime = 0
eCharge = false
local qRange = 550 + GetHitBox(myHero)/2
local wRange = 350 + GetHitBox(myHero)/2
local rRAnge = 300 + GetHitBox(myHero)/2
local ZacQ = { delay = 0.3, speed = math.huge , width = 100, range = qRange}
local Move = { delay = 0.5, speed = math.huge, width = 50, range = math.huge}
local cSkin = 0
local item = {GetItemSlot(myHero,3143),GetItemSlot(myHero,3748),GetItemSlot(myHero,3146)}
--						 Rand 				 hydra Kappa 				 gb 

--Lvlup table
local lTable={
[1]={_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
[2]={_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W},
[3]={_Q,_W,_E,_Q,_Q,_R,_Q,_Q,_W,_E,_R,_W,_E,_W,_E,_R,_W,_E}
}

--dmg table
local dmg={ 
[0] = 30 + 40*GetCastLevel(myHero,0) + GetBonusAP(myHero)*.5 , 
[1] = 25 + 15*GetCastLevel(myHero,1) + GetMaxHP(GetCurrentTarget())*(.03*GetCastLevel(myHero,1)+GetBonusAP(myHero)*.02) ,
[2] = 30 + 50*GetCastLevel(myHero,2) + GetBonusAP(myHero)*.7 , 
[3] = 70 + 70*GetCastLevel(myHero,3) + GetBonusAP(myHero)*.4 
}

-- Start
OnTick(function(myHero)
	DrawCircle(GetOrigin(myHero),eRange(),0,3,GoS.White)
	if not IsDead(myHero) then
		local unit = GetCurrentTarget()
		ks()
		combo(unit)
		items(unit)
		lvlUp()
		skin()
	end
end)

OnDraw(function(myHero)
	local qRdy = Ready(_Q)
	local wRdy = Ready(_W)
	local eRdy = Ready(_E)
	local rRdy = Ready(_R)
	for i,unit in pairs(GetEnemyHeroes()) do
		if ValidTarget(unit,2000) and ZMenu.d.dD:Value() then
			local DmgDraw=0
			if qRdy and ZMenu.d.dQ:Value() then
				DmgDraw = dmg.Q
			end
			if wRdy and ZMenu.d.dW:Value() then
				DmgDraw = DmgDraw + dmg.W
			end
			if wRdy and ZMenu.d.dE:Value() then
				DmgDraw = DmgDraw + dmg.E
			end
			if wRdy and ZMenu.d.dR:Value() then
				DmgDraw = DmgDraw + dmg.R
			end
			DmgDraw = CalcDamage(myHero, unit, 0, DmgDraw)
			if DmgDraw > GetCurrentHP(unit) then
				DmgDraw = GetCurrentHP(unit)
			end
			DrawDmgOverHpBar(unit,GetCurrentHP(unit),0,DmgDraw,0xffffffff)
		end
	end
end)


--Functions

function combo(unit)

	if IOW:Mode() == "Combo" then
		local qRdy = Ready(0)
		local wRdy = Ready(1)
		local eRdy = Ready(2)
		local rRdy = Ready(3)
		
		--Q
		if ZMenu.c.Q:Value() and qRdy and ValidTarget(unit, qRange) then
			local QPred = GetPrediction(unit, ZacQ)
			if QPred and QPred.hitChance >= (ZMenu.p.hQ:Value()/100) then
				CastSkillShot(0,QPred.castPos)
			end
		end
		
		--W
		if ZMenu.c.W:Value() and wRdy and ValidTarget(unit, wRange) then
			CastSpell(1)
		end
		
		--E
		if ZMenu.c.E:Value() and not eCharge and eRdy and ValidTarget(unit, 1050 + GetCastLevel(myHero,2)*150) then
			CastSkillShot(2,GetOrigin(unit))
		elseif eCharge and ZMenu.c.E:Value() then
			local ZacE = { delay = 0.1, speed = 1700, range = eRange(), radius = 300}
			local EPred=GetCircularAOEPrediction(unit, ZacE)
			if EPred and EPred.hitChance >= (ZMenu.p.hE:Value()/100) then
				CastSkillShot(2,EPred.castPos)
			end
		end	
	end
end

function eRange()
	local maxRange = 1050 + GetCastLevel(myHero,2) * 150 
	local mt = 750 + GetCastLevel(myHero,2) * 150
	local currentRange = (maxRange) * ((GetTickCount()- eTime)/mt)
	if currentRange > maxRange then
		currentRange = maxRange
	end
	return currentRange
end

function ks()
	local qRdy = Ready(_Q)
	local wRdy = Ready(_W)
	local rRdy = Ready(_R)
	for i,unit in pairs(GetEnemyHeroes()) do
		
		--W
		if ZMenu.ks.KSW:Value() and wRdy and ValidTarget(unit,wRange) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 ,dmg.W) then
			CastSpell(1)
		end
		
		--Q
		local QPred = GetPrediction(unit, ZacQ)
		if ZMenu.ks.KSQ:Value() and qRdy and ValidTarget(unit,qRange) and QPred and QPred.hitChance >= (ZMenu.p.hQ:Value()/100) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 ,dmg.Q) then
			CastSkillShot(0, QPred.castPos)				
		end
		
		--R
		if ZMenu.ks.KSR:Value() and rRdy and ValidTarget(unit,rRange) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 ,dmg.R) then
			CastSpell(3)
		end
	end
end

function items(unit)
	if ZMenu.i.iO:Value() and ValidTarget(unit,500) then
		if IOW:Mode() == "Combo" or not ZMenu.i.iC:Value() then
			for _,i in pairs(item) do
				if i>0 then
					CastTargetSpell(unit,i)
				end
			end
		end
	end
end

function lvlUp()
	if ZMenu.a.aL:Value() and GetLevelPoints(myHero) >= 1 and GetLevel(myHero) >= ZMenu.a.sL:Value() then
		if ZMenu.a.hL:Value() then
			DelayAction(function() LevelSpell(lTable[ZMenu.a.aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(0.500,0.750))
		else
			LevelSpell(lTable[ZMenu.a.aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1])
		end
	end
end

function skin()
	if ZMenu.s.uS:Value() and ZMenu.s.sV:Value() ~= cSkin then
		HeroSkinChanger(GetMyHero(),ZMenu.s.sV:Value()) 
		cSkin = ZMenu.s.sV:Value()
	end
end

--CALLBACKS
OnProcessSpell(function(unit,spellProc)

end)

OnUpdateBuff(function(unit,buffProc)
	if unit == myHero and buffProc.Name == "ZacE" then
		print("E spell")
		eCharge = true
		eTime = GetTickCount()
		IOW.movementEnabled = false
		IOW.attacksEnabled = false
	end
end)

OnRemoveBuff(function(unit,buffProc)
	if unit == myHero and buffProc.Name == "ZacE" then
		print("E end")
		eCharge = false
		IOW.movementEnabled = true
		IOW.attacksEnabled = true
	end
end)

PrintChat("Zac Loaded - Enjoy your game - Logge")
