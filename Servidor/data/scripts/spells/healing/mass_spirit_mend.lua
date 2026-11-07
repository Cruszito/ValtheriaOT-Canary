local SPELL_BASE_POWER = 800

local function targetFunction(creature, target)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local bosses = { "leiden", "ravennous hunger", "dorokoll the mystic", "eshtaba the conjurer", "eliz the unyielding", "mezlon the defiler", "malkhar deathbringer", "containment crystal" }
	local master = target:getMaster()
	if target:isMonster() and (not master or master:isMonster()) then
		if not table.contains(bosses, target:getName():lower()) then
			return true
		end
	end

	local level = player:getLevel()
	local magicLevel = player:getMagicLevel()
	local levelBonus = player:calculateFlatDamageHealing()
	local min = levelBonus + magicLevel * (SPELL_BASE_POWER * 7.3 / 250) + 42
	local max = levelBonus + magicLevel * (SPELL_BASE_POWER * 12.4 / 250) + 90

	-- The caster receives the lesser effect of a regular Spirit Mend.
	if target:getId() == creature:getId() then
		min = (level / 5) + (magicLevel * 7.22) + 44
		max = (level / 5) + (magicLevel * 12.79) + 79
	end

	doTargetCombatHealth(creature, target, COMBAT_HEALING, min, max, CONST_ME_NONE, ORIGIN_SPELL, "Mass Spirit Mend")
	return true
end

function onTargetCreature(creature, target)
	targetFunction(creature, target)
	return true
end

local function createCombat(area, combatFunc)
	local initCombat = Combat()
	initCombat:setCallback(CALLBACK_PARAM_TARGETCREATURE, combatFunc)
	initCombat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
	initCombat:setParameter(COMBAT_PARAM_AGGRESSIVE, 0)
	initCombat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
	initCombat:setArea(createCombatArea(area))
	return initCombat
end

local combat = createCombat(AREA_MASS_SPIRIT_MEND, "onTargetCreature")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	return combat:execute(creature, var)
end

spell:name("Mass Spirit Mend")
spell:words("exura mas nia")
spell:group("healing")
spell:vocation("monk;true", "exalted monk;true")
spell:id(296)
spell:cooldown(12 * 1000)
spell:groupCooldown(1 * 1000)
spell:level(150)
spell:mana(400)
spell:isPremium(true)
spell:isAggressive(false)

spell:castSound(SOUND_EFFECT_TYPE_SPELL_MASS_HEALING)
spell:register()
