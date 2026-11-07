local mType = Game.createMonsterType("Apocalypse")
local monster = {}

local VISUAL_INTERVAL = 4000

local apocalypseStates = {}

local visualEffects = {
	CONST_ME_FIREAREA,
	CONST_ME_MORTAREA,
	CONST_ME_ENERGYAREA,
	CONST_ME_BLACKSMOKE,
}

local phases = {
	{
		healthPercent = 75,
		text = "THE SEALS OF DESTRUCTION ARE BROKEN!",
		centerEffect = CONST_ME_MORTAREA,
		ringEffect = CONST_ME_BLACKSMOKE,
		ringRadius = 2,
	},
	{
		healthPercent = 50,
		text = "HELL ANSWERS THE CALL OF APOCALYPSE!",
		centerEffect = CONST_ME_EXPLOSIONAREA,
		ringEffect = CONST_ME_FIREAREA,
		ringRadius = 3,
	},
	{
		healthPercent = 25,
		text = "THE END OF ALL THINGS HAS COME!",
		centerEffect = CONST_ME_FIREWORK_RED,
		ringEffect = CONST_ME_MORTAREA,
		ringRadius = 3,
	},
}

local function sendEffect(position, effect)
	if Tile(position) then
		position:sendMagicEffect(effect)
	end
end

local function sendEffectRing(center, radius, effect)
	for offsetX = -radius, radius do
		for offsetY = -radius, radius do
			if math.abs(offsetX) == radius or math.abs(offsetY) == radius then
				local effectPosition = Position(center.x + offsetX, center.y + offsetY, center.z)
				sendEffect(effectPosition, effect)
			end
		end
	end
end

local function sendCrossEffects(center, effect)
	local offsets = {
		{ x = 0, y = -2 },
		{ x = 2, y = 0 },
		{ x = 0, y = 2 },
		{ x = -2, y = 0 },
		{ x = 2, y = -2 },
		{ x = 2, y = 2 },
		{ x = -2, y = 2 },
		{ x = -2, y = -2 },
	}

	for _, offset in ipairs(offsets) do
		local effectPosition = Position(center.x + offset.x, center.y + offset.y, center.z)
		sendEffect(effectPosition, effect)
	end
end

local function playSpawnSequence(monsterId, stage)
	local boss = Monster(monsterId)
	if not boss then
		return
	end

	local position = boss:getPosition()
	if stage == 1 then
		boss:say("THE APOCALYPSE HAS BEGUN!", TALKTYPE_MONSTER_YELL)
		sendEffect(position, CONST_ME_TELEPORT)
		sendEffectRing(position, 3, CONST_ME_BLACKSMOKE)
	elseif stage == 2 then
		sendEffect(position, CONST_ME_MAGIC_RED)
		sendEffectRing(position, 2, CONST_ME_MORTAREA)
	elseif stage == 3 then
		sendEffect(position, CONST_ME_EXPLOSIONAREA)
		sendEffectRing(position, 1, CONST_ME_FIREAREA)
	elseif stage == 4 then
		sendEffect(position, CONST_ME_FIREWORK_RED)
		sendCrossEffects(position, CONST_ME_FIREAREA)
	end
end

local function activatePhase(boss, phase)
	local position = boss:getPosition()
	boss:say(phase.text, TALKTYPE_MONSTER_YELL)
	sendEffect(position, phase.centerEffect)
	sendEffectRing(position, phase.ringRadius, phase.ringEffect)
end

monster.description = "Apocalypse"
monster.experience = 1000000
monster.outfit = {
	lookType = 12,
	lookHead = 38,
	lookBody = 114,
	lookLegs = 0,
	lookFeet = 94,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 250000
monster.maxHealth = 250000
monster.race = "fire"
monster.corpse = 6068
monster.speed = 350
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
	level = 12,
	color = 215,
}

monster.voices = {
	interval = 5000,
	chance = 45,
	{ text = "BOW TO THE POWER OF THE RUTHLESS SEVEN!", yell = true },
	{ text = "DESTRUCTION!", yell = true },
	{ text = "CHAOS!", yell = true },
	{ text = "DEATH TO ALL!", yell = true },
	{ text = "THE WORLD WILL BURN!", yell = true },
}

