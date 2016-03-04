if GetObjectName(GetMyHero()) ~= "Aatrox" then return end

require ('Inspired')
require ('OpenPredict')

Callback.Add("Load", function()
  Aatrox()
end)

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
	self.cMenu = Menu("Aatrox", "Aatrox")
	self.cMenu:SubMenu("C", "Combo")
	self.cMenu.C:Boolean("Q", "Use Q", true)
	self.cMenu.C:Boolean("W", "Use W", true)
	self.cMenu.C:Slider("WT", "Toggle W at % HP", 45, 5, 90, 5)
	self.cMenu.C:Boolean("E", "Use E", true)
	self.cMenu.C:Boolean("R", "Use R", true)
	self.cMenu.C:Slider("RE", "Use R if x enemies", 2, 1, 5, 1)
	
	self.cMenu:SubMenu("KS", "Killsteal")
	self.cMenu.KS:Boolean("Enable", "Enable Killsteal", true)
	self.cMenu.KS:Boolean("Q", "Use Q", false)
	self.cMenu.KS:Boolean("E", "Use E", true)
	
	self.cMenu:SubMenu("p", "Prediction")
	self.cMenu.p:Slider("hQ", "HitChance Q", 20, 0, 100, 1)
	self.cMenu.p:Slider("hE", "HitChance E", 20, 0, 100, 1)
	
	self.cMenu:SubMenu("A", "AutoLvl")
	self.cMenu.A:Boolean("aL", "Use AutoLvl", true)
	self.cMenu.A:DropDown("aLS", "AutoLvL", 1, {"Q-W-E","Q-E-W"})
	self.cMenu.A:Slider("sL", "Start AutoLvl with LvL x", 1, 1, 18, 1)
	self.cMenu.A:Boolean("hL", "Humanize LvLUP", true)

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
	
	--AutoLvl
	self.lTable={
	[1]={_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
	[2]={_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}
	}
	
	--Var
	self.W = nil
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
	if IsDead(myHero) then return end
	
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
		elseif Mode == "Laneclear" then
			self:LaneClear()
		elseif Mode == "LastHit" then
			self:LastHit()
		elseif Mode == "Harass" then
			self:Harass()
		else
			return
		end
		
		self:Lvl()
		
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
	if self.SReady[0] and ValidTarget(target, self.Spell[0].range*1.1) and self.cMenu.C.Q:Value() then
		local Pred = GetCircularAOEPrediction(target, self.Spell[0])
		if Pred.hitChance >= self.cMenu.p.hQ:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < self.Spell[0].range then
			CastSkillShot(0,Pred.castPos)
		end
	end
	if self.SReady[1] and self.cMenu.C.W:Value() then
		if GetPercentHP(myHero) < self.cMenu.C.WT:Value()+1 and self.W == "dmg" then
			CastSpell(1)
		elseif GetPercentHP(myHero) > self.cMenu.C.WT:Value()+	1 and self.W == "heal" then
			CastSpell(1)
		end
	end
	if self.SReady[2] and ValidTarget(target, self.Spell[2].range*1.1) and self.cMenu.C.E:Value() then
		local Pred = GetPrediction(target, self.Spell[2])
		if Pred.hitChance >= self.cMenu.p.hE:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < self.Spell[2].range then
			CastSkillShot(2,Pred.castPos)
		end
	end
	if self.SReady[3] and ValidTarget(target, 550) and self.cMenu.C.R:Value() and EnemiesAround(myHero,550) >= self.cMenu.C.RE:Value() then
		local Pred = GetPrediction(target, self.Spell[2])
		if Pred.hitChance >= self.cMenu.p.hE:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < self.Spell[2].range then
			CastSkillShot(2,Pred.castPos)
		end
	end
end

function Aatrox:Lvl()
	if self.cMenu.A.aL:Value() and GetLevelPoints(myHero) >= 1 and GetLevel(myHero) >= self.cMenu.A.sL:Value() then
		if self.cMenu.A.hL:Value() then
			DelayAction(function() LevelSpell(self.lTable[self.cMenu.A.aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(0.500,0.750))
		else
			LevelSpell(self.lTable[self.cMenu.A.aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1])
		end
	end
end

function Aatrox:KS()
	if not self.cMenu.KS.Enable:Value() then return end
	for _,unit in pairs(GetEnemyHeroes()) do
		if GetCurrentHP(unit) + GetDmgShield(unit) < CalcDamage(myHero,unit, self.DmgR[0](), 0) and self.SReady[0] and ValidTarget(unit, self.Spell[0].range*1.1) and self.cMenu.KS.Q:Value() then
			local Pred = GetCircularAOEPrediction(unit, self.Spell[0])
			if Pred.hitChance >= self.cMenu.p.hQ:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < self.Spell[0].range then
				CastSkillShot(0,Pred.castPos)
			end
		end
		if GetCurrentHP(unit) + GetDmgShield(unit) < CalcDamage(myHero,unit, 0, self.DmgR[2]()) and self.SReady[2] and ValidTarget(unit, self.Spell[2].range*1.1) and self.cMenu.KS.E:Value() then
			local Pred = GetPrediction(unit, self.Spell[2])
			if Pred.hitChance >= self.cMenu.p.hE:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < self.Spell[2].range then
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
		
PrintChat("Aatrox Loaded")