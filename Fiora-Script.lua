local myHero = GetMyHero()
if GetObjectName(myHero) ~= "Fiora" then return end

local debug = false

local target
local timerold,timernew, AAREADY,cAS = 0,0,0,0

d = require 'DLib'
local IsInDistance = d.IsInDistance
local ValidTarget = d.ValidTarget
local GetEnemyHeroes = d.GetEnemyHeroes
local CalcDamage = d.CalcDamage
local GetDistance = d.GetDistance

local submenu = menu.addItem(SubMenu.new("simple fiora"))
local combo = submenu.addItem(MenuKeyBind.new("combo key", string.byte(" ")))
local autoBlock = submenu.addItem(MenuBool.new("auto W when possible", true))

require 'antiCC'
addAntiCCCallback(function(unit, spellProc)
	if autoBlock.getValue() or combo.getValue() then
		if CanUseSpell(myHero,_W) == READY then
			CastSkillShot(_W,GetOrigin(unit))
		end
	end
end)

local distance = 200
local passtiveList = {
	["Fiora_Base_Passive_NE.troy"] = { x = 0, y = distance},
	["Fiora_Base_Passive_NW.troy"] = { x = distance, y = 0},
	["Fiora_Base_Passive_SE.troy"] = { x = -1 * distance, y = 0},
	["Fiora_Base_Passive_SW.troy"] = { x = 0, y = -1 * distance},
	["Fiora_Base_R_Mark_NE_FioraOnly.troy"] = { x = 0, y = distance},
	["Fiora_Base_R_Mark_NW_FioraOnly.troy"] = { x = distance, y = 0},
	["Fiora_Base_R_Mark_SE_FioraOnly.troy"] = { x = -1 * distance, y = 0},
	["Fiora_Base_R_Mark_SW_FioraOnly.troy"] = { x = 0, y = -1 * distance}
}

require('simple orbwalk')

local objectList = {}
local buffList = {}

local function getNearestPos()
	local result = nil
	local distanceTemp = math.huge
	for _,obj in pairs(buffList) do
		local origin = GetOrigin(obj)
		if origin then
			local distance = passtiveList[GetObjectBaseName(obj)]
			local buff_pos = {
				x = origin.x+distance.x,
				y = origin.y+distance.y,
				z = origin.z
			}
			local buff_pos_distance = GetDistance(buff_pos)
			if not result or buff_pos_distance < distanceTemp then
				result = buff_pos
				distanceTemp = buff_pos_distance
			end
		end
	end

	return result, distanceTemp
end

local function processObjectList()
	local tempObjectList = {}
	for _,object in ipairs(objectList) do
		local id = GetNetworkID(object)
		if id then
			buffList[id] = object
		else
			table.insert(tempObjectList, object)
		end
	end
	objectList = tempObjectList
end

OnTick(function(myHero)
	processObjectList()
	local buff_pos, distance = getNearestPos()
	if buff_pos and combo.getValue() and distance > 100 then
		if CanUseSpell(myHero,_Q) == READY and distance < GetCastRange(myHero,_Q) then
   		CastSkillShot(_Q,buff_pos)
   	elseif not canAttack() and canMove() then
   		canMove(false)
   		MoveToXYZ(buff_pos)
   	end
  else
  	canMove(true)
	end
	if IOW:Mode() == "Combo"  then
		combo()
	end
	
	cAS = GetAttackSpeed( GetMyHero() ) * 0.69
	timernew = GetTickCount()
	lastAA = timerold - timernew
	
	if -lastAA > (1/ cAS ) * 1000 then
		AAREADY = 1
	end
end)

OnDraw(function(myHero)
	if debug then
		for _,obj in pairs(buffList) do
			local origin = GetOrigin(obj)
			if origin then
				local distance = passtiveList[GetObjectBaseName(obj)]
				DrawCircle(origin.x+distance.x,origin.y+distance.y,origin.z,100,0,0,0xffffffff)
			end
		end	
	end
end)

addResetAASpell(function()
	if CanUseSpell(myHero,_E) == READY then
   	CastSpell(_E)
		return true
	else
		return false
  end
end)

OnProcessSpellComplete(function(unit, spell)
  if unit == myHero and spell.name == "FioraE" then
		resetAA()
  end
end)

OnCreateObj(function(object)
	if passtiveList[GetObjectBaseName(object)] then
		table.insert(objectList, object)
	end

	if debug and GetObjectBaseName(object):find("Fiora_Base") and not GetObjectBaseName(object):lower():find("speed")then
		PrintChat(
			""..GetObjectBaseName(object).."  "..
			"IsVisible : "..tostring(IsVisible(object)).."  "..
			"GetTeam : "..GetTeam(object).."  "..
			"IsTargetable : "..tostring(IsTargetable(object)).."  "
			)
	end
end)

OnDeleteObj(function(object)
	if passtiveList[GetObjectBaseName(object)] then
		buffList[GetNetworkID(object)] = nil
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

PrintChat("simple fiora loaded")
