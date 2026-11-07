local SPELL_BASE_POWER = 62

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 370)
combat:setArea(createCombatArea(AREA_CIRCLE3X3))

function onGetFormulaValues(player, skill, attack, factor)
	local damage = player:calculateFlatDamageHealing()
		+ (SPELL_BASE_POWER / 1000) * skill * attack
		+ (SPELL_BASE_POWER / 4)
	return -(damage * 0.9), -(damage * 1.1)
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	return combat:execute(creature, var)
end

spell:group("attack")
spell:id(301)
spell:name("Thousand Fist Blows")
spell:words("exori mas amp pug")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_BERSERK)
spell:level(120)
spell:mana(145)
spell:isPremium(true)
spell:isAggressive(true)
spell:range(7)
spell:needPosition(true)
spell:blockWalls(true)
spell:cooldown(12 * 1000)
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
spell:monkSpellType(MonkSpell_Builder)
spell:vocation("monk;true", "exalted monk;true")
spell:register()
