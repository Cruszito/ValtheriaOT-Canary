local sourcePositionOne = Position(32322, 32163, 14)
local sourcePositionTwo = Position(32322, 32164, 14)

local destinationPosition = Position(32315, 32172, 14)

local sqmTeleport = MoveEvent()

function sqmTeleport.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	position:sendMagicEffect(CONST_ME_TELEPORT)
	player:teleportTo(destinationPosition)
	destinationPosition:sendMagicEffect(CONST_ME_TELEPORT)

	return true
end

sqmTeleport:type("stepin")
sqmTeleport:position(sourcePositionOne, sourcePositionTwo)
sqmTeleport:register()