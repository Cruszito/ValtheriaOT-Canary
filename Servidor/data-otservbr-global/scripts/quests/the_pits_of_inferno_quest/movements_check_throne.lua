local barriers = {
	{
		name = "poi.barrier.infernatil",
		position = Position(32824, 32230, 12),
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThroneInfernatil,
		value = 1,
		throne = "Infernatil",
	},
	{
		name = "poi.barrier.tafariel",
		position = Position(32824, 32229, 12),
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThroneTafariel,
		value = 1,
		throne = "Tafariel",
	},
	{
		name = "poi.barrier.verminor",
		position = Position(32824, 32228, 12),
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThroneVerminor,
		value = 1,
		throne = "Verminor",
	},
	{
		name = "poi.barrier.apocalypse",
		position = Position(32824, 32227, 12),
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThroneApocalypse,
		value = 1,
		throne = "Apocalypse",
	},
	{
		name = "poi.barrier.bazir",
		position = Position(32824, 32226, 12),
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThroneBazir,
		value = 1,
		throne = "Bazir",
	},
	{
		name = "poi.barrier.ashfalor",
		position = Position(32824, 32225, 12),
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThroneAshfalor,
		value = 1,
		throne = "Ashfalor",
	},
	{
		name = "poi.barrier.pumin",
		position = Position(32824, 32224, 12),
		storage = Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin,
		value = 10,
		throne = "Pumin",
	},
}

local requirementsByZoneName = {}
local messageCooldown = {}

for _, barrier in ipairs(barriers) do
	local zone = Zone(barrier.name)
	zone:addArea(barrier.position, barrier.position)
	requirementsByZoneName[barrier.name] = barrier
end

local callback = EventCallback("PoIThroneBarrierAccess")

function callback.zoneBeforeCreatureEnter(zone, creature)
	local requirement = requirementsByZoneName[zone:getName()]
	if not requirement then
		return true
	end

	local player = creature:getPlayer()
	if not player then
		return true
	end

	local storageValue = player:getStorageValue(requirement.storage)

	-- Se usa >= para aceptar storages que ya hayan avanzado
	-- más allá del valor mínimo requerido.
	if storageValue >= requirement.value then
		return true
	end

	local cooldownKey = player:getId() .. ":" .. requirement.name
	local currentTime = os.time()

	if (messageCooldown[cooldownKey] or 0) <= currentTime then
		player:say(
			"You've not absorbed energy from " .. requirement.throne .. "'s throne.",
			TALKTYPE_MONSTER_SAY
		)
		messageCooldown[cooldownKey] = currentTime + 2
	end

	-- Cancela el paso antes de entrar. No realiza ningún teleport.
	return false
end

callback:register()