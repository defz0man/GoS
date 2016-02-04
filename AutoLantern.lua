require('Inspired')
local tr = false
for _,i in pairs(GetAllyHeroes()) do
	if GetObjectName(i)=="Thresh" then
		tr = true
		break
	end
end
if not tr then return end

local lantern = nil
local Lt = nil
local LMenu = Menu("AL","AutoLantern")
LMenu:Boolean("PL","AutoPick Lantern",true)
LMenu:Boolean("PC","AutoPick in Combo",true)
LMenu:Slider("PH", "AutoPick when lower than", 30, 0, 100, 1)

OnTick(function(myHero)
	if lantern and GetTeam(lantern) == MINION_ALLY and GetDistance(GetOrigin(lantern))<280 and LMenu.PL:Value() and (KeyIsDown(32) or not LMenu.PC:Value() or LMenu.PH:Value()>GetPercentHP(myHero)) then
		Interact(lantern)
	end
	if Lt and GetTickCount()-Lt>5900 then
	Lt = nil
	end
end)


OnDraw(function(myHero)
	if Lt and lantern then
	local lS = WorldToScreen(0, GetOrigin(lantern))
		DrawText(6-math.floor(GetTickCount()-Lt)*.001,30,lS.x,lS.y+10,GoS.White)
	end
end)


OnCreateObj(function(Object)
	if GetObjectBaseName(Object)=="ThreshLantern" then
		Lt = GetTickCount()
		lantern = Object
		DelayAction(function() lantern = nil Lt = nil end, 6)
	end
end)

OnDeleteObj(function(Object,myHero)
	if GetObjectBaseName(Object)=="ThreshLantern" then 
		lantern = nil
	end
end)

print("AutoLantern loaded")
