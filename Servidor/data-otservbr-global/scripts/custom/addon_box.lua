local config = {
	itemId = 55976,
	effect = CONST_ME_GIFT_WRAPS,

	outfits = {
		{
			name = "orochimaru",
			female = 2063,
			male = 2063,
			addons = 3
		},
		{
			name = "shisui",
			female = 2065,
			male = 2065,
			addons = 3
		},
		{
			name = "Naruto",
			female = 2066,
			male = 2066,
			addons = 3
		},
		{
			name = "Magin buu",
			female = 2081,
			male = 2081,
			addons = 3
		},
		{
			name = "Avatar",
			female = 2124,
			male = 2124,
			addons = 3
		},
		{
			name = "Gladiador",
			female = 2126,
			male = 2126,
			addons = 3
		},
		{
			name = "Manco",
			female = 2149,
			male = 2149,
			addons = 3
		},
		{
			name = "Toro Muu",
			female = 2156,
			male = 2156,
			addons = 3
		},
		{
			name = "Black Guardian",
			female = 2176,
			male = 2176,
			addons = 3
		},
		{
			name = "Harry Potter",
			female = 2372,
			male = 2372,
			addons = 3
		},
		{
			name = "Archer addon",
			female = 2385,
			male = 2385,
			addons = 3
		},
		{
			name = "Don Axe",
			female = 2431,
			male = 2431,
			addons = 3
		},
		{
			name = "Don Axe II",
			female = 2437,
			male = 2437,
			addons = 3
		},
		{
			name = "Drakula",
			female = 2396,
			male = 2396,
			addons = 3
		},
		{
			name = "Bob Esponja",
			female = 2395,
			male = 2395,
			addons = 3
		},
		{
			name = "Lord orochi",
			female = 2400,
			male = 2400,
			addons = 3
		},
		{
			name = "Akatsuki",
			female = 2399,
			male = 2399,
			addons = 3
		},
		{
			name = "Black Knightaxe",
			female = 2462,
			male = 2462,
			addons = 3
		},
		{
			name = "Warrior Elite",
			female = 2470,
			male = 2470,
			addons = 3
		},
		{
			name = "Warrior Elita",
			female = 2471,
			male = 2471,
			addons = 3
		},

		{
			name = "Yu Gi Oh",
			female = 2073,
			male = 2073,
			addons = 3
		},
		{
			name = "Black Goku",
			female = 2074,
			male = 2074,
			addons = 3
		},
		{
			name = "Bunny",
			female = 2077,
			male = 2077,
			addons = 3
		},
		{
			name = "Captain Corsair",
			female = 2132,
			male = 2132,
			addons = 3
		},
		{
			name = "Warrior Elite Ek",
			female = 2244,
			male = 2244,
			addons = 3
		},
				{
			name = "Frostbound Sage",
			female = 2108,
			male = 2108,
			addons = 3
		},
		{
			name = "Iron Vanguard",
			female = 2109,
			male = 2109,
			addons = 3
		},
		{
			name = "Woodland Ranger",
			female = 2110,
			male = 2110,
			addons = 3
		},
		{
			name = "Celestial Noble",
			female = 2145,
			male = 2145,
			addons = 3
		},
		{
			name = "Silver Sentinel",
			female = 2146,
			male = 2146,
			addons = 3
		},
		{
			name = "Shadow Striker",
			female = 2147,
			male = 2147,
			addons = 3
		},
		{
			name = "Crimson Avenger",
			female = 2148,
			male = 2148,
			addons = 3
		},
		{
			name = "Arcane Champion",
			female = 2205,
			male = 2205,
			addons = 3
		},

	}
}

local addonBox = Action()

local function getPlayerLookType(player, outfit)
	if player:getSex() == PLAYERSEX_FEMALE then
		return outfit.female
	end

	return outfit.male
end

local function giveOutfit(player, outfit)
	player:addOutfit(outfit.female, outfit.addons)

	if outfit.male ~= outfit.female then
		player:addOutfit(outfit.male, outfit.addons)
	end
end

function addonBox.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local availableOutfits = {}

	-- Solo incluye outfits que el jugador todavía no tiene completos.
	for _, outfit in ipairs(config.outfits) do
		local lookType = getPlayerLookType(player, outfit)

		if not player:hasOutfit(lookType, outfit.addons) then
			table.insert(availableOutfits, outfit)
		end
	end

	-- No consume la caja si ya tiene todos.
	if #availableOutfits == 0 then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"You already own every outfit available from this box."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Selecciona un outfit disponible al azar.
	local selectedOutfit = availableOutfits[math.random(#availableOutfits)]
	local selectedLookType = getPlayerLookType(player, selectedOutfit)

	giveOutfit(player, selectedOutfit)

	-- Comprueba que el outfit esté registrado correctamente.
	if not player:hasOutfit(selectedLookType, selectedOutfit.addons) then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"The outfit could not be granted. LookType "
				.. selectedLookType
				.. " is not registered correctly."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	player:sendTextMessage(
		MESSAGE_EVENT_ADVANCE,
		"You received the complete " .. selectedOutfit.name .. " outfit!"
	)

	player:getPosition():sendMagicEffect(config.effect)

	-- Se consume únicamente después de entregar el outfit.
	item:remove(1)
	return true
end

addonBox:id(config.itemId)
addonBox:register()