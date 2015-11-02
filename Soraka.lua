if GetObjectName(GetMyHero()) ~= "Soraka" then return end

require("Inspired")

local Config = Menu("Soraka", "Soraka")

Config:SubMenu("c", "Combo")
Config.c:Boolean("Q", "Use Q", true)
Config.c:Boolean("E", "Use E", true)
Config.c:Boolean("AE", "Auto E on immobile", true)

Config:SubMenu("h","Heal")
Config.h:Boolean("AW", "Auto use W", true)
Config.h:Boolean("AR", "Auto use R", true)


healvalue=0.4

OnTick(function (myHero)
	if not IsDead(myHero) then
	local unit=GetCurrentTarget()
		heals()
		AutoE(unit)
		combo(unit)
	end
end)

function heals()
	if CanUseSpell(myHero,_W) == READY or CanUseSpell(myHero,_R) == READY then
		for _,champ in pairs(GetAllyHeroes()) do
				if Config.h.AW:Value() then
					if not IsDead(champ) and (GetCurrentHP(champ)/GetMaxHP(champ)<healvalue) and GetDistance(myHero,champ)<GetCastRange(myHero,_W) then
						CastTargetSpell(champ,_W)
					end
				end
				if Config.h.AR:Value() then
					if not IsDead(champ) and (GetCurrentHP(champ)/GetMaxHP(champ)<(healvalue*0.5)) then
						CastSpell(_R)
				end
			end
		end
	end
end

function AutoE(unit)
	if CanUseSpell(myHero,_E) == READY and ValidTarget(unit,GetCastRange(myHero,_E)) and Config.c.AE:Value() and (GotBuff(unit, "veigareventhorizonstun") > 0 or (GotBuff(unit, "snare") > 0 or GotBuff(unit, "taunt") > 0 or GotBuff(unit, "suppression") > 0 or GotBuff(unit, "stun"))) then
		local EnemyOrg=GetOrigin(unit)
		CastSkillShot(_E,EnemyOrg.x,EnemyOrg.y,EnemyOrg.z)
	end
end

function combo(unit)
	if IOW:Mode() == "Combo" then
		if Config.c.Q:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(unit,GetCastRange(myHero,_Q)*0.85) then
			local Delay=(GetDistance(myHero,unit)/GetCastRange(myHero,_Q))*750
			local QPred = GetPredictionForPlayer(GetOrigin(myHero),unit,GetMoveSpeed(unit)-10,math.huge,GetCastRange(myHero,_Q),250+Delay,80,false,true)
			if QPred.HitChance==1 then
				CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
			end
		end
		if Config.c.E:Value() and CanUseSpell(myHero,_E) == READY and ValidTarget(unit,GetCastRange(myHero,_E)) then
			local EnemyOrg=GetOrigin(unit)
			CastSkillShot(_E,EnemyOrg.x,EnemyOrg.y,EnemyOrg.z)
		end
	end
end
print("Raka injected - Logge")
