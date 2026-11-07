local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local deactivate = player:getStance() == STANCE_SHARED_CONSERVATION
	if not player:setStance(STANCE_SHARED_CONSERVATION) then
		return false
	end
	player:getPosition():sendMagicEffect(deactivate and CONST_ME_POFF or 287)
	return true
end

spell:name("Shared Conservation")
spell:words("utura sio")
spell:group("support", "stance")
spell:vocation("druid;true", "elder druid;true")
spell:id(309)
spell:cooldown(10 * 1000)
spell:groupCooldown(2 * 1000, 10 * 1000)
spell:level(20)
spell:mana(400)
spell:needLearn(false)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(true)
spell:register()
