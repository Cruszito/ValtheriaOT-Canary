local mType = Game.createMonsterType("Cryonath the Frozen")
local monster = {}

monster.description = "cryonath the frozen"
monster.experience = 300000
monster.outfit = {
	lookType = 2195,
	lookHead = 0,
	lookBody = 98,
	lookLegs = 86,
	lookFeet = 94,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 500000
monster.maxHealth = 500000
monster.race = "undead"
monster.corpse = 6068
monster.speed = 200
monster.manaCost = 0

monster.changeTarget = {
	interval = 10000,
	chance = 20,
}

monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
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
	staticAttackChance = 98,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.light = {
	level = 0,
	color = 0,
}

monster.summon = {
	maxSummons = 2,
	summons = {
		{ name = "Elder Bloodjaw", chance = 100, interval = 2000, count = 6 },
	},
}

monster.voices = {
	interval = 5000,
	chance = 10,
	{ text = "YOUR FIRST TRIAL ENDS HERE!", yell = true },
	{ text = "BRING IT, MORTALS!", yell = true },
}

monster.loot = {
	{ name = "crystal coin", chance = 50000, maxCount = 90 },
	{ name = "boots of haste", chance = 16033 },
	{ name = "giant sword", chance = 60000 },
	{  id = 55976, chance = 20000 },
	{ name = "warlord sword", chance = 35 },
	{ name = "patched boots", chance = 7000 },
	{ id = 3123, chance = 16000 },
	{ id = 39179, chance = 500 },
	{ id = 36727, chance = 500 , maxCount = 1 },
	{ id = 8154, chance = 600 , maxCount = 1 },
	{ id = 34109, chance = 200 , maxCount = 1 },
	{ id = 55370, chance = 200 , maxCount = 1 },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, minDamage = -1500, maxDamage = -4000 },
	{ name = "combat", interval = 3000, chance = 40, type = COMBAT_ICEDAMAGE, minDamage = -1900, maxDamage = -2100, range = 7, radius = 7, shootEffect = CONST_ANI_ICE, effect = 243, target = true },
	{ name = "combat", interval = 2000, chance = 45, type = COMBAT_DEATHDAMAGE, minDamage = -2500, maxDamage = -2800, length = 8, spread = 0, effect = 252, target = false },
	{ name = "combat", interval = 3000, chance = 45, type = COMBAT_FIREDAMAGE, minDamage = -2000, maxDamage = -2500, length = 8, spread = 0, effect = 249, target = false },
	{ name = "combat", interval = 2000, chance = 45, type = COMBAT_ICEDAMAGE, minDamage = -2950, maxDamage = -3400, range = 7, radius = 3, shootEffect = 37, effect = 240, target = true },
	{ name = "combat", interval = 2000, chance = 45, type = COMBAT_DEATHDAMAGE, minDamage = -2600, maxDamage = -2900, length = 8, spread = 0, effect = 244, target = false },
	{ name = "extended holy chain", interval = 3000, chance = 69, minDamage = -4150, maxDamage = -4800, range = 10 },
}

monster.defenses = {
	defense = 65,
	armor = 55,
	{ name = "combat", interval = 2000, chance = 35, type = COMBAT_HEALING, minDamage = 300, maxDamage = 800, effect = CONST_ME_MAGIC_BLUE, target = false },
	{ name = "speed", interval = 4000, chance = 80, speedChange = 440, effect = CONST_ME_MAGIC_RED, target = false, duration = 6000 },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 60 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 60 },
	{ type = COMBAT_EARTHDAMAGE, percent = 80 },
	{ type = COMBAT_FIREDAMAGE, percent = 100 },
	{ type = COMBAT_LIFEDRAIN, percent = 35 },
	{ type = COMBAT_MANADRAIN, percent = 35 },
	{ type = COMBAT_DROWNDAMAGE, percent = 35 },
	{ type = COMBAT_ICEDAMAGE, percent = 50 },
	{ type = COMBAT_HOLYDAMAGE, percent = 40 },
	{ type = COMBAT_DEATHDAMAGE, percent = 90 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = false },
}


mType:register(monster)
