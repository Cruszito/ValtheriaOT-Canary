local mType = Game.createMonsterType("Dragon Pack")
local monster = {}

monster.description = "a dragon pack"
monster.experience = 7810

monster.outfit = {
	lookType = 1712,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 280000
monster.maxHealth = 280000
monster.race = "blood"
monster.corpse = 44663
monster.speed = 170
monster.manaCost = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10,
}

monster.strategiesTarget = {
	nearest = 100,
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
	staticAttackChance = 70,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.light = {
	level = 0,
	color = 0,
}

monster.voices = {
	interval = 5000,
	chance = 10,
	{ text = "Just look at me!", yell = false },
	{ text = "I'll stare you down!", yell = false },
	{ text = "Let me have a look!", yell = false },
}

monster.loot = {
	{ id = 3031, chance = 100000, minCount = 1, maxCount = 391 },
	{ id = 3035, chance = 70000, minCount = 1, maxCount = 200 },
	{ id = 3043, chance = 25000, minCount = 1, maxCount = 3 },
	{ id = 3041, chance = 18000, minCount = 1, maxCount = 2 },
	{ id = 3061, chance = 18000, minCount = 1, maxCount = 2 },
	{ id = 3037, chance = 18000, minCount = 1, maxCount = 2 },
	{ id = 3301, chance = 15000 },
	{ id = 32769, chance = 15000, minCount = 1, maxCount = 2 },

	{ id = 8057, chance = 3500 },
	{ id = 7430, chance = 3500 },
	{ id = 3386, chance = 3000 },
	{ id = 32622, chance = 3000 },
	{ id = 30060, chance = 2500 },
	{ id = 32623, chance = 2500 },
	{ id = 10323, chance = 2000 },
	{ id = 3392, chance = 2500 },
	{ id = 3428, chance = 3500 },
	{ id = 3071, chance = 4000 },
	{ id = 10385, chance = 2000 },

	{ id = 44752, chance = 900 },
	{ id = 44750, chance = 700 },
	{ id = 44751, chance = 500 },

	{ id = 44623, chance = 700 },
	{ id = 44621, chance = 700 },
	{ id = 44754, chance = 800 },
	{ id = 44753, chance = 800 },
	{ id = 50264, chance = 500 },
	{ id = 44624, chance = 500 },
	{ id = 44622, chance = 500 },
}

monster.attacks = {
	{
		name = "melee",
		interval = 2000,
		chance = 100,
		minDamage = -1150,
		maxDamage = -1450,
	},
	{
		name = "combat",
		interval = 2500,
		chance = 15,
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -250,
		maxDamage = -350,
		range = 2,
		effect = CONST_ME_BIG_SCRATCH,
		target = true,
	},
	{
		name = "combat",
		interval = 2500,
		chance = 20,
		type = COMBAT_FIREDAMAGE,
		minDamage = -250,
		maxDamage = -300,
		length = 8,
		spread = 4,
		effect = CONST_ME_EXPLOSIONHIT,
		target = false,
	},
	{
		name = "combat",
		interval = 2500,
		chance = 15,
		type = COMBAT_FIREDAMAGE,
		minDamage = -200,
		maxDamage = -300,
		range = 7,
		radius = 4,
		shootEffect = CONST_ANI_FIRE,
		effect = CONST_ME_FIREAREA,
		target = true,
	},
	{
		name = "combat",
		interval = 3000,
		chance = 5,
		type = COMBAT_PHYSICALDAMAGE,
		minDamage = -200,
		maxDamage = -350,
		radius = 4,
		effect = CONST_ME_POFF,
		target = true,
	},
	{
		name = "combat",
		interval = 9500,
		chance = 59,
		type = COMBAT_HOLYDAMAGE,
		minDamage = -1050,
		maxDamage = -1300,
		radius = 4,
		effect = CONST_ME_HOLYAREA,
		target = false,
	},
	{
		name = "extended holy chain",
		interval = 5000,
		chance = 59,
		minDamage = -1150,
		maxDamage = -1300,
		range = 7,
	},
	{
		name = "destroy magic walls",
		interval = 1000,
		chance = 30,
	},
	{
		name = "death chain",
		interval = 2500,
		chance = 15,
		minDamage = -800,
		maxDamage = -850,
		range = 7,
	},
}

monster.defenses = {
	defense = 76,
	armor = 76,
	mitigation = 1.96,
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 15 },
	{ type = COMBAT_ENERGYDAMAGE, percent = -10 },
	{ type = COMBAT_EARTHDAMAGE, percent = -10 },
	{ type = COMBAT_FIREDAMAGE, percent = 15 },
	{ type = COMBAT_LIFEDRAIN, percent = 15 },
	{ type = COMBAT_MANADRAIN, percent = 15 },
	{ type = COMBAT_DROWNDAMAGE, percent = 15 },
	{ type = COMBAT_ICEDAMAGE, percent = 15 },
	{ type = COMBAT_HOLYDAMAGE, percent = -10 },
	{ type = COMBAT_DEATHDAMAGE, percent = 15 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = false },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = false },
}

mType:register(monster)
