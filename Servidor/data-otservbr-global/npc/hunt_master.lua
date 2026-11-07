--[[
	Hunt Master - Multi-task hunting system for Canary

	Recommended path:
	data-otservbr-global/npc/hunt_master.lua

	Features:
	- Up to three active tasks per player.
	- Independent progress for every active task.
	- Repeatable tasks after claiming the reward.
	- Automatic migration from the former single-task KV format.
	- Progress saved with player:kv().
]]

-- =========================================================
-- GENERAL CONFIGURATION
-- =========================================================

local TASK_KV_SCOPE = "custom-hunting-tasks"
local TASK_DEATH_EVENT = "HuntingTaskDeath"
local MAX_ACTIVE_TASKS = 3
local MULTI_TASK_DATA_VERSION = 1

local tierRewards = {
	[1] = {
		experience = 1000000,
		gold = 100000,
		items = {
			{ id = 58448, count = 50, name = "Endless Coins" },
		},
	},
	[2] = {
		experience = 3000000,
		gold = 200000,
		items = {
			{ id = 58448, count = 100, name = "Endless Coins" },
		},
	},
	[3] = {
		experience = 5000000,
		gold = 300000,
		items = {
			{ id = 58448, count = 150, name = "Endless Coins" },
		},
	},
	[4] = {
		experience = 8000000,
		gold = 500000,
		items = {
			{ id = 58448, count = 200, name = "Endless Coins" },
		},
	},
}

-- One-time reward for completing every task in the catalog at least once.
local completionReward = {
	{ id = 49176, count = 5, name = "celestial torch" },
	{ id = 52785, count = 5, name = "stamina potion" },
	{ id = 55145, count = 5, name = "XP Boost 50%" },
	{ id = 36727, count = 5, name = "wealth duplex" },
	{ id = 58448, count = 300, name = "Endless Coins" },
	{ id = 51589, count = 50, name = "greater proficiency catalysts" },
}

-- =========================================================
-- TASK CATALOG
-- =========================================================

local tasks = {}

local function addTask(name, keyword, monsters, requiredKills, tier, keywords)
	tasks[#tasks + 1] = {
		name = name,
		keyword = keyword,
		keywords = keywords or { keyword },
		monsters = monsters,
		requiredKills = requiredKills,
		tier = tier,
	}
end

-- Tier 1
-- These Minotaur variants intentionally share progress in one task.
addTask(
	"Minotaur",
	"minotaur",
	{ "minotaur", "minotaur archer", "minotaur guard", "minotaur mage" },
	250,
	1,
	{ "minotaur", "minotaurs" }
)

-- These Cyclops variants intentionally share progress in one task.
addTask(
	"Cyclops",
	"cyclops",
	{ "cyclops", "cyclops drone", "cyclops smith" },
	350,
	1
)

addTask("Hero", "hero", { "hero" }, 500, 1)
addTask("Dragon", "dragon", { "dragon" }, 800, 1)
addTask("Dragon Lord", "dragon lord", { "dragon lord" }, 1000, 1)
addTask("Lizard High Guard", "lizard high guard", { "lizard high guard" }, 1300, 1)
addTask("Werehyaena", "werehyaena", { "werehyaena" }, 1500, 1)
addTask("Werehyaena Shaman", "werehyaena shaman", { "werehyaena shaman" }, 1500, 1)
addTask("Gazer Spectre", "gazer spectre", { "gazer spectre" }, 800, 1)
addTask("Burster Spectre", "burster spectre", { "burster spectre" }, 800, 1)
addTask("Ripper Spectre", "ripper spectre", { "ripper spectre" }, 800, 1)

-- Tier 2
addTask("Glooth Bandit", "glooth bandit", { "glooth bandit" }, 800, 2)
addTask("Glooth Brigand", "glooth brigand", { "glooth brigand" }, 800, 2)
addTask("Werelion", "werelion", { "werelion" }, 1000, 2)
addTask("Werelioness", "werelioness", { "werelioness" }, 1000, 2)
addTask("Undead Gladiator", "undead gladiator", { "undead gladiator" }, 1300, 2)
addTask("Undead Elite Gladiator", "undead elite gladiator", { "undead elite gladiator" }, 1300, 2)
addTask("Skeleton Elite Warrior", "skeleton elite warrior", { "skeleton elite warrior" }, 1300, 2)
addTask("Crazed Summer Vanguard", "crazed summer vanguard", { "crazed summer vanguard" }, 1500, 2)
addTask("Crazed Summer Rearguard", "crazed summer rearguard", { "crazed summer rearguard" }, 1500, 2)
addTask("Insane Siren", "insane siren", { "insane siren" }, 1500, 2)

