local config = {
	bossName = "Ghulosh",
	bossPosition = Position(32756, 32720, 10),

	bookName = "The Book of Death",
	bookPosition = Position(32756, 32718, 10),

	boneJawName = "Bone Jaw",
	boneJawPosition = Position(32755, 32721, 10),
	boneJawInterval = 25 * 1000,

	centerRoom = Position(32756, 32721, 10),
	exitPosition = Position(32660, 32713, 13),
	teleportPosition = Position(32757, 32727, 10),

	requiredLevel = 250,

	playerPositions = {
		Position(32747, 32773, 10),
		Position(32748, 32773, 10),
		Position(32749, 32773, 10),
		Position(32750, 32773, 10),
		Position(32751, 32773, 10),
	},

	specPos = {
		from = Position(32748, 32713, 10),
		to = Position(32763, 32729, 10),
	},

	timeToDefeat = 20 * 60, -- 20 minutos

	-- Cooldown independiente de The Secret Library y del config.lua.
	cooldownStorage = 888916,
	cooldownTime = 20 * 60 * 60, -- 20 horas
}

local ghuloshStageStorage =
	Storage.Quest.U11_80.TheSecretLibrary.Library.Ghulosh

local clearEvent = nil
local boneJawEvent = nil

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

local function roomHasPlayers()
	for _, spectator in ipairs(getRoomSpectators()) do
		if spectator:isPlayer()
			and isInsideRoom(spectator:getPosition())
		then
			return true
		end
	end

	return false
end

local function stopBossEvents()
	if clearEvent then
		stopEvent(clearEvent)
		clearEvent = nil
	end

	if boneJawEvent then
		stopEvent(boneJawEvent)
		boneJawEvent = nil
	end
end

local function resetGhuloshMechanic()
	Game.setStorageValue(ghuloshStageStorage, -1)
end

local function clearGhuloshRoom()
	stopBossEvents()

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

	resetGhuloshMechanic()
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

local function spawnBoneJaw()
	boneJawEvent = nil

	if not roomHasPlayers() then
		return
	end

	Game.createMonster(
		config.boneJawName,
		config.boneJawPosition,
		true,
		true
	)

	boneJawEvent = addEvent(
		spawnBoneJaw,
		config.boneJawInterval
	)
end

local function createFightMonsters()
	-- El stage debe comenzar en 1 para que ghuloshThink active
	-- sus transformaciones al 75%, 50% y 25% de vida.
	Game.setStorageValue(ghuloshStageStorage, 1)

	local boss = Game.createMonster(
		config.bossName,
		config.bossPosition,
		true,
		true
	)

	if not boss then
		resetGhuloshMechanic()
		return false
	end

	local book = Game.createMonster(
		config.bookName,
		config.bookPosition,
		true,
		true
	)

	if not book then
		boss:remove()
		resetGhuloshMechanic()
		return false
	end

	-- Primer Bone Jaw después de la animación inicial.
	config.boneJawPosition:sendMagicEffect(CONST_ME_TELEPORT)

	boneJawEvent = addEvent(
		spawnBoneJaw,
		4 * 1000
	)

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

local ghuloshAction = Action()

function ghuloshAction.onUse(
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

	-- No permite iniciar otra pelea mientras haya jugadores dentro.
	if roomHasPlayers() then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"There's someone fighting with Ghulosh."
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
					.. " to face Ghulosh again."
			)

			teamPlayer:getPosition():sendMagicEffect(
				CONST_ME_POFF
			)

			return true
		end
	end

	stopBossEvents()
	clearRoomMonsters()
	resetGhuloshMechanic()

	-- Si falta Ghulosh o The Book of Death, no teletransporta
	-- ni consume el cooldown.
	if not createFightMonsters() then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Ghulosh or The Book of Death could not be created. "
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
			"You have 20 minutes to defeat Ghulosh."
		)
	end

	clearEvent = addEvent(
		clearGhuloshRoom,
		config.timeToDefeat * 1000
	)

	return true
end

-- Palanca:
-- Position: (32746, 32773, 10)
ghuloshAction:position(Position(32746, 32773, 10))
ghuloshAction:register()