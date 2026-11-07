local config = {
	actionId = 60056,
	modalId = 90002,
	eventName = "WelcomeChestWeaponSelection",

	tibiaCoins = 250,
	trainingWeaponCharges = 64400,

	rewards = {
		{ id = 58448, count = 150 }, -- Endless Coins
		{ id = 10294, count = 1 },   -- Random Mount
		{ id = 8154, count = 1 },    -- Addon Doll
	},

	trainingWeapons = {
		{ id = 58450, name = "Prolonged Exercise Axe" },
		{ id = 58451, name = "Prolonged Exercise Bow" },
		{ id = 58452, name = "Prolonged Exercise Club" },
		{ id = 58453, name = "Prolonged Exercise Rod" },
		{ id = 58454, name = "Prolonged Exercise Sword" },
		{ id = 58455, name = "Prolonged Exercise Wand" },
		{ id = 58456, name = "Prolonged Exercise Wraps" },
	},

	alreadyClaimedMessage =
		"Esta direccion IP ya reclamo la recompensa de bienvenida. "
		.. "Solo se permite una entrega por IP, sin importar el personaje o la cuenta.",
}

local BUTTON_CONFIRM = 100
local BUTTON_CANCEL = 101

-- Solo permite confirmar ventanas abiertas mediante este cofre.
local pendingSelections = {}

local function notifyError(player, message)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
	player:getPosition():sendMagicEffect(CONST_ME_POFF)
end

local function hasIpClaimed(playerIp)
	local query = db.storeQuery(
		"SELECT `ip` FROM `ip_welcome_rewards` WHERE `ip` = "
		.. playerIp
		.. " LIMIT 1"
	)

	if query then
		result.free(query)
		return true
	end

	return false
end

-- Registra la IP para TODO el paquete de bienvenida.
local function markIpAsClaimed(playerIp)
	return db.query(
		"INSERT INTO `ip_welcome_rewards` (`ip`) VALUES ("
		.. playerIp
		.. ")"
	)
end

local function getEligibleIp(player)
	local playerIp = player:getIp()

	if not playerIp or playerIp == 0 then
		notifyError(
			player,
			"No fue posible validar tu direccion IP. "
			.. "Vuelve a conectarte e intentalo nuevamente."
		)
		return nil
	end

	if hasIpClaimed(playerIp) then
		notifyError(player, config.alreadyClaimedMessage)
		return nil
	end

	return playerIp
end

local function isValidItem(itemId)
	local itemType = ItemType(itemId)
	return itemType and itemType:getId() ~= 0
end

local function validateRewards(player)
	for _, reward in ipairs(config.rewards) do
		if not isValidItem(reward.id) then
			notifyError(
				player,
				"Una recompensa no esta configurada correctamente. "
				.. "Comunicate con un administrador."
			)

			logger.error(
				"[Welcome Chest] ID de recompensa no valido: {}.",
				reward.id
			)
			return false
		end
	end

	for _, weapon in ipairs(config.trainingWeapons) do
		if not isValidItem(weapon.id) then
			notifyError(
				player,
				"Un arma de entrenamiento no esta configurada correctamente. "
				.. "Comunicate con un administrador."
			)

			logger.error(
				"[Welcome Chest] ID de arma no valido: {}.",
				weapon.id
			)
			return false
		end
	end

	return true
end

local function sendWeaponSelection(player, playerIp)
	local modal = ModalWindow(
		config.modalId,
		"Selecciona tu arma de entrenamiento",
		"Solo puedes reclamar una recompensa de bienvenida por IP. "
		.. "Elige una sola arma. Esta eleccion es definitiva."
	)

	for choiceId, weapon in ipairs(config.trainingWeapons) do
		modal:addChoice(choiceId, weapon.name)
	end

	modal:addButton(BUTTON_CONFIRM, "Seleccionar")
	modal:addButton(BUTTON_CANCEL, "Cancelar")
	modal:setDefaultEnterButton(BUTTON_CONFIRM)
	modal:setDefaultEscapeButton(BUTTON_CANCEL)

	pendingSelections[player:getId()] = {
		guid = player:getGuid(),
		ip = playerIp,
	}

	player:registerEvent(config.eventName)
	modal:sendToPlayer(player)
