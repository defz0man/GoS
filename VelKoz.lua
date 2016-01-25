if GetObjectName(GetMyHero()) ~= "Velkoz" then return end

require("Inspired")
require("OpenPredict")

LoadIOW()

local VelM = Menu("Vel","Vel")
VelM:SubMenu("c", "Combo")
VelM.c:Boolean("Q","Use Q",true)
VelM.c:Boolean("FQ","Force Q Split",true)
VelM.c:Boolean("W","Use W",true)
VelM.c:Boolean("E","Use E",true)

VelM:SubMenu("p", "Prediction")
VelM.p:Slider("hQ", "HitChance Q", 20, 0, 100, 1)
VelM.p:Slider("hE", "HitChance E", 20, 0, 100, 1)
VelM.p:Slider("hR", "HitChance R", 20, 0, 100, 1)

VelM:SubMenu("a", "Advanced")
VelM.a:Slider("eQ", "Extra Q", 5 , 1, 20, 1)

--velkozqsplitactive
--VelkozQ
value=4 --get value from silder
DegreeTable={22.5,-22.5,45,-45}
local rCast = false


VelQ = { delay = 0.1, speed = 1300, width = 75, range = 750}
VelQ2 ={ delay = 0.1, speed = 1300, width = 75, range = 1000}
VelW = { delay = 0.1, speed = 1700, width = 75, range = 1050}
VelE = { delay = 0.1, speed = 1700, range = 850, radius = 200 }
ccTrack={}
for _,i in pairs(GetEnemyHeroes()) do
	ccTrack[GetObjectName(i)] = false
end


OnTick(function(myHero)
	local unit = GetCurrentTarget()
	if not IsDead(myHero) and not rCast then
		Combo(unit)
end)




function Combo(unit)
	for _,i in pairs(GetEnemyHeroes()) do
		if VelM.c.Q:Value() and GetCastName(myHero,_Q)=="VelkozQ" and ValidTarget(i,1400) and IOW:Mode() == "Combo"  then
			local direct=GetPrediction(i,VelQ)
		
			if direct and direct.hitChance>.25 and not direct:mCollision(1) then
				QStart=GetOrigin(myHero)
				CastSkillShot(_Q,direct.castPos)
			end
				
			--Base Vector
			local BVec = Vector(GetOrigin(i)) - Vector(GetOrigin(myHero))
			local dist = math.sqrt(GetDistance(GetOrigin(myHero),GetOrigin(i))^2/2)
			for l=1,value do
			
				--Degree Vector from table
				local sideVec=getVec(BVec,DegreeTable[l]):normalized()*dist
				--DrawCircle(sideVec+GetOrigin(myHero) ,50,0,3,GoS.Green)
				
				local circlespot = sideVec+GetOrigin(myHero)
				local QPred = GetPrediction(i, VelQ2, circlespot)
				--print(DegreeTable[l]..":"..sideVec.x)
				
				--Part on the range around enemy
				--DrawCircle(circlespot,50,0,3,GoS.Red)
				--print(CountObjectsOnLineSegment(GetOrigin(myHero), circlespot, 70, enemyCreeps)<1)
				if not QPred:mCollision(1) then
						
					--ShootQ at predcited Pos
					CastSkillShot(_Q,circlespot)
						
					--GetStartingPos
					QStart=GetOrigin(myHero)
				end
			end
		end	
		
		--if q traveling
		if GetCastName(myHero,_Q)~="VelkozQ" and ValidTarget(i,2000) then
			local split=GetPrediction(i, VelQ2, GetOrigin(QBall))
			if ((Vector(GetOrigin(QBall))-Vector(QStart)):normalized()*(Vector(GetOrigin(QBall))-Vector(split.castPos)):normalized())^2 < VelM.a.eQ:Value()/1000 then
				CastSpell(_Q)
			end
		end
	end
	
	if IOW:Mode() == "Combo" then		
		if VelM.c.W:Value() and Ready(_W) and ValidTarget(unit,1050) then
			local WPred = GetPrediction(unit, VelW)
			CastSkillShot(_W,WPred.castPos)
		end
			
		if VelM.c.E:Value() and Ready(_E) and ValidTarget(unit,850) then
			local EPred = GetCircularAOEPrediction(unit, VelE)
			CastSkillShot(_E,EPred.castPos)
		end
		
		if ValidTarget(unit,GetCastRange(myHero,_R)*.8) and Ready(_R) and EnemiesAround(GetOrigin(myHero),400) == 0 then
			if GetDistance(GetOrigin(myHero),GetOrigin(enemy)) then
				local RTick = 30 + 20 * GetCastLevel(myHero,_R) + GetBonusAP(myHero) * .06
				local Passive = 25 + 10 * GetLevel(myHero)
				local ticks = (GetCastRange(myHero,_R) - GetDistance(GetOrigin(unit),GetOrigin(myHero))) / (GetMoveSpeed(unit)*.8)
				if ccTrack[GetObjectName(unit)] and rTime > GetGameTimer() then ticks = ticks + (rTime - GetGameTimer())*4 end
				DrawDmgOverHpBar(unit, GetCurrentHP(unit), CalcDamage(myHero, unit, 0, RTick * ticks) + Passive * 0.6, 0, GoS.White)
				if GetCurrentHP(unit) < CalcDamage(myHero, unit, 0, RTick * ticks * 4) + Passive * 0.6 then
					CastSkillShot(_R, GetOrigin(unit))
				end
			end
		end
	end	
end

OnProcessSpell(function(unit,spellProc)
	if unit==myHero and spellProc.name == "VelkozQ" then
		QStart=spellProc.startPos
	end
end)


OnCreateObj(function(Object,myHero)
	if GetObjectBaseName(Object)=="Velkoz_Base_Q_mis.troy" then
		QBall=Object
	end
end)

function getVec(base, deg)
	local x,y,z=base:unpack()
	x=x*math.cos(degrad(deg))-z*math.sin(degrad(deg))
	z=z*math.cos(degrad(deg))+x*math.sin(degrad(deg))
	vek=Vector(x,y,z)
	return vek
end

function degrad(deg)
	deg=(deg/180)*math.pi
	return deg
end

--Callback

OnUpdateBuff(function(unit,buffProc)
	if unit ~= myHero and (buffProc.Type == 29 or buffProc.Type == 11 or buffProc.Type == 24 or buffProc.Type == 30) then 
		ccTrack[GetObjectName(unit)] = true
		rTime = buffProc.ExpireTime
	elseif unit == myHero and buffProc.Name == "VelkozR" then
		IOW.movementEnabled = false
		IOW.attacksEnabled = false
		rCast = true
	end
end)

OnRemoveBuff(function(unit,buffProc)
	if unit ~= myHero and (buffProc.Type == 29 or buffProc.Type == 11 or buffProc.Type == 24 or buffProc.Type == 30) then 
		ccTrack[GetObjectName(unit)] = false
	elseif unit == myHero and buffProc.Name == "VelkozR" then
		IOW.movementEnabled = true
		IOW.attacksEnabled = true
		rCast = false
	end
end)

print("Vel loaded - Logge")
