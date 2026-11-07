local SPELL_BASE_POWER = 97

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 369)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_SMALLEARTH)
combat:setParameter(COMBAT_PARAM_CHAIN_EFFECT, CONST_ME_CARNIPHILA)

function onGetFormulaValues(player, level, magicLevel)
	local average = player:calculateFlatDamageHealing()
		+ (SPELL_BASE_POWER / 25) * magicLevel
		+ (SPELL_BASE_POWER / 4)
	return -math.floor(average * 0.88), -math.ceil(average * 1.12)
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

function getChainValue(creature)
	local targets = 6
	local player = creature:getPlayer()
	if player then
		targets = targets + player:getWheelSpellAdditionalTarget("Forked Thorns")
	end
	return targets, 6, false
end

combat:setCallback(CALLBACK_PARAM_CHAINVALUE, "getChainValue")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	return combat:execute(creature, var)
end

spell:group("attack", "special")
spell:id(318)
spell:name("Forked Thorns")
spell:words("exevo fur tera")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_OR_RUNE)
spell:impactSound(SOUND_EFFECT_TYPE_SPELL_STRONG_TERRA_STRIKE)
spell:level(80)
spell:mana(180)
spell:isPremium(true)
spell:range(7)
spell:needTarget(true)
spell:blockWalls(true)
spell:cooldown(6 * 1000)
spell:groupCooldown(2 * 1000, 2 * 1000)
spell:needLearn(false)
spell:vocation("druid;true", "elder druid;true")
spell:register()
