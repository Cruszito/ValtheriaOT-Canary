local PORTAL_ITEM_ID = 1949
local PORTAL_DURATION = 60 * 1000

local bossPortals = {
	["azhurak the infernal"] = {
		portalPosition = Position(32193, 32165, 15),
		destination = Position(32326, 32164, 14),
	},
	["arkhazul the devourer"] = {
		portalPosition = Position(32277, 32329, 15),
		destination = Position(32286, 32225, 12),
	},
	["azrathor the tormentor"] = {
		portalPosition = Position(32194, 32193, 15),
		destination = Position(32166, 32173, 15),
	},
	["akhzeron the blighted"] = {
		portalPosition = Position(32118, 32383, 15),
		destination = Position(31819, 32224, 15),
	},
	["amonkar the undying"] = {
		portalPosition = Position(32192, 32140, 15),
		destination = Position(32196, 32366, 15),
	},
	["arkanith the ruinous"] = {
		portalPosition = Position(31774, 32288, 15),
		destination = Position(31899, 32289, 14),
	},
}

local function removeTeleport(position)
	local tile = Tile(position)
	if not tile then
		return
	end

	local teleport = tile:getItemById(PORTAL_ITEM_ID)
	if teleport then
		teleport:remove()
		position:sendMagicEffect(CONST_ME_POFF)
	end
end

local bossDeathTeleport = CreatureEvent("CustomQuestBossDeathTeleport")

function bossDeathTeleport.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	local monster = creature:getMonster()
	if not monster then
		return true
	end

	local config = bossPortals[creature:getName():lower()]
	if not config then
		return true
	end

	-- Evita dejar dos portales sobre la misma posicion.
	local tile = Tile(config.portalPosition)
	if tile then
		local oldTeleport = tile:getItemById(PORTAL_ITEM_ID)
		if oldTeleport then
			oldTeleport:remove()
		end
	end

	local teleport = Game.createItem(PORTAL_ITEM_ID, 1, config.portalPosition)
	if not teleport then
		return true
	end

	if not teleport:isTeleport() then
		teleport:remove()
		return true
	end

	teleport:setDestination(config.destination)
	config.portalPosition:sendMagicEffect(CONST_ME_TELEPORT)

	creature:say(
		"The portal will disappear in 60 seconds!",
		TALKTYPE_MONSTER_SAY,
		0,
		0,
		config.portalPosition
	)

	addEvent(removeTeleport, PORTAL_DURATION, config.portalPosition)
	return true
end

bossDeathTeleport:register()
