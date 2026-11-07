local config = {
	activatePosition = Position(32210, 32167, 5),

	-- Bonus
	expBonusPercent = 10,
	duration = 8 * 60 * 60, -- 8 horas

	-- Storages del jugador
	bonusEndStorage = 46001,
	bonusOwnerStorage = 46003,

	-- Storages globales del castle
	globalOwnerStorage = 46004,
	globalEndStorage = 46005,

	-- Anti-spam del tile
	activationCooldownStorage = 46002,
	activationCooldown = 10, -- segundos
}

local function samePosition(pos1, pos2)
	return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
end

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

local function getPartyPlayers(player)
	local players = {}
	local added = {}

	local party = player:getParty()
	if not party then
		table.insert(players, player)
		return players
	end

	local leader = party:getLeader()
	if leader then
		table.insert(players, leader)
		added[leader:getGuid()] = true
	end

	for _, member in ipairs(party:getMembers()) do
		if member and member:isPlayer() and not added[member:getGuid()] then
			table.insert(players, member)
			added[member:getGuid()] = true
		end
	end

	return players
end

local function getPartyOwnerGuid(player)
	local party = player:getParty()
	if party and party:getLeader() then
		return party:getLeader():getGuid()
	end

	return player:getGuid()
end

local function isCurrentOwnerInParty(currentOwnerGuid, players)
	if currentOwnerGuid <= 0 then
		return false
	end

	for _, partyPlayer in ipairs(players) do
		if partyPlayer:getGuid() == currentOwnerGuid then
			return true
		end
	end

	return false
end

local function applyCastleBonus(players, ownerGuid, endTime)
	for _, partyPlayer in ipairs(players) do
		partyPlayer:setStorageValue(config.bonusEndStorage, endTime)
		partyPlayer:setStorageValue(config.bonusOwnerStorage, ownerGuid)

		partyPlayer:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"Castle Blessing active: +" .. config.expBonusPercent .. "% experience for " .. getTimeLeft(endTime - os.time()) .. "."
		)

		partyPlayer:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end
end

local castlePartyExpBonus = MoveEvent()

function castlePartyExpBonus.onStepIn(creature, item, position, fromPosition)
	if not creature or not creature:isPlayer() then
		return true
	end

	if not samePosition(position, config.activatePosition) then
		return true
	end

	local player = creature
	local now = os.time()

	local activationCooldown = player:getStorageValue(config.activationCooldownStorage)
	if activationCooldown > now then
		player:sendCancelMessage("Please wait before activating the castle blessing again.")
		return true
	end

	player:setStorageValue(config.activationCooldownStorage, now + config.activationCooldown)

	local players = getPartyPlayers(player)
	local currentOwnerGuid = Game.getStorageValue(config.globalOwnerStorage)
	local currentEndTime = Game.getStorageValue(config.globalEndStorage)

	if currentOwnerGuid < 0 then
		currentOwnerGuid = 0
	end

	if currentEndTime < 0 then
		currentEndTime = 0
	end

    -- Si la misma party ya controla el castle, reinicia las 8 horas.
    if currentEndTime > now and isCurrentOwnerInParty(currentOwnerGuid, players) then
        local refreshedEndTime = now + config.duration

        Game.setStorageValue(config.globalOwnerStorage, currentOwnerGuid)
        Game.setStorageValue(config.globalEndStorage, refreshedEndTime)

        applyCastleBonus(players, currentOwnerGuid, refreshedEndTime)

        Game.broadcastMessage(
            player:getName() .. " has renewed the Castle Blessing. Their party keeps +" .. config.expBonusPercent .. "% experience for another 8 hours!",
            MESSAGE_STATUS_WARNING
        )

        return true
    end

	-- Si otra party/player pisa, toma el control y el bonus anterior queda invalidado.
	local newOwnerGuid = getPartyOwnerGuid(player)
	local newEndTime = now + config.duration

	Game.setStorageValue(config.globalOwnerStorage, newOwnerGuid)
	Game.setStorageValue(config.globalEndStorage, newEndTime)

	applyCastleBonus(players, newOwnerGuid, newEndTime)

	Game.broadcastMessage(
		player:getName() .. " has claimed the Castle Blessing. Their party receives +" .. config.expBonusPercent .. "% experience for 8 hours!",
		MESSAGE_STATUS_WARNING
	)

	return true
end

castlePartyExpBonus:position(config.activatePosition)
castlePartyExpBonus:register()