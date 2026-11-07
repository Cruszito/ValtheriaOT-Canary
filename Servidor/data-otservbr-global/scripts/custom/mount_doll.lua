local mountDoll = Action()

local config = {
	itemId = 10294, -- stuffed toad
	removeOnUse = true,

	-- Lista de monturas posibles
	-- Ajusta/agrega aquí los IDs de monturas de tu servidor
	mounts = {
		{ id = 1, name = "Widow Queen" },
		{ id = 2, name = "Racing Bird" },
		{ id = 3, name = "War Bear" },
		{ id = 4, name = "Black Sheep" },
		{ id = 5, name = "Midnight Panther" },
		{ id = 6, name = "Draptor" },
		{ id = 7, name = "Titanica" },
		{ id = 8, name = "Tin Lizzard" },
		{ id = 9, name = "Blazebringer" },
		{ id = 10, name = "Rapid Boar" },
		{ id = 11, name = "Stampor" },
		{ id = 12, name = "Undead Cavebear" },
		{ id = 13, name = "Donkey" },
		{ id = 14, name = "Tiger Slug" },
		{ id = 15, name = "Uniwheel" },
		{ id = 16, name = "Crystal Wolf" },
		{ id = 17, name = "War Horse" },
		{ id = 18, name = "Kingly Deer" },
		{ id = 19, name = "Tamed Panda" },
		{ id = 20, name = "Dromedary" },
		{ id = 21, name = "Scorpion King" },
		{ id = 27, name = "Lady Bug" },
		{ id = 28, name = "Manta Ray" },
		{ id = 29, name = "Ironblight" },
		{ id = 30, name = "Magma Crawler" },
		{ id = 31, name = "Dragonling" },
		{ id = 32, name = "Gnarlhound" },
		{ id = 35, name = "Water Buffalo" },
		{ id = 38, name = "Ursagrodon" },
		{ id = 39, name = "The Hellgrip" },
		{ id = 40, name = "Noble Lion" },
		{ id = 42, name = "Shock Head" },
		{ id = 43, name = "Walker" },
		{ id = 71, name = "Glooth Glider" },
		{ id = 87, name = "Rift Runner" },
		{ id = 94, name = "Sparkion" },
		{ id = 98, name = "Neon Sparkid" },
		{ id = 99, name = "Vortexion" },
		{ id = 106, name = "Stone Rhino" },
		{ id = 119, name = "Mole" },
		{ id = 126, name = "Fleeting Knowledge" },
		{ id = 130, name = "Lacewing Moth" },
		{ id = 131, name = "Hibernal Moth" },
		{ id = 132, name = "Cold Percht Sleigh" },
		{ id = 133, name = "Bright Percht Sleigh" },
		{ id = 134, name = "Dark Percht Sleigh" },
		{ id = 144, name = "Gryphon" },
		{ id = 147, name = "Cold Percht Sleigh Variant" },
		{ id = 148, name = "Bright Percht Sleigh Variant" },
		{ id = 149, name = "Dark Percht Sleigh Variant" },
		{ id = 150, name = "Cold Percht Sleigh Final" },
		{ id = 151, name = "Bright Percht Sleigh Final" },
		{ id = 152, name = "Dark Percht Sleigh Final" },
		{ id = 156, name = "Blue Rolling Barrel" },
		{ id = 157, name = "Red Rolling Barrel" },
		{ id = 158, name = "Green Rolling Barrel" },
		{ id = 162, name = "Haze" },
		{ id = 163, name = "Antelope" },
		{ id = 174, name = "White Lion" },
		{ id = 175, name = "Krakoloss" },
		{ id = 182, name = "Phant" },
		{ id = 183, name = "Shellodon" },
		{ id = 184, name = "Singeing Steed" },
		{ id = 201, name = "Giant Beaver" },
		{ id = 202, name = "Noxious Ripptor" },
		{ id = 206, name = "Mutated Abomination" },
		{ id = 222, name = "Mystic Jaguar" },
		{ id = 227, name = "Pegasus" },
		{ id = 232, name = "Primal Demonosaur" },
		{ id = 238, name = "Hellish Demonosaur" },
		{ id = 239, name = "Ancient Demonosaur" },
		{ id = 243, name = "White Gloom Maw" },
		{ id = 244, name = "Gloom Maw" },
		{ id = 246, name = "Battlefrazzle" },
		{ id = 247, name = "Tidal Seawater Predator" },
		{ id = 248, name = "Ashen Coast Predator" },
		{ id = 249, name = "Crimson Bay Predator" },
	},
}

local function getAvailableMounts(player)
	local available = {}

	for _, mount in ipairs(config.mounts) do
		if not player:hasMount(mount.id) then
			table.insert(available, mount)
		end
	end

	return available
end

function mountDoll.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local availableMounts = getAvailableMounts(player)

	if #availableMounts == 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You already have all available mounts from this doll.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local reward = availableMounts[math.random(1, #availableMounts)]

	player:addMount(reward.id)

	player:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		"You received the " .. reward.name .. " mount."
	)

	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	if config.removeOnUse then
		item:remove(1)
	end

	return true
end

mountDoll:id(config.itemId)
mountDoll:register()