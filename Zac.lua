if GetObjectName(GetMyHero()) ~= "Zac" then return end

require("Inspired")
if not pcall( require, "OpenPredict" ) then PrintChat("This script doesn't work without OpenPredict! Download it!") return end

local version = 1

-- Menu
ZMenu = Menu("Zac", "Zac")
ZMenu:SubMenu("c", "Combo")
ZMenu.c:Slider("pB", "Pick up blobs (range)", 200, 100, 500, 1)
ZMenu.c:Boolean("dR", "Draw Pickup range", true)
ZMenu.c:Boolean("Q", "Use Q", true)
ZMenu.c:Boolean("W", "Use W", true)
ZMenu.c:Boolean("aW", "Auto use W", false)
ZMenu.c:Boolean("E", "Use E", true)
ZMenu.c:Boolean("R", "Use R", true)
--ZMenu.c:Slider("aR", "Auto R if x enemys", 3, 1, 5, 1)


ZMenu:SubMenu("ks", "Killsteal")
ZMenu.ks:Boolean("KSQ","Killsteal with Q", true)
ZMenu.ks:Boolean("KSW","Killsteal with W", true)
ZMenu.ks:Boolean("KSR","Killsteal with R", true)

ZMenu:SubMenu("p", "Prediction")
ZMenu.p:Slider("hQ", "HitChance Q", 20, 0, 100, 1)
ZMenu.p:Slider("hE", "HitChance E", 20, 0, 100, 1)

ZMenu:SubMenu("d", "Draw Damage")
ZMenu.d:Info("dD","Use Paint.lua instead")

ZMenu:SubMenu("i", "Items")
ZMenu.i:Boolean("iC","Use Items only in Combo", true)
ZMenu.i:Boolean("iO","Use defensive Items", true)

ZMenu:SubMenu("a", "AutoLvl")
ZMenu.a:Boolean("aL", "Use AutoLvl", true)
ZMenu.a:DropDown("aLS", "AutoLvL", 1, {"E-Q-W","Q-W-E","Q-E-W"})
ZMenu.a:Slider("sL", "Start AutoLvl with LvL x", 1, 1, 18, 1)
ZMenu.a:Boolean("hL", "Humanize LvLUP", true)

ZMenu:SubMenu("s","Skin")
ZMenu.s:Boolean("uS", "Use Skin", false)
ZMenu.s:Slider("sV", "Skin Number", 0, 0, 7, 1)

--Locals
eTime = 0
eCharge = false
local blobb={}
local qRange = 550 + GetHitBox(myHero)*.5
local wRange = 350 + GetHitBox(myHero)*.5
local rRAnge = 300 + GetHitBox(myHero)*.5
local ZacQ = { delay = 0.3, speed = math.huge , width = 100, range = qRange}
local Move = { delay = 0.5, speed = math.huge, width = 50, range = math.huge}
local cSkin = 0
local item = {3143,3748,3146}
--						 Rand 				 hydra Kappa 				 gb 

