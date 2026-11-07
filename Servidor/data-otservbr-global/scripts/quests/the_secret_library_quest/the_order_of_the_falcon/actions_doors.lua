local REQUIRE_FALCON_QUEST = false

local CLOSED_FALCON_DOOR_ID = 5116
local OPEN_FALCON_DOOR_ID = 5117

local doors = {
	[1] = { doorPosition = Position(33376, 31335, 3), value = 1 },
	[2] = { doorPosition = Position(33371, 31349, 4), value = 2 },
	[3] = { doorPosition = Position(33376, 31349, 4), value = 2 },
	[4] = { doorPosition = Position(33375, 31346, 5), value = 2 },
	[5] = { doorPosition = Position(33363, 31346, 7), value = 4 },
	[6] = { doorPosition = Position(33366, 31343, 7), value = 4 },
}

local boats = {
	[1] = {
		boatPosition = Position(33373, 31309, 7),
		value = 3,
		toPosition = Position(33382, 31292, 7),
		message = "A small island emerges out of the mist as you row towards a tiny light inside a dark, forehoding chapel.",
	},
	[2] = {
		boatPosition = Position(33382, 31294, 7),
		value = 3,
		toPosition = Position(33374, 31310, 7),
		message = "Your heart lightens as you return from the gloomy isle.",
	},
	[3] = {
		boatPosition = Position(33344, 31348, 7),
		value = 3,
		toPosition = Position(33326, 31352, 7),
	},
	[4] = {
		boatPosition = Position(33328, 31352, 7),
		value = 3,
		toPosition = Position(33346, 31348, 7),
	},
}

local function hasFalconAccess(player, requiredValue)
	if not REQUIRE_FALCON_QUEST then
		return true
	end

	return player:getStorageValue(
		Storage.Quest.U11_80.TheSecretLibrary.FalconBastion.KillingBosses
	) >= requiredValue
end

local function useFalconDoor(player, item, toPosition)
	-- Si está abierta, la vuelve a cerrar.
	if item.itemid == OPEN_FALCON_DOOR_ID then
		if Creature.checkCreatureInsideDoor(player, toPosition) then
			return true
		end

		item:transform(CLOSED_FALCON_DOOR_ID)
		item:getPosition():sendSingleSoundEffect(
			SOUND_EFFECT_TYPE_ACTION_CLOSE_DOOR
		)
		return true
	end

	-- Abre la puerta. También corrige automáticamente estados
	-- incorrectos como 5118, 5119 o 5120.
	item:transform(OPEN_FALCON_DOOR_ID)
	item:getPosition():sendSingleSoundEffect(
		SOUND_EFFECT_TYPE_ACTION_OPEN_DOOR
	)
	player:teleportTo(toPosition, true)

	return true
end

local actions_falcon_doors = Action()

function actions_falcon_doors.onUse(
	player,
	item,
	fromPosition,
	target,
	toPosition,
	isHotkey
)
	if item:getActionId() == 4920 then
		for _, doorConfig in pairs(doors) do
			if item:getPosition() == doorConfig.doorPosition then
				if not hasFalconAccess(player, doorConfig.value) then
					player:sendTextMessage(
						MESSAGE_EVENT_ADVANCE,
						"The door seems to be sealed against unwanted intruders."
					)
					return true
				end

				return useFalconDoor(player, item, toPosition)
			end
		end
	elseif item:getActionId() == 4921 then
		for _, boatConfig in pairs(boats) do
			if item:getPosition() == boatConfig.boatPosition then
				if not hasFalconAccess(player, boatConfig.value) then
					player:sendTextMessage(
						MESSAGE_EVENT_ADVANCE,
						"You can not use this boat yet."
					)
					return true
				end

				player:teleportTo(boatConfig.toPosition, true)
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

				if boatConfig.message then
					player:sendTextMessage(
						MESSAGE_EVENT_ADVANCE,
						boatConfig.message
					)
				end

				return true
			end
		end
	end

	return true
end

actions_falcon_doors:aid(4920, 4921)
actions_falcon_doors:register()