local combat = Combat()

combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ETHEREALSPEAR)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, 1)

function onGetFormulaValues(player, skill, attack, factor)
    local levelTotal = player:getLevel() / 5

    -- Daño original
    local minDamage = ((2 * skill + attack / 2500) * 2.30) + levelTotal + 7
    local maxDamage = ((2 * skill + attack / 1875) * 3.30) + levelTotal + 13

    -- 0.60 = conserva el 60% del daño original
    -- Equivale a una reducción del 40%
    local damageMultiplier = 0.60

    return -(minDamage * damageMultiplier), -(maxDamage * damageMultiplier)
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    return combat:execute(creature, var)
end

spell:group("attack")
spell:id(57)
spell:name("Strong Ethereal Spear")
spell:words("exori gran con")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_OR_RUNE)
spell:impactSound(SOUND_EFFECT_TYPE_SPELL_STRONG_ETHEREAL_SPEAR)

spell:level(90)
spell:mana(55)
spell:isPremium(true)

spell:range(7)
spell:needTarget(true)
spell:blockWalls(true)

spell:cooldown(8 * 1000)
spell:groupCooldown(2 * 1000)

spell:vocation("paladin;true", "royal paladin;true")

spell:register()