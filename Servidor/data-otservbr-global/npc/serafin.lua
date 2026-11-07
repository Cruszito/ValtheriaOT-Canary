local internalNpcName = "Serafin"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 129,
	lookHead = 96,
	lookBody = 123,
	lookLegs = 86,
	lookFeet = 98,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

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

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

local BloodBrothers = Storage.Quest.U8_4.BloodBrothers
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if message == "cookie" then
		if player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission02) == 1 and player:getItemCount(8199) > 0 and player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Serafin) < 0 then
			npcHandler:say("Oh, no I don't sell cookies. Or, do you mean you'd like to give me one?", npc, creature)
			npcHandler:setTopic(playerId, 1)
		else
			npcHandler:say("It'd be better for you to leave now.", npc, creature)
		end
	elseif message == "yes" then
		if npcHandler:getTopic(playerId) == 1 and player:removeItem(8199, 1) then -- garlic cookie
			npcHandler:say("COUGH?! What kind of a mean trick is that? Get out of my shop!", npc, creature)
			player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Serafin, 1)
			npcHandler:setTopic(playerId, 0)
		end
	end
end
--Basic
keywordHandler:addKeyword({ "alori mort" }, StdModule.say, { npcHandler = npcHandler, text = "There's something about these words which makes me feel awkward. Or maybe it's you who causes that feeling. You better get lost." }, function(player)
	return player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission03) == 1
end)

