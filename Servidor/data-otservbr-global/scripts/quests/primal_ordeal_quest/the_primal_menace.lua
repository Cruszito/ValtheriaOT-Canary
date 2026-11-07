local config = {
	bossName = "The Primal Menace",
	bossPos = Position(33558, 32759, 15),

	centerRoom = Position(33558, 32759, 15),
	exitPosition = Position(33520, 32871, 15),
	newPos = Position(33565, 32758, 15),

	leverPosition = Position(33547, 32752, 14),

	requiredLevel = 500,

	playerPositions = {
		Position(33548, 32752, 14),
		Position(33549, 32752, 14),
		Position(33550, 32752, 14),
		Position(33551, 32752, 14),
		Position(33552, 32752, 14),
	},

	specPos = {
		from = Position(33547, 32749, 15),
		to = Position(33570, 32769, 15),
	},

	range = 15,

	-- Tiempo máximo para derrotar al boss
	timeToDefeat = 20 * 60,

	-- Tiempo para salir después de derrotarlo
	timeAfterKill = 60,

	-- Cooldown de 20 horas
	cooldownStorage = 888910,
	cooldownTime = 20 * 60 * 60,
}

local EventPrimalMenaceClear = nil

local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	if hours > 0 then
		return string.format(
			"%d hours, %d minutes and %d seconds",
			hours,
			minutes,
			secs
		)
	elseif minutes > 0 then
		return string.format(
			"%d minutes and %d seconds",
			minutes,
			secs
		)
	end

	return secs .. " seconds"
end

local function isInBossRoom(position)
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
		config.range,
		config.range,
		config.range,
		config.range
	)
end

local function getEntrancePlayers()
	local players = {}

	for _, position in ipairs(config.playerPositions) do
		local tile = Tile(position)
		local creature = tile and tile:getTopCreature()

		if creature and creature:isPlayer() then
			table.insert(players, creature)
		end
	end

	return players
end

local function sendRoomMessage(message)
	local spectators = getRoomSpectators()

	for _, spectator in ipairs(spectators) do
		if spectator:isPlayer()
			and isInBossRoom(spectator:getPosition())
		then
			spectator:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				message
			)
		end
	end
end

local function clearPrimalMenace()
	local spectators = getRoomSpectators()

	for _, spectator in ipairs(spectators) do
		if spectator:isPlayer()
			and isInBossRoom(spectator:getPosition())
		then
			spectator:teleportTo(config.exitPosition)
			spectator:getPosition():sendMagicEffect(
				CONST_ME_TELEPORT
			)

			spectator:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"Time out! You were teleported out by strange forces."
			)
		elseif spectator:isMonster()
			and isInBossRoom(spectator:getPosition())
		then
			spectator:remove()
		end
	end

	EventPrimalMenaceClear = nil
end

local PrimalMenaceDeath = CreatureEvent(
	"PrimalMenaceDeath"
)

function PrimalMenaceDeath.onDeath(creature)
	if not creature then
		return true
	end

	if creature:getName():lower()
		~= config.bossName:lower()
	then
		return true
	end

	if EventPrimalMenaceClear then
		stopEvent(EventPrimalMenaceClear)
		EventPrimalMenaceClear = nil
	end

	sendRoomMessage(
		"The Primal Menace has been defeated. "
			.. "You have 60 seconds to leave the room."
	)

	EventPrimalMenaceClear = addEvent(
		clearPrimalMenace,
		config.timeAfterKill * 1000
	)

	return true
end

PrimalMenaceDeath:register()

local PrimalMenaceAction = Action()

function PrimalMenaceAction.onUse(
	player,
	item,
	fromPosition,
	target,
	toPosition,
	isHotkey
)
	local playerPosition = player:getPosition()
	local activationPosition = config.playerPositions[1]

	-- Solamente el jugador frente a la palanca puede activarla
	if playerPosition.x ~= activationPosition.x
		or playerPosition.y ~= activationPosition.y
		or playerPosition.z ~= activationPosition.z
	then
		return true
	end

	-- Comprobar si ya hay jugadores dentro
	local spectators = getRoomSpectators()

	for _, spectator in ipairs(spectators) do
		if spectator:isPlayer()
			and isInBossRoom(spectator:getPosition())
		then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"There's someone fighting with "
					.. config.bossName
					.. "."
			)

			player:getPosition():sendMagicEffect(
				CONST_ME_POFF
			)

			return true
		end
	end

	local participants = getEntrancePlayers()

	if #participants == 0 then
		return true
	end

	-- Validar nivel y cooldown antes de iniciar
	for _, member in ipairs(participants) do
		if member:getLevel() < config.requiredLevel then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				member:getName()
					.. " needs to be level "
					.. config.requiredLevel
					.. " or higher."
			)

			member:getPosition():sendMagicEffect(
				CONST_ME_POFF
			)

			return true
		end

		local cooldownUntil = member:getStorageValue(
			config.cooldownStorage
		)

		if cooldownUntil > os.time() then
			local remainingTime = cooldownUntil - os.time()

			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				member:getName()
					.. " has to wait "
					.. formatTime(remainingTime)
					.. " to face "
					.. config.bossName
					.. " again."
			)

			member:getPosition():sendMagicEffect(
				CONST_ME_POFF
			)

			return true
		end
	end

	-- Limpiar monstruos anteriores
	for _, spectator in ipairs(spectators) do
		if spectator:isMonster()
			and isInBossRoom(spectator:getPosition())
		then
			spectator:remove()
		end
	end

	if EventPrimalMenaceClear then
		stopEvent(EventPrimalMenaceClear)
		EventPrimalMenaceClear = nil
	end

	-- Crear el boss antes de ingresar al equipo
	local boss = Game.createMonster(
		config.bossName,
		config.bossPos,
		true,
		true
	)

	if not boss then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"The Primal Menace could not be created."
		)

		player:getPosition():sendMagicEffect(
			CONST_ME_POFF
		)

		return true
	end

	boss:registerEvent("PrimalMenaceDeath")

	-- Se aplica desde el momento en que la palanca es activada
	local cooldownUntil = os.time() + config.cooldownTime

	for _, member in ipairs(participants) do
		member:setStorageValue(
			config.cooldownStorage,
			cooldownUntil
		)

		-- Mostrarlo también en la ventana de Boss Cooldowns
		member:setBossCooldown(
			config.bossName,
			cooldownUntil
		)

		local oldPosition = member:getPosition()
		oldPosition:sendMagicEffect(CONST_ME_POFF)

		member:teleportTo(config.newPos)
		member:getPosition():sendMagicEffect(
			CONST_ME_TELEPORT
		)

		member:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"The Primal Menace cooldown has been activated "
				.. "for 20 hours."
		)
	end

	EventPrimalMenaceClear = addEvent(
		clearPrimalMenace,
		config.timeToDefeat * 1000
	)

	return true
end

-- Palanca Client ID: 8911
-- Posición: 33547, 32752, 14
PrimalMenaceAction:position(config.leverPosition)
PrimalMenaceAction:register()