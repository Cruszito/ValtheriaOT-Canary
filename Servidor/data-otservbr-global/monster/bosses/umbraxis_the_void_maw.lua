local mType = Game.createMonsterType("Umbraxis the Void Maw")

local monster = {}

monster.description = "umbraxis the void maw"
monster.experience = 400000
monster.outfit = { lookType = 2056 }
monster.health = 380000
monster.maxHealth = 380000
monster.race = "undead"
monster.corpse = 6068
monster.speed = 3500
monster.manaCost = 0

monster.changeTarget = { interval = 3200, chance = 42 }
monster.strategiesTarget = { nearest = 45, health = 25, damage = 25, random = 5 }

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

monster.light = { level = 3, color = 215 }

monster.summon = {
	maxSummons = 8,
	summons = {
		{ name = "Turbulent Elemental", chance = 100, interval = 7000, count = 8 },
	},
}

monster.voices = {
	interval = 4200,
	chance = 20,
	{ text = "NOTHING ESCAPES THE VOID!", yell = true },
	{ text = "I CONSUME LIGHT AND SOUL!", yell = true },
	{ text = "THE ABYSS HUNGERS!", yell = true },
}

monster.loot = {
	{ name = "crystal coin", chance = 100000, maxCount = 90 },
	{ name = "gold coin", chance = 100000, maxCount = 100 },
	{ name = "warlord sword", chance = 1100 },
	{ name = "boots of haste", chance = 9000 },
	{ name = "death oyoroi", chance = 9000 },
	{ name = "crypt jaw", chance = 1500 },
	{ name = "great spirit potion", chance = 2900, maxCount = 6 },
	{ name = "ultimate mana potion", chance = 3000, minCount = 20, maxCount = 40 },
	{ name = "ultimate health potion", chance = 3500, minCount = 10, maxCount = 20 },
	{ name = "supreme health potion", chance = 2900, minCount = 5, maxCount = 10 },
	{ name = "ultimate spirit potion", chance = 3500, minCount = 2, maxCount = 14 },
	{ id = 36727, chance = 5800 }, --wealth duplex
	{ id = 51462, chance = 2500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 800, maxCount = 1 }, -- bag you desire
	{ id = 22755, chance = 900, maxCount = 1 }, -- book of lies
	{ id = 51589, chance = 3600, maxCount = 1 }, -- greater proficiency catalyst
}

monster.attacks = {
	{ name = "melee", interval = 1900, chance = 100, minDamage = -2100, maxDamage = -4800, effect = CONST_ME_DRAWBLOOD },
	{ name = "combat", interval = 2100, chance = 43, type = COMBAT_DEATHDAMAGE, minDamage = -2500, maxDamage = -3700, range = 9, shootEffect = CONST_ANI_DEATH, effect = CONST_ME_MORTAREA, target = true },
	{ name = "combat", interval = 2800, chance = 34, type = COMBAT_MANADRAIN, minDamage = -1400, maxDamage = -2300, radius = 5, effect = CONST_ME_MAGIC_BLUE, target = false },
	{ name = "combat", interval = 3400, chance = 34, type = COMBAT_LIFEDRAIN, minDamage = -2700, maxDamage = -4000, length = 9, spread = 2, effect = CONST_ME_MAGIC_RED, target = false },
	{ name = "combat", interval = 4100, chance = 30, type = COMBAT_DEATHDAMAGE, minDamage = -3200, maxDamage = -4600, length = 11, spread = 0, effect = CONST_ME_MORTAREA, target = false },
	{ name = "combat", interval = 5000, chance = 26, type = COMBAT_ENERGYDAMAGE, minDamage = -3500, maxDamage = -5000, range = 7, radius = 4, shootEffect = CONST_ANI_ENERGY, effect = CONST_ME_ENERGYAREA, target = true },
	{ name = "speed", interval = 5200, chance = 25, speedChange = -650, range = 8, duration = 6000, effect = CONST_ME_MORTAREA, target = true },
}

monster.defenses = {
	defense = 82,
	armor = 75,
	{ name = "combat", interval = 2800, chance = 30, type = COMBAT_HEALING, minDamage = 900, maxDamage = 1850, effect = CONST_ME_MAGIC_RED, target = false },
	{ name = "speed", interval = 4500, chance = 24, speedChange = 320, duration = 6000, effect = CONST_ME_PURPLEENERGY, target = false },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 45 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 75 },
	{ type = COMBAT_EARTHDAMAGE, percent = 30 },
	{ type = COMBAT_FIREDAMAGE, percent = 10 },
	{ type = COMBAT_ICEDAMAGE, percent = 0 },
	{ type = COMBAT_DEATHDAMAGE, percent = 100 }, -- Complete immunity to death damage
	{ type = COMBAT_LIFEDRAIN, percent = 100 },
	{ type = COMBAT_MANADRAIN, percent = 100 },
	{ type = COMBAT_HOLYDAMAGE, percent = -35 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = true },
	{ type = "poison", condition = true },
}

monster.events = { "CustomQuestBossDeathTeleport" }

mType:register(monster)