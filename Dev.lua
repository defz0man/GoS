local o = {}
local s = {}
local ind = 0
local M = Menu("Dev","Dev")
M:SubMenu("G","Global")
M.G:Slider("T","Time for clear",5,1,30,1)
M:SubMenu("S","Spells")
M.S:Boolean("E","Enable",false)
M.S:Boolean("AA", "Exclude AA", true)
M.S:Boolean("oH", "Only Heroes", true)
M.S:Boolean("mH", "Register myHero", true)
M.S:Boolean("rE", "Register Enemy", false)
M.S:Boolean("rA", "Register Ally", false)
M.S:Boolean("pC", "Print Names", false)
M.S:Boolean("sS", "Save SpellInfo", false)
M.S:Info("","-----------")
M.S:Boolean("dSN","Draw SpellName",true)
M.S:Boolean("dSP","Draw StartPos",true)
M.S:Boolean("dEP","Draw EndPos",true)
M.S:Boolean("dL","Draw Line",true)
M.S:Boolean("dD", "Draw Details",false)
M:SubMenu("O","Objects")
M.O:Boolean("E","Enable",false)
M.O:Boolean("oM", "Missiles", true)
M.O:Boolean("omH", "only my Missiles", true)
M.O:Boolean("eO", "Extra objects (me)", false)
M.O:Info("","-----------")
M.O:Boolean("dN", "Draw Name", true)
M.O:Boolean("dH", "Draw HitBox", true)
M.O:Boolean("sO", "Save ObjectInfo", false)
DelayAction(function()
	if GetAllyHeroes()[1] or GetEnemyHeroes()[1] then
		M.O:SubMenu("U","Extra Objects Units")
		M.O.U:Boolean("E","Enable (lag)",false)
		for _,i in pairs(GetAllyHeroes()) do
			M.O.U:Boolean(i.networkID,i.name,false)
		end
		if GetAllyHeroes()[1] and GetEnemyHeroes()[1] then M.O.U:Info("","------------") end
		for _,i in pairs(GetEnemyHeroes()) do
			M.O.U:Boolean(i.networkID,i.name,false)
		end
	end
end)
	
OnProcessSpell(function(unit,spellProc)
	if not M.S.E:Value() then return end
	if M.S.AA:Value() and spellProc.name:lower():find("attack") then return end
	if not unit.isHero and M.S.oH:Value() then return end
	if not ((unit.isMe and M.S.mH:Value()) or (unit.team == MINION_ENEMY and M.S.rE:Value()) or (unit.team == MINION_ALLY and M.S.rA:Value())) then return end
	if M.S.pC:Value() then PrintChat(unit.name.." casted "..spellProc.name) end
	s[GetGameTimer()] = {u = unit, s = spellProc}
	if M.S.sS:Value() then 
		if not M.S.S then M.S:SubMenu("S","Saved Spells") end
		if not M.S.S[spellProc.name] then 
			M.S.S:SubMenu(spellProc.name,spellProc.name) 
			M.S.S[spellProc.name]:Info("1","windUpTime: "..spellProc.windUpTime)
			M.S.S[spellProc.name]:Info("2","animationTime: "..spellProc.animationTime)
			M.S.S[spellProc.name]:Info("3","castSpeed: "..spellProc.castSpeed)
		end
	end
end)

OnDraw(function()
	local off = 0 
	for _,i in pairs(s) do
		if M.S.dSN:Value() and i.s.name then DrawText(i.s.name,20,WorldToScreen(0,i.s.startPos).x,WorldToScreen(0,i.s.startPos).y+off,GoS.White) off = off + 30 end
		if M.S.dSP:Value() and i.s.startPos then DrawCircle(i.s.startPos,50,0,3,GoS.Green) end
		if M.S.dEP:Value() and i.s.endPos then DrawCircle(i.s.endPos,50,0,3,GoS.Red) end
		if M.S.dL:Value() and i.s.endPos and i.s.startPos then DrawLine(WorldToScreen(0,i.s.startPos).x,WorldToScreen(0,i.s.startPos).y,WorldToScreen(0,i.s.endPos).x,WorldToScreen(0,i.s.endPos).y,1,GoS.Yellow) end
		if M.S.dD:Value() then
			if i.s.target and i.s.target.name then DrawText("target: "..i.s.target.name or "none",20,WorldToScreen(0,i.s.startPos).x,WorldToScreen(0,i.s.startPos).y+off,GoS.White) off = off + 30 end
			if i.s.windUpTime  then DrawText("windUpTime: "..i.s.windUpTime,20,WorldToScreen(0,i.s.startPos).x,WorldToScreen(0,i.s.startPos).y+off,GoS.White) off = off + 30 end
			if i.s.animationTime   then DrawText("animationTime: "..i.s.animationTime,20,WorldToScreen(0,i.s.startPos).x,WorldToScreen(0,i.s.startPos).y+off,GoS.White) off = off + 30 end
			if i.s.castSpeed   then DrawText("castSpeed: "..i.s.castSpeed,20,WorldToScreen(0,i.s.startPos).x,WorldToScreen(0,i.s.startPos).y+off,GoS.White) off = off + 30 end
		end
		off = 0
	end
	for _,i in pairs(o) do
		off = 0 
		if M.O.dH:Value() then DrawCircle(i.o.pos,GetHitBox(i.o),3,3,GoS.White) end
		if M.O.dN:Value() then DrawText("name: "..i.o.name,20,i.o.pos2D.x,i.o.pos2D.y+off,GoS.White) off = off + 30 end
	end
end)

OnCreateObj(function(Object)
	if not M.O.E:Value() then return end
	local found = false
	DelayAction(function()
		if Object.name == "missile" and M.O.oM:Value() and Object.isSpell then
			--if M.O.omH:Value() and not Object.spellOwner.isMe then return end
			found = true
		else
			if M.O.eO:Value() and GetObjectBaseName(Object):lower():find(GetObjectName(myHero):lower()) then found = true end
			if M.O.U.E:Value() then
				for _,i in pairs(GetAllyHeroes()) do 
					if M.O.U[i.networkID]:Value() and GetObjectBaseName(Object):lower():find(GetObjectName(i):lower()) then found = true end
				end
				for _,i in pairs(GetEnemyHeroes()) do 
					if M.O.U[i.networkID]:Value() and GetObjectBaseName(Object):lower():find(GetObjectName(i):lower()) then found = true end
				end
			end
		end
		if not found then return end
		--print(Object.spellName)
		o[GetGameTimer()] = {o = Object, n = Object.charName}
		if M.O.sO:Value() then
			if not M.O.O then M.O:SubMenu("O","Saved Objects") end
			if Object.name == "missile" then n = Object.spellName else n = Object.name end
			if M.O.O[n] then return end
			M.O.O:SubMenu(n,n) 
			M.O.O[n]:Info("1","HitBox: "..GetHitBox(Object))
			if Object and Object.isSpell then
				--if Object.spellOwner then M.O.O[n]:Info("2","Owner: ".. Object.spellOwner) end
				M.O.O[n]:Info("3","SpellName: "..Object.spellName)
			end
		end
	end)
end)

OnTick(function()
	for _,i in pairs(s) do
		if _ + M.G.T:Value() < GetGameTimer() then 
			s[_] = nil
		end
	end
		for _,i in pairs(o) do
		if _ + M.G.T:Value() < GetGameTimer() or i.o.name ~= i.n then 
			o[_] = nil
		end
	end
end)