end

local weaponSelection = CreatureEvent(config.eventName)

function weaponSelection.onModalWindow(
	player, modalWindowId, buttonId, choiceId
)
	if modalWindowId ~= config.modalId then
		return true
	end

	local pending = pendingSelections[player:getId()]
	pendingSelections[player:getId()] = nil
	player:unregisterEvent(config.eventName)

	if not pending or pending.guid ~= player:getGuid() then
		return true
	end

	if buttonId ~= BUTTON_CONFIRM then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Cancelaste la seleccion. No se entrego ninguna recompensa. "
			.. "Puedes utilizar el cofre nuevamente."
		)
		return true
	end

	local selectedWeapon = config.trainingWeapons[choiceId]

	if not selectedWeapon then
		notifyError(
			player,
			"La seleccion no es valida. Utiliza nuevamente el cofre."
		)
		return true
	end

	-- Revisa otra vez la IP al confirmar.
	-- Otro personaje pudo reclamar mientras la ventana estaba abierta.
	local playerIp = getEligibleIp(player)
	if not playerIp then
		return true
	end

	if pending.ip ~= playerIp then
		notifyError(
			player,
			"Tu direccion IP cambio. Utiliza nuevamente el cofre."
		)
		return true
	end

	if not validateRewards(player) then
		return true
	end

	-- Reserva el reclamo antes de entregar cualquier recompensa.
	if not markIpAsClaimed(playerIp) then
		notifyError(
			player,
			"No fue posible registrar el reclamo. "
			.. "La IP puede haber reclamado ya o existir un error de base de datos. "
			.. "No se entrego ninguna recompensa."
		)

		logger.error(
			"[Welcome Chest] No se pudo registrar la IP {} del jugador {}.",
			playerIp,
			player:getName()
		)
		return true
	end

	local itemDeliveryFailed = false

	for _, reward in ipairs(config.rewards) do
		local addedItem = player:addItem(reward.id, reward.count)

		if not addedItem then
			itemDeliveryFailed = true

			logger.error(
				"[Welcome Chest] Entrega incompleta. IP {}, jugador {}, objeto {} x{}.",
				playerIp,
				player:getName(),
				reward.id,
				reward.count
			)
		end
	end

	local addedWeapon = player:addItem(selectedWeapon.id, 1)

	if addedWeapon then
		addedWeapon:setAttribute(
			ITEM_ATTRIBUTE_CHARGES,
			config.trainingWeaponCharges
		)
	else
		itemDeliveryFailed = true

		logger.error(
			"[Welcome Chest] Entrega incompleta. IP {}, jugador {}, arma {}.",
			playerIp,
			player:getName(),
			selectedWeapon.id
		)
	end

	player:addTransferableCoins(config.tibiaCoins)

	if itemDeliveryFailed then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Tu recompensa fue registrada, pero hubo un problema "
			.. "al entregar uno o mas objetos. Comunicate con un administrador. "
			.. "No vuelvas a reclamar: la IP ya quedo registrada."
		)
	else
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Bienvenido. Recibiste 150 Endless Coins, un Random Mount, "
			.. "un Addon Doll y el arma "
			.. selectedWeapon.name
			.. " con "
			.. config.trainingWeaponCharges
			.. " cargas. Tambien recibiste "
			.. config.tibiaCoins
			.. " Tibia Coins. Esta IP ya reclamo su recompensa de bienvenida."
		)

		player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
	end

	logger.warn(
		"[Welcome Chest] Reclamo registrado. IP {}, jugador {}, arma {}.",
		playerIp,
		player:getName(),
		selectedWeapon.id
	)

	return true
end

weaponSelection:register()

local welcomeChest = Action()

function welcomeChest.onUse(
	player, item, fromPosition, target, toPosition, isHotkey
)
	local playerIp = getEligibleIp(player)
	if not playerIp then
		return true
	end

	if not validateRewards(player) then
		return true
	end

	sendWeaponSelection(player, playerIp)
	return true
end

welcomeChest:aid(config.actionId)
welcomeChest:register()