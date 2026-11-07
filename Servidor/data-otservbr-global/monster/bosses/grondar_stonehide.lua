local mType = Game.createMonsterType("Grondar Stonehide")
local monster = {}

monster.description = "grondar stonehide"
monster.experience = 410000

monster.outfit = {
	lookType = 2165,
}

monster.health = 420000
monster.maxHealth = 420000
monster.race = "blood"
monster.corpse = 6068
monster.speed = 225
monster.manaCost = 0

monster.changeTarget = {
	interval = 6500,
	chance = 58,
}

monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 15,
	random = 5,
}

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = false,
	rewardBoss = true,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = true,
	staticAttackChance = 96,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = false,
	canWalkOnPoison = true,
}

-- Luz fría para combinar con su apariencia plateada
monster.light = {
	level = 6,
	color = 215,
}

monster.summon = {
	maxSummons = 8,
	summons = {
		{ name = "Dreadful Harvester", chance = 100, interval = 5000, count = 8 },
	},
}

monster.voices = {
	interval = 5000,
	chance = 14,
	{ text = "MY IRON HORNS WILL BREAK YOU!", yell = true },
	{ text = "STONE AND STEEL OBEY MY WILL!", yell = true },
	{ text = "YOUR WEAPONS CANNOT PIERCE MY HIDE!", yell = true },
}

monster.loot = {
	{ id = 36727, chance = 5800, maxCount = 1 }, --wealth duplex
	{ id = 51462, chance = 2500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 600, maxCount = 1 }, -- bag you desire
	{ id = 51589, chance = 1600, maxCount = 1 }, -- greater proficiency catalyst
	{ name = "crypt splitter", chance = 2900 },--crypt splitter
	{ name = "crypt slicer", chance = 2900 },-- crypt slicer
	{ name = "great spirit potion", chance = 2900, maxCount = 6 },
	{ name = "ultimate mana potion", chance = 3000, minCount = 20, maxCount = 40 },
	{ name = "ultimate health potion", chance = 3500, minCount = 10, maxCount = 20 },
	{ name = "supreme health potion", chance = 2900, minCount = 5, maxCount = 10 },
	{ name = "ultimate spirit potion", chance = 3500, minCount = 2, maxCount = 14 },
	{ name = "blue gem", chance = 2900, maxCount = 2 },
	{ id = 3039, chance = 2500, maxCount = 2 }, -- red gem
	{ name = "yellow gem", chance = 2000, maxCount = 2 },
	{ id = 6299, chance = 1900 }, -- death ring
	{ name = "devil helmet", chance = 1800 },
	{ name = "fire axe", chance = 1700 },
	{ name = "fire sword", chance = 1600 },
	{ name = "giant sword", chance = 1500 },
	{ name = "gold ring", chance = 1400 },
	{ name = "golden sickle", chance = 1300 },
	{ name = "giant amethyst", chance = 900 },
	{ name = "giant emerald", chance = 900 },
	{ name = "giant ruby", chance = 900 },
	{ name = "giant sapphire", chance = 900 },
	{ name = "golden legs", chance = 900 },
	{ name = "magic plate armor", chance = 900 },
}

monster.attacks = {
	-- Golpe cuerpo a cuerpo más rápido y fuerte
	{
		name = "melee",
		interval = 1700,
		chance = 100,
		minDamage = -3800,
		maxDamage = -6200,
	},

	-- Pisotón metálico alrededor del boss
	{
		name = "combat",
		interval = 2200,
		chance = 46,
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -3000,
		maxDamage = -4500,
		radius = 4,
		effect = CONST_ME_GROUNDSHAKER,
		target = false,
	},

	-- Proyectil de hielo dirigido
	{
		name = "combat",
		interval = 2600,
		chance = 42,
		type = COMBAT_ICEDAMAGE,
		minDamage = -3300,
		maxDamage = -4800,
		range = 7,
		radius = 3,
		shootEffect = CONST_ANI_ICE,
		effect = CONST_ME_ICEAREA,
		target = true,
	},

	-- Rayo de energía en línea recta
	{
		name = "combat",
		interval = 3100,
		chance = 38,
		type = COMBAT_ENERGYDAMAGE,
		minDamage = -3500,
		maxDamage = -5200,
		length = 9,
		spread = 0,
		effect = CONST_ME_ENERGYAREA,
		target = false,
	},

	-- Onda oscura lanzada por los cuernos
	{
		name = "combat",
		interval = 3700,
		chance = 35,
		type = COMBAT_DEATHDAMAGE,
		minDamage = -3800,
		maxDamage = -5600,
		length = 8,
		spread = 3,
		effect = CONST_ME_MORTAREA,
		target = false,
	},

	-- Explosión metálica de gran alcance
	{
		name = "combat",
		interval = 4500,
		chance = 30,
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -4200,
		maxDamage = -6500,
		radius = 7,
		effect = CONST_ME_EXPLOSIONAREA,
		target = false,
	},

	-- Congelación y ralentización del objetivo
	{
		name = "speed",
		interval = 5000,
		chance = 26,
		speedChange = -650,
		range = 7,
		duration = 6000,
		effect = CONST_ME_ICEAREA,
		target = true,
	},
}

monster.defenses = {
	defense = 110,
	armor = 105,

	{
		name = "combat",
		interval = 3000,
		chance = 32,
		type = COMBAT_HEALING,
		minDamage = 1500,
		maxDamage = 3000,
		effect = CONST_ME_MAGIC_BLUE,
		target = false,
	},

	{
		name = "speed",
		interval = 4500,
		chance = 35,
		speedChange = 350,
		effect = CONST_ME_ENERGYAREA,
		target = false,
		duration = 5000,
	},
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 80 },
	{ type = COMBAT_EARTHDAMAGE, percent = 100 },
	{ type = COMBAT_ICEDAMAGE, percent = 65 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 55 },
	{ type = COMBAT_DEATHDAMAGE, percent = 40 },
	{ type = COMBAT_FIREDAMAGE, percent = 20 },
	{ type = COMBAT_HOLYDAMAGE, percent = -15 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = true },
}

monster.events = {
	"CustomQuestBossDeathTeleport",
}

mType:register(monster)