local c = {}
local mk = {}
local lastSound = GetGameTimer()

c[GetNetworkID(myHero)] = {unit = myHero, dead = false, deadT = nil, lDmg = nil, killer = nil}
for _,i in pairs(GetAllyHeroes()) do
	c[GetNetworkID(i)] = {unit = i, dead = false, deadT = nil, lDmg = nil, killer = nil}
end
for _,i in pairs(GetEnemyHeroes()) do
	c[GetNetworkID(i)] = {unit = i, dead = false, deadT = nil, lDmg = nil, killer = nil}
end

OnDamage( function (unit,target,dmg)
	if GetObjectType(unit) == Obj_AI_Hero and GetObjectType(target) == Obj_AI_Hero then
		if GetTeam(unit) == MINION_ENEMY then
			c[GetNetworkID(unit)].lDmg = target
		else
			c[GetNetworkID(unit)].lDmg = target
		end
	end
end)

OnTick( function ()
	for _,i in pairs(c) do
		if not i.dead and i.unit.dead then	--onDeath
			i.deadT = GetGameTimer()
			i.killer = i.lDmg
		else		
			i.deadT = nil
			i.killer = nil
		end
		if i.dead and not i.unit.dead and _ == GetNetworkID(myHero) then	--On Respawn
			Play("Dlc_glados_ann_glados_followup_respaw_",13)
			i.dead = false
		end
		
		if i.unit.dead then 
			i.dead = true
		else
			i.dead = false
		end
	end
end)

function Play(str,m)
	if GetGameTimer() - lastSound > 2 then
		repeat 
			local rnd = math.random(1,m)
			if rnd < 10 then
				PlaySound(SOUNDS_PATH.. [[\Glados\]] ..str.. "0"..tostring(rnd) .. ".wav")
			else
				PlaySound(SOUNDS_PATH.. [[\Glados\]] ..str ..tostring(rnd) .. ".wav")
			end
		print("Ran Sound "..SOUNDS_PATH.. [[\Glados\]] ..str.. tostring(rnd) .. ".wav")
		until FileExist(SOUNDS_PATH.. [[\Glados\]] ..str.. "0"..tostring(rnd) .. ".wav")
	end
end
