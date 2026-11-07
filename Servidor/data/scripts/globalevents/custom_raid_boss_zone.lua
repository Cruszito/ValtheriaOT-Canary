local raidBossConfig = {
	enabled = true,

	-- Cada cuánto se lanza la raid
	interval = 2 * 60 * 60, -- 2 horas

	-- Avisos antes del spawn
	warningsBefore = {
		10 * 60, -- 10 minutos
		5 * 60, -- 5 minutos
		2 * 60, -- 2 minutos
		1 * 60, -- 1 minuto
	},

	-- Posiciones donde intentará aparecer el boss
	spawnPositions = {
		Position(32149, 32212, 7),
		Position(32160, 32214, 7),
		Position(32151, 32225, 7),
		Position(32147, 32215, 7),
		Position(32129, 32220, 7),
		Position(32124, 32216, 7),
		Position(32153, 32205, 7),
	},

	-- Si quieres que siempre salga el boosted boss actual del servidor, pon true.
	-- Si lo dejas false, usará la lista de bosses de abajo.
	useTodayBoostedBoss = false,

	-- Lista de bosses posibles si useTodayBoostedBoss = false
	bosses = {
		"Morgaroth",
		"Ghazbaran",
		"Orshabaal",
        "Demodras",
		"Grand Master Oberon",
		"Vok the Freakish",
		"Gnomevil",
		"The Baron from Below",
		"The Count of the Core",
		"The Duke of the Depths",
		"Ravenous Hunger",
		"Earl Osam",
		"Gaffir",
		"Lord Azaram",
		"Count Vlarkorth",
		"Custodian",
		"Guard Captain Quaid",
		"Duke Krule",
		"Grand Commander Soeren",
		"Grand Chaplain Gaunder",
		"Preceptor Lazare",
		"Grand Canon Dominus",
		"Lady Tenebris",
		"Lloyd",
		"Mawhawk",
		"Furyosa",
		"The Welter",
		"Apocalypse",
        "Goshnar's Cruelty",
        "Goshnar's Greed",
        "Goshnar's Hatred",
        "Goshnar's Malice",
        "Goshnar's Spite",
        "King Zelos",
        "The Monster",
        "Magma Bubble",
	},

	-- Potenciadores del boss de raid
	healthMultiplier = 1.5, -- x1.5 vida
	criticalChance = 10, -- 10% crítico
	criticalDamage = 10, -- +10% daño crítico

	-- Área para validar si ya hay un boss vivo en la zona
	checkRangeX = 15,
	checkRangeY = 15,
}

local nextSpawnTime = os.time() + raidBossConfig.interval
local announcedWarnings = {}
local selectedBossName = nil

local function resetRaidAnnouncements()
	announcedWarnings = {}
end

local function getRaidCenterPosition()
	return raidBossConfig.spawnPositions[1]
end

local function broadcastRaidWarning(bossName, secondsLeft)
	local minutesLeft = math.floor(secondsLeft / 60)

	Game.broadcastMessage(
		string.format("[Raid Boss] %s aparecerá en %d minuto(s) en la zona de raids.", bossName, minutesLeft),
		MESSAGE_GAME_HIGHLIGHT
	)
end

local function getRandomRaidBoss()
	if raidBossConfig.useTodayBoostedBoss then
		local boostedBoss = Game.getBoostedBoss()
		if boostedBoss and boostedBoss ~= "" then
			return boostedBoss
		end
	end

	return raidBossConfig.bosses[math.random(#raidBossConfig.bosses)]
end

local function hasRaidBossAlive()
	local centerPosition = getRaidCenterPosition()

	local spectators = Game.getSpectators(
		centerPosition,
		false,
		false,
		raidBossConfig.checkRangeX,
		raidBossConfig.checkRangeX,
		raidBossConfig.checkRangeY,
		raidBossConfig.checkRangeY
	)

	for _, spectator in ipairs(spectators) do
		if spectator:isMonster() then
			local monsterName = spectator:getName():lower()

			for _, bossName in ipairs(raidBossConfig.bosses) do
				if monsterName == bossName:lower() then
					return true
				end
			end

			if raidBossConfig.useTodayBoostedBoss then
				local boostedBoss = Game.getBoostedBoss()
				if boostedBoss and boostedBoss ~= "" and monsterName == boostedBoss:lower() then
					return true
				end
			end
		end
	end

	return false
end

local function createRaidBoss(bossName)
	for _, position in ipairs(raidBossConfig.spawnPositions) do
		local tile = Tile(position)

		if tile then
			local monster = Game.createMonster(bossName, position, true, true)
			if monster then
				return monster
			end
		else
			logger.warn("[Raid Boss] No existe tile en position: {}, {}, {}", position.x, position.y, position.z)
		end
	end

	return nil
end

local function boostRaidBoss(monster)
	if not monster then
		return
	end

	local maxHealth = monster:getMaxHealth()
	local boostedHealth = math.floor(maxHealth * raidBossConfig.healthMultiplier)

	monster:setMaxHealth(boostedHealth)
	monster:setHealth(boostedHealth)

	if monster.criticalChance then
		monster:criticalChance(raidBossConfig.criticalChance)
	end

	if monster.criticalDamage then
		monster:criticalDamage(raidBossConfig.criticalDamage)
	end

	monster:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	monster:say("I have been empowered by the raid force!", TALKTYPE_MONSTER_SAY)
end

local customRaidBoss = GlobalEvent("custom.raid.boss.zone")

function customRaidBoss.onThink(interval, lastExecution)
	if not raidBossConfig.enabled then
		return true
	end

	local now = os.time()

	if not selectedBossName then
		selectedBossName = getRandomRaidBoss()
	end

	for _, warningTime in ipairs(raidBossConfig.warningsBefore) do
		if not announcedWarnings[warningTime] and now >= nextSpawnTime - warningTime and now < nextSpawnTime then
			broadcastRaidWarning(selectedBossName, warningTime)
			announcedWarnings[warningTime] = true
			return true
		end
	end

	if now >= nextSpawnTime then
		if hasRaidBossAlive() then
			Game.broadcastMessage(
				"[Raid Boss] Aún hay un boss activo en la zona de raids. El siguiente intento será en 30 minutos.",
				MESSAGE_GAME_HIGHLIGHT
			)

			nextSpawnTime = now + (2 * 60 * 60)
			resetRaidAnnouncements()
			selectedBossName = nil
			return true
		end

		local monster = createRaidBoss(selectedBossName)

		if monster then
			boostRaidBoss(monster)

			Game.broadcastMessage(
				string.format("[Raid Boss] %s ha aparecido en la zona de raids.", selectedBossName),
				MESSAGE_GAME_HIGHLIGHT
			)

			logger.info("[Raid Boss] Spawned boosted raid boss: {}", selectedBossName)

			nextSpawnTime = now + raidBossConfig.interval
			resetRaidAnnouncements()
			selectedBossName = nil
		else
			Game.broadcastMessage(
				string.format("[Raid Boss] No se pudo crear el boss: %s. Se intentará nuevamente en 10 minutos.", selectedBossName),
				MESSAGE_GAME_HIGHLIGHT
			)

			logger.error("[Raid Boss] Could not spawn boss: {}", selectedBossName)

			nextSpawnTime = now + (10 * 60)
			resetRaidAnnouncements()
			selectedBossName = nil
		end
	end

	return true
end

customRaidBoss:interval(60000)
customRaidBoss:register()