--Menu
local m = {}
local open = true
local res = GetResolution()
local frames = {}
local clicked = {[1] = {}, [2]= {}}
local w = 0
local fgt = Menu("t","t")
fgt:Slider("x","X",.2,0,1,0.01)
fgt:Slider("xw","XW",.6,0,1,0.01)
fgt:Slider("y","Y",.2,0,1,0.01)
fgt:Slider("yw","YW",.6,0,1,0.01)
fgt:Slider("t","T",.02,.01,.1,0.01)

local win = CreateSpriteFromFile("\\kek\\win98logo.png",1)

OnWndMsg(function(msg,key)
	if key == 0 or key == 1 then
		click(GetCursorPos().x,GetCursorPos().y,key)
	end
end)

OnDraw(function()
	if not open then return end
	for i = 1,#frames do
		m = frames[i]
		FillRect(m.xs*res.x,m.ys*res.y,m.xw*res.x,m.yw*res.y,m.c)
	end
	if not frames[1] then return end
	DrawSprite(win, (frames[2].xs+frames[2].xw)*res.x , (frames[2].ys+frames[2].yw)*res.y , frames[2].xw*res.x,frames[2].yw*res.y , 0,0,ARGB(255,255,255,255))
	FillRect((frames[1].xs+frames[1].xw-w*2)*res.x,(frames[1].ys)*res.y,w*2*res.x,w*2*res.y,GoS.Red)
	DrawText("X",40,(frames[1].xs+frames[1].xw-w*1.2)*res.x,(frames[1].ys)*res.y,GoS.White)
	
end)

OnTick(function()
	w = fgt.t:Value()
	frames[1] = {xs=fgt.x:Value(),ys=fgt.y:Value(),xw=fgt.xw:Value(),yw=fgt.yw:Value(),c = GoS.White}
	frames[2] = {xs=frames[1].xs+fgt.t:Value(),ys=frames[1].ys+fgt.t:Value(),xw=frames[1].xw-fgt.t:Value()*2,yw=frames[1].yw-fgt.t:Value()*2, c = GoS.Blue}
	if clicked[1]["s"] and not clicked[2]["s"] then
		fgt.x:Value(GetCursorPos().x/res.x+clicked[1]["x"])
		fgt.y:Value(GetCursorPos().y/res.y+clicked[1]["y"])
	end
end)

function click(x,y,s)
	x = x/res.x
	y = y/res.y
	for i = 1,#frames do
		if s == 1 then clicked[i]["s"] = false end
		l = frames[i]
		if x >= l.xs and x <= l.xs + l.xw and y >= l.ys and y <= l.ys + l.yw and s == 0 and not clicked[i]["s"] then
			clicked[i]["s"] = true
			clicked[i]["x"] = l.xs - GetCursorPos().x / res.x
			clicked[i]["y"] = l.ys - GetCursorPos().y / res.y
			print(i)
		elseif s == 0 then 
			clicked[i]["s"] = false
		end
	end
	if x >= frames[1].xs+frames[1].xw-w*2 and x <= frames[1].xs+frames[1].xw and y >= frames[1].ys and y <= frames[1].ys+2*w then
		open = false
	end
end
