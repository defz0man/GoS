if GetObjectName(GetMyHero()) ~= "Karma" then return end

require("Inspired")
if not pcall( require, "OpenPredict" ) then PrintChat("This script doesn't work without OpenPredict! Download it!") return end

local version = 1
 

-- Menu
KMenu = Menu("Karma", "Karma")
KMenu:SubMenu("c", "Combo")
KMenu.c:Boolean("Q", "Use Q", true)
KMenu.c:Boolean("W", "Use W", true)
KMenu.c:Boolean("R", "Use R", true)
KMenu.c:Slider("rW", "R-W if lower than %HP", 10, 0, 100, 1)

KMenu:SubMenu("sh", "Shield")
KMenu.sh:Slider("sP", "Shield ally under %HP", 50, 0, 100, 1)
KMenu.sh:Boolean("sG", "Use shield as GapCloser", false)
KMenu.sh:Boolean("sT", "Shield Turretshot", true)
KMenu.sh:Boolean("sL", "Shield LowHealth", true)

eHeroes = {}
DelayAction( function()
	eHeroes["Karma"] = "s1"
	KMenu.sh:Boolean("s1", "Shield Yourself", true)
	for n,i in pairs(GetAllyHeroes()) do
		eHeroes[GetObjectName(i)] = "s"..n+1
		KMenu.sh:Boolean(eHeroes[GetObjectName(i)], "Shield "..GetObjectName(i).." ("..GetObjectBaseName(i)..")", true)
	end
end, .01)

KMenu:SubMenu("ks", "Killsteal")
KMenu.ks:Boolean("KSQ","Killsteal with Q", true)
KMenu.ks:Boolean("KSR","Killsteal with R", true)

KMenu:SubMenu("p", "Prediction")
KMenu.p:Slider("hQ", "HitChance Q", 20, 0, 100, 1)

KMenu:SubMenu("d", "Draw Damage")
KMenu.d:Boolean("dD","Draw Damage", true)
KMenu.d:Boolean("dQ","Draw Q", true)
KMenu.d:Boolean("dW","Draw W", true)
KMenu.d:Boolean("dR","Draw R Bonus", true)

KMenu:SubMenu("i", "Items")
KMenu.i:Boolean("iC","Use Items only in Combo", true)
KMenu.i:Boolean("iO","Use offensive Items", true)

KMenu:SubMenu("a", "AutoLvl")
KMenu.a:Boolean("aL", "Use AutoLvl", true)
KMenu.a:DropDown("aLS", "AutoLvL", 1, {"Q-W-E","Q-E-W"})
KMenu.a:Slider("sL", "Start AutoLvl with LvL x", 1, 1, 18, 1)
KMenu.a:Boolean("hL", "Humanize LvLUP", true)

KMenu:SubMenu("s","Skin")
KMenu.s:Boolean("uS", "Use Skin", false)
KMenu.s:Slider("sV", "Skin Number", 0, 0, 7, 1)

--Locals
local qRange = 950
local wRange = 675
local eRange = 800
local KarmaQ = { delay = 0.1, speed = 1700, width = 100, range = qRange}
local Move = { delay = 0.5, speed = math.huge, width = 50, range = math.huge}
local cSkin = 0
local item = {GetItemSlot(myHero,3092),GetItemSlot(myHero,3142),GetItemSlot(myHero,3153)}
--						 FrostQuell 				 gb 			 bork 

