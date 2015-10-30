require("Inspired")
require("Collision")

local Config=Menu("Vel","Vel")
Config:SubMenu("c", "Combo")
Config.c:Boolean("Q","Use Q",true)
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
value=4 --get value from silder
DegreeTable={22.5,-22.5,45,-45}


function Combo(unit)
	for _,i in pairs(GetEnemyHeroes()) do
		if Config.c.Q:Value() and GetCastName(myHero,_Q)=="VelkozQ" then

			if ValidTarget(i,1500) and IOW:Mode() == "Combo" then
					
				EnemyPos=GetOrigin(i)
				DrawCircle(EnemyPos.x,EnemyPos.y,EnemyPos.z,750,0,3,0xffffff00)		
				local direct=GetPredictionForPlayer(GetOrigin(myHero),i,GetMoveSpeed(i),1300,250,750,50,true,false)
			
				if direct and direct.HitChance==1 then
					QStart=GetOrigin(myHero)
					CastSkillShot(_Q,direct.PredPos.x,direct.PredPos.y,direct.PredPos.z)
				end
					
				--Base Vector
				local BVec=Vector(GetOrigin(myHero))-Vector(GetOrigin(i))
					
				for l=1,value,1 do
				
					--Degree Vector from table
					local sideVec=getVec(BVec,DegreeTable[l]):normalized()*750
						
					--Part on the range around enemy
					local circlespot=Vector(GetOrigin(i))+Vector(sideVec)
					
					
					QCol=Collision(1500,1200,925,70)
					local state,Objects=QCol:__GetMinionCollision(myHero,circlespot,ENEMY)
					local hitcount=0
				
					for i,unit in ipairs(Objects) do 
						return
					end
					--Debug1
					--DrawCircle(circlespot.x,circlespot.y,circlespot.z,75,0,3,0xffffff00)
					
					--From circlespot to enemy
					local side1=GetPredictionForPlayer(circlespot,i,GetMoveSpeed(i),1300,250,1000,70,true,false)
						
					--From circlespot to me 
					--local side2=GetPredictionForPlayer(circlespot,myHero,GetMoveSpeed(i),1300,250,1000,50,true,false)
					
					--Check for both ways to be clear
					if side1.HitChance==1 then
							
						--Debug2
						--DrawCircle(circlespot.x,circlespot.y,circlespot.z,50,0,3,0xffffff00)
							
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
			if split.HitChance==1 and ((Vector(GetOrigin(QBall))-Vector(QStart)):normalized()*(Vector(GetOrigin(QBall))-Vector(split.PredPos)):normalized())^2<0.01 then
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

print("Vel loaded")
