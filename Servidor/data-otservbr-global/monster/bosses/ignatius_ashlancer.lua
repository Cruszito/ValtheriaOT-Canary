local mType = Game.createMonsterType("Ignatius Ashlancer")
local monster = {}

monster.description = "ignatius ashlancer"
monster.experience = 385000

monster.outfit = {
	lookType = 2170,
}

monster.health = 560000
monster.maxHealth = 560000
monster.race = "fire"
monster.corpse = 6068
monster.speed = 245
monster.manaCost = 0

monster.changeTarget = {
	interval = 6000,
	chance = 32,
}

monster.strategiesTarget = {
	nearest = 55,
	health = 10,
	damage = 30,
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
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.light = {
	level = 9,
	color = 208,
}


monster.summon = {
	maxSummons = 6,
	summons = {
		{ name = "Elder Bloodjaw", chance = 100, interval = 2000, count = 6 },
	},
}

monster.voices = {
	interval = 4300,
	chance = 16,
	{ text = "MY STAFF COMMANDS THE INFERNO!", yell = true },
	{ text = "BURN BENEATH THE ASHEN FLAME!", yell = true },
	{ text = "YOUR BONES WILL FEED THE FIRE!", yell = true },
}

monster.loot = {
	{ name = "crystal coin", chance = 100000, maxCount = 6 },
	{ name = "gold coin", chance = 100000, maxCount = 100 },
	{ name = "crystal coin", chance = 14615, maxCount = 115 },
	{ name = "ultimate spirit potion", chance = 7169, maxCount = 153 },
	{ name = "mastermind potion", chance = 14651, maxCount = 45 },
	{ name = "yellow gem", chance = 9243, maxCount = 5 },
	{ name = "amber with a bug", chance = 7224, maxCount = 2 },
	{ name = "ultimate mana potion", chance = 13137, maxCount = 179 },
	{ name = "violet gem", chance = 14447, maxCount = 4 },
	{ name = "raw watermelon tourmaline", chance = 6788, maxCount = 2 },
	{ id = 3039, chance = 9047, maxCount = 1 }, -- red gem
	{ name = "supreme health potion", chance = 14635, maxCount = 37 },
	{ name = "berserk potion", chance = 14973, maxCount = 45 },
	{ name = "amber with a dragonfly", chance = 6470, maxCount = 1 },
	{ name = "gold ingot", chance = 11421, maxCount = 1 },
	{ name = "blue gem", chance = 8394, maxCount = 1 },
	{ name = "bullseye potion", chance = 13783, maxCount = 36 },
	{ name = "putrefactive figurine", chance = 11416, maxCount = 1 },
	{ name = "white gem", chance = 13559, maxCount = 3 },
	{ id = 43895, chance = 360 }, -- Bag you covet
	{ name = "devil helmet", chance = 9800 },
	{ name = "fire axe", chance = 8700 },
	{ name = "fire sword", chance = 7600 },
	{ name = "giant sword", chance = 6500 },
	{ name = "gold ring", chance = 9400 },
	{ name = "golden sickle", chance = 1300 },
	{ id = 58448,  chance = 100000, maxCount = 100 }, -- Endless coin
	{ id = 36727, chance = 9800, maxCount = 1  }, --wealth duplex
	{ id = 51462, chance = 6500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 400, maxCount = 1 }, -- bag you desire
	{ id = 51589, chance = 6600, maxCount = 1 }, -- greater proficiency catalyst
	
}

monster.attacks = {
	{ name = "melee", interval = 1700, chance = 100, minDamage = -2100, maxDamage = -4800 },
	{ name = "combat", interval = 1900, chance = 48, type = COMBAT_FIREDAMAGE, minDamage = -2400, maxDamage = -3600, range = 8, radius = 2, shootEffect = CONST_ANI_FIRE, effect = CONST_ME_FIREAREA, target = true },
	{ name = "combat", interval = 2400, chance = 43, type = COMBAT_ENERGYDAMAGE, minDamage = -2700, maxDamage = -4050, length = 10, spread = 0, effect = CONST_ME_ENERGYAREA, target = false },
	{ name = "combat", interval = 2900, chance = 40, type = COMBAT_FIREDAMAGE, minDamage = -3000, maxDamage = -4400, length = 8, spread = 3, effect = CONST_ME_FIREAREA, target = false },
	{ name = "combat", interval = 3300, chance = 36, type = COMBAT_EARTHDAMAGE, minDamage = -2900, maxDamage = -4200, radius = 3, effect = CONST_ME_GROUNDSHAKER, target = false },
	{ name = "combat", interval = 3900, chance = 33, type = COMBAT_FIREDAMAGE, minDamage = -3300, maxDamage = -4800, range = 8, radius = 4, shootEffect = CONST_ANI_FIRE, effect = CONST_ME_EXPLOSIONAREA, target = true },
	{ name = "combat", interval = 4700, chance = 28, type = COMBAT_FIREDAMAGE, minDamage = -3800, maxDamage = -5500, radius = 6, effect = CONST_ME_FIREAREA, target = false },
	{ name = "speed", interval = 4600, chance = 27, speedChange = -500, range = 7, duration = 5500, effect = CONST_ME_FIREAREA, target = true },
}

monster.defenses = {
	defense = 82,
	armor = 74,
	{ name = "combat", interval = 2800, chance = 34, type = COMBAT_HEALING, minDamage = 1000, maxDamage = 2000, effect = CONST_ME_FIREAREA, target = false },
	{ name = "speed", interval = 3500, chance = 40, speedChange = 370, effect = CONST_ME_MAGIC_RED, target = false, duration = 5500 },
}

monster.elements = {
	{ type = COMBAT_FIREDAMAGE, percent = 100 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 60 },
	{ type = COMBAT_EARTHDAMAGE, percent = 50 },
	{ type = COMBAT_PHYSICALDAMAGE, percent = 45 },
	{ type = COMBAT_DEATHDAMAGE, percent = 25 },
	{ type = COMBAT_HOLYDAMAGE, percent = -10 },
	{ type = COMBAT_ICEDAMAGE, percent = -30 },
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