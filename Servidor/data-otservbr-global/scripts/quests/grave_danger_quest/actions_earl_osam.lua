local config = {
	bossName = "Earl Osam",
	bossPosition = Position(33488, 31441, 13),

	centerRoom = Position(33488, 31438, 13),
	exitPosition = Position(33261, 31986, 8),
	teleportPosition = Position(33488, 31430, 13),

	requiredLevel = 250,

	playerPositions = {
		Position(33516, 31444, 13),
		Position(33517, 31444, 13),
		Position(33518, 31444, 13),
		Position(33519, 31444, 13),
		Position(33520, 31444, 13),
	},

	specPos = {
		from = Position(33479, 31429, 13),
		to = Position(33497, 31446, 13),
	},

	timeToDefeat = 20 * 60, -- 20 minutos
	timeAfterKill = 60, -- 60 segundos después de derrotarlo

	-- Cooldown independiente de Grave Danger y del config.lua.
	cooldownStorage = 888933,
	cooldownTime = 20 * 60 * 60, -- 20 horas
}

local earlOsamClearEvent = nil

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

local function isInsideRoom(position)
	return position.z == config.specPos.from.z
		and position.x >= config.specPos.from.x
		and position.x <= config.specPos.to.x
		and position.y >= config.specPos.from.y
		and position.y <= config.specPos.to.y
end

local function getRoomSpectators()
	return Game.getSpectators(
		config.centerRoom,
		false,
		false,
		15,
		15,
		15,
		15
	)
end

local function sendRoomMessage(message)
	for _, spectator in ipairs(getRoomSpectators()) do
		if spectator:isPlayer()
			and isInsideRoom(spectator:getPosition())
		then
			spectator:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				message
			)
		end
	end
end

local function clearEarlOsamRoom()
	for _, spectator in ipairs(getRoomSpectators()) do
		if isInsideRoom(spectator:getPosition()) then
			if spectator:isPlayer() then
				spectator:teleportTo(config.exitPosition)
				spectator:getPosition():sendMagicEffect(
					CONST_ME_TELEPORT
				)

				spectator:say(
					"Time out! You were teleported out by strange forces.",
					TALKTYPE_MONSTER_SAY
				)
			elseif spectator:isMonster() then
				spectator:remove()
			end
		end
	end

	earlOsamClearEvent = nil
end

local function clearRoomMonsters()
	for _, spectator in ipairs(getRoomSpectators()) do
		if spectator:isMonster()
			and isInsideRoom(spectator:getPosition())
		then
			spectator:remove()
		end
	end
end

local earlOsamCustomDeath =
	CreatureEvent("EarlOsamCustomDeath")

function earlOsamCustomDeath.onDeath(creature)
	if not creature
		or creature:getName():lower()
			~= config.bossName:lower()
	then
		return true
	end

	if earlOsamClearEvent then
		stopEvent(earlOsamClearEvent)
		earlOsamClearEvent = nil
	end

	sendRoomMessage(
		"Earl Osam has been defeated. "
			.. "You have 60 seconds to leave the room."
	)

	earlOsamClearEvent = addEvent(
		clearEarlOsamRoom,
		config.timeAfterKill * 1000
	)

	return true
end

earlOsamCustomDeath:register()

local function createEarlOsam()
	local boss = Game.createMonster(
		config.bossName,
		config.bossPosition,
		true,
		true
	)

	if not boss then
		return false
	end

	-- La mecánica de Magical Spheres ya está registrada
	-- desde el archivo del monstruo mediante "earl_osam_transform".
	boss:registerEvent("EarlOsamCustomDeath")

	return true
end

local function getEntrancePlayers()
	local players = {}

	for _, position in ipairs(config.playerPositions) do
		local tile = Tile(position)
		local creature = tile and tile:getTopCreature()

		if creature and creature:isPlayer() then
			players[#players + 1] = creature
		end
	end

	return players
end

local earlOsamAction = Action()

function earlOsamAction.onUse(
	player,
	item,
	fromPosition,
	target,
	toPosition,
	isHotkey
)
	-- Solo el jugador de la primera posición activa la palanca.
	if player:getPosition() ~= config.playerPositions[1] then
		return true
	end

	-- No permite otra pelea mientras haya jugadores dentro.
	for _, spectator in ipairs(getRoomSpectators()) do
		if spectator:isPlayer()
			and isInsideRoom(spectator:getPosition())
		then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"There's someone fighting with Earl Osam."
			)

			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end
	end

	local players = getEntrancePlayers()

	if #players == 0 then
		return true
	end

	local currentTime = os.time()

	-- Sin requisitos de Grave Danger:
	-- solamente nivel 250 y cooldown individual.
	for _, teamPlayer in ipairs(players) do
		if teamPlayer:getLevel() < config.requiredLevel then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				teamPlayer:getName()
					.. " needs to be level "
					.. config.requiredLevel
					.. " or higher."
			)

			teamPlayer:getPosition():sendMagicEffect(
				CONST_ME_POFF
			)

			return true
		end

		local cooldownUntil =
			teamPlayer:getStorageValue(config.cooldownStorage)

		if cooldownUntil > currentTime then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				teamPlayer:getName()
					.. " has to wait "
					.. formatTime(
						cooldownUntil - currentTime
					)
					.. " to face Earl Osam again."
			)

			teamPlayer:getPosition():sendMagicEffect(
				CONST_ME_POFF
			)

			return true
		end
	end

	clearRoomMonsters()

	if earlOsamClearEvent then
		stopEvent(earlOsamClearEvent)
		earlOsamClearEvent = nil
	end

	-- No teletransporta ni aplica cooldown si no puede crear al boss.
	if not createEarlOsam() then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Earl Osam could not be created. "
				.. "Please contact an administrator."
		)

		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local cooldownUntil =
		currentTime + config.cooldownTime

	for _, teamPlayer in ipairs(players) do
		teamPlayer:setStorageValue(
			config.cooldownStorage,
			cooldownUntil
		)

		teamPlayer:getPosition():sendMagicEffect(
			CONST_ME_POFF
		)

		teamPlayer:teleportTo(config.teleportPosition)

		teamPlayer:getPosition():sendMagicEffect(
			CONST_ME_TELEPORT
		)

		teamPlayer:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You have 20 minutes to defeat Earl Osam."
		)
	end

	earlOsamClearEvent = addEvent(
		clearEarlOsamRoom,
		config.timeToDefeat * 1000
	)

	return true
end

-- Palanca:
-- Position: (33515, 31444, 13)
earlOsamAction:position(Position(33515, 31444, 13))
earlOsamAction:register()