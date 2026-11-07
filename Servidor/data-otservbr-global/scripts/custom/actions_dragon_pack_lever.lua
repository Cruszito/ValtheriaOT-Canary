local config = {
	leverUniqueId = 2003,

	bossName = "Dragon Pack",
	bossPosition = Position(33213, 31033, 13),

	enterPosition = Position(33214, 31039, 13),
	exitPosition = Position(33260, 31061, 13),

	-- Solo el jugador de esta posición puede accionar la palanca.
	leaderPosition = Position(33260, 31061, 13),

	playerPositions = {
		Position(33260, 31061, 13),
		Position(33261, 31061, 13),
		Position(33262, 31061, 13),
		Position(33263, 31061, 13),
		Position(33264, 31061, 13),
	},

	requiredLevel = 250,

	-- Cooldown individual por personaje.
	cooldownStorage = 920030,
	cooldownTime = 20 * 60 * 60, -- 20 horas

	timeToDefeat = 20 * 60, -- 20 minutos
	timeAfterKill = 60, -- 60 segundos para salir

	roomCenter = Position(33214, 31036, 13),
	roomRangeX = 15,
	roomRangeY = 15,
}

local clearRoomEvent = nil

local function samePosition(firstPosition, secondPosition)
	return firstPosition.x == secondPosition.x
		and firstPosition.y == secondPosition.y
		and firstPosition.z == secondPosition.z
end

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
		config.roomCenter,
		false,
		onlyPlayers,
		config.roomRangeX,
		config.roomRangeX,
		config.roomRangeY,
		config.roomRangeY
	)
end

local function roomHasPlayers()
	return #getRoomSpectators(true) > 0
end

local function sendRoomMessage(message)
	for _, spectator in ipairs(getRoomSpectators(true)) do
		spectator:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			message
		)
	end
end

local function stopClearEvent()
	if clearRoomEvent then
		stopEvent(clearRoomEvent)
		clearRoomEvent = nil
	end
end

local function clearDragonPackRoom()
	stopClearEvent()

	for _, spectator in ipairs(getRoomSpectators(false)) do
		if spectator:isPlayer() then
			spectator:teleportTo(config.exitPosition)
			spectator:getPosition():sendMagicEffect(
				CONST_ME_TELEPORT
			)
			spectator:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"You were removed from the Dragon Pack room."
			)
		elseif spectator:isMonster() then
			spectator:remove()
		end
	end
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

	for _, position in ipairs(config.playerPositions) do
		local tile = Tile(position)
		local creature = tile and tile:getTopCreature()

		if creature and creature:isPlayer() then
			players[#players + 1] = creature
		end
	end

	return players
end

local dragonPackDeath =
	CreatureEvent("DragonPackCustomDeath")

function dragonPackDeath.onDeath(creature)
	if not creature
		or creature:getName():lower()
			~= config.bossName:lower()
	then
		return true
	end

	stopClearEvent()

	sendRoomMessage(
		"Dragon Pack has been defeated. "
			.. "You have 60 seconds to leave the room."
	)

	clearRoomEvent = addEvent(
		clearDragonPackRoom,
		config.timeAfterKill * 1000
	)

	return true
end

dragonPackDeath:register()

local dragonPackLever = Action()

function dragonPackLever.onUse(
	player,
	item,
	fromPosition,
	target,
	toPosition,
	isHotkey
)
	if not samePosition(
		player:getPosition(),
		config.leaderPosition
	) then
		player:sendCancelMessage(
			"Only the player standing in the first position "
				.. "can pull this lever."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local players = getEntrancePlayers()

	if #players == 0 then
		player:sendCancelMessage(
			"There are no players in the boss entrance positions."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if roomHasPlayers() then
		player:sendCancelMessage(
			"Someone is already fighting Dragon Pack."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local currentTime = os.time()

	for _, participant in ipairs(players) do
		if participant:getLevel() < config.requiredLevel then
			player:sendCancelMessage(
				participant:getName()
					.. " needs to be level "
					.. config.requiredLevel
					.. " or higher."
			)
			participant:getPosition():sendMagicEffect(
				CONST_ME_POFF
			)
			return true
		end

		local cooldownUntil =
			participant:getStorageValue(
				config.cooldownStorage
			)

		if cooldownUntil > currentTime then
			player:sendCancelMessage(
				participant:getName()
					.. " has to wait "
					.. formatTime(
						cooldownUntil - currentTime
					)
					.. " to face Dragon Pack again."
			)
			participant:getPosition():sendMagicEffect(
				CONST_ME_POFF
			)
			return true
		end
	end

	stopClearEvent()
	clearRoomMonsters()

	local boss = Game.createMonster(
		config.bossName,
		config.bossPosition,
		true,
		true
	)

	if not boss then
		player:sendCancelMessage(
			"Dragon Pack could not be created. "
				.. "Check whether dragon_pack.lua was loaded."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	boss:registerEvent("DragonPackCustomDeath")
	boss:setReward(true)

	config.bossPosition:sendMagicEffect(CONST_ME_TELEPORT)

	local cooldownUntil =
		currentTime + config.cooldownTime

	for _, participant in ipairs(players) do
		participant:setStorageValue(
			config.cooldownStorage,
			cooldownUntil
		)

		participant:getPosition():sendMagicEffect(
			CONST_ME_TELEPORT
		)

		participant:teleportTo(config.enterPosition)

		participant:getPosition():sendMagicEffect(
			CONST_ME_TELEPORT
		)

		participant:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You have 20 minutes to defeat Dragon Pack."
		)
	end

	clearRoomEvent = addEvent(
		clearDragonPackRoom,
		config.timeToDefeat * 1000
	)

	return true
end

-- La palanca del mapa debe tener Unique ID 2003.
dragonPackLever:uid(config.leverUniqueId)
dragonPackLever:register()
