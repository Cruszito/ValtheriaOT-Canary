local armorId = 31482
local armorPos = Position(33398, 32640, 6)
local metalWallId = 31449

local function createArmor(id, amount, pos)
	local armor = Game.createItem(id, amount, pos)
	if armor then
		armor:setActionId(40003)
	end
end

local config = {
	bossName = "Scarlett Etzel",
	bossPos = Position(33396, 32643, 6),

	centerRoom = Position(33396, 32649, 6),
	exitPosition = Position(33395, 32665, 6),
	teleportPosition = Position(33396, 32651, 6),

	requiredLevel = 250,

	playerPositions = {
		Position(33395, 32661, 6),
		Position(33394, 32662, 6),
		Position(33396, 32662, 6),
		Position(33395, 32662, 6),
		Position(33395, 32663, 6),
	},

	specPos = {
		from = Position(33385, 32638, 6),
		to = Position(33406, 32660, 6),
	},

	timeToDefeat = 20 * 60, -- 20 minutos para matar a Scarlett
	timeAfterKill = 60, -- 60 segundos para salir después de matarla

	cooldownStorage = 888912,
	cooldownTime = 20 * 60 * 60, -- 20 horas
}

local scarlettClearEvent = nil

local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	if hours > 0 then
		return string.format("%d hour(s), %d minute(s) and %d second(s)", hours, minutes, secs)
	elseif minutes > 0 then
		return string.format("%d minute(s) and %d second(s)", minutes, secs)
	end

	return string.format("%d second(s)", secs)
end

local function isInBossRoom(position)
	return position.z == config.specPos.from.z
		and position.x >= config.specPos.from.x
		and position.x <= config.specPos.to.x
		and position.y >= config.specPos.from.y
		and position.y <= config.specPos.to.y
end

local function getRoomSpectators()
	return Game.getSpectators(config.centerRoom, false, false, 15, 15, 15, 15)
end

local function clearScarlettRoom()
	local spectators = getRoomSpectators()

	for _, spectator in ipairs(spectators) do
		if isInBossRoom(spectator:getPosition()) then
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

	scarlettClearEvent = nil
end

local function sendRoomMessage(message)
	for _, spectator in ipairs(getRoomSpectators()) do
		if spectator:isPlayer() and isInBossRoom(spectator:getPosition()) then
			spectator:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
		end
	end
end

local scarlettCustomDeath = CreatureEvent("ScarlettCustomDeath")

function scarlettCustomDeath.onDeath(creature)
	if not creature or creature:getName():lower() ~= config.bossName:lower() then
		return true
	end

	if scarlettClearEvent then
		stopEvent(scarlettClearEvent)
		scarlettClearEvent = nil
	end

	sendRoomMessage(
		"Scarlett Etzel has been defeated. You have 60 seconds to leave the room."
	)

	scarlettClearEvent = addEvent(
		clearScarlettRoom,
		config.timeAfterKill * 1000
	)

	return true
end

scarlettCustomDeath:register()

local function createScarlett()
	SCARLETT_MAY_TRANSFORM = 0

	local scarlett = Game.createMonster(
		config.bossName,
		config.bossPos,
		true,
		true
	)

	if not scarlett then
		return false
	end

	-- Necesario para que funcione la mecánica de daño y espejos.
	scarlett:setStorageValue(
		Storage.Quest.U12_20.GraveDanger.CobraBastion.Questline,
		1
	)

	scarlett:registerEvent("ScarlettCustomDeath")
	return true
end

local scarlettAction = Action()

function scarlettAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Solo el jugador colocado frente a la palanca puede activarla.
	if player:getPosition() ~= config.playerPositions[1] then
		return true
	end

	local spectators = getRoomSpectators()

	-- No permite iniciar otra pelea si ya hay jugadores dentro.
	for _, spectator in ipairs(spectators) do
		if spectator:isPlayer() and isInBossRoom(spectator:getPosition()) then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"There's someone fighting with Scarlett Etzel."
			)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end
	end

	local players = {}
	local currentTime = os.time()

	-- Valida únicamente nivel y cooldown; no revisa storages de quest.
	for _, position in ipairs(config.playerPositions) do
		local tile = Tile(position)
		local creature = tile and tile:getTopCreature()

		if creature and creature:isPlayer() then
			if creature:getLevel() < config.requiredLevel then
				player:sendTextMessage(
					MESSAGE_EVENT_ADVANCE,
					creature:getName()
						.. " needs to be level "
						.. config.requiredLevel
						.. " or higher."
				)
				creature:getPosition():sendMagicEffect(CONST_ME_POFF)
				return true
			end

			local cooldownUntil = creature:getStorageValue(config.cooldownStorage)
			if cooldownUntil > currentTime then
				player:sendTextMessage(
					MESSAGE_EVENT_ADVANCE,
					creature:getName()
						.. " has to wait "
						.. formatTime(cooldownUntil - currentTime)
						.. " to face Scarlett Etzel again."
				)
				creature:getPosition():sendMagicEffect(CONST_ME_POFF)
				return true
			end

			players[#players + 1] = creature
		end
	end

	if #players == 0 then
		return true
	end

	-- Limpia monstruos de una pelea anterior.
	for _, spectator in ipairs(spectators) do
		if spectator:isMonster() and isInBossRoom(spectator:getPosition()) then
			spectator:remove()
		end
	end

	if scarlettClearEvent then
		stopEvent(scarlettClearEvent)
		scarlettClearEvent = nil
	end

	-- Si Scarlett no puede crearse, no teletransporta ni aplica cooldown.
	if not createScarlett() then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Scarlett Etzel could not be created. Please contact an administrator."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local cooldownUntil = currentTime + config.cooldownTime

	for _, currentPlayer in ipairs(players) do
		currentPlayer:getPosition():sendMagicEffect(CONST_ME_POFF)
		currentPlayer:teleportTo(config.teleportPosition)
		currentPlayer:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		currentPlayer:setStorageValue(config.cooldownStorage, cooldownUntil)
	end

	scarlettClearEvent = addEvent(
		clearScarlettRoom,
		config.timeToDefeat * 1000
	)

	return true
end

-- Palanca ubicada en (33395, 32660, 6).
scarlettAction:position(Position(33395, 32660, 6))
scarlettAction:register()

local transformTo = {
	[31474] = 31475,
	[31475] = 31476,
	[31476] = 31477,
	[31477] = 31474,
}

local mirror = {
	fromPos = Position(33389, 32641, 6),
	toPos = Position(33403, 32655, 6),
	mirrors = { 31474, 31475, 31476, 31477 },
}

local function backMirror()
	for x = mirror.fromPos.x, mirror.toPos.x do
		for y = mirror.fromPos.y, mirror.toPos.y do
			local tile = Tile(Position(x, y, 6))

			if tile then
				for _, id in pairs(mirror.mirrors) do
					local mirrorItem = tile:getItemById(id)

					if mirrorItem then
						mirrorItem:transform(
							mirror.mirrors[math.random(#mirror.mirrors)]
						)
						mirrorItem:setActionId(40003)
						mirrorItem:getPosition():sendMagicEffect(CONST_ME_POFF)
					end
				end
			end
		end
	end
end

local graveScarlettAid = Action()

function graveScarlettAid.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Sin requisitos de Gaffir, Custodian, Quaid ni otros storages de quest.
	if table.contains(transformTo, item.itemid) then
		local nextMirrorId = transformTo[item.itemid]

		if nextMirrorId then
			item:transform(nextMirrorId)
			item:setActionId(40003)
			item:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	elseif item.itemid == armorId then
		item:getPosition():sendMagicEffect(CONST_ME_THUNDER)
		item:remove(1)

		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You hold the old chestplate of Galthein in front of you. "
				.. "It does not fit and is far too old to withstand any attack."
		)

		addEvent(createArmor, 20 * 1000, armorId, 1, armorPos)
		addEvent(backMirror, 10 * 1000)

		SCARLETT_MAY_TRANSFORM = 1

		addEvent(function()
			SCARLETT_MAY_TRANSFORM = 0
		end, 2000)
	elseif item.itemid == metalWallId then
		if player:getPosition().y == 32666 then
			player:teleportTo(Position(33395, 32668, 6))
		else
			player:teleportTo(Position(33395, 32666, 6))
		end

		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end

	return true
end

-- Muro, espejos y armadura.
graveScarlettAid:aid(40003)
graveScarlettAid:register()