local config = {
	monsterName = "Castle Protector",

	-- Cada cuánto revisará si falta algún Castle Protector
	checkInterval = 60 * 1000, -- 60 segundos

	positions = {
		Position(32238, 32201, 5),
		Position(32253, 32194, 5),
		Position(32240, 32217, 6),
		Position(32221, 32195, 6),
	}
}

local function hasCastleProtector(position)
	local tile = Tile(position)
	if not tile then
		return false
	end

	local creatures = tile:getCreatures()
	if not creatures then
		return false
	end

	for _, creature in ipairs(creatures) do
		if creature:isMonster() and creature:getName():lower() == config.monsterName:lower() then
			return true
		end
	end

	return false
end

local function spawnCastleProtectors()
	for _, position in ipairs(config.positions) do
		if not hasCastleProtector(position) then
			local monster = Game.createMonster(config.monsterName, position, true, true)

			if monster then
				position:sendMagicEffect(CONST_ME_TELEPORT)
			else
				print("[CastleProtectorSpawns] Could not create " .. config.monsterName .. " at position: " .. position.x .. ", " .. position.y .. ", " .. position.z)
			end
		end
	end
end

local castleProtectorStartup = GlobalEvent("CastleProtectorStartup")

function castleProtectorStartup.onStartup()
	spawnCastleProtectors()
	return true
end

castleProtectorStartup:register()

local castleProtectorThink = GlobalEvent("CastleProtectorThink")

function castleProtectorThink.onThink(interval)
	spawnCastleProtectors()
	return true
end

castleProtectorThink:interval(config.checkInterval)
castleProtectorThink:register()