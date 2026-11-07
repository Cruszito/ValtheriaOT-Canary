local config = {
	-- Posición de la palanca o item que activa la ruleta
	leverPosition = Position(32113, 32346, 7),

	-- Requisitos para jugar
	requiredLevel = 500,

	-- Si está en true, no permite jugar dentro de Protection Zone.
	-- Esto garantiza que el death item pueda matar mediante combate normal.
	blockProtectionZone = true,

	-- Storages persistentes de la jugada pendiente.
	-- IMPORTANTE: usa IDs que no estén ocupados por otro sistema.
	rouletteStateStorage = 91001, -- 1 = pendiente, 2 = aplicando muerte
	rouletteRewardStorage = 91002,
	rouletteCountStorage = 91003,
	rouletteOriginXStorage = 91004,
	rouletteOriginYStorage = 91005,
	rouletteOriginZStorage = 91006,

	-- Resultado de muerte
	deathItemId = 53636,
	deathChance = 75, -- 75% muerte / 35% premio

	-- Monstruo temporal que ejecutará la muerte.
	-- Debe existir en tu servidor.
	deathKillerMonster = "Grim Reaper",
	deathDamageMultiplier = 100,

	-- Posiciones donde giran los items
	slots = {
		Position(32108, 32345, 7),
		Position(32109, 32345, 7),
		Position(32110, 32345, 7),
		Position(32111, 32345, 7),
		Position(32112, 32345, 7),
		Position(32113, 32345, 7), -- CENTRO / ITEM GANADOR
		Position(32114, 32345, 7),
		Position(32115, 32345, 7),
		Position(32116, 32345, 7),
		Position(32117, 32345, 7),
		Position(32118, 32345, 7),
		Position(32119, 32345, 7),
	},

	centerSlot = 6,

	-- Costo por jugar
	cost = 50,
	currencyItemId = 58448,
	currencyName = "Endless Coin",

	-- Se cobra directamente del saldo bancario
	goldCost = 3000000,

	-- Configuración de la animación
	rolls = 45,
	rollSpeedStart = 20,
	rollSpeedEnd = 900,

	-- Premios posibles
	-- chance = peso real dentro del 50% destinado a premios.
	-- visualChance = frecuencia con la que aparece durante la animación.
	rewards = {
		-- DEATH ITEM
		{
			itemId = 53636,
			count = 1,
			isDeath = true,
			visualChance = 170,
		},

		-- ITEMS COMUNES
		{ itemId = 52332, count = 1, chance = 40, visualChance = 170 },
		{ itemId = 52333, count = 1, chance = 35, visualChance = 165 },
		{ itemId = 52334, count = 1, chance = 25, visualChance = 155 },
		{ itemId = 52335, count = 1, chance = 24, visualChance = 150 },
		{ itemId = 52336, count = 1, chance = 19, visualChance = 140 },
		{ itemId = 52337, count = 1, chance = 16, visualChance = 130 },
		{ itemId = 52338, count = 1, chance = 15, visualChance = 125 },

		-- ITEMS RAROS
		-- ITEMS RAROS
		{ itemId = 57196, count = 1, chance = 10, visualChance = 100 },
		{ itemId = 57195, count = 1, chance = 9, visualChance = 100 },
		{ itemId = 57194, count = 1, chance = 8, visualChance = 100 },
		{ itemId = 57197, count = 1, chance = 7, visualChance = 100 },
		{ itemId = 57198, count = 1, chance = 6, visualChance = 100 },

		-- ITEMS SUPERDIFÍCILES
		{ itemId = 57185, count = 1, chance = 5, visualChance = 120 },
		{ itemId = 57174, count = 1, chance = 1, visualChance = 100 },
		{ itemId = 57177, count = 1, chance = 1, visualChance = 100 },
		{ itemId = 57179, count = 1, chance = 1, visualChance = 100 },
		{ itemId = 57189, count = 1, chance = 1, visualChance = 100 },
		{ itemId = 57183, count = 1, chance = 1, visualChance = 100 },
		{ itemId = 57181, count = 1, chance = 1, visualChance = 100 },
		{ itemId = 57173, count = 1, chance = 1, visualChance = 100 },
		{ itemId = 57175, count = 1, chance = 1, visualChance = 100 },
		{ itemId = 57182, count = 1, chance = 1, visualChance = 100 },
		{ itemId = 57172, count = 1, chance = 1, visualChance = 100 },
		{ itemId = 57187, count = 1, chance = 1, visualChance = 100 },
		{ itemId = 57193, count = 1, chance = 1, visualChance = 100 },
		{ itemId = 57190, count = 1, chance = 1, visualChance = 100 },
	},
}

