local config = {
	boss = {
		name = "Lady Tenebris",
		position = Position(32912, 31599, 14),
	},

	requiredLevel = 250,
	minPlayers = 1,

	-- Valores explícitos para no depender del config.lua.
	timeToFightAgain = 20 * 60 * 60, -- 20 horas
	timeToDefeat = 20 * 60, -- 20 minutos
	timeAfterKill = 60, -- 60 segundos para salir

	playerPositions = {
		{
			pos = Position(32902, 31623, 14),
			teleport = Position(32911, 31603, 14),
			effect = CONST_ME_TELEPORT,
		},
		{
			pos = Position(32902, 31624, 14),
			teleport = Position(32911, 31603, 14),
			effect = CONST_ME_TELEPORT,
		},
		{
			pos = Position(32902, 31625, 14),
			teleport = Position(32911, 31603, 14),
			effect = CONST_ME_TELEPORT,
		},
		{
			pos = Position(32902, 31626, 14),
			teleport = Position(32911, 31603, 14),
			effect = CONST_ME_TELEPORT,
		},
		{
			pos = Position(32902, 31627, 14),
			teleport = Position(32911, 31603, 14),
			effect = CONST_ME_TELEPORT,
		},
	},

	monsters = {
		{
			name = "Shadow Tentacle",
			pos = Position(32910, 31599, 14),
		},
		{
			name = "Shadow Tentacle",
			pos = Position(32912, 31597, 14),
		},
		{
			name = "Shadow Tentacle",
			pos = Position(32914, 31599, 14),
		},
	},

	specPos = {
		from = Position(32899, 31587, 14),
		to = Position(32923, 31612, 14),
	},

	exit = Position(32902, 31629, 14),
}

local lever = BossLever(config)

-- Palanca:
-- Position(32902, 31622, 14)
lever:position(Position(32902, 31622, 14))
lever:register()