-- Maximum simultaneous summons: 2 Orshabaal and 4 Demons.
-- When one dies, Apocalypse can summon a replacement up to these limits.
monster.summon = {
	maxSummons = 6,
	summons = {
		{ name = "Orshabaal", interval = 4000, chance = 100, count = 2 },
		{ name = "Demon", interval = 2000, chance = 100, count = 4 },
	},
}

monster.loot = {
	{ id = 51589, chance = 13500, maxCount = 10 }, -- proficiency catalis
	{ id = 3025, chance = 13500 }, -- ancient amulet
	{ id = 3116, chance = 19000 }, -- big bone
	{ name = "black pearl", chance = 15000, maxCount = 35 },
	{ name = "boots of haste", chance = 14000 },
	{ id = 3076, chance = 22500 }, -- crystal ball
	{ name = "crystal necklace", chance = 21500 },
	{ id = 3007, chance = 15500 }, -- crystal ring
	{ name = "demon shield", chance = 15500 },
	{ name = "devil helmet", chance = 11000 },
	{ name = "dragon hammer", chance = 34500 },
	{ id = 3051, chance = 13500 }, -- energy ring
	{ name = "fire axe", chance = 17000 },
	{ name = "giant sword", chance = 12500 },
	{ name = "platinum coin", chance = 69900, maxCount = 100 },
	{ name = "platinum coin", chance = 68800, maxCount = 100 },
	{ name = "crystal coin", chance = 47700, maxCount = 40 },
	{ name = "crystal coin", chance = 36600, maxCount = 15 },
	{ name = "gold ring", chance = 28000 },
	{ name = "golden legs", chance = 15000 },
	{ name = "giant ruby", chance = 31500 },
	{ name = "giant sapphire", chance = 31500 },
	{ name = "giant emerald", chance = 31500 },
	{ name = "ice rapier", chance = 27500 },
	{ name = "magic plate armor", chance = 13000 },
	{ name = "mastermind shield", chance = 17500 },
	{ name = "purple tome", chance = 12600 },
	{ name = "ring of the sky", chance = 13500 },
	{ name = "silver dagger", chance = 15500 },
	{ name = "skull staff", chance = 25000 },
	{ name = "talon", chance = 14000, maxCount = 27 },
	{ name = "teddy bear", chance = 10500 },
	{ name = "thunder hammer", chance = 3500 },
	{ id = 3002, chance = 5100 }, -- voodoo doll
	{ id = 46626, chance = 5100, maxCount = 50  }, --greater fragment
    { id = 46625, chance = 5100, maxCount = 80  }, --lesser fragment
	{ name = "white pearl", chance = 12500, maxCount = 35 },

}


monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, skill = 230, attack = 210 },
	{ name = "combat", interval = 1000, chance = 52, type = COMBAT_DEATHDAMAGE, minDamage = -800, maxDamage = -1900, radius = 9, effect = CONST_ME_MORTAREA, target = false },
	{ name = "speed", interval = 1000, chance = 40, speedChange = -850, radius = 6, effect = CONST_ME_POISONAREA, target = false, duration = 60000 },
	{ name = "strength", interval = 1000, chance = 55, minDamage = -600, maxDamage = -1450, radius = 5, effect = CONST_ME_HITAREA, target = false },
	{ name = "combat", interval = 3000, chance = 46, type = COMBAT_FIREDAMAGE, minDamage = -300, maxDamage = -800, range = 7, radius = 7, shootEffect = CONST_ANI_FIRE, effect = CONST_ME_FIREAREA, target = true },
	{ name = "combat", interval = 3000, chance = 66, type = COMBAT_MANADRAIN, minDamage = -600, maxDamage = -700, radius = 10, effect = CONST_ME_ENERGYAREA, target = false },
	{ name = "combat", interval = 2000, chance = 65, type = COMBAT_ENERGYDAMAGE, minDamage = -400, maxDamage = -800, length = 8, spread = 0, effect = CONST_ME_MAGIC_RED, target = false },
	{ name = "condition", type = CONDITION_POISON, interval = 5000, chance = 85, minDamage = -800, maxDamage = -1000, effect = CONST_ME_HITBYPOISON, target = false },
	{ name = "combat", interval = 2000, chance = 72, type = COMBAT_LIFEDRAIN, minDamage = -600, maxDamage = -1200, radius = 14, effect = CONST_ME_MAGIC_GREEN, target = false },
	-- Additional cinematic attacks.
	{ name = "combat", interval = 2500, chance = 78, type = COMBAT_FIREDAMAGE, minDamage = -700, maxDamage = -1500, radius = 4, effect = CONST_ME_EXPLOSIONAREA, target = false },
	{ name = "combat", interval = 3000, chance = 48, type = COMBAT_DEATHDAMAGE, minDamage = -700, maxDamage = -1600, length = 10, spread = 3, effect = CONST_ME_MORTAREA, target = false },
}

