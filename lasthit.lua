-- LastHit

local atkREADY = true
local baseAS = GetBaseAttackSpeed(myHero)

OnProcessSpellComplete(function(unit, spell)
	if unit == myHero and spell.name:lower():find("attack") then
		local ASDelay = 1/(baseAS*GetAttackSpeed(myHero))
		atkREADY = false
		DelayAction(function()
			atkREADY = true
			-- PrintChat("ON!")
		end, ASDelay*1000- spell.windUpTime*1000)
	end
end)

OnTick(function(myHero)
if not IsDead(myHero) then

	if atkREADY == true then
		lasthit()
	end

end
end)

function lasthit()
	for i,minion in pairs(minionManager.objects) do
		if MINION_ENEMY == GetTeam(minion) then
			if ValidTarget(minion, myHeroRange) and GetDistance(myHero, minion) < myHeroRange then
				local minionInRange = minion
				if GetCurrentHP(minionInRange) - GetDamagePrediction(minionInRange,(GetDistance(myHero,minionInRange)/1200)*1000)  < CalcDamage(myHero,minion,GetBaseDamage(myHero)+GetBonusDmg(myHero),0) then
					AttackUnit(minionInRange)
				end
			end
		end
	end
end
