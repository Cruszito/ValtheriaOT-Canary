-- Endless Forge Arena - Canary / RevScriptSys
-- Instalar UNICAMENTE en data/scripts/custom/endless_forge_arena.lua.
-- Requiere el sistema ForgeSystemMonster incluido en tu data.
-- No ejecutar /reload durante una partida: reiniciar el servidor para actualizar.
local config = {
    from = Position(32489, 32321, 7),
    to = Position(32502, 32333, 7),
    lever = Position(32499, 32335, 7),
    activator = Position(32499, 32336, 7),
    -- Tu entrada indicada coincide con lever (fuera del rectangulo).
    -- Este es un centro INTERIOR provisional para distribuir al equipo.
    arrival = Position(32496, 32331, 7),
    -- Tu salida indicada (32489,32333,7) esta DENTRO del rectangulo.
    -- Salida EXTERIOR provisional. Debe tener suelo libre en tu mapa.
    exit = Position( 32502, 32337, 7),
    waiting = {
        Position(32498, 32335, 7), Position(32500, 32335, 7),
        Position(32498, 32336, 7), Position(32499, 32336, 7),
        Position(32500, 32336, 7), Position(32498, 32337, 7),
        Position(32499, 32337, 7), Position(32500, 32337, 7),
        Position(32498, 32338, 7), Position(32499, 32338, 7),
        Position(32500, 32338, 7),
    },
    initialDelayMs = 5000,
    betweenWavesMs = 8000,
    checkIntervalMs = 1000,
    timeLimitSeconds = 30 * 60,
    finalLootSeconds = 60,
    cooldownSeconds = 0, -- Sin espera adicional; el loot y la ocupacion siguen bloqueando.
    -- Sin premio adicional inventado: se conserva XP/loot/dust/slivers nativos.
    -- Cantidad = base + extraPerPlayer por cada jugador adicional al iniciar.
    waves = {
        { name = "Dragon",        base = 3, extraPerPlayer = 1, fiendish = 1 },
        { name = "Dragon Lord",   base = 3, extraPerPlayer = 1, fiendish = 1 },
        { name = "Wyrm",          base = 4, extraPerPlayer = 1, fiendish = 1 },
        { name = "Hydra",         base = 4, extraPerPlayer = 1, fiendish = 1 },
        { name = "Frost Dragon",  base = 4, extraPerPlayer = 1, fiendish = 2 },
        { name = "Serpent Spawn", base = 4, extraPerPlayer = 1, fiendish = 2 },
        { name = "Medusa",        base = 4, extraPerPlayer = 1, fiendish = 2 },
        { name = "Destroyer",     base = 5, extraPerPlayer = 1, fiendish = 2 },
        { name = "Demon",         base = 5, extraPerPlayer = 1, fiendish = 2 },
        { name = "Hellhound",     base = 5, extraPerPlayer = 1, fiendish = 2 },
    },
}

local EVENT_DEATH = "EndlessForgeArenaDeath"
local EVENT_LOGOUT = "EndlessForgeArenaLogout"
local EVENT_PLAYER_DEATH = "EndlessForgeArenaPlayerDeath"
local state = { session = nil, serial = 0, nextAllowed = 0 }
local startWave, tick, finish, schedule

local function samePosition(a, b)
    return a.x == b.x and a.y == b.y and a.z == b.z
end

local function inside(pos)
    return pos.z == config.from.z and pos.x >= config.from.x
        and pos.x <= config.to.x and pos.y >= config.from.y and pos.y <= config.to.y
end

