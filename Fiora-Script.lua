-- Description: Q's to mouse position then uses AA , E , Hydra , AA on champion target

local myHero = GetMyHero()
if GetObjectName(myHero) ~= "Fiora" then return end
-- import antiCC
require 'antiCC'
addAntiCCCallback(function(unit, spellProc)
	if autoBlock.getValue() or combo.getValue() then
		if CanUseSpell(myHero,_W) == READY then
			CastSkillShot(_W,GetOrigin(unit))
		end
	end
end)
-- define variables
local target
local timerold,timernew, AAREADY,cAS = 0,0,0,0
-- perma refreshed
OnTick(function(myHero)
	if IOW:Mode() == "Combo" and doCombo == true then
		combo()
	end
	
	cAS = GetAttackSpeed( GetMyHero() ) * 0.69
	timernew = GetTickCount()
	lastAA = timerold - timernew
	
	if -lastAA > (1/ cAS ) * 1000 then
		AAREADY = 1
	end
end)
-- Combo
function combo()
target = GetCurrentTarget()

			castQ()
			
			if (AAREADY == 1 ) and CanUseSpell(myHero,_Q) ~= READY then
				AttackUnit(target)
			end
			
			if AAREADY == 0 then
				castE()
			end
			
			if CanUseSpell(myHero,_E) ~= READY then
			CastOffensiveItems(target)
			end
			
			if (AAREADY == 1 ) and CanUseSpell(myHero,_E) ~= READY then
				AttackUnit(target)
			end

		end

function castQ()
	if Ready(_Q) then
		CastSkillShot(_Q, GetMousePos())
	end
end

function castE()
	if Ready(_E) then
		CastSpell(_E)
	end
end

OnProcessSpellComplete(function(Object,Spell)
	if Object == GetMyHero() then
	    	timerold = GetTickCount()
			AAREADY = 0			
	end
end)

PrintChat("simple Fiora Combo loaded.")