--Lvlup table
local lTable={
[1]={_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
[2]={_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}
}
--dmg table
local dmg={ 
["Q"] = 35 + 45*GetCastLevel(myHero,0) + GetBonusAP(myHero)*.6 , 
["Q2"] = 10 + 45*GetCastLevel(myHero,0) + 50*GetCastLevel(myHero,3) + GetBonusAP(myHero)*.9 ,
["Q3"] = -50 + 100*GetCastLevel(myHero,3) + GetBonusAP(myHero)*.6,
["W"] = 10 + 50*GetCastLevel(myHero,1) + GetBonusAP(myHero)*.9
}

-- Start
OnTick(function(myHero)
	if not IsDead(myHero) then
		local unit = GetCurrentTarget()
		ks()
		combo(unit)
		shield()
		items(unit)
		lvlUp()
		skin()
	end
end)

OnDraw(function(myHero)
	local qRdy = Ready(_Q)
	local wRdy = Ready(_W)
	local rRdy = Ready(_R)
	for i,unit in pairs(GetEnemyHeroes()) do
		if ValidTarget(unit,2000) and KMenu.d.dD:Value() then
			local DmgDraw=0
			if rRdy and qRdy and KMenu.d.dQ:Value() and KMenu.d.dR:Value() then
				DmgDraw = dmg.Q2
			elseif qRdy and KMenu.d.dQ:Value() then
				DmgDraw = dmg.Q
			end
			if wRdy and KMenu.d.dW:Value() then
				DmgDraw = DmgDraw + dmg.W
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
		local qRdy = Ready(_Q)
		local wRdy = Ready(_W)
		local rRdy = Ready(_R)
		--W
		if KMenu.c.W:Value() and wRdy and ValidTarget(unit, wRange) then
			if rRdy and GetPercentHP(myHero) < KMenu.c.rW:Value() then
				CastSpell(3)
				DelayAction( function() CastTargetSpell(unit,1) end,0.01)
			else
				CastTargetSpell(unit,1)			
			end
		end
		
		--RQ
		if KMenu.c.Q:Value() and KMenu.c.R:Value() and qRdy and rRdy and ValidTarget(unit, qRange) then
			local QPred = GetPrediction(unit, KarmaQ)
			if QPred and QPred.hitChance >= (KMenu.p.hQ:Value()/100) and not QPred:mCollision(1) then
				CastSpell(3)
				DelayAction( function() CastSkillShot(_Q, QPred.castPos) end, .01)
			end
		end
		
		--Q
		if KMenu.c.Q:Value() and qRdy and ValidTarget(unit, qRange) then
			local QPred = GetPrediction(unit, KarmaQ)
			
			if QPred and QPred.hitChance >= (KMenu.p.hQ:Value()/100) and not QPred:mCollision(1) then
				CastSkillShot(_Q, QPred.castPos)
			end
		end	
	end
end

function shield()
	for _,i in pairs(GetAllyHeroes()) do
		local movePos = GetPrediction(i, Move).castPos
		local ePos = GetOrigin(ClosestEnemy(GetOrigin(i)))
		if IOW:Mode() == "Combo" and KMenu.sh.sG:Value() and KMenu.sh[eHeroes[GetObjectName(i)]]:Value() and GetDistance(ePos,GetOrigin(i))>GetDistance(ePos,movePos) and GetDistance(GetOrigin(myHero),GetOrigin(i))< eRange then
			CastTargetSpell(i,2)
		end
	end
	local movePos = GetPrediction(myHero, Move).castPos
	local ePos = GetOrigin(ClosestEnemy(GetOrigin(myHero)))
	if IOW:Mode() == "Combo" and KMenu.sh.sG:Value() and KMenu.sh[eHeroes[GetObjectName(myHero)]]:Value() and GetDistance(ePos,GetOrigin(myHero))>GetDistance(ePos,movePos) then
			CastTargetSpell(myHero,2)
	end
end

function ks()
	local qRdy = Ready(_Q)
	local rRdy = Ready(_R)
	for i,unit in pairs(GetEnemyHeroes()) do
		--Q
		local QPred = GetPrediction(unit, KarmaQ)
		if KMenu.ks.KSQ:Value() and qRdy and ValidTarget(unit,qRange) and QPred and QPred.hitChance >= (KMenu.p.hQ:Value()/100) and not QPred:mCollision(1) then
			if GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 ,dmg.Q) then
				CastSkillShot(0, QPred.castPos)				
			elseif rRy and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 , dmg.Q2) then
				CastSpell(3)
				DelayAction(function() CastSkillShot(0,QPred.castPos) end,0.01)
			end
		end
	end
end

function items(unit)
	if KMenu.i.iO:Value() and ValidTarget(unit,700) then
		if IOW:Mode() == "Combo" or not KMenu.i.iC:Value() then
			for _,i in pairs(item) do
				if i>0 then
					CastTargetSpell(unit,i)
				end
			end
		end
	end
end

function lvlUp()
	if KMenu.a.aL:Value() and GetLevelPoints(myHero) >= 1 and GetLevel(myHero) >= KMenu.a.sL:Value() then
		if KMenu.a.hL:Value() then
			DelayAction(function() LevelSpell(lTable[KMenu.a.aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(0.500,0.750))
		else
			LevelSpell(lTable[KMenu.a.aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1])
		end
	end
end

function skin()
	if KMenu.s.uS:Value() and KMenu.s.sV:Value() ~= cSkin then
		HeroSkinChanger(GetMyHero(),KMenu.s.sV:Value()) 
		cSkin = KMenu.s.sV:Value()
	end
end

--CALLBACKS
OnProcessSpell(function(unit,spellProc)
	if Ready(2) and KMenu.sh.sT:Value() and GetObjectType(unit) == Obj_AI_Turret and GetDistance(GetOrigin(spellProc.target),GetOrigin(myHero))<eRange and GetObjectType(spellProc.target) == Obj_AI_Hero and GetTeam(spellProc.target) == MINION_ALLY and GetPercentHP(spellProc.target)<= KMenu.sh.sP:Value() and KMenu.sh[eHeroes[GetObjectName(spellProc.target)]]:Value() then
		CastTargetSpell(spellProc.target,2)
	end
end)

PrintChat("Karma Loaded - Enjoy your game - Logge")
