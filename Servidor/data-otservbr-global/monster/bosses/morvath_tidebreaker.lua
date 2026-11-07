local mType = Game.createMonsterType("Morvath Tidebreaker")
local monster = {}

monster.description = "morvath tidebreaker"
monster.experience = 360000
monster.outfit = { lookType = 2524 }

monster.health = 360000
monster.maxHealth = 360000
monster.race = "blood"
monster.corpse = 6068
monster.speed = 315
monster.manaCost = 0

monster.changeTarget = { interval = 3000, chance = 40 }
monster.strategiesTarget = { nearest = 20, health = 50, damage = 25, random = 5 }

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
	canWalkOnEnergy = false,
	canWalkOnFire = false,
	canWalkOnPoison = true,
}

monster.light = { level = 6, color = 86 }

monster.summon = {
	maxSummons = 8,
	summons = {
		{ name = "Turbulent Elemental", chance = 100, interval = 5000, count = 8 },
	},
}

monster.voices = {
	interval = 5000,
	chance = 13,
	{ text = "THE DEEP CLAIMS ALL!", yell = true },
	{ text = "DROWN BENEATH MY TIDE!", yell = true },
}

monster.loot = {
	{ name = "life crystal", chance = 890 },
	{ name = "shard", chance = 520 },
	{ name = "ice rapier", chance = 310 },
	{ id = 7441, chance = 100000 }, -- ice cube
	{ id = 58448,  chance = 100000, maxCount = 50 }, -- Endless coin
	{ name = "crystal coin", chance = 100000, maxCount = 100 },
	{ name = "white pearl", chance = 35000, maxCount = 6 },
	{ name = "Golden boots", chance = 3500, maxCount = 1 },
	{ id = 36727, chance = 5800, maxCount = 1  }, --wealth duplex
	{ id = 51462, chance = 2500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 700, maxCount = 1 }, -- bag you desire
	{ id = 22755, chance = 900, maxCount = 1 }, -- book of lies
	{ id = 51589, chance = 1600, maxCount = 1 }, -- greater proficiency catalyst
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
	{ name = "melee", interval = 2000, chance = 100, minDamage = -1700, maxDamage = -4200 },
	{ name = "combat", interval = 2400, chance = 35, type = COMBAT_DROWNDAMAGE, minDamage = -2100, maxDamage = -3300, range = 8, radius = 3, shootEffect = CONST_ANI_ICE, effect = CONST_ME_WATERSPLASH, target = true },
	{ name = "combat", interval = 3000, chance = 30, type = COMBAT_ICEDAMAGE, minDamage = -2400, maxDamage = -3700, length = 8, spread = 2, effect = CONST_ME_ICEAREA, target = false },
	{ name = "combat", interval = 3800, chance = 24, type = COMBAT_EARTHDAMAGE, minDamage = -2600, maxDamage = -4000, radius = 5, effect = CONST_ME_GROUNDSHAKER, target = false },
	{ name = "combat", interval = 3600, chance = 22, type = COMBAT_LIFEDRAIN, minDamage = -2200, maxDamage = -3500, length = 8, spread = 3, effect = CONST_ME_MORTAREA, target = false },
	{ name = "combat", interval = 5000, chance = 18, type = COMBAT_DROWNDAMAGE, minDamage = -3200, maxDamage = -4600, length = 9, spread = 4, effect = CONST_ME_WATERSPLASH, target = false },
	{ name = "combat", interval = 3300, chance = 18, type = COMBAT_PHYSICALDAMAGE, minDamage = -1700, maxDamage = -2800, radius = 3, effect = CONST_ME_GROUNDSHAKER, target = false },
	{ name = "speed", interval = 4200, chance = 24, speedChange = -650, range = 8, duration = 6500, effect = CONST_ME_ICEATTACK, target = true },
}

monster.defenses = {
	defense = 82,
	armor = 76,
	{ name = "combat", interval = 3200, chance = 25, type = COMBAT_HEALING, minDamage = 900, maxDamage = 1800, effect = CONST_ME_WATERSPLASH, target = false },
	{ name = "speed", interval = 4500, chance = 28, speedChange = 380, duration = 5000, effect = CONST_ME_MAGIC_RED, target = false },
}


monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 25 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 0 },
	{ type = COMBAT_EARTHDAMAGE, percent = 50 },
	{ type = COMBAT_FIREDAMAGE, percent = 100 },
	{ type = COMBAT_LIFEDRAIN, percent = 100 },
	{ type = COMBAT_MANADRAIN, percent = 25 },
	{ type = COMBAT_DROWNDAMAGE, percent = 90 },
	{ type = COMBAT_ICEDAMAGE, percent = 100 },
	{ type = COMBAT_HOLYDAMAGE, percent = 25 },
	{ type = COMBAT_DEATHDAMAGE, percent = 35 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = true },
}

monster.events = { "CustomQuestBossDeathTeleport" }

mType:register(monster)
