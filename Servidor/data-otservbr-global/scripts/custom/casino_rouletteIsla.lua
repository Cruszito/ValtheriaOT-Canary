local config = {
	-- Posición de la palanca o item que activa la ruleta
	leverPosition = Position(32164, 32308, 7), -- Palanca

	-- Posiciones donde van rolando los items
	slots = {
		Position(32158, 32310, 7),
		Position(32159, 32310, 7),
		Position(32160, 32310, 7),
		Position(32161, 32310, 7),
		Position(32162, 32310, 7),
		Position(32163, 32310, 7),
		Position(32164, 32310, 7), -- CENTRO / ITEM GANADOR
		Position(32165, 32310, 7),
		Position(32166, 32310, 7),
		Position(32167, 32310, 7),
		Position(32168, 32310, 7),
		Position(32169, 32310, 7),
		Position(32170, 32310, 7),
	},

	centerSlot = 7,

	-- Costo por jugar en Tibia Coins
	cost = 5,
	currencyItemId = 58448,
	currencyName = "Endless Coin",

	-- Configuración visual de la ruleta
	rolls = 45,

	-- Velocidad de la ruleta
	-- Empieza rápido y termina lento
	rollSpeedStart = 50,
	rollSpeedEnd = 550,

	-- Premios posibles
	-- chance más alto = más probable
	-- chance más bajo = más raro
	rewards = {
		{ itemId = 3043, count = 10, chance = 500 }, -- crystal coin
		{ itemId = 36723, count = 1, chance = 180 }, -- kooldown-aid
		{ itemId = 36724, count = 1, chance = 180 }, -- strike enhancement
		{ itemId = 36729, count = 1, chance = 180 }, -- fire resilience
		{ itemId = 36730, count = 1, chance = 180 }, -- ice resilience
		{ itemId = 36732, count = 1, chance = 180 }, -- energy resilience
		{ itemId = 36733, count = 1, chance = 180 }, -- holy resilience
		{ itemId = 36734, count = 1, chance = 180 }, -- death resilience
		{ itemId = 36735, count = 1, chance = 180 }, -- physical resilience
		{ itemId = 36736, count = 1, chance = 180 }, -- fire amplification
		{ itemId = 36737, count = 1, chance = 180 }, -- ice amplification
		{ itemId = 36738, count = 1, chance = 180 }, -- earth amplification
		{ itemId = 36739, count = 1, chance = 180 }, -- energy amplification
		{ itemId = 36740, count = 1, chance = 180 }, -- holy amplification
		{ itemId = 36741, count = 1, chance = 180 }, -- death amplification
		{ itemId = 36742, count = 1, chance = 180 }, -- physical amplification
		{ itemId = 3043, count = 8, chance = 180 }, -- crystal coin
		{ itemId = 3043, count = 12, chance = 180 }, -- crystal coin
		{ itemId = 28493, count = 1, chance = 180 }, -- bone fiddle
		{ itemId = 18339, count = 1, chance = 100 }, -- Zaoan chest box
		{ itemId = 8154, count = 1, chance = 30 }, -- Addon doll
		{ itemId = 10294, count = 1, chance = 30 }, -- Mount doll
		{ itemId = 3043, count = 20, chance = 150 }, -- crystal coin
		{ itemId = 9596, count = 1, chance = 40 }, -- squeezing gear of girlpower

		-- Rare rewards - Lion items
		{ itemId = 50185, count = 1, chance = 50 }, -- jade legs
		{ itemId = 50168, count = 1, chance = 50 }, -- nunchaku of destruction
		{ itemId = 50276, count = 1, chance = 50 }, -- gnomish cuirass
		{ itemId = 50190, count = 1, chance = 50 }, -- dark vision bandana
		{ itemId = 50270, count = 1, chance = 50 }, -- bambus jo
		{ itemId = 27650, count = 1, chance = 80 }, -- gnome shield
		{ itemId = 29423, count = 1, chance = 70 }, -- dream shroud
		{ itemId = 36727, count = 1, chance = 25 }, -- wealth duplex
		{ itemId = 13994, count = 1, chance = 35 }, -- Depth lorica


		-- Destructions weapons
		{ itemId = 37110, count = 1, chance = 80 }, -- Exalted core
		{ itemId = 27449, count = 1, chance = 35 }, -- blade of destruction
		{ itemId = 27450, count = 1, chance = 35 }, -- slayer of destruction
		{ itemId = 27451, count = 1, chance = 35 }, -- axe of destruction
		{ itemId = 27452, count = 1, chance = 35 }, -- chopper of destruction
		{ itemId = 27453, count = 1, chance = 35 }, -- mace of destruction
		{ itemId = 27454, count = 1, chance = 35 }, -- hammer of destruction
		{ itemId = 27455, count = 1, chance = 35 }, -- bow of destruction
		{ itemId = 27456, count = 1, chance = 35 }, -- crossbow of destruction
		{ itemId = 27457, count = 1, chance = 35 }, -- wand of destruction
		{ itemId = 27458, count = 1, chance = 35 }, -- rod of destruction

		-- Ultra rare rewards
		{ itemId = 39546, count = 1, chance = 8 }, -- primal bag
	},
}

