local supremeCube = Action()

local config = {
	storage = 9007,
	cooldown = 60,

	-- Debe coincidir con rouletteStateStorage del script de la ruleta.
	rouletteStateStorage = 91001,

	cities = {
		{ name = "Ab'Dendriel", teleport = Position(32732, 31634, 7) },
		{ name = "Ankrahmun", teleport = Position(33194, 32853, 8) },
		{ name = "Carlin", teleport = Position(32360, 31782, 7) },
		{ name = "Darashia", teleport = Position(33213, 32454, 1) },
		{ name = "Edron", teleport = Position(33217, 31814, 8) },
		{ name = "Farmine", teleport = Position(33023, 31521, 11) },
		{ name = "Issavi", teleport = Position(33921, 31477, 5) },
		{ name = "Kazordoon", teleport = Position(32649, 31925, 11) },
		{ name = "Krailos", teleport = Position(33657, 31665, 8) },
		{ name = "Liberty Bay", teleport = Position(32317, 32826, 7) },
		{ name = "Marapur", teleport = Position(33842, 32853, 7) },
		{ name = "Port Hope", teleport = Position(32594, 32745, 7) },
		{ name = "Rathleton", teleport = Position(33594, 31899, 6) },
		{ name = "Roshamuul", teleport = Position(33513, 32363, 6) },
		{ name = "Svargrond", teleport = Position(32212, 31132, 7) },
		{ name = "Thais", teleport = Position(32369, 32241, 7) },
		{ name = "Venore", teleport = Position(32957, 32076, 7) },
		{ name = "Yalahar", teleport = Position(32787, 31276, 7) },
	},

	bosses = {
		{ name = "Arbaziloth", teleport = Position(34058, 32401, 14) },
		{ name = "Count Vlarkorth", teleport = Position(33456, 31410, 13) },
		{ name = "Dragon Pack", teleport = Position(33262, 31057, 13) },
		{ name = "Drume", teleport = Position(32459, 32507, 6) },
		{ name = "Earl Osam", teleport = Position(33516, 31440, 13) },
		{ name = "Faceless Bane", teleport = Position(33638, 32560, 13) },
		{ name = "Ferumbras Ascension", teleport = Position(33265, 31478, 14) },
		{ name = "Ghulosh", teleport = Position(32748, 32770, 10) },
		{ name = "Gorzindel", teleport = Position(32748, 32746, 10) },
		{ name = "Goshnar's Cruelty", teleport = Position(33856, 31851, 6) },
		{ name = "Goshnar's Greed", teleport = Position(33777, 31662, 14) },
		{ name = "Goshnar's Hatred", teleport = Position(33775, 31599, 14) },
		{ name = "Goshnar's Malice", teleport = Position(33682, 31597, 14) },
		{ name = "Goshnar's Spite", teleport = Position(33776, 31632, 14) },
		{ name = "Grand Master Oberon", teleport = Position(33366, 31342, 9) },
		{ name = "King Zelos", teleport = Position(33490, 31545, 13) },
		{ name = "Leiden", teleport = Position(33135, 31953, 15) },
		{ name = "Lord Azaram", teleport = Position(33423, 31495, 13) },
		{ name = "Lokathmor", teleport = Position(32722, 32746, 10) },
		{ name = "Magma Bubble", teleport = Position(33660, 32896, 14) },
		{ name = "Mazzinor", teleport = Position(32722, 32770, 10) },
		{ name = "Ratmiral Blackwhiskers", teleport = Position(33894, 31386, 15) },
		{ name = "Rotten Blood Quest", teleport = Position(32958, 32398, 9) },
		{ name = "Scarlett Etzel", teleport = Position(33395, 32671, 6) },
		{ name = "Sir Baeloc", teleport = Position(33426, 31407, 13) },
		{ name = "Tentugly's Head", teleport = Position(33792, 31386, 6) },
		{ name = "The Brainstealer", teleport = Position(32530, 31120, 15) },
		{ name = "The Dread Maiden", teleport = Position(33739, 31504, 14) },
		{ name = "The Duke Krule", teleport = Position(33457, 31497, 13) },
		{ name = "The Fear Feaster", teleport = Position(33740, 31471, 14) },
		{ name = "The Monster", teleport = Position(33808, 32581, 12) },
		{ name = "The Nightmare Beast", teleport = Position(32212, 32072, 15) },
		{ name = "The Pale Worm", teleport = Position(33778, 31504, 14) },
		{ name = "The Scourge of Oblivion", teleport = Position(32679, 32742, 11) },
		{ name = "Timira the Many-Headed", teleport = Position(33807, 32699, 8) },
		{ name = "Urmahlullu the Weakened", teleport = Position(33919, 31605, 8) },
		{ name = "Warzone 6", teleport = Position(33277, 32318, 15) },
		{ name = "Warzone 5", teleport = Position(33323, 32111, 15) },
		{ name = "Warzone 4", teleport = Position(33462, 32267, 15) },
	}
}

