local mType = Game.createMonsterType("Noxhyr Frostfang")
local monster = {}

monster.description = "noxhyr frostfang"
monster.experience = 335000
monster.outfit = { lookType = 2427 }

monster.health = 350000
monster.maxHealth = 350000
monster.race = "blood"
monster.corpse = 6068
monster.speed = 235
monster.manaCost = 0

monster.changeTarget = { interval = 6500, chance = 30 }
monster.strategiesTarget = { nearest = 55, health = 20, damage = 20, random = 5 }

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
	staticAttackChance = 92,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = false,
	canWalkOnPoison = true,
}

monster.light = { level = 6, color = 89 }

monster.voices = {
	interval = 4600,
	chance = 13,
	{ text = "THE WINTER HUNTS WITH ME!", yell = true },
	{ text = "FREEZE WHERE YOU STAND!", yell = true },
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
	{ name = "melee", interval = 1700, chance = 100, minDamage = -1650, maxDamage = -4000 },
	{ name = "combat", interval = 2000, chance = 44, type = COMBAT_ICEDAMAGE, minDamage = -2200, maxDamage = -3300, range = 8, radius = 3, shootEffect = CONST_ANI_ICE, effect = CONST_ME_ICEAREA, target = true },
	{ name = "combat", interval = 2700, chance = 38, type = COMBAT_ICEDAMAGE, minDamage = -2600, maxDamage = -3900, length = 7, spread = 4, effect = CONST_ME_ICEAREA, target = false },
	{ name = "combat", interval = 3400, chance = 33, type = COMBAT_ENERGYDAMAGE, minDamage = -2400, maxDamage = -3700, length = 9, spread = 0, effect = CONST_ME_ENERGYAREA, target = false },
	{ name = "combat", interval = 3900, chance = 29, type = COMBAT_PHYSICALDAMAGE, minDamage = -3000, maxDamage = -4300, range = 5, shootEffect = CONST_ANI_ICE, effect = CONST_ME_HITAREA, target = true },
	{ name = "speed", interval = 4300, chance = 28, speedChange = -600, range = 8, duration = 6500, effect = CONST_ME_MAGIC_BLUE, target = true },
}

monster.defenses = {
	defense = 66,
	armor = 60,
	{ name = "combat", interval = 2800, chance = 30, type = COMBAT_HEALING, minDamage = 550, maxDamage = 1250, effect = CONST_ME_MAGIC_BLUE, target = false },
}

monster.elements = {
	{ type = COMBAT_ICEDAMAGE, percent = 100 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 60 },
	{ type = COMBAT_PHYSICALDAMAGE, percent = 30 },
	{ type = COMBAT_EARTHDAMAGE, percent = 25 },
	{ type = COMBAT_DEATHDAMAGE, percent = 25 },
	{ type = COMBAT_FIREDAMAGE, percent = -25 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = true },
}

monster.events = { "CustomQuestBossDeathTeleport" }

mType:register(monster)
