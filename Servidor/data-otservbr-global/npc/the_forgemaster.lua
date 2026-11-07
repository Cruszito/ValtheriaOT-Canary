local internalNpcName = "The Forgemaster"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 150
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 247,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "I'll be doing my job, same as ever. Just lay out your arms." },
	{ text = "I knew you'd be back. Lay out your arms. Let's get to smithing." },
	{ text = "Ah, you, is it? I... didn't notice you there." },
}

-- Uses Canary's global storage table when it is available. The numeric
-- fallbacks keep this NPC self-contained when the quest storages have not
-- yet been added to data-global/lib/core/storages.lua.
local questlineStorage = 47973
local accessDoorStorage = 47975

if Storage
	and Storage.Quest
	and Storage.Quest.U14_10
	and Storage.Quest.U14_10.NoRestForTheWicked
then
	local quest = Storage.Quest.U14_10.NoRestForTheWicked
	if quest.ForgemasterDoor and quest.ForgemasterDoor.Questline then
		questlineStorage = quest.ForgemasterDoor.Questline
	end
	if quest.ForgeMaster and quest.ForgeMaster.AccessDoor then
		accessDoorStorage = quest.ForgeMaster.AccessDoor
	end
end

local forgeItems = {
	bow = { base = 49520, critical = 49858, life = 49859, mana = 49860 },
	crossbow = { base = 49522, critical = 49861, life = 49862, mana = 49863 },
	onehand_axe = { base = 49523, critical = 49864, life = 49865, mana = 49866 },
	twohand_axe = { base = 49524, critical = 49867, life = 49868, mana = 49869 },
	onehand_club = { base = 49525, critical = 49870, life = 49871, mana = 49872 },
	twohand_club = { base = 49526, critical = 49873, life = 49874, mana = 49875 },
	onehand_sword = { base = 49527, critical = 49876, life = 49877, mana = 49878 },
	twohand_sword = { base = 49530, critical = 49879, life = 49880, mana = 49881 },
	wand = { base = 49528, critical = 49882, life = 49883, mana = 49884 },
	rod = { base = 49529, critical = 49885, life = 49886, mana = 49887 },
	fist = { base = 50250, critical = 50251, life = 50252, mana = 50253 },
}

-- These amounts preserve the Crystal Server recipe supplied for migration.
local recipes = {
	critical = {
		{ id = 49892, count = 1 }, -- skin of Gralvalon
		{ id = 12541, count = 1 }, -- demonic finger
		{ id = 22728, count = 100 }, -- vexclaw talons
		{ id = 49894, count = 500 }, -- demonic matter
		{ id = 5954, count = 50 }, -- demon horns
		{ id = 6499, count = 350 }, -- demonic essences
		{ id = 6558, count = 750 }, -- flasks of demonic blood
	},
	life = {
		{ id = 49893, count = 1 }, -- skin of Malvaroth
		{ id = 9663, count = 100 }, -- pieces of dead brain
		{ id = 49894, count = 500 }, -- demonic matter
		{ id = 6558, count = 750 }, -- flasks of demonic blood
		{ id = 5906, count = 50 }, -- demon dust
	},
	mana = {
		{ id = 49891, count = 1 }, -- skin of Twisterror
		{ id = 22730, count = 100 }, -- grimeleech wings
		{ id = 49894, count = 500 }, -- demonic matter
		{ id = 6499, count = 750 }, -- demonic essences
		{ id = 9647, count = 200 }, -- demonic skeletal hands
	},
}

