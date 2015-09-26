--laiha riven beta 0.0.1 ALPHA IOW UPDATE (Logge)

if GetObjectName(GetMyHero()) ~= "Riven" then return end

require('Inspired')
require('IOW')
RivenMenu = Menu("BoxBox", "BoxBox")

RivenMenu:SubMenu("c", "Combo")
RivenMenu.c:Boolean("Q", "Use Q", true)
RivenMenu.c:Boolean("W", "Use W", true)
RivenMenu.c:Boolean("E", "Use smart E", true)
RivenMenu.c:Boolean("R", "Use R only kill", true)
RivenMenu.c:Key("Combo", "Combo", string.byte(" "))

RivenMenu:SubMenu("m", "Misc")
RivenMenu.m:Boolean("It","Use items")
RivenMenu.m:Boolean("Drawing","Drawings")
 
        local lvl = GetLevel(myHero)
        local ad = GetBaseDamage(myHero)
        local bad = GetBonusDmg(myHero)
        local Qlvl = GetCastLevel(myHero,_Q)
        local Wlvl = GetCastLevel(myHero,_W)
        local Rlvl = GetCastLevel(myHero,_R)

       
spellData =
        {
        [-1] = {dmg = function () return 5+math.max(5*math.floor((lvl+2)/3)+10,10*math.floor((lvl+2/3)-15)*ad/100) end, }, -- only 1 buff not 3
        [_Q] = {dmg = function () return 20*Qlvl-10+(.05*Qlvl+.35)*ad end }, --only 1 strike end,
        [_W] = {dmg = function () return 30*Wlvl+20+bad end, },
        [_R] = {dmg = function () return math.min((40*Rlvl+40+.6*bad)*(1+(100-25)/100*8/3),120*Rlvl+120+1.8*bad) end, },
        }
OnLoop(function(myHero)
                myHero = GetMyHero()
                local unit = GoS:GetTarget(1500, DAMAGE_NORMAL)	
                local myHeroPos = GoS:myHeroPos()
                local mousePos=GetMousePos()
                local unitpos=GetOrigin(unit)
                --if ((GetCurrentHP(myHero)/(GetMaxHP(myHero)/100))) < 26 then
                     --   CastSkillShot(_E,mousePos.x,mousePos.y,mousePos.z)
             --   end
				if unit and RivenMenu.m.Drawing:Value() then
                DrawDmgOverHpBar(unit,GetCurrentHP(unit),120,60,0xffffffff)
				end
                    if RivenMenu.c.Combo:Value() then
						
						UseItems()
                       
                                --if GotBuff(myHero, "rivenpassiveaaboost") > 0 and GoS:ValidTarget(unit, 125) then
                               --       MoveToXYZ(GetOrigin(unit).x, GetOrigin(unit).y, GetOrigin(unit).z)
                               --         GoS:DelayAction(function() AttackObject(unit) end, 180)
                               -- end
 
 
                                if  GoS:ValidTarget(unit, 260) then	--Q Usage
                                    if RivenMenu.c.Q:Value() then
                                        GoS:DelayAction(function() CastSkillShot(_Q,unitpos.x,unitpos.y,unitpos.z) end, 400+GetLatency())
										AttackUnit(unit)
                                    end
									
                                    if CanUseSpell(myHero,_W) == READY and GoS:GetDistance(unit)<125 then	--W Usage
                                        CastTargetSpell(myHero,_W)
                                    elseif CanUseSpell(myHero,_W) == READY and CanUseSpell(myHero,_E) == READY and GoS:GetDistance(unit) < 300 then
                                                CastSkillShot(_E,unitpos.x,unitpos.y,unitpos.z)
                                                CastTargetSpell(myHero,_W)
                                    end
                                end
                        end
                for _, enemy in pairs(GoS:GetEnemyHeroes()) do
                        local hp = GetCurrentHP(enemy)
                        local mhp = GetMaxHP(enemy)
                        if (mhp/hp)<25 and CanUseSpell(myHero, _R) ==  ACTIVE then
                                rpred=GetPredictionForPlayer(GetOrigin(myHero), unit, GetMoveSpeed(unit), 1600, 0.5, 1100, 200, false, true)
				if GetCastName(myHero, _R) == "RivenFengShuiEngine" then
                        		CastSkillShot(_R,rpred.PredPos.x,rpred.PredPos.y,rpred.PredPos.z)
				end	
                               
 
                        end
                end
end)
 
function DamageCalc()
        for _,enemy in pairs(GoS:GetEnemyHeroes()) do
                if GoS:ValidTarget(enemy,1000) then
                        ComboDmg = spellData[-1].dmg() + spellData[_Q].dmg() + spellData[_W].dmg() + spellData[_R].dmg()
                        if ComboDmg>GetCurrentHP(unit) and RivenMenu.m.Drawing:Value() then
                        local drawPos = WorldToScreen(1,unitPos.x,unitPos.y,unitPos.z)
                        DrawText( " KILL THAT BITCH ",20,drawPos.x,drawPos.y,0xffffffff)
                        end
                end
        end
end

GoS:AddGapcloseEvent(_W, 120, true)


aaResetItems={3074,3077,3748}
--		Hydr,Tiam,Tita

meeleItems={3153,3144,3142,3143,3074,3077,3748}
--	    Botr,Bilg,Ghos,Rand
cleanseItems={3140,3139}
--	     Merc,QSS

function UseItems()
	if RivenMenu.m.It:Value() then 
	local unit = GoS:GetTarget(1500, DAMAGE_NORMAL)
		for _,id in pairs(cleanseItems) do
			if GetItemSlot(myHero,id) > 0 and GotBuff(myHero, "rocketgrab2") > 0 or GotBuff(myHero, "charm") > 0 or GotBuff(myHero, "fear") > 0 or GotBuff(myHero, "flee") > 0 or GotBuff(myHero, "snare") > 0 or GotBuff(myHero, "taunt") > 0 or GotBuff(myHero, "suppression") > 0 or GotBuff(myHero, "stun") > 0 or GotBuff(myHero, "zedultexecute") > 0 or GotBuff(myHero, "summonerexhaust") > 0  then
				CastTargetSpell(myHero, GetItemSlot(myHero,id))
			end
		end
		if IOW:Mode() == "Combo" then
			for _,id in pairs(meeleItems) do
				if GetItemSlot(myHero,id) > 0 and GoS:ValidTarget(unit, 550) then
				CastTargetSpell(unit, GetItemSlot(myHero,id))
				end
			end
		end
	end
end


OnProcessSpell(function(unit, spell)
	if unit and unit == myHero and spell and spell.name and spell.name:lower():find("attack") then
	--print("Windup:"..spell.windUpTime*1000)
		if GetTeam(spell.target)~=GetTeam(myHero) and GetObjectType(spell.target) == Obj_AI_Hero then
			--	print("aa Q")
		--RivenMenu.c.Combo:Value() and
			targetPos = GetOrigin(unit)
			GoS:DelayAction(
				function()
					CastSkillShot(_Q, targetPos.x, targetPos.y, targetPos.z) 
				end, 
				spell.windUpTime * 1000)
		end
	end
end)

