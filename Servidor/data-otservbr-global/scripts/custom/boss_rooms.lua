local FIGHT_COOLDOWN = 12 * 60 * 60 -- 12 hours, in seconds
local FIGHT_DURATION = 20 * 60 -- 20 minutes, in seconds
local TIME_AFTER_KILL = 60 -- Seconds before removing the team after killing the boss

local bossLeverConfigs = {
	{
		leverPosition = Position(32389, 32332, 12),
		cooldownKey = "custom.boss.cooldown.apocalypse",
		boss = {
			name = "Apocalypse",
			position = Position(32390, 32310, 12),
		},
		timeToFightAgain = FIGHT_COOLDOWN,
		timeToDefeat = FIGHT_DURATION,
		timeAfterKill = TIME_AFTER_KILL,
		minPlayers = 1,
		playerPositions = {
			{ pos = Position(32390, 32332, 12), teleport = Position(32390, 32320, 12) },
			{ pos = Position(32391, 32332, 12), teleport = Position(32390, 32320, 12) },
			{ pos = Position(32392, 32332, 12), teleport = Position(32390, 32320, 12) },
			{ pos = Position(32393, 32332, 12), teleport = Position(32390, 32320, 12) },
			{ pos = Position(32394, 32332, 12), teleport = Position(32390, 32320, 12) },
		},
		specPos = {
			from = Position(32377, 32298, 12),
			to = Position(32402, 32322, 12),
		},
		exit = Position(32390, 32332, 12),
	},
	{
		leverPosition = Position(32428, 32332, 12),
		cooldownKey = "custom.boss.cooldown.zoralurk",
		boss = {
			name = "Zoralurk",
			position = Position(32428, 32310, 12),
		},
		timeToFightAgain = FIGHT_COOLDOWN,
		timeToDefeat = FIGHT_DURATION,
		timeAfterKill = TIME_AFTER_KILL,
		minPlayers = 1,
		playerPositions = {
			{ pos = Position(32429, 32332, 12), teleport = Position(32428, 32320, 12) },
			{ pos = Position(32430, 32332, 12), teleport = Position(32428, 32320, 12) },
			{ pos = Position(32431, 32332, 12), teleport = Position(32428, 32320, 12) },
			{ pos = Position(32432, 32332, 12), teleport = Position(32428, 32320, 12) },
			{ pos = Position(32433, 32332, 12), teleport = Position(32428, 32320, 12) },
		},
		specPos = {
			from = Position(32415, 32298, 12),
			to = Position(32440, 32322, 12),
		},
		exit = Position(32429, 32332, 12),
	},
	{
		leverPosition = Position(32349, 32332, 12),
		cooldownKey = "custom.boss.cooldown.verminor",
		boss = {
			name = "Verminor",
			position = Position(32352, 32310, 12),
		},
		timeToFightAgain = FIGHT_COOLDOWN,
		timeToDefeat = FIGHT_DURATION,
		timeAfterKill = TIME_AFTER_KILL,
		minPlayers = 1,
		playerPositions = {
			{ pos = Position(32350, 32332, 12), teleport = Position(32352, 32320, 12) },
			{ pos = Position(32351, 32332, 12), teleport = Position(32352, 32320, 12) },
			{ pos = Position(32352, 32332, 12), teleport = Position(32352, 32320, 12) },
			{ pos = Position(32353, 32332, 12), teleport = Position(32352, 32320, 12) },
			{ pos = Position(32354, 32332, 12), teleport = Position(32352, 32320, 12) },
		},
		specPos = {
			from = Position(32339, 32298, 12),
			to = Position(32364, 32322, 12),
		},
		exit = Position(32350, 32332, 12),
	},
}

local originalBossLeverOnUse = BossLever.onUse

