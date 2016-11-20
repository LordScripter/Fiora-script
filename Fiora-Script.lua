-- Script for fiora
-- Combo: Q to mouse, AA, E(reset AA), Hydra/Tiamat, AA
local myHero = GetMyHero()
if GetObjectName(myHero) ~= "Fiora" then return end
--vars
local target
local timerOld, timerNew, AAReady, as = 0, 0, 0, 0

OnTick(function(myHero)
  if IOW:Mode() == "Combo" then combo() end
  as = GetAttackSpeed(myHero) * 0.69
  timerNew = GetTickCount()
  lastAA = timerNew - timerOld
  if lastAA > (1/as) * 1000
    then AAReady = 1
  end
end

function combo()
  target = GetCurrentTarget()
  castQ()
  if AAReady and CanUseSpell(myHero,_Q) ~= READY then
    AttackUnit(target) end
  if ~AAReady then
    CastE()
    AttackUnit(target)
  end
  if CanUseSpell(myHero,_E)~=READY then
    CastOffensiveItems(target)
  end
  if AAReady and CanUseSpell(myHero,_E)~=READY then
    AttackUnit(target)
  end
end

function castQ()
  if Ready(_Q) then
    CastSkilShot(_Q, GetMousePos())
  end

function castE()
  if Ready(_E) then
      CastSpell(_E)
  end

OnProcessSpellComplete(function(Object,Spell)
	if Object == GetMyHero() then
	    	timerold = GetTickCount()
			AAREADY = 0			
	end
end)

PrintChat("Fiora Script Loaded")
