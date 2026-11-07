local config = {
	bossName = "Xaltherion Abyssborn",
	bossPosition = Position(32473, 32363, 15),

	leverPosition = Position(32490, 32366, 15),
	leaderPosition = Position(32490, 32367, 15),
	teleportPosition = Position(32463, 32373, 15),
	exitPosition = Position(32487, 32368, 15),

	playerPositions = {
		Position(32490, 32367, 15),
		Position(32490, 32368, 15),
		Position(32490, 32369, 15),
		Position(32490, 32370, 15),
		Position(32490, 32371, 15),
	},

	arenaFrom = Position(32462, 32362, 15),
	arenaTo = Position(32476, 32374, 15),

	cooldown = 20 * 60 * 60,
	timeToDefeat = 30 * 60,
	timeAfterKill = 60,
	cooldownKey = "custom-boss.cooldown.xaltherion-abyssborn",
}

local arena = Zone("custom.boss.xaltherion-abyssborn")
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

local bossDeath = CreatureEvent("XaltherionAbyssbornLeverDeath")

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
			participant:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"You must wait " .. timeLeft .. " to face " .. config.bossName .. " again."
			)
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
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"The boss could not be created. Please contact an administrator."
		)
		return true
	end
	boss:registerEvent("XaltherionAbyssbornLeverDeath")

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
