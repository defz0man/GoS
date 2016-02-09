if GetObjectName(GetMyHero()) ~= "Annie" then return end	--Checks if our hero is named "Annie" and stops the scripts if that's not the case

require("Inspired")											--Loads the Inspired lib

local AnnieMenu = Menu("Annie", "Annie")						--Create a New Menu and call it AnnieMenu (the user only sees "Annie")
AnnieMenu:SubMenu("Combo", "Combo")								--Create a New SubMenu and call it Combo
AnnieMenu.Combo:Boolean("Q", "Use Q", true)						--Add a button to toggle the usage of Q
AnnieMenu.Combo:Boolean("W", "Use W", true)						--Add a button to toggle the usage of W


OnTick(function (myHero)									--The code inside the Function runs every tick
	
	local target = GetCurrentTarget()					--Saves the "best" enemy champ to the target variable
		
	if IOW:Mode() == "Combo" then						--Check if we are in Combo mode (holding space)
			
		
		if AnnieMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 625) then	
			--[[
				AnnieMenu.Combo.Q:Value() returns true if the menu has been ticked
				Ready(_Q) returns true if we are able to cast Q now
				ValidTarget(target, 625) returns true if the target can be attacked and is in a range of 625 (Annie Q range; see wiki)
			]]		
			CastTargetSpell(target , _Q)	--Casts the Q as Point&Click spell on the enemy
		end		--Ends the Q logic
	
		if AnnieMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 625) then
			--[[
				AnnieMenu.Combo.W:Value() returns true if the menu has been ticked
				Ready(_W) returns true if we are able to cast W now
				ValidTarget(target, 625) returns true if the target can be attacked and is in a range of 625 (Annie W range; see wiki)
				We don't care that it's conic atm because it's pretty much instant
			]]
			local targetPos = GetOrigin(target)		--saves the XYZ coordinates of the target to the variable
			CastSkillShot(_W , targetPos)			--Since the W is a skillshot (select area), we have to cast it at a point on the ground (targetPos)
		end		--Ends the W logic
	end		--Ends the Combo Mode
end)

print("Annie loaded")	--Little message to show that the script has injected without breaking
