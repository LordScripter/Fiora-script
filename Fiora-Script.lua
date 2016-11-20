-- Description: Q's to mouse position then uses AA , E , Hydra , AA on champion target

local myHero = GetMyHero()
if GetObjectName(myHero) ~= "Fiora" then return end
-- define variables
local target
local timerold,timernew, AAREADY,cAS = 0,0,0,0
local usedQ, usedAA1, usedE, usedAA2, usedHydra, usedAA3 = 0,1,1,1,1,1
-- perma refreshed
OnTick(function(myHero)
	if IOW:Mode() == "Combo"  then
		combo()
	else
		usedQ, usedAA1, usedE, usedAA2, usedHydra, usedAA3 = 0,1,1,1,1,1
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

			if usedQ == 0 then
				castQ()
				usedQ = 1
				usedAA1 = 0
				return
			end
			
			if AAREADY == 1 and usedAA1 == 0 then
				AttackUnit(target)
				usedAA1 = 1
				usedE = 0
				return
			end
			
			if AAREADY == 0 and usedE == 0 then
				castE()
				usedE = 1
				usedAA2 = 0
				return
			end
			
			if AAREADY == 1 and usedAA2 == 0 then
				AttackUnit(target)
				usedAA2 = 1
				usedHydra = 0
				return
			end
	
			if usedHydra == 0 then
				CastOffensiveItems(target)
				usedHydra = 1
				usedAA3 = 0
				return
			end
			
			if AAREADY == 1 and usedAA3 == 0 then
				AttackUnit(target)
				usedAA3 = 1
				return
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

