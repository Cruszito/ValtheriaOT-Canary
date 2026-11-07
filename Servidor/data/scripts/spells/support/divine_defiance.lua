local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local deactivate = player:getStance() == STANCE_DIVINE_DEFIANCE
	if not player:setStance(STANCE_DIVINE_DEFIANCE) then
		return false
	end
	player:getPosition():sendMagicEffect(deactivate and CONST_ME_POFF or 299)
	return true
end

spell:name("Divine Defiance")
spell:words("utori hur")
spell:group("support", "stance")
spell:vocation("paladin;true", "royal paladin;true")
spell:id(314)
spell:cooldown(10 * 1000)
spell:groupCooldown(2 * 1000, 10 * 1000)
spell:level(20)
spell:mana(250)
spell:needLearn(false)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(true)
spell:register()
