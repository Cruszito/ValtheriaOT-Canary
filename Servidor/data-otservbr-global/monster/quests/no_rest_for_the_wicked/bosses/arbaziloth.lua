local mType = Game.createMonsterType("Arbaziloth")
local monster = {}

monster.description = "Arbaziloth"
monster.experience = 500000
monster.outfit = {
	lookType = 1802,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

monster.bosstiary = {
	bossRaceId = 2594,
	bossRace = RARITY_ARCHFOE,
}

monster.health = 360000
monster.maxHealth = 360000
monster.race = "fire"
monster.corpse = 50029
monster.speed = 160
monster.manaCost = 0

monster.changeTarget = {
	interval = 5000,
	chance = 40,
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
	staticAttackChance = 90,
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
		{ name = "Overcharged Demon", chance = 12, interval = 2000, count = 2 },
	},
}

monster.voices = {
	interval = 5000,
	chance = 10,
	{ text = "I am superior!", yell = true },
	{ text = "You are mad to challange a demon prince!", yell = true },
	{ text = "You can't stop me or my plans!", yell = true },
	{ text = "Pesky humans!", yell = true },
	{ text = "This insolence!", yell = true },
	{ text = "Nobody can stop me!", yell = true },
	{ text = "All will have to bow to me!", yell = true },
	{ text = "With this power I can crush everyone!", yell = true },
	{ text = "All that energy is mine!", yell = true },
	{ text = "Face the power of hell!", yell = true },
	{ text = "AHHH! THE POWER!!", yell = true },
}

monster.loot = {
    { name = "crystal coin", chance = 20000, minCount = 1, maxCount = 5 },
    { name = "platinum coin", chance = 25000, minCount = 50, maxCount = 100 },

    { name = "strong mana potion", chance = 10000, minCount = 11, maxCount = 20 },
    { name = "great mana potion", chance = 10000, minCount = 2, maxCount = 15 },
    { name = "great spirit potion", chance = 8000, maxCount = 6 },
    { name = "ultimate mana potion", chance = 10000, minCount = 20, maxCount = 40 },
    { name = "ultimate health potion", chance = 10000, minCount = 10, maxCount = 20 },
    { name = "supreme health potion", chance = 8000, minCount = 5, maxCount = 10 },
    { name = "ultimate spirit potion", chance = 10000, minCount = 2, maxCount = 14 },

    { name = "blue gem", chance = 7000, maxCount = 2 },
    { id = 3039, chance = 7000, maxCount = 2 }, -- red gem
    { name = "yellow gem", chance = 7000, maxCount = 2 },

    { name = "arbaziloth shoulder piece", chance = 3000 },

    { name = "demon shield", chance = 2500 },
    { name = "demonbone amulet", chance = 2500 },
    { name = "demonrage sword", chance = 2500 },

    { name = "giant amethyst", chance = 2500 },
    { name = "giant emerald", chance = 2500 },
    { name = "giant ruby", chance = 2500 },
    { name = "giant sapphire", chance = 2500 },

    { name = "golden legs", chance = 2000 },
    { name = "magic plate armor", chance = 2000 },

    -- Addons / Mount
    { name = "demon claws", chance = 500 },
    { id = 50061, chance = 500 },
    { name = "demon in a green box", chance = 400 },

    -- Inferniarch equipment
    { name = "inferniarch arbalest", chance = 1000 },
    { name = "inferniarch battleaxe", chance = 1000 },
    { name = "inferniarch blade", chance = 1000 },
    { name = "inferniarch bow", chance = 1000 },
    { name = "inferniarch flail", chance = 1000 },
    { name = "inferniarch greataxe", chance = 1000 },
    { name = "inferniarch rod", chance = 1000 },
    { name = "inferniarch slayer", chance = 1000 },
    { name = "inferniarch wand", chance = 1000 },
    { name = "inferniarch warhammer", chance = 1000 },

    -- Helmets
    { name = "maliceforged helmet", chance = 1000 },
    { name = "hellstalker visor", chance = 1000 },
    { name = "dreadfire headpiece", chance = 1000 },
    { name = "demonfang mask", chance = 1000 },
	{ id = 49892, chance = 2800, maxCount = 1 },
}



monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, minDamage = -1520, maxDamage = -2000 },
}

monster.defenses = {
	defense = 145,
	armor = 80,
	mitigation = 2.45,
	{ name = "combat", interval = 2000, chance = 5, type = COMBAT_HEALING, minDamage = 200, maxDamage = 600, effect = CONST_ME_MAGIC_BLUE, target = false },
}

monster.elements = {
	{ type = COMBAT_HOLYDAMAGE, percent = 0 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 0 },
	{ type = COMBAT_EARTHDAMAGE, percent = 0 },
	{ type = COMBAT_DROWNDAMAGE, percent = 0 },
	{ type = COMBAT_FIREDAMAGE, percent = 15 },
	{ type = COMBAT_DEATHDAMAGE, percent = 20 },
	{ type = COMBAT_ICEDAMAGE, percent = 20 },
	{ type = COMBAT_PHYSICALDAMAGE, percent = 30 },
	{ type = COMBAT_LIFEDRAIN, percent = 100 },
	{ type = COMBAT_MANADRAIN, percent = 100 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = false },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = false },
}

mType.onAppear = function(monster, creature)
	if monster:getType():isRewardBoss() then
		monster:setReward(true)
	end
end

mType:register(monster)
