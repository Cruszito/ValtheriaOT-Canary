-- Hunting Ticket (Canary) - Item 55045
-- +30% experience for the selected monster for 60 minutes.
-- Search command (separate TalkAction): !huntsearch <name>
-- NOTE: The experience modifier must also be installed in Player:onGainExperience.

HuntingTicket = {
    itemId = 55045,
    bonus = 30,
    duration = 60 * 60,
    pageSize = 20,
    maxActive = 3,
    modalList = 55045,
    modalConfirm = 55046,
    storageMonster = "hunting-ticket-monster",
    storageExpires = "hunting-ticket-expires",
    sessions = {}
}

local HT = HuntingTicket

-- Three independent persistent slots. Legacy single-ticket data is migrated.
function HT.clearExpired(player)
    local kv, now = player:kv(), os.time()
    -- Migrate an existing ticket rather than losing an already purchased boost.
    local oldName = kv:get(HT.storageMonster)
    local oldExpiry = tonumber(kv:get(HT.storageExpires)) or 0
    if type(oldName) == "string" and oldName ~= "" and oldExpiry > now then
        local found = false
        for i = 1, HT.maxActive do
            local name = kv:get(HT.storageMonster .. "-" .. i)
            if type(name) == "string" and name:lower() == oldName:lower() then
                found = true
                break
            end
        end
        if not found then
            for i = 1, HT.maxActive do
                local key = HT.storageExpires .. "-" .. i
                if (tonumber(kv:get(key)) or 0) <= now then
                    kv:set(HT.storageMonster .. "-" .. i, oldName:lower())
                    kv:set(key, oldExpiry)
                    break
                end
            end
        end
    end
    kv:remove(HT.storageMonster)
    kv:remove(HT.storageExpires)
    for i = 1, HT.maxActive do
        local expKey = HT.storageExpires .. "-" .. i
        if (tonumber(kv:get(expKey)) or 0) <= now then
            kv:remove(HT.storageMonster .. "-" .. i)
            kv:remove(expKey)
        end
    end
end

