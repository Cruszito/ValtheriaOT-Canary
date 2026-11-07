local TIME_TO_DEFEAT = 15 * 60 -- 15 minutos para derrotar al boss.
local TIME_AFTER_KILL = 60 -- Tiempo para usar el portal antes de expulsar la sala.
local DEATH_PORTAL_ITEM_ID = 1949

local levers = {
	{
		bossName = "Azhurak the Infernal",
		bossPosition = Position(32193, 32165, 15),
		leverPosition = Position(32215, 32209, 15),
		pullerPosition = Position(32216, 32209, 15),
		playerDestination = Position(32193, 32173, 15),
		roomArea = {
			from = Position(32181, 32153, 15),
			to = Position(32205, 32177, 15),
		},
		playerPositions = {
			Position(32216, 32207, 15),
			Position(32217, 32207, 15),
			Position(32216, 32208, 15),
			Position(32217, 32208, 15),
			Position(32216, 32209, 15),
			Position(32217, 32209, 15),
			Position(32216, 32210, 15),
			Position(32217, 32210, 15),
			Position(32216, 32211, 15),
			Position(32217, 32211, 15),
		},
	},
	{
		bossName = "Arkhazul the Devourer",
		bossPosition = Position(32277, 32329, 15),
		leverPosition = Position(32234, 32209, 15),
		pullerPosition = Position(32235, 32209, 15),
		playerDestination = Position(32280, 32337, 15),
		roomArea = {
			from = Position(32265, 32317, 15),
			to = Position(32289, 32341, 15),
		},
		playerPositions = {
			Position(32235, 32207, 15),
			Position(32236, 32207, 15),
			Position(32235, 32208, 15),
			Position(32236, 32208, 15),
			Position(32235, 32209, 15),
			Position(32236, 32209, 15),
			Position(32235, 32210, 15),
			Position(32236, 32210, 15),
			Position(32235, 32211, 15),
			Position(32236, 32211, 15),
		},
	},
	{
		bossName = "Azrathor the Tormentor",
		bossPosition = Position(32194, 32193, 15),
		leverPosition = Position(32215, 32228, 15),
		pullerPosition = Position(32216, 32228, 15),
		playerDestination = Position(32194, 32200, 15),
		roomArea = {
			from = Position(32182, 32181, 15),
			to = Position(32206, 32205, 15),
		},
		playerPositions = {
			Position(32216, 32226, 15),
			Position(32217, 32226, 15),
			Position(32216, 32227, 15),
			Position(32217, 32227, 15),
			Position(32216, 32228, 15),
			Position(32217, 32228, 15),
			Position(32216, 32229, 15),
			Position(32217, 32229, 15),
			Position(32216, 32230, 15),
			Position(32217, 32230, 15),
		},
	},
	{
		bossName = "Amonkar the Undying",
		bossPosition = Position(32192, 32140, 15),
		leverPosition = Position(32234, 32228, 15),
		pullerPosition = Position(32235, 32228, 15),
		playerDestination = Position(32196, 32148, 15),
		roomArea = {
			from = Position(32180, 32128, 15),
			to = Position(32204, 32152, 15),
		},
		playerPositions = {
			Position(32235, 32226, 15),
			Position(32236, 32226, 15),
			Position(32235, 32227, 15),
			Position(32236, 32227, 15),
			Position(32235, 32228, 15),
			Position(32236, 32228, 15),
			Position(32235, 32229, 15),
			Position(32236, 32229, 15),
			Position(32235, 32230, 15),
			Position(32236, 32230, 15),
		},
	},
	{
		bossName = "Akhzeron the Blighted",
		bossPosition = Position(32118, 32383, 15),
		leverPosition = Position(32215, 32247, 15),
		pullerPosition = Position(32216, 32247, 15),
		playerDestination = Position(32121, 32390, 15),
		roomArea = {
			from = Position(32106, 32371, 15),
			to = Position(32130, 32395, 15),
		},
		playerPositions = {
			Position(32216, 32245, 15),
			Position(32217, 32245, 15),
			Position(32216, 32246, 15),
			Position(32217, 32246, 15),
			Position(32216, 32247, 15),
			Position(32217, 32247, 15),
			Position(32216, 32248, 15),
			Position(32217, 32248, 15),
			Position(32216, 32249, 15),
			Position(32217, 32249, 15),
		},
	},
	{
		bossName = "Arkanith the Ruinous",
		bossPosition = Position(31774, 32288, 15),
		leverPosition = Position(32234, 32247, 15),
		pullerPosition = Position(32235, 32247, 15),
		playerDestination = Position(31777, 32294, 15),
		roomArea = {
			from = Position(31762, 32276, 15),
			to = Position(31786, 32300, 15),
		},
		playerPositions = {
			Position(32235, 32245, 15),
			Position(32236, 32245, 15),
			Position(32235, 32246, 15),
			Position(32236, 32246, 15),
			Position(32235, 32247, 15),
			Position(32236, 32247, 15),
			Position(32235, 32248, 15),
			Position(32236, 32248, 15),
			Position(32235, 32249, 15),
			Position(32236, 32249, 15),
		},
	},
}

local function buildPlayerPositions(positions, destination)
	local result = {}
	for _, position in ipairs(positions) do
		result[#result + 1] = {
			pos = position,
			teleport = destination,
			effect = CONST_ME_TELEPORT,
		}
	end
	return result
end

local function registerQuestBossLever(data)
	local config = {
		boss = {
			name = data.bossName,
			position = data.bossPosition,
		},
		minPlayers = 1,
		requiredLevel = 0,
		disableCooldown = true,
		timeToDefeat = TIME_TO_DEFEAT,
		timeAfterKill = TIME_AFTER_KILL,
		playerPositions = buildPlayerPositions(data.playerPositions, data.playerDestination),
		specPos = data.roomArea,
		-- Si se acaba el tiempo, los jugadores regresan frente a su palanca.
		exit = data.pullerPosition,
	}

	local bossLever = BossLever(config)
	local defaultOnUse = bossLever.onUse

	-- BossLever permite activar desde cualquier posicion participante.
	-- Esta validacion limita el uso al SQM indicado frente a la palanca.
	function bossLever:onUse(player)
		if player:getPosition() ~= data.pullerPosition then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Only the player directly in front of the lever can use it.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end

		-- No permite iniciar otra pelea mientras siga activo el portal anterior.
		local bossTile = Tile(data.bossPosition)
		if bossTile and bossTile:getItemById(DEATH_PORTAL_ITEM_ID) then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Wait for the previous boss portal to disappear before starting again.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return true
		end

		return defaultOnUse(self, player)
	end

	bossLever:position(data.leverPosition)
	bossLever:register()
end

for _, data in ipairs(levers) do
	registerQuestBossLever(data)
end
