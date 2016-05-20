local smite = (GetCastName(myHero,4):lower():find("smite") and 4) or (GetCastName(myHero,5):lower():find("smite") and 5) or nil
if not smite then return end

local smiteD = {390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000}
local smiteP = function() return 20 + 8*myHero.level end
local s1 = {}
local s2 = {}
local EpicJgl = {["SRU_Baron"]="Baron", ["SRU_Dragon"]="Dragon", ["TT_Spiderboss"]="Vilemaw"}
local BigJgl = {["SRU_Red"]="Red Buff", ["SRU_Blue"]="Blue Buff", ["SRU_Krug"]="Krugs", ["SRU_Murkwolf"]="Wolves", ["SRU_Razorbeak"]="Razor", ["SRU_Gromp"]="Gromp", ["Sru_Crab"]="Scuttles"}

local SMenu = Menu("Quick_Smite","Quick Smite")
SMenu:Boolean("E","Enable", true)
SMenu:SubMenu("M","Epic Mobs")
SMenu:SubMenu("B","Big Mobs")
SMenu:Boolean("F","Faster smite",true)
SMenu:Boolean("D","Draw missing Dmg",true)
SMenu:Boolean("K", "Killsteal", true)
for _,i in pairs(EpicJgl) do
	SMenu.M:Boolean(_,i,true)
end
for _,i in pairs(BigJgl) do
	SMenu.B:Boolean(_,i,false)
end

OnTick(function()
	if not SMenu.E:Value() then return end
	if SMenu.K:Value() and GetCastName(myHero,smite) == "S5_SummonerSmitePlayerGanker" then
		local sP = smiteP()
		for _,i in pairs(GetEnemyHeroes()) do
			if i.valid and i.distance < 675 and i.health < sP then
				CastTargetSpell(i,smite)
			end
		end
	end
	for _,i in pairs(s1) do
		if i.valid and i.distance < 1000 and ((SMenu.B[_] and SMenu.B[_] :Value()) or (SMenu.M[_] and SMenu.M[_]:Value()) or (_:find("Dragon") and SMenu.M["SRU_Dragon"])) then
			s2[_] = i
		else
			s2[_] = nil
		end
	end
	if not SMenu.F:Value() and CanUseSpell(myHero,smite) == READY then
		for _,i in pairs(s2) do
			if i.health < smiteD[myHero.level] and i.distance <= 675 then
				CastTargetSpell(i,smite)
			end
		end
	end
end)

OnDraw(function()
	if SMenu.F:Value() and CanUseSpell(myHero,smite) == READY then
		for _,i in pairs(s2) do
			if SMenu.D:Value() then
					i:Draw(59)
					DrawText(math.floor(i.health-smiteD[myHero.level]),20,i.pos2D.x,i.pos2D.y,GoS.White)
				end
			if i.health < smiteD[myHero.level] and i.distance <= 675 then
				CastTargetSpell(i,smite)
			end
		end
	end
end)

OnCreateObj(function(obj)
	if (EpicJgl[obj.charName] and SMenu.M[obj.charName]) or (BigJgl[obj.charName] and SMenu.B[obj.charName]) or (obj.charName:lower():find("dragon") and SMenu.M["SRU_Dragon"]:Value()) then
		s1[obj.charName] = obj
	end
end)

OnObjectLoad(function(obj)
	if (EpicJgl[obj.charName] and SMenu.M[obj.charName]) or (BigJgl[obj.charName] and SMenu.B[obj.charName]) or (obj.charName:lower():find("dragon") and SMenu.M["SRU_Dragon"]:Value()) then
		s1[obj.charName] = obj
	end
end)
