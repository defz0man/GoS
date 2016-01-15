if GetObjectName(GetMyHero()) ~= "Velkoz" then return end

require("Inspired")
require("OpenPredict")

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

--velkozqsplitactive
--VelkozQ
value=4 --get value from silder
DegreeTable={22.5,-22.5,45,-45}

VelQ = { delay = 0.1, speed = 1300, width = 75, range = 1000}
VelQ2 ={ delay = 0.1, speed = 1300, width = 75, range = 1000}
VelW = { delay = 0.1, speed = 1700, width = 55, range = GetCastRange(myHero,_W)}
VelE = { delay = 0.1, speed = 1700, range = GetCastRange(myHero,_E), radius = 200 }



OnTick(function(myHero)
	if not IsDead(myHero) then
		local unit = GetCurrentTarget()
		Combo(unit)
	end
end)




function Combo(unit)
	for _,i in pairs(GetEnemyHeroes()) do
		if VelM.c.Q:Value() and GetCastName(myHero,_Q)=="VelkozQ" and ValidTarget(i,1400) and IOW:Mode() == "Combo"  then
			local direct=GetPrediction(i,VelQ)
		
			if direct and direct.hitChance>.25 then
				QStart=GetOrigin(myHero)
				CastSkillShot(_Q,direct.castPos)
				break
			end
				
			--Base Vector
			local BVec = Vector(GetOrigin(i)) - Vector(GetOrigin(myHero))
			local dist = math.sqrt(GetDistance(GetOrigin(myHero),GetOrigin(i))^2/2)
			for l=1,value do
			
				--Degree Vector from table
				local sideVec=getVec(BVec,DegreeTable[l]):normalized()*dist
				DrawCircle(sideVec+GetOrigin(myHero) ,50,0,3,GoS.Green)
				
				local circlespot = sideVec+GetOrigin(myHero)
				local QPred = GetPrediction(i, VelQ2, circlespot)
				--print(DegreeTable[l]..":"..sideVec.x)
				
				--Part on the range around enemy
				DrawCircle(circlespot,50,0,3,GoS.Red)
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
			local BallVec = Vector(GetOrigin(QBall))-Vector(QStart)
			--print((((Vector(GetOrigin(QBall))-Vector(QStart)):normalized()*(Vector(GetOrigin(QBall))-Vector(split.castPos)):normalized())^2))
			if (split.hitChance>.25 or VelM.c.FQ:Value()) and ((Vector(GetOrigin(QBall))-Vector(QStart)):normalized()*(Vector(GetOrigin(QBall))-Vector(split.castPos)):normalized())^2<0.02 then
				--print("SPLIT")
				CastSpell(_Q)
			end
		end
	end
			
	if VelM.c.W:Value() and IOW:Mode() == "Combo" then
		if Ready(_W) and ValidTarget(unit,GetCastRange(myHero,_W)) then
			local WPred = GetPrediction(unit, VelW)
			CastSkillShot(_W,WPred.castPos)
		end
	end
	
	if VelM.c.E:Value() and IOW:Mode() == "Combo" then
		if Ready(_E) and ValidTarget(unit,GetCastRange(myHero,_E)) then
			local EPred = GetCircularAOEPrediction(unit, VelE)
			CastSkillShot(_E,EPred.castPos)
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
	local mult=1/deg
	--x' = x cos θ - y sin θ
   -- y' = x sin θ + y cos θ
	--[[if deg<0 then
		local perp=Vector(base):perpendicular2()
	else
		local perp=Vector(base):perpendicular()
	end 	
	local vek=(Vector(base)-Vector(perp))*mult--]]
	local x,y,z=base:unpack()
	x=x*math.cos(degrad(deg))-z*math.sin(degrad(deg))
	z=z*math.cos(degrad(deg))+x*math.sin(degrad(deg))
	vek=Vector(x,y,z)
	--vek=Vector(base)+Vector(vek)
	return vek
end

function degrad(deg)
	deg=(deg/180)*math.pi
	return deg
end

print("Vel loaded - Logge")
