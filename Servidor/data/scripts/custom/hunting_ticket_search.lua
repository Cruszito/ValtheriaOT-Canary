-- Hunting Ticket search: supports three simultaneously active monsters.
local huntSearch = TalkAction("!huntsearch")

function huntSearch.onSay(player, words, param)
    local HT = HuntingTicket
    if not HT or type(HT.sessions) ~= "table" or
       type(HT.getMonsters) ~= "function" or
       type(HT.showList) ~= "function" or
       type(HT.canActivate) ~= "function" then
        player:sendCancelMessage("Hunting Ticket system is not available.")
        return false
    end

    local session = HT.sessions[player:getGuid()]
    if not session then
        player:sendCancelMessage("Use a Hunting Ticket first.")
        return false
    end
    local allowed, reason = HT.canActivate(player)
    if not allowed then
        HT.sessions[player:getGuid()] = nil
        player:sendCancelMessage(reason)
        return false
    end

    local query = tostring(param or ""):lower():match("^%s*(.-)%s*$")
    if query == "" or #query > 50 then
        player:sendCancelMessage("Usage: !huntsearch monster name (max 50 chars).")
        return false
    end

    local results = {}
    for _, name in ipairs(HT.getMonsters()) do
        if name:lower():find(query, 1, true) then
            results[#results + 1] = name
        end
    end
    if #results == 0 then
        player:sendCancelMessage("No monsters found matching: " .. query)
        return false
    end

    table.sort(results, function(a, b) return a:lower() < b:lower() end)
    session.monsters = results
    session.searchQuery = query
    session.page = 1
    session.selected = nil
    session.choices = {}
    player:registerEvent("HuntingTicketModal")
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        "Found " .. #results .. " monsters matching '" .. query .. "'.")
    HT.showList(player, 1)
    return false
end

huntSearch:separator(" ")
huntSearch:groupType("normal")
huntSearch:register()
