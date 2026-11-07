local xpBoostInfo = TalkAction("!xp")

local potionStorageExpiresAt = "sun-fruit-juice-xp-boost-expires-at"
local potionStoragePercent = "sun-fruit-juice-xp-boost-percent"

local function formatTime(seconds)
	if seconds <= 0 then
		return "00:00:00"
	end

	local hours = math.floor(seconds / 3600)
	seconds = seconds % 3600

	local minutes = math.floor(seconds / 60)
	seconds = seconds % 60

	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function xpBoostInfo.onSay(player, words, param)
	local messages = {}

	local storeBoostPercent = player:getXpBoostPercent()
	local storeBoostTime = player:getXpBoostTime()

	if storeBoostPercent and storeBoostPercent > 0 and storeBoostTime and storeBoostTime > 0 then
		table.insert(messages, string.format("Store XP Boost: %d%% - %s remaining.", storeBoostPercent, formatTime(storeBoostTime)))
	else
		table.insert(messages, "Store XP Boost: inactive.")
	end

	local now = os.time()
	local potionExpiresAt = player:kv():get(potionStorageExpiresAt) or 0
	local potionPercent = player:kv():get(potionStoragePercent) or 0

	if potionExpiresAt > now and potionPercent > 0 then
		table.insert(messages, string.format("Potion XP Boost: %d%% - %s remaining.", potionPercent, formatTime(potionExpiresAt - now)))
	else
		table.insert(messages, "Potion XP Boost: inactive.")
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, table.concat(messages, "\n"))
	return true
end

xpBoostInfo:groupType("normal")
xpBoostInfo:register()