require('DamageLib')

local ver = 1
GetWebResultAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/v/Paint.version", function(data)
	if tonumber(data) > tonumber(ver) then
        DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Paint.lua", SCRIPT_PATH .. "Paint.lua", function() print("Paint updated to version "..data .. ". Please reload now!") return end)
	end
end)

local dmgSpell = {}
local spellName= {"Q","W","E","R"} 
local dC = { {200,255,255,0}, {200,0,255,0}, {200,255,0,0}, {200,0,0,255} }
local sC = { {200,255,255,0}, {200,0,255,0}, {200,255,0,0}, {200,0,0,255} }
local aa = {}
local E = {}
local dCheck = {}
local dX = {}
local DrawMenu = Menu("Draw","Draw "..GetObjectName(myHero).." Damage")
DrawMenu:Boolean("dAA","Count AA to kill", true)
DrawMenu:Boolean("dAAc","Consider Crit", true)
DrawMenu:Boolean("dED", "Enemy Dmg on me", false)
DrawMenu:Slider("dR","Draw Range", 1500, 500, 3000, 100)
DrawMenu:SubMenu("D","Self Colors")
for i=1,4,1 do
	if getdmg(spellName[i],myHero,myHero,1,3)~=0 then
		DrawMenu:Boolean(spellName[i], "Draw "..spellName[i], true)
		DrawMenu:ColorPick(spellName[i].."c", "Color for "..spellName[i], dC[i])
	end
	DrawMenu.D:Boolean(spellName[i], "Draw "..spellName[i], true)
	DrawMenu.D:ColorPick(spellName[i].."c", "Color for "..spellName[i], dC[i])
end

dmgSpell[myHero.name]={0, 0, 0, 0}
dX[myHero.name] = {{0,0}, {0,0}, {0,0}, {0,0}}
DelayAction( function()
	for _,champ in pairs(GetEnemyHeroes()) do
		dmgSpell[champ.name]={0, 0, 0, 0}
		dX[champ.name] = {{0,0}, {0,0}, {0,0}, {0,0}}
	end
end, 0.001)

OnTick(function()
	for _,champ in pairs(GetEnemyHeroes()) do
		dCheck[champ.name]={false,false,false,false}
		local last = GetPercentHP(champ)*1.04
		local lock = false
		for i=1,4,1 do
			if DrawMenu[spellName[i]] and DrawMenu[spellName[i]]:Value() and Ready(i-1) and GetDistance(GetOrigin(myHero),GetOrigin(champ)) < DrawMenu.dR:Value() then
				dmgSpell[champ.name][i] = getdmg(spellName[i],champ,myHero,GetCastLevel(myHero,i-1))
				dCheck[champ.name][i]=true
			else 
				dmgSpell[champ.name][i] = 0
				dCheck[champ.name][i]=false
			end
			dX[champ.name][i][2] = dmgSpell[champ.name][i]/(GetMaxHP(champ)+GetDmgShield(champ))*104
			dX[champ.name][i][1] = last - dX[champ.name][i][2]
			last = last - dX[champ.name][i][2]
			if lock then
				dX[champ.name][i][1] = 0 
				dX[champ.name][i][2] = 0
			end
			if dX[champ.name][i][1]<=0 and not lock then
				dX[champ.name][i][1] = 0 
				dX[champ.name][i][2] = last + dX[champ.name][i][2]
				lock = true
			end
		end
		if DrawMenu.dAA:Value() and DrawMenu.dAAc:Value() then 
			aa[champ.name] = math.ceil(GetCurrentHP(champ)/(CalcDamage(myHero, champ, GetBaseDamage(myHero)+GetBonusDmg(myHero),0)*(GetCritChance(myHero)+1)))
		elseif DrawMenu.dAA:Value() and not DrawMenu.dAAc:Value() then 
			aa[champ.name] = math.ceil(GetCurrentHP(champ)/(CalcDamage(myHero, champ, GetBaseDamage(myHero)+GetBonusDmg(myHero),0)))
		end
	end
	local tar = GetCurrentTarget()
	if DrawMenu.dED:Value() and ValidTarget(tar,DrawMenu.dR:Value()) then
		local lock = false
		local last = GetPercentHP(myHero)*1.04
		dCheck[myHero.name] = {false,false,false,false}
		for i=1,4 do
			tar:Draw(50)
			if CanUseSpell(tar,i-1) == 8 then
				dmgSpell[myHero.name][i] = getdmg(spellName[i],myHero,tar,GetCastLevel(tar,i-1))
				dCheck[myHero.name][i] = true
				dX[myHero.name][i][2] = dmgSpell[myHero.name][i]/(GetMaxHP(myHero)+GetDmgShield(myHero))*104
				dX[myHero.name][i][1] = last - dX[myHero.name][i][2]
				last = last - dX[myHero.name][i][2]
				if lock then
					dX[myHero.name][i][1] = 0 
					dX[myHero.name][i][2] = 0
				end
				if dX[myHero.name][i][1]<=0 and not lock then
					dX[myHero.name][i][1] = 0 
					dX[myHero.name][i][2] = last + dX[myHero.name][i][2]
					lock = true
				end
			end
		end
	else
		dCheck[myHero.name] = {false,false,false,false}
	end
end)

OnDraw(function()
	for _,champ in pairs(GetEnemyHeroes()) do
		local bar = GetHPBarPos(champ)
		if bar.x ~= 0 and bar.y ~= 0 then
			for i=4,1,-1 do
				if dCheck[champ.name] and dCheck[champ.name][i] then
					FillRect(bar.x+dX[champ.name][i][1],bar.y,dX[champ.name][i][2],9,DrawMenu[spellName[i].."c"]:Value())
					FillRect(bar.x+dX[champ.name][i][1],bar.y-1,2,11,GoS.Black)
				end
			end
			if DrawMenu.dAA:Value() and bar.x ~= 0 and bar.y ~= 0 and aa[champ.name] then 
				DrawText(aa[champ.name].." AA", 15, bar.x + 75, bar.y + 25, GoS.White)
			end
		end
	end
	local bar = GetHPBarPos(myHero)
	for i = 4,1,-1 do 
		if dCheck[myHero.name] and dCheck[myHero.name][i] then
			FillRect(bar.x+dX[myHero.name][i][1],bar.y,dX[myHero.name][i][2],9,DrawMenu.D[spellName[i].."c"]:Value())
			FillRect(bar.x+dX[myHero.name][i][1],bar.y-1,2,11,GoS.Black)
		end
	end
end)

print("Paint.lua loaded")
