require('Inspired')
require('DamageLib')

local dmgSpell = {}
local spellName= {"Q","W","E","R"} 
local dC = { {200,255,255,0}, {200,0,255,0}, {200,255,0,0}, {200,0,0,255} }
local aa = {}
local dCheck = {}
local dX = {}
local DrawMenu=Menu("Draw","Draw "..GetObjectName(myHero).." Damage")
DrawMenu:Boolean("dAA","Count AA to kill", true)
DrawMenu:Boolean("dAAc","Consider Crit", true)
DrawMenu:Slider("dR","Draw Range", 1500, 500, 3000, 100)

for i=1,4,1 do
	if getdmg(spellName[i],myHero,myHero,1,3)~=0 then
		DrawMenu:Boolean(spellName[i], "Draw "..spellName[i], true)
		DrawMenu:ColorPick(spellName[i].."c", "Color for "..spellName[i], dC[i])
	end
end

DelayAction( function()
	for _,champ in pairs(GetEnemyHeroes()) do
		dmgSpell[GetObjectName(champ)]={0, 0, 0, 0}
		dX[GetObjectName(champ)] = {{0,0}, {0,0}, {0,0}, {0,0}}
	end
end, 0.001)

OnTick(function (myHero)
	for _,champ in pairs(GetEnemyHeroes()) do
		dCheck[GetObjectName(champ)]={false,false,false,false}
		local last = GetPercentHP(champ)*1.04
		local lock = false
		for i=1,4,1 do
			if DrawMenu[spellName[i]] and DrawMenu[spellName[i]]:Value() and Ready(i-1) and GetDistance(GetOrigin(myHero),GetOrigin(champ)) < DrawMenu.dR:Value() then
				dmgSpell[GetObjectName(champ)][i] = getdmg(spellName[i],champ,myHero,GetCastLevel(myHero,i-1))
				dCheck[GetObjectName(champ)][i]=true
			else 
				dmgSpell[GetObjectName(champ)][i] = 0
				dCheck[GetObjectName(champ)][i]=false
			end
			dX[GetObjectName(champ)][i][2] = dmgSpell[GetObjectName(champ)][i]/(GetMaxHP(champ)+GetDmgShield(champ))*104
			dX[GetObjectName(champ)][i][1] = last - dX[GetObjectName(champ)][i][2]
			last = last - dX[GetObjectName(champ)][i][2]
			if lock then
				dX[GetObjectName(champ)][i][1] = 0 
				dX[GetObjectName(champ)][i][2] = 0
			end
			if dX[GetObjectName(champ)][i][1]<=0 and not lock then
				dX[GetObjectName(champ)][i][1] = 0 
				dX[GetObjectName(champ)][i][2] = last + dX[GetObjectName(champ)][i][2]
				lock = true
			end
			print(dX[GetObjectName(champ)][i][1])
		end
		if DrawMenu.dAA:Value() and DrawMenu.dAAc:Value() then 
			aa[GetObjectName(champ)] = math.ceil(GetCurrentHP(champ)/(CalcDamage(myHero, champ, GetBaseDamage(myHero)+GetBonusDmg(myHero),0)*(GetCritChance(myHero)+1)))
		elseif DrawMenu.dAA:Value() and not DrawMenu.dAAc:Value() then 
			aa[GetObjectName(champ)] = math.ceil(GetCurrentHP(champ)/(CalcDamage(myHero, champ, GetBaseDamage(myHero)+GetBonusDmg(myHero),0)))
		end
	end
end)

OnDraw(function (myHero)
	for _,champ in pairs(GetEnemyHeroes()) do
		
		local bar = GetHPBarPos(champ)
		if bar.x ~= 0 and bar.y ~= 0 then
			for i=4,1,-1 do
				if dCheck[GetObjectName(champ)] and dCheck[GetObjectName(champ)][i] then
					FillRect(bar.x+dX[GetObjectName(champ)][i][1],bar.y,dX[GetObjectName(champ)][i][2],9,DrawMenu[spellName[i].."c"]:Value())
					FillRect(bar.x+dX[GetObjectName(champ)][i][1],bar.y-1,2,11,GoS.Black)
				end
			end
			if DrawMenu.dAA:Value() and bar.x ~= 0 and bar.y ~= 0 and aa[GetObjectName(champ)] then 
				DrawText(aa[GetObjectName(champ)].." AA", 15, bar.x + 75, bar.y + 25, GoS.White)
			end
		end
	end
end)

print("Hello "..GetUser().." :>")
