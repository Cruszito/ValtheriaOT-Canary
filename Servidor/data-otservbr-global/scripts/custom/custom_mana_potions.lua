local potions = {
	[55765] = {
		minLevel = 100,
		manaMin = 240,
		manaMax = 360,
		vocations = {
			["paladin"] = true,
			["royal paladin"] = true,
			["monk"] = true,
			["exalted monk"] = true,
			["sorcerer"] = true,
			["master sorcerer"] = true,
			["druid"] = true,
			["elder druid"] = true,
		},
	},

	[55768] = {
		minLevel = 130,
		manaMin = 240,
		manaMax = 360,
		vocations = nil, -- Todas las vocaciones
	},

	[55049] = {
		minLevel = 200,
		manaMin = 425,
		manaMax = 575,
		vocations = nil, -- Todas las vocaciones
	},
}

local customManaPotions = Action()

function customManaPotions.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local potion = potions[item:getId()]
	if not potion then
		return false
	end

	-- Validación de nivel
	if player:getLevel() < potion.minLevel then
		player:sendCancelMessage(
			string.format(
				"Only players of level %d or higher may drink this potion.",
				potion.minLevel
			)
		)
		return true
	end

	-- Validación de vocación
	if potion.vocations then
		local vocationName = player:getVocation():getName():lower()

		if not potion.vocations[vocationName] then
			player:sendCancelMessage(
				"Your vocation cannot use this potion."
			)
			return true
		end
	end

	-- Permitir usarla sobre uno mismo o sobre otro jugador
	local targetPlayer = player

	if target and target:isPlayer() then
		targetPlayer = target
	end

	local manaAmount = math.random(
		potion.manaMin,
		potion.manaMax
	)

    targetPlayer:addMana(manaAmount)

    targetPlayer:say("Aaaah...", TALKTYPE_MONSTER_SAY)

    targetPlayer:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)

    item:remove(1)
    return true
end

customManaPotions:id(55765, 55768, 55049)
customManaPotions:register()