monster.defenses = {
	defense = 145,
	armor = 188,
	{ name = "combat", interval = 1000, chance = 65, type = COMBAT_HEALING, minDamage = 1000, maxDamage = 3000, effect = CONST_ME_MAGIC_BLUE, target = false },
	{ name = "speed", interval = 2000, chance = 45, speedChange = 480, effect = CONST_ME_MAGIC_RED, target = false, duration = 6000 },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 80 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 100 },
	{ type = COMBAT_EARTHDAMAGE, percent = 100 },
	{ type = COMBAT_FIREDAMAGE, percent = 100 },
	{ type = COMBAT_LIFEDRAIN, percent = 100 },
	{ type = COMBAT_MANADRAIN, percent = 60 },
	{ type = COMBAT_DROWNDAMAGE, percent = 55 },
	{ type = COMBAT_ICEDAMAGE, percent = 30 },
	{ type = COMBAT_HOLYDAMAGE, percent = 35 },
	{ type = COMBAT_DEATHDAMAGE, percent = 1 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = false },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = false },
}

mType.onThink = function(boss, interval)
	local bossId = boss:getId()
	local state = apocalypseStates[bossId]
	if not state then
		state = {
			visualTicks = 0,
			visualIndex = 0,
			activatedPhases = {},
			spawnSequenceStarted = false,
		}
		apocalypseStates[bossId] = state
	end

	state.visualTicks = state.visualTicks + interval
	if state.visualTicks >= VISUAL_INTERVAL then
		state.visualTicks = state.visualTicks - VISUAL_INTERVAL
		state.visualIndex = (state.visualIndex % #visualEffects) + 1

		local position = boss:getPosition()
		local effect = visualEffects[state.visualIndex]
		sendEffect(position, effect)
		sendCrossEffects(position, effect)
	end

	local maximumHealth = boss:getMaxHealth()
	if maximumHealth > 0 then
		local healthPercent = (boss:getHealth() * 100) / maximumHealth
		for phaseIndex, phase in ipairs(phases) do
			if healthPercent <= phase.healthPercent and not state.activatedPhases[phaseIndex] then
				state.activatedPhases[phaseIndex] = true
				activatePhase(boss, phase)
			end
		end
	end

	return true
end

mType.onAppear = function(boss, creature)
	if boss:getType():isRewardBoss() then
		boss:setReward(true)
	end

	local bossId = boss:getId()
	local state = apocalypseStates[bossId]
	if not state then
		state = {
			visualTicks = 0,
			visualIndex = 0,
			activatedPhases = {},
			spawnSequenceStarted = false,
		}
		apocalypseStates[bossId] = state
	end

	if state.spawnSequenceStarted then
		return true
	end
	state.spawnSequenceStarted = true

	for stage = 1, 4 do
		addEvent(playSpawnSequence, stage * 400, bossId, stage)
	end

	return true
end

mType.onDisappear = function(boss, creature)
	if creature and boss:getId() == creature:getId() then
		apocalypseStates[boss:getId()] = nil
	end
	return true
end

mType:register(monster)