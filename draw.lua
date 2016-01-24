require('Inspired')
require('DamageLib')

local dmgSpell={0,0,0,0}
local spellName= {"Q","W","E","R"} 
local allDmg = 0
local DrawMenu=Menu("Draw","Draw "..GetObjectName(myHero).." Damage")
local dC = { {255,255,255,0}, {255,0,255,0}, {255,255,0,0}, {255,0,0,255} }
for i=0,3,1 do
	if getdmg(spellName[i+1],myHero,myHero,1,3)~=0 then
		DrawMenu:Boolean(spellName[i+1], "Draw "..spellName[i+1], true)
		DrawMenu:ColorPick(spellName[i+1].."c", "Color for "..spellName[i+1], dC[i+1])
	end
end


OnTick(function (myHero)
	allDmg = 0 
	for i=0,3,1 do
		for _,champ in pairs(GetEnemyHeroes()) do
		champ=myHero
			dmgSpell[i+1]=0
			if  DrawMenu[spellName[i+1]] and DrawMenu[spellName[i+1]]:Value() and Ready(i) and GetDistance(myHero,champ) < (GetCastRange(myHero,i)*2) then
				dmgSpell[i+1] = getdmg(spellName[i+1],champ,myHero,GetCastLevel(myHero,i))
			else 
				dmgSpell[i+1] = 0
			end
			allDmg = allDmg + dmgSpell[i+1]
		end
	end
end)

OnDraw(function (myHero)
	champ=myHero
	local cDmg = allDmg
	for _,champ in pairs(GetEnemyHeroes()) do
		for i=3,0,-1 do
			if GetDistance(myHero,champ)< GetCastRange(myHero,i)*2 and DrawMenu[spellName[i+1].."c"] then
				DrawDmgOverHpBar(champ,GetCurrentHP(champ),cDmg,0,DrawMenu[spellName[i+1].."c"]:Value())
			end
			cDmg=cDmg-dmgSpell[i+1]
		end
	end
end)

print("Hello "..GetUser().." :>")
