local Expboost50 = Action()

local config = {
	storageExpiresAt = "sun-fruit-juice-xp-boost-expires-at",
	storagePercent = "sun-fruit-juice-xp-boost-percent",
	duration = 60 * 60, -- 1 hora
	items = {
		[30003] = 30, -- XP Boost 30%
		[55145] = 50, -- Exp Card Token: XP Boost 50%
	},
}

local function formatRemainingTime(seconds)
	local hours = math.floor(seconds / 3600)
	seconds = seconds % 3600

	local minutes = math.floor(seconds / 60)
	seconds = seconds % 60

	if hours > 0 then
		return string.format(
			"%d hour%s, %d minute%s and %d second%s",
			hours, hours == 1 and "" or "s",
			minutes, minutes == 1 and "" or "s",
			seconds, seconds == 1 and "" or "s"
		)
	end

	if minutes > 0 then
		return string.format(
			"%d minute%s and %d second%s",
			minutes, minutes == 1 and "" or "s",
			seconds, seconds == 1 and "" or "s"
		)
	end

	return string.format(
		"%d second%s",
		seconds,
		seconds == 1 and "" or "s"
	)
end

function Expboost50.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local percent = config.items[item:getId()]
	if not percent then
		return false
	end

	local now = os.time()
	local expiresAt = player:kv():get(config.storageExpiresAt) or 0
	local activePercent = player:kv():get(config.storagePercent) or 0

	if expiresAt > now then
		player:sendCancelMessage(string.format(
			"You already have an active %d%% experience boost. Time remaining: %s.",
			activePercent,
			formatRemainingTime(expiresAt - now)
		))
		return true
	end

	player:kv():set(config.storageExpiresAt, now + config.duration)
	player:kv():set(config.storagePercent, percent)

	item:remove(1)

	player:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		string.format(
			"You have activated a %d%% extra experience boost for 1 hour.",
			percent
		)
	)

	player:say("¡XP Boost activado! +50% de experiencia extra. Usa el comando !xp para ver tus activaciones.", TALKTYPE_MONSTER_SAY)

	return true
end

for itemId, _ in pairs(config.items) do
	Expboost50:id(itemId)
end

Expboost50:register()