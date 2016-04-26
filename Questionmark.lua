--Supported Champs
local c = {
	["Aatrox"] = true,
}
version = .02
local myHeroName = GetObjectName(myHero)

if c[myHeroName] then
	
	require ('Inspired')
	require ('OpenPredict')

	Callback.Add("Load", 
	function()	
		Update()
		cMenu = Menu(myHeroName, "|?| "..myHeroName)
		_G[myHeroName]()
		Items()
		LvL()
		Skin()
		DmgDraw()
		PrintChat("|?| "..myHero.charName.." Loaded")
	end)

else
	PrintChat("|?| "..myHeroName" not supported")
	return
end

class "Aatrox"

function Aatrox:__init()
	
	--OpenPred
	self.Spell = { 
	[0] = { delay = 0.2, range = 650, speed = 1500, radius = 113 },
	[2] = { delay = 0.1, range = 1000, speed = 1000, width = 150 }
	}
	
	--SpellDmg
	self.DmgR = {
	[0] = function () return 35 + GetCastLevel(myHero,0)*45 + GetBonusDmg(myHero)*.6 end,
	[1] = function () return 25 + GetCastLevel(myHero,1)*35 + GetBonusDmg(myHero) end,
	[2] = function () return 35 + GetCastLevel(myHero,2)*35 + GetBonusDmg(myHero)*.6 + GetBonusAP(myHero)*.6 end,
	[3] = function () return 100 + GetCastLevel(myHero,3)*100 + GetBonusAP(myHero) end,
	}
	
	--Menu
	--cMenu = Menu("Aatrox", "|?| Aatrox")
	cMenu:SubMenu("C", "Combo")
	cMenu.C:Boolean("Q", "Use Q", true)
	cMenu.C:Boolean("W", "Use W", true)
	cMenu.C:Slider("WT", "Toggle W at % HP", 45, 5, 90, 5)
	cMenu.C:Boolean("E", "Use E", true)
	cMenu.C:Boolean("R", "Use R", true)
	cMenu.C:Slider("RE", "Use R if x enemies", 2, 1, 5, 1)
	
	cMenu:SubMenu("KS", "Killsteal")
	cMenu.KS:Boolean("Enable", "Enable Killsteal", true)
	cMenu.KS:Boolean("Q", "Use Q", false)
	cMenu.KS:Boolean("E", "Use E", true)
	
	cMenu:SubMenu("p", "Prediction")
	cMenu.p:Slider("hQ", "HitChance Q", 20, 0, 100, 1)
	cMenu.p:Slider("hE", "HitChance E", 20, 0, 100, 1)

	--Callbacks
	Callback.Add("Tick", function() self:Tick() end)
	--Callback.Add("Draw", function self:Draw() end)
	Callback.Add("UpdateBuff", function(unit,buff) self:Stat(unit,buff) end)
	
	
	--SpellStatus
	self.SReady = {
	[0] = false,
	[1] = false,
	[2] = false,
	[3] = false,
	}
	
	--Var
	self.W = "heal"
end  

function Aatrox:SpellCheck()	--SpellCheck
	for s = 0,3 do 
		if CanUseSpell(myHero,s) == READY then
			self.SReady[s] = true
		else 
			self.SReady[s] = false
		end
	end
end

function Aatrox:Tick()
	if myHero.dead then return end
	
	if (_G.IOW or _G.DAC_Loaded) then
		
		self:SpellCheck()
		
		self:KS()
		
		local Mode = nil
		if _G.DAC_Loaded then 
			Mode = DAC:Mode()
		elseif _G.IOW then
			Mode = IOW:Mode()
		end

		if Mode == "Combo" then
			self:Combo()
		--[[elseif Mode == "Laneclear" then
			self:LaneClear()
		elseif Mode == "LastHit" then
			self:LastHit()
		elseif Mode == "Harass" then
			self:Harass()--]]
		else
			return
		end
	end
end


