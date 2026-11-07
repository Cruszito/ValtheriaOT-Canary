local mType = Game.createMonsterType("Glacior the Shattered")
local monster = {}

monster.description = "glacior the shattered"
monster.experience = 410000

monster.outfit = {
	lookType = 2168,
}

monster.health = 400000
monster.maxHealth = 400000
monster.race = "undead"
monster.corpse = 6068
monster.speed = 235
monster.manaCost = 0

monster.changeTarget = {
	interval = 5600,
	chance = 35,
}

monster.strategiesTarget = {
	nearest = 55,
	health = 20,
	damage = 20,
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
	staticAttackChance = 93,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = false,
	canWalkOnPoison = false,
}

monster.light = {
	level = 8,
	color = 89,
}

monster.summon = {
	maxSummons = 8,
	summons = {
		{ name = "Many Faces", chance = 100, interval = 5000, count = 8 },
	},
}

monster.voices = {
	interval = 4600,
	chance = 16,
	{ text = "DROWN BENEATH THE FROZEN TIDE!", yell = true },
	{ text = "THE OCEAN ITSELF OBEYS ME!", yell = true },
	{ text = "SHATTER LIKE THIN ICE!", yell = true },
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
	{ id = 34109, chance = 3800, maxCount = 1 }, -- bag you desire
	{ id = 51589, chance = 6600, maxCount = 1 }, -- greater proficiency catalyst
	{ name = "crypt slicer", chance = 1600 },
	{ name = "robe of the ice queen", chance = 2300 },
	{ name = "runic ice shield", chance = 2100 },
	{ name = "twiceslicer", chance = 9100 },
	{ name = "ice ward ring", chance = 1800 },
	{ name = "ice robe", chance = 2900 },
	{ name = "glacier robe", chance = 9900 },
	
}

monster.attacks = {
	{ name = "melee", interval = 1700, chance = 100, minDamage = -2400, maxDamage = -5200 },
	{ name = "combat", interval = 1950, chance = 48, type = COMBAT_ICEDAMAGE, minDamage = -2700, maxDamage = -4200, radius = 4, effect = CONST_ME_ICEAREA, target = false },
	{ name = "combat", interval = 2300, chance = 44, type = COMBAT_DROWNDAMAGE, minDamage = -3000, maxDamage = -4500, range = 8, radius = 3, shootEffect = CONST_ANI_ICE, effect = CONST_ME_WATERSPLASH, target = true },
	{ name = "combat", interval = 2800, chance = 41, type = COMBAT_ICEDAMAGE, minDamage = -3200, maxDamage = -4800, length = 9, spread = 3, effect = CONST_ME_ICEAREA, target = false },
	{ name = "combat", interval = 3300, chance = 37, type = COMBAT_DROWNDAMAGE, minDamage = -3400, maxDamage = -5000, length = 11, spread = 0, effect = CONST_ME_WATERSPLASH, target = false },
	{ name = "combat", interval = 3900, chance = 34, type = COMBAT_ICEDAMAGE, minDamage = -3700, maxDamage = -5400, range = 8, radius = 5, shootEffect = CONST_ANI_ICE, effect = CONST_ME_ICEAREA, target = true },
	{ name = "combat", interval = 4600, chance = 30, type = COMBAT_DROWNDAMAGE, minDamage = -4200, maxDamage = -6200, radius = 6, effect = CONST_ME_WATERSPLASH, target = false },
	{ name = "speed", interval = 4200, chance = 32, speedChange = -700, range = 8, duration = 7000, effect = CONST_ME_ICEAREA, target = true },
}

monster.defenses = {
	defense = 88,
	armor = 80,
	{ name = "combat", interval = 2800, chance = 34, type = COMBAT_HEALING, minDamage = 1400, maxDamage = 3000, effect = CONST_ME_ICEAREA, target = false },
	{ name = "speed", interval = 3500, chance = 38, speedChange = 350, effect = CONST_ME_WATERSPLASH, target = false, duration = 5000 },
}

monster.elements = {
	{ type = COMBAT_ICEDAMAGE, percent = 100 },
	{ type = COMBAT_DROWNDAMAGE, percent = 100 },
	{ type = COMBAT_PHYSICALDAMAGE, percent = 45 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 35 },
	{ type = COMBAT_DEATHDAMAGE, percent = 40 },
	{ type = COMBAT_EARTHDAMAGE, percent = 30 },
	{ type = COMBAT_HOLYDAMAGE, percent = -15 },
	{ type = COMBAT_FIREDAMAGE, percent = -35 },
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