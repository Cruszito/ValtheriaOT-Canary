local mType = Game.createMonsterType("Zyrek Stormblade")
local monster = {}

monster.description = "zyrek stormblade"
monster.experience = 370000

monster.outfit = {
	lookType = 2523,
}

monster.health = 480000
monster.maxHealth = 480000
monster.race = "energy"
monster.corpse = 6068
monster.speed = 345
monster.manaCost = 0

monster.changeTarget = {
	interval = 5500,
	chance = 35,
}

monster.strategiesTarget = {
	nearest = 50,
	health = 15,
	damage = 25,
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
	staticAttackChance = 90,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = false,
	canWalkOnPoison = true,
}

monster.light = {
	level = 8,
	color = 87,
}

monster.summon = {
	maxSummons = 8,
	summons = {
		{ name = "Many Faces", chance = 100, interval = 8000, count = 6 },
	},
}

monster.voices = {
	interval = 4300,
	chance = 16,
	{ text = "THE STORM COILS AROUND YOU!", yell = true },
	{ text = "MY VENOM CARRIES THE LIGHTNING!", yell = true },
	{ text = "SSSSURRENDER TO THE MUTATION!", yell = true },
}

monster.loot = {
	{ name = "silver amulet", chance = 7000 },
	{ name = "skull staff", chance = 8000 },
	{ name = "spellweaver's robe", chance = 9300 },
	{ name = "stone skin amulet", chance = 8900 },
	{ name = "strange helmet", chance = 9000 },
	{ name = "underworld rod", chance = 9600 },
	{ name = "ice rapier", chance = 9200},
	{ name = "great spirit potion", chance = 9900, maxCount = 6},
	{ name = "ultimate mana potion", chance = 9000, minCount = 20, maxCount = 40 },
	{ name = "ultimate health potion", chance = 9500, minCount = 10, maxCount = 20 },
	{ name = "supreme health potion", chance = 9900, minCount = 5, maxCount = 10 },
	{ name = "ultimate spirit potion", chance = 9500, minCount = 2, maxCount = 14 },
	{ name = "blue gem", chance = 8900, maxCount = 2 },
	{ id = 3039, chance = 2500, maxCount = 2 }, -- red gem
	{ name = "yellow gem", chance = 12000, maxCount = 2 },
	{ id = 6299, chance = 1900 }, -- death ring
	{ name = "devil helmet", chance = 9800 },
	{ name = "fire axe", chance = 8700 },
	{ name = "fire sword", chance = 7600 },
	{ name = "giant sword", chance = 6500 },
	{ name = "gold ring", chance = 9400 },
	{ name = "golden sickle", chance = 1300 },
	{ id = 58448,  chance = 100000, maxCount = 100 }, -- Endless coin
	{ name = "crystal coin", chance = 100000, maxCount = 100 },
	{ id = 36727, chance = 9800, maxCount = 1  }, --wealth duplex
	{ id = 51462, chance = 6500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 400, maxCount = 1 }, -- bag you desire
	{ id = 51589, chance = 6600, maxCount = 1 }, -- greater proficiency catalyst
	{ name = "crypt slicer", chance = 800 },
	{ id = 55976, chance = 1300 },
	{ name = "twiceslicer", chance = 9100 },
	{ name = "ice ward ring", chance = 1800 },
	{ name = "ice robe", chance = 2900 },
	{ name = "glacier robe", chance = 9900 },
	{ name = "rift lance", chance = 1360 },
	{ id = 3098, chance = 1320 }, -- ring of healing
	{ name = "platinum amulet", chance = 6940 },
	{ name = "devil helmet", chance = 2520 },
	{ name = "rift crossbow", chance = 3370 },
	{ name = "rift bow", chance = 3730 },
	{ name = "rift shield", chance = 4370 },
	{ name = "demon shield", chance = 3370 },
	{ name = "magic plate armor", chance = 8570 },
	{ name = "golden legs", chance = 5620 },
	{ name = "demonrage sword", chance = 3530 },
}

monster.attacks = {
	{ name = "melee", interval = 1550, chance = 100, minDamage = -1800, maxDamage = -4300 },
	{ name = "combat", interval = 1900, chance = 48, type = COMBAT_ENERGYDAMAGE, minDamage = -2350, maxDamage = -3600, length = 10, spread = 0, effect = CONST_ME_ENERGYAREA, target = false },
	{ name = "combat", interval = 2300, chance = 44, type = COMBAT_EARTHDAMAGE, minDamage = -2400, maxDamage = -3700, range = 8, radius = 2, shootEffect = CONST_ANI_EARTH, effect = CONST_ME_POISONAREA, target = true },
	{ name = "combat", interval = 2800, chance = 40, type = COMBAT_ICEDAMAGE, minDamage = -2550, maxDamage = -3900, length = 8, spread = 3, effect = CONST_ME_ICEAREA, target = false },
	{ name = "combat", interval = 3300, chance = 36, type = COMBAT_PHYSICALDAMAGE, minDamage = -2800, maxDamage = -4200, radius = 3, effect = CONST_ME_GROUNDSHAKER, target = false },
	{ name = "combat", interval = 4100, chance = 31, type = COMBAT_ENERGYDAMAGE, minDamage = -3050, maxDamage = -4500, radius = 4, effect = CONST_ME_ENERGYAREA, target = false },
	{ name = "speed", interval = 4800, chance = 27, speedChange = -600, range = 7, duration = 5000, effect = CONST_ME_POISONAREA, target = true },
}

monster.defenses = {
	defense = 74,
	armor = 65,
	{ name = "combat", interval = 3000, chance = 28, type = COMBAT_HEALING, minDamage = 800, maxDamage = 1600, effect = CONST_ME_MAGIC_GREEN, target = false },
	{ name = "speed", interval = 3800, chance = 35, speedChange = 250, effect = CONST_ME_ENERGYAREA, target = false, duration = 4500 },
}

monster.elements = {
	{ type = COMBAT_ENERGYDAMAGE, percent = 100 },
	{ type = COMBAT_EARTHDAMAGE, percent = 80 },
	{ type = COMBAT_ICEDAMAGE, percent = 55 },
	{ type = COMBAT_PHYSICALDAMAGE, percent = 35 },
	{ type = COMBAT_DEATHDAMAGE, percent = 20 },
	{ type = COMBAT_HOLYDAMAGE, percent = -10 },
	{ type = COMBAT_FIREDAMAGE, percent = -15 },
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