if GetObjectName(GetMyHero()) ~= "Nasus" then return end

require("Inspired")
if not pcall( require, "OpenPredict" ) then PrintChat("This script doesn't work without OpenPredict! Download it!") return end

local version = 1

-- Menu
NMenu = Menu("Nasus", "Nasus")
NMenu:SubMenu("c", "Combo")
NMenu.c:Boolean("Q", "Use Q", true)
NMenu.c:Boolean("QP", "Use HP Pred for Q", true)
NMenu.c:Slider("QDM", "Q DMG mod", 0, -10, 10, 1)
NMenu.c:Boolean("W", "Use W", true)
NMenu.c:Slider("WHP", "Use W at %HP", 20, 1, 100, 1)
NMenu.c:Boolean("E", "Use E", true)
NMenu.c:Boolean("R", "Use R", true)
NMenu.c:Slider("RHP", "Use R at %HP", 20, 1, 100, 1)

NMenu:SubMenu("f", "Farm")
NMenu.f:Boolean("QLC", "Use Q in LaneClear", true)
NMenu.f:Boolean("QLH", "Use Q in LastHit", true)
NMenu.f:Boolean("QA", "Always use Q", true)

NMenu:SubMenu("ks", "Killsteal")
NMenu.ks:Boolean("KSQ","Killsteal with Q", true)
NMenu.ks:Boolean("KSE","Killsteal with E", true)

NMenu:SubMenu("d", "Draw Damage")
NMenu.d:Boolean("dD","Draw Damage", true)
NMenu.d:Boolean("dQ","Draw Q", true)
NMenu.d:Boolean("dE","Draw E", true)
NMenu.d:Boolean("dQM","Draw Q (Minions)", true)

NMenu:SubMenu("i", "Items")
NMenu.i:Boolean("iC","Use Items only in Combo", true)
NMenu.i:Boolean("iO","Use offensive Items", true)

NMenu:SubMenu("a", "AutoLvl")
NMenu.a:Boolean("aL", "Use AutoLvl", true)
NMenu.a:DropDown("aLS", "AutoLvL", 1, {"Q-W-E","Q-E-W"})
NMenu.a:Slider("sL", "Start AutoLvl with LvL x", 1, 1, 18, 1)
NMenu.a:Boolean("hL", "Humanize LvLUP", true)

NMenu:SubMenu("s","Skin")
NMenu.s:Boolean("uS", "Use Skin", false)
NMenu.s:Slider("sV", "Skin Number", 0, 0, 10, 1)

--Var
NasusE = { delay = 0.1, speed = math.huge, range = GetCastRange(myHero,_E), radius = 390}
cSkin = 0
Stacks = 0
local item = {3144,3142,3153}
--						 cutlassl 				 gb 			 bork 

