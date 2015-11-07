if GetObjectName(GetMyHero()) ~= "Velkoz" then return end

require("Inspired")

local Config=Menu("Vel","Vel")
Config:SubMenu("c", "Combo")
Config.c:Boolean("Q","Use Q",true)
Config.c:Boolean("FQ","Force Q Split",true)
Config.c:Boolean("W","Use W",true)
Config.c:Boolean("E","Use E",true)

OnTick(function(myHero)
	if not IsDead(myHero) then
		local unit = GetCurrentTarget()
		Combo(unit)
	end
end)

--velkozqsplitactive
--VelkozQ
value=6 --get value from silder
DegreeTable={10,-10,22.5,-22.5,45,-45}


function Combo(unit)
	for _,i in pairs(GetEnemyHeroes()) do
		if Config.c.Q:Value() and GetCastName(myHero,_Q)=="VelkozQ" then

			if ValidTarget(i,1500) and IOW:Mode() == "Combo" then
					
				local direct=GetPredictionForPlayer(GetOrigin(myHero),i,GetMoveSpeed(i),1300,250,750,50,true,false)
			
				if direct and direct.HitChance==1 then
					QStart=GetOrigin(myHero)
					CastSkillShot(_Q,direct.PredPos.x,direct.PredPos.y,direct.PredPos.z)
				end
					
				--Base Vector
				local BVec=Vector(GetOrigin(myHero))-Vector(GetOrigin(i))
					
				for l=1,value do
				
					--Degree Vector from table
					local sideVec=getVec(BVec,DegreeTable[l]):normalized()*750
						
					--Part on the range around enemy
					local circlespot=Vector(GetOrigin(i))+Vector(sideVec)
					local enemyCreeps={}
					local cPos=1
					for _,l in pairs(minionManager.objects) do
						if GetTeam(l)==MINION_ENEMY and GetDistance(l,myHero)<2000 then
							enemyCreeps[cPos]=l
							cPos=cPos+1
						end
					end
					--print(CountObjectsOnLineSegment(GetOrigin(myHero), circlespot, 70, enemyCreeps)<1)
					if CountObjectsOnLineSegment(GetOrigin(myHero), circlespot, 70, enemyCreeps)<1 and CountObjectsOnLineSegment(circlespot, GetOrigin(i), 70, enemyCreeps)<1 then
							
						--ShootQ at predcited Pos
						CastSkillShot(_Q,circlespot.x,circlespot.y,circlespot.z)
							
						--GetStartingPos
						QStart=GetOrigin(myHero)
					end
				end
			end	
		end
			--if q traveling
		if GetCastName(myHero,_Q)~="VelkozQ" and ValidTarget(i,2000) then
			local split=QPred(GetOrigin(QBall),i)
			local BallPos=GetOrigin(QBall)
			--DrawCircle(BallPos.x,BallPos.y,BallPos.z,50,0,3,0xffffff00)
			--DrawCircle(split.PredPos.x,split.PredPos.y,split.PredPos.z,50,0,3,0xffffff00)
			--print(((Vector(GetOrigin(QBall))-Vector(QStart)):normalized()*(Vector(GetOrigin(QBall))-Vector(split.PredPos)):normalized())^2)
			if (split.HitChance==1 or Config.c.FQ:Value()) and ((Vector(GetOrigin(QBall))-Vector(QStart)):normalized()*(Vector(GetOrigin(QBall))-Vector(split.PredPos)):normalized())^2<0.01 then
				--print("SPLIT")
				CastSpell(_Q)
			end
		end
				
		if Config.c.W:Value() and IOW:Mode() == "Combo" then
			if CanUseSpell(myHero, _W) == READY and ValidTarget(unit,GetCastRange(myHero,_W)) then
			local WPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit)*1.5,1000,250,GetCastRange(myHero,_W),70,false,true)
			   CastSkillShot(_W,WPred.PredPos.x,WPred.PredPos.y,WPred.PredPos.z)
			end
		end
		
		if Config.c.E:Value() and IOW:Mode() == "Combo" then
			if CanUseSpell(myHero, _E) == READY and ValidTarget(unit,GetCastRange(myHero,_E)) then
			local EPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),1300,100,GetCastRange(myHero,_E),70,false,true)
			   CastSkillShot(_E,EPred.PredPos.x,EPred.PredPos.y,EPred.PredPos.z)
			end
		end
	end
end


OnCreateObj(function(Object,myHero)
	if GetObjectBaseName(Object)=="Velkoz_Base_Q_mis.troy" then
		QBall=Object
	end
end)


function QPred(pos,unit)
	QPredict=GetPredictionForPlayer(pos,unit,GetMoveSpeed(unit),1300,250,750,70,true,false)
	return QPredict
end

function getVec(base, deg)
	local mult=1/deg
	local vek=(Vector(base)-Vector(base):perpendicular())*mult
	return vek
end

print("Vel loaded - Logge")
