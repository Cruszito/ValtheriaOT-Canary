local internalNpcName = "Jorge"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 159,
	lookHead = 38,
	lookBody = 77,
	lookLegs = 78,
	lookFeet = 94,
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

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

local function onAddFocus(npc, creature)
	local playerId = creature:getId()
end

local function onReleaseFocus(npc, creature)
	local playerId = creature:getId()
end

local items = {

}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- Implementing the "souvenir" message interaction
	if MsgContains(message, "souvenir") then
		npcHandler:say({
			"In this category I can offer you a Norseman doll, an abacus, a key of numerous locks, a friendship amulet, a mexcalibur sword, an orc shredder, a frozen heart, a phoenix statue, a dragon eye and a noble sword. Or: ...",
			"A hand puppet, a music box, an encyclopedia, a Durin doll, a medusa skull, a newspaper, a bag of spices or an Exhiti imortus. ...",
			"A mathmaster shield, a draken doll, an emblem, a crimson doll, an old radio, a bookworm doll, a golden falcon and an assassin doll. ...",
			"A dragon goblet, a pigeon trophy, a loremaster doll and a jade amulet. ...",
			"All listed souvenirs are at 20 silver raid tokens each. Which one of them do you want?",
		}, npc, creature)
		npcHandler:setTopic(playerId, 1)
		return true
	end

	-- Checking if the player responded with an item name after "souvenir"
	if npcHandler:getTopic(playerId) == 1 then
		for i = 1, #items do
			if MsgContains(message, items[i].name) then
				if getPlayerItemCount(creature, 19083) >= 20 then
					doPlayerRemoveItem(creature, 19083, 20)
					doPlayerAddItem(creature, items[i].id, 1)
					npcHandler:say("You just swapped 20 silver raid tokens for 1 " .. items[i].name .. ".", npc, creature)
				else
					npcHandler:say("I'm sorry, I need at least 20 silver tokens for that. Please come back when you have them.", npc, creature)
				end
				npcHandler:setTopic(playerId, 0) -- Reset topic after processing
				return true
			end
		end
	end

	return true
end

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
