local SPELL_BASE_POWER = 75
local DEATH_ECHO_AREA = {
	{ 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 1, 1 },
	{ 1, 1, 3, 1, 1 },
	{ 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 1, 1 },
}

local function getDeathEchoValues(player, magicLevel)
	local average = player:calculateFlatDamageHealing()
		+ (SPELL_BASE_POWER / 25) * magicLevel
		+ (SPELL_BASE_POWER / 4)
	return -math.floor(average * 0.88), -math.ceil(average * 1.12)
end

function onGetDeathEchoValues(player, level, magicLevel)
	return getDeathEchoValues(player, magicLevel)
end

function onGetDeathEchoRepeatValues(player, level, magicLevel)
	local min, max = getDeathEchoValues(player, magicLevel)
	return min * 0.5, max * 0.5
end

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 364)
combat:setArea(createCombatArea(DEATH_ECHO_AREA))
combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetDeathEchoValues")

local repeatCombat = Combat()
repeatCombat:setParameter(COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
repeatCombat:setParameter(COMBAT_PARAM_EFFECT, 364)
repeatCombat:setArea(createCombatArea(DEATH_ECHO_AREA))
repeatCombat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetDeathEchoRepeatValues")

local function repeatDeathEcho(position, playerId)
	if not Tile(position) then
		return
	end

	local player = Player(playerId)
	if not player then
		return
	end

	local variant = {
		instantName = "Death Echo",
		runeName = "",
		type = 2,
		pos = position,
	}
	repeatCombat:execute(player, variant)
end

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	local position = var:getPosition()
	local result = combat:execute(creature, var)
	if result then
		addEvent(repeatDeathEcho, 1000, position, creature:getId())
	end
	return result
end

spell:group("attack")
spell:id(310)
spell:name("Death Echo")
spell:words("exevo mort ora")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_OR_RUNE)
spell:level(120)
spell:mana(155)
spell:isPremium(true)
spell:range(7)
spell:needPosition(true)
spell:blockWalls(true)
spell:cooldown(6 * 1000)
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
spell:vocation("sorcerer;true", "master sorcerer;true")
spell:register()
