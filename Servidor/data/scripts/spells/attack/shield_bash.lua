local SPELL_BASE_POWER = 55
local DEBUFF_DURATION = 10 * 1000

local function getEquippedShield(player)
	local bestShield
	local bestDefense = -1
	for _, slot in ipairs({ CONST_SLOT_LEFT, CONST_SLOT_RIGHT }) do
		local item = player:getSlotItem(slot)
		if item then
			local itemType = item:getType()
			if itemType and itemType:getWeaponType() == WEAPON_SHIELD then
				local defense = itemType:getDefense()
				if defense > bestDefense then
					bestShield = item
					bestDefense = defense
				end
			end
		end
	end
	return bestShield
end

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 362)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, 1)

function onGetShieldBashFormulaValues(player, skill, attack, factor)
	local shield = getEquippedShield(player)
	if not shield then
		return 0, 0
	end

	local shieldingSkill = player:getSkillLevel(SKILL_SHIELD)
	local shieldDefense = shield:getType():getDefense()
	local average = player:calculateFlatDamageHealing()
		+ (SPELL_BASE_POWER / 1000) * shieldingSkill * shieldDefense
		+ (SPELL_BASE_POWER / 4)
	return -math.floor(average * 0.9), -math.ceil(average * 1.1)
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetShieldBashFormulaValues")

function onShieldBashTargetCreature(creature, target)
	if not target then
		return true
	end
	local condition = Condition(CONDITION_ATTRIBUTES)
	condition:setParameter(CONDITION_PARAM_SUBID, AttrSubId_ShieldAttackReduction)
	condition:setParameter(CONDITION_PARAM_TICKS, DEBUFF_DURATION)
	condition:setParameter(CONDITION_PARAM_BUFF_AUTOATTACKDEALT, 50)
	target:addCondition(condition)
	return true
end

combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "onShieldBashTargetCreature")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local shield = getEquippedShield(player)
	if not shield then
		player:sendCancelMessage("You need to wield a shield to cast this spell.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	return combat:execute(creature, variant)
end

spell:name("Shield Bash")
spell:words("exori ico scu")
spell:group("attack")
spell:vocation("knight;true", "elite knight;true")
spell:id(315)
spell:cooldown(4 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(18)
spell:mana(30)
spell:needLearn(false)
spell:range(1)
spell:needTarget(true)
spell:blockWalls(true)
spell:isAggressive(true)
spell:isPremium(true)
spell:register()