--Lvlup table
lTable={
[1]={_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
[2]={_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}
}


-- Start
OnTick(function(myHero)
	if not IsDead(myHero) then
		qDmg = getQdmg()
		local unit = GetCurrentTarget()
		ks()
		combo(unit)
		farm()
		items(unit)
		lvlUp()
		skin()
	end
end)

OnDraw(function(myHero)
	for i,unit in pairs(GetEnemyHeroes()) do
		if ValidTarget(unit,2000) and NMenu.d.dD:Value() then
			local DmgDraw=0
			if Ready(_Q) and NMenu.d.dQ:Value() then
				DmgDraw = DmgDraw + getQdmg()
			end
			if Ready(_E) and NMenu.d.dE:Value() then
				DmgDraw = DmgDraw + CalcDamage(myHero, unit, 0, 15+40*GetCastLevel(myHero,_E)+GetBonusAP(myHero)*6)
			end
			if DmgDraw > GetCurrentHP(unit) then
				DmgDraw = GetCurrentHP(unit)
			end
			DrawDmgOverHpBar(unit,GetCurrentHP(unit),DmgDraw,0,0xffffffff)
		end
	end
	for _, creep in pairs(minionManager.objects) do
		if NMenu.d.dQM:Value() and ValidCreep(creep,1000) and GetHealthPrediction(creep, GetWindUp(myHero))<CalcDamage(myHero, creep, getQdmg(), 0) then
			DrawCircle(GetOrigin(creep),50,0,3,GoS.Red)
		end
	end
end)


--Functions

function combo(unit)

	if IOW:Mode() == "Combo" then
		--Q
		if NMenu.c.Q:Value() and Ready(_Q) and ValidTarget(unit, GetCastRange(myHero,_Q)) then
			CastSpell(_Q)
			AttackUnit(unit)
		end
		
		--W
		if Ready(_W) and NMenu.c.W:Value() and ValidTarget(unit, GetCastRange(myHero,_W)) and GetPercentHP(unit) < NMenu.c.WHP:Value() then
			CastTargetSpell(unit,_W)
		end		
		
		--E
		if Ready(_E) and NMenu.c.E:Value() and ValidTarget(unit, GetCastRange(myHero,_E)) then
			local EPred=GetCircularAOEPrediction(unit, NasusE)
			if EPred and EPred.hitChance >= 0.2 then
				CastSkillShot(_E,EPred.castPos)
			end
		end		
	end
	
	--R
	if Ready(_R) and NMenu.c.R:Value() and ValidTarget(unit, 1075) and GetPercentHP(myHero) < NMenu.c.RHP:Value() then
		CastSpell(_R)
	end		
end

function farm()
	if (Ready(_Q) or CanUseSpell(myHero,_Q) == 8) and ((NMenu.f.QLC:Value() and IOW:Mode() == "LaneClear") or (NMenu.f.QLH:Value() and IOW:Mode() == "LastHit") or (NMenu.f.QA:Value() and IOW:Mode() ~= "Combo")) then
		for _, creep in pairs(minionManager.objects) do
			if ValidCreep(creep,175) and GetCurrentHP(creep)<qDmg*2 and ((GetHealthPrediction(creep, GetWindUp(myHero))<CalcDamage(myHero, creep, qDmg, 0) and NMenu.c.QP:Value()) or (GetCurrentHP(creep)<CalcDamage(myHero, creep, qDmg, 0) and not NMenu.c.QP:Value())) then
				CastSpell(_Q)
				AttackUnit(creep)
				break
			end
		end
	end
end

function ks()
	for i,unit in pairs(GetEnemyHeroes()) do
		
		--Q
		if NMenu.ks.KSQ:Value() and Ready(_Q) and ValidTarget(unit, GetCastRange(myHero,_Q)) and GetCurrentHP(unit)+GetDmgShield(unit)+GetMagicShield(unit) < CalcDamage(myHero, unit, qDmg, 0) then
			CastSpell(_Q)
			AttackUnit(unit)
		end
		
		--E
		if NMenu.ks.KSE:Value() and Ready(_E) and ValidTarget(unit,GetCastRange(myHero,_E)) and GetCurrentHP(unit)+GetDmgShield(unit)+GetMagicShield(unit) <  CalcDamage(myHero, unit, 0, 15+40*GetCastLevel(myHero,_E)+GetBonusAP(myHero)*6) then 
			local NasusE=GetCircularAOEPrediction(unit, NasusE)
			if EPred and EPred.hitChance >= .2 then
				CastSkillShot(_E,EPred.castPos)
			end
		end
	end
end

function items(unit)
	if NMenu.i.iO:Value() and ValidTarget(unit,500) then
		if IOW:Mode() == "Combo" or not NMenu.i.iC:Value() then
			for _,i in pairs(item) do
				if GetItemSlot(myHero,i)>0 then
					CastTargetSpell(unit,GetItemSlot(myHero,i))
				end
			end
		end
	end
end

function getQdmg()
	local base = 10 + 20*GetCastLevel(myHero,_Q) + GetBaseDamage(myHero) + GetBuffData(myHero,"nasusqstacks").Stacks + NMenu.c.QDM:Value()
	if 		(Ready(GetItemSlot(myHero,3078))) and GetItemSlot(myHero,3078)>0 then base = base + GetBaseDamage(myHero)*2 
	elseif 	(Ready(GetItemSlot(myHero,3057))) and GetItemSlot(myHero,3057)>0 then base = base + GetBaseDamage(myHero)
	elseif 	(Ready(GetItemSlot(myHero,3057))) and GetItemSlot(myHero,3025)>0 then base = base + GetBaseDamage(myHero)*1.25 
	end
	return base
end

function lvlUp()
	if NMenu.a.aL:Value() and GetLevelPoints(myHero) >= 1 and GetLevel(myHero) >= NMenu.a.sL:Value() then
		if NMenu.a.hL:Value() then
			DelayAction(function() LevelSpell(lTable[NMenu.a.aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(500,750))
		else
			LevelSpell(lTable[NMenu.a.aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1])
		end
	end
end

function skin()
	if NMenu.s.uS:Value() and NMenu.s.sV:Value() ~= cSkin then
		HeroSkinChanger(GetMyHero(),NMenu.s.sV:Value()) 
		cSkin = NMenu.s.sV:Value()
	end
end

function ValidCreep(creep, range)
	if creep and not IsDead(creep) and GetTeam(creep) == MINION_ENEMY and IsTargetable(creep) and GetDistance(GetOrigin(myHero), GetOrigin(creep)) < range then
		return true
	else 
		return false
	end
end

--CALLBACKS
--thanks Noddy

PrintChat("Nasus Loaded - Enjoy your game - Logge")
