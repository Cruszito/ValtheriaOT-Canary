local pzCommand = TalkAction("!pz")

local function formatTime(seconds)
	if seconds <= 0 then
		return "0 seconds"
	end

	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds % 60

	if minutes > 0 and remainingSeconds > 0 then
		return minutes .. " minute" .. (minutes == 1 and "" or "s") .. " and " .. remainingSeconds .. " second" .. (remainingSeconds == 1 and "" or "s")
	elseif minutes > 0 then
		return minutes .. " minute" .. (minutes == 1 and "" or "s")
	end

	return remainingSeconds .. " second" .. (remainingSeconds == 1 and "" or "s")
end

local function getBattleSecondsLeft(player)
	local condition = nil

	-- Intenta obtener la condición de battle de distintas formas según el core.
	if player.getCondition then
		condition = player:getCondition(CONDITION_INFIGHT)
	end

	if not condition and player.getCondition then
		condition = player:getCondition(CONDITION_INFIGHT, CONDITIONID_DEFAULT)
	end

	if not condition and player.getCondition then
		condition = player:getCondition(CONDITION_INFIGHT, CONDITIONID_COMBAT)
	end

	if not condition then
		return nil
	end

	-- Algunos cores exponen getTicks()
	if condition.getTicks then
		local ticks = condition:getTicks()
		if ticks and ticks > 0 then
			return math.ceil(ticks / 1000)
		end
	end

	-- Algunos cores exponen getEndTime()
	if condition.getEndTime then
		local endTime = condition:getEndTime()
		if endTime and endTime > os.time() then
			return endTime - os.time()
		end
	end

	return nil
end

function pzCommand.onSay(player, words, param)
	if not player:hasCondition(CONDITION_INFIGHT) then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are not in battle. You can logout safely.")
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		return true
	end

	local secondsLeft = getBattleSecondsLeft(player)

	if secondsLeft and secondsLeft > 0 then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You are still in battle. You can logout in approximately " .. formatTime(secondsLeft) .. "."
		)
	else
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You are still in battle, but this server core does not expose the remaining battle time to Lua."
		)
	end

	player:getPosition():sendMagicEffect(CONST_ME_POFF)
	return true
end

pzCommand:groupType("normal")
pzCommand:register()