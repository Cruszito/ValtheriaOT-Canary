local mType = Game.createMonsterType("Korvul Duskclaw")
local monster = {}

monster.description = "korvul duskclaw"
monster.experience = 315000
monster.outfit = { lookType = 2169 }

monster.health = 450000
monster.maxHealth = 450000
monster.race = "blood"
monster.corpse = 6068
monster.speed = 438
monster.manaCost = 0

monster.changeTarget = { interval = 6100, chance = 33 }
monster.strategiesTarget = { nearest = 50, health = 25, damage = 20, random = 5 }

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
	staticAttackChance = 89,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.light = { level = 3, color = 215 }

monster.summon = {
	maxSummons = 8,
	summons = {
		{ name = "Skeleton Elite Warrior", chance = 100, interval = 5000, count = 8 },
	},
}

monster.voices = {
	interval = 4600,
	chance = 15,
	{ text = "DUSK HIDES MY CLAWS!", yell = true },
	{ text = "RUN, LITTLE PREY!", yell = true },
}

monster.loot = {
	{ name = "stone skin amulet", chance = 8900 },
	{ name = "strange helmet", chance = 9000 },
	{ name = "underworld rod", chance = 9600 },
    { name = "great spirit potion", chance = 9900, maxCount = 6},
	{ name = "ultimate mana potion", chance = 9000, minCount = 20, maxCount = 40 },
	{ name = "ultimate health potion", chance = 9500, minCount = 10, maxCount = 20 },
	{ name = "supreme health potion", chance = 9900, minCount = 5, maxCount = 10 },
	{ name = "ultimate spirit potion", chance = 9500, minCount = 2, maxCount = 14 },
	{ name = "blue gem", chance = 8900, maxCount = 2 },
	{ id = 36019, chance = 300, maxCount = 1 },
	{ id = 3039, chance = 2500, maxCount = 2 }, -- red gem
	{ name = "lion figurine", chance = 12000, maxCount = 2 },
	{ id = 6299, chance = 1900 }, -- death ring
	{ name = "devil helmet", chance = 9800 },
	{ name = "fire axe", chance = 8700 },
	{ name = "lion axe", chance = 4600 },
	{ name = "lion amulet", chance = 6500 },
	{ name = "crypt spine", chance = 400 },
	{ name = "crypt bile", chance = 900 },
	{ id = 58448,  chance = 100000, maxCount = 100 }, -- Endless coin
	{ name = "crystal coin", chance = 100000, maxCount = 100 },
	{ id = 36727, chance = 9800, maxCount = 1  }, --wealth duplex
	{ id = 51462, chance = 6500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 400, maxCount = 1 }, -- bag you desire
	{ id = 51589, chance = 6600, maxCount = 1 }, -- greater proficiency catalyst
}

monster.attacks = {
	{ name = "melee", interval = 1500, chance = 100, minDamage = -1700, maxDamage = -4200 },
	{ name = "combat", interval = 1900, chance = 47, type = COMBAT_PHYSICALDAMAGE, minDamage = -2200, maxDamage = -3350, range = 6, shootEffect = CONST_ANI_WHIRLWINDSWORD, effect = CONST_ME_HITAREA, target = true },
	{ name = "combat", interval = 2400, chance = 42, type = COMBAT_PHYSICALDAMAGE, minDamage = -2450, maxDamage = -3750, length = 7, spread = 3, effect = CONST_ME_GROUNDSHAKER, target = false },
	{ name = "combat", interval = 2900, chance = 38, type = COMBAT_HOLYDAMAGE, minDamage = -2500, maxDamage = -3800, range = 7, radius = 2, shootEffect = CONST_ANI_HOLY, effect = CONST_ME_HOLYDAMAGE, target = true },
	{ name = "combat", interval = 3400, chance = 35, type = COMBAT_EARTHDAMAGE, minDamage = -2700, maxDamage = -4000, radius = 3, effect = CONST_ME_GROUNDSHAKER, target = false },
	{ name = "combat", interval = 4000, chance = 30, type = COMBAT_PHYSICALDAMAGE, minDamage = -2900, maxDamage = -4200, radius = 4, effect = CONST_ME_DRAWBLOOD, target = false },
	{ name = "speed", interval = 4500, chance = 27, speedChange = -480, range = 7, duration = 5000, effect = CONST_ME_GROUNDSHAKER, target = true },
}

monster.defenses = {
	defense = 72,
	armor = 64,
	{ name = "combat", interval = 3200, chance = 26, type = COMBAT_HEALING, minDamage = 700, maxDamage = 1400, effect = CONST_ME_HOLYDAMAGE, target = false },
	{ name = "speed", interval = 3000, chance = 45, speedChange = 380, effect = CONST_ME_MAGIC_RED, target = false, duration = 5000 },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 45 },
	{ type = COMBAT_EARTHDAMAGE, percent = 50 },
	{ type = COMBAT_HOLYDAMAGE, percent = 60 },
	{ type = COMBAT_FIREDAMAGE, percent = 20 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 20 },
	{ type = COMBAT_DEATHDAMAGE, percent = -10 },
	{ type = COMBAT_ICEDAMAGE, percent = -5 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = true },
}

monster.events = { "CustomQuestBossDeathTeleport" }

mType:register(monster)
