local config = {
	-- Tiempo que consideramos que el mensaje sigue visible.
	-- Mientras esté activo, no se enviará otro mensaje global del castle.
	messageLockTime = 15, -- segundos

	invasionMessage = "%s has breached the castle walls. Defenders, take up arms!",
    interruptMessage = "%s is approaching the heart of the castle. Stop them before they break the siege!",

	invasionPositions = {
		Position(32221, 32203, 5),
		Position(32221, 32204, 5),
		Position(32221, 32205, 5),
	},

	interruptPositions = {
		Position(32240, 32217, 6),
	}
}

local castleMessageLocked = false

local function samePosition(pos1, pos2)
	return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
end

local function isInPositionList(position, list)
	for _, checkPosition in ipairs(list) do
		if samePosition(position, checkPosition) then
			return true
		end
	end

	return false
end

local function unlockCastleMessage()
	castleMessageLocked = false
end

local function broadcastCastleMessage(message)
	if castleMessageLocked then
		return false
	end

	castleMessageLocked = true
	Game.broadcastMessage(message, MESSAGE_STATUS_WARNING)

	addEvent(unlockCastleMessage, config.messageLockTime * 1000)

	return true
end

local castleWarningTiles = MoveEvent()

function castleWarningTiles.onStepIn(creature, item, position, fromPosition)
	if not creature or not creature:isPlayer() then
		return true
	end

	local player = creature

	if isInPositionList(position, config.invasionPositions) then
		broadcastCastleMessage(string.format(config.invasionMessage, player:getName()))
		return true
	end

	if isInPositionList(position, config.interruptPositions) then
		broadcastCastleMessage(string.format(config.interruptMessage, player:getName()))
		return true
	end

	return true
end

for _, position in ipairs(config.invasionPositions) do
	castleWarningTiles:position(position)
end

for _, position in ipairs(config.interruptPositions) do
	castleWarningTiles:position(position)
end

castleWarningTiles:register()