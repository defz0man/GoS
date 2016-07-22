if myHero.charName ~= "Tryndamere" then return end
require("OpenPredict")
if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end
local rTime = 0
local EData = {delay = 0.050, range = 660, radius = 225, speed = 1300}
local asdf = Menu("T","T")
asdf:Boolean("Q","Q",true)
asdf:Slider("QH","QPercent",30,0,100,1)
asdf:Boolean("W","W",true)
asdf:Boolean("E","E",true)
asdf:Boolean("R","R",true)
asdf:Slider("RH","RPercent",5,0,100,1)

OnTick(function()
	if GetPercentHP(myHero) < asdf.RH:Value() and EnemiesAround(myHero,1000)>0 and asdf.R:Value() then
		CastSpell(3)
	end
	if Ready(0) and rTime - GetGameTimer() < .2 and not myHero.isRecalling and asdf.Q:Value() and asdf.QH:Value() > GetPercentHP(myHero) then
		CastSpell(0)
	end
	if Mix:Mode() == "Combo" then
		local target = GetCurrentTarget()
		if Ready(2) and ValidTarget(target,660) and asdf.E:Value() and target.distance > 150 then
			CastSkillShot(2,GetPrediction(target,EData).castPos)
		end
		if Ready(1) and ValidTarget(target,1000) then
			CastSpell(1)
		end
	end
end)	
OnUpdateBuff(function(unit,buffProc)
	if unit.isMe and buffProc.Name == "UndyingRage" then
		rTime = buffProc.ExpireTime
	end
end)
OnRemoveBuff(function(unit,buffProc)
	if unit.isMe and buffProc.Name == "UndyingRage" then
		rTime = buffProc.ExpireTime
	end
end)
