local c = {}
local lastSound = GetGameTimer()


c[GetNetworkID(myHero)] = {unit = myHero, dead = false, deadT = nil, lDmg = nil, lDmgT = nil, killer = nil, mk = 0, mks = nil, counted = false}
DelayAction( function() 
	for _,i in pairs(GetAllyHeroes()) do
		c[GetNetworkID(i)] = {unit = i, dead = false, deadT = nil, lDmg = nil, lDmgT = nil, killer = nil, mk = 0, mks = nil, counted = false}
	end
	for _,i in pairs(GetEnemyHeroes()) do
		c[GetNetworkID(i)] = {unit = i, dead = false, deadT = nil, lDmg = nil, lDmgT = nil, killer = nil, mk = 0, mks = nil, counted = false}
	end
end,0)

OnDamage( function (unit,target,dmg)
	if GetObjectType(unit) == Obj_AI_Hero and GetObjectType(target) == Obj_AI_Hero then
		c[GetNetworkID(target)].lDmg = unit
		c[GetNetworkID(target)].lDmgT = GetGameTimer()
	end
end)

OnTick( function ()
	for _,i in pairs(c) do
		if not i.dead and i.unit.dead and i.lDmg then	--onDeath
			i.deadT = GetGameTimer()
			i.killer = i.lDmg
		end
		
		if i.dead and not i.unit.dead and _ == GetNetworkID(myHero) then	--On Respawn
			Play("Dlc_glados_ann_glados_followup_respaw_",17)
			
		elseif not i.dead and i.unit.dead and _ == GetNetworkID(myHero) then	--On Death (Self)
			Play("Dlc_glados_ann_glados_ally_neg_",30)
		end
		
		
		if not i.dead and i.unit.dead and i.killer and i.deadT and not i.counted then
			c[GetNetworkID(i.killer)].mko = c[GetNetworkID(i.killer)].mk
			c[GetNetworkID(i.killer)].mk = c[GetNetworkID(i.killer)].mk + 1
			i.counted = true
			c[GetNetworkID(i.killer)].mks = GetGameTimer()
		elseif i.killer and c[GetNetworkID(i.killer)].mks and GetGameTimer() - c[GetNetworkID(i.killer)].mks >= 10 and i.counted then
			c[GetNetworkID(i.killer)].mk = 0
			c[GetNetworkID(i.killer)].mks = nil
			i.counted = false
		end
		
		if mko and mko < i.mk then
			if i.mk == 2 then
				Play("Dlc_glados_killing_spree_ann_glados_kill_double_",1)
			elseif i.mk == 3 then
				Play("Dlc_glados_killing_spree_ann_glados_kill_triple_",1)
			elseif i.mk == 4 then
				Play("Dlc_glados_killing_spree_ann_glados_kill_ultra_",2)
			elseif i.mk == 5 then
				Play("Dlc_glados_killing_spree_ann_glados_kill_rampage_",2)
			end
		end
		print(mko)
		
		if i.lDmgT and GetGameTimer() - i.lDmgT >= 10 then
			i.lDmg = nil
			i.killer = nil
		end
		
		if i.unit.dead then 
			i.dead = true
		else
			i.dead = false
			i.killer = nil
			i.deadT = nil
		end
	end
end)

OnDraw( function()
	DrawText(math.floor(GetGameTimer()),20,5,5,GoS.White)
	for l,m in pairs(c) do
		local y = 0
		local mph = WorldToScreen(0,GetOrigin(m.unit))
		for _,i in pairs(m) do
			if type(i)=="Object" then
				i = GetObjectName(i)
			end
			DrawText(_..": "..tostring(i),20,mph.x,mph.y+y,GoS.White)
			y = y + 30
		end
	end
end)

function Play(str,m)
	print(GetGameTimer())
	if GetGameTimer() - lastSound > 2 or GetGameTimer() <= 20 then
		repeat 
			local rnd = math.random(1,m)
			if rnd < 10 then
				PlaySound(SOUNDS_PATH.. [[\Glados\]] ..str.. "0"..tostring(rnd) .. ".wav")
			else
				PlaySound(SOUNDS_PATH.. [[\Glados\]] ..str ..tostring(rnd) .. ".wav")
			end
		print("Ran Sound "..SOUNDS_PATH.. [[\Glados\]] ..str.. tostring(rnd) .. ".wav")
		until FileExist(SOUNDS_PATH.. [[\Glados\]] ..str.. "0"..tostring(rnd) .. ".wav")
		lastSound = GetGameTimer()
	else
	print("spam catch")
	end
end

if GetGameTimer() <= 20 then
	Play("Dlc_glados_ann_glados_battle_prepare_",10)
end

--1:15 creeps
