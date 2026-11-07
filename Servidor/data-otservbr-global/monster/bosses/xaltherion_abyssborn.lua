local mType = Game.createMonsterType("Xaltherion Abyssborn")
local monster = {}

monster.description = "xaltherion abyssborn"
monster.experience = 390000
monster.outfit = { lookType = 2522 }

monster.health = 360000
monster.maxHealth = 360000
monster.race = "undead"
monster.corpse = 6068
monster.speed = 220
monster.manaCost = 0

monster.changeTarget = { interval = 8500, chance = 28 }
monster.strategiesTarget = { nearest = 60, health = 15, damage = 20, random = 5 }

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
	staticAttackChance = 94,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.light = { level = 7, color = 190 }

monster.voices = {
	interval = 5200,
	chance = 15,
	{ text = "THE ABYSS REMEMBERS YOUR NAME!", yell = true },
	{ text = "SINK INTO ETERNAL NIGHT!", yell = true },
}

monster.loot = {
	{ id = 51589, chance = 13500, maxCount = 10 }, -- proficiency catalist
	{ id = 3025, chance = 13500 }, -- ancient amulet
	{ id = 3116, chance = 19000 }, -- big bone
	{ name = "black pearl", chance = 15000, maxCount = 35 },
	{ name = "boots of haste", chance = 14000 },
	{ id = 3076, chance = 22500 }, -- crystal ball
	{ name = "crystal necklace", chance = 21500 },
	{ id = 3007, chance = 15500 }, -- crystal ring
	{ name = "demon shield", chance = 15500 },
	{ name = "devil helmet", chance = 11000 },
	{ name = "dragon hammer", chance = 34500 },
	{ id = 3051, chance = 13500 }, -- energy ring
	{ name = "fire axe", chance = 17000 },
	{ name = "giant sword", chance = 12500 },
	{ name = "platinum coin", chance = 69900, maxCount = 100 },
	{ name = "platinum coin", chance = 68800, maxCount = 100 },
	{ name = "crystal coin", chance = 47700, maxCount = 40 },
	{ name = "crystal coin", chance = 36600, maxCount = 15 },
	{ name = "gold ring", chance = 28000 },
	{ name = "golden legs", chance = 15000 },
	{ name = "giant ruby", chance = 31500 },
	{ name = "giant sapphire", chance = 31500 },
	{ name = "giant emerald", chance = 31500 },
	{ name = "ice rapier", chance = 27500 },
	{ name = "magic plate armor", chance = 13000 },
	{ name = "mastermind shield", chance = 17500 },
	{ name = "purple tome", chance = 12600 },
	{ name = "ring of the sky", chance = 13500 },
	{ name = "silver dagger", chance = 15500 },
	{ name = "skull staff", chance = 25000 },
	{ name = "talon", chance = 14000, maxCount = 27 },
	{ name = "teddy bear", chance = 10500 },
	{ name = "thunder hammer", chance = 3500 },
	{ id = 3002, chance = 5100 }, -- voodoo doll
	{ id = 46626, chance = 5100, maxCount = 50  }, --greater fragment
    { id = 46625, chance = 5100, maxCount = 80  }, --lesser fragment
	{ name = "white pearl", chance = 12500, maxCount = 35 },
}

monster.attacks = {
	{ name = "melee", interval = 1950, chance = 100, minDamage = -2000, maxDamage = -4700 },
	{ name = "combat", interval = 2200, chance = 43, type = COMBAT_DEATHDAMAGE, minDamage = -2700, maxDamage = -3900, range = 8, radius = 4, shootEffect = CONST_ANI_DEATH, effect = CONST_ME_MORTAREA, target = true },
	{ name = "combat", interval = 2800, chance = 37, type = COMBAT_ENERGYDAMAGE, minDamage = -2600, maxDamage = -3800, length = 10, spread = 0, effect = CONST_ME_ENERGYAREA, target = false },
	{ name = "combat", interval = 3600, chance = 34, type = COMBAT_LIFEDRAIN, minDamage = -2500, maxDamage = -3700, radius = 5, effect = CONST_ME_MAGIC_RED, target = false },
	{ name = "combat", interval = 4100, chance = 31, type = COMBAT_MANADRAIN, minDamage = -1500, maxDamage = -2400, length = 8, spread = 3, effect = CONST_ME_MAGIC_BLUE, target = false },
	{ name = "combat", interval = 4900, chance = 27, type = COMBAT_DEATHDAMAGE, minDamage = -3600, maxDamage = -5100, length = 9, spread = 4, effect = CONST_ME_MORTAREA, target = false },
}

monster.defenses = {
	defense = 80,
	armor = 72,
	{ name = "combat", interval = 2500, chance = 35, type = COMBAT_HEALING, minDamage = 850, maxDamage = 1750, effect = CONST_ME_MAGIC_RED, target = false },
}

monster.elements = {
	{ type = COMBAT_DEATHDAMAGE, percent = 100 },
	{ type = COMBAT_LIFEDRAIN, percent = 100 },
	{ type = COMBAT_MANADRAIN, percent = 80 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 70 },
	{ type = COMBAT_PHYSICALDAMAGE, percent = 40 },
	{ type = COMBAT_HOLYDAMAGE, percent = -30 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = true },
}

monster.events = { "CustomQuestBossDeathTeleport" }

mType:register(monster)
