local MOUSEEVENTF_RIGHTDOWN     = 0x0008
local MOUSEEVENTF_RIGHTUP       = 0x0010
local KEYEVENTF_KEYUP 			= 0x0002

local Move, Attack, SkillShot, Targeted = _G.MoveToXYZ,_G.AttackUnit,_G.CastSkillShot,_G.CastTargetSpell
local MPos = myHero.pos
local Slot = {[0] = "Q",[1]="W",[2]="E",[3]="R"}

local function click()
	mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
	mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
end


_G.MoveToXYZ = function(x,y,z)
	if MPos and GetDistance(MPos,Vector(x,y,z)) < 100 then return end
	MPos = Vector(x,y,z)
	local p = WorldToScreen(1,MPos)
	local m = GetCursorPos()
	if p.flag then
		SetCursorPos(p.x,p.y)
		click()
		DelayAction(function()
			SetCursorPos(m.x,m.y)
		end,.01)
	end
end

_G.AttackUnit = function(u)
	local p = WorldToScreen(1,u.pos)
	local m = GetCursorPos()
	if p.flag then
		SetCursorPos(p.x,p.y)
		click()
		DelayAction(function()
			SetCursorPos(m.x,m.y)
		end,.01)
	end
	MPos = myHero.pos
end

_G.CastSkillShot = function(s,x,y,z)
	if Ready(s) and not IsChatOpened() and Slot[s] then
		local p = WorldToScreen(1,Vector(x,y,z))
		local m = GetCursorPos()
		local s = string.byte(Slot[s])
		if p.flag then
			SetCursorPos(p.x,p.y)
			keybd_event(s, MapVirtualKey(s, 0), 0, 0)
			keybd_event(s, MapVirtualKey(s, 0), KEYEVENTF_KEYUP, 0)
			DelayAction(function()
				SetCursorPos(m.x,m.y)
			end,.01)
		end
		MPos = myHero.pos
	else
		SkillShot(s,Vector(x,y,z))
		print("Fail")
	end
end

_G.CastTargetSpell = function(u,s)
	if Ready(s) and not IsChatOpened() and Slot[s] then
		local p = WorldToScreen(1,u.pos)
		local m = GetCursorPos()
		local s = string.byte(Slot[s])
		if p.flag then
			SetCursorPos(p.x,p.y)
			keybd_event(s, MapVirtualKey(s, 0), 0, 0)
			keybd_event(s, MapVirtualKey(s, 0), KEYEVENTF_KEYUP, 0)
			DelayAction(function()
				SetCursorPos(m.x,m.y)
			end,.01)
		end
		MPos = myHero.pos
	else
		SkillShot(u,s)
		print("Fail")
	end
end

OnDraw(function()
	if MPos then DrawCircle(MPos,50,0,3,GoS.White) end
end)