-- These Winter Court monsters intentionally share progress in one task.
addTask(
	"Crazed Winter Vanguard",
	"crazed winter vanguard",
	{ "crazed winter vanguard", "crazed winter rearguard", "soul-broken harbinger" },
	1500,
	2
)

addTask("Dragolisk", "dragolisk", { "dragolisk" }, 2000, 2)
addTask("Mega Dragon", "mega dragon", { "mega dragon" }, 2000, 2)
addTask("Wardragon", "wardragon", { "wardragon" }, 2000, 2)
addTask("Lamassu", "lamassu", { "lamassu" }, 2500, 2)
addTask("Sphinx", "sphinx", { "sphinx" }, 2500, 2)
addTask("Crypt Warden", "crypt warden", { "crypt warden" }, 2500, 2)
addTask("Falcon Knight", "falcon knight", { "falcon knight" }, 2500, 2)
addTask("Falcon Paladin", "falcon paladin", { "falcon paladin" }, 2500, 2)

-- Tier 3
addTask("Energetic Book", "energetic book", { "energetic book" }, 3000, 3)
addTask("Knowledge Elemental", "knowledge elemental", { "knowledge elemental" }, 3000, 3)
addTask("Brain Squid", "brain squid", { "brain squid" }, 3000, 3)
addTask("Burning Book", "burning book", { "burning book" }, 3000, 3)
addTask("Rage Squid", "rage squid", { "rage squid" }, 3000, 3)
addTask("Guardian of Tales", "guardian of tales", { "guardian of tales" }, 3000, 3)
addTask("Cursed Book", "cursed book", { "cursed book" }, 3000, 3)
addTask("Vexclaw", "vexclaw", { "vexclaw" }, 2500, 3)
addTask("Dark Torturer", "dark torturer", { "dark torturer" }, 2500, 3)

-- Tier 4
addTask("Infernal Demon", "infernal demon", { "infernal demon" }, 1500, 4)
addTask("Many Faces", "many faces", { "many faces" }, 800, 4)
addTask("Druid's Apparition", "druid's apparition", { "druid's apparition" }, 1500, 4)
addTask("Knight's Apparition", "knight's apparition", { "knight's apparition" }, 1500, 4)
addTask("Paladin's Apparition", "paladin's apparition", { "paladin's apparition" }, 1500, 4)
addTask("Sorcerer's Apparition", "sorcerer's apparition", { "sorcerer's apparition" }, 1500, 4)
addTask("Monk's Apparition", "monk's apparition", { "monk's apparition" }, 1500, 4)

-- Maps IDs from the former 30-task catalog to this expanded catalog.
-- Existing single-task progress is migrated into slot 1.
local legacyTaskIdMap = {
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[6] = 6,
	[7] = 7,
	[8] = 9,
	[9] = 10,
	[10] = 11,
	[11] = 12,
	[12] = 14,
	[13] = 16,
	[14] = 19,
	[15] = 22,
	[16] = 23,
	[17] = 26,
	[18] = 29,
	[19] = 31,
	[20] = 34,
	[21] = 37,
	[22] = 38,
	[23] = 39,
	[24] = 40,
	[25] = 41,
	[26] = 42,
	[27] = 43,
	[28] = 44,
	[29] = 45,
	[30] = 46,
}

-- =========================================================
-- TASK LOOKUPS
-- =========================================================

local taskKeywordLookup = {}

for taskId, task in ipairs(tasks) do
	task.monsterLookup = {}

	for _, monsterName in ipairs(task.monsters) do
		task.monsterLookup[monsterName:lower()] = true
	end

	task.rewards = task.rewards or tierRewards[task.tier]

	for _, keyword in ipairs(task.keywords) do
		taskKeywordLookup[keyword:lower()] = taskId
	end
end

-- =========================================================
-- PLAYER DATA
-- =========================================================

local function getTaskKV(player)
	return player:kv():scoped(TASK_KV_SCOPE)
end

local function getSlotTaskIdKey(slot)
	return string.format("slot-%d-task-id", slot)
end

local function getSlotKillCountKey(slot)
	return string.format("slot-%d-kill-count", slot)
end

