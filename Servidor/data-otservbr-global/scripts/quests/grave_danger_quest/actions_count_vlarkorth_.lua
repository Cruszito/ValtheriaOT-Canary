local config = {
	bossName = "Count Vlarkorth",
	bossPosition = Position(33456, 31434, 13),

	centerRoom = Position(33456, 31437, 13),
	exitPosition = Position(33195, 31690, 8),
	teleportPosition = Position(33454, 31445, 13),

	requiredLevel = 250,

	playerPositions = {
		Position(33455, 31413, 13),
		Position(33456, 31413, 13),
		Position(33457, 31413, 13),
		Position(33458, 31413, 13),
		Position(33459, 31413, 13),
	},

	specPos = {
		from = Position(33448, 31428, 13),
		to = Position(33464, 31446, 13),
	},

	timeToDefeat = 20 * 60, -- 20 minutos
	timeAfterKill = 60, -- 60 segundos después de matar al boss

	-- Cooldown independiente de la quest y del config.lua.
	cooldownStorage = 888932,
	cooldownTime = 20 * 60 * 60, -- 20 horas
}

local vlarkorthClearEvent = nil

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

local function clearVlarkorthRoom()
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

	vlarkorthClearEvent = nil
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

local vlarkorthCustomDeath =
	CreatureEvent("CountVlarkorthCustomDeath")

function vlarkorthCustomDeath.onDeath(creature)
	if not creature
		or creature:getName():lower()
			~= config.bossName:lower()
	then
		return true
	end

	if vlarkorthClearEvent then
		stopEvent(vlarkorthClearEvent)
		vlarkorthClearEvent = nil
	end

	sendRoomMessage(
		"Count Vlarkorth has been defeated. "
			.. "You have 60 seconds to leave the room."
	)

	vlarkorthClearEvent = addEvent(
		clearVlarkorthRoom,
		config.timeAfterKill * 1000
	)

	return true
end

vlarkorthCustomDeath:register()

local function createVlarkorth()
	local boss = Game.createMonster(
		config.bossName,
		config.bossPosition,
		true,
		true
	)

	if not boss then
		return false
	end

	-- Conserva la mecánica de:
	-- creaturescripts_count_vlarkorth.lua
	boss:registerEvent("CountVlarkorthCustomDeath")

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

local vlarkorthAction = Action()

function vlarkorthAction.onUse(
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

	-- No permite otra pelea si hay jugadores dentro.
	for _, spectator in ipairs(getRoomSpectators()) do
		if spectator:isPlayer()
			and isInsideRoom(spectator:getPosition())
		then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"There's someone fighting with Count Vlarkorth."
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
					.. " to face Count Vlarkorth again."
			)

			teamPlayer:getPosition():sendMagicEffect(
				CONST_ME_POFF
			)

			return true
		end
	end

	-- Limpia restos de una pelea anterior.
	clearRoomMonsters()

	if vlarkorthClearEvent then
		stopEvent(vlarkorthClearEvent)
		vlarkorthClearEvent = nil
	end

	-- Si el boss no puede crearse, no teletransporta ni aplica cooldown.
	if not createVlarkorth() then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Count Vlarkorth could not be created. "
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
			"You have 20 minutes to defeat Count Vlarkorth."
		)
	end

	vlarkorthClearEvent = addEvent(
		clearVlarkorthRoom,
		config.timeToDefeat * 1000
	)

	return true
end

-- Palanca:
-- Position: (33454, 31413, 13)
vlarkorthAction:position(Position(33454, 31413, 13))
vlarkorthAction:register()