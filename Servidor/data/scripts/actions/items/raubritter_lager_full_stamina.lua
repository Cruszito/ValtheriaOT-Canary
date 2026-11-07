local ITEM_ID = 52785 -- cool bottle of Raubritter Lager

local MAX_STAMINA = 42 * 60 -- 42 horas = 2520 minutos
local COOLDOWN_STORAGE = 52785001
local COOLDOWN_TIME = 12 * 60 * 60 -- 12 horas en segundos

local function formatTime(seconds)
	if seconds <= 0 then
		return "0 seconds"
	end

	local hours = math.floor(seconds / 3600)
	seconds = seconds % 3600

	local minutes = math.floor(seconds / 60)
	seconds = seconds % 60

	local parts = {}

	if hours > 0 then
		table.insert(parts, hours .. " hour" .. (hours == 1 and "" or "s"))
	end

	if minutes > 0 then
		table.insert(parts, minutes .. " minute" .. (minutes == 1 and "" or "s"))
	end

	if seconds > 0 then
		table.insert(parts, seconds .. " second" .. (seconds == 1 and "" or "s"))
	end

	return table.concat(parts, ", ")
end

local raubritterLager = Action()

function raubritterLager.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local now = os.time()
	local cooldown = player:getStorageValue(COOLDOWN_STORAGE)

	if cooldown and cooldown > now then
		player:sendCancelMessage("You have to wait " .. formatTime(cooldown - now) .. " before using another Raubritter Lager.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if player:getStamina() >= MAX_STAMINA then
		player:sendCancelMessage("Your stamina is already full.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	player:setStamina(MAX_STAMINA)
	player:setStorageValue(COOLDOWN_STORAGE, now + COOLDOWN_TIME)

	item:remove(1)

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You drank the Raubritter Lager and your stamina has been fully restored to 42 hours.")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	return true
end

raubritterLager:id(ITEM_ID)
raubritterLager:register()