local function migrateLegacyTaskData(player)
	local kv = getTaskKV(player)
	local currentVersion = kv:get("multi-task-data-version") or 0

	if currentVersion >= MULTI_TASK_DATA_VERSION then
		return
	end

	local legacyTaskId = kv:get("task-id") or 0
	local legacyKillCount = kv:get("kill-count") or 0
	local migratedTaskId = legacyTaskIdMap[legacyTaskId]
	local firstSlotTaskId = kv:get(getSlotTaskIdKey(1)) or 0

	if migratedTaskId and tasks[migratedTaskId] and firstSlotTaskId == 0 then
		local migratedTask = tasks[migratedTaskId]
		local migratedKills = math.min(math.max(legacyKillCount, 0), migratedTask.requiredKills)

		kv:set(getSlotTaskIdKey(1), migratedTaskId)
		kv:set(getSlotKillCountKey(1), migratedKills)
	end

	-- Retire the former single-task keys after migration.
	kv:set("task-id", 0)
	kv:set("kill-count", 0)
	kv:set("multi-task-data-version", MULTI_TASK_DATA_VERSION)
end

local function getActiveTasks(player)
	migrateLegacyTaskData(player)

	local kv = getTaskKV(player)
	local activeTasks = {}

	for slot = 1, MAX_ACTIVE_TASKS do
		local taskId = kv:get(getSlotTaskIdKey(slot)) or 0
		local task = tasks[taskId]

		if task then
			local kills = kv:get(getSlotKillCountKey(slot)) or 0
			kills = math.min(math.max(kills, 0), task.requiredKills)

			activeTasks[#activeTasks + 1] = {
				slot = slot,
				taskId = taskId,
				task = task,
				kills = kills,
			}
		elseif taskId ~= 0 then
			kv:set(getSlotTaskIdKey(slot), 0)
			kv:set(getSlotKillCountKey(slot), 0)
		end
	end

	return activeTasks
end

local function findActiveTaskById(player, taskId)
	for _, activeTask in ipairs(getActiveTasks(player)) do
		if activeTask.taskId == taskId then
			return activeTask
		end
	end

	return nil
end

local function addActiveTask(player, taskId)
	migrateLegacyTaskData(player)

	local kv = getTaskKV(player)

	for slot = 1, MAX_ACTIVE_TASKS do
		local currentTaskId = kv:get(getSlotTaskIdKey(slot)) or 0

		if currentTaskId == 0 then
			kv:set(getSlotTaskIdKey(slot), taskId)
			kv:set(getSlotKillCountKey(slot), 0)
			return slot
		end
	end

	return nil
end

local function setKillCount(player, slot, count)
	getTaskKV(player):set(getSlotKillCountKey(slot), count)
end

local function resetTaskSlot(player, slot)
	local kv = getTaskKV(player)
	kv:set(getSlotTaskIdKey(slot), 0)
	kv:set(getSlotKillCountKey(slot), 0)
end

local function getTaskCompletionKey(taskId)
	return string.format("completed-task-%d", taskId)
end

local function getCompletionRewardItemKey(index)
	return string.format("completion-reward-item-%d", index)
end

local function markTaskCompleted(player, taskId)
	getTaskKV(player):set(getTaskCompletionKey(taskId), 1)
end

local function getCompletedTaskCount(player)
	local kv = getTaskKV(player)
	local completedCount = 0

	for taskId = 1, #tasks do
		if (kv:get(getTaskCompletionKey(taskId)) or 0) == 1 then
			completedCount = completedCount + 1
		end
	end

	return completedCount
end

local function hasCompletedAllTasks(player)
	return getCompletedTaskCount(player) >= #tasks
end

local function hasClaimedCompletionReward(player)
	return (getTaskKV(player):get("completion-reward-claimed") or 0) == 1
end

-- =========================================================
-- TEXT HELPERS
-- =========================================================

local function normalizeText(text)
	text = text:lower()
	text = text:gsub("[{}]", "")
	text = text:gsub("^%s+", "")
	text = text:gsub("%s+$", "")
	text = text:gsub("%s+", " ")
	return text
end

local function getItemsRewardText(task)
	local parts = {}

	for _, rewardItem in ipairs(task.rewards.items or {}) do
		parts[#parts + 1] = string.format(
			"%dx %s",
			rewardItem.count,
			rewardItem.name or ("item " .. rewardItem.id)
		)
	end

	if #parts == 0 then
		return "no items"
	end

	return table.concat(parts, ", ")
end

