local mType = Game.createMonsterType("Aeralith Skyreaver")
local monster = {}

monster.description = "aeralith skyreaver"
monster.experience = 400000

monster.outfit = {
	lookType = 2166,
}

monster.health = 390000
monster.maxHealth = 390000
monster.race = "energy"
monster.corpse = 6068
monster.speed = 270
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
	staticAttackChance = 90,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = false,
	canWalkOnPoison = false,
}

-- Luz amarilla para darle apariencia sagrada
monster.light = {
	level = 9,
	color = 210,
}

monster.summon = {
	maxSummons = 5,
	summons = {
		{ name = "Distorted Phantom", chance = 100, interval = 5000, count = 5 },
	},
}

monster.voices = {
	interval = 4500,
	chance = 16,
	{ text = "THE LIGHT SHALL JUDGE YOU!", yell = true },
	{ text = "HEAVEN'S WRATH DESCENDS!", yell = true },
	{ text = "YOUR DARKNESS ENDS HERE!", yell = true },
}

monster.loot = {
	{ id = 58448,  chance = 100000, maxCount = 50 }, -- Endless coin
	{ name = "crystal coin", chance = 100000, maxCount = 100 },
	{ name = "winged boots", chance = 35000},
	{ name = "Golden boots", chance = 3500},
	{ id = 36727, chance = 5800, maxCount = 1  }, --wealth duplex
	{ id = 51462, chance = 2500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 1400}, -- bag you desire
	{ id = 22755, chance = 900}, -- book of lies
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
	{ name = "devil helmet", chance = 2800 },
	{ name = "fire axe", chance = 2700 },
	{ name = "fire sword", chance = 2600 },
	{ name = "giant sword", chance = 2500 },
	{ name = "moonsilver strike helm", chance = 300 },
	{ name = "Moonsilver Spirit Mask", chance = 600 },
	{ name = "Moonsilver Trail Hood", chance = 200 },
	{ name = "giant amethyst", chance = 3900 },
	{ name = "giant emerald", chance = 3900 },
	{ name = "giant ruby", chance = 3900 },
	{ name = "giant sapphire", chance = 3900 },
	{ name = "winged helmet", chance = 200 },
	{ name = "magic plate armor", chance = 3900 },
}

monster.attacks = {
	{ name = "melee", interval = 1500, chance = 100, minDamage = -2400, maxDamage = -4200 },
	{ name = "combat", interval = 1900, chance = 48, type = COMBAT_HOLYDAMAGE, minDamage = -2800, maxDamage = -4300, range = 9, radius = 2, shootEffect = CONST_ANI_HOLY, effect = CONST_ME_HOLYDAMAGE, target = true },
	{ name = "combat", interval = 2500, chance = 43, type = COMBAT_HOLYDAMAGE, minDamage = -3200, maxDamage = -4800, length = 9, spread = 3, effect = CONST_ME_HOLYDAMAGE, target = false },
	{ name = "combat", interval = 3100, chance = 38, type = COMBAT_ENERGYDAMAGE, minDamage = -3300, maxDamage = -4900, length = 12, spread = 0, effect = CONST_ME_ENERGYAREA, target = false },
	{ name = "combat", interval = 3700, chance = 35, type = COMBAT_HOLYDAMAGE, minDamage = -3600, maxDamage = -5000, range = 8, radius = 4, shootEffect = CONST_ANI_HOLY, effect = CONST_ME_HOLYDAMAGE, target = true },
	{ name = "combat", interval = 4500, chance = 30, type = COMBAT_HOLYDAMAGE, minDamage = -4200, maxDamage = -5000, radius = 6, effect = CONST_ME_HOLYDAMAGE, target = false },
	{ name = "combat", interval = 4000, chance = 28, type = COMBAT_MANADRAIN, minDamage = -1200, maxDamage = -2200, range = 8, shootEffect = CONST_ANI_HOLY, effect = CONST_ME_MAGIC_BLUE, target = true },
	{ name = "speed", interval = 4800, chance = 27, speedChange = -650, range = 9, duration = 5000, effect = CONST_ME_HOLYDAMAGE, target = true },
}

monster.defenses = {
	defense = 82,
	armor = 72,
	{ name = "combat", interval = 2800, chance = 35, type = COMBAT_HEALING, minDamage = 1500, maxDamage = 3000, effect = CONST_ME_HOLYDAMAGE, target = false },
	{ name = "speed", interval = 3200, chance = 48, speedChange = 420, effect = CONST_ME_MAGIC_BLUE, target = false, duration = 5000 },
}

monster.elements = {
	{ type = COMBAT_HOLYDAMAGE, percent = 100 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 80 },
	{ type = COMBAT_ICEDAMAGE, percent = 40 },
	{ type = COMBAT_PHYSICALDAMAGE, percent = 35 },
	{ type = COMBAT_FIREDAMAGE, percent = 25 },
	{ type = COMBAT_EARTHDAMAGE, percent = -15 },
	{ type = COMBAT_DEATHDAMAGE, percent = -30 },
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