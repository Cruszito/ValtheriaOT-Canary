local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local deactivate = player:getStance() == STANCE_PROTECTOR
	if not player:setStance(STANCE_PROTECTOR) then
		return false
	end
	player:getPosition():sendMagicEffect(deactivate and CONST_ME_POFF or CONST_ME_MAGIC_GREEN)
	return true
end

spell:name("Protector")
spell:words("utamo tempo")
spell:group("support", "stance")
spell:vocation("knight;true", "elite knight;true")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_PROTECTOR)
spell:id(132)
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000, 2 * 1000)
spell:level(20)
spell:mana(20)
spell:needLearn(false)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(true)
spell:register()