function Aatrox:Combo()

	local target = nil
	if _G.DAC_Loaded then
		target = DAC:GetTarget() 
	elseif _G.IOW then
		target = GetCurrentTarget()
	else
		return
	end
	if self.SReady[0] and ValidTarget(target, self.Spell[0].range*1.1) and cMenu.C.Q:Value() then
		local Pred = GetCircularAOEPrediction(target, self.Spell[0])
		if Pred.hitChance >= cMenu.p.hQ:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < self.Spell[0].range then
			CastSkillShot(0,Pred.castPos)
		end
	end
	if self.SReady[1] and cMenu.C.W:Value() and ValidTarget(target,400) then
		if GetPercentHP(myHero) < cMenu.C.WT:Value()+1 and self.W == "dmg" then
			CastSpell(1)
		elseif GetPercentHP(myHero) > cMenu.C.WT:Value()+	1 and self.W == "heal" then
			CastSpell(1)
		end
	end
	if self.SReady[2] and ValidTarget(target, self.Spell[2].range*1.1) and cMenu.C.E:Value() then
		local Pred = GetPrediction(target, self.Spell[2])
		if Pred.hitChance >= cMenu.p.hE:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < self.Spell[2].range then
			CastSkillShot(2,Pred.castPos)
		end
	end
	if self.SReady[3] and ValidTarget(target, 550) and cMenu.C.R:Value() and EnemiesAround(myHero,550) >= cMenu.C.RE:Value() then
		local Pred = GetPrediction(target, self.Spell[2])
		if Pred.hitChance >= cMenu.p.hE:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < self.Spell[2].range then
			CastSkillShot(2,Pred.castPos)
		end
	end
end

function Aatrox:KS()
	if not cMenu.KS.Enable:Value() then return end
	for _,unit in pairs(GetEnemyHeroes()) do
		if GetCurrentHP(unit) + GetDmgShield(unit) < CalcDamage(myHero,unit, self.DmgR[0](), 0) and self.SReady[0] and ValidTarget(unit, self.Spell[0].range*1.1) and cMenu.KS.Q:Value() then
			local Pred = GetCircularAOEPrediction(unit, self.Spell[0])
			if Pred.hitChance >= cMenu.p.hQ:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < self.Spell[0].range then
				CastSkillShot(0,Pred.castPos)
			end
		end
		if GetCurrentHP(unit) + GetDmgShield(unit) < CalcDamage(myHero,unit, 0, self.DmgR[2]()) and self.SReady[2] and ValidTarget(unit, self.Spell[2].range*1.1) and cMenu.KS.E:Value() then
			local Pred = GetPrediction(unit, self.Spell[2])
			if Pred.hitChance >= cMenu.p.hE:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < self.Spell[2].range then
				CastSkillShot(2,Pred.castPos)
			end
		end
	end
end

function Aatrox:Stat(unit, buff)
	if unit == myHero and buff.Name:lower() == "aatroxwlife" then
		self.W = "heal"
	elseif unit == myHero and buff.Name:lower() == "aatroxwpower" then
		self.W = "dmg"
	end
end
--------AATROX END-------

class 'Skin'

function Skin:__init()

	cMenu:SubMenu("S", "|?| Skin")
	cMenu.S:Boolean("uS", "Use Skin", false)
	cMenu.S:Slider("sV", "Skin Number", 0, 0, 10, 1)
	
	local cSkin = 0
	
	Callback.Add("Tick", function() self:Change() end)
end

function Skin:Change()
	if cMenu.S.uS:Value() and cMenu.S.sV:Value() ~= cSkin then
		HeroSkinChanger(myHero,cMenu.S.sV:Value()) 
		cSkin = cMenu.S.sV:Value()
	end
end

class 'LvL'

