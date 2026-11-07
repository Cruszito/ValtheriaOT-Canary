local CHRISTMAS_TOKEN_ID = 6526

local function removeChristmasTokens(lootTable)
	local removedCount = 0

	-- El loot generado por Canary utiliza el ID del objeto como índice.
	local tokenLoot = lootTable[CHRISTMAS_TOKEN_ID]
	if tokenLoot then
		removedCount = removedCount + (tokenLoot.count or 0)
		lootTable[CHRISTMAS_TOKEN_ID] = nil
	end

	-- También elimina tokens que puedan estar dentro de contenedores.
	for _, lootItem in pairs(lootTable) do
		if lootItem.childLoot then
			removedCount = removedCount + removeChristmasTokens(lootItem.childLoot)
		end
	end

	return removedCount
end

local callback = EventCallback("MonsterOnDropLootBaseEvent")

function callback.monsterOnDropLoot(monster, corpse)
	local player = Player(corpse:getCorpseOwner())
	local factor = 1.0
	local msgSuffix = ""

	if player and player:canReceiveLoot() then
		local config = player:calculateLootFactor(monster)
		factor = config.factor
		msgSuffix = config.msgSuffix
	end

	local mType = monster:getType()
	if not mType then
		logger.warn(
			"monsterOnDropLoot: monster '{}' has no type",
			monster:getName()
		)
		return
	end

	local mTypeCharm = player and player:getCharmMonsterType(CHARM_GUT)
	local gut = mTypeCharm and mTypeCharm:raceId() == mType:raceId()

	local lootTable = mType:generateLootRoll(
		{
			factor = factor,
			gut = gut,
		},
		{},
		player
	)

	-- Impide que cualquier monstruo entregue Christmas Tokens.
	-- Se realiza silenciosamente, sin llenar la consola de warnings.
	removeChristmasTokens(lootTable)

	corpse:addLoot(lootTable)

	local charmMessage = false
	local existingSuffix = corpse:getAttribute(
		ITEM_ATTRIBUTE_LOOTMESSAGE_SUFFIX
	) or ""

	for _, item in pairs(lootTable) do
		if item.gut and not charmMessage then
			charmMessage = true
			msgSuffix = msgSuffix
				.. (string.len(msgSuffix) > 0 and ", gut charm" or "gut charm")
		end
	end

	corpse:setAttribute(
		ITEM_ATTRIBUTE_LOOTMESSAGE_SUFFIX,
		existingSuffix .. msgSuffix
	)
end

callback:register()