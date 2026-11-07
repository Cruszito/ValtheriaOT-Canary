local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local deactivate = player:getStance() == STANCE_SAP_STRENGTH
	if not player:setStance(STANCE_SAP_STRENGTH) then
		return false
	end
	player:getPosition():sendMagicEffect(deactivate and CONST_ME_POFF or 311)
	return true
end

spell:name("Aura of Sapped Strength")
spell:words("exori kor tempo")
spell:group("support", "crippling")
spell:vocation("sorcerer;true", "master sorcerer;true")
spell:id(311)
spell:cooldown(30 * 1000)
spell:groupCooldown(2 * 1000, 30 * 1000)
spell:level(175)
spell:mana(1500)
spell:needLearn(false)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(true)
spell:register()
