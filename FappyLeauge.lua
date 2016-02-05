require('Inspired')

local FLMenu = Menu("FL","FappyLeauge")
FLMenu:Boolean("a","Activate FlappyLeauge",true)
FLMenu:Boolean("o","Only when dead",true)
FLMenu:Boolean("b","Block Input",true)

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
--x14

local xp = 0
local h = 0
local v = 0
local jump = false
local av = 3
local hscore = 0
local score = 0
local block = {
	[1] = {x = math.random(res.x*.4,res.x*.6),	h = 100, w = 24},
	[2] = {x = math.random(res.x*.2,res.x*.4),	h = 70, w = 24},
	[3] = {x = math.random(0,res.x*.2),			h = 60, w = 24}
}

OnDraw(function(myHero)
	BlockInput(false)
	if not FLMenu.a:Value() or (FLMenu.o:Value() and not IsDead(myHero)) then return end 
	if FLMenu.b:Value() then BlockInput(true) end
	FillRect(0,23*6+res.y*.75,res.x,20,GoS.Black)
	blockw = math.random(4,6)*6
	if xp > .9 then xp = 0 else xp = xp + res.x*.0000001 end
	for y=1,#pixelArt do
		for x=1,#pixelArt[y] do
			if pixelArt[y][x] ~= 9 and y<xp*math.random(500,750) then
				FillRect(xp*res.x+x*6,h+res.y*.75+y*6,6,6,color[pixelArt[y][x]+1])
			end
		end
	end
	
	--FillRect(xp*res.x+30,h+res.y*.75+22*6,6,6,GoS.Green)
	--FillRect(xp*res.x+78,h+res.y*.75+22*6,6,6,GoS.Green)
	
	--DrawText("Script made by Logge",30,xp*res.x+100,res.y*.80,GoS.White)
	for i=1, #block do
		FillRect(res.x-block[i].x,res.y*.75+150-block[i].h,block[i].w,block[i].h,GoS.Red)
		--FillRect(res.x-block[i].x,res.y*.75+150-block[i].h,6,6,GoS.Blue)
		--FillRect(res.x-block[i].x+block[i].w-6,res.y*.75+150-block[i].h,6,6,GoS.Blue)
		block[i].x = block[i].x + av + av*xp*2
		if block[i].x>res.x then
			block[i].x = math.random(0,res.x*.3) - res.x*.3
			block[i].w = math.random(4,6)*6
		end
		if h+res.y*.75+22*6 >= res.y*.75+150-block[i].h then
			if xp*res.x+30 > res.x-block[i].x and xp*res.x+30 < res.x-block[i].x+block[i].w-6 then
			reset()
			elseif xp*res.x+78 > res.x-block[i].x and xp*res.x+78 < res.x-block[i].x+block[i].w-6 then
			reset()
			end
		end
		score = xp*av*av*100
		if score > hscore then
			hscore = score
		end
		
		DrawText("Score: "..math.floor(score),		50, res.x*.01+GetTextRect("Highscore",50,10,10).w-GetTextRect("Score",50,10,10).w, res.y*.5, GoS.White)
		DrawText("Highscore: "..math.floor(hscore),	50, res.x*.01, res.y*.55, GoS.White)
	end
	
	--y movement
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

function reset()
	score = 0
	v = 0
	h = 0
	xp = 0
	jump = false
	block = {
	[1] = {x = math.random(res.x*.4,res.x*.6),	h = 100, w = 24},
	[2] = {x = math.random(res.x*.2,res.x*.4),	h = 70, w = 24},
	[3] = {x = math.random(0,res.x*.2),			h = 60, w = 24}
	}
end

OnWndMsg(function(msg,key)
	--jump
	if key==32 and h > -5 then
		jump = true
		v = 7
		DelayAction(function() jump = false end, .3)
	end
end)

