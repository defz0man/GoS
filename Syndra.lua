if myHero.charName ~= "Syndra" then return end

local ver = 2

GetWebResultAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/v/Syndra.version", function()
    if tonumber(data) > ver then
		DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Syndra.lua", SCRIPT_PATH .. "SyndraForPH.lua", function() print("Updated! Reload please!") return	end)
	end
end)

if not FileExist(COMMON_PATH.."runrunrun.lua") then
	DownloadFileAsync("https://raw.githubusercontent.com/Maxxxel/GOS/master/Common/Utility/runrunrun.lua", COMMON_PATH .. "runrunrun.lua", function() require('runrunrun') end)
else
	require('runrunrun')
end

--Load Libs
require("OpenPredict")

--Basic Menu
local SMenu = Menu("Syndra", "Syndra")
--Combo (ON/OFF)
SMenu:SubMenu("c", "Combo")
SMenu.c:Boolean("Q", "Use Q", true)
SMenu.c:Boolean("AQ", "Auto Q immobile", true)
SMenu.c:Boolean("W", "Use W", true)
SMenu.c:Boolean("E", "Use E", true)


--Prediction (Slider)
SMenu:SubMenu("p", "Prediction")
SMenu.p:Slider("hQ", "HitChance Q", 20, 0, 100, 1)
SMenu.p:Slider("hW", "HitChance W", 20, 0, 100, 1)
SMenu.p:Slider("hE", "HitChance E", 20, 0, 100, 1)

--Misc checks (ON/OFF)
SMenu:SubMenu("f", "Farm")
SMenu.f:Boolean("AQ", "Auto Q Laneclear", true)

SMenu:SubMenu("m", "Misc")
SMenu.m:Boolean("D" , "Enable Drawings", true)


local Spell = {
[0] = { delay = .6, speed = 999999, radius = 210, range = 800},
[1] = { delay = 0,  speed = 1450, range = 925 , radius = 220},
[2] = { delay = .35,speed = 1500, range = 725 , width = 140},
[3] = { delay = .5, range = 675},
}

local B = {}
local E = {}
local Immobile = {}
local grab = nil
local qT = 6000
local aB = 0
local gT = 0

local Dmg = {
	[0] = function (unit) return CalcDamage(myHero, unit, 0, 45 * GetCastLevel(myHero,0) + 5  + myHero.ap* .75) end,
	[1] = function (unit) return CalcDamage(myHero, unit, 0, 40 * GetCastLevel(myHero,1) + 40 + myHero.ap * .7) end,
	[2] = function (unit) return CalcDamage(myHero, unit, 0, 45 * GetCastLevel(myHero,2) + 25 + myHero.ap * .4) end,
	[3] = function (unit) return CalcDamage(myHero, unit, 0, (45 * GetCastLevel(myHero,3) + 45 + myHero.ap * .2) * math.min(math.max(aB+3,3),7)) end,
}


DelayAction(function()
	if GetEnemyHeroes()[1] then
		SMenu.c:Menu("RE","Ult Enemies")
		SMenu.c.RE:Boolean("R","Use R",true)
		for _,i in pairs(GetEnemyHeroes()) do
			E[i.name] = i
			SMenu.c.RE:Boolean(i.name,"Ult "..i.charName,true)
			Immobile[i.name] = false
		end
	end
end)

local function CountB()
	local c = 0
	for _,i in pairs(B) do
		c = c + 1
	end
	return c
end

local SReady = {}
local function Check()
	for i = 0,3 do
		SReady[i] = (CanUseSpell(myHero,i) == READY)
	end
	for _,i in pairs(B) do
		if GetTickCount() > _ + qT then
			B[_] = nil
		end
	end
	if GetCastLevel(myHero,3) == 3 and Spell[3].range == 675 then
		Spell[3].range = 750
	end
	if GetCastLevel(myHero,2) == 5 and Spell[2].width == 140 then
		Spell[3].width = 200
	end
	if GetCastLevel(myHero,0) == 5 and qT == 6000 then
		qT = 8000
	end
	if GetCastName(myHero,1) ~= "SyndraW" then grab = true else grab = false end
	aB = CountB()
end
	
local Buff = {}
Buff[5], Buff[8], Buff[11], Buff[21], Buff[22], Buff[24] = true, true, true, true, true, true 

--Modded MixLib Snippet from Ryzuki
local dl = false
if FileExist(COMMON_PATH.."MixLib.lua") then
	require('MixLib')
	LoadMixLib()
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", 
	function() 
	require('MixLib')
	LoadMixLib()
	dl = false
	end)
end

--------------------END OF INIT----------------


OnTick(function (myHero)
	if myHero.dead or dl then return end
	Check()
	local unit = GetCurrentTarget()
	KS()
	AutoQ()
	Combo(unit)
	Farm()
end)

OnDraw(function (myHero)
	if not SMenu.m.D:Value() then return end
	if E[GetCurrentTarget().name] then GetCurrentTarget():Draw(50) end
	myHero:Draw(1300)
	for _,unit in pairs(E) do
		if E[unit.name] then
			unit:DrawDmg(Dmg[3](unit), GoS.Red)
		end
	end
	DrawText(grab or aB,20,myHero.pos2D.x,myHero.pos2D.y,GoS.White)
	for _,i in pairs(B) do
		i:Draw(50)
	end
end)