local function getRewardText(task)
	return string.format(
		"%d experience, %d gold and %s",
		task.rewards.experience or 0,
		task.rewards.gold or 0,
		getItemsRewardText(task)
	)
end

local function getTaskListText(tier)
	local parts = {}

	for _, task in ipairs(tasks) do
		if task.tier == tier then
			parts[#parts + 1] = string.format(
				"{%s} (%d kills)",
				task.keyword,
				task.requiredKills
			)
		end
	end

	return string.format(
		"Nivel %d: %s. Say the exact task name to accept it.",
		tier,
		table.concat(parts, ", ")
	)
end

local function getTierFromMessage(message)
	local normalized = normalizeText(message)

	local tierAliases = {
		["nivel 1"] = 1,
		["nivel1"] = 1,
		["nivel 2"] = 2,
		["nivel2"] = 2,
		["nivel 3"] = 3,
		["nivel3"] = 3,
		["nivel 4"] = 4,
		["nivel4"] = 4,
	}

	return tierAliases[normalized]
end

local function getProgressText(activeTasks)
	local parts = {}

	for _, activeTask in ipairs(activeTasks) do
		parts[#parts + 1] = string.format(
			"Slot %d: %s %d/%d",
			activeTask.slot,
			activeTask.task.name,
			activeTask.kills,
			activeTask.task.requiredKills
		)
	end

	return table.concat(parts, " | ")
end

local function getCompletionProgressText(player)
	local completedCount = getCompletedTaskCount(player)
	local text = string.format("Overall completion: %d/%d unique tasks.", completedCount, #tasks)

	if completedCount >= #tasks then
		if hasClaimedCompletionReward(player) then
			text = text .. " Final reward already claimed."
		else
			text = text .. " Final reward unlocked; say {reward}."
		end
	end

	return text
end

-- =========================================================
-- MONSTER DEATH EVENT
-- =========================================================

local taskDeathEvent = CreatureEvent(TASK_DEATH_EVENT)

function taskDeathEvent.onDeath(
	creature,
	corpse,
	killer,
	mostDamageKiller,
	lastHitUnjustified,
	mostDamageUnjustified
)
	if not creature or not creature:isMonster() then
		return true
	end

	-- Summoned monsters never count as task kills.
	if creature:getMaster() then
		return true
	end

	-- The player who lands the final hit receives the progress.
	local player = nil

	if killer then
		if killer:isPlayer() then
			player = killer
		else
			local master = killer:getMaster()

			if master and master:isPlayer() then
				player = master
			end
		end
	end

	if not player then
		return true
	end

	local activeTasks = getActiveTasks(player)
	if #activeTasks == 0 then
		return true
	end

	local monsterName = creature:getName():lower()

	for _, activeTask in ipairs(activeTasks) do
		local task = activeTask.task

		if task.monsterLookup[monsterName] and activeTask.kills < task.requiredKills then
			local currentKills = math.min(activeTask.kills + 1, task.requiredKills)
			setKillCount(player, activeTask.slot, currentKills)

			if currentKills >= task.requiredKills then
				player:sendTextMessage(
					MESSAGE_EVENT_ADVANCE,
					string.format(
						"Task complete: %s. Progress: %d/%d. Return to Hunt Master and ask for your reward.",
						task.name,
						currentKills,
						task.requiredKills
					)
				)
			else
				local remainingKills = task.requiredKills - currentKills

				player:sendTextMessage(
					MESSAGE_EVENT_ADVANCE,
					string.format(
						"Task %s: %d/%d. %d remaining.",
						task.name,
						currentKills,
						task.requiredKills,
						remainingKills
					)
				)
			end
		end
	end

	return true
end

taskDeathEvent:register()

-- Register the death event only on monsters used by this task system.
local registeredTaskMonsters = {}

for _, task in ipairs(tasks) do
	for _, monsterName in ipairs(task.monsters) do
		local normalizedName = monsterName:lower()

		if not registeredTaskMonsters[normalizedName] then
			local monsterType = MonsterType(monsterName)

			if monsterType then
				monsterType:registerEvent(TASK_DEATH_EVENT)
				registeredTaskMonsters[normalizedName] = true
			else
				logger.warn(
					"[Hunt Master] MonsterType '{}' was not found and will not count for tasks.",
					monsterName
				)
			end
		end
	end
end

-- =========================================================
-- REWARD DELIVERY
-- =========================================================

local function giveTaskReward(player, task)
	for _, rewardItem in ipairs(task.rewards.items or {}) do
		local addedItem = player:addItem(rewardItem.id, rewardItem.count, true)

		if not addedItem then
			return false, string.format(
				"I could not give you %dx %s. Free some room or capacity and ask for your reward again.",
				rewardItem.count,
				rewardItem.name or ("item " .. rewardItem.id)
			)
		end
	end

	if (task.rewards.experience or 0) > 0 then
		player:addExperience(task.rewards.experience, true)
	end

	if (task.rewards.gold or 0) > 0 then
		player:addMoney(task.rewards.gold)
	end

	return true
end

local function getCompletionRewardText()
	local parts = {}

	for _, rewardItem in ipairs(completionReward) do
		parts[#parts + 1] = string.format("%dx %s", rewardItem.count, rewardItem.name)
	end

	return table.concat(parts, ", ")
end

local function giveCompletionReward(player)
	if hasClaimedCompletionReward(player) then
		return false, nil
	end

	if not hasCompletedAllTasks(player) then
		return false, nil
	end

	local kv = getTaskKV(player)
	local deliveredAnyItem = false

	for index, rewardItem in ipairs(completionReward) do
		local itemKey = getCompletionRewardItemKey(index)

		if (kv:get(itemKey) or 0) ~= 1 then
			local addedItem = player:addItem(rewardItem.id, rewardItem.count, true)

			if not addedItem then
				local prefix = deliveredAnyItem and "Some final-reward items were delivered, but " or ""

				return false,
					prefix
						.. string.format(
							"I could not give you %dx %s. Free some room or capacity and say {reward} again. Items already delivered will not be repeated.",
							rewardItem.count,
							rewardItem.name
						)
			end

			kv:set(itemKey, 1)
			deliveredAnyItem = true
		end
	end

	kv:set("completion-reward-claimed", 1)

	return true,
		"Congratulations! You completed every task and received the final reward: "
			.. getCompletionRewardText()
			.. "."
end

-- =========================================================
-- NPC
-- =========================================================

local npcName = "Hunt Master"
local npcType = Game.createNpcType(npcName)
local npcConfig = {}

npcConfig.name = npcName
npcConfig.description = "a Hunt Master"

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 1500
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 129,
	lookHead = 95,
	lookBody = 40,
	lookLegs = 40,
	lookFeet = 57,
	lookAddons = 1,
}

npcConfig.voices = {
	interval = 15000,
	chance = 20,
	{ text = "Are you looking for a hunting task?" },
	{ text = "I have rewards for brave hunters." },
}

npcConfig.flags = {
	floorchange = false,
	profession = "normal",
}

npcConfig.speechBubble = SPEECHBUBBLE_NORMAL

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, player)
	npcHandler:onCloseChannel(npc, player)
