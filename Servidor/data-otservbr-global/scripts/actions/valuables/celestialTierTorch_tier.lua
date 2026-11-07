local celestialTierTorch = Action()

local TOKEN_ID = 49176

-- Límites normales establecidos por las clasificaciones de Forge.
local maxTierByClassification = {
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 10,
}

local armorSlotFlags = SLOTP_HEAD
	+ SLOTP_ARMOR
	+ SLOTP_LEGS
	+ SLOTP_FEET

function celestialTierTorch.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or type(target) ~= "userdata" or not target:isItem() then
		player:sendTextMessage(
			MESSAGE_FAILURE,
			"Use this token on a helmet, armor, legs, boots or weapon."
		)
		return true
	end

	if target:getId() == TOKEN_ID then
		player:sendTextMessage(
			MESSAGE_FAILURE,
			"You cannot use a platinum token on another platinum token."
		)
		return true
	end

	local targetType = ItemType(target:getId())
	local weaponType = targetType:getWeaponType()
	local slotPosition = targetType:getSlotPosition()

	if weaponType == WEAPON_SHIELD then
		player:sendTextMessage(
			MESSAGE_FAILURE,
			"Shields and spellbooks cannot be upgraded with this token."
		)
		return true
	end

	local isArmorPiece = bit.band(slotPosition, armorSlotFlags) ~= 0
	local isWeapon = targetType:isWeapon()

	if not isArmorPiece and not isWeapon then
		player:sendTextMessage(
			MESSAGE_FAILURE,
			"This token can only be used on helmets, armors, legs, boots or weapons."
		)
		return true
	end

	local classification = target:getClassification()
	local maxTier = maxTierByClassification[classification]

	if not maxTier then
		player:sendTextMessage(
			MESSAGE_FAILURE,
			"This item does not have a valid Forge classification."
		)
		return true
	end

	local currentTier = target:getTier()

	if currentTier >= maxTier then
		player:sendTextMessage(
			MESSAGE_FAILURE,
			string.format(
				"This item has already reached its maximum tier: %d.",
				maxTier
			)
		)
		return true
	end

	local newTier = currentTier + 1
	target:setTier(newTier)

	-- Verifica que Canary realmente haya aplicado el tier.
	if target:getTier() ~= newTier then
		player:sendTextMessage(
			MESSAGE_FAILURE,
			"The tier could not be applied to this item."
		)
		return true
	end

	-- Consume exactamente un platinum token.
	item:remove(1)

	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)

	player:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		string.format(
			"Your %s has been upgraded from Tier %d to Tier %d.",
			targetType:getName(),
			currentTier,
			newTier
		)
	)

	return true
end

celestialTierTorch:id(TOKEN_ID)
celestialTierTorch:register()