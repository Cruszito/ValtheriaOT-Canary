local config = {
	-- Posición de la palanca o item que activa la ruleta
	leverPosition = Position(32373, 32236, 7),

	-- Posiciones donde van rolando los items
	slots = {
		Position(32374, 32233, 7),
		Position(32374, 32234, 7),
		Position(32374, 32235, 7),
		Position(32374, 32236, 7), -- Centro / item ganador
		Position(32374, 32237, 7),
		Position(32374, 32238, 7),
		Position(32374, 32239, 7),
	},

	centerSlot = 4,

	-- Costo por cada jugada
	costItemId = 58448, -- Endless Coin
	costAmount = 15,

	rolls = 45,

	rollSpeedStart = 50,
	rollSpeedEnd = 550,

	rewards = {
		{ itemId = 3043, count = 60, chance = 500 },
		{ itemId = 3043, count = 70, chance = 180 },
		{ itemId = 3043, count = 80, chance = 170 },
		{ itemId = 3043, count = 90, chance = 160 },
		{ itemId = 3043, count = 100, chance = 150 },
		{ itemId = 8154, count = 1, chance = 140 },
		{ itemId = 10294, count = 1, chance = 130 },

		-- Rune backpacks
		{ itemId = 55022, count = 1, chance = 40 }, -- Sudden Death Backpack
		{ itemId = 55023, count = 1, chance = 39 }, -- Avalanche Backpack
		{ itemId = 55024, count = 1, chance = 38 }, -- Paralize Backpack
		{ itemId = 55025, count = 1, chance = 37 }, -- Destroy Field Backpack
		{ itemId = 55026, count = 1, chance = 36 }, -- Wild Growth Backpack
		{ itemId = 55027, count = 1, chance = 35 }, -- Great Fireball Backpack
		{ itemId = 55028, count = 1, chance = 34 }, -- Fly Backpack

		-- Fantasy and anime backpacks
		{ itemId = 55245, count = 1, chance = 33 }, -- Green Fairy Backpack
		{ itemId = 55246, count = 1, chance = 32 }, -- Purple Night Backpack
		{ itemId = 55247, count = 1, chance = 31 }, -- Green Night Backpack
		{ itemId = 55248, count = 1, chance = 30 }, -- Bulma Backpack
		{ itemId = 55253, count = 1, chance = 29 }, -- Ghosting Backpack
		{ itemId = 55254, count = 1, chance = 28 }, -- Dragonball Backpack
		{ itemId = 55255, count = 1, chance = 27 }, -- Majin Boo Backpack
		{ itemId = 55256, count = 1, chance = 26 }, -- Shenlong Backpack
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

-- Crea visualmente el item con la cantidad configurada.
local function createItemOnSlot(itemId, count, pos)
	local createdItem = Game.createItem(itemId, count or 1, pos)

	if createdItem then
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

-- Muestra tanto el item como su cantidad.
local function renderCurrentSlots()
	clearSlots()

	for i = 1, #config.slots do
		local visualReward = currentVisualItems[i]

		if visualReward then
			createItemOnSlot(
				visualReward.itemId,
				visualReward.count,
				config.slots[i]
			)
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

local function finishRoulette(playerId, finalItemId, finalCount)
	local player = Player(playerId)

	renderFinalReward()

	if player then
		local itemName = ItemType(finalItemId):getName()
		local addedItem = player:addItem(finalItemId, finalCount)

		if addedItem then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"¡Ganaste "
					.. finalCount
					.. "x "
					.. itemName
					.. "!"
			)

			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		else
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"No fue posible entregar tu premio. Comunícate con un administrador."
			)

			player:getPosition():sendMagicEffect(CONST_ME_POFF)

			logger.error(
				"[Casino Roulette] No se pudo entregar el item ID {} x{} al jugador {}.",
				finalItemId,
				finalCount,
				player:getName()
			)
		end
	end

	rouletteBusy = false
end

local function getRollDelay(rollCount)
	local totalRolls = config.rolls
	local progress = (totalRolls - rollCount) / totalRolls

	-- Efecto de frenado progresivo
	local easedProgress = progress * progress

	local delay = config.rollSpeedStart
		+ ((config.rollSpeedEnd - config.rollSpeedStart) * easedProgress)

	return math.floor(delay)
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

		addEvent(
			finishRoulette,
			800,
			playerId,
			winningReward.itemId,
			winningReward.count
		)

		return true
	end

	shiftItems()
	renderCurrentSlots()

	-- Mientras menos vueltas falten, más efecto en el centro
	if rollCount <= 10 then
		config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_MAGIC_RED)
	elseif rollCount <= 20 then
		config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	end

	local nextDelay = getRollDelay(rollCount)

	addEvent(
		rollRoulette,
		nextDelay,
		playerId,
		rollCount - 1
	)

	return true
end

local casinoRoulette = Action()

function casinoRoulette.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if rouletteBusy then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"La ruleta ya está girando. Espera a que termine la jugada actual."
		)

		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Verifica que el jugador tenga las 15 Endless Coins.
	if player:getItemCount(config.costItemId) < config.costAmount then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Necesitas "
				.. config.costAmount
				.. " Endless Coins para jugar a la ruleta."
		)

		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Cobra las 15 Endless Coins antes de comenzar.
	if not player:removeItem(config.costItemId, config.costAmount) then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"No fue posible cobrar las "
				.. config.costAmount
				.. " Endless Coins. Inténtalo nuevamente."
		)

		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	rouletteBusy = true

	initializeVisualItems()
	renderCurrentSlots()

	player:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		"¡La ruleta comenzó a girar! Se cobraron "
			.. config.costAmount
			.. " Endless Coins."
	)

	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	rollRoulette(player:getId(), config.rolls)

	return true
end

casinoRoulette:position(config.leverPosition)
casinoRoulette:register()