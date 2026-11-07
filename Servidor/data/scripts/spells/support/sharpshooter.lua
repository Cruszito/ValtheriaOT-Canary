local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local deactivate = player:getStance() == STANCE_SHARPSHOOTER
	if not player:setStance(STANCE_SHARPSHOOTER) then
		return false
	end
	player:getPosition():sendMagicEffect(deactivate and CONST_ME_POFF or CONST_ME_MAGIC_GREEN)
	return true
end

spell:name("Sharpshooter")
spell:words("utori con")
spell:group("support", "stance")
spell:vocation("paladin;true", "royal paladin;true")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_SHARPSHOOTER)
spell:id(313)
spell:cooldown(10 * 1000)
spell:groupCooldown(2 * 1000, 10 * 1000)
spell:level(20)
spell:mana(250)
spell:needLearn(false)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(false)
spell:register()
