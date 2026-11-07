local config = {
	bossName = "Faceless Bane",
	bossPosition = Position(33617, 32561, 13),

	centerRoom = Position(33617, 32563, 13),
	exitPosition = Position(33618, 32523, 15),
	teleportPosition = Position(33617, 32567, 13),

	requiredLevel = 250,

	playerPositions = {
		Position(33638, 32562, 13),
		Position(33639, 32562, 13),
		Position(33640, 32562, 13),
		Position(33641, 32562, 13),
		Position(33642, 32562, 13),
	},

	specPos = {
		from = Position(33607, 32553, 13),
		to = Position(33627, 32570, 13),
	},

	timeToDefeat = 15 * 60, -- 15 minutos
	timeAfterKill = 60, -- 60 segundos para salir

	-- Cooldown individual e independiente de la quest.
	cooldownStorage = 888915,
	cooldownTime = 20 * 60 * 60, -- 20 horas
}

local facelessClearEvent = nil
local facelessTilesStorage =
	Storage.Quest.U12_00.TheDreamCourts.BurriedCatedralGlobal.FacelessTiles

local facelessLifesStorage =
	Storage.Quest.U12_00.TheDreamCourts.BurriedCatedral.FacelessLifes

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

local function resetFacelessMechanic()
	Game.setStorageValue(facelessTilesStorage, 0)
end

local function clearFacelessRoom()
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

	resetFacelessMechanic()
	facelessClearEvent = nil
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

local facelessCustomDeath =
	CreatureEvent("FacelessBaneCustomDeath")

function facelessCustomDeath.onDeath(creature)
	if not creature
		or creature:getName():lower()
			~= config.bossName:lower()
	then
		return true
	end

	if facelessClearEvent then
		stopEvent(facelessClearEvent)
		facelessClearEvent = nil
	end

	sendRoomMessage(
		"Faceless Bane has been defeated. "
			.. "You have 60 seconds to leave the room."
	)

	facelessClearEvent = addEvent(
		clearFacelessRoom,
		config.timeAfterKill * 1000
	)

	return true
end

facelessCustomDeath:register()

local function createFacelessBane()
	resetFacelessMechanic()

	local boss = Game.createMonster(
		config.bossName,
		config.bossPosition,
		true,
		true
	)

	if not boss then
		return false
	end

	-- Reinicia las vidas de la mecánica original de Canary.
	boss:setStorageValue(facelessLifesStorage, -1)
	boss:registerEvent("FacelessBaneCustomDeath")
	boss:setReward(true)

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

local facelessAction = Action()

function facelessAction.onUse(
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

	-- Impide iniciar otra pelea con jugadores dentro.
	for _, spectator in ipairs(getRoomSpectators()) do
		if spectator:isPlayer()
			and isInsideRoom(spectator:getPosition())
		then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"There's someone fighting with Faceless Bane."
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

	-- Sin requisitos de The Dream Courts:
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
					.. " to face Faceless Bane again."
			)

			teamPlayer:getPosition():sendMagicEffect(
				CONST_ME_POFF
			)

			return true
		end
	end

	clearRoomMonsters()
	resetFacelessMechanic()

	if facelessClearEvent then
		stopEvent(facelessClearEvent)
		facelessClearEvent = nil
	end

	-- No aplica cooldown ni teletransporta si no puede crear al boss.
	if not createFacelessBane() then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Faceless Bane could not be created. "
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
			"You have 15 minutes to defeat Faceless Bane."
		)
	end

	facelessClearEvent = addEvent(
		clearFacelessRoom,
		config.timeToDefeat * 1000
	)

	return true
end

-- Palanca:
-- Position: (33637, 32562, 13)
facelessAction:position(Position(33637, 32562, 13))
facelessAction:register()
