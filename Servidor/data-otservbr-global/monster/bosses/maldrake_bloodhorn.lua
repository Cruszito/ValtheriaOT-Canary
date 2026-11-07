local mType = Game.createMonsterType("Maldrake Bloodhorn")
local monster = {}

monster.description = "maldrake bloodhorn"
monster.experience = 320000
monster.outfit = { lookType = 2233 }

monster.health = 460000
monster.maxHealth = 460000
monster.race = "blood"
monster.corpse = 6068
monster.speed = 260
monster.manaCost = 0

monster.changeTarget = { interval = 7000, chance = 28 }
monster.strategiesTarget = { nearest = 60, health = 20, damage = 15, random = 5 }

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
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.race = "energy"
monster.light = { level = 8, color = 87 }

monster.summon = {
	maxSummons = 6,
	summons = {
		{ name = "Skeleton Elite Warrior", chance = 100, interval = 8000, count = 6 },
	},
}

monster.voices = {
    interval = 4600,
    chance = 16,
    { text = "THE THUNDER ANSWERS MY CALL!", yell = true },
    { text = "FACE THE WRATH OF THE STORM!", yell = true },
    { text = "MY HAMMER WILL BREAK THE SKIES!", yell = true },
}

monster.loot = {
	{ id = 58448,  chance = 100000, maxCount = 100 }, -- Endless coin
	{ id = 36727, chance = 9800, maxCount = 1  }, --wealth duplex
	{ id = 51462, chance = 6500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 400, maxCount = 1 }, -- bag you desire
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
    { name = "melee", interval = 1700, chance = 100, minDamage = -1850, maxDamage = -4350 },
    { name = "combat", interval = 1950, chance = 48, type = COMBAT_ENERGYDAMAGE, minDamage = -2200, maxDamage = -3350, range = 8, shootEffect = CONST_ANI_ENERGY, effect = CONST_ME_ENERGYAREA, target = true },
    { name = "combat", interval = 2450, chance = 42, type = COMBAT_PHYSICALDAMAGE, minDamage = -2450, maxDamage = -3650, radius = 3, effect = CONST_ME_GROUNDSHAKER, target = false },
    { name = "combat", interval = 3000, chance = 38, type = COMBAT_ENERGYDAMAGE, minDamage = -2700, maxDamage = -4000, length = 10, spread = 0, effect = CONST_ME_ENERGYAREA, target = false },
    { name = "combat", interval = 3650, chance = 34, type = COMBAT_ENERGYDAMAGE, minDamage = -2950, maxDamage = -4250, range = 7, radius = 3, shootEffect = CONST_ANI_ENERGY, effect = CONST_ME_ENERGYAREA, target = true },
    { name = "combat", interval = 4300, chance = 29, type = COMBAT_PHYSICALDAMAGE, minDamage = -3150, maxDamage = -4550, length = 7, spread = 4, effect = CONST_ME_HITAREA, target = false },
    { name = "combat", interval = 5100, chance = 24, type = COMBAT_ENERGYDAMAGE, minDamage = -3400, maxDamage = -4800, radius = 6, effect = CONST_ME_ENERGYAREA, target = false },
    { name = "speed", interval = 4500, chance = 27, speedChange = -500, range = 7, duration = 5000, effect = CONST_ME_ENERGYAREA, target = true },
}

monster.defenses = {
    defense = 76,
    armor = 69,
    { name = "combat", interval = 3000, chance = 29, type = COMBAT_HEALING, minDamage = 700, maxDamage = 1450, effect = CONST_ME_MAGIC_BLUE, target = false },
    { name = "speed", interval = 4200, chance = 28, speedChange = 250, duration = 4000, effect = CONST_ME_ENERGYAREA, target = false },
}

monster.elements = {
    { type = COMBAT_ENERGYDAMAGE, percent = 100 },
    { type = COMBAT_PHYSICALDAMAGE, percent = 55 },
    { type = COMBAT_HOLYDAMAGE, percent = 35 },
    { type = COMBAT_FIREDAMAGE, percent = 20 },
    { type = COMBAT_DEATHDAMAGE, percent = 10 },
    { type = COMBAT_EARTHDAMAGE, percent = -20 },
    { type = COMBAT_ICEDAMAGE, percent = -15 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = true },
}

monster.events = { "CustomQuestBossDeathTeleport" }

mType:register(monster)