local EndlessBusy = false
local currentVisualItems = {}

local function hasPendingRoulette(player)
	return player:getStorageValue(config.rouletteStateStorage) > 0
end

local function savePendingRoulette(player, reward)
	local originPosition = player:getPosition()

	player:setStorageValue(config.rouletteStateStorage, 1)
	player:setStorageValue(config.rouletteRewardStorage, reward.itemId)
	player:setStorageValue(config.rouletteCountStorage, reward.count or 1)
	player:setStorageValue(config.rouletteOriginXStorage, originPosition.x)
	player:setStorageValue(config.rouletteOriginYStorage, originPosition.y)
	player:setStorageValue(config.rouletteOriginZStorage, originPosition.z)
end

local function clearPendingRoulette(player)
	player:setStorageValue(config.rouletteStateStorage, -1)
	player:setStorageValue(config.rouletteRewardStorage, -1)
	player:setStorageValue(config.rouletteCountStorage, -1)
	player:setStorageValue(config.rouletteOriginXStorage, -1)
	player:setStorageValue(config.rouletteOriginYStorage, -1)
	player:setStorageValue(config.rouletteOriginZStorage, -1)
end

local function getPendingOriginPosition(player)
	local x = player:getStorageValue(config.rouletteOriginXStorage)
	local y = player:getStorageValue(config.rouletteOriginYStorage)
	local z = player:getStorageValue(config.rouletteOriginZStorage)

	if x <= 0 or y <= 0 or z < 0 then
		return nil
	end

	return Position(x, y, z)
end

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
			for itemId in pairs(rewardItemIds) do
				local slotItem = tile:getItemById(itemId)

				while slotItem do
					slotItem:remove()
					slotItem = tile:getItemById(itemId)
				end
			end
		end
	end
end

local function createItemOnSlot(itemId, position)
	local createdItem = Game.createItem(itemId, 1, position)

	if createdItem then
		position:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	end
end

-- Sorteo ponderado utilizado solamente para la animación visual.
local function getWeightedRewardByField(fieldName)
	local totalChance = 0

	for _, reward in ipairs(config.rewards) do
		totalChance = totalChance + (reward[fieldName] or 1)
	end

	if totalChance <= 0 then
		return nil
	end

	local randomValue = math.random(1, totalChance)
	local currentChance = 0

	for _, reward in ipairs(config.rewards) do
		currentChance = currentChance + (reward[fieldName] or 1)

		if randomValue <= currentChance then
			return reward
		end
	end

	return nil
end

local function getDeathReward()
	for _, reward in ipairs(config.rewards) do
		if reward.isDeath or reward.itemId == config.deathItemId then
			return reward
		end
	end

	return nil
end

-- Selecciona un premio normal excluyendo el death item.
local function getWeightedItemReward()
	local totalChance = 0

	for _, reward in ipairs(config.rewards) do
		if not reward.isDeath and reward.itemId ~= config.deathItemId then
			totalChance = totalChance + (reward.chance or 1)
		end
	end

	if totalChance <= 0 then
		return nil
	end

	local randomValue = math.random(1, totalChance)
	local currentChance = 0

	for _, reward in ipairs(config.rewards) do
		if not reward.isDeath and reward.itemId ~= config.deathItemId then
			currentChance = currentChance + (reward.chance or 1)

			if randomValue <= currentChance then
				return reward
			end
		end
	end

	return nil
