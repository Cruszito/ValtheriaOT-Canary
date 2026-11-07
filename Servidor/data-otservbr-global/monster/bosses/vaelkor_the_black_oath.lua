local mType = Game.createMonsterType("Vaelkor the Black Oath")
local monster = {}

monster.description = "vaelkor the black oath"
monster.experience = 310000
monster.outfit = { lookType = 2231 }

monster.health = 658000
monster.maxHealth = 658000
monster.race = "undead"
monster.corpse = 6068
monster.speed = 210
monster.manaCost = 0

monster.changeTarget = { interval = 9000, chance = 25 }
monster.strategiesTarget = { nearest = 65, health = 15, damage = 15, random = 5 }

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
	staticAttackChance = 95,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.light = { level = 4, color = 215 }

monster.summon = {
	maxSummons = 8,
	summons = {
		{ name = "Dreadful Harvester", chance = 100, interval = 8000, count = 8 },
	},
}

monster.voices = {
    interval = 4800,
    chance = 15,
    { text = "YOUR SENTENCE IS DEATH!", yell = true },
    { text = "KNEEL BEFORE THE EXECUTIONER!", yell = true },
    { text = "THE BLACK AXE CLAIMS ANOTHER!", yell = true },
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
    { name = "melee", interval = 1800, chance = 100, minDamage = -1750, maxDamage = -4300 },
    { name = "combat", interval = 2100, chance = 44, type = COMBAT_PHYSICALDAMAGE, minDamage = -2250, maxDamage = -3400, length = 7, spread = 3, effect = CONST_ME_HITAREA, target = false },
    { name = "combat", interval = 2600, chance = 40, type = COMBAT_DEATHDAMAGE, minDamage = -2400, maxDamage = -3550, range = 7, radius = 2, shootEffect = CONST_ANI_DEATH, effect = CONST_ME_MORTAREA, target = true },
    { name = "combat", interval = 3100, chance = 35, type = COMBAT_PHYSICALDAMAGE, minDamage = -2700, maxDamage = -3900, radius = 3, effect = CONST_ME_GROUNDSHAKER, target = false },
    { name = "combat", interval = 3700, chance = 31, type = COMBAT_LIFEDRAIN, minDamage = -2600, maxDamage = -3850, range = 6, radius = 2, shootEffect = CONST_ANI_DEATH, effect = CONST_ME_MAGIC_RED, target = true },
    { name = "combat", interval = 4400, chance = 28, type = COMBAT_DEATHDAMAGE, minDamage = -3200, maxDamage = -4650, length = 8, spread = 3, effect = CONST_ME_MORTAREA, target = false },
    { name = "combat", interval = 5200, chance = 23, type = COMBAT_PHYSICALDAMAGE, minDamage = -3500, maxDamage = -4900, range = 5, radius = 2, shootEffect = CONST_ANI_DEATH, effect = CONST_ME_EXPLOSIONAREA, target = true },
    { name = "speed", interval = 4800, chance = 26, speedChange = -500, range = 7, duration = 5500, effect = CONST_ME_MAGIC_RED, target = true },
}

monster.defenses = {
    defense = 78,
    armor = 70,
    { name = "combat", interval = 3000, chance = 28, type = COMBAT_HEALING, minDamage = 650, maxDamage = 1350, effect = CONST_ME_MAGIC_RED, target = false },
}

monster.elements = {
    { type = COMBAT_DEATHDAMAGE, percent = 100 },
    { type = COMBAT_LIFEDRAIN, percent = 75 },
    { type = COMBAT_PHYSICALDAMAGE, percent = 55 },
    { type = COMBAT_MANADRAIN, percent = 50 },
    { type = COMBAT_ENERGYDAMAGE, percent = 25 },
    { type = COMBAT_FIREDAMAGE, percent = 10 },
    { type = COMBAT_HOLYDAMAGE, percent = -25 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = true },
}

monster.events = { "CustomQuestBossDeathTeleport" }

mType:register(monster)
