local SPELL_BASE_POWER = 130

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 363)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_SMALLHOLY)
combat:setArea(createCombatArea(AREA_CIRCLE2X2))

function onGetFormulaValues(player, level, magicLevel)
	local average = player:calculateFlatDamageHealing()
		+ (SPELL_BASE_POWER / 25) * magicLevel
		+ (SPELL_BASE_POWER / 4)
	return -math.floor(average * 0.88), -math.ceil(average * 1.12)
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	return combat:execute(creature, var)
end

spell:group("attack")
spell:id(302)
spell:name("Divine Barrage")
spell:words("exori dir san")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_DIVINE_CALDERA)
spell:level(70)
spell:mana(175)
spell:isPremium(true)
spell:isAggressive(true)
spell:range(7)
spell:needPosition(true)
spell:blockWalls(true)
spell:needLearn(false)
spell:cooldown(4 * 1000)
spell:groupCooldown(2 * 1000)
spell:vocation("paladin;true", "royal paladin;true")
spell:register()