end

-- Primer sorteo: 50% muerte / 50% premio.
local function getWeightedReward()
	if math.random(1, 100) <= config.deathChance then
		return getDeathReward()
	end

	return getWeightedItemReward()
end

local function getRandomVisualReward()
	return getWeightedRewardByField("visualChance")
end

local function initializeVisualItems()
	currentVisualItems = {}

	for index = 1, #config.slots do
		currentVisualItems[index] = getRandomVisualReward()
	end
end

local function renderCurrentSlots()
	clearSlots()

	for index = 1, #config.slots do
		local visualReward = currentVisualItems[index]

		if visualReward then
			createItemOnSlot(visualReward.itemId, config.slots[index])
		end
	end
end

local function shiftItems()
	for index = #currentVisualItems, 2, -1 do
		currentVisualItems[index] = currentVisualItems[index - 1]
	end

	currentVisualItems[1] = getRandomVisualReward()
end

local function renderFinalReward()
	renderCurrentSlots()
	config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_FIREAREA)
end

local function removeTemporaryMonster(monsterId)
	local temporaryMonster = Monster(monsterId)

	if temporaryMonster then
		temporaryMonster:remove()
	end
end

local function executePendingDeath(player)
	local originPosition = getPendingOriginPosition(player)

	if not originPosition then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"The roulette could not recover your original position. The death result remains pending."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	-- Intenta regresar al jugador a la posición donde inició la ruleta.
	-- Si está ocupada, prueba las casillas adyacentes, siempre fuera de PZ.
	local deathCandidates = {
		originPosition,
		Position(originPosition.x + 1, originPosition.y, originPosition.z),
		Position(originPosition.x - 1, originPosition.y, originPosition.z),
		Position(originPosition.x, originPosition.y + 1, originPosition.z),
		Position(originPosition.x, originPosition.y - 1, originPosition.z),
		Position(originPosition.x + 1, originPosition.y + 1, originPosition.z),
		Position(originPosition.x - 1, originPosition.y + 1, originPosition.z),
		Position(originPosition.x + 1, originPosition.y - 1, originPosition.z),
		Position(originPosition.x - 1, originPosition.y - 1, originPosition.z),
	}

	local deathPosition = nil

	for _, candidatePosition in ipairs(deathCandidates) do
		local candidateTile = Tile(candidatePosition)

		if candidateTile
			and not candidateTile:hasFlag(TILESTATE_PROTECTIONZONE)
		then
			player:teleportTo(candidatePosition, true)

			local currentPosition = player:getPosition()
			if currentPosition.x == candidatePosition.x
				and currentPosition.y == candidatePosition.y
				and currentPosition.z == candidatePosition.z
			then
				deathPosition = currentPosition
				break
			end
		end
	end

	if not deathPosition then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"The roulette could not return you to a valid death position. The result remains pending."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	deathPosition:sendMagicEffect(CONST_ME_TELEPORT)

	local spawnPositions = {
		Position(deathPosition.x + 1, deathPosition.y, deathPosition.z),
		Position(deathPosition.x - 1, deathPosition.y, deathPosition.z),
		Position(deathPosition.x, deathPosition.y + 1, deathPosition.z),
		Position(deathPosition.x, deathPosition.y - 1, deathPosition.z),
		Position(deathPosition.x + 1, deathPosition.y + 1, deathPosition.z),
		Position(deathPosition.x - 1, deathPosition.y + 1, deathPosition.z),
		Position(deathPosition.x + 1, deathPosition.y - 1, deathPosition.z),
		Position(deathPosition.x - 1, deathPosition.y - 1, deathPosition.z),
	}

	local deathKiller = nil

	for _, spawnPosition in ipairs(spawnPositions) do
		deathKiller = Game.createMonster(
			config.deathKillerMonster,
			spawnPosition,
			true,
			true
		)

		if deathKiller then
			break
		end
	end

	if not deathKiller then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Could not create the death killer monster. The result remains pending."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	player:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		"The death item was selected. You have died!"
	)

	local deathKillerId = deathKiller:getId()
	local lethalDamage = math.max(
		player:getHealth() + 100000,
		player:getMaxHealth() * config.deathDamageMultiplier
	)

	-- Estado 2 permite que el logout producido por la muerte continúe.
	-- Si el servidor se apaga antes de terminar, seguirá pendiente al entrar.
	player:setStorageValue(config.rouletteStateStorage, 2)

	doTargetCombatHealth(
		deathKiller,
		player,
		COMBAT_DEATHDAMAGE,
		-lethalDamage,
		-lethalDamage,
		CONST_ME_MORTAREA
	)

	clearPendingRoulette(player)
	addEvent(removeTemporaryMonster, 100, deathKillerId)
	return true
