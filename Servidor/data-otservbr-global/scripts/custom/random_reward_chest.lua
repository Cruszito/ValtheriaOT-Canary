local chests = {
	-- Cofre 1
	[65534] = {
		rewards = {
			{ id = 55134, count = 1 },
			{ id = 55131, count = 1 },
			{ id = 55135, count = 1 },
		},
	},

	-- Cofre 2
	[65533] = {
		rewards = {
			{ id = 55038, count = 1 },
			{ id = 55292, count = 1 },
			{ id = 55293, count = 1 },
		},
	},

	-- Cofre 3
	[65532] = {
		rewards = {
			{ id = 55347, count = 1 },
			{ id = 55345, count = 1 },
			{ id = 55349, count = 1 },
		},
	},

	-- Cofre 4
	[65531] = {
		rewards = {
			{ id = 55726, count = 1 },
			{ id = 55728, count = 1 },
			{ id = 55730, count = 1 },
		},
	},

	-- Cofre 5
	[65530] = {
		rewards = {
			{ id = 55573, count = 1 },
			{ id = 55574, count = 1 },
			{ id = 55575, count = 1 },
		},
	},

	-- Cofre 6
	[65529] = {
		rewards = {
			{ id = 55558, count = 1 },
			{ id = 55559, count = 1 },
			{ id = 55560, count = 1 },
		},
	},

	-- Cofre 7 
	[65528] = {
		rewards = {
			{ id = 55539, count = 1 },
			{ id = 55687, count = 1 },
			{ id = 55639, count = 1 },
		},
	},
}

local randomRewardChests = Action()

function randomRewardChests.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local actionId = item:getActionId()
	local chest = chests[actionId]

	if not chest then
		return false
	end

	-- Cada Action ID funciona también como storage individual.
	if player:getStorageValue(actionId) >= 1 then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Este cofre esta vacio. Ya recibiste su recompensa."
		)
		return true
	end

	local selectedReward = chest.rewards[math.random(#chest.rewards)]

	local addedItem = player:addItem(
		selectedReward.id,
		selectedReward.count,
		false
	)

	if not addedItem then
		player:sendCancelMessage(
			"No tienes suficiente capacidad o espacio para recibir la recompensa."
		)
		return true
	end

	-- Se registra como reclamado después de entregar el premio.
	player:setStorageValue(actionId, 1)

	local itemName = ItemType(selectedReward.id):getName()

	player:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		string.format(
			"Has recibido %dx %s.",
			selectedReward.count,
			itemName
		)
	)

	fromPosition:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end

for actionId in pairs(chests) do
	randomRewardChests:aid(actionId)
end

randomRewardChests:register()