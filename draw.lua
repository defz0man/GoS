require('Inspired')
require('DamageLib')

local dmgSpell = {}
local spellName= {"Q","W","E","R"} 
local dC = { {255,255,255,0}, {255,0,255,0}, {255,255,0,0}, {255,0,0,255} }
local aa = {}
local dCheck = {}
local DrawMenu=Menu("Draw","Draw "..GetObjectName(myHero).." Damage")
DrawMenu:Boolean("dAA","Count AA to kill", true)
DrawMenu:Boolean("dAAc","Consider Crit", true)


for i=1,4,1 do
	if getdmg(spellName[i],myHero,myHero,1,3)~=0 then
		DrawMenu:Boolean(spellName[i], "Draw "..spellName[i], true)
		DrawMenu:ColorPick(spellName[i].."c", "Color for "..spellName[i], dC[i])
	end
end

DelayAction( function()
	for _,champ in pairs(GetEnemyHeroes()) do
		dmgSpell[GetObjectName(champ)]={0,0,0,0}
	end
end, 0.001)

OnTick(function (myHero)
	for _,champ in pairs(GetEnemyHeroes()) do
		dCheck[GetObjectName(champ)]={false,false,false,false}
		local sDmg = 0
		for i=1,4,1 do
			dmgSpell[GetObjectName(champ)][i]=0
			if  DrawMenu[spellName[i]] and DrawMenu[spellName[i]]:Value() and Ready(i-1) and GetDistance(GetOrigin(myHero),GetOrigin(champ)) < (GetCastRange(myHero,i-1)*2) then
				sDmg = sDmg + getdmg(spellName[i],champ,myHero,GetCastLevel(myHero,i-1))
				dCheck[GetObjectName(champ)][i]=true
			else 
				dmgSpell[GetObjectName(champ)][i] = 0
				dCheck[GetObjectName(champ)][i]=false
			end
			dmgSpell[GetObjectName(champ)][i] = sDmg
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
		for i=4,1,-1 do
			if dCheck[GetObjectName(champ)] and dCheck[GetObjectName(champ)][i] then
				DrawDmgOverHpBar(champ,GetCurrentHP(champ),dmgSpell[GetObjectName(champ)][i], 0, DrawMenu[spellName[i].."c"]:Value())
			end
		end
		if DrawMenu.dAA:Value() and bar.x ~= 0 and bar.y ~= 0 then 
			DrawText(aa[GetObjectName(champ)].." AA", 15, bar.x + 75, bar.y + 25, GoS.White)
		end
	end
end)

print("Hello "..GetUser().." :>")
