require('Inspired')
require('MapPositionGOS')

OnTick(function(myHero)	
	if Ready(0) and KeyIsDown(string.byte("A")) and GetDistance(GetMousePos(),GetOrigin(myHero))<1500 then
		local mou = GetMousePos()
		local wallEnd = nil
		local wallStart = nil
		if not MapPosition:inWall(mou) then
			--DrawLine(WorldToScreen(0, GetOrigin(myHero)).x, WorldToScreen(0, GetOrigin(myHero)).y, WorldToScreen(0, mou).x, WorldToScreen(0, mou).y, 3, GoS.White)
			local dV = Vector(GetOrigin(myHero))-Vector(mou)
			for i = 1, dV:len(), 5 do
				if MapPosition:inWall(mou+dV:normalized()*i) and not wallEnd then
					wallEnd = Vector(mou+dV:normalized()*i)
				elseif wallEnd and not MapPosition:inWall(Vector(mou+dV:normalized()*i)) then
					wallStart = Vector(mou+dV:normalized()*i)
					--DrawCircle(wallStart,50,0,3,GoS.White)
					break
				end
			end
			if wallEnd and wallStart then
				local WS = WorldToScreen(0,wallStart)
				local WE = WorldToScreen(0,wallEnd)
				if Vector(wallEnd-wallStart):len() < 300 then
					DrawLine(WS.x,WS.y,WE.x,WE.y,3,GoS.Green)
					MoveToXYZ(wallStart)
				else
					DrawLine(WS.x,WS.y,WE.x,WE.y,3,GoS.Red)
					--DrawCircle(wallEnd,50,0,3,GoS.White)
					--DrawCircle(wallStart,50,0,3,GoS.White)
				end
				if GetDistance(GetOrigin(myHero),wallEnd) < 300 then
					CastSkillShot(0,wallEnd)
					DelayAction(function()
						MoveToXYZ(mou)
					end, 0.001)
				end
			end
		end
	end
end)

print("Benzin")
