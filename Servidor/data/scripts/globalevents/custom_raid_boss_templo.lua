local raidBossConfig = {
	enabled = true,

	-- Cada cuanto se lanza la raid (segundos).
    interval = 3 * 60 * 60, -- 2 horas

	-- Tiempo para volver a intentar si todavia hay un boss vivo.
	activeBossRetryDelay = 30 * 60, -- 30 minutos

	-- Tiempo para volver a intentar si no se pudo crear el boss.
	failedSpawnRetryDelay = 10 * 60, -- 10 minutos

	-- Avisos antes del spawn (segundos).
	warningsBefore = {
		10 * 60, -- 10 minutos
		5 * 60, -- 5 minutos
		2 * 60, -- 2 minutos
		1 * 60, -- 1 minuto
	},

	-- Posiciones donde intentara aparecer el boss.
	spawnPositions = {
		Position(32373, 32292, 9),
		Position(32371, 32292, 9),
		Position(32372, 32292, 9),
	},

	-- Si esta en true, intentara utilizar el boosted boss del servidor.
	-- Si no existe uno valido, utilizara la lista de bosses de abajo.
	useTodayBoostedBoss = false,

	-- Bosses creados con los lookTypes 2192 al 2197.
	bosses = {
		"Voltrakar the Stormborn", -- lookType 2192
		"Malverox the Venomous", -- lookType 2193
		"Aurakar the Sunforged", -- lookType 2194
		"Cryonath the Frozen", -- lookType 2195
		"Ignivar the Hellforged", -- lookType 2196
		"Nocthar the Voidborn", -- lookType 2197
	},

	-- Multiplicador aplicado a la vida del boss creado por esta raid.
	healthMultiplier = 1.5,

	-- Este evento se retira del boss de raid para que no cree un
	-- teleport al morir, aunque el evento siga en el archivo del monstruo.
	deathTeleportEvent = "CustomQuestBossDeathTeleport",

	-- Area para validar si ya hay un boss vivo en la zona.
	checkRangeX = 15,
	checkRangeY = 15,
}

local nextSpawnTime = os.time() + raidBossConfig.interval
local announcedWarnings = {}
local selectedBossName = nil

local function resetRaidAnnouncements()
	announcedWarnings = {}
end

local function scheduleNextRaid(delay)
	nextSpawnTime = os.time() + delay
	selectedBossName = nil
	resetRaidAnnouncements()
end

local function getRaidCenterPosition()
	return raidBossConfig.spawnPositions[1]
end

local function broadcastRaidWarning(bossName, secondsLeft)
	local minutesLeft = math.max(1, math.ceil(secondsLeft / 60))

	Game.broadcastMessage(
		string.format("[Raid Boss] %s aparecera en %d minuto(s) en la zona de raids.", bossName, minutesLeft),
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

local function isConfiguredRaidBoss(monsterName)
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

	return false
end

local function hasRaidBossAlive()
	local spectators = Game.getSpectators(
		getRaidCenterPosition(),
		false,
		false,
		raidBossConfig.checkRangeX,
		raidBossConfig.checkRangeX,
		raidBossConfig.checkRangeY,
		raidBossConfig.checkRangeY
	)

	for _, spectator in ipairs(spectators) do
		if spectator:isMonster() and isConfiguredRaidBoss(spectator:getName():lower()) then
			return true
		end
	end

	return false
end

local function createRaidBoss(bossName)
	-- Comienza en una posicion aleatoria y prueba las demas si es necesario.
	local positionCount = #raidBossConfig.spawnPositions
	local startIndex = math.random(positionCount)

	for offset = 0, positionCount - 1 do
		local index = ((startIndex + offset - 1) % positionCount) + 1
		local position = raidBossConfig.spawnPositions[index]
		local tile = Tile(position)

		if tile then
			-- extended = true, force = true
			local monster = Game.createMonster(bossName, position, true, true)
			if monster then
				monster:unregisterEvent(raidBossConfig.deathTeleportEvent)
				return monster
			end
		else
			logger.warn("[Raid Boss] No existe tile en position: {}, {}, {}", position.x, position.y, position.z)
		end
	end

	return nil
end

local function boostRaidBoss(monster)
	local maxHealth = monster:getMaxHealth()
	local boostedHealth = math.floor(maxHealth * raidBossConfig.healthMultiplier)

	monster:setMaxHealth(boostedHealth)
	monster:addHealth(boostedHealth)

	-- Efecto visual del fortalecimiento del boss.
	monster:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	monster:say("I have been empowered by the raid force!", TALKTYPE_MONSTER_SAY)
end

local function processRaidWarning(now)
	local secondsLeft = nextSpawnTime - now
	local warningToAnnounce = nil

	-- Selecciona solo el aviso pendiente mas cercano para evitar mensajes
	-- atrasados o varios avisos simultaneos despues de un lag/reinicio.
	for _, warningTime in ipairs(raidBossConfig.warningsBefore) do
		if not announcedWarnings[warningTime] and secondsLeft > 0 and secondsLeft <= warningTime then
			if not warningToAnnounce or warningTime < warningToAnnounce then
				warningToAnnounce = warningTime
			end
		end
	end

	if not warningToAnnounce then
		return false
	end

	broadcastRaidWarning(selectedBossName, secondsLeft)

	-- Marca tambien los avisos mas antiguos que ya se hayan pasado.
	for _, warningTime in ipairs(raidBossConfig.warningsBefore) do
		if warningTime >= warningToAnnounce then
			announcedWarnings[warningTime] = true
		end
	end

	return true
end

local customRaidBoss = GlobalEvent("custom.raid.elemental.bosses")

function customRaidBoss.onThink(interval, lastExecution)
	if not raidBossConfig.enabled then
		return true
	end

	local now = os.time()

	if not selectedBossName then
		selectedBossName = getRandomRaidBoss()
	end

	if now < nextSpawnTime then
		processRaidWarning(now)
		return true
	end

	if hasRaidBossAlive() then
		Game.broadcastMessage(
			"[Raid Boss] Aun hay un boss activo en la zona de raids. El siguiente intento sera en 30 minutos.",
			MESSAGE_GAME_HIGHLIGHT
		)

		scheduleNextRaid(raidBossConfig.activeBossRetryDelay)
		return true
	end

	local monster = createRaidBoss(selectedBossName)

	if monster then
		boostRaidBoss(monster)

		Game.broadcastMessage(
			string.format("[Raid Boss] %s ha aparecido en la zona de raids.", selectedBossName),
			MESSAGE_GAME_HIGHLIGHT
		)

		logger.info("[Raid Boss] Spawned raid boss: {}", selectedBossName)
		scheduleNextRaid(raidBossConfig.interval)
	else
		Game.broadcastMessage(
			string.format("[Raid Boss] No se pudo crear el boss: %s. Se intentara nuevamente en 10 minutos.", selectedBossName),
			MESSAGE_GAME_HIGHLIGHT
		)

		logger.error("[Raid Boss] Could not spawn boss: {}", selectedBossName)
		scheduleNextRaid(raidBossConfig.failedSpawnRetryDelay)
	end

	return true
end

customRaidBoss:interval(60 * 1000)
customRaidBoss:register()