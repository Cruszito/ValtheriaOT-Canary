local config = {
	actionId = 45001,

	-- Boss inicial que aparecerá cuando usen la palanca
	bossName = "Fire Demon",
	bossPosition = Position(32393, 31998, 7),

	-- Cooldown de 20 horas por jugador
	cooldownStorage = 45002,
	cooldownTime = 20 * 60 * 60,

	leverPosition = Position(32386, 32000, 8),

	-- Solo el jugador parado aquí puede usar la palanca
	requiredUsePosition = Position(32386, 32001, 8),

	playerPositions = {
		Position(32385, 32001, 8),
		Position(32386, 32001, 8),
		Position(32387, 32001, 8),

		Position(32385, 32002, 8),
		Position(32386, 32002, 8),
		Position(32387, 32002, 8),

		Position(32385, 32003, 8),
		Position(32386, 32003, 8),
		Position(32387, 32003, 8),

		Position(32385, 32004, 8),
		Position(32386, 32004, 8),
		Position(32387, 32004, 8),

		Position(32385, 32005, 8),
		Position(32386, 32005, 8),
		Position(32387, 32005, 8),
	},

	destinationPositions = {
		Position(32391, 32000, 7),
		Position(32389, 32000, 7),
		Position(32390, 32001, 7),
		Position(32390, 32002, 7),
		Position(32389, 31999, 7),
		Position(32392, 32002, 7),
	},

	-- Área completa de la quest/boss rooms.
	-- Esto bloquea la entrada si hay jugadores en cualquier piso del 1 al 7.
	roomCheckCenter = Position(32390, 32000, 4),
    roomArea = {
        from = Position(32384, 31994, 0),
        to = Position(32398, 32008, 7),
    },
	roomRangeX = 20,
	roomRangeY = 20,
}

local function samePosition(pos1, pos2)
	return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
end

local function isInBossArea(position)
	return position.x >= config.roomArea.from.x and position.x <= config.roomArea.to.x
		and position.y >= config.roomArea.from.y and position.y <= config.roomArea.to.y
		and position.z >= config.roomArea.from.z and position.z <= config.roomArea.to.z
end

local function shuffleTable(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

local function getPlayerFromPosition(position)
	local tile = Tile(position)
	if not tile then
		return nil
	end

	local creature = tile:getTopCreature()
	if not creature or not creature:isPlayer() then
		return nil
	end

	return creature
end

local function getTimeLeft(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)

	if hours > 0 and minutes > 0 then
		return hours .. " hours and " .. minutes .. " minutes"
	elseif hours > 0 then
		return hours .. " hours"
	end

	return minutes .. " minutes"
end

local function getBossRoomSpectators()
	return Game.getSpectators(
		config.roomCheckCenter,
		true,
		false,
		config.roomRangeX,
		config.roomRangeX,
		config.roomRangeY,
		config.roomRangeY
	)
end

local function isBossRoomOccupied()
	local spectators = getBossRoomSpectators()

	for _, spectator in ipairs(spectators) do
		if spectator:isPlayer() and isInBossArea(spectator:getPosition()) then
			return true
		end
	end

	return false
end

local function removeOldMonsters()
	local spectators = getBossRoomSpectators()

	for _, spectator in ipairs(spectators) do
		if spectator:isMonster() and isInBossArea(spectator:getPosition()) then
			spectator:remove()
		end
	end
end

local function spawnBoss()
	local boss = Game.createMonster(config.bossName, config.bossPosition, true, true)

	if boss then
		config.bossPosition:sendMagicEffect(CONST_ME_TELEPORT)
		return true
	end

	return false
end

local bossLever = Action()

function bossLever.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not samePosition(player:getPosition(), config.requiredUsePosition) then
		player:sendCancelMessage("You need to stand in the center position to use this lever.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Si ya hay jugadores dentro de la quest, no deja entrar
	if isBossRoomOccupied() then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "There is already a team inside. You must wait until the room is empty.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local players = {}

	for _, position in ipairs(config.playerPositions) do
		local foundPlayer = getPlayerFromPosition(position)
		if foundPlayer then
			table.insert(players, foundPlayer)
		end
	end

	if #players == 0 then
		player:sendCancelMessage("There are no players on the entrance positions.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Revisa cooldown de todos antes de entrar.
	-- Si uno tiene cooldown, no entra nadie y se avisa a todo el grupo.
	for _, foundPlayer in ipairs(players) do
		local cooldown = foundPlayer:getStorageValue(config.cooldownStorage)

		if foundPlayer:getGroup():getId() < 5 and cooldown > os.time() then
			local remainingTime = cooldown - os.time()
			local message = foundPlayer:getName() .. " must wait " .. getTimeLeft(remainingTime) .. " before entering again."

			for _, teamPlayer in ipairs(players) do
				teamPlayer:sendCancelMessage(message)
			end

			foundPlayer:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end
	end

	-- Limpia monsters viejos solo porque ya confirmamos que no hay jugadores dentro
	removeOldMonsters()

	-- Crea el boss antes de mandar a los jugadores
	if not spawnBoss() then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The boss could not be created. Contact an administrator.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local destinations = {}
	for _, position in ipairs(config.destinationPositions) do
		table.insert(destinations, position)
	end

	shuffleTable(destinations)

	for index, foundPlayer in ipairs(players) do
		local destination = destinations[index]

		-- Si hay más jugadores que posiciones destino, reutiliza posiciones al azar
		if not destination then
			destination = config.destinationPositions[math.random(#config.destinationPositions)]
		end

		if foundPlayer:getGroup():getId() < 5 then
			foundPlayer:setStorageValue(config.cooldownStorage, os.time() + config.cooldownTime)
		end

		foundPlayer:getPosition():sendMagicEffect(CONST_ME_POFF)
		foundPlayer:teleportTo(destination)
		foundPlayer:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end

	if item.itemid == 1945 then
		item:transform(1946)
	elseif item.itemid == 1946 then
		item:transform(1945)
	end

	return true
end

bossLever:aid(config.actionId)
bossLever:register()