function Combo(unit)
	if not E[unit.name] then return end
	if Mix:Mode() == "Combo" then
		if unit.isSpellShielded then return end		
		if SMenu.c.W:Value() and SReady[1] and ValidTarget(unit, Spell[1].range*1.3) then
			if grab and gT + 50 < GetTickCount() then
				local WPred = GetCircularAOEPrediction(unit,Spell[1])
				if WPred.hitChance >= SMenu.p.hW:Value()*.01 and GetDistance(unit) <= Spell[1].range then				
					myHero:Cast(1,WPred.castPos)
				end
			elseif not grab then
				for _,b in pairs(B) do
					if GetDistance(b) < Spell[1].range and GetCastName(myHero,1) == "SyndraW" then
						run_once(function() 
						myHero:Cast(1,b.pos) 
						gT = GetTickCount()
						grab = true
						print("Grab1")
						end)
						return
					end
				end
				for _,creep in pairs(minionManager.objects) do
					if ValidTarget(creep,Spell[1].range) and not grab then
						run_once(function() 
						myHero:Cast(1,creep.pos) 
						gT = GetTickCount()
						grab = true
						print("Grab2")
						end)
						break
					end
				end
			end
		end	
		
		if SMenu.c.E:Value() and SReady[2] and SMenu.c.Q:Value() and SReady[0] and ValidTarget(unit, 1300) then
			local EPred = GetPrediction(unit,Spell[2])
			if EPred.hitChance >= SMenu.p.hE:Value()*.01 and GetDistance(unit) <= Spell[2].range then	
				CastSkillShot(0,myHero.pos+(EPred.castPos-myHero.pos):normalized()*150)
				DelayAction(function()
					CastSkillShot(2,EPred.castPos)
				end,.05)
			end
		end
		
		if SMenu.c.Q:Value() and SReady[0] and ValidTarget(unit, Spell[0].range*1.3) then
			local QPred = GetCircularAOEPrediction(unit,Spell[0])
			if QPred.hitChance >= SMenu.p.hQ:Value()*.01 and GetDistance(unit) <= Spell[0].range then				
				CastSkillShot(0,QPred.castPos)
			end
		end	
	end
end

function KS()
	for _,unit in pairs(E) do
		if unit.isSpellShielded then return end
		
		--Q KS
		if SMenu.c.Q:Value() and SReady[0] and ValidTarget(unit, Spell[0].range*1.3) and Dmg[0](unit) > unit.health + unit.shieldAD + unit.shieldAP then
			local QPred = GetPrediction(unit,Spell[0])
			if QPred.hitChance >= SMenu.p.hQ:Value()*.01 and GetDistance(unit) <= Spell[0].range then				
				CastSkillShot(0,QPred.castPos)
			end
		end
		
		--W KS
		if SMenu.c.W:Value() and SReady[1] and ValidTarget(unit, Spell[1].range*1.3) and Dmg[1](unit) > unit.health + unit.shieldAD + unit.shieldAP then
			local WPred = GetCircularAOEPrediction(unit, Spell[1])
			if WPred.hitChance >= SMenu.p.hW:Value()*.01 and GetDistance(unit) <= Spell[1].range then				
				CastSkillShot(2,WPred.castPos)
			end
		end
		
		--R KS
		if SMenu.c.RE.R:Value() and SReady[3] and ValidTarget(unit, Spell[3].range) and Dmg[3](unit) > unit.health + unit.shieldAD + unit.shieldAP and SMenu.c.RE[unit.name]:Value() then
			CastTargetSpell(unit,3)
		end	
	end
end


function AutoQ()
	for _,unit in pairs(E) do
		if Immobile[unit.name] and SMenu.c.AQ:Value() and ValidTarget(unit,Spell[0].range*1.3) then
			local QPred = GetCircularAOEPrediction(unit, Spell[0])
			if QPred.hitChance >= (SMenu.p.hQ:Value()*.01) then			
				CastSkillShot(0,QPred.castPos)
			end
		end
	end
end


function Farm()
	if SMenu.f.AQ:Value() and SReady[0] and Mix:Mode() == "LaneClear" then
		for i,creep in pairs(minionManager.objects) do
			if creep.team ~= MINION_ALLY and ValidTarget(creep,Spell[0].range*1.3) and creep.health < Dmg[0](creep) then
				local QPred = GetCircularAOEPrediction(creep, Spell[0])
				if QPred.hitChance >= (SMenu.p.hQ:Value()*.01) then		
					CastSkillShot(0,QPred.castPos)
					break
				end
			end
		end
	end
end


OnCreateObj(function(Obj)
	if Obj.name == "Seed" then
		B[GetTickCount()] = Obj
	end
end)	

OnDeleteObj(function(Obj)
	if Obj.name == "Seed" then
		B[GetTickCount()] = nil
	end
end)	

OnUpdateBuff(function(unit,buffProc)
	if unit.team == MINION_ENEMY and Buff[buffProc.type] then
		Immobile[unit.name] = true
	end
end)

OnRemoveBuff(function(unit,buffProc)
	if unit.team == MINION_ENEMY and Buff[buffProc.type] then
		Immobile[unit.name] = false
	end
end)


print("Syndra injected")
