local config = {
	uniqueId = 45004,

	-- 20 horas. Si quieres 24 horas exactas, cambia a: 24 * 60 * 60
	cooldownStorage = 45004,
	cooldownTime = 20 * 60 * 60,

	rewards = {
		{itemId = 3043, count = 50},  -- crystal coin
		{itemId = 51589, count = 5},  -- proficiency
		{itemId = 22118, count = 10}, -- tibia coins
		{itemId = 58448, count = 100}, -- Endless coin
	}
}

local function getTimeLeft(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)

	if hours > 0 and minutes > 0 then
		return hours .. " hours and " .. minutes .. " minutes"
	elseif hours > 0 then
		return hours .. " hours"
	end

	return minutes .. " minutes"
end

local dailyRewardChest = Action()

function dailyRewardChest.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local cooldown = player:getStorageValue(config.cooldownStorage)

	if cooldown > os.time() then
		local remainingTime = cooldown - os.time()
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have already claimed this reward. You must wait " .. getTimeLeft(remainingTime) .. ".")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	for _, reward in ipairs(config.rewards) do
		local addedItem = player:addItem(reward.itemId, reward.count)

		if not addedItem then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You do not have enough capacity or space to receive the reward.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end
	end

	player:setStorageValue(config.cooldownStorage, os.time() + config.cooldownTime)

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have received your daily reward.")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)

	return true
end

dailyRewardChest:uid(config.uniqueId)
dailyRewardChest:register()