local function registerBossRoom(config)
	local cooldownKey = config.cooldownKey
	local bossName = config.boss.name
	local bossPosition = config.boss.position
	local deathEventName = "CustomBossRoomDeath" .. bossName:gsub("[^%w]", "")
	local registeredLever

	-- Unlock the room after the boss dies and the team receives its normal
	-- timeAfterKill period to leave.
	local roomDeathEvent = CreatureEvent(deathEventName)
	function roomDeathEvent.onDeath(creature)
		if not registeredLever then
			return true
		end

		local finishedSessionId = registeredLever.roomSessionId
		addEvent(function()
			-- Do not touch a newer fight that may already be running.
			if not registeredLever.roomOccupied or registeredLever.roomSessionId ~= finishedSessionId then
				return
			end

			if registeredLever.roomTimeoutEvent then
				stopEvent(registeredLever.roomTimeoutEvent)
				registeredLever.roomTimeoutEvent = nil
			end

			if registeredLever.timeoutEvent then
				stopEvent(registeredLever.timeoutEvent)
				registeredLever.timeoutEvent = nil
			end

			local zone = registeredLever:getZone()
			zone:refresh()
			zone:removePlayers()
			zone:removeMonsters()
			registeredLever.roomOccupied = false
		end, (registeredLever.timeAfterKill * 1000) + 100)

		return true
	end
	roomDeathEvent:register()

	-- Create the boss and register both the original BossLever death event and
	-- the event that releases this room's occupied state.
	config.boss.createFunction = function()
		local monster = Game.createMonster(bossName, bossPosition, true, true)
		if not monster then
			return false
		end

		monster:registerEvent("BossLeverOnDeath")
		monster:registerEvent(deathEventName)
		return true
	end

	-- The default BossLever cooldown uses the boss raceId. These custom keys
	-- keep the three cooldowns independent, even when their raceId is 0.
	config.disableCooldown = true
	config.onUseExtra = function(player)
		-- Prevent BossLever from also writing its raceId-based cooldown.
		if registeredLever and registeredLever.lever then
			registeredLever.lever.setCooldownAllPlayers = function()
				return true
			end
		end

		local cooldownEnd = tonumber(player:kv():get(cooldownKey)) or 0
		if cooldownEnd > os.time() then
			local timeLeft = cooldownEnd - os.time()
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"You have to wait " .. Game.getTimeInWords(timeLeft) .. " to face " .. bossName .. " again."
			)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		return true
	end

	registeredLever = BossLever(config)
	registeredLever.cooldownKey = cooldownKey
	registeredLever.displayBossName = bossName
	registeredLever.roomOccupied = false
	registeredLever.roomSessionId = 0
	registeredLever.roomTimeoutEvent = nil

	-- Store the 12-hour cooldown for every player who was on a participation tile.
	function registeredLever:setLastEncounterTime(cooldownEnd)
		local infoPositions = self.lever and self.lever:getInfoPositions()
		if not infoPositions then
			logger.error("Custom BossLever:setLastEncounterTime - No participant information for {}", self.name)
			return false
		end

		-- This method is called only after the boss was created and the players
		-- were teleported successfully, so it is the reliable moment to lock it.
		self.roomOccupied = true
		self.roomSessionId = self.roomSessionId + 1

		for _, positionInfo in ipairs(infoPositions) do
			local participant = positionInfo.creature and positionInfo.creature:getPlayer()
			if participant then
				participant:kv():set(self.cooldownKey, cooldownEnd)
				participant:sendTextMessage(
					MESSAGE_EVENT_ADVANCE,
					"You have 20 minutes to defeat the boss and leave the room."
				)
			end
		end

		return true
	end

	-- Block the lever when any player is inside this boss room.
	function registeredLever:onUse(player)
		local zone = self:getZone()
		zone:refresh()
		local playersInside = zone:getPlayers()

		-- If the previous team abandoned the fight and nobody remains inside,
		-- release the lock, cancel its timers and remove the abandoned boss.
		-- The same lever use can then start a new fight immediately.
		if self.roomOccupied and #playersInside == 0 then
			if self.roomTimeoutEvent then
				stopEvent(self.roomTimeoutEvent)
				self.roomTimeoutEvent = nil
			end

			if self.timeoutEvent then
				stopEvent(self.timeoutEvent)
				self.timeoutEvent = nil
			end

			self.roomOccupied = false
			self.roomSessionId = self.roomSessionId + 1
			zone:removeMonsters()
		end

		if self.roomOccupied or #playersInside > 0 then
			player:sendTextMessage(
				MESSAGE_EVENT_ADVANCE,
				"There is already someone fighting " .. self.displayBossName .. "."
			)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end

		local result = originalBossLeverOnUse(self, player)

		-- roomOccupied changes to true only when entry actually succeeded.
		if self.roomOccupied then
			if self.timeoutEvent then
				stopEvent(self.timeoutEvent)
				self.timeoutEvent = nil
			end

			if self.roomTimeoutEvent then
				stopEvent(self.roomTimeoutEvent)
				self.roomTimeoutEvent = nil
			end

			local activeLever = self
			local activeSessionId = self.roomSessionId
			self.roomTimeoutEvent = addEvent(function()
				if not activeLever.roomOccupied or activeLever.roomSessionId ~= activeSessionId then
					return
				end

				activeLever.roomTimeoutEvent = nil

				if activeLever.timeoutEvent then
					stopEvent(activeLever.timeoutEvent)
					activeLever.timeoutEvent = nil
				end

				local activeZone = activeLever:getZone()
				activeZone:refresh()
				for _, participant in ipairs(activeZone:getPlayers()) do
					participant:sendTextMessage(
						MESSAGE_EVENT_ADVANCE,
						"Your 20-minute time limit has expired. You have been removed from the boss room."
					)
				end

				activeZone:removePlayers()
				activeZone:removeMonsters()
				activeLever.roomOccupied = false
			end, activeLever.timeToDefeat * 1000)
		end

		return result
	end

	registeredLever:position(config.leverPosition)
	registeredLever:register()
end

for _, config in ipairs(bossLeverConfigs) do
	registerBossRoom(config)
end