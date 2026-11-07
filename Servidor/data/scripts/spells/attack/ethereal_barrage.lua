local SPELL_BASE_POWER = 40

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 365)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ETHEREALSPEAR)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, 1)
combat:setArea(createCombatArea(AREA_CIRCLE2X2))

function onGetFormulaValues(player, skill, attack, factor)
	local average = player:calculateFlatDamageHealing()
		+ (SPELL_BASE_POWER / 1000) * skill * attack
		+ (SPELL_BASE_POWER / 4)
	return -math.floor(average * 0.9), -math.ceil(average * 1.1)
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	return combat:execute(creature, var)
end

spell:group("attack")
spell:id(303)
spell:name("Ethereal Barrage")
spell:words("exori dir moe")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_STRONG_ETHEREAL_SPEAR)
spell:impactSound(SOUND_EFFECT_TYPE_SPELL_STRONG_ETHEREAL_SPEAR)
spell:level(60)
spell:mana(135)
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
