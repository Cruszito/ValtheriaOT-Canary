local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local deactivate = player:getElementalStance() == STANCE_MASTER_OF_THUNDER
	if not player:setElementalStance(STANCE_MASTER_OF_THUNDER) then
		return false
	end
	player:getPosition():sendMagicEffect(deactivate and CONST_ME_POFF or 287)
	return true
end

spell:name("Master of Thunder")
spell:words("uteta vis")
spell:group("support", "stance")
spell:vocation("sorcerer;true", "master sorcerer;true")
spell:id(305)
spell:cooldown(30 * 1000)
spell:groupCooldown(2 * 1000, 30 * 1000)
spell:level(20)
spell:mana(400)
spell:needLearn(false)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(true)
spell:register()
