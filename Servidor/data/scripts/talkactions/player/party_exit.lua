local partyExit = TalkAction("!partyexit")

function partyExit.onSay(player, words, param)
	local party = player:getParty()

	if not party then
		player:sendCancelMessage("No estas dentro de una party.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local position = player:getPosition()
	local result = party:removeMember(player)

	if result then
		position:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	else
		player:sendCancelMessage("No fue posible salir de la party.")
		position:sendMagicEffect(CONST_ME_POFF)
	end

	return true
end

partyExit:setDescription("Permite salir de la party actual. Uso: !partyexit")
partyExit:groupType("normal")
partyExit:register()