--Lvlup table
local lTable={
[1]={_Q,_W,_E,_Q,_Q,_R,_Q,_Q,_W,_E,_R,_W,_E,_W,_E,_R,_W,_E},
[2]={_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
[3]={_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}
}

-- Start
OnTick(function(myHero)
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
	if not IsDead(myHero) and ZMenu.c.dR:Value() and GetDistance(GetMousePos(),GetOrigin(myHero))<1500 then
		DrawCircle(GetMousePos(),ZMenu.c.pB:Value(),0,3,GoS.White)
	end
end)	


--Functions

function combo(unit)
	local qRdy = Ready(0)
	local wRdy = Ready(1)
	local eRdy = Ready(2)
	local rRdy = Ready(3)
	
	--Auto W
	if ZMenu.c.aW:Value() and wRdy and ValidTarget(unit, wRange) then
		CastSpell(1)
	end
	
	--[[Auto R
	if ZMenu.c.R:Value() and rRdy and EnemiesAround(GetOrigin(myHero), 300 + GetHitBox(myHero)*.5) >= ZMenu.c.aR:Value() then
		CastSpell(3)
	end--]]


	if IOW:Mode() == "Combo" then
		
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
		if ZMenu.c.E:Value() and not eCharge and eRdy and ValidTarget(unit, 1050 + GetCastLevel(myHero,2)*130) then
			local ZacE = { delay = 0.1, speed = 750, range = eRange(), radius = 300}
			local EPred=GetCircularAOEPrediction(unit, ZacE)
			if GetDistance(EPred.castPos,GetOrigin(unit)) < 1050 + GetCastLevel(myHero,2) * 150 then
				CastSkillShot(2,GetOrigin(unit))
			end
		elseif eCharge and ZMenu.c.E:Value() then
			local ZacE = { delay = 0.1, speed = 1700, range = eRange(), radius = 300}
			local EPred=GetCircularAOEPrediction(unit, ZacE)
			if EPred and EPred.hitChance >= (ZMenu.p.hE:Value()/100) then
				CastSkillShot2(2,EPred.castPos)
			end
		end	
		
		local cB = nil
		local lDist = math.huge
		for _,i in pairs(blobb) do
			if GetDistance(GetMousePos(),GetOrigin(blobb)) then
				cB = i
			end
		end
		if cB and GetDistance(GetOrigin(cB),GetOrigin(myHero)) < ZMenu.c.pB:Value() then
			IOW.forcePos = GetOrigin(cB)
		else
			IOW.forcePos = false
		end
		
	end
end

function eRange()
	local maxRange = 1050 + GetCastLevel(myHero,2) * 150 
	local mt = 750 + GetCastLevel(myHero,2) * 150
	local currentRange = maxRange * ((GetTickCount()- eTime)/mt)
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
		if ZMenu.ks.KSW:Value() and wRdy and ValidTarget(unit,wRange) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 ,dmgCalc(1,unit)) then
			CastSpell(1)
		end
		
		--Q
		local QPred = GetPrediction(unit, ZacQ)
		if ZMenu.ks.KSQ:Value() and qRdy and ValidTarget(unit,qRange) and QPred and QPred.hitChance >= (ZMenu.p.hQ:Value()/100) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 ,dmgCalc(0,unit)) then
			CastSkillShot(0, QPred.castPos)				
		end
		
		--R
		if ZMenu.ks.KSR:Value() and rRdy and ValidTarget(unit,rRange) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 ,dmgCalc(3,unit)) then
			CastSpell(3)
		end
	end
end

function items(unit)
	if ZMenu.i.iO:Value() and ValidTarget(unit,500) then
		if IOW:Mode() == "Combo" or not ZMenu.i.iC:Value() then
			for _,i in pairs(item) do
				if GetItemSlot(myHero,i)>0 and Ready(GetItemSlot(myHero,i)) then
					CastTargetSpell(unit,GetItemSlot(myHero,i))
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

--dmg table
function dmgCalc(spell,unit)
	local dmg={ 
	[0] = 30 + 40*GetCastLevel(myHero,0) + GetBonusAP(myHero)*.5 , 
	[1] = 25 + 15*GetCastLevel(myHero,1) + GetMaxHP(unit)*(.03*GetCastLevel(myHero,1)+GetBonusAP(myHero)*.02) ,
	[2] = 30 + 50*GetCastLevel(myHero,2) + GetBonusAP(myHero)*.7 , 
	[3] = 70 + 70*GetCastLevel(myHero,3) + GetBonusAP(myHero)*.4 
	}
	return dmg[spell]
end

--CALLBACKS
OnProcessSpell(function(unit,spellProc)

end)

OnCreateObj(function(Object,myHero)
	if GetObjectBaseName(Object) == "Zac_Base_P_Chunk.troy" then
	blobb[Object]=Object
	end
end)

OnDeleteObj(function(Object,myHero)
	if GetObjectBaseName(Object) == "Zac_Base_P_Chunk.troy" then
	blobb[Object]=nil
	end
end)

OnUpdateBuff(function(unit,buffProc)
	if unit == myHero and buffProc.Name:lower() == "zace" then
		eCharge = true
		eTime = GetTickCount()
		IOW.movementEnabled = false
		IOW.attacksEnabled = false
	end
end)

OnRemoveBuff(function(unit,buffProc)
	if unit == myHero and buffProc.Name:lower() == "zace" then
		eCharge = false
		IOW.movementEnabled = true
		IOW.attacksEnabled = true
	end
end)

PrintChat("Zac Loaded - Enjoy your game - Logge")
