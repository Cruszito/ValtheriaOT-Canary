local config = {
	-- Posición de la palanca o item que activa la ruleta
	leverPosition = Position(32101, 32302, 7), -- Palanca

	-- Posiciones donde van rolando los items
	slots = {
		Position(32098, 32301, 7),
		Position(32099, 32301, 7),
		Position(32100, 32301, 7),
		Position(32101, 32301, 7),-- CENTRO / ITEM GANADOR
		Position(32102, 32301, 7),
		Position(32103, 32301, 7), 
		Position(32104, 32301, 7),
	},

	centerSlot = 4,

	-- Costo por jugar
	cost = 50,
	currencyItemId = 58448,
	currencyName = "Endless Coin",

	rolls = 45,

	-- Velocidad de la ruleta
	-- Empieza rápido y termina lento
	rollSpeedStart = 50,
	rollSpeedEnd = 400,

	-- Premios posibles
	-- chance = probabilidad REAL de ganar
	-- visualChance = probabilidad de que se vea girando
	rewards = {
		-- Comunes / premio de recuperación
		{ itemId = 58448, count = 20, chance = 650, visualChance = 80 }, -- Endless coins / refund
		{ itemId = 58448, count = 25, chance = 600, visualChance = 80 }, -- Endless coins / refund
		{ itemId = 58448, count = 15, chance = 550, visualChance = 80 }, -- Endless coins / refund
		{ itemId = 3043, count = 20, chance = 500, visualChance = 70 }, -- crystal coin
		{ itemId = 3043, count = 15, chance = 400, visualChance = 70 }, -- crystal coin
		{ itemId = 58448, count = 150, chance = 150, visualChance = 45 }, -- Endless coins / big refund

		-- Comunes especiales
		{ itemId = 37110, count = 1, chance = 110, visualChance = 200 }, -- exalted core.
		{ itemId = 8154, count = 1, chance = 90, visualChance = 190 }, -- addon doll
		{ itemId = 10294, count = 1, chance = 80, visualChance = 180 }, -- mount doll
		{ itemId = 55368, count = 1, chance = 75, visualChance = 175 }, -- prey wildcardx20


		-- Boxes difíciles
		{ itemId = 55364, count = 1, chance = 40, visualChance = 170 }, -- Lion Box
		{ itemId = 55171, count = 1, chance = 35, visualChance = 165 }, -- Cobra Box
		{ itemId = 55388, count = 1, chance = 25, visualChance = 155 }, -- Falcon Box
		{ itemId = 55737, count = 1, chance = 24, visualChance = 150 }, -- Stag Box

		-- Boxes muy difíciles
		{ itemId = 55894, count = 1, chance = 19, visualChance = 140 }, -- Primal Box


	},
}

local EndlessBusy = false
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
	Game.createItem(itemId, 1, pos)
	pos:sendMagicEffect(CONST_ME_MAGIC_BLUE)
end

local function getWeightedRewardByField(fieldName)
	local totalChance = 0

	for _, reward in ipairs(config.rewards) do
		totalChance = totalChance + (reward[fieldName] or reward.chance or 1)
	end

	local randomValue = math.random(1, totalChance)
	local currentChance = 0

	for _, reward in ipairs(config.rewards) do
		currentChance = currentChance + (reward[fieldName] or reward.chance or 1)

		if randomValue <= currentChance then
			return reward
		end
	end

	return config.rewards[1]
end

-- Probabilidad REAL del premio.
local function getWeightedReward()
	return getWeightedRewardByField("chance")
end

-- Probabilidad VISUAL de lo que se ve girando.
local function getRandomVisualReward()
	return getWeightedRewardByField("visualChance")
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

local function finishEndless(playerId, finalItemId, finalCount)
	local player = Player(playerId)

	renderFinalReward()

	if player then
		local itemName = ItemType(finalItemId):getName()
		local rewardItem = player:addItem(finalItemId, finalCount)

		if rewardItem then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You won " .. finalCount .. "x " .. itemName .. "!")
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		else
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You won " .. finalCount .. "x " .. itemName .. ", but you do not have enough capacity or space.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	end

	EndlessBusy = false
end

local function getRollDelay(rollCount)
	local totalRolls = config.rolls
	local progress = (totalRolls - rollCount) / totalRolls

	-- Efecto de frenado progresivo
	local easedProgress = progress * progress

	local delay = config.rollSpeedStart + ((config.rollSpeedEnd - config.rollSpeedStart) * easedProgress)

	return math.floor(delay)
end

local function rollEndless(playerId, rollCount, finalItemId, finalCount)
	if rollCount <= 0 then
		local centerReward = currentVisualItems[config.centerSlot]

		if not centerReward or centerReward.itemId ~= finalItemId then
			EndlessBusy = false
			return true
		end

		renderCurrentSlots()
		config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_FIREAREA)

		addEvent(finishEndless, 800, playerId, finalItemId, finalCount)
		return true
	end

	shiftItems()

	-- Aquí metemos el premio REAL en la cinta visual.
	-- Con centerSlot = 6, entra 6 movimientos antes y se ve avanzar hasta el centro.
	if rollCount == config.centerSlot then
		currentVisualItems[1] = {
			itemId = finalItemId,
			count = finalCount
		}
	end

	renderCurrentSlots()

	if rollCount <= 10 then
		config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_MAGIC_RED)
	elseif rollCount <= 20 then
		config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	end

	local nextDelay = getRollDelay(rollCount)

	addEvent(rollEndless, nextDelay, playerId, rollCount - 1, finalItemId, finalCount)
	return true
end

local casinoEndless = Action()

function casinoEndless.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if EndlessBusy then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The Endless is already spinning. Please wait.")
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

	EndlessBusy = true

	-- Premio REAL. Este usa "chance", no "visualChance".
	local finalReward = getWeightedReward()

	initializeVisualItems()
	renderCurrentSlots()

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The Endless starts spinning!")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	rollEndless(player:getId(), config.rolls, finalReward.itemId, finalReward.count)

	return true
end

casinoEndless:position(config.leverPosition)
casinoEndless:register()