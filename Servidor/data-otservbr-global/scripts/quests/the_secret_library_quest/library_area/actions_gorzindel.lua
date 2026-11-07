local config = {
	bossName = "Gorzindel",
	bossPosition = Position(32687, 32715, 10),

	centerRoom = Position(32687, 32718, 10),
	exitPosition = Position(32660, 32734, 12),
	teleportPosition = Position(32686, 32721, 10),

	requiredLevel = 250,

	playerPositions = {
		Position(32747, 32749, 10),
		Position(32748, 32749, 10),
		Position(32749, 32749, 10),
		Position(32750, 32749, 10),
		Position(32751, 32749, 10),
	},

	-- Área completa de la mecánica, incluyendo los cinco tomos.
	roomArea = {
		from = Position(32674, 32705, 10),
		to = Position(32700, 32731, 10),
	},

	monsters = {
		{ name = "Mean Minion", position = Position(32687, 32717, 10) },

		{ name = "Malicious Minion", position = Position(32687, 32720, 10) },
		{ name = "Malicious Minion", position = Position(32687, 32708, 10) },
		{ name = "Malicious Minion", position = Position(32698, 32716, 10) },
		{ name = "Malicious Minion", position = Position(32693, 32730, 10) },
		{ name = "Malicious Minion", position = Position(32681, 32730, 10) },
		{ name = "Malicious Minion", position = Position(32676, 32716, 10) },

		{ name = "Stolen Knowledge of Armor", position = Position(32687, 32707, 10) },
		{ name = "Stolen Knowledge of Summoning", position = Position(32698, 32715, 10) },
		{ name = "Stolen Knowledge of Lifesteal", position = Position(32693, 32729, 10) },
		{ name = "Stolen Knowledge of Spells", position = Position(32681, 32729, 10) },
		{ name = "Stolen Knowledge of Healing", position = Position(32676, 32715, 10) },

		{ name = "Stolen Tome of Portals", position = Position(32688, 32715, 10) },
	},

	timeToDefeat = 20 * 60, -- 20 minutos
	timeAfterKill = 60, -- 60 segundos para abandonar la sala

	-- Cooldown individual, sin depender de The Secret Library ni config.lua.
	cooldownStorage = 888917,
	cooldownTime = 20 * 60 * 60, -- 20 horas
}

local clearEvent = nil

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
	return position.z == config.roomArea.from.z
		and position.x >= config.roomArea.from.x
		and position.x <= config.roomArea.to.x
		and position.y >= config.roomArea.from.y
		and position.y <= config.roomArea.to.y
end

local function getRoomSpectators()
	return Game.getSpectators(
		config.centerRoom,
		false,
		false,
		16,
		16,
		16,
		16
	)
end

local function roomHasPlayers()
	for _, spectator in ipairs(getRoomSpectators()) do
		if spectator:isPlayer() and isInsideRoom(spectator:getPosition()) then
			return true
		end
	end

	return false
end

local function sendRoomMessage(message)
	for _, spectator in ipairs(getRoomSpectators()) do
		if spectator:isPlayer() and isInsideRoom(spectator:getPosition()) then
			spectator:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
		end
	end
end

local function clearRoom()
	for _, spectator in ipairs(getRoomSpectators()) do
		if isInsideRoom(spectator:getPosition()) then
			if spectator:isPlayer() then
				spectator:teleportTo(config.exitPosition)
				spectator:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				spectator:say(
					"Time out! You were teleported out by strange forces.",
					TALKTYPE_MONSTER_SAY
				)
			elseif spectator:isMonster() then
				spectator:remove()
			end
		end
	end

	clearEvent = nil
end

local function clearRoomMonsters()
	for _, spectator in ipairs(getRoomSpectators()) do
		if spectator:isMonster() and isInsideRoom(spectator:getPosition()) then
			spectator:remove()
		end
	end

	-- Elimina portales temporales que hayan quedado de una pelea anterior.
	for x = config.roomArea.from.x, config.roomArea.to.x do
		for y = config.roomArea.from.y, config.roomArea.to.y do
			local tile = Tile(Position(x, y, config.roomArea.from.z))
			local portal = tile and tile:getItemById(1949)

			while portal do
				portal:remove()
				portal = tile:getItemById(1949)
			end
		end
	end
end

local gorzindelCustomDeath = CreatureEvent("GorzindelCustomDeath")

function gorzindelCustomDeath.onDeath(creature)
	if not creature or creature:getName():lower() ~= config.bossName:lower() then
		return true
	end

	if clearEvent then
		stopEvent(clearEvent)
		clearEvent = nil
	end

	sendRoomMessage(
		"Gorzindel has been defeated. You have 60 seconds to leave the room."
	)

	clearEvent = addEvent(clearRoom, config.timeAfterKill * 1000)
	return true
end

gorzindelCustomDeath:register()

local function createFightMonsters()
	local createdMonsters = {}

	local boss = Game.createMonster(
		config.bossName,
		config.bossPosition,
		true,
		true
	)

	if not boss then
		return false
	end

	createdMonsters[#createdMonsters + 1] = boss
	boss:registerEvent("GorzindelCustomDeath")

	for _, monsterInfo in ipairs(config.monsters) do
		local monster = Game.createMonster(
			monsterInfo.name,
			monsterInfo.position,
			true,
			true
		)

		if not monster then
			for _, createdMonster in ipairs(createdMonsters) do
				if createdMonster then
					createdMonster:remove()
				end
			end

			return false
		end

		createdMonsters[#createdMonsters + 1] = monster
	end

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

local gorzindelAction = Action()

function gorzindelAction.onUse(
	player,
	item,
	fromPosition,
	target,
	toPosition,
	isHotkey
)
	-- Solo el jugador colocado frente a la palanca puede activarla.
	if player:getPosition() ~= config.playerPositions[1] then
		return true
	end

	if roomHasPlayers() then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"There's someone fighting with Gorzindel."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local players = getEntrancePlayers()

	if #players == 0 then
		return true
	end

	local currentTime = os.time()

	-- Sin requisitos de The Secret Library:
	-- únicamente nivel 250 y cooldown individual.
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
					.. " to face Gorzindel again."
			)

			teamPlayer:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end
	end

	if clearEvent then
		stopEvent(clearEvent)
		clearEvent = nil
	end

	clearRoomMonsters()

	-- Gorzindel empieza inmune. Los cinco Stolen Knowledges deben morir
	-- para que creaturescripts_gorzindel.lua retire "gorzindelHealth".
	if not createFightMonsters() then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Gorzindel's encounter could not be created. "
				.. "Please contact an administrator."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local cooldownUntil = currentTime + config.cooldownTime

	for _, teamPlayer in ipairs(players) do
		teamPlayer:setStorageValue(
			config.cooldownStorage,
			cooldownUntil
		)

		teamPlayer:getPosition():sendMagicEffect(CONST_ME_POFF)
		teamPlayer:teleportTo(config.teleportPosition)
		teamPlayer:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

		teamPlayer:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You have 20 minutes to defeat Gorzindel."
		)
	end

	clearEvent = addEvent(
		clearRoom,
		config.timeToDefeat * 1000
	)

	return true
end

-- Palanca:
-- Position: (32746, 32749, 10)
gorzindelAction:position(Position(32746, 32749, 10))
gorzindelAction:register()