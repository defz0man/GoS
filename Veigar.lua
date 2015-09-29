if GetObjectName(GetMyHero()) ~= "Veigar" then return end

require("Inspired")
require("IOW")
require("Collision")

local Config = Menu("Veigar", "Veigar")
Config:SubMenu("c", "Combo")
Config.c:Boolean("Q", "Use Q", true)
Config.c:Boolean("W", "Use W", true)
Config.c:Boolean("AW", "Auto W on immobile", true)
Config.c:Boolean("E", "Use E", true)
Config.c:Boolean("R", "Use R", true)

Config:SubMenu("f", "Farm")
Config.f:Boolean("AQ", "Auto Q farm", true)


local myHero=GetMyHero()

OnLoop(function (myHero)

	Combo()
	if Config.f.AQ:Value() then FarmQ() end
end)


function Combo()
		local unit=GetCurrentTarget()
	if not IsDead(myHero) and IOW:Mode() == "Combo" then
		if Config.c.Q:Value() and CanUseSpell(myHero,_Q) == READY and GoS:ValidTarget(unit, GetCastRange(myHero,_Q)) then
			local QPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),1200,GetCastRange(myHero,_Q),550,80,true,false)
			if QPred.HitChance == 1 then				
				CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
			end
		end	
		
		if Config.c.W:Value() and CanUseSpell(myHero,_W) == READY and GoS:ValidTarget(unit, GetCastRange(myHero,_W)) then
			local WPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),math.huge,GetCastRange(myHero,_W),550,80,false,false)
			if WPred.HitChance == 1 then				
				CastSkillShot(_W,WPred.PredPos.x,WPred.PredPos.y,WPred.PredPos.z)
			end
		end	
		
		if Config.c.E:Value() and CanUseSpell(myHero,_E) == READY and GoS:ValidTarget(unit, GetCastRange(myHero,_E)) then
			local EPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),math.huge,GetCastRange(myHero,_E),550,80,false,false)
			if EPred.HitChance == 1 then				
				CastSkillShot(_E,EPred.PredPos.x,EPred.PredPos.y,EPred.PredPos.z)
			end
		end
		
		if Config.c.R:Value() and CanUseSpell(myHero,_R) == READY and GoS:ValidTarget(unit, GetCastRange(myHero,_R)) then
			local RPercent=GetCurrentHP(unit)/GoS:CalcDamage(myHero, unit, 0, (125*GetCastLevel(myHero,_R)+GetBonusAP(myHero)+125+GetBonusAP(unit)*0.8))
			if RPercent<1 and RPercent>0.2 then 
				CastTargetSpell(unit,_R)
			end
		end	
	end
end

function AutoW()
	if Config.c.AW:Value() and GoS:ValidTarget(unit,GetCastRange(myHero,_W)) and GotBuff(unit, "veigareventhorizonstun") > 0 and (GotBuff(unit, "snare") > 0 or GotBuff(unit, "taunt") > 0 or GotBuff(unit, "suppression") > 0 or GotBuff(unit, "stun")) then
	local WPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit),math.huge,GetCastRange(myHero,_W),550,80,false,false)
		if WPred.HitChance == 1 then
			CastSkillShot(_W,WPred.PredPos.x,WPred.PredPos.y,WPred.PredPos.z)
		end
	end
end

function FarmQ()
	if not IsDead(myHero) and IOW:Mode() ~= "Combo" then
		for i,creep in pairs(GoS:GetAllMinions(MINION_ENEMY)) do
			if GoS:ValidTarget(creep,GetCastRange(myHero,_Q)) and GetCurrentHP(creep)<GoS:CalcDamage(myHero, creep, 0, (45*GetCastLevel(myHero,_Q)+30+GetBonusAP(myHero)*0.6)) then
				CreepOrigin=GetOrigin(creep)
				DrawCircle(CreepOrigin.x,CreepOrigin.y,CreepOrigin.z,75,0,3,0xffffffff)
				--"name" = Collision(range,projSPeed,delay,width)
				QCol=Collision(GetCastRange(myHero,_Q),1200,925,70)
				local state,Objects=QCol:__GetMinionCollision(myHero,creep,ENEMY)
				local hitcount=0
				
				for i,unit in ipairs(Objects) do 
					hitcount=hitcount+1
				end
							
				if hitcount<=1 then
				CastSkillShot(_Q,CreepOrigin.x,CreepOrigin.y,CreepOrigin.z)
				end
			end
		end
	end
end

print("Veigar injected")

--[[
function drawDoubleQ()		--TRASH
	for i,creep in pairs(GoS:GetAllMinions(MINION_ENEMY)) do
		if GoS:ValidTarget(creep,GetCastRange(myHero,_Q)) and GetCurrentHP(creep)<GoS:CalcDamage(myHero, creep, 0, (45*GetCastLevel(myHero,_Q)+35+GetBonusAP(myHero))*0.6) then
		--print(GoS:CalcDamage(myHero, creep,0, (45*GetCastLevel(myHero,_Q)+35+GetBonusAP(myHero))*0.6))
			local CreepOrigin=GetOrigin(creep)
			DrawCircle(CreepOrigin.x,CreepOrigin.y,CreepOrigin.z,100,0,0,0xffffffff)
			for i2,creep2 in pairs(GoS:GetAllMinions(MINION_ENEMY)) do
				local Creep2Origin=GetOrigin(creep2)
				if creep2~=creep and GoS:ValidTarget(creep2,GetCastRange(myHero,_Q)) and GetCurrentHP(creep2)<GoS:CalcDamage(myHero, creep2, 0, (45*GetCastLevel(myHero,_Q)+35+GetBonusAP(myHero))*0.6) then
					DrawCircle(Creep2Origin.x,Creep2Origin.y,Creep2Origin.z,150,0,0,0xffffffff)
					
					local drawCreep=WorldToScreen(1,GetOrigin(creep))
					local drawCreep2=WorldToScreen(1,GetOrigin(creep2))
					DrawLine(drawCreep.x,drawCreep.y,drawCreep2.x,drawCreep2.y,1,ARGB(255,255,255,255))
					
					if GoS:GetDistance(myHero,creep)<GoS:GetDistance(myHero,creep2) then
						local closest=creep
					else
						local closest=creep2
					end
					
					local dist=GoS:GetDistance(creep,creep2)
					local vectorx=(Creep2Origin.x-CreepOrigin.x)/dist
					local vectory=(Creep2Origin.y-CreepOrigin.y)/dist
					local vectorz=(Creep2Origin.z-CreepOrigin.z)/dist
					local range=GetCastRange(myHero,_Q)
					
					local xpos=CreepOrigin.x-vectorx*range
					local ypos=CreepOrigin.y-vectory*range
					local zpos=CreepOrigin.z-vectorz*range
					
					local LineDraw=WorldToScreen(1,xpos,ypos,zpos)
					DrawLine(LineDraw.x,LineDraw.y,drawCreep.x,drawCreep.y,1,ARGB(255,255,255,255))
				end
			end
		end
	end
end
--]]
