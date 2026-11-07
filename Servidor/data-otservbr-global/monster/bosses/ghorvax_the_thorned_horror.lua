local mType = Game.createMonsterType("Ghorvax the Thorned Horror")
local monster = {}

monster.description = "ghorvax the thorned horror"
monster.experience = 330000
monster.outfit = { lookType = 2055 }

monster.health = 470000
monster.maxHealth = 470000
monster.race = "venom"
monster.corpse = 6068
monster.speed = 305
monster.manaCost = 0

monster.changeTarget = { interval = 2600, chance = 40 }
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
	canWalkOnEnergy = false,
	canWalkOnFire = false,
	canWalkOnPoison = true,
}

monster.light = { level = 4, color = 66 }


monster.summon = {
	maxSummons = 5,
	summons = {
		{ name = "juggernaut", chance = 100, interval = 5000, count = 5 },
	},
}

monster.voices = {
	interval = 4900,
	chance = 13,
	{ text = "THE THORNS HUNGER!", yell = true },
	{ text = "ROT TAKES ROOT IN YOU!", yell = true },
}

monster.loot = {
	{ id = 36727, chance = 2800, maxCount = 1 }, --wealth duplex
	{ id = 51462, chance = 2500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 450, maxCount = 1 }, -- bag you desire
	{ id = 22755, chance = 900, maxCount = 1 }, -- book of lies
	{ id = 51589, chance = 1600, maxCount = 1 }, -- greater proficiency catalyst
	{ name = "demonwing axe", chance = 2900 }, -- demonwing axe
	{ name = "crypt breaker", chance = 2600 },-- crypt breaker
	{ name = "crystal coin", chance = 100000, maxCount = 4 },
	{ name = "gold coin", chance = 100000, maxCount = 100 },
	{ name = "giant sword", chance = 19000 },
	{ name = "white pearl", chance = 18000, maxCount = 4 },
	{ name = "demon shield", chance = 1900 },
	{ name = "demonbone amulet", chance = 1900 },
	{ name = "demonrage sword", chance = 3900 },
	{ name = "giant amethyst", chance = 3900 },
	{ name = "giant emerald", chance = 2900 },
	{ name = "giant ruby", chance = 1900 },
	{ name = "giant sapphire", chance = 1900 },
	{ name = "golden legs", chance = 3900 },
	{ name = "magic plate armor", chance = 900 },
	{ name = "great spirit potion", chance = 2900, maxCount = 6 },
	{ name = "ultimate mana potion", chance = 3000, minCount = 20, maxCount = 40 },
	{ name = "ultimate health potion", chance = 3500, minCount = 10, maxCount = 20 },
	{ name = "supreme health potion", chance = 2900, minCount = 5, maxCount = 10 },
	{ name = "ultimate spirit potion", chance = 3500, minCount = 2, maxCount = 14 },
}

monster.attacks = {
    { name = "melee", interval = 1850, chance = 100, minDamage = -2500, maxDamage = -5250, effect = CONST_ME_DRAWBLOOD },
    { name = "combat", interval = 2050, chance = 54, type = COMBAT_EARTHDAMAGE, minDamage = -2200, maxDamage = -3400, range = 7, shootEffect = CONST_ANI_EARTH, effect = CONST_ME_PLANTATTACK, target = true },
    { name = "combat", interval = 2750, chance = 48, type = COMBAT_EARTHDAMAGE, minDamage = -2600, maxDamage = -3850, length = 8, spread = 5, effect = CONST_ME_CARNIPHILA, target = false },
    { name = "combat", interval = 3450, chance = 44, type = COMBAT_PHYSICALDAMAGE, minDamage = -2800, maxDamage = -5050, radius = 8, effect = CONST_ME_GROUNDSHAKER, target = false },
    { name = "combat", interval = 4250, chance = 49, type = COMBAT_LIFEDRAIN, minDamage = -2400, maxDamage = -3550, range = 6, radius = 2, shootEffect = CONST_ANI_EARTH, effect = CONST_ME_GREEN_RINGS, target = true },
    { name = "speed", interval = 5100, chance = 23, speedChange = -480, range = 7, duration = 7000, effect = CONST_ME_POISONAREA, target = true },
}

monster.defenses = {
	defense = 76,
	armor = 73,
	{ name = "combat", interval = 2900, chance = 32, type = COMBAT_HEALING, minDamage = 700, maxDamage = 1500, effect = CONST_ME_MAGIC_GREEN, target = false },
}

monster.elements = {
	{ type = COMBAT_EARTHDAMAGE, percent = 100 },
	{ type = COMBAT_PHYSICALDAMAGE, percent = 50 },
	{ type = COMBAT_LIFEDRAIN, percent = 55 },
	{ type = COMBAT_DEATHDAMAGE, percent = 35 },
	{ type = COMBAT_ICEDAMAGE, percent = 15 },
	{ type = COMBAT_FIREDAMAGE, percent = -20 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = true },
}

monster.events = { "CustomQuestBossDeathTeleport" }

mType:register(monster)