function LvL:__init()
	cMenu:SubMenu("A", "|?| Auto Level")
	cMenu.A:Boolean("aL", "Use AutoLvl", true)
	cMenu.A:DropDown("aLS", "AutoLvL", 1, {"Q-W-E","Q-E-W","W-Q-E","W-E-Q","E-Q-W","E-W-Q"})
	cMenu.A:Slider("sL", "Start AutoLvl with LvL x", 4, 1, 18, 1)
	cMenu.A:Boolean("hL", "Humanize LvLUP", true)
	
	--AutoLvl
	self.lTable={
	[1] = {_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
	[2] = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W},
	[3] = {_W,_Q,_E,_W,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E},
	[4] = {_W,_E,_Q,_W,_W,_R,_W,_E,_W,_E,_R,_E,_E,_Q,_Q,_R,_Q,_Q},
	[5] = {_E,_Q,_W,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W},
	[6] = {_E,_W,_Q,_E,_E,_R,_E,_W,_E,_W,_R,_W,_W,_Q,_Q,_R,_Q,_Q},
	}
	
	Callback.Add("Tick", function() self:Do() end)
end

function LvL:Do()
	if cMenu.A.aL:Value() and GetLevelPoints(myHero) >= 1 and GetLevel(myHero) >= cMenu.A.sL:Value() then
		if cMenu.A.hL:Value() then
			DelayAction(function() LevelSpell(self.lTable[cMenu.A.aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(.5,.8))
		else
			LevelSpell(self.lTable[cMenu.A.aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1])
		end
	end
end


class 'Items'

function Items:__init()

	cMenu:SubMenu("I", "|?| Items")
	cMenu.I:Boolean("uI", "Use Items", true)
	cMenu.I:Boolean("uAD", "Use AD Items", true)
	cMenu.I:Boolean("uAA", "Use AA Reset Items", true)
	cMenu.I:Boolean("uAP", "Use AP Items", true)
	cMenu.I:Boolean("uTA", "Use Tank Items", true)
	cMenu.I:Boolean("uDE", "Use Defensive Items (self)", true)
	cMenu.I:Slider("uDEP", "Use Defensive a % HP (self)", 20, 5, 90, 5)
	cMenu.I:Boolean("uADE", "Use Defensive Items (allies)", true)
	cMenu.I:Slider("uADEP", "Use Defensive a % HP (allies)", 20, 5, 90, 5)
	
	
	self.AD = {3144,3153,3142}
	self.AA = {3077,3074,3748}
	self.AP = {3146,3092,3290}
	self.DE = {3040,3048}
	self.ADE = {3401,3222,3190}
	self.CC = {3139,3140,3137}
	self.TA = {3143,3800}
	self.Banner = 3060
	--self.HG = soon
	
	Callback.Add("Tick", function() self:Use() end)
	Callback.Add("ProcessSpellAttack", function(Object,spellProc) self:AAReset(Object,spellProc) end)
	
end

function Items:Use()

	if not cMenu.I.uI then return end
	
	local target = nil
	if _G.DAC_Loaded then
		target = DAC:GetTarget() 
	elseif _G.IOW then
		target = GetCurrentTarget()
	else
		return
	end
	
	if ValidTarget(target,550) and cMenu.I.uAD:Value() then
		for i = 1,#self.AD do
			local l = GetItemSlot(myHero,self.AD[i])
			if l>0 and CanUseSpell(myHero,l) == READY then
				CastTargetSpell(target,l)
			end
		end
	end
	
	if ValidTarget(target,500) and cMenu.I.uTA:Value() then
		for i = 1,#self.TA do
			local l = GetItemSlot(myHero,self.TA[i])
			if l>0 and CanUseSpell(myHero,l) == READY then
				CastSpell(target,l)
			end
		end
	end
	
	if ValidTarget(target,700) and cMenu.I.uAP:Value() then
		for i = 1,#self.AP do
			local l = GetItemSlot(myHero,self.AP[i])
			if l>0 and CanUseSpell(myHero,l) == READY then
				CastTargetSpell(target,l)
			end
		end
	end
	
	if GetPercentHP(myHero) < cMenu.I.uDEP:Value() and cMenu.I.uDE:Value() and EnemiesAround(myHero,800) > 0 then
		for i = 1,#self.DE do
			local l = GetItemSlot(myHero,self.DE[i])
			if l>0 and CanUseSpell(myHero,l) == READY then
				CastSpell(l)
			end
		end
	end
	
	if cMenu.I.uDEP:Value() then
		for _,n in pairs(GetAllyHeroes()) do
			if GetPercentHP(n) <= cMenu.I.uADEP:Value() and EnemiesAround(n,800) > 0 then 
				for i = 1,#self.ADE do
					local l = GetItemSlot(myHero,self.ADE[i])
					if l>0 and CanUseSpell(myHero,l) == READY then
						CastSpell(l)
					end
				end
			end
		end
	end
	
end

function Items:AAReset(Object,spellProc)
	local ta = spellProc.target
	if cMenu.I.uAA:Value() and Object == myHero and GetObjectType(ta) == Obj_AI_Hero and GetTeam(ta) == MINION_ENEMY then
		for i = 1,#self.AA do
			local l = GetItemSlot(myHero,self.AA[i])
			if l>0 and CanUseSpell(myHero,l) == READY then
				CastSpell(l)
			end 
		end
	end
end


class 'Update'

function Update:__init()

	self.webV = "Error"
	self.Stat = "Error"
	self.Do = true

	function AutoUpdate(data)
		if tonumber(data) > version then
			self.webV = data
			self.State = "|?| Update to v"..self.webV
			Callback.Add("Draw", function() self:Box() end)
			Callback.Add("WndMsg", function(key,msg) self:Click(key,msg) end)
		end
	end

	GetWebResultAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Questionmark.version", AutoUpdate)
end

function Update:Box()
	if not self.Do then return end
	local cur = GetCursorPos()
	FillRect(0,0,360,85,GoS.Red)
	if cur.x < 350 and cur.y < 75 then
		FillRect(0,0,350,75,GoS.White)
	else
		FillRect(0,0,350,75,GoS.Black)
	end
	
	DrawText(self.State, 40, 10, 10, GoS.Green)
	
	FillRect(360,10,50,60,GoS.Red)
	FillRect(365,15,40,50,GoS.White)
	if cur.x < 370 or cur.x > 400 or cur.y<7 or cur.y > 60 then
		DrawText("X", 60, 370,7, GoS.Black)
	else
		DrawText("X", 60, 370,7, GoS.Red)
	end
	
end

function Update:Click(key,msg)
	local cur = GetCursorPos()
	if key == 513 and cur.x < 350 and cur.y < 75 then
		self.State = "Downloading..."
		DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Questionmark.lua", SCRIPT_PATH .. "Questionmark.lua", function() self.State = "Update Complete" PrintChat("Reload the Script with 2x F6") return	end)
	elseif key == 513 and cur.x > 370 and cur.x < 400 and cur.y > 7 and cur.y < 60 then
		Callback.Del("Draw", function() self:Box() end)
		self.Do = false
	end
end


class 'DmgDraw'

function DmgDraw:__init()
	require('DamageLib')

	self.dmgSpell = {}
	self.spellName= {"Q","W","E","R"} 
	self.dC = { {200,255,255,0}, {200,0,255,0}, {200,255,0,0}, {200,0,0,255} }
	self.aa = {}
	self.dCheck = {}
	self.dX = {}
	cMenu:SubMenu("D","|?| Draw Damage")
	cMenu.D:Boolean("dAA","Count AA to kill", true)
	cMenu.D:Boolean("dAAc","Consider Crit", true)
	cMenu.D:Slider("dR","Draw Range", 1500, 500, 3000, 100)

	for i=1,4,1 do
		if getdmg(self.spellName[i],myHero,myHero,1,3)~=0 then
			cMenu.D:Boolean(self.spellName[i], "Draw "..self.spellName[i], true)
			cMenu.D:ColorPick(self.spellName[i].."c", "Color for "..self.spellName[i], self.dC[i])
		end
	end

	DelayAction( function()
		for _,champ in pairs(GetEnemyHeroes()) do
			self.dmgSpell[GetObjectName(champ)]={0, 0, 0, 0}
			self.dX[GetObjectName(champ)] = {{0,0}, {0,0}, {0,0}, {0,0}}
		end
	end, 0.001)
	
	Callback.Add("Tick", function() self:Set() end)
	Callback.Add("Draw", function() self:Draw() end)
	
end

function DmgDraw:Set()
	for _,champ in pairs(GetEnemyHeroes()) do
		self.dCheck[GetObjectName(champ)]={false,false,false,false}
		local last = GetPercentHP(champ)*1.04
		local lock = false
		for i=1,4,1 do
			if cMenu.D[self.spellName[i]] and cMenu.D[self.spellName[i]]:Value() and Ready(i-1) and GetDistance(GetOrigin(myHero),GetOrigin(champ)) < cMenu.D.dR:Value() then
				self.dmgSpell[GetObjectName(champ)][i] = getdmg(self.spellName[i],champ,myHero,GetCastLevel(myHero,i-1))
				self.dCheck[GetObjectName(champ)][i]=true
			else 
				self.dmgSpell[GetObjectName(champ)][i] = 0
				self.dCheck[GetObjectName(champ)][i]=false
			end
			self.dX[GetObjectName(champ)][i][2] = self.dmgSpell[GetObjectName(champ)][i]/(GetMaxHP(champ)+GetDmgShield(champ))*104
			self.dX[GetObjectName(champ)][i][1] = last - self.dX[GetObjectName(champ)][i][2]
			last = last - self.dX[GetObjectName(champ)][i][2]
			if lock then
				self.dX[GetObjectName(champ)][i][1] = 0 
				self.dX[GetObjectName(champ)][i][2] = 0
			end
			if self.dX[GetObjectName(champ)][i][1]<=0 and not lock then
				self.dX[GetObjectName(champ)][i][1] = 0 
				self.dX[GetObjectName(champ)][i][2] = last + self.dX[GetObjectName(champ)][i][2]
				lock = true
			end
		end
		if cMenu.D.dAA:Value() and cMenu.D.dAAc:Value() then 
			self.aa[GetObjectName(champ)] = math.ceil(GetCurrentHP(champ)/(CalcDamage(myHero, champ, GetBaseDamage(myHero)+GetBonusDmg(myHero),0)*(GetCritChance(myHero)+1)))
		elseif cMenu.D.dAA:Value() and not cMenu.D.dAAc:Value() then 
			self.aa[GetObjectName(champ)] = math.ceil(GetCurrentHP(champ)/(CalcDamage(myHero, champ, GetBaseDamage(myHero)+GetBonusDmg(myHero),0)))
		end
	end
end

function DmgDraw:Draw()
	for _,champ in pairs(GetEnemyHeroes()) do
		
		local bar = GetHPBarPos(champ)
		if bar.x ~= 0 and bar.y ~= 0 then
			for i=4,1,-1 do
				if self.dCheck[GetObjectName(champ)] and self.dCheck[GetObjectName(champ)][i] then
					FillRect(bar.x+self.dX[GetObjectName(champ)][i][1],bar.y,self.dX[GetObjectName(champ)][i][2],9,cMenu.D[self.spellName[i].."c"]:Value())
					FillRect(bar.x+self.dX[GetObjectName(champ)][i][1],bar.y-1,2,11,GoS.Black)
				end
			end
			if cMenu.D.dAA:Value() and bar.x ~= 0 and bar.y ~= 0 and self.aa[GetObjectName(champ)] then 
				DrawText(self.aa[GetObjectName(champ)].." AA", 15, bar.x + 75, bar.y + 25, GoS.White)
			end
		end
	end
end
