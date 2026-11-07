local softBoots = TalkAction("!soft", "!softboots")

local config = {
	price = 10000,

	-- IDs correctos en tu server
	wornSoftBootsId = 6530,
	softBootsId = 6529,
}

function softBoots.onSay(player, words, param)
	-- Permite:
	-- !soft
	-- !soft boots
	-- !softboots

	local wornSoftBoots = player:getItemById(config.wornSoftBootsId, true)

	if not wornSoftBoots then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendCancelMessage("You don't have worn soft boots.")
		return true
	end

	if not player:removeMoneyBank(config.price) then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendCancelMessage("You need 10000 gold coins to recharge your soft boots.")
		return true
	end

	wornSoftBoots:transform(config.softBootsId)

	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your soft boots have been recharged for 10000 gold coins.")

	return true
end

softBoots:separator(" ")
softBoots:groupType("normal")
softBoots:register()