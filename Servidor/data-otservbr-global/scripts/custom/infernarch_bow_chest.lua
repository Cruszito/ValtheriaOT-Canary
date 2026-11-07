
local config = {
    -- Storage compartido por los 11 cofres.
    sharedStorage = 950000,

    -- Storages de la versión anterior.
    -- Evita que jugadores que ya recibieron
    -- un arma puedan reclamar otra.
    legacyStorages = {
        950020,
        950022,
        950023,
        950024,
        950025,
        950026,
        950027,
        950028,
        950029,
        950030,
        950031,
    },

    rewards = {
        [45020] = {
            itemId = 49520,
            itemName = "Infernarch Bow",
        },
        [45022] = {
            itemId = 49522,
            itemName = "Infernarch Arbalest",
        },
        [45023] = {
            itemId = 49523,
            itemName = "Infernarch Battleaxe",
        },
        [45024] = {
            itemId = 49524,
            itemName = "Infernarch Greataxe",
        },
        [45025] = {
            itemId = 49525,
            itemName = "Infernarch Flail",
        },
        [45026] = {
            itemId = 49526,
            itemName = "Infernarch Warhammer",
        },
        [45027] = {
            itemId = 49527,
            itemName = "Infernarch Blade",
        },
        [45028] = {
            itemId = 49530,
            itemName = "Inferniarch Slayer",
        },
        [45029] = {
            itemId = 49528,
            itemName = "Inferniarch Wand",
        },
        [45030] = {
            itemId = 49529,
            itemName = "Inferniarch Rod",
        },
        [45031] = {
            itemId = 50250,
            itemName = "Infernarch Claws",
        },
    },
}

local infernarchChests = Action()

-- Comprueba si el personaje ya reclamó un arma.
local function hasAlreadySelectedWeapon(player)

    -- Verificar storage compartido.
    if player:getStorageValue(config.sharedStorage) >= 1 then
        return true
    end

    -- Verificar storages antiguos.
    for _, storage in ipairs(config.legacyStorages) do
        if player:getStorageValue(storage) >= 1 then
            return true
        end
    end

    return false
end

function infernarchChests.onUse(player, item, fromPosition, target, toPosition, isHotkey)

    local rewardConfig = config.rewards[item:getActionId()]

    if not rewardConfig then
        return true
    end

    -- Bloquear si ya obtuvo cualquier arma.
    if hasAlreadySelectedWeapon(player) then

        player:sendTextMessage(
            MESSAGE_EVENT_ADVANCE,
            "You have already selected your Infernarch weapon."
        )

        player:getPosition():sendMagicEffect(CONST_ME_POFF)

        return true
    end

    -- Entregar el arma seleccionada.
    local reward = player:addItem(
        rewardConfig.itemId,
        1,
        false
    )

    -- Validar capacidad y espacio.
    if not reward then

        player:sendTextMessage(
            MESSAGE_EVENT_ADVANCE,
            "You do not have enough capacity or inventory space."
        )

        player:getPosition():sendMagicEffect(CONST_ME_POFF)

        return true
    end

    -- Registrar la recompensa del personaje.
    player:setStorageValue(
        config.sharedStorage,
        rewardConfig.itemId
    )

    player:sendTextMessage(
        MESSAGE_EVENT_ADVANCE,
        "You have selected the " .. rewardConfig.itemName .. "."
    )

    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)

    return true
end

-- Registrar los 11 cofres.
for actionId in pairs(config.rewards) do
    infernarchChests:aid(actionId)
end

infernarchChests:register()

logger.info("[Infernarch Chests] Registered 11 exclusive reward chests.")
