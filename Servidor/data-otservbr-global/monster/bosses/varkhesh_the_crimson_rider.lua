local mType = Game.createMonsterType("Varkhesh the Crimson Rider")
local monster = {}

monster.description = "varkhesh the crimson rider"
monster.experience = 420000

monster.outfit = {
	lookType = 2167,
}

monster.health = 410000
monster.maxHealth = 410000
monster.race = "blood"
monster.corpse = 6068
monster.speed = 465
monster.manaCost = 0

monster.changeTarget = {
	interval = 5200,
	chance = 38,
}

monster.strategiesTarget = {
	nearest = 50,
	health = 20,
	damage = 25,
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
	staticAttackChance = 92,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = false,
	canWalkOnPoison = true,
}

monster.light = {
	level = 7,
	color = 35,
}

monster.summon = {
	maxSummons = 8,
	summons = {
		{ name = "Dreadful Harvester", chance = 100, interval = 5000, count = 8 },
	},
}

monster.voices = {
	interval = 4300,
	chance = 17,
	{ text = "YOUR BLOOD BELONGS TO ME!", yell = true },
	{ text = "KNEEL BEFORE THE CRIMSON LORD!", yell = true },
	{ text = "I HAVE FEASTED FOR A THOUSAND YEARS!", yell = true },
}

monster.loot = {
	{ id = 58448,  chance = 100000, maxCount = 50 }, -- Endless coin
	{ name = "crystal coin", chance = 100000, maxCount = 100 },
	{ id = 36727, chance = 5800, maxCount = 1  }, --wealth duplex
	{ id = 51462, chance = 2500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 500, maxCount = 1 }, -- bag you desire
	{ id = 22755, chance = 4000}, -- book of lies
	{ id = 51589, chance = 1600, maxCount = 1 }, -- greater proficiency catalyst
	{ name = "great spirit potion", chance = 2900, maxCount = 6 },
	{ name = "ultimate mana potion", chance = 3000, minCount = 20, maxCount = 40 },
	{ name = "ultimate health potion", chance = 3500, minCount = 10, maxCount = 20 },
	{ name = "supreme health potion", chance = 2900, minCount = 5, maxCount = 10 },
	{ name = "ultimate spirit potion", chance = 3500, minCount = 2, maxCount = 14 },
	{ name = "blue gem", chance = 2900, maxCount = 2 },
	{ id = 3039, chance = 2500, maxCount = 2 }, -- red gem
	{ name = "yellow gem", chance = 2000, maxCount = 2 },
	{ id = 8154, chance = 1900 }, -- Addon doll
	{ name = "nightmare shield", chance = 1800 },
	{ name = "fire axe", chance = 1700 },
	{ name = "fire sword", chance = 1600 },
	{ name = "crypt spine", chance = 600 },
	{ name = "crypt slicer", chance = 900 },
	{ name = "crypt strike", chance = 800 },
	{ name = "death oyoroi", chance = 1400 },
	{ name = "dark whispers", chance = 1300 },
	{ name = "sanguine bow", chance = 300 },
	{ name = "spiritthorn ring", chance = 900 },
	{ name = "ghosting backpack", chance =1900 },
	{ name = "sanguine hatchet", chance = 300 },
	{ name = "sanguine coil", chance = 300 },
	{ name = "sanguine boots", chance = 300 },
}

monster.attacks = {
	{ name = "melee", interval = 1550, chance = 100, minDamage = -2600, maxDamage = -5600 },
	{ name = "combat", interval = 1900, chance = 48, type = COMBAT_LIFEDRAIN, minDamage = -2800, maxDamage = -4300, range = 8, radius = 2, shootEffect = CONST_ANI_DEATH, effect = CONST_ME_DRAWBLOOD, target = true },
	{ name = "combat", interval = 2450, chance = 43, type = COMBAT_DEATHDAMAGE, minDamage = -3200, maxDamage = -4800, length = 9, spread = 3, effect = CONST_ME_MORTAREA, target = false },
	{ name = "combat", interval = 3000, chance = 39, type = COMBAT_PHYSICALDAMAGE, minDamage = -3300, maxDamage = -4900, radius = 4, effect = CONST_ME_DRAWBLOOD, target = false },
	{ name = "combat", interval = 3400, chance = 36, type = COMBAT_MANADRAIN, minDamage = -1300, maxDamage = -2300, range = 8, shootEffect = CONST_ANI_DEATH, effect = CONST_ME_MAGIC_BLUE, target = true },
	{ name = "combat", interval = 3900, chance = 34, type = COMBAT_DEATHDAMAGE, minDamage = -3700, maxDamage = -5500, length = 12, spread = 0, effect = CONST_ME_MORTAREA, target = false },
	{ name = "combat", interval = 4500, chance = 30, type = COMBAT_LIFEDRAIN, minDamage = -4100, maxDamage = -6200, radius = 6, effect = CONST_ME_DRAWBLOOD, target = false },
	{ name = "speed", interval = 4700, chance = 28, speedChange = -650, range = 8, duration = 6000, effect = CONST_ME_MAGIC_RED, target = true },
}

monster.defenses = {
	defense = 85,
	armor = 75,
	{ name = "combat", interval = 2700, chance = 38, type = COMBAT_HEALING, minDamage = 1800, maxDamage = 3600, effect = CONST_ME_MAGIC_RED, target = false },
	{ name = "speed", interval = 3200, chance = 45, speedChange = 420, effect = CONST_ME_MAGIC_RED, target = false, duration = 5000 },
}

monster.elements = {
	{ type = COMBAT_DEATHDAMAGE, percent = 100 },
	{ type = COMBAT_LIFEDRAIN, percent = 100 },
	{ type = COMBAT_PHYSICALDAMAGE, percent = 55 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 35 },
	{ type = COMBAT_EARTHDAMAGE, percent = 25 },
	{ type = COMBAT_ICEDAMAGE, percent = 20 },
	{ type = COMBAT_FIREDAMAGE, percent = -20 },
	{ type = COMBAT_HOLYDAMAGE, percent = -35 },
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