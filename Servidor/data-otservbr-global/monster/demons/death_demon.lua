local mType = Game.createMonsterType("Death Demon")
local monster = {}

monster.description = "a death demon"
monster.experience = 300000
monster.outfit = {
	lookType = 12,
	lookHead = 0,
	lookBody = 57,
	lookLegs = 0,
	lookFeet = 80,
	lookAddons = 0,
	lookMount = 0,
}


monster.health = 300000
monster.maxHealth = 300000
monster.race = "undead"
monster.corpse = 6068
monster.speed = 145
monster.manaCost = 0

monster.changeTarget = {
	interval = 4000,
	chance = 20,
}

monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
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
	staticAttackChance = 80,
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

monster.summon = {
	maxSummons = 1,
	summons = {
		{ name = "demon skeleton", chance = 8, interval = 3000, count = 1 },
	},
}

monster.voices = {
	interval = 5000,
	chance = 10,
	{ text = "DEATH CLAIMS YOU!", yell = true },
	{ text = "YOUR SOUL IS MINE!", yell = true },
	{ text = "KNEEL BEFORE THE VOID!", yell = true },
}

monster.loot = {
	{ name = "gold coin", chance = 70000, maxCount = 100 },
	{ name = "gold coin", chance = 70000, maxCount = 100 },
	{ name = "platinum coin", chance = 90540, maxCount = 12 },
	{ name = "demonic essence", chance = 18000 },
	{ name = "demon horn", chance = 16000 },
	{ name = "talon", chance = 5000 },
	{ name = "small emerald", chance = 8500, maxCount = 5 },
	{ name = "small amethyst", chance = 8500, maxCount = 5 },
	{ name = "small ruby", chance = 8500, maxCount = 5 },
	{ name = "ultimate health potion", chance = 22000, maxCount = 4 },
	{ id = 238,  chance = 24000, maxCount = 4 },
	{ name = "great spirit potion", chance = 19000, maxCount = 4 },
	{ name = "might ring", chance = 2200 },
	{ name = "giant sword", chance = 2000 },
	{ name = "fire axe", chance = 4000 },
	{ name = "devil helmet", chance = 1300 },
	{ name = "demon shield", chance = 900 },
	{ name = "mastermind shield", chance = 600 },
	{ name = "magic plate armor", chance = 180 },
	{ id = 7393, chance = 120 }, -- demon trophy
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, minDamage = 0, maxDamage = -650 },
	{ name = "combat", interval = 2000, chance = 10, type = COMBAT_MANADRAIN, minDamage = 1500, maxDamage = -1660, range = 7, target = false },
	{ name = "combat", interval = 2000, chance = 25, type = COMBAT_DEATHDAMAGE, minDamage = -1300, maxDamage = -1720, range = 7, radius = 5, shootEffect = CONST_ANI_SUDDENDEATH, effect = CONST_ME_MORTAREA, target = true },
	{ name = "combat", interval = 2000, chance = 15, type = COMBAT_LIFEDRAIN, minDamage = -1380, maxDamage = -1720, length = 8, spread = 0, effect = CONST_ME_MORTAREA, target = false },
	{ name = "combat", interval = 2000, chance = 12, type = COMBAT_MANADRAIN, minDamage = -1100, maxDamage = -1200, range = 7, target = true },
	{ name = "death chain", interval = 3000, chance = 45, minDamage = -1300, maxDamage = -2150, range = 7 },
}

monster.defenses = {
	defense = 65,
	armor = 55,
	mitigation = 2.10,
	{ name = "combat", interval = 2000, chance = 15, type = COMBAT_HEALING, minDamage = 250, maxDamage = 420, effect = CONST_ME_MAGIC_BLUE, target = false },
	{ name = "speed", interval = 2000, chance = 15, speedChange = 320, effect = CONST_ME_MAGIC_RED, target = false, duration = 5000 },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 25 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 30 },
	{ type = COMBAT_EARTHDAMAGE, percent = 40 },
	{ type = COMBAT_FIREDAMAGE, percent = 40 },
	{ type = COMBAT_LIFEDRAIN, percent = 100 },
	{ type = COMBAT_MANADRAIN, percent = 30 },
	{ type = COMBAT_DROWNDAMAGE, percent = 100 },
	{ type = COMBAT_ICEDAMAGE, percent = 20 },
	{ type = COMBAT_HOLYDAMAGE, percent = -25 },
	{ type = COMBAT_DEATHDAMAGE, percent = 100 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = false },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = false },
}

monster.events = {
	"DemonBossDeathTeleport"
}

mType:register(monster)
