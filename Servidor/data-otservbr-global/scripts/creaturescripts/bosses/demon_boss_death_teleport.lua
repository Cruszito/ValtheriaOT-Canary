local config = {
	teleportItemId = 1949,
	teleportActionId = 45003,
	teleportDuration = 60, -- segundos
	effectCreate = CONST_ME_TELEPORT,
	effectRemove = CONST_ME_POFF,

	-- Texto que aparecerá encima del portal
	teleportText = "Portal Abierto!",
	teleportTextInterval = 3 * 1000, -- cada 3 segundos
	teleportTextColor = TEXTCOLOR_ORANGE or TEXTCOLOR_LIGHTBLUE or 192,

	bosses = {
		["fire demon"] = {
			-- Donde caerán los jugadores para el segundo boss
			teleportDestination = Position(32389, 32002, 6),
			nextBoss = {
				name = "Ice Demon",
				position = Position(32393, 31998, 6)
			}
		},

		["ice demon"] = {
			-- Donde caerán los jugadores para el tercer boss
			teleportDestination = Position(32389, 32002, 5),
			nextBoss = {
				name = "Energy Demon",
				position = Position(32393, 31998, 5)
			}
		},

		["energy demon"] = {
			-- Donde caerán los jugadores para el cuarto boss
			teleportDestination = Position(32390, 32003, 4),
			nextBoss = {
				name = "Poison Demon",
				position = Position(32394, 31999, 4)
			}
		},

		["poison demon"] = {
			-- Donde caerán los jugadores para el quinto boss
			teleportDestination = Position(32391, 32004, 3),
			nextBoss = {
				name = "Death Demon",
				position = Position(32395, 32000, 3)
			}
		},

		["death demon"] = {
			-- Donde caerán los jugadores para el sexto boss
			teleportDestination = Position(32392, 32005, 2),
			nextBoss = {
				name = "Holy Demon",
				position = Position(32396, 32001, 2)
			}
		},

		["holy demon"] = {
			-- Donde caerán los jugadores para el séptimo boss
			teleportDestination = Position(32394, 32007, 0),
			nextBoss = {
				name = "Blood Demon",
				position = Position(32397, 32003, 0)
			}
		},

		["blood demon"] = {
			-- Salida / reward room después del último boss
			teleportDestination = Position(32363, 32003, 8),
			nextBoss = nil
		}
	}
}

local function hasTemporaryTeleport(position)
	local tile = Tile(position)
	if not tile then
		return false
	end

	local items = tile:getItems()
	if not items then
		return false
	end

	for _, item in ipairs(items) do
		if item:getId() == config.teleportItemId and item:getActionId() == config.teleportActionId then
			return true
		end
	end

	return false
end

local function sendTeleportAnimatedText(position)
	-- Efecto visual sobre el portal para que se note
	position:sendMagicEffect(CONST_ME_TUTORIALARROW)

	local spectators = Game.getSpectators(position, false, true, 8, 8, 6, 6)
	if not spectators then
		return
	end

	for _, spectator in ipairs(spectators) do
		if spectator:isPlayer() then
			-- Mensaje seguro para que el jugador sepa que el portal está abierto
			spectator:sendTextMessage(MESSAGE_EVENT_ADVANCE, config.teleportText .. " El portal desaparece en 60 segundos.")

			-- Intento de texto visible en la posición del portal.
			-- En algunos sources esto sí muestra texto encima del portal.
			pcall(function()
				spectator:say(config.teleportText, TALKTYPE_MONSTER_SAY, false, nil, position)
			end)
		end
	end
end

local function repeatTeleportText(position, endTime)
	if os.time() >= endTime then
		return
	end

	if not hasTemporaryTeleport(position) then
		return
	end

	sendTeleportAnimatedText(position)

	addEvent(repeatTeleportText, config.teleportTextInterval, position, endTime)
end

local function removeTeleport(position)
	local tile = Tile(position)
	if not tile then
		return
	end

	local items = tile:getItems()
	if not items then
		return
	end

	for _, item in ipairs(items) do
		if item:getId() == config.teleportItemId and item:getActionId() == config.teleportActionId then
			item:remove()
			position:sendMagicEffect(config.effectRemove)
			return
		end
	end
end

local function createTemporaryTeleport(position, destination)
	local teleport = Game.createItem(config.teleportItemId, 1, position)
	if not teleport then
		print("[DemonBossDeathTeleport] Could not create teleport at position: " .. position.x .. ", " .. position.y .. ", " .. position.z)
		return false
	end

	teleport:setActionId(config.teleportActionId)
	teleport:setDestination(destination)

	position:sendMagicEffect(config.effectCreate)

	-- Texto encima del teleport mientras esté activo
	sendTeleportAnimatedText(position)
	addEvent(repeatTeleportText, config.teleportTextInterval, position, os.time() + config.teleportDuration)

	addEvent(removeTeleport, config.teleportDuration * 1000, position)

	return true
end

local function spawnNextBoss(nextBoss)
	if not nextBoss then
		return true
	end

	local boss = Game.createMonster(nextBoss.name, nextBoss.position, true, true)
	if not boss then
		print("[DemonBossDeathTeleport] Could not create boss: " .. nextBoss.name .. " at position: " .. nextBoss.position.x .. ", " .. nextBoss.position.y .. ", " .. nextBoss.position.z)
		return false
	end

	nextBoss.position:sendMagicEffect(CONST_ME_TELEPORT)

	return true
end

local demonBossDeathTeleport = CreatureEvent("DemonBossDeathTeleport")

function demonBossDeathTeleport.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	local bossName = creature:getName():lower()
	local bossConfig = config.bosses[bossName]

	if not bossConfig then
		print("[DemonBossDeathTeleport] Boss not configured: " .. creature:getName())
		return true
	end

	local deathPosition = creature:getPosition()

	-- Quita el cuerpo para que el corpse se convierta visualmente en teleport
	if corpse then
		corpse:remove()
	end

	-- Crea el portal y le asigna el destino correcto
	createTemporaryTeleport(deathPosition, bossConfig.teleportDestination)

	-- Crea el siguiente boss
	spawnNextBoss(bossConfig.nextBoss)

	return true
end

demonBossDeathTeleport:register()