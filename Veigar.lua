if GetObjectName(GetMyHero()) ~= "Veigar" then return end

require("OpenPredict")

local VMenu = Menu("Veigar", "Veigar")
VMenu:SubMenu("c", "Combo")
VMenu.c:Boolean("Q", "Use Q", true)
VMenu.c:Boolean("W", "Use W", true)
VMenu.c:Boolean("AW", "Auto W on immobile", true)
VMenu.c:Boolean("E", "Use E", true)
VMenu.c:Boolean("R", "Use R", true)
VMenu.c:Boolean("AR", "Auto use R", true)

VMenu:SubMenu("p", "Prediction")
VMenu.p:Slider("hQ", "HitChance Q", 20, 0, 100, 1)
VMenu.p:Slider("hW", "HitChance W", 20, 0, 100, 1)
VMenu.p:Slider("hE", "HitChance E", 20, 0, 100, 1)

VMenu:SubMenu("f", "Farm")
VMenu.f:Boolean("AQ", "Auto Q farm", true)

VMenu:SubMenu("m", "Misc")
VMenu.m:Boolean("D" , "Enable Drawings", true)


local myHero=GetMyHero()
local RDmg = 0 
local VeigarQ = { delay = 0.1, speed = 2000, width = 100, range = 950}
local VeigarW = { delay = 0.1, speed = math.huge, range = 900 , radius = 225}
local VeigarE = { delay = 0.6, speed = math.huge, range = 725 , radius = 400}
local Move = { delay = 0.1, speed = math.huge, width = 50, range = math.huge}



OnTick(function (myHero)
	if not IsDead(myHero) then
	local unit=GetCurrentTarget()
		KS()
		AutoW(unit)
		Combo(unit)
		FarmQ()
	end
end)

OnDraw(function (myHero)
	local unit=GetCurrentTarget()
	if Ready(_R) and ValidTarget(unit,1500) and VMenu.m.D:Value() then
		DrawDmgOverHpBar(unit,GetCurrentHP(unit),0,RDmg,0xffffffff)
	end
end)

function Combo(unit)
	if IOW:Mode() == "Combo" then
			
		if VMenu.c.R:Value() and Ready(3) and ValidTarget(unit, 650) then
			local RPercent=GetCurrentHP(unit)/CalcDamage(myHero, unit, 0, (125*GetCastLevel(myHero,_R)+GetBonusAP(myHero)+125+GetBonusAP(unit)*0.8))
			if RPercent<1 and RPercent>0.2 then 
				CastTargetSpell(unit,_R)
			end
		end	
	
		if VMenu.c.Q:Value() and Ready(0) and ValidTarget(unit, GetCastRange(myHero,_Q)+10) then
			local QPred = GetPrediction(unit,VeigarQ)
			if QPred.hitChance >= (VMenu.p.hQ:Value()/100) and (not QPred:mCollision() or #QPred:mCollision() < 2) then				
				CastSkillShot(_Q,QPred.castPos)
			end
		end	
		
		if VMenu.c.W:Value() and CanUseSpell(myHero,_W) == READY and ValidTarget(unit, GetCastRange(myHero,_W)) then
			local WPred = GetCircularAOEPrediction(unit, VeigarW)
			if WPred.hitChance >= (VMenu.p.hW:Value()/100) then				
				CastSkillShot(_W,WPred.castPos)
			end
		end	
		castE(unit)
	end
end

function KS()
	for _,unit in pairs(GetEnemyHeroes()) do
		if VMenu.c.AR:Value() and Ready(3) and ValidTarget(unit, 650) then
			local RPercent=GetCurrentHP(unit)/CalcDamage(myHero, unit, 0, (125*GetCastLevel(myHero,_R)+GetBonusAP(myHero)+125+GetBonusAP(unit)*0.8))
			if RPercent<1 and RPercent>0.2 then 
				CastTargetSpell(unit,_R)
			end
		end	
		if VMenu.m.D:Value() and Ready(3) and ValidTarget(unit,1000) then
			RDmg = CalcDamage(myHero, unit, 0, (75*GetCastLevel(myHero,_R) + 100)*math.max((100-GetPercentHP(unit))*1.5,200)*.01)
			if RDmg>=GetCurrentHP(unit) then
				RDmg=GetCurrentHP(unit)
			end
		end
	end
end

function AutoW(unit)
	if VMenu.c.AW:Value() and ValidTarget(unit,GetCastRange(myHero,_W)) and GotBuff(unit, "veigareventhorizonstun") > 0 and (GotBuff(unit, "snare") > 0 or GotBuff(unit, "taunt") > 0 or GotBuff(unit, "suppression") > 0 or GotBuff(unit, "stun")) then
	local WPred = GetCircularAOEPrediction(unit, VeigarW)
		if WPred.hitChance >= (VMenu.p.hW:Value()/100) then			
			CastSkillShot(_W,WPred.castPos)
		end
	end
end

function castE(unit)
	if VMenu.c.E:Value() and Ready(2) and ValidTarget(unit, 725) then
		local EPred = GetCircularAOEPrediction(unit, VeigarE)
		local EMove = GetPrediction(unit, Move)
		if GetDistance(EMove.castPos , GetOrigin(myHero)) < GetDistance(GetOrigin(unit),GetOrigin(myHero)) then
			EPred.castPos = Vector(EPred.castPos)+((Vector(EPred.castPos)-GetOrigin(myHero)):normalized()*325)
		else
			EPred.castPos = Vector(EPred.castPos)+((GetOrigin(myHero)-Vector(EPred.castPos)):normalized()*325)
		end
		CastSkillShot(_E,EPred.castPos)
	end
end


function FarmQ()
	if VMenu.f.AQ:Value() and Ready(_Q) and IOW:Mode() ~= "Combo" then
		for i,creep in pairs(minionManager.objects) do
			if GetTeam(creep) ~= MINION_ALLY and ValidTarget(creep,1000) and GetCurrentHP(creep)<CalcDamage(myHero, creep, 0, (40*GetCastLevel(myHero,_Q)+25+GetBonusAP(myHero)*0.6)) then
				if VMenu.m.D:Value() then DrawCircle(GetOrigin(creep),75,0,3,0xffffff00) end
				local QPred = GetPrediction(creep,VeigarQ)			
				if not QPred:mCollision() or #QPred:mCollision() < 2 then
					CastSkillShot(_Q,QPred.castPos)
				end
			end
		end
	end
end

print("Veigar injected")
