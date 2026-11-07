local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ROOTS)

local rootWaveArea = {
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 0, 1, 1, 1, 0, 0 },
	{ 0, 0, 0, 1, 0, 0, 0 },
	{ 0, 0, 0, 3, 0, 0, 0 },
}

local area = createCombatArea(rootWaveArea)
combat:setArea(area)

local spell = Spell("instant")

local condition = Condition(CONDITION_ROOTED)
condition:setParameter(CONDITION_PARAM_TICKS, 3000)
combat:addCondition(condition)

function spell.onCastSpell(creature, var)
	return combat:execute(creature, var)
end

spell:name("root wave")
spell:words("###691")
spell:blockWalls(true)
spell:needDirection(true)
spell:needTarget(false)
spell:needLearn(true)
spell:register()