if GetObjectName(GetMyHero()) ~= "Soraka" then return end

require("Inspired")

local Config = Menu("Soraka", "Soraka")

Config:SubMenu("c", "Combo")
Config.c:Boolean("Q", "Use Q", true)
Config.c:Boolean("E", "Use E", true)

Config:SubMenu("h","Heal")
Config.h:Boolean("AW", "Auto use W", true)
Config.h:Boolean("AR", "Auto use R", true)

Config:SubMenu("m", "Misc")
Config.m:Boolean("D" , "Enable Drawings", true)



OnTick(function (myHero)
	if not IsDead(myHero) then
	local unit=GetCurrentTarget()
		heals()
	end
end)

function heals()
	for i=1,
end

print("Raka injected - Logge")
