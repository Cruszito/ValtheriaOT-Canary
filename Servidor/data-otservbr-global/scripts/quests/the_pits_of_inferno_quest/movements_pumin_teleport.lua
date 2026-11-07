local puminTeleport = MoveEvent()

function puminTeleport.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	-- Omite los diálogos de los burócratas y concede el permiso automáticamente.
	if player:getStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin) < 9 then
		player:setStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin, 9)
	end

	player:teleportTo(Position(32786, 32308, 15))
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

	return true
end

puminTeleport:type("stepin")
puminTeleport:aid(50087)
puminTeleport:register()