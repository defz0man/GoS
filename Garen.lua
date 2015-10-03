require('Inspired')

PrintChat("Garen Auto R - Logge")

OnLoop (function (myHero)
	local target = GetCurrentTarget()
	
	if CanUseSpell(myHero,_R) == READY and GoS:ValidTarget(target, GetCastRange(myHero,_R)) then
		if GotBuff(target,"garenpassivegrit")>1 and GetCurrentHP(target) < GoS:CalcDamage(myHero, target, 0, 175*GetCastLevel(myHero,_R) + ((GetMaxHP(target)-GetCurrentHP(target))*(0.219+0.067*GetCastLevel(myHero, _R)))) then
			CastTargetSpell(target,_R)
		elseif GotBuff(target,"garenpassivegrit")<1 and GetCurrentHP(target) < (175*GetCastLevel(myHero,_R) + ((GetMaxHP(target)-GetCurrentHP(target))*(0.219+0.067*GetCastLevel(myHero, _R)))) then
			CastTargetSpell(target,_R)
		end
	end	
end)