end

local function resolvePendingRoulette(player)
	if not hasPendingRoulette(player) then
		return true
	end

	local finalItemId = player:getStorageValue(config.rouletteRewardStorage)
	local finalCount = math.max(
		1,
		player:getStorageValue(config.rouletteCountStorage)
	)

	if finalItemId <= 0 then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"The pending roulette result is invalid and was cleared."
		)
		clearPendingRoulette(player)
		return false
	end

	if finalItemId == config.deathItemId then
		return executePendingDeath(player)
	end

	local itemName = ItemType(finalItemId):getName()
	local rewardItem = player:addItem(finalItemId, finalCount)

	if rewardItem then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You won " .. finalCount .. "x " .. itemName .. "!"
		)
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	else
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You won "
				.. finalCount
				.. "x "
				.. itemName
				.. ", but you do not have enough capacity or space."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end

	clearPendingRoulette(player)
	return rewardItem ~= nil
end

local function finishEndless(playerId, finalItemId, finalCount)
	local player = Player(playerId)

	renderFinalReward()
	EndlessBusy = false

	-- El resultado permanece guardado en storages si el jugador está offline.
	-- Se resolverá automáticamente cuando vuelva a iniciar sesión.
	if not player then
		return
	end

	if not hasPendingRoulette(player) then
		return
	end

	local storedItemId = player:getStorageValue(config.rouletteRewardStorage)
	local storedCount = player:getStorageValue(config.rouletteCountStorage)

	if storedItemId ~= finalItemId or storedCount ~= finalCount then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"The roulette result could not be validated. It remains pending."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return
	end

	resolvePendingRoulette(player)
end

-- Frenado cúbico: rápido al inicio y muy lento al final.
local function getRollDelay(rollCount)
	local totalRolls = config.rolls
	local progress = (totalRolls - rollCount) / totalRolls
	local easedProgress = progress * progress * progress

	local delay = config.rollSpeedStart
		+ ((config.rollSpeedEnd - config.rollSpeedStart) * easedProgress)

	-- Agrega mayor tensión durante los últimos diez movimientos.
	if rollCount <= 10 then
		delay = delay + ((11 - rollCount) * 100)
	end

	return math.floor(delay)
end

local function rollEndless(playerId, rollCount, finalItemId, finalCount)
	if rollCount <= 0 then
		local centerReward = currentVisualItems[config.centerSlot]

		-- Si por cualquier desajuste visual el centro no coincide, se corrige
		-- con el resultado real que ya quedó guardado en los storages.
		if not centerReward or centerReward.itemId ~= finalItemId then
			currentVisualItems[config.centerSlot] = {
				itemId = finalItemId,
				count = finalCount,
			}
		end

		renderCurrentSlots()
		config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_FIREAREA)

		addEvent(
			finishEndless,
			800,
			playerId,
			finalItemId,
			finalCount
		)

		return true
	end

	shiftItems()

	-- Introduce el resultado real para que termine en el slot central.
	if rollCount == config.centerSlot then
		currentVisualItems[1] = {
			itemId = finalItemId,
			count = finalCount,
		}
	end

	renderCurrentSlots()

	if rollCount <= 10 then
		config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_MAGIC_RED)
	elseif rollCount <= 20 then
		config.slots[config.centerSlot]:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	end

	local nextDelay = getRollDelay(rollCount)

	addEvent(
		rollEndless,
		nextDelay,
		playerId,
		rollCount - 1,
		finalItemId,
		finalCount
	)

	return true
