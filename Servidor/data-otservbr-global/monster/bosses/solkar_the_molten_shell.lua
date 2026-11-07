local mType = Game.createMonsterType("Solkar the Molten Shell")
local monster = {}

monster.description = "solkar the molten shell"
monster.experience = 305000
monster.outfit = { lookType = 2054 }

monster.health = 470000
monster.maxHealth = 470000
monster.race = "fire"
monster.corpse = 6068
monster.speed = 195
monster.manaCost = 0

monster.changeTarget = { interval = 9000, chance = 20 }
monster.strategiesTarget = { nearest = 80, health = 5, damage = 10, random = 5 }

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

monster.light = { level = 8, color = 35 }

monster.summon = {
	maxSummons = 6,
	summons = {
		{ name = "Angry Demon", chance = 80, interval = 2000, count = 6 },
	},
}

monster.voices = {
    interval = 5000,
    chance = 15,
    { text = "YOUR BLOOD SHALL FEED MY FLAMES!", yell = true },
    { text = "BURN BENEATH THE CRIMSON CURSE!", yell = true },
    { text = "YOUR SOUL BELONGS TO THE RED ABYSS!", yell = true },
}

monster.loot = {
	{ id = 58448,  chance = 100000, maxCount = 100 }, -- Endless coin
	{ id = 36727, chance = 9800, maxCount = 1  }, --wealth duplex
	{ id = 51462, chance = 6500, maxCount = 1 }, -- powerful strike scroll
	{ id = 34109, chance = 700, maxCount = 1 }, -- bag you desire
	{ id = 51589, chance = 6600, maxCount = 1 }, -- greater proficiency catalyst
	{ id = 2848, chance = 1180 }, -- purple tome
	{ id = 3031, chance = 60000, maxCount = 100 }, -- gold coin
	{ id = 3031, chance = 60000, maxCount = 100 }, -- gold coin
	{ id = 3032, chance = 9690, maxCount = 5 }, -- small emerald
	{ id = 3033, chance = 7250, maxCount = 5 }, -- small amethyst
	{ id = 3030, chance = 7430, maxCount = 5 }, -- small ruby
	{ id = 9057, chance = 7470, maxCount = 5 }, -- small topaz
	{ id = 3039, chance = 2220 }, -- red gem
	{ id = 6499, chance = 14630 }, -- demonic essence
	{ id = 3034, chance = 3430 }, -- talon
	{ id = 3035, chance = 90540, maxCount = 8 }, -- platinum coin
	{ id = 3048, chance = 1890 }, -- might ring
	{ id = 3049, chance = 2170 }, -- stealth ring
	{ id = 3055, chance = 680 }, -- platinum amulet
	{ id = 3060, chance = 2854 }, -- orb
	{ id = 3063, chance = 1050 }, -- gold ring
	{ id = 3098, chance = 1990 }, -- ring of healing
	{ id = 3281, chance = 1980 }, -- giant sword
	{ id = 3284, chance = 1550 }, -- ice rapier
	{ id = 3306, chance = 1440 }, -- golden sickle
	{ id = 3320, chance = 4030 }, -- fire axe
	{ id = 3356, chance = 1180 }, -- devil helmet
	{ id = 3364, chance = 440 }, -- golden legs
	{ id = 3366, chance = 130 }, -- magic plate armor
	{ id = 3414, chance = 480 }, -- mastermind shield
	{ id = 3420, chance = 740 }, -- demon shield
	{ id = 3731, chance = 19660, maxCount = 6 }, -- fire mushroom
	{ id = 7368, chance = 12550, maxCount = 10 }, -- assassin star
	{ id = 7382, chance = 70 }, -- demonrage sword
	{ id = 238, chance = 22220, maxCount = 3 }, -- great mana potion
	{ id = 7643, chance = 19540, maxCount = 3 }, -- ultimate health potion
	{ id = 7642, chance = 18510, maxCount = 3 }, -- great spirit potion
	{ name = "djinn blade", chance = 5530 },
}

monster.attacks = {
    { name = "melee", interval = 1900, chance = 100, minDamage = -1900, maxDamage = -4400 },

    -- Llama sanguínea dirigida
    { name = "combat", interval = 2000, chance = 48, type = COMBAT_FIREDAMAGE, minDamage = -2250, maxDamage = -3450, range = 7, radius = 2, shootEffect = CONST_ANI_FIRE, effect = CONST_ME_FIREAREA, target = true },

    -- Aliento de fuego carmesí
    { name = "combat", interval = 2550, chance = 42, type = COMBAT_FIREDAMAGE, minDamage = -2450, maxDamage = -3700, length = 8, spread = 3, effect = CONST_ME_FIREAREA, target = false },

    -- Maldición de sangre
    { name = "combat", interval = 3100, chance = 37, type = COMBAT_LIFEDRAIN, minDamage = -2650, maxDamage = -3950, range = 7, radius = 3, shootEffect = CONST_ANI_DEATH, effect = CONST_ME_MAGIC_RED, target = true },

    -- Explosión infernal
    { name = "combat", interval = 3700, chance = 33, type = COMBAT_FIREDAMAGE, minDamage = -2950, maxDamage = -4250, radius = 4, effect = CONST_ME_EXPLOSIONAREA, target = false },

    -- Oleada del abismo rojo
    { name = "combat", interval = 4350, chance = 29, type = COMBAT_DEATHDAMAGE, minDamage = -3150, maxDamage = -4550, length = 9, spread = 4, effect = CONST_ME_MORTAREA, target = false },

    -- Tormenta de sangre y fuego
    { name = "combat", interval = 5200, chance = 24, type = COMBAT_LIFEDRAIN, minDamage = -3400, maxDamage = -4800, radius = 6, effect = CONST_ME_MAGIC_RED, target = false },

    -- Maldición que ralentiza
    { name = "speed", interval = 4700, chance = 27, speedChange = -500, range = 7, duration = 5500, effect = CONST_ME_MAGIC_RED, target = true },
}

monster.defenses = {
    defense = 82,
    armor = 74,

    -- Absorbe sangre para regenerarse
    { name = "combat", interval = 3000, chance = 30, type = COMBAT_HEALING, minDamage = 800, maxDamage = 1600, effect = CONST_ME_MAGIC_RED, target = false },

    -- Forma incorpórea del djinn
    { name = "speed", interval = 4200, chance = 26, speedChange = 220, duration = 4000, effect = CONST_ME_FIREAREA, target = false },
}

monster.elements = {
    { type = COMBAT_FIREDAMAGE, percent = 100 },
    { type = COMBAT_LIFEDRAIN, percent = 85 },
    { type = COMBAT_DEATHDAMAGE, percent = 70 },
    { type = COMBAT_ENERGYDAMAGE, percent = 30 },
    { type = COMBAT_PHYSICALDAMAGE, percent = 25 },
    { type = COMBAT_HOLYDAMAGE, percent = -20 },
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
