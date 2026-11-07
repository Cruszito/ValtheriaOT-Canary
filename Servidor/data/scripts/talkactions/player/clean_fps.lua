local talk = TalkAction("!fps")

local keyValue = "talkaction-fps"
local cooldown = 300 -- 5 minutos

function talk.onSay(player, words, param)
	local currentTime = os.time()
	local exhaustionTime = player:kv():get(keyValue) or 0

	if currentTime < exhaustionTime then
		player:sendCancelMessage(string.format(
			"Estas exhausto. Espera %s para volver a usar este comando.",
			Game.getTimeInWords(exhaustionTime - currentTime)
		))
		return true
	end

	player:kv():set(keyValue, currentTime + cooldown)

	local playerId = player:getId()

	player:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		"Reiniciando tu conexion. Tu personaje permanecera en el mapa."
	)

	addEvent(function(pid)
		local targetPlayer = Player(pid)

		if not targetPlayer then
			return
		end

		targetPlayer:disconnect()
	end, 500, playerId)

	return true
end

talk:setDescription("Reinicia la conexion sin remover al personaje del mapa.")
talk:groupType("normal")
talk:register()