local rouletteBusy = false
local currentVisualItems = {}

local function getRewardItemIds()
	local ids = {}

	for _, reward in ipairs(config.rewards) do
		ids[reward.itemId] = true
	end

	return ids
end

local rewardItemIds = getRewardItemIds()

local function clearSlots()
	for _, pos in ipairs(config.slots) do
		local tile = Tile(pos)

		if tile then
			for itemId, _ in pairs(rewardItemIds) do
				local item = tile:getItemById(itemId)

				while item do
					item:remove()
					item = tile:getItemById(itemId)
				end
			end
		end
	end
end

local function createItemOnSlot(itemId, pos)
	local item = Game.createItem(itemId, 1, pos)

	if item then
		pos:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	end
end

local function getWeightedReward()
	local totalChance = 0

	for _, reward in ipairs(config.rewards) do
		totalChance = totalChance + reward.chance
	end

	local randomValue = math.random(1, totalChance)
	local currentChance = 0

	for _, reward in ipairs(config.rewards) do
		currentChance = currentChance + reward.chance

		if randomValue <= currentChance then
			return reward
		end
	end

	return config.rewards[1]
end

local function getRandomVisualReward()
	return getWeightedReward()
end

local function initializeVisualItems()
	currentVisualItems = {}

	for i = 1, #config.slots do
		currentVisualItems[i] = getRandomVisualReward()
	end
end

local function renderCurrentSlots()
	clearSlots()

	for i = 1, #config.slots do
		if currentVisualItems[i] then
			createItemOnSlot(currentVisualItems[i].itemId, config.slots[i])
		end
	end
end

local function shiftItems()
	for i = #currentVisualItems, 2, -1 do
		currentVisualItems[i] = currentVisualItems[i - 1]
	end

	currentVisualItems[1] = getRandomVisualReward()
end

local function renderFinalReward()
	renderCurrentSlots()
	config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_FIREAREA)
end

local function getRollDelay(rollCount)
	local totalRolls = config.rolls
	local progress = (totalRolls - rollCount) / totalRolls
	local easedProgress = progress * progress
	local delay = config.rollSpeedStart + ((config.rollSpeedEnd - config.rollSpeedStart) * easedProgress)

	return math.floor(delay)
end

local function finishRoulette(playerId, finalItemId, finalCount)
	local player = Player(playerId)

	renderFinalReward()

	if player then
		local itemName = ItemType(finalItemId):getName()

		player:addItem(finalItemId, finalCount)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You won " .. finalCount .. "x " .. itemName .. "!")
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end

	rouletteBusy = false
end

local function rollRoulette(playerId, rollCount)
	if rollCount <= 0 then
		local winningReward = currentVisualItems[config.centerSlot]

		if not winningReward then
			rouletteBusy = false
			return true
		end

		renderCurrentSlots()
		config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_FIREAREA)

		addEvent(finishRoulette, 800, playerId, winningReward.itemId, winningReward.count)
		return true
	end

	shiftItems()
	renderCurrentSlots()

	if rollCount <= 10 then
		config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_MAGIC_RED)
	elseif rollCount <= 20 then
		config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	end

	local nextDelay = getRollDelay(rollCount)

	addEvent(rollRoulette, nextDelay, playerId, rollCount - 1)
	return true
end

local casinoRoulette = Action()

function casinoRoulette.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if rouletteBusy then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The roulette is already spinning. Please wait.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if config.cost > 0 then
		if player:getItemCount(config.currencyItemId) < config.cost then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"You need " .. config.cost .. " " .. config.currencyName .. " to play."
			)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end

		if not player:removeItem(config.currencyItemId, config.cost) then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Could not remove the required " .. config.currencyName .. ".")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end
	end

	rouletteBusy = true

	initializeVisualItems()
	renderCurrentSlots()

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The roulette starts spinning!")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	rollRoulette(player:getId(), config.rolls)

	return true
end

casinoRoulette:position(config.leverPosition)
casinoRoulette:register()