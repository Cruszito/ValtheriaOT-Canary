local config = {
	interval = 5 * 1000, -- cada 10 segundos
	effect = CONST_ME_EXPLOSIONAREA,

	teleports = {
		{
			position = Position(32373, 32236, 7),
			text = "ROULETTE!"
		},
		{
			position = Position(32353, 32227, 7),
			text = "ENDLESS VIP CASINO!"
		},
		{
			position = Position(32365, 32232, 7),
			text = "TRAINING ZONE!"
		},
		{
			position = Position(32341, 32237, 7),
			text = "BOSS CHALLENGE!"
		},
		{
			position = Position(32354, 32219, 7),
			text = "ZONA DE HUNT I!"
		},
		{
			position = Position(32364, 32235, 7),
			text = "ZONA DE HUNT I!"
		},
		{
			position = Position(32356, 32219, 7),
			text = "ZONA DE HUNT II!"
		},
		{
			position = Position(32364, 32237, 7),
			text = "ZONA DE HUNT II!"
		},
		{
			position = Position(32389, 31998, 5),
			text = "TEMPLE EXIT!"
		},
		{
			position = Position(32114, 32338, 7),
			text = "DEATH ROULETTE!"
		},
		{
			position = Position(32364, 32239, 7),
			text = "RAID ZONE!"
		},
		{
			position = Position(32341, 32235, 7),
			text = "RAID ZONE!"
		},
		{
			position = Position(32358, 32219, 7),
			text = "FIENDISH ARENA!"
		},
		{
			position = Position(32341, 32233, 7),
			text = "TOWER QUEST"
		},
	}
}

local function sendTeleportText(position, text)
	-- Muestra la flecha sobre el teleport.
	position:sendMagicEffect(config.effect)

	-- Busca únicamente jugadores cercanos.
	local spectators = Game.getSpectators(
		position,
		false,
		true,
		8,
		8,
		6,
		6
	)

	for _, player in ipairs(spectators) do
		-- El texto se envía individualmente para evitar duplicados.
		player:say(
			text,
			TALKTYPE_MONSTER_SAY,
			false,
			player,
			position
		)
	end
end

local teleportTexts = GlobalEvent("TeleportTexts")

function teleportTexts.onThink(interval)
	for _, teleport in ipairs(config.teleports) do
		sendTeleportText(teleport.position, teleport.text)
	end

	return true
end

teleportTexts:interval(config.interval)
teleportTexts:register()