end

local casinoEndless = Action()

function casinoEndless.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	-- Nivel mínimo.
	if player:getLevel() < config.requiredLevel then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You need to be level " .. config.requiredLevel .. " or higher to play."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- No permite jugar dentro de Protection Zone.
	if config.blockProtectionZone then
		local playerTile = Tile(player:getPosition())

		if playerTile and playerTile:hasFlag(TILESTATE_PROTECTIONZONE) then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"You cannot play the roulette inside a protection zone."
			)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end
	end

	-- No permite iniciar otra jugada con un resultado pendiente.
	if hasPendingRoulette(player) then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You already have a pending roulette result."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Solo una jugada simultánea.
	if EndlessBusy then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"The Endless is already spinning. Please wait."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Verifica las Endless Coins.
	if config.cost > 0
		and player:getItemCount(config.currencyItemId) < config.cost
	then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You need "
				.. config.cost
				.. " "
				.. config.currencyName
				.. " to play."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Verifica el saldo bancario.
	local bankBalance = player:getBankBalance()

	if config.goldCost > 0 and bankBalance < config.goldCost then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You need "
				.. config.goldCost
				.. " gold coins in your bank balance to play."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Selecciona el resultado antes de cobrar.
	local finalReward = getWeightedReward()

	if not finalReward then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"The roulette could not select a reward."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Retira las Endless Coins.
	if config.cost > 0
		and not player:removeItem(config.currencyItemId, config.cost)
	then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Could not remove the required " .. config.currencyName .. "."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Retira los 5kk directamente del banco.
	if config.goldCost > 0 then
		player:setBankBalance(bankBalance - config.goldCost)
	end

	-- Guarda el resultado y la posición original antes de comenzar la animación.
	-- Aunque cierre el cliente o se reinicie el servidor, la jugada no se pierde.
	savePendingRoulette(player, finalReward)

	EndlessBusy = true

	initializeVisualItems()
	renderCurrentSlots()

	player:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		"The Endless starts spinning! You paid "
			.. config.cost
			.. " "
			.. config.currencyName
			.. " and "
			.. config.goldCost
			.. " gold coins."
	)

	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	rollEndless(
		player:getId(),
		config.rolls,
		finalReward.itemId,
		finalReward.count
	)

	return true
end

-- Bloquea el logout voluntario mientras la animación está pendiente.
-- Cerrar el cliente a la fuerza no elimina el resultado porque queda en storages.
local rouletteLogout = CreatureEvent("EndlessRouletteLogout")

function rouletteLogout.onLogout(player)
	if player:getStorageValue(config.rouletteStateStorage) == 1
		and player:getHealth() > 0
	then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You cannot logout while the roulette is spinning."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	return true
end

rouletteLogout:register()

-- Resuelve automáticamente una jugada que quedó pendiente por desconexión
-- o por un reinicio del servidor.
local rouletteLogin = CreatureEvent("EndlessRouletteLogin")

function rouletteLogin.onLogin(player)
	if not hasPendingRoulette(player) then
		return true
	end

	addEvent(function(playerId)
		local currentPlayer = Player(playerId)

		if not currentPlayer or not hasPendingRoulette(currentPlayer) then
			return
		end

		currentPlayer:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Your pending roulette result will now be applied."
		)

		resolvePendingRoulette(currentPlayer)
	end, 1500, player:getId())

	return true
end

rouletteLogin:register()

casinoEndless:position(config.leverPosition)
casinoEndless:register()