local config = {
	lionPosition = {
		Position(32444, 32512, 7),
		Position(32449, 32516, 7),
		Position(32444, 32520, 7),
	},

	usurperPosition = {
		Position(32450, 32520, 7),
		Position(32444, 32516, 7),
		Position(32448, 32512, 7),
	},

	-- Jugador que acciona la palanca
	firstPlayerPosition = Position(32457, 32508, 6),

	-- Sala del combate
	centerPosition = Position(32439, 32523, 7),
	exitPosition = Position(32453, 32503, 7),
	newPosition = Position(32453, 32510, 7),

	rangeX = 22,
	rangeY = 16,

	requiredLevel = 250,

	-- Tiempo máximo para completar la pelea
	timeToKill = 20, -- minutos

	-- Cooldown individual, sin depender de la quest ni del config.lua
	cooldownStorage = 888913,
	cooldownTime = 20 * 60 * 60, -- 20 horas
}

local currentEvent = nil

local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	if hours > 0 then
		return string.format(
			"%d hour(s), %d minute(s) and %d second(s)",
			hours,
			minutes,
			secs
		)
	elseif minutes > 0 then
		return string.format(
			"%d minute(s) and %d second(s)",
			minutes,
			secs
		)
	end

	return string.format("%d second(s)", secs)
end

local function getRoomSpectators(onlyPlayers)
	return Game.getSpectators(
		config.centerPosition,
		false,
		onlyPlayers,
		config.rangeX,
		config.rangeX,
		config.rangeY,
		config.rangeY
	)
end

local function resetCommanderStorages()
	Game.setStorageValue(
		GlobalStorage.TheOrderOfTheLion.Drume.TotalLionCommanders,
		-1
	)

	Game.setStorageValue(
		GlobalStorage.TheOrderOfTheLion.Drume.TotalUsurperCommanders,
		-1
	)
end

local function clearRoomDrume()
	for _, spectator in ipairs(getRoomSpectators(false)) do
		if spectator:isMonster() then
			spectator:remove()
		elseif spectator:isPlayer() then
			spectator:teleportTo(config.exitPosition)
			spectator:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			spectator:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"Your time is over."
			)
		end
	end

	resetCommanderStorages()
	currentEvent = nil
end

local function clearRoomMonsters()
	for _, spectator in ipairs(getRoomSpectators(false)) do
		if spectator:isMonster() then
			spectator:remove()
		end
	end
end

local function getEntrancePlayers()
	local players = {}

	for x = config.firstPlayerPosition.x, config.firstPlayerPosition.x + 4 do
		local position = Position(
			x,
			config.firstPlayerPosition.y,
			config.firstPlayerPosition.z
		)

		local tile = Tile(position)
		local creature = tile and tile:getTopCreature()

		if creature and creature:isPlayer() then
			players[#players + 1] = creature
		end
	end

	return players
end

local function createCommanders(player)
	local totalLion = 0
	local totalUsurper = 0

	for _, position in ipairs(config.lionPosition) do
		local monster = Game.createMonster(
			"Lion Commander",
			position,
			true,
			true
		)

		if not monster then
			clearRoomMonsters()
			player:sendCancelMessage(
				"Could not create the Lion Commanders. Contact an administrator."
			)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		totalLion = totalLion + 1
	end

	for _, position in ipairs(config.usurperPosition) do
		local monster = Game.createMonster(
			"Usurper Commander",
			position,
			true,
			true
		)

		if not monster then
			clearRoomMonsters()
			player:sendCancelMessage(
				"Could not create the Usurper Commanders. Contact an administrator."
			)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		totalUsurper = totalUsurper + 1
	end

	Game.setStorageValue(
		GlobalStorage.TheOrderOfTheLion.Drume.TotalLionCommanders,
		totalLion
	)

	Game.setStorageValue(
		GlobalStorage.TheOrderOfTheLion.Drume.TotalUsurperCommanders,
		totalUsurper
	)

	return true
end

local drumeAction = Action()

function drumeAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Solo el jugador situado frente a la palanca puede activarla.
	if player:getPosition() ~= config.firstPlayerPosition then
		return true
	end

	-- Evita iniciar una segunda pelea mientras hay jugadores dentro.
	if #getRoomSpectators(true) > 0 then
		player:sendCancelMessage(
			"There's someone already in the skirmish."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local players = getEntrancePlayers()

	if #players == 0 then
		return true
	end

	local currentTime = os.time()

	-- Sin requisitos de quest: solo nivel 250 y cooldown.
	for _, teamPlayer in ipairs(players) do
		if teamPlayer:getLevel() < config.requiredLevel then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				teamPlayer:getName()
					.. " needs to be level "
					.. config.requiredLevel
					.. " or higher."
			)

			teamPlayer:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end

		local cooldownUntil =
			teamPlayer:getStorageValue(config.cooldownStorage)

		if cooldownUntil > currentTime then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				teamPlayer:getName()
					.. " has to wait "
					.. formatTime(cooldownUntil - currentTime)
					.. " to face Drume again."
			)

			teamPlayer:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end
	end

	clearRoomMonsters()
	resetCommanderStorages()

	if not createCommanders(player) then
		return true
	end

	if currentEvent then
		stopEvent(currentEvent)
		currentEvent = nil
	end

	local cooldownUntil = currentTime + config.cooldownTime

	for _, teamPlayer in ipairs(players) do
		teamPlayer:setStorageValue(
			config.cooldownStorage,
			cooldownUntil
		)

		teamPlayer:getPosition():sendMagicEffect(CONST_ME_POFF)
		teamPlayer:teleportTo(config.newPosition)
		teamPlayer:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

		teamPlayer:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You have "
				.. config.timeToKill
				.. " minutes to defeat Drume."
		)
	end

	currentEvent = addEvent(
		clearRoomDrume,
		config.timeToKill * 60 * 1000
	)

	toPosition:sendMagicEffect(CONST_ME_POFF)
	return true
end

-- Palanca del mapa Crystal:
-- Client ID: 31366
-- Position: (32456, 32508, 6)
drumeAction:position(Position(32456, 32508, 6))
drumeAction:register()