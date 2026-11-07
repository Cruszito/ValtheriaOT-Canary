local config = {
	level = 150,

	-- Debe ser un storage que no esté utilizado por otro script.
	storage = 950150,

	rewards = {
		[VOCATION.ID.SORCERER] = {
			{ 25700, 1 }, -- dream blossom staff
			{ 11687, 1 }, -- royal scale robe
			{ 8864, 1 }, -- yalahari mask
			{ 3398, 1 }, -- dwarven legs
			{ 3079, 1 }, -- boots of haste
			{ 8090, 1 }, -- spellbook of dark mysteries
		},

		[VOCATION.ID.DRUID] = {
			{ 25700, 1 }, -- dream blossom staff
			{ 11687, 1 }, -- royal scale robe
			{ 8864, 1 }, -- yalahari mask
			{ 3398, 1 }, -- dwarven legs
			{ 3079, 1 }, -- boots of haste
			{ 8090, 1 }, -- spellbook of dark mysteries
		},

		[VOCATION.ID.PALADIN] = {
			{ 11689, 1 }, -- elite draken helmet
			{ 8060, 1 }, -- master archer's armor
			{ 8863, 1 }, -- yalahari leg piece
			{ 10323, 1 }, -- guardian boots
			{ 22866, 1 }, -- rift bow
			{ 27565, 1 }, -- foxtail amulet
			{ 25698, 1 }, -- butterfly ring
		},

		[VOCATION.ID.KNIGHT] = {
			{ 10385, 1 }, -- zaoan helmet
			{ 16110, 1 }, -- prismatic armor
			{ 13999, 1 }, -- ornate legs
			{ 13997, 1 }, -- depth calcei
		},

		[VOCATION.ID.MONK] = {
			{ 50276, 1 }, -- gnomish cuirass
			{ 3398, 1 }, -- dwarven legs
			{ 50290, 1 }, -- gnomish footwraps
			{ 50190, 1 }, -- dark vision bandana
			{ 50270, 1 }, -- bambus jo
		},
	},
}

-- Busca la recompensa correspondiente.
-- Si el jugador está promocionado, revisa su vocación base.
local function getVocationReward(player)
	local vocation = player:getVocation()

	while vocation do
		local reward = config.rewards[vocation:getId()]

		if reward then
			return reward
		end

		local demotion = vocation:getDemotion()

		if not demotion or demotion:getId() == vocation:getId() then
			break
		end

		vocation = demotion
	end

	return nil
end

local function giveLevelReward(player)
	-- Todavía no alcanza el nivel requerido.
	if player:getLevel() < config.level then
		return true
	end

	-- Ya recibió la recompensa anteriormente.
	if player:getStorageValue(config.storage) >= 1 then
		return true
	end

	local reward = getVocationReward(player)

	if not reward then
		print(string.format(
			"[Level 150 Reward] No existe recompensa para la vocation ID %d del jugador %s.",
			player:getVocation():getId(),
			player:getName()
		))

		return true
	end

	-- Valida primero que todos los ID configurados sean válidos.
	for i = 1, #reward do
		local itemId = reward[i][1]
		local itemType = ItemType(itemId)

		if itemType:getId() == 0 then
			print(string.format(
				"[Level 150 Reward] El item ID %d no existe. Recompensa no entregada a %s.",
				itemId,
				player:getName()
			))

			player:sendTextMessage(
				MESSAGE_STATUS_WARNING,
				"No fue posible entregar tu recompensa de nivel 150. Informa a un administrador."
			)

			return true
		end
	end

	-- Entrega los objetos directamente al jugador.
	for i = 1, #reward do
		local itemId = reward[i][1]
		local itemCount = reward[i][2]

		-- El tercer argumento permite dejarlo en el piso si no tiene capacidad.
		local addedItem = player:addItem(itemId, itemCount, true)

		if not addedItem then
			print(string.format(
				"[Level 150 Reward] No se pudo entregar el item ID %d a %s.",
				itemId,
				player:getName()
			))
		end
	end

	-- Impide que la recompensa vuelva a entregarse.
	player:setStorageValue(config.storage, 1)

	player:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		"Felicidades, recibiste tu equipo especial por alcanzar el nivel 150."
	)

	player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)

	return true
end

-- Evento ejecutado cuando el jugador sube de nivel.
local levelAdvance = CreatureEvent("Level150EquipmentRewardAdvance")

function levelAdvance.onAdvance(player, skill, oldLevel, newLevel)
	if skill ~= SKILL_LEVEL then
		return true
	end

	-- También funciona si pasa directamente del nivel 149 al 151 o superior.
	if oldLevel < config.level and newLevel >= config.level then
		return giveLevelReward(player)
	end

	return true
end

levelAdvance:register()

-- Registra el evento cada vez que el jugador inicia sesión.
local levelLogin = CreatureEvent("Level150EquipmentRewardLogin")

function levelLogin.onLogin(player)
	player:registerEvent("Level150EquipmentRewardAdvance")

	-- Los personajes que ya sean nivel 150 o superior también lo recibirán
	-- al iniciar sesión, siempre que no lo hayan recibido anteriormente.
	giveLevelReward(player)

	return true
end

levelLogin:register()