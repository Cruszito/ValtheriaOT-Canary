local itemDollIds = { 6579, 8154 }

local outfits = {
	{ 136, 128, "Citizen" },
	{ 137, 129, "Hunter" },
	{ 139, 131, "Knight" },
	{ 140, 132, "Nobleman" },
	{ 142, 134, "Warrior" },
	{ 147, 143, "Barbarian" },
	{ 148, 144, "Druid" },
	{ 149, 145, "Wizard" },
	{ 150, 146, "Oriental" },
	{ 155, 151, "Pirate" },
	{ 156, 152, "Assassin" },
	{ 157, 153, "Beggar" },
	{ 158, 154, "Shaman" },
	{ 252, 251, "Norseman" },
	{ 269, 268, "Nightmare" },
	{ 270, 273, "Jester" },
	{ 278, 279, "Brotherhood" },
	{ 288, 289, "Demonhunter" },
	{ 324, 325, "Yalaharian" },
	{ 336, 335, "Wayfarer" },
	{ 366, 367, "Warmaster" },
	{ 329, 328, "Wedding" },
	{ 430, 431, "Afflicted" },
	{ 432, 433, "Elementalist" },
	{ 463, 464, "Deepling" },
	{ 465, 466, "Insectoid" },
	{ 471, 472, "Entrepreneur" },
	{ 512, 513, "Crystal Warlord" },
	{ 516, 514, "Soil Guardian" },
	{ 541, 542, "Demon" },
	{ 574, 575, "Cave Explorer" },
	{ 578, 579, "Dream Warden" },
	{ 618, 619, "Glooth Engineer" },
	{ 620, 621, "Jungle Explorer" },
	{ 632, 633, "Chaos Acolyte" },
	{ 634, 635, "Death Herald" },
	{ 636, 637, "Ranger" },
	{ 664, 665, "Ceremonial Garb" },
	{ 666, 667, "Puppeteer" },
	{ 683, 684, "Spirit Caller" },
	{ 694, 695, "Evoker" },
	{ 696, 697, "Conjurer" },
}

local randOutfit = Action("RandomOutfitFullAddon")

local function hasFullAddon(player, outfit)
	-- Tu lista: [1] femenino, [2] masculino
	local lookType

	if player:getSex() == PLAYERSEX_FEMALE then
		lookType = outfit[1]
	else
		lookType = outfit[2]
	end

	-- 3 significa ambos addons: 1 + 2
	return player:hasOutfit(lookType, 3)
end

local function getAvailableOutfits(player)
	local availableOutfits = {}

	for _, outfit in ipairs(outfits) do
		if not hasFullAddon(player, outfit) then
			table.insert(availableOutfits, outfit)
		end
	end

	return availableOutfits
end

function randOutfit.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local availableOutfits = getAvailableOutfits(player)

	if #availableOutfits == 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You already have all available full addons.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local outfit = availableOutfits[math.random(1, #availableOutfits)]

	-- Dar outfit base masculino y femenino
	player:addOutfit(outfit[1])
	player:addOutfit(outfit[2])

	-- Dar addon full masculino
	player:addOutfitAddon(outfit[1], 1)
	player:addOutfitAddon(outfit[1], 2)

	-- Dar addon full femenino
	player:addOutfitAddon(outfit[2], 1)
	player:addOutfitAddon(outfit[2], 2)

	player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)

	player:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		string.format("You received the full %s outfit addons!", outfit[3])
	)

	item:remove(1)
	return true
end

for _, itemId in ipairs(itemDollIds) do
	randOutfit:id(itemId)
end

randOutfit:register()