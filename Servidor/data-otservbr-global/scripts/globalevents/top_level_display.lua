local config = {
	displays = {
		[1] = {
			position = Position(32375, 32209, 7),
		},
		[2] = {
			position = Position(32374, 32209, 7),
		},
		[3] = {
			position = Position(32376, 32209, 7),
		},
	},

	direction = DIRECTION_SOUTH,
	refreshInterval = 60 * 60 * 1000, -- 1 hora
}

local registeredNpcTypes = {}

local function removeOldDisplays()
	for _, display in pairs(config.displays) do
		local tile = Tile(display.position)
		if tile then
			local creatures = tile:getCreatures()
			if creatures then
				for _, creature in ipairs(creatures) do
					if creature and creature:isNpc() then
						creature:remove()
					end
				end
			end
		end
	end
end

local function registerTopNpcType(playerData)
	if registeredNpcTypes[playerData.name] then
		return
	end

	local npcType = Game.createNpcType(playerData.name)
	local npcConfig = {}

	npcConfig.name = playerData.name
	npcConfig.description = playerData.name

	npcConfig.health = 100
	npcConfig.maxHealth = 100
	npcConfig.walkInterval = 0
	npcConfig.walkRadius = 0

	npcConfig.outfit = playerData.outfit

	npcConfig.flags = {
		floorchange = false,
	}

	npcType:register(npcConfig)
	registeredNpcTypes[playerData.name] = true
end

local function getTopPlayer(rank)
	local offset = rank - 1

	local query = string.format([[
		SELECT name, level, looktype, lookhead, lookbody, looklegs, lookfeet, lookaddons
		FROM players
		WHERE deletion = 0
		ORDER BY level DESC, experience DESC
		LIMIT 1 OFFSET %d
	]], offset)

	local resultId = db.storeQuery(query)
	if not resultId then
		return nil
	end

	local playerData = {
		name = result.getString(resultId, "name"),
		level = result.getNumber(resultId, "level"),
		outfit = {
			lookType = result.getNumber(resultId, "looktype"),
			lookHead = result.getNumber(resultId, "lookhead"),
			lookBody = result.getNumber(resultId, "lookbody"),
			lookLegs = result.getNumber(resultId, "looklegs"),
			lookFeet = result.getNumber(resultId, "lookfeet"),
			lookAddons = result.getNumber(resultId, "lookaddons"),
		},
	}

	result.free(resultId)
	return playerData
end

local function updateTopLevelDisplay()
	removeOldDisplays()

	local shownPlayers = 0

	for rank = 1, #config.displays do
		local display = config.displays[rank]
		local playerData = getTopPlayer(rank)

		if not playerData then
			logger.warn("[TopLevelDisplay] No se encontro player para Top {}.", rank)
		else
			registerTopNpcType(playerData)

			local npc = Game.createNpc(playerData.name, display.position, false, true)
			if npc then
				npc:setOutfit(playerData.outfit)
				npc:setDirection(config.direction)

				shownPlayers = shownPlayers + 1

				logger.info(
					"[TopLevelDisplay] Top {} creado correctamente: {} level {}.",
					rank,
					playerData.name,
					playerData.level
				)

				addEvent(function(npcId, topRank, name, level)
					local creature = Creature(npcId)
					if creature then
						creature:say(string.format("Top %d: %s [Lv. %d]", topRank, name, level), TALKTYPE_MONSTER_SAY)
					end
				end, 1500, npc:getId(), rank, playerData.name, playerData.level)
			else
				logger.warn(
					"[TopLevelDisplay] No se pudo crear NPC para Top {}: {} en {}, {}, {}.",
					rank,
					playerData.name,
					display.position.x,
					display.position.y,
					display.position.z
				)
			end
		end
	end

	if shownPlayers < 3 then
		logger.warn("[TopLevelDisplay] Solo se mostraron {} players.", shownPlayers)
	end

	return true
end

local topLevelStartup = GlobalEvent("TopLevelDisplayStartup")

function topLevelStartup.onStartup()
	updateTopLevelDisplay()
	return true
end

topLevelStartup:register()

local topLevelRefresh = GlobalEvent("TopLevelDisplayRefresh")

function topLevelRefresh.onThink(interval)
	updateTopLevelDisplay()
	return true
end

topLevelRefresh:interval(config.refreshInterval)
topLevelRefresh:register()