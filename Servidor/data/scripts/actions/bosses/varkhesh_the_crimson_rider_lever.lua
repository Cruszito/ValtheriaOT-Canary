local config = {
	bossName = "Varkhesh the Crimson Rider",
	bossPosition = Position(32411, 32359, 15),

	leverPosition = Position(32440, 32356, 15),
	leaderPosition = Position(32440, 32357, 15),
	teleportPosition = Position(32418, 32350, 15),
	exitPosition = Position(32442, 32357, 15),

	playerPositions = {
		Position(32440, 32357, 15),
		Position(32440, 32358, 15),
		Position(32440, 32359, 15),
		Position(32440, 32360, 15),
		Position(32440, 32361, 15),
	},

	arenaFrom = Position(32408, 32348, 15),
	arenaTo = Position(32418, 32362, 15),

	cooldown = 20 * 60 * 60, -- 20 hours
	timeToDefeat = 30 * 60, -- 30 minutes
	timeAfterKill = 60, -- Time to leave the arena after defeating the boss
	cooldownKey = "custom-boss.cooldown.varkhesh-the-crimson-rider",
}

local arena = Zone("custom.boss.varkhesh-the-crimson-rider")
arena:addArea(config.arenaFrom, config.arenaTo)
arena:blockFamiliars()
arena:setRemoveDestination(config.exitPosition)

local timeoutEvent
local removalEvent

local function removeArenaPlayersAndMonsters()
	arena:refresh()
	arena:removePlayers()
	arena:removeMonsters()
end

local bossDeath = CreatureEvent("VarkheshTheCrimsonRiderLeverDeath")

function bossDeath.onDeath(creature)
	if creature:getName():lower() ~= config.bossName:lower() then
		return true
	end

	if timeoutEvent then
		stopEvent(timeoutEvent)
		timeoutEvent = nil
	end

	arena:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		config.bossName .. " has been defeated. You have " .. config.timeAfterKill .. " seconds to leave the room."
	)

	if removalEvent then
		stopEvent(removalEvent)
	end

	removalEvent = addEvent(function()
		removeArenaPlayersAndMonsters()
		removalEvent = nil
	end, config.timeAfterKill * 1000)

	return true
end

bossDeath:register()

local leverAction = Action()

function leverAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getPosition() ~= config.leaderPosition then
		player:sendCancelMessage("Only the player in the first position can use this lever.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if arena:countPlayers(IgnoredByMonsters) > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "There is already a team fighting " .. config.bossName .. ".")
		return true
	end

	local participants = {}
	for _, position in ipairs(config.playerPositions) do
		local tile = Tile(position)
		local creature = tile and tile:getBottomCreature()
		local participant = creature and creature:getPlayer()
		if participant then
			table.insert(participants, participant)
		end
	end

	if #participants == 0 or participants[1] ~= player then
		player:sendCancelMessage("You must stand in the first position to start the fight.")
		return true
	end

	local currentTime = os.time()
	for _, participant in ipairs(participants) do
		local cooldownEnd = participant:kv():get(config.cooldownKey) or 0
		if cooldownEnd > currentTime then
			local timeLeft = Game.getTimeInWords(cooldownEnd - currentTime)
			participant:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You must wait " .. timeLeft .. " to face " .. config.bossName .. " again.")
			participant:getPosition():sendMagicEffect(CONST_ME_POFF)
			if participant ~= player then
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, participant:getName() .. " still has a boss cooldown.")
			end
			return true
		end
	end

	arena:removeMonsters()

	local boss = Game.createMonster(config.bossName, config.bossPosition, true, true)
	if not boss then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The boss could not be created. Please contact an administrator.")
		return true
	end
	boss:registerEvent("VarkheshTheCrimsonRiderLeverDeath")

	local cooldownEnd = currentTime + config.cooldown
	for _, participant in ipairs(participants) do
		participant:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		participant:teleportTo(config.teleportPosition)
		participant:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		participant:kv():set(config.cooldownKey, cooldownEnd)
	end

	if timeoutEvent then
		stopEvent(timeoutEvent)
	end
	if removalEvent then
		stopEvent(removalEvent)
		removalEvent = nil
	end

	timeoutEvent = addEvent(function()
		removeArenaPlayersAndMonsters()
		timeoutEvent = nil
	end, config.timeToDefeat * 1000)

	return true
end

leverAction:position(config.leverPosition)
leverAction:register()