local function creaturesInArena()
    local center = Position(math.floor((config.from.x + config.to.x) / 2),
        math.floor((config.from.y + config.to.y) / 2), config.from.z)
    local found = Game.getSpectators(center, false, false,
        center.x - config.from.x, config.to.x - center.x,
        center.y - config.from.y, config.to.y - center.y)
    local result = {}
    for _, creature in ipairs(found) do
        if inside(creature:getPosition()) then result[#result + 1] = creature end
    end
    return result
end

local function walkable(pos, avoidPz)
    local tile = Tile(pos)
    return tile and tile:isWalkable(avoidPz, true, true, true) and not tile:getTopCreature()
end

local function broadcast(session, message)
    for guid, id in pairs(session.players) do
        local player = Player(id)
        if player and player:getGuid() == guid and inside(player:getPosition()) then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
        end
    end
end

-- Al crear un monstruo, onSpawn puede haberlo inscrito automaticamente
-- en la forja global. Se retira solo ESTE ID, sin crear reemplazos.
local function detachFromGlobalForge(monster)
    local id = monster:getId()
    for _, entry in pairs(Game.getFiendishMonsters()) do
        if entry == id then Game.removeFiendishMonster(id, false); break end
    end
    for _, entry in pairs(Game.getInfluencedMonsters()) do
        if entry == id then Game.removeInfluencedMonster(id, false); break end
    end
end

local function removeMonster(monster)
    -- Tambien limpiar summons de los monstruos de esta arena.
    for _, summon in ipairs(monster:getSummons()) do removeMonster(summon) end
    detachFromGlobalForge(monster)
    monster:setMonsterForgeClassification(FORGE_NORMAL_MONSTER)
    monster:remove()
end

local function unregisterPlayer(player)
    player:unregisterEvent(EVENT_LOGOUT)
    player:unregisterEvent(EVENT_PLAYER_DEATH)
end

local function safeExit(player)
    -- Primero buscar un tile libre alrededor de la salida EXTERIOR.
    for radius = 0, 4 do
        for dx = -radius, radius do
            for dy = -radius, radius do
                local pos = Position(config.exit.x + dx, config.exit.y + dy, config.exit.z)
                if not inside(pos) and walkable(pos, false)
                    and Tile(pos):queryAdd(player) == RETURNVALUE_NOERROR then
                    if player:teleportTo(pos) then
                        pos:sendMagicEffect(CONST_ME_TELEPORT)
                        return true
                    end
                end
            end
        end
    end
    -- Si la salida se bloqueo durante la partida, usar el templo.
    return player:teleportTo(player:getTown():getTemplePosition())
end

local function fail(reason)
    print("[EndlessForgeArena] " .. tostring(reason))
    finish("Arena cancelada: " .. tostring(reason))
end

finish = function(message)
    local session = state.session
    if not session then return end
    state.session = nil -- Invalida callbacks antes de retirar criaturas.
    state.nextAllowed = os.time() + config.cooldownSeconds
    for eventId in pairs(session.events) do stopEvent(eventId) end
    for id in pairs(session.alive) do
        local monster = Monster(id)
        if monster then removeMonster(monster) end
    end
    -- La sala se exige vacia al inicio y es de uso exclusivo.
    for _, creature in ipairs(creaturesInArena()) do
        if creature:isMonster() then removeMonster(creature) end
    end
    for guid, id in pairs(session.players) do
        local player = Player(id)
        if player and player:getGuid() == guid then
            unregisterPlayer(player)
            if inside(player:getPosition()) then
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
                if not safeExit(player) then
                    print("[EndlessForgeArena] No se pudo sacar a " .. player:getName())
                end
            end
        end
    end
end

schedule = function(session, delay, callback)
    local eventId
    eventId = addEvent(function()
        session.events[eventId] = nil
        if state.session ~= session then return end
        local ok, err = pcall(callback, session)
        if not ok and state.session == session then fail(err) end
    end, delay)
    session.events[eventId] = true
end

local function setArenaForge(monster, fiendish, session)
    detachFromGlobalForge(monster)
    monster:clearFiendishStatus()
    if not monster:isForgeable() then return false end
    local classification = fiendish and FORGE_FIENDISH_MONSTER or FORGE_INFLUENCED_MONSTER
    monster:setMonsterForgeClassification(classification)
    monster:configureForgeSystem(fiendish and 15 or math.random(1, 5))
    if monster:getMonsterForgeClassification() ~= classification or monster:getForgeStack() <= 0 then
        return false
    end
    if fiendish then
        monster:setTimeToChangeFiendish(session.deadline)
    end
    -- ForgeSystemMonster entrega dust; la clasificacion fiendish permite
    -- slivers y otros callbacks de loot nativos. No se duplican premios.
    monster:registerEvent("ForgeSystemMonster")
    return monster:registerEvent(EVENT_DEATH)
end

local function spawnPositions()
    local result = {}
    -- Mitad superior de la sala; equipo en las filas inferiores.
    for y = config.from.y + 1, config.to.y - 4 do
        for x = config.from.x + 1, config.to.x - 1 do
            local pos = Position(x, y, config.from.z)
            if walkable(pos, true) then result[#result + 1] = pos end
        end
    end
    for i = #result, 2, -1 do
        local j = math.random(i)
        result[i], result[j] = result[j], result[i]
    end
    return result
end

startWave = function(session)
    if session.phase == "loot" then return end
    local wave = config.waves[session.wave]
    if not wave then return fail("Configuracion de oleada inexistente.") end
    session.phase = "combat"
    local total = wave.base + wave.extraPerPlayer * (session.teamSize - 1)
    local positions = spawnPositions()
    local cursor = 1
    for index = 1, total do
        local monster
        while positions[cursor] and not monster do
            monster = Game.createMonster(wave.name, positions[cursor], false, false)
            cursor = cursor + 1
        end
        if not monster then return fail("No hay espacio para " .. wave.name .. ".") end
        session.alive[monster:getId()] = true
        if not setArenaForge(monster, index <= wave.fiendish, session) then
            return fail("No se pudo configurar la forja para " .. wave.name .. ".")
        end
        monster:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
    end
    broadcast(session, string.format("Oleada %d/%d: %d %s (%d fiendish, %d influenced).",
        session.wave, #config.waves, total, wave.name, wave.fiendish, total - wave.fiendish))
end

local function removeParticipant(session, guid, id)
    session.players[guid] = nil
    local player = Player(id)
    if player and player:getGuid() == guid then unregisterPlayer(player) end
end

tick = function(session)
    -- Expulsar intrusos. Solo los jugadores recogidos por la palanca participan.
    local creatures = creaturesInArena()
    for _, creature in ipairs(creatures) do
        if creature:isPlayer() and session.players[creature:getGuid()] ~= creature:getId() then
            creature:sendCancelMessage("Esta arena esta reservada para otro equipo.")
            safeExit(creature)
        end
    end
    local remaining = 0
    for guid, id in pairs(session.players) do
        local player = Player(id)
        if not player or player:getGuid() ~= guid or player:getHealth() <= 0
            or not inside(player:getPosition()) then
            removeParticipant(session, guid, id)
        else
            remaining = remaining + 1
        end
    end
    if remaining == 0 then return finish("La arena quedo vacia.") end
    if session.phase == "loot" then
        if os.time() >= session.lootDeadline then return finish("Completaste las 10 oleadas. Gracias por participar.") end
    elseif os.time() >= session.deadline then
        return finish("Se termino el tiempo de la arena.")
    elseif session.phase == "combat" then
        -- Desaparicion por admin/despawn NO cuenta como muerte valida.
        for id in pairs(session.alive) do
            local monster = Monster(id)
            if not monster or not inside(monster:getPosition()) then
                return fail("Un monstruo desaparecio o salio del area sin morir.")
            end
        end
        local alive = next(session.alive) ~= nil
        -- Incluye summons enemigos; excluye summons de jugadores.
        for _, creature in ipairs(creatures) do
            if creature:isMonster() then
                local master = creature:getMaster()
                if not master or not master:isPlayer() then alive = true end
            end
        end
        if not alive then
            if session.wave == #config.waves then
                session.phase = "loot"
                session.lootDeadline = os.time() + config.finalLootSeconds
                broadcast(session, "Completaste las 10 oleadas. Tienes " .. config.finalLootSeconds .. " segundos para recoger el loot.")
            else
                session.wave = session.wave + 1
                session.phase = "waiting"
                broadcast(session, "Oleada superada. La siguiente comienza en " .. (config.betweenWavesMs / 1000) .. " segundos.")
                schedule(session, config.betweenWavesMs, startWave)
            end
        end
    end
    schedule(session, config.checkIntervalMs, tick)
end

local monsterDeath = CreatureEvent(EVENT_DEATH)
function monsterDeath.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
    local session = state.session
    if session and session.alive[creature:getId()] then
        session.alive[creature:getId()] = nil
        -- Canary genera el loot ANTES de onDeath y ejecuta Monster::death
        -- DESPUES. Neutralizar aqui evita que estas criaturas independientes
        -- intenten reponer monstruos de la forja GLOBAL al morir.
        creature:setMonsterForgeClassification(FORGE_NORMAL_MONSTER)
    end
    return true
end
monsterDeath:register()

local playerDeath = CreatureEvent(EVENT_PLAYER_DEATH)
function playerDeath.onDeath(player, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
    local session = state.session
    if session then session.players[player:getGuid()] = nil end
    return true -- Muerte normal: no se desactivan perdidas ni penalizaciones.
end
playerDeath:register()

local logout = CreatureEvent(EVENT_LOGOUT)
function logout.onLogout(player)
    -- Impedir logout voluntario mientras participa. Desconexion forzada:
    -- onLogin de abajo devuelve al jugador a una salida segura.
    if state.session and state.session.players[player:getGuid()] and inside(player:getPosition()) then
        player:sendCancelMessage("Sal de la arena antes de desconectarte.")
        return false
    end
    return true
end
logout:register()

local login = CreatureEvent("EndlessForgeArenaLogin")
function login.onLogin(player)
    -- Tras reinicio/desconexion no hay reingreso a partidas anteriores.
    if inside(player:getPosition()) then safeExit(player) end
    return true
end
login:register()

local function destinations(players)
    local result = {}
    local candidates = {}
    for y = config.to.y - 3, config.to.y - 1 do
        for x = config.from.x + 1, config.to.x - 1 do
            local pos = Position(x, y, config.from.z)
            if walkable(pos, true) then candidates[#candidates + 1] = pos end
        end
    end
    table.sort(candidates, function(a, b)
        local da = math.abs(a.x - config.arrival.x) + math.abs(a.y - config.arrival.y)
        local db = math.abs(b.x - config.arrival.x) + math.abs(b.y - config.arrival.y)
        if da == db then return a.y < b.y or (a.y == b.y and a.x < b.x) end
        return da < db
    end)
    local used = {}
    for _, player in ipairs(players) do
        local chosen
        for index, pos in ipairs(candidates) do
            if not used[index] and Tile(pos):queryAdd(player) == RETURNVALUE_NOERROR then
                chosen = pos; used[index] = true; break
            end
        end
        if not chosen then return nil end
        result[#result + 1] = chosen
    end
    return result
end

local action = Action()
function action.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not samePosition(player:getPosition(), config.activator) then
        player:sendCancelMessage("Solo puedes activar la palanca desde (la posicion central).")
        return true
    end
    if state.session then
        player:sendCancelMessage("Hay otro equipo en la arena. Espera a que termine.")
        return true
    end
    if os.time() < state.nextAllowed then
        player:sendCancelMessage("La arena aun se esta preparando.")
        return true
    end
    if inside(config.exit) or not Tile(config.exit) or not Tile(config.exit):isWalkable(false, false, true, true) then
        player:sendCancelMessage("Configura una salida exterior con suelo libre antes de iniciar.")
        return true
    end
    if #creaturesInArena() > 0 then
        player:sendCancelMessage("La arena debe estar vacia antes de comenzar.")
        return true
    end
    for _, wave in ipairs(config.waves) do
        if not MonsterType(wave.name) then
            player:sendCancelMessage("Monstruo no disponible en tu datapack: " .. wave.name)
            return true
        end
    end
    local players, origins = {}, {}
    for _, pos in ipairs(config.waiting) do
        local tile = Tile(pos)
        if tile then
            for _, creature in ipairs(tile:getCreatures() or {}) do
                if creature:isPlayer() then
                    players[#players + 1] = creature
                    origins[#origins + 1] = creature:getPosition()
                end
            end
        end
    end
    if #players == 0 then return true end
    local arrivalPositions = destinations(players)
    if not arrivalPositions then
        player:sendCancelMessage("No hay suficientes tiles interiores libres para todo el equipo.")
        return true
    end
    state.serial = state.serial + 1
    local session = { serial = state.serial, players = {}, alive = {}, events = {},
        wave = 1, teamSize = #players, phase = "waiting", deadline = os.time() + config.timeLimitSeconds }
    state.session = session
    for i, member in ipairs(players) do
        session.players[member:getGuid()] = member:getId()
        if not member:teleportTo(arrivalPositions[i]) then
            -- Rollback de los jugadores ya trasladados.
            state.session = nil
            for j = 1, i - 1 do
                players[j]:teleportTo(origins[j])
                unregisterPlayer(players[j])
            end
            player:sendCancelMessage("No se pudo trasladar al equipo. Revisa los tiles de entrada.")
            return true
        end
        member:registerEvent(EVENT_LOGOUT)
        member:registerEvent(EVENT_PLAYER_DEATH)
        arrivalPositions[i]:sendMagicEffect(CONST_ME_TELEPORT)
    end
    broadcast(session, "Arena iniciada para " .. #players .. " jugador(es). Primera oleada en 5 segundos.")
    schedule(session, config.initialDelayMs, startWave)
    schedule(session, config.checkIntervalMs, tick)
    return true
end
-- Registro por posicion: no necesitas asignar Action ID.
action:position(config.lever)
action:register()
