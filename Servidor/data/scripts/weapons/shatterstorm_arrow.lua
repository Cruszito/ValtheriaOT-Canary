local ITEM_ID = 56245 -- Server ID de Shatterstorm Arrow

-- Misma área de impacto que Diamond Arrow.
local area = createCombatArea({
	{ 0, 0, 1, 0, 0 },
	{ 0, 1, 1, 1, 0 },
	{ 1, 1, 3, 1, 1 },
	{ 0, 1, 1, 1, 0 },
	{ 0, 0, 1, 0, 0 },
})

local combat = Combat()

combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)

-- Mismo efecto visual de impacto que Diamond Arrow.
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYHIT)

-- Mismo proyectil que Diamond Arrow.
combat:setParameter(
	COMBAT_PARAM_DISTANCEEFFECT,
	CONST_ANI_DIAMONDARROW
)

-- Mismos sonidos que Diamond Arrow.
combat:setParameter(
	COMBAT_PARAM_IMPACTSOUND,
	SOUND_EFFECT_TYPE_DIAMOND_ARROW_EFFECT
)

combat:setParameter(
	COMBAT_PARAM_CASTSOUND,
	SOUND_EFFECT_TYPE_DIST_ATK_BOW
)

combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)

-- Mantiene tu fórmula actual de daño.
combat:setFormula(COMBAT_FORMULA_SKILL, 0, 0, 1, 0)

combat:setArea(area)

local shatterstormArrow = Weapon(WEAPON_AMMO)

function shatterstormArrow.onUseWeapon(player, variant)
	if player:getSkull() == SKULL_BLACK then
		return false
	end

	return combat:execute(player, variant)
end

shatterstormArrow:id(ITEM_ID)
shatterstormArrow:attack(35)
shatterstormArrow:level(125)
shatterstormArrow:action("removecount")
shatterstormArrow:ammoType("arrow")

-- Debe estar completamente en mayúsculas.
shatterstormArrow:shootType(CONST_ANI_DIAMONDARROW)

shatterstormArrow:maxHitChance(91)
shatterstormArrow:register()