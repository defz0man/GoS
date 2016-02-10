require('Inspired')

local mixed = {"Akali","Corki","Ekko","Evelynn","Ezreal","Kayle","Kennen","KogMaw","Malzahar","MissFortune","Mordekaiser","Pantheon","Poppy","Shaco","Skarner","Teemo","Tristana","TwistedFate","XinZhao","Yoric"}
local 	ad = {"Aatrox","Corki","Darius","Draven","Ezreal","Fiora","Gangplank","Garen","Gnar","Graves","Hecarim","Illaoi","Irelia","JarvanIV","Jax","Jayce","Jinx","Kalista","KhaZix","KogMaw","LeeSin","Lucian","MasterYi","MissFortune","Nasus","Nocturne","Olaf","Pantheon","Quinn","RekSai","Renekton","Rengar","Riven","Shaco","Shyvana","Sion","Sivir","Talon","Tristana","Trundle","Tryndamere","Twitch","Udyr","Urgot","Varus","Vayne","Vi","Warwick","Wukong","XinZhao","Yasuo","Yoric","Zed"}
local 	ap = {"Ahri","Akali","Alistar","Amumu","Anivia","Annie","Azir","Bard","Blitzcrank","Brand","Braum","Cassiopea","ChoGath","Diana","DrMundo","Ekko","Elise","Evelynn","Fiddlesticks","Fizz","Galio","Gragas","Heimerdinger","Janna","Karma","Karthus","Kassadin","Katarina","Kayle","Kennen","LeBlanc","Leona","Lissandra","Lulu","Lux","Malphite","Malzahar","Maokai","Mordekaiser","Morgana","Nami","Nautilus","Nidalee","Nunu","Orianna","Poppy","Rammus","Rumble","Ryze","Sejuani","Shen","Singed","Skarner","Sona","Soraka","Swain","Syndra","TahmKench","Taric","Teemo","Thresh","TwistedFate","Veigar","VelKoz","Viktor","Vladimir","Volibear","Xerath","Zac","Ziggz","Zilean","Zyra"}
local norm = false
local magi = false
local bestUnit = nil
local bestHP = math.huge

for i=1,#mixed do
	if mixed[i]==GetObjectName(myHero) then
		norm = true
		print("AD Hero detected")
	end
end
for i=1,#ad do
	if ad[i]==GetObjectName(myHero) then
		norm = true
		print("AD Hero detected")
	end
end
for i=1,#ap do
	if ap[i]==GetObjectName(myHero) then
		magi = true
		print("AP Hero detected")
	end
end

--100/100+Resistance
OnTick(function(myHero)
	bestUnit = nil
	bestHP = math.huge
	for _,unit in pairs(GetEnemyHeroes()) do
		if norm and ValidTarget(unit,GetRange(myHero)) then
			EffHP = GetCurrentHP(unit)*(1-(100/GetArmor(unit)-GetArmorPenFlat(myHero)-GetArmor(unit)*GetArmorPenPercent(myHero)))
			if EffHP < bestHP then
				bestUnit = unit 
				bestHP = EffHP
			end
		elseif magi and ValidTarget(unit,GetRange(myHero)) then
			EffHP = GetCurrentHP(unit)*(1-(100/GetMagicResist(unit)-GetMagicPenFlat(myHero)-GetMagicResist(unit)*GetMagicPenPercent(myHero)))
			if EffHP < bestHP then
				bestUnit = unit 
				bestHP = EffHP
			end
		end
		if bestUnit then 
			IOW.forceTarget = bestUnit 
		end
	end
end)

OnDraw(function(myHero)
	if bestUnit then 
		DrawText("Best Target: "..GetObjectName(bestUnit),10,1,300,GoS.White)
	end
end)
