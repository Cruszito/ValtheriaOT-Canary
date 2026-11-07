local mType = Game.createMonsterType("Ignivar the Pyroclast")
local monster = {}

monster.description = "ignivar the pyroclast"
monster.experience = 345000
monster.outfit = { lookType = 2426 }

monster.health = 490000
monster.maxHealth = 490000
monster.race = "fire"
monster.corpse = 6068
monster.speed = 325
monster.manaCost = 0

monster.changeTarget = { interval = 7500, chance = 25 }
monster.strategiesTarget = { nearest = 70, health = 10, damage = 15, random = 5 }

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
	staticAttackChance = 96,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.light = { level = 8, color = 208 }

monster.summon = {
	maxSummons = 8,
	summons = {
		{ name = "Hellhound", chance = 100, interval = 1000, count = 8 },
	},
}

monster.voices = {
    interval = 4500,
    chance = 16,
    { text = "THE MOUNTAIN BURNS WITHIN ME!", yell = true },
    { text = "STONE AND FLAME SHALL BURY YOU!", yell = true },
    { text = "DROWN IN MOLTEN ROCK!", yell = true },
}

monster.loot = {

	{ name = "Dawnfire pantaloons", chance = 800 },
	{ name = "dawnfire sherwani", chance = 900 },
	{ name = "fire ward ring", chance = 300 },
	{ name = "fireborn giant armor", chance = 3200 },
	{ id = 36727, chance = 9800, maxCount = 1  }, --wealth duplex
	{ id = 51462, chance = 6500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 600, maxCount = 1 }, -- bag you desire
	{ id = 51589, chance = 6600, maxCount = 1 }, -- greater proficiency catalyst
	{ id = 7426, chance = 2000 }, -- amber staff
	{ id = 7368, chance = 25000, maxCount = 10 }, -- assassin star
	{ id = 3116, chance = 900 }, -- big bone
	{ id = 3027, chance = 9200, maxCount = 4 }, -- black pearl
	{ id = 16131, chance = 12500 }, -- blazing bone
	{ id = 6558, chance = 20000 }, -- concentrated demonic blood
	{ id = 6558, chance = 20000 }, -- concentrated demonic blood
	{ id = 6499, chance = 20000 }, -- demonic essence
	{ id = 4871, chance = 400 }, -- explorer brooch
	{ id = 9636, chance = 10000 }, -- fiery heart
	{ id = 3280, chance = 7000 }, -- fire sword
	{ id = 3281, chance = 1000 }, -- giant sword
	{ id = 9058, chance = 1500 }, -- gold ingot
	{ id = 238, chance = 30000, maxCount = 3 }, -- great mana potion
	{ id = 7642, chance = 20000 }, -- great spirit potion
	{ id = 3038, chance = 1000 }, -- green gem
	{ id = 5910, chance = 5000 }, -- green piece of cloth
	{ id = 3582, chance = 30000, maxCount = 6 }, -- ham
	{ id = 5925, chance = 10000 }, -- hardened bone
	{ id = 9637, chance = 20000 }, -- hellhound slobber
	{ id = 3318, chance = 7500 }, -- knight axe
	{ id = 817, chance = 3000 }, -- magma amulet
	{ id = 818, chance = 1500 }, -- magma boots
	{ id = 826, chance = 800 }, -- magma coat
	{ id = 821, chance = 1000 }, -- magma legs
	{ id = 827, chance = 900 }, -- magma monocle
	{ id = 7421, chance = 1000 }, -- onyx flail
	{ id = 3035, chance = 100000, maxCount = 7 }, -- platinum coin
	{ id = 3039, chance = 4500 }, -- red gem
	{ id = 5911, chance = 3000 }, -- red piece of cloth
	{ id = 6553, chance = 1000 }, -- ruthless axe
	{ id = 3032, chance = 10000, maxCount = 3 }, -- small emerald
	{ id = 3030, chance = 10000, maxCount = 3 }, -- small ruby
	{ id = 9057, chance = 10000, maxCount = 3 }, -- small topaz
	{ id = 5944, chance = 20000 }, -- soul orb
	{ id = 7643, chance = 16000 }, -- ultimate health potion
	{ id = 3071, chance = 7000 }, -- wand of inferno
	{ id = 3037, chance = 4500 }, -- yellow gem
	{ id = 5914, chance = 6000 }, -- yellow piece of cloth
}

monster.attacks = {
    { name = "melee", interval = 1850, chance = 100, minDamage = -1800, maxDamage = -4200 },
    { name = "combat", interval = 2050, chance = 47, type = COMBAT_FIREDAMAGE, minDamage = -2300, maxDamage = -3500, range = 7, radius = 2, shootEffect = CONST_ANI_FIRE, effect = CONST_ME_FIREAREA, target = true },
    { name = "combat", interval = 2600, chance = 42, type = COMBAT_EARTHDAMAGE, minDamage = -2450, maxDamage = -3700, length = 7, spread = 4, effect = CONST_ME_GROUNDSHAKER, target = false },
    { name = "combat", interval = 3200, chance = 37, type = COMBAT_PHYSICALDAMAGE, minDamage = -2700, maxDamage = -4050, radius = 4, effect = CONST_ME_GROUNDSHAKER, target = false },
    { name = "combat", interval = 3800, chance = 33, type = COMBAT_FIREDAMAGE, minDamage = -3000, maxDamage = -4450, length = 9, spread = 3, effect = CONST_ME_EXPLOSIONAREA, target = false },
    { name = "combat", interval = 4400, chance = 29, type = COMBAT_EARTHDAMAGE, minDamage = -3250, maxDamage = -4650, range = 7, radius = 3, shootEffect = CONST_ANI_EARTH, effect = CONST_ME_GROUNDSHAKER, target = true },
    { name = "combat", interval = 5200, chance = 25, type = COMBAT_FIREDAMAGE, minDamage = -3500, maxDamage = -4950, radius = 6, effect = CONST_ME_FIREAREA, target = false },
    { name = "speed", interval = 4700, chance = 25, speedChange = -450, range = 7, duration = 5000, effect = CONST_ME_GROUNDSHAKER, target = true },
}

monster.defenses = {
    defense = 76,
    armor = 70,
    { name = "combat", interval = 3000, chance = 30, type = COMBAT_HEALING, minDamage = 750, maxDamage = 1550, effect = CONST_ME_FIREAREA, target = false },
}

monster.elements = {
    { type = COMBAT_FIREDAMAGE, percent = 100 },
    { type = COMBAT_EARTHDAMAGE, percent = 85 },
    { type = COMBAT_PHYSICALDAMAGE, percent = 45 },
    { type = COMBAT_DEATHDAMAGE, percent = 20 },
    { type = COMBAT_ENERGYDAMAGE, percent = 10 },
    { type = COMBAT_ICEDAMAGE, percent = -30 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = true },
}

monster.events = { "CustomQuestBossDeathTeleport" }

mType:register(monster)
