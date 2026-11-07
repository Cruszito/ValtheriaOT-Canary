local internalNpcName = "Santa Claus"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 160,
	lookHead = 0,
	lookBody = 112,
	lookLegs = 93,
	lookFeet = 95,
}

npcConfig.flags = {
	floorchange = false,
	profession = "trader",
}

npcConfig.speechBubble = SPEECHBUBBLE_TRADE

local CHRISTMAS_TOKEN_ID = 6526
local MINIMUM_PRESENT_LEVEL = 200
local K = 1000
local KK = 1000000

-- El Christmas Token es la moneda de la tienda.
npcConfig.currency = CHRISTMAS_TOKEN_ID

-- Obtiene automáticamente el nombre cargado en items.xml.
-- Si un objeto personalizado no tiene nombre, muestra su ID como respaldo.
local function createShopItem(itemId, tokenPrice)
	local itemType = ItemType(itemId)
	local itemName = "item " .. itemId

	if itemType then
		local loadedName = itemType:getName()
		if loadedName and loadedName ~= "" then
			itemName = loadedName
		end
	end

	return {
		itemName = itemName,
		clientId = itemId,
		buy = tokenPrice,
	}
end

-- Objetos vendidos por Christmas Tokens.
local itemsTable = {
	["christmas items"] = {
		createShopItem(3423, 10 * KK),
		createShopItem(3011, 8 * KK),
		createShopItem(37060, 2 * KK),
		createShopItem(39757, 2 * KK),
		createShopItem(21963, 2 * KK),
		createShopItem(20342, 2 * KK),
		createShopItem(8154, 50 * K),
		createShopItem(10294, 75 * K),
		createShopItem(55145, 15 * K),
		createShopItem(30003, 8 * K),
		createShopItem(9596, 5 * K),
		createShopItem(36725, 10 * K),
		createShopItem(52785, 100 * K),
	},
}

npcConfig.shop = {}
for _, categoryTable in pairs(itemsTable) do
	for _, itemTable in ipairs(categoryTable) do
		table.insert(npcConfig.shop, itemTable)
	end
end

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

-- Regalos normales: 70%.
local normalItems = {
	{ itemId = 58448, count = 100 },
	{ itemId = 30003, count = 1 },
	{ itemId = 10294, count = 1 },
	{ itemId = 8154, count = 1 },
	{ itemId = 6567, count = 1 },
	{ itemId = 25062, count = 1 },
}

-- Regalos semi raros: 20%.
local semiRareItems = {
	{ itemId = 52785, count = 1 },
	{ itemId = 30006, count = 1 },
	{ itemId = 30363, count = 1 },
	{ itemId = 30362, count = 1 },
	{ itemId = 30364, count = 1 },
	{ itemId = 30365, count = 1 },
	{ itemId = 30366, count = 1 },
	{ itemId = 30367, count = 1 },
	{ itemId = 7252, count = 1 },
}

-- Regalos raros: 9%.
local rareItems = {
	{ itemId = 12571, count = 1 },
	{ itemId = 14764, count = 1 },
	{ itemId = 21947, count = 1 },
	{ itemId = 22120, count = 1 },
	{ itemId = 27846, count = 1 },
	{ itemId = 33331, count = 1 },
	{ itemId = 33334, count = 1 },
	{ itemId = 31674, count = 1 },
	{ itemId = 32076, count = 1 },
	{ itemId = 32077, count = 1 },
	{ itemId = 32075, count = 1 },
	{ itemId = 32074, count = 1 },
	{ itemId = 18343, count = 1 },
	{ itemId = 27591, count = 1 },
}

-- Regalos muy raros: 1%.
local veryRareItems = {
	{ itemId = 4100, count = 1 },
	{ itemId = 21963, count = 1 },
	{ itemId = 12905, count = 1 },
	{ itemId = 3011, count = 1 },
	{ itemId = 3365, count = 1 },
	{ itemId = 3368, count = 1 },
	{ itemId = 3423, count = 1 },
	{ itemId = 3402, count = 1 },
	{ itemId = 3570, count = 1 },
	{ itemId = 32100, count = 1 },
	{ itemId = 23683, count = 1 },
	{ itemId = 16275, count = 1 },
}

-- Normal: 70%, semi raro: 20%, raro: 9%, muy raro: 1%.
local function getReward()
	local random = math.random(100)
	local rewardTable

	if random <= 1 then
		rewardTable = veryRareItems
	elseif random <= 10 then
		rewardTable = rareItems
	elseif random <= 30 then
		rewardTable = semiRareItems
	else
		rewardTable = normalItems
	end

	return rewardTable[math.random(#rewardTable)]
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	if not player then
		return false
	end

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local lowerMessage = message:lower()
	local categoryTable = itemsTable[lowerMessage]

	if MsgContains(message, "present") then
		if player:getLevel() < MINIMUM_PRESENT_LEVEL then
			npcHandler:say(
				"You need to be at least level " .. MINIMUM_PRESENT_LEVEL .. " to receive a present.",
				npc,
				creature
			)
			return true
		end

		if player:getStorageValue(840293) == 1 then
			npcHandler:say("You can't get another present.", npc, creature)
			return true
		end

		local reward = getReward()
		local present = player:addItem(6510, 1)

		if not present then
			npcHandler:say("You don't have enough room for your present.", npc, creature)
			return true
		end

		local container = Container(present:getUniqueId())
		if not container then
			present:remove()
			npcHandler:say("I couldn't prepare your present. Please try again.", npc, creature)
			return true
		end

		local addedReward = container:addItem(reward.itemId, reward.count)
		if not addedReward then
			present:remove()
			npcHandler:say("I couldn't prepare your present. Please try again.", npc, creature)
			return true
		end

		player:setStorageValue(840293, 1)
		npcHandler:say("Merry Christmas!", npc, creature)
	elseif categoryTable then
		local remainingCategories = npc:getRemainingShopCategories(lowerMessage, itemsTable)
		npcHandler:say(
			"Of course! All prices are in Christmas Tokens. You can also look at "
				.. remainingCategories
				.. ".",
			npc,
			creature
		)

		npc:openShopWindowTable(player, categoryTable)
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:setMessage(
	MESSAGE_GREET,
	"Ho ho ho, |PLAYERNAME|! Players level 200 or higher can say {present}. Say {trade} to exchange Christmas Tokens for prizes."
)

npcHandler:setMessage(
	MESSAGE_SENDTRADE,
	"Of course! All prices are in Christmas Tokens. You can also look only at "
		.. GetFormattedShopCategoryNames(itemsTable)
		.. "."
)

npcHandler:setMessage(MESSAGE_FAREWELL, "Merry Christmas, |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Merry Christmas!")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- Compra objetos usando Christmas Tokens.
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end

npcType.onCheckItem = function(npc, player, clientId, subType)
end

npcType:register(npcConfig)