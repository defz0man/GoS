require('Inspired')
require('DamageLib')

dmgSpell={}
for i=0,3,1 do
	dmgSpell[i]=0
end
allDmg=0

spell={}
spell[0]="Q"
spell[1]="W"
spell[2]="E"
spell[3]="R"

local DrawMenu=Menu("Draw","Draw")
DrawMenu:SubMenu("c", GetObjectName(myHero))
for i=0,3,1 do
	DrawMenu.c:Boolean(spell[i], "Draw "..spell[i], true)
end




OnTick(function (myHero)
	for i=0,3,1 do
		for _,i in pairs(spell) do
			dmgSpell[i]=0
			if DrawMenu.c.spell[i]:Value() and Ready(i) and ValidTarget(champ,GetCastRange(myHero,i)*2) and GetDistance(myHero,champ)<GetCastRange(myHero,i)*2 then
				dmgSpell[i]= getdmg(spell[i],champ,myHero,GetCastLevel(myHero,i))
			end
		end
		allDmg=dmgSpell[0]+dmgSpell[1]+dmgSpell[2]+dmgSpell[3]
	end
end)

OnDraw(function (myHero)
	for _,champ in pairs(GetEnemyHeroes()) do
		if ValidTarget(champ) then
			DrawDmgOverHpBar(champ,GetCurrentHP(champ),allDmg,0,0xffffffff)
		end
	end
end)

print("DmgDraw loaded - Logge")
