local ITEM_ID = 56248 -- Server ID de Froststorm Arrow

local area = createCombatArea({
	{ 0, 0, 1, 0, 0 },
	{ 0, 1, 1, 1, 0 },
	{ 1, 1, 3, 1, 1 },
	{ 0, 1, 1, 1, 0 },
	{ 0, 0, 1, 0, 0 },
})

local combat = Combat()

-- Mantiene el daño de hielo.
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)

-- Mantiene el efecto de hielo cuando impacta.
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICEAREA)

-- Usa únicamente el proyectil visual de Shatterstorm/Diamond Arrow.
combat:setParameter(
	COMBAT_PARAM_DISTANCEEFFECT,
	CONST_ANI_DIAMONDARROW
)

combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
combat:setFormula(COMBAT_FORMULA_SKILL, 0, 0, 1, 0)
combat:setArea(area)

local froststormArrow = Weapon(WEAPON_AMMO)

function froststormArrow.onUseWeapon(player, variant)
	if player:getSkull() == SKULL_BLACK then
		return false
	end

	local targetId = variant:getNumber()
	local target = Creature(targetId)

	if not target then
		return false
	end

	return combat:execute(
		player,
		Variant(target:getPosition())
	)
end

froststormArrow:id(ITEM_ID)
froststormArrow:attack(35)
froststormArrow:level(125)
froststormArrow:action("removecount")
froststormArrow:ammoType("arrow")

-- Mismo proyectil a distancia que Shatterstorm Arrow.
froststormArrow:shootType(CONST_ANI_DIAMONDARROW)

froststormArrow:maxHitChance(91)
froststormArrow:register()