local mType = Game.createMonsterType("Rhazgor Ironmaw")
local monster = {}

monster.description = "rhazgor ironmaw"
monster.experience = 325000
monster.outfit = { lookType = 2232 }

monster.health = 460000
monster.maxHealth = 460000
monster.race = "blood"
monster.corpse = 6068
monster.speed = 205
monster.manaCost = 0

monster.changeTarget = { interval = 8000, chance = 22 }
monster.strategiesTarget = { nearest = 75, health = 5, damage = 15, random = 5 }

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
	staticAttackChance = 97,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.light = { level = 3, color = 207 }

monster.summon = {
	maxSummons = 6,
	summons = {
		{ name = "Dreadful Harvester", chance = 100, interval = 8000, count = 6 },
	},
}

monster.voices = {
    interval = 5000,
    chance = 14,
    { text = "MY SPEAR HAS ENDED KINGDOMS!", yell = true },
    { text = "THE FROZEN NORTH MARCHES WITH ME!", yell = true },
    { text = "YOUR BONES WILL FEED THE TUNDRA!", yell = true },
}

monster.loot = {
	{ id = 58448,  chance = 100000, maxCount = 100 }, -- Endless coin
	{ id = 36727, chance = 9800, maxCount = 1  }, --wealth duplex
	{ id = 51462, chance = 6500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 800, maxCount = 1 }, -- bag you desire
	{ id = 51589, chance = 6600, maxCount = 1 }, -- greater proficiency catalyst
	{ name = "crystal coin", chance = 100000, maxCount = 100 },
	{ name = "gold coin", chance = 50000, maxCount = 100 },
	{ name = "gold coin", chance = 40000, maxCount = 99 },
	{ name = "platinum coin", chance = 55000, maxCount = 8 },
	{ name = "golden legs", chance = 30 },
	{ id = 3461, chance = 5250 }, -- saw
	{ name = "steel boots", chance = 5050 },
	{ name = "ham", chance = 60000, maxCount = 2 },
	{ name = "orichalcum pearl", chance = 2760, maxCount = 2 },
	{ name = "cat's paw", chance = 2222 },
	{ name = "jewelled backpack", chance = 1192 },
	{ name = "soul orb", chance = 23000 },
	{ id = 6299, chance = 2008 }, -- death ring
	{ name = "demonic essence", chance = 8520 },
	{ name = "flask of demonic blood", chance = 33333, maxCount = 3 },
	{ name = "assassin star", chance = 2222, maxCount = 5 },
	{ name = "vile axe", chance = 480 },
	{ name = "butcher's axe", chance = 850 },
	{ id = 238,  chance = 14830, maxCount = 2 },
	{ name = "great health potion", chance = 10000, maxCount = 2 },
	{ name = "gold ingot", chance = 3140 },
	{ name = "demon shield", chance = 3370 },
	{ name = "magic plate armor", chance = 8570 },
	{ name = "golden legs", chance = 5620 },
	{ name = "demonrage sword", chance = 3530 },
	{ name = "great axe", chance = 2530 },
}

monster.attacks = {
    { name = "melee", interval = 1750, chance = 100, minDamage = -1950, maxDamage = -4450 },
    { name = "combat", interval = 2050, chance = 47, type = COMBAT_PHYSICALDAMAGE, minDamage = -2300, maxDamage = -3450, range = 7, shootEffect = CONST_ANI_SPEAR, effect = CONST_ME_HITAREA, target = true },
    { name = "combat", interval = 2550, chance = 42, type = COMBAT_PHYSICALDAMAGE, minDamage = -2500, maxDamage = -3700, length = 8, spread = 2, effect = CONST_ME_HITAREA, target = false },
    { name = "combat", interval = 3150, chance = 37, type = COMBAT_EARTHDAMAGE, minDamage = -2700, maxDamage = -3950, radius = 4, effect = CONST_ME_GROUNDSHAKER, target = false },
    { name = "combat", interval = 3750, chance = 33, type = COMBAT_ICEDAMAGE, minDamage = -2750, maxDamage = -4050, range = 7, radius = 3, shootEffect = CONST_ANI_ICE, effect = CONST_ME_ICEAREA, target = true },
    { name = "combat", interval = 4400, chance = 29, type = COMBAT_PHYSICALDAMAGE, minDamage = -3150, maxDamage = -4550, length = 9, spread = 4, effect = CONST_ME_GROUNDSHAKER, target = false },
    { name = "combat", interval = 5200, chance = 24, type = COMBAT_ICEDAMAGE, minDamage = -3300, maxDamage = -4750, radius = 6, effect = CONST_ME_ICEAREA, target = false },
    { name = "speed", interval = 4600, chance = 27, speedChange = -480, range = 7, duration = 5000, effect = CONST_ME_ICEAREA, target = true },
}

monster.defenses = {
	defense = 78,
	armor = 70,
	{ name = "combat", interval = 3000, chance = 25, type = COMBAT_HEALING, minDamage = 700, maxDamage = 1400, effect = CONST_ME_MAGIC_GREEN, target = false },
}

monster.elements = {
    { type = COMBAT_PHYSICALDAMAGE, percent = 75 },
    { type = COMBAT_ICEDAMAGE, percent = 70 },
    { type = COMBAT_EARTHDAMAGE, percent = 55 },
    { type = COMBAT_DEATHDAMAGE, percent = 25 },
    { type = COMBAT_ENERGYDAMAGE, percent = 15 },
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
