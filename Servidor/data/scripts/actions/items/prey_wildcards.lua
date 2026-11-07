local wildcardAmounts = {
	[55368] = 20,
	[55369] = 10,
	[55370] = 5,
}

local preyWildcards = Action()

function preyWildcards.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local amount = wildcardAmounts[item:getId()]

	if not amount then
		return false
	end

	-- Primero consume el objeto para evitar duplicaciones.
	if not item:remove(1) then
		player:sendCancelMessage("The prey wildcard item could not be consumed.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	player:addPreyCards(amount)

	local newBalance = player:getPreyCards()

	player:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		string.format(
			"You received %d prey wildcards. Your new balance is %d.",
			amount,
			newBalance
		)
	)

	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	return true
end

preyWildcards:id(55368, 55369, 55370)
preyWildcards:register()