npcHandler:setMessage(MESSAGE_GREET, "Welcome to my fruit and vegetable store, |PLAYERNAME|! Ask me for a {trade} if you'd like to see my wares.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	-- Toekens - 
	{ itemName = "gold token", clientId = 22721, buy = 100000 },
	{ itemName = "silver token", clientId = 22516, buy = 50000 },

	{ itemName = "aubergine", clientId = 11460, buy = 8 },
	{ itemName = "banana", clientId = 3587, buy = 5 },
	{ itemName = "blueberry", clientId = 3588, buy = 1 },
	{ itemName = "carrot", clientId = 3595, buy = 3 },
	{ itemName = "cherry", clientId = 3590, buy = 1 },
	{ itemName = "corncob", clientId = 3597, buy = 3 },
	{ itemName = "grapes", clientId = 3592, buy = 3 },
	{ itemName = "juice squeezer", clientId = 5865, buy = 100 },
	{ itemName = "lemon", clientId = 8013, buy = 3 },
	{ itemName = "mango", clientId = 5096, buy = 10 },
	{ itemName = "melon", clientId = 3593, buy = 10 },
	{ itemName = "orange", clientId = 3586, buy = 10 },
	{ itemName = "potato", clientId = 8010, buy = 4 },
	{ itemName = "pumpkin", clientId = 3594, buy = 10 },
	{ itemName = "strawberry", clientId = 3591, buy = 2 },
	{ itemName = "white mushroom", clientId = 3723, buy = 10 },
	{ itemName = "blueberry cupcake", clientId = 28484, buy = 1000000 },
	{ itemName = "strawberry cupcake", clientId = 28485, buy = 1000000 },
	{ itemName = "lemon cupcake", clientId = 28486, buy = 1000000 },
	{ itemName = "consecrated beef", clientId = 29415, buy = 1000000 },
	{ itemName = "coconut shrimp bake", clientId = 11584, buy = 1000000 },
	{ itemName = "tropical marinated tiger", clientId = 29410, buy = 1000000 },
	{ itemName = "rotworm stew", clientId = 9079, buy = 1000000 },
	{ itemName = "roasted dragon wings", clientId = 9081, buy = 1000000 },
	{ itemName = "veggie casserole", clientId = 9084, buy = 1000000 },
	-- Intricate Scrolls - 
	{ itemName = "intricate bash scroll", clientId = 51724, buy = 25000 },
	{ itemName = "intricate blockade scroll", clientId = 51725, buy = 25000 },
	{ itemName = "intricate chop scroll", clientId = 51726, buy = 25000 },
	{ itemName = "intricate cloud fabric scroll", clientId = 51727, buy = 25000 },
	{ itemName = "intricate demon presence scroll", clientId = 51728, buy = 25000 },
	{ itemName = "intricate dragon hide scroll", clientId = 51729, buy = 25000 },
	{ itemName = "intricate electrify scroll", clientId = 51730, buy = 25000 },
	{ itemName = "intricate epiphany scroll", clientId = 51731, buy = 25000 },
	{ itemName = "intricate featherweight scroll", clientId = 51732, buy = 25000 },
	{ itemName = "intricate frost scroll", clientId = 51733, buy = 25000 },
	{ itemName = "intricate lich shroud scroll", clientId = 51734, buy = 25000 },
	{ itemName = "intricate precision scroll", clientId = 51735, buy = 25000 },
	{ itemName = "intricate punch scroll", clientId = 51736, buy = 25000 },
	{ itemName = "intricate quara scale scroll", clientId = 51737, buy = 25000 },
	{ itemName = "intricate reap scroll", clientId = 51738, buy = 25000 },
	{ itemName = "intricate scorch scroll", clientId = 51739, buy = 25000 },
	{ itemName = "intricate slash scroll", clientId = 51740, buy = 25000 },
	{ itemName = "intricate snake skin scroll", clientId = 51741, buy = 25000 },
	{ itemName = "intricate strike scroll", clientId = 51742, buy = 25000 },
	{ itemName = "intricate swiftness scroll", clientId = 51743, buy = 25000 },
	{ itemName = "intricate vampirism scroll", clientId = 51744, buy = 25000 },
	{ itemName = "intricate venom scroll", clientId = 51745, buy = 25000 },
	{ itemName = "intricate vibrancy scroll", clientId = 51746, buy = 25000 },
	{ itemName = "intricate void scroll", clientId = 51747, buy = 25000 },

	-- Powerful Scrolls - 
	{ itemName = "magic shield potion", clientId = 35563, buy = 10000 },
	{ itemName = "powerful bash scroll", clientId = 51444, buy = 200000 },
	{ itemName = "powerful blockade scroll", clientId = 51445, buy = 200000 },
	{ itemName = "powerful chop scroll", clientId = 51446, buy = 200000 },
	{ itemName = "powerful cloud fabric scroll", clientId = 51447, buy = 200000 },
	{ itemName = "powerful demon presence scroll", clientId = 51448, buy = 200000 },
	{ itemName = "powerful dragon hide scroll", clientId = 51449, buy = 200000 },
	{ itemName = "powerful electrify scroll", clientId = 51450, buy = 200000 },
	{ itemName = "powerful epiphany scroll", clientId = 51451, buy = 200000 },
	{ itemName = "powerful featherweight scroll", clientId = 51452, buy = 200000 },
	{ itemName = "powerful frost scroll", clientId = 51453, buy = 200000 },
	{ itemName = "powerful lich shroud scroll", clientId = 51454, buy = 200000 },
	{ itemName = "powerful precision scroll", clientId = 51455, buy = 200000 },
	{ itemName = "powerful punch scroll", clientId = 51456, buy = 200000 },
	{ itemName = "powerful quara scale scroll", clientId = 51457, buy = 200000 },
	{ itemName = "powerful reap scroll", clientId = 51458, buy = 200000 },
	{ itemName = "powerful scorch scroll", clientId = 51459, buy = 200000 },
	{ itemName = "powerful slash scroll", clientId = 51460, buy = 200000 },
	{ itemName = "powerful snake skin scroll", clientId = 51461, buy = 200000 },
	{ itemName = "powerful strike scroll", clientId = 51462, buy = 200000 },
	{ itemName = "powerful swiftness scroll", clientId = 51463, buy = 200000 },
	{ itemName = "powerful vampirism scroll", clientId = 51464, buy = 200000 },
	{ itemName = "powerful venom scroll", clientId = 51465, buy = 200000 },
	{ itemName = "powerful vibrancy scroll", clientId = 51466, buy = 200000 },
	{ itemName = "powerful void scroll", clientId = 51467, buy = 200000 },


}
-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end
-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

-- Dialog options (interactive icons in the NPC conversation window)
-- Crystal only: npcType:addDialogOptions("trade", "bye") -- desactivado para Canary
npcType:register(npcConfig)