function HT.getActives(player)
    HT.clearExpired(player)
    local kv, result = player:kv(), {}
    for i = 1, HT.maxActive do
        local name = kv:get(HT.storageMonster .. "-" .. i)
        local expires = tonumber(kv:get(HT.storageExpires .. "-" .. i)) or 0
        if type(name) == "string" and name ~= "" and expires > os.time() then
            result[#result + 1] = {monster = name:lower(), expires = expires, slot = i}
        end
    end
    return result
end

function HT.getActive(player, targetName)
    local active = HT.getActives(player)
    if targetName then
        for _, info in ipairs(active) do
            if info.monster == targetName:lower() then
                return info.monster, info.expires
            end
        end
        return nil, 0
    end
    if #active > 0 then return active[1].monster, active[1].expires end
    return nil, 0
end

function HT.canActivate(player, monster)
    local active = HT.getActives(player)
    if #active >= HT.maxActive then
        return false, "You already have 3 active Hunting Tickets."
    end
    if monster then
        for _, info in ipairs(active) do
            if info.monster == monster:lower() then
                return false, "You already have an active ticket for " .. monster .. "."
            end
        end
    end
    return true
end

function HT.activate(player, monster)
    local allowed, reason = HT.canActivate(player, monster)
    if not allowed then return false, reason end
    local kv, now = player:kv(), os.time()
    for i = 1, HT.maxActive do
        if (tonumber(kv:get(HT.storageExpires .. "-" .. i)) or 0) <= now then
            kv:set(HT.storageMonster .. "-" .. i, monster:lower())
            kv:set(HT.storageExpires .. "-" .. i, now + HT.duration)
            return true
        end
    end
    return false, "No available Hunting Ticket slot."
end

function HT.getMonsters()
    local names, seen = {}, {}
    local monsterTypes = Game.getMonsterTypes() or {}
    for key, monsterType in pairs(monsterTypes) do
        local name
        if type(key) == "string" then
            name = key
        elseif monsterType then
            name = monsterType:getName()
        end
        if type(name) == "string" and name ~= "" then
            local normalized = name:lower()
            if not seen[normalized] then
                seen[normalized] = true
                names[#names + 1] = name
            end
        end
    end
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

function HT.showList(player, page)
    local session = HT.sessions[player:getGuid()]
    if not session then return end
    local names = session.monsters or {}
    if #names == 0 then
        player:sendCancelMessage("No monsters found. Type !huntsearch followed by a name.")
        return
    end
    local maxPages = math.max(1, math.ceil(#names / HT.pageSize))
    page = math.max(1, math.min(tonumber(page) or 1, maxPages))
    session.page = page
    session.choices = {}
    local label = session.searchQuery and ("Search: " .. session.searchQuery .. "\n") or ""
    local modal = ModalWindow(HT.modalList, "Hunting Ticket - Monster Selection",
        "Choose a monster (+30% EXP for 60 minutes).\n" .. label ..
        "Page " .. page .. "/" .. maxPages .. " | " .. #names .. " monsters")
    local first = (page - 1) * HT.pageSize + 1
    local last = math.min(first + HT.pageSize - 1, #names)
    for i = first, last do
        local choiceId = i - first + 1
        modal:addChoice(choiceId, names[i])
        session.choices[choiceId] = names[i]
    end
    modal:addButton(1, "Select")
    modal:addButton(2, "Next")
    modal:addButton(3, "Previous")
    modal:addButton(4, "Cancel")
    modal:addButton(5, "Search")
    modal:setDefaultEnterButton(1)
    modal:setDefaultEscapeButton(4)
    modal:sendToPlayer(player)
end

function HT.showConfirmation(player)
    local session = HT.sessions[player:getGuid()]
    if not session or not session.selected then return end
    local modal = ModalWindow(HT.modalConfirm, "Confirm Hunting Ticket",
        "Selected monster: " .. session.selected ..
        "\nBonus: +30% EXP\nDuration: 60 minutes" ..
        "\n\nConsume one Hunting Ticket?")
    modal:addButton(1, "Activate")
    modal:addButton(2, "Back")
    modal:addButton(3, "Cancel")
    modal:setDefaultEnterButton(1)
    modal:setDefaultEscapeButton(3)
    modal:sendToPlayer(player)
end

local ticketAction = Action()
function ticketAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local allowed, reason = HT.canActivate(player)
    if not allowed then
        player:sendCancelMessage(reason)
        return true
    end
    local monsters = HT.getMonsters()
    if #monsters == 0 then
        player:sendCancelMessage("No monsters are registered on this server.")
        return true
    end
    HT.sessions[player:getGuid()] = {
        monsters = monsters,
        page = 1,
        choices = {},
        selected = nil,
        searchQuery = nil
    }
    player:registerEvent("HuntingTicketModal")
    HT.showList(player, 1)
    return true
end
ticketAction:id(HT.itemId)
ticketAction:register()

local modalEvent = CreatureEvent("HuntingTicketModal")
function modalEvent.onModalWindow(player, modalId, buttonId, choiceId)
    if modalId ~= HT.modalList and modalId ~= HT.modalConfirm then
        return true
    end
    local guid = player:getGuid()
    local session = HT.sessions[guid]
    if not session then return true end
    if modalId == HT.modalList then
        if buttonId == 5 then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
                "Type !huntsearch followed by a monster name (example: !huntsearch minotaur).")
            return true -- preserve the session for the TalkAction
        elseif buttonId == 4 or buttonId == 0 then
            HT.sessions[guid] = nil
            return true
        elseif buttonId == 2 then
            HT.showList(player, session.page + 1)
            return true
        elseif buttonId == 3 then
            HT.showList(player, session.page - 1)
            return true
        elseif buttonId == 1 then
            local selected = session.choices[choiceId]
            if not selected then
                player:sendCancelMessage("Select a monster from the list.")
                HT.showList(player, session.page)
                return true
            end
            session.selected = selected
            HT.showConfirmation(player)
            return true
        end
    elseif modalId == HT.modalConfirm then
        if buttonId == 3 or buttonId == 0 then
            HT.sessions[guid] = nil
            return true
        elseif buttonId == 2 then
            HT.showList(player, session.page)
            return true
        elseif buttonId == 1 then
            if not session.selected then
                HT.sessions[guid] = nil
                return true
            end
            local allowed, reason = HT.canActivate(player, session.selected)
            if not allowed then
                HT.sessions[guid] = nil
                player:sendCancelMessage(reason)
                return true
            end
            if not player:removeItem(HT.itemId, 1) then
                HT.sessions[guid] = nil
                player:sendCancelMessage("You need a Hunting Ticket in your inventory.")
                return true
            end
            local selected = session.selected:lower()
            local success, activationError = HT.activate(player, selected)
            if not success then
                -- Roll back item consumption when persistence fails unexpectedly.
                player:addItem(HT.itemId, 1)
                HT.sessions[guid] = nil
                player:sendCancelMessage(activationError or "Unable to activate ticket.")
                return true
            end
            HT.sessions[guid] = nil
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
                "Hunting Ticket activated! +" .. HT.bonus .. "% EXP from " ..
                session.selected .. " for 60 minutes.")
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
            return true
        end
    end
    HT.sessions[guid] = nil
    return true
end
modalEvent:register()

local logoutEvent = CreatureEvent("HuntingTicketLogout")
function logoutEvent.onLogout(player)
    HT.sessions[player:getGuid()] = nil
    return true
end
logoutEvent:register()

local loginEvent = CreatureEvent("HuntingTicketLogin")
function loginEvent.onLogin(player)
    HT.clearExpired(player)
    player:registerEvent("HuntingTicketLogout")
    local active = HT.getActives(player)
    for _, info in ipairs(active) do
        player:sendTextMessage(MESSAGE_STATUS_SMALL,
            "Hunting Ticket: +30% EXP from " .. info.monster .. ". " ..
            math.ceil((info.expires - os.time()) / 60) .. " minutes remaining.")
    end
    return true
end
loginEvent:register()
