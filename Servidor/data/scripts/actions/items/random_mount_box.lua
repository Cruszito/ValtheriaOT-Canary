local mounts = {
	{ id = 237, name = "Celestial Lynx" },
	{ id = 238, name = "Astral Warbeast" },
	{ id = 239, name = "Emberbone Scorpion" },
	{ id = 240, name = "Bloodbound Charger" },
	{ id = 241, name = "Abyssal Stalker" },
	{ id = 242, name = "Crimson Crawler" },
	{ id = 243, name = "Infernal Scorpion" },
	{ id = 244, name = "Blightwood Ravager" },
	{ id = 245, name = "Dreadmane" },
	{ id = 246, name = "Frostbone Scorpion" },
	{ id = 247, name = "Venomsteel Scorpion" },
	{ id = 248, name = "Cinder Wraith" },
}

local randomMountBox = Action()

function randomMountBox.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local availableMounts = {}

	for _, mount in ipairs(mounts) do
		if not player:hasMount(mount.id) then
			availableMounts[#availableMounts + 1] = mount
		end
	end

	if #availableMounts == 0 then
		player:sendCancelMessage("You already own all the mounts from this box.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local selectedMount = availableMounts[math.random(#availableMounts)]
	player:addMount(selectedMount.id)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You received the " .. selectedMount.name .. " mount!")
	player:say("You received the " .. selectedMount.name .. " mount!", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	item:remove(1)
	return true
end

randomMountBox:id(55725)
randomMountBox:register()