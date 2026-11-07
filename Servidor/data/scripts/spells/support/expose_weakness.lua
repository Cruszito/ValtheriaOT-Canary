local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local deactivate = player:getStance() == STANCE_EXPOSE_WEAKNESS
	if not player:setStance(STANCE_EXPOSE_WEAKNESS) then
		return false
	end
	player:getPosition():sendMagicEffect(deactivate and CONST_ME_POFF or 288)
	return true
end

spell:name("Aura of Exposed Weakness")
spell:words("exori moe tempo")
spell:group("support", "crippling")
spell:vocation("sorcerer;true", "master sorcerer;true")
spell:id(312)
spell:cooldown(30 * 1000)
spell:groupCooldown(2 * 1000, 30 * 1000)
spell:level(175)
spell:mana(1500)
spell:needLearn(false)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(true)
spell:register()
