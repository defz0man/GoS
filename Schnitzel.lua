require "Inspired"

local obj = {}

local IMenu = Menu("Info","Info")

OnCreateObj(function (Object)
	if GetObjectBaseName(Object):find(".troy") and GetObjectBaseName(Object):find("mis") and not GetObjectBaseName(Object):lower():find("attack") and not GetObjectBaseName(Object):lower():find("_ba_")  then
		for _,i in pairs(GetEnemyHeroes()) do 
			if GetObjectBaseName(Object):lower():find(GetObjectName(i):lower()) then
				print(GetObjectName(GetObjectSpellOwner(Object)))
				if not IMenu[GetObjectBaseName(Object)] then 
					IMenu:Menu(GetObjectBaseName(Object),GetObjectBaseName(Object)) 
				end
				obj[GetObjectBaseName(Object)] = {Obj = Object, sPos = GetOrigin(Object)}
				print(GetObjectBaseName(Object))
			end
		end
	end
end)

OnDeleteObj(function (Object)
	if GetObjectBaseName(Object):find(".troy") and GetObjectBaseName(Object):find(GetObjectName(myHero)) then
		obj[GetObjectBaseName(Object)] = nil
	end
end)

OnDraw( function ()
	local offy = 30
	for _,i in pairs(obj) do
		if GetObjectBaseName(i.Obj) ~= _ then obj[_] = nil end
		local Screen = WorldToScreen(0,GetOrigin(i.Obj))
		local Screen2 = WorldToScreen(0,i.sPos)
		DrawCircle(GetOrigin(i.Obj),GetHitBox(i.Obj)*.5,3,3,GoS.White)
		DrawText(GetObjectBaseName(i.Obj),30,40,offy,GoS.White)
		offy = offy + 30
		
		--HitBox
		LVector = (Vector(GetOrigin(myHero)) - GetOrigin(i.Obj)):normalized():perpendicular()*GetHitBox(i.Obj)*.5
		local TopD1 = WorldToScreen(0,GetOrigin(i.Obj)+LVector)
		local TopD2 = WorldToScreen(0,GetOrigin(i.Obj)-LVector)
		local BotD1 = WorldToScreen(0,i.sPos+LVector)
		local BotD2 = WorldToScreen(0,i.sPos-LVector)
		DrawLine(Screen2.x,Screen2.y,Screen.x,Screen.y,5,GoS.White)
		DrawLine(TopD1.x,TopD1.y,BotD1.x,BotD1.y,3,GoS.White)
		DrawLine(TopD2.x,TopD2.y,BotD2.x,BotD2.y,3,GoS.White)
		DrawLine(BotD1.x,BotD1.y,BotD2.x,BotD2.y,3,GoS.White)
		DrawCircle(GetOrigin(i.Obj)+LVector,50,3,3,GoS.White)
		DrawCircle(GetOrigin(i.Obj)-LVector,50,3,3,GoS.White)
	end
end)

OnTick( function()
	for _,i in pairs(obj) do
		if GetDistance(myHero,i.Obj) < GetHitBox(myHero)+GetHitBox(i.Obj)*3 then
			if GetDistance(GetOrigin(myHero),GetOrigin(i.Obj)+LVector*2)>GetDistance(GetOrigin(myHero),GetOrigin(i.Obj)-LVector*2) then LVector=LVector*-1 end
			CastSkillShot(2,GetOrigin(myHero)+LVector*2)
		end
		if IMenu[GetObjectBaseName(i.Obj)] and not IMenu[GetObjectBaseName(i.Obj)]["1"] and GetHitBox(i.Obj)>1 then
			IMenu[GetObjectBaseName(i.Obj)]:Info("1",GetHitBox(i.Obj))
		end
	end
end)
