local config = {
	bossName = "Arbaziloth",
	bossPos = Position(34034, 32330, 14),

	centerRoom = Position(34034, 32331, 14),
	exitPosition = Position(34058, 32403, 14),
	newPos = Position(34034, 32340, 14),

	playerPositions = {
		Position(34058, 32395, 14),
		Position(34058, 32396, 14),
		Position(34058, 32397, 14),
		Position(34058, 32398, 14),
		Position(34058, 32399, 14),
	},

	specPos = {
		from = Position(34025, 32322, 14),
		to = Position(34043, 32341, 14),
	},

	monsters = {
		{ name = "The Forgemaster", pos = Position(34033, 32330, 14) },
	},

	range = 15,

	-- Tienen 20 minutos para matar a Arbaziloth
	timeToDefeat = 20 * 60,

	-- Después de matar al boss, tienen 60 segundos para salir
	timeAfterKill = 60,

	-- Cooldown de Arbaziloth: 20 horas
	cooldownStorage = 888929,
	cooldownTime = 12 * 60 * 60,
}

local EventArbazilothClear = nil

Game.setStorageValue("globalArbazilothHeal", 0)

local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	if hours > 0 then
		return hours .. " hours, " .. minutes .. " minutes and " .. secs .. " seconds"
	elseif minutes > 0 then
		return minutes .. " minutes and " .. secs .. " seconds"
	else
		return secs .. " seconds"
	end
end

local function isInBossRoom(pos)
	return pos.z == 14
		and pos.x >= config.specPos.from.x and pos.x <= config.specPos.to.x
		and pos.y >= config.specPos.from.y and pos.y <= config.specPos.to.y
end

local function sendRoomMessage(message)
	local spectators = Game.getSpectators(config.centerRoom, false, false, config.range, config.range, config.range, config.range)

	for i = 1, #spectators do
		local spectator = spectators[i]

		if spectator:isPlayer() and isInBossRoom(spectator:getPosition()) then
			spectator:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
		end
	end
end

local function clearArbaziloth()
	local spectators = Game.getSpectators(config.centerRoom, false, false, config.range, config.range, config.range, config.range)

	for i = 1, #spectators do
		local spectator = spectators[i]

		if spectator:isPlayer() and isInBossRoom(spectator:getPosition()) then
			spectator:teleportTo(config.exitPosition)
			spectator:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			spectator:say("Time out! You were teleported out by strange forces.", TALKTYPE_MONSTER_SAY)
		elseif spectator:isMonster() and isInBossRoom(spectator:getPosition()) then
			spectator:remove()
		end
	end

	EventArbazilothClear = nil
end

local ArbazilothDeath = CreatureEvent("ArbazilothDeath")

function ArbazilothDeath.onDeath(creature)
	if not creature then
		return true
	end

	if creature:getName():lower() ~= config.bossName:lower() then
		return true
	end

	if EventArbazilothClear then
		stopEvent(EventArbazilothClear)
		EventArbazilothClear = nil
	end

	sendRoomMessage("Arbaziloth has been defeated. You have 60 seconds to leave the room.")

	EventArbazilothClear = addEvent(clearArbaziloth, config.timeAfterKill * 1000)

	return true
end

ArbazilothDeath:register()

local function startBossFight()
	Game.setStorageValue("globalArbazilothHeal", 0)

	local boss = Game.createMonster(config.bossName, config.bossPos, true, true)

	if boss then
		boss:registerEvent("ArbazilothDeath")
	end

	for _, monster in ipairs(config.monsters) do
		Game.createMonster(monster.name, monster.pos, true, true)
	end
end

local ArbazilothAction = Action()

function ArbazilothAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local playerPosition = player:getPosition()

	-- Solo el jugador de la primera posición puede activar la lever
	if playerPosition.x ~= 34058 or playerPosition.y ~= 32395 or playerPosition.z ~= 14 then
		return true
	end

	-- Validar si ya hay jugadores dentro de la sala
	local spectators = Game.getSpectators(config.centerRoom, false, false, config.range, config.range, config.range, config.range)

	for i = 1, #spectators do
		local spectator = spectators[i]

		if spectator:isPlayer() and isInBossRoom(spectator:getPosition()) then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "There's someone fighting with Arbaziloth.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end
	end

	-- Validar cooldown de todos los jugadores en la entrada
	for _, position in ipairs(config.playerPositions) do
		local tile = Tile(position)
		local creature = tile and tile:getTopCreature()

		if creature and creature:isPlayer() then
			if creature:getGroup():getId() < 5 and creature:getStorageValue(config.cooldownStorage) > os.time() then
				local remainingTime = creature:getStorageValue(config.cooldownStorage) - os.time()
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, creature:getName() .. " has to wait " .. formatTime(remainingTime) .. " to face Arbaziloth again.")
				creature:getPosition():sendMagicEffect(CONST_ME_POFF)
				return true
			end
		end
	end

	-- Limpiar monstruos anteriores dentro de la sala
	for i = 1, #spectators do
		local spectator = spectators[i]

		if spectator:isMonster() and isInBossRoom(spectator:getPosition()) then
			spectator:remove()
		end
	end

	if EventArbazilothClear then
		stopEvent(EventArbazilothClear)
		EventArbazilothClear = nil
	end

	-- Teleportar jugadores y aplicar cooldown
	for _, position in ipairs(config.playerPositions) do
		local tile = Tile(position)
		local creature = tile and tile:getTopCreature()

		if creature and creature:isPlayer() then
			creature:getPosition():sendMagicEffect(CONST_ME_POFF)
			creature:teleportTo(config.newPos)
			creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

			if creature:getGroup():getId() < 5 then
				creature:setStorageValue(config.cooldownStorage, os.time() + config.cooldownTime)
			end
		end
	end

	startBossFight()

	-- Si no matan a Arbaziloth en 20 minutos, los saca
	EventArbazilothClear = addEvent(clearArbaziloth, config.timeToDefeat * 1000)

	return true
end

-- Lever de Arbaziloth
-- Position: 34058, 32394, 14
ArbazilothAction:position(Position(34058, 32394, 14))
ArbazilothAction:register()