local function supremeCubeMessage(player, effect, message)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
	player:getPosition():sendMagicEffect(effect)
end

local function canUseSupremeCube(player)
	-- Bloquea el cubo mientras exista cualquier resultado pendiente de la ruleta.
	-- La comprobación también se ejecuta al confirmar el destino en el modal.
	if player:getStorageValue(config.rouletteStateStorage) > 0 then
		supremeCubeMessage(
			player,
			CONST_ME_POFF,
			"You cannot use the Supreme Cube while the roulette is spinning."
		)
		return false
	end

	local inPz = player:getTile():hasFlag(TILESTATE_PROTECTIONZONE)
	local inFight = player:isPzLocked() or player:getCondition(CONDITION_INFIGHT, CONDITIONID_DEFAULT)

	if not inPz and inFight then
		supremeCubeMessage(player, CONST_ME_POFF, "You can't use this when you're in a fight.")
		return false
	end

	local cooldown = player:getStorageValue(config.storage)
	if cooldown > os.time() then
		local remainingTime = cooldown - os.time()
		supremeCubeMessage(player, CONST_ME_POFF, "You can use it again in: " .. remainingTime .. " seconds.")
		return false
	end

	return true
end

local openMainWindow

local function openTeleportWindow(player, title, destinations)
	local window = ModalWindow({
		title = title,
		message = "Select your destination.",
	})

	for _, destination in pairs(destinations) do
		window:addChoice(destination.name, function(player, button, choice)
			if button.name == "Back" then
				openMainWindow(player)
				return true
			end

			if button.name ~= "Teleport" then
				return true
			end

			if not canUseSupremeCube(player) then
				return true
			end

			player:teleportTo(destination.teleport, true)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			player:setStorageValue(config.storage, os.time() + config.cooldown)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Welcome to " .. destination.name .. ".")

			return true
		end)
	end

	window:addButton("Teleport")
	window:addButton("Back")
	window:addButton("Close")

	window:setDefaultEnterButton(0)
	window:setDefaultEscapeButton(2)

	window:sendToPlayer(player)
end

function openMainWindow(player)
	local window = ModalWindow({
		title = "Supreme Cube",
		message = "Choose a section.",
	})

	window:addChoice("Cities", function(player, button, choice)
		if button.name == "Select" then
			openTeleportWindow(player, "Supreme Cube - Cities", config.cities)
		end

		return true
	end)

	window:addChoice("Bosses", function(player, button, choice)
		if button.name == "Select" then
			openTeleportWindow(player, "Supreme Cube - Bosses", config.bosses)
		end

		return true
	end)

	window:addButton("Select")
	window:addButton("Close")

	window:setDefaultEnterButton(0)
	window:setDefaultEscapeButton(1)

	window:sendToPlayer(player)
end

function supremeCube.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not canUseSupremeCube(player) then
		return true
	end

	openMainWindow(player)
	return true
end

supremeCube:id(31633)
supremeCube:register()