end

local function greetCallback(npc, player)
	npcHandler:setMessage(
		MESSAGE_GREET,
		"Hello |PLAYERNAME|. Ask me about {tasks}. You may keep up to three tasks active. Complete every unique task to earn a special final reward. You can also say {progress}, {reward}, or cancel followed by a task name."
	)
	return true
end

local function creatureSayCallback(npc, player, type, message)
	if not npcHandler:checkInteraction(npc, player) then
		return false
	end

	local normalizedMessage = normalizeText(message)
	local activeTasks = getActiveTasks(player)

	if normalizedMessage == "task"
		or normalizedMessage == "tasks"
		or normalizedMessage == "task list"
		or normalizedMessage == "list"
		or normalizedMessage == "tiers"
	then
		npcHandler:say(
			string.format(
				"Tasks are divided into {nivel 1}, {nivel 2}, {nivel 3}, and {nivel 4}. You currently have %d/%d active tasks.",
				#activeTasks,
				MAX_ACTIVE_TASKS
			),
			npc,
			player
		)
		return true
	end

	local selectedTier = getTierFromMessage(message)
	if selectedTier then
		npcHandler:say(getTaskListText(selectedTier), npc, player)
		return true
	end

	if normalizedMessage == "progress" or normalizedMessage == "status" then
		if #activeTasks == 0 then
			npcHandler:say(
				"You do not have an active task. Ask me about {tasks}. " .. getCompletionProgressText(player),
				npc,
				player
			)
		else
			npcHandler:say(
				"Your active tasks: "
					.. getProgressText(activeTasks)
					.. ". "
					.. getCompletionProgressText(player),
				npc,
				player
			)
		end

		return true
	end

	if normalizedMessage == "reward" or normalizedMessage == "report" then
		local rewardedTasks = {}
		local rewardFailures = {}

		for _, activeTask in ipairs(activeTasks) do
			if activeTask.kills >= activeTask.task.requiredKills then
				local success, errorMessage = giveTaskReward(player, activeTask.task)

				if success then
					markTaskCompleted(player, activeTask.taskId)
					resetTaskSlot(player, activeTask.slot)
					rewardedTasks[#rewardedTasks + 1] = activeTask.task.name
				else
					rewardFailures[#rewardFailures + 1] = errorMessage
				end
			end
		end

		local completionRewardSuccess, completionRewardMessage = giveCompletionReward(player)
		local messages = {}

		if #rewardedTasks > 0 then
			messages[#messages + 1] = "You claimed the reward for: " .. table.concat(rewardedTasks, ", ") .. "."
		end

		if #rewardFailures > 0 then
			messages[#messages + 1] = table.concat(rewardFailures, " ")
		end

		if completionRewardMessage then
			messages[#messages + 1] = completionRewardMessage
		end

		if #messages == 0 then
			if #activeTasks == 0 then
				npcHandler:say(
					"You do not have an active task. " .. getCompletionProgressText(player),
					npc,
					player
				)
			else
				npcHandler:say(
					"None of your tasks is complete yet. Your progress: "
						.. getProgressText(activeTasks)
						.. ". "
						.. getCompletionProgressText(player),
					npc,
					player
				)
			end

			return true
		end

		if #rewardedTasks > 0 or completionRewardSuccess then
			player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
		end

		local remainingActiveTasks = getActiveTasks(player)
		messages[#messages + 1] = string.format(
			"You now have %d/%d active tasks.",
			#remainingActiveTasks,
			MAX_ACTIVE_TASKS
		)
		messages[#messages + 1] = getCompletionProgressText(player)

		npcHandler:say(table.concat(messages, " "), npc, player)
		return true
	end

	if normalizedMessage == "cancel" then
		if #activeTasks == 0 then
			npcHandler:say("You do not have an active task to cancel.", npc, player)
		else
			local names = {}

			for _, activeTask in ipairs(activeTasks) do
				names[#names + 1] = "{" .. activeTask.task.keyword .. "}"
			end

			npcHandler:say(
				"Say cancel followed by the exact task name. Active tasks: " .. table.concat(names, ", ") .. ".",
				npc,
				player
			)
		end

		return true
	end

	local cancelTarget = normalizedMessage:match("^cancel%s+(.+)$")
	if cancelTarget then
		local cancelTaskId = taskKeywordLookup[cancelTarget]

		if not cancelTaskId then
			npcHandler:say("I could not find that task. Use {progress} to see your active tasks.", npc, player)
			return true
		end

		local activeTask = findActiveTaskById(player, cancelTaskId)
		if not activeTask then
			npcHandler:say("That task is not currently active.", npc, player)
			return true
		end

		resetTaskSlot(player, activeTask.slot)
		npcHandler:say(
			string.format(
				"You cancelled the %s task. You now have %d/%d active tasks.",
				activeTask.task.name,
				#getActiveTasks(player),
				MAX_ACTIVE_TASKS
			),
			npc,
			player
		)

		return true
	end

	-- Exact selection prevents conflicts such as "dragon" and "dragon lord".
	local selectedTaskId = taskKeywordLookup[normalizedMessage]
	if selectedTaskId then
		local selectedTask = tasks[selectedTaskId]

		if findActiveTaskById(player, selectedTaskId) then
			npcHandler:say("The " .. selectedTask.name .. " task is already active.", npc, player)
			return true
		end

		activeTasks = getActiveTasks(player)
		if #activeTasks >= MAX_ACTIVE_TASKS then
			npcHandler:say(
				"You already have three active tasks. Complete one or cancel one before accepting another.",
				npc,
				player
			)
			return true
		end

		local slot = addActiveTask(player, selectedTaskId)
		if not slot then
			npcHandler:say("I could not assign the task. Please try again.", npc, player)
			return true
		end

		npcHandler:say(
			string.format(
				"Task accepted in slot %d: kill %d %s. Your reward will be %s. You now have %d/%d active tasks.",
				slot,
				selectedTask.requiredKills,
				selectedTask.name,
				getRewardText(selectedTask),
				#getActiveTasks(player),
				MAX_ACTIVE_TASKS
			),
			npc,
			player
		)

		return true
	end

	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:setMessage(MESSAGE_FAREWELL, "Good hunting.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Return when you are ready to hunt.")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)