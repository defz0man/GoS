require('Inspired')

--[[
0 = white
1 = light gray
2 = dark gray
3 = black
4 = yellow
5 = red
--]]
local res = GetResolution()
local color = {ARGB(255,255,255,255), ARGB(255,50,50,50), ARGB(255,71,71,71), ARGB(255,0,0,0), ARGB(255,255,255,0),  ARGB(255,255,0,0)}

local pixelArt = {
[1] = {9,9,9,9,9,3,3,3,3,3,3,9,9,9},
[2] = {9,3,3,3,3,3,2,1,1,0,0,3,9,9},
[3] = {9,3,0,0,0,0,3,1,0,4,5,3,9,9},
[4] = {9,9,3,4,4,4,4,2,4,4,5,3,9,9},
[5] = {9,9,9,3,4,4,4,4,4,4,5,3,9,9},
[6] = {9,9,9,9,3,4,1,1,3,3,5,3,9,9},
[7] = {9,3,3,9,3,4,4,4,4,4,4,3,3,9},
[8] = {9,3,9,3,3,3,4,1,1,2,4,2,3,3},
[9] = {9,3,4,0,4,4,3,2,1,1,4,3,0,3},
[10]= {3,3,4,1,1,2,0,3,3,3,3,4,1,3},
[11]= {3,4,3,1,1,3,1,4,4,4,4,1,3,9},
[12]= {9,3,3,2,1,3,2,2,4,5,4,1,3,9},
[13]= {9,9,3,2,1,3,2,1,0,5,0,3,3,9},
[14]= {9,9,3,4,4,0,3,4,4,5,4,3,0,3},
[15]= {9,9,3,1,1,2,3,2,1,4,2,3,2,3},
[16]= {9,9,3,2,2,2,3,3,3,3,3,3,2,3},
[17]= {9,9,9,3,3,3,1,1,4,3,4,3,3,9},
[18]= {9,9,9,9,9,3,2,1,4,3,4,3,9,9},
[19]= {9,9,9,9,3,2,2,1,1,3,2,3,9,9},
[20]= {9,9,9,9,3,4,2,2,1,3,2,3,9,9},
[21]= {9,9,9,9,3,4,4,4,4,0,3,0,3,9},
[22]= {9,9,9,9,3,3,3,3,3,3,3,3,3,9}
}
local xp = 0
local h = 0
local v = 0
local jump = false
local av = 3
local block = {math.random(res.x*.4,res.x*.6),math.random(res.x*.2,res.x*.4),math.random(0,res.x*.2)}

OnDraw(function(myHero)
	--if not isDead(myHero) then return end
	BlockInput(true)
	FillRect(0,23*6+res.y*.75,res.x,20,GoS.Black)
	if xp > .9 then xp = 0 else xp = xp + res.x*.0000001 end
	for y=1,#pixelArt do
		for x=1,#pixelArt[y] do
			if pixelArt[y][x] ~= 9 and y<xp*math.random(500,750) then
				FillRect(xp*res.x+x*6,h+res.y*.75+y*6,6,6,color[pixelArt[y][x]+1])
			end
		end
	end
	--DrawText("Script made by Logge",30,xp*res.x+100,res.y*.80,GoS.White)
	for i=1, #block do
		FillRect(res.x-block[i],res.y*.75+50,25,100,GoS.Red)
		block[i] = block[i] + av + av*xp
		if block[i]>res.x then
			block[i] = math.random(0,res.x*.3)
		end
	end
	
	if h < 0 and not jump then 
		v = v - .5
		h = h - v
	elseif h+v >= 0 and not jump then
		h = 0
		v = 0
	elseif jump then
		h = h - v
	end
end)

OnWndMsg(function(msg,key)
	--jump
	if key==32 and h > -5 then
		jump = true
		v = 7
		DelayAction(function() jump = false end, .3)
	end
end)