local recipeMessages = {
	critical = "You will need the base weapon, 1 skin of Gralvalon, 1 demonic finger, 100 vexclaw talons, 500 samples of demonic matter, 50 demon horns, 350 demonic essences and 750 flasks of demonic blood. Do you want to proceed, {yes}?",
	life = "You will need the base weapon, 1 skin of Malvaroth, 100 pieces of dead brain, 500 samples of demonic matter, 750 flasks of demonic blood and 50 samples of demon dust. Do you want to proceed, {yes}?",
	mana = "You will need the base weapon, 1 skin of Twisterror, 100 grimeleech wings, 500 samples of demonic matter, 750 demonic essences and 200 demonic skeletal hands. Do you want to proceed, {yes}?",
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

local selectedWeapon = {}
local selectedForge = {}

local function clearSelection(playerId)
	selectedWeapon[playerId] = nil
	selectedForge[playerId] = nil
end

local function resetConversation(playerId)
	clearSelection(playerId)
	npcHandler:setTopic(playerId, 0)
end

local function getItemName(itemId)
	local itemType = ItemType(itemId)
	local name = itemType and itemType:getName() or ""
	if name == "" then
		return "item " .. itemId
	end
	return name
end

local function buildRequirements(weaponKey, forgeType)
	local weaponConfig = forgeItems[weaponKey]
	local recipe = recipes[forgeType]
	if not weaponConfig or not recipe or not weaponConfig[forgeType] then
		return nil, nil
	end

	local requirements = {
		{ id = weaponConfig.base, count = 1 },
	}
	for _, requiredItem in ipairs(recipe) do
		requirements[#requirements + 1] = requiredItem
	end

	return requirements, weaponConfig[forgeType]
end

local function findMissingRequirement(player, requirements)
	for _, requiredItem in ipairs(requirements) do
		local owned = player:getItemCount(requiredItem.id)
		if owned < requiredItem.count then
			return requiredItem, requiredItem.count - owned
		end
	end
	return nil, 0
end

local function refundItems(player, removedItems)
	for _, removedItem in ipairs(removedItems) do
		player:addItem(removedItem.id, removedItem.count)
	end
end

local function craftWeapon(npc, player, playerId)
	local weaponKey = selectedWeapon[playerId]
	local forgeType = selectedForge[playerId]
	local requirements, forgedItemId = buildRequirements(weaponKey, forgeType)

	if not requirements then
		npcHandler:say("I could not identify that weapon and forging type. Please start again with {craft}.", npc, player)
		resetConversation(playerId)
		return true
	end

	local missingItem, missingCount = findMissingRequirement(player, requirements)
	if missingItem then
		npcHandler:say("You still need " .. missingCount .. "x " .. getItemName(missingItem.id) .. ".", npc, player)
		return true
	end

	local removedItems = {}
	for _, requiredItem in ipairs(requirements) do
		if not player:removeItem(requiredItem.id, requiredItem.count) then
			refundItems(player, removedItems)
			npcHandler:say("I could not take all the required materials. Nothing was forged and the removed items were returned.", npc, player)
			resetConversation(playerId)
			return true
		end
		removedItems[#removedItems + 1] = requiredItem
	end

	local forgedItem = player:addItem(forgedItemId, 1)
	if not forgedItem then
		refundItems(player, removedItems)
		npcHandler:say("You do not have enough room for the forged weapon. Your materials were returned.", npc, player)
		resetConversation(playerId)
		return true
	end

	npcHandler:say("Here you go: " .. getItemName(forgedItemId) .. ".", npc, player)
	resetConversation(playerId)
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local player = Player(creature)
	if not player then
		return false
	end

	local playerId = player:getId()
	local normalizedMessage = message:lower()
	local topic = npcHandler:getTopic(playerId)

	if MsgContains(normalizedMessage, "key") then
		if player:getStorageValue(questlineStorage) == 2 then
			player:setStorageValue(accessDoorStorage, 1)
			player:setStorageValue(questlineStorage, 3)
			npcHandler:say("You have proven yourself worthy. The door to the Forgemaster's chamber is now accessible.", npc, player)
		else
			npcHandler:say("You are not ready yet. Prove yourself worthy first.", npc, player)
		end
		return true
	end

	if MsgContains(normalizedMessage, "forge") then
		npcHandler:say("I can transform base Inferniarch weapons into rending, draining or siphoning versions. Say {craft} to begin.", npc, player)
		return true
	end

	if MsgContains(normalizedMessage, "craft") then
		clearSelection(playerId)
		npcHandler:say({
			"If you have the ingredients, I can channel the ancient demonic power of this place into {fist}s, {sword}s, {club}s, {axe}s, {bow}s, {crossbow}s, {wand}s and {rod}s.",
			"This is only possible for base Inferniarch equipment that has not been treated at the Exaltation Forge.",
		}, npc, player)
		npcHandler:setTopic(playerId, 1)
		return true
	end

	if topic == 1 and table.contains({ "sword", "club", "axe" }, normalizedMessage) then
		selectedWeapon[playerId] = normalizedMessage
		npcHandler:say("Do you want the {one-handed} or {two-handed} " .. normalizedMessage .. "?", npc, player)
		npcHandler:setTopic(playerId, 2)
		return true
	end

	if topic == 1 and table.contains({ "fist", "bow", "crossbow", "wand", "rod" }, normalizedMessage) then
		selectedWeapon[playerId] = normalizedMessage
		npcHandler:say("Do you want a {critical}, {life} or {mana} version of the Inferniarch " .. normalizedMessage .. "?", npc, player)
		npcHandler:setTopic(playerId, 3)
		return true
	end

	if topic == 2 then
		local weaponFamily = selectedWeapon[playerId]
		local handedness = nil
		if table.contains({ "one-handed", "one handed", "onehand", "onehand_" .. tostring(weaponFamily) }, normalizedMessage) then
			handedness = "onehand"
		elseif table.contains({ "two-handed", "two handed", "twohand", "twohand_" .. tostring(weaponFamily) }, normalizedMessage) then
			handedness = "twohand"
		end

		if handedness and table.contains({ "sword", "club", "axe" }, weaponFamily) then
			selectedWeapon[playerId] = handedness .. "_" .. weaponFamily
			npcHandler:say("Do you want a {critical}, {life} or {mana} version of that weapon?", npc, player)
			npcHandler:setTopic(playerId, 3)
			return true
		end
	end

	if topic == 3 and table.contains({ "critical", "life", "mana" }, normalizedMessage) then
		local weaponConfig = forgeItems[selectedWeapon[playerId]]
		if not weaponConfig or not weaponConfig[normalizedMessage] then
			npcHandler:say("That forging type is not available for the selected weapon.", npc, player)
			resetConversation(playerId)
			return true
		end

		selectedForge[playerId] = normalizedMessage
		npcHandler:say(recipeMessages[normalizedMessage], npc, player)
		npcHandler:setTopic(playerId, 4)
		return true
	end

	if topic == 4 then
		if MsgContains(normalizedMessage, "yes") then
			return craftWeapon(npc, player, playerId)
		elseif MsgContains(normalizedMessage, "no") then
			npcHandler:say("Alright. Come back if you change your mind.", npc, player)
			resetConversation(playerId)
			return true
		end
	end

	return true
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	local player = Player(creature)
	if player then
		clearSelection(player:getId())
	end
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	local player = Player(creature)
	if player then
		clearSelection(player:getId())
	end
	npcHandler:onCloseChannel(npc, creature)
end

npcHandler:setMessage(MESSAGE_GREET, "What brings you here this time? Do you want to {craft} a weapon in the forge?")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
