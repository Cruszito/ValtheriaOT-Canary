local ITEM_ID = 56247 -- Server ID de Terrastorm Arrow

local area = createCombatArea({
	{ 0, 0, 1, 0, 0 },
	{ 0, 1, 1, 1, 0 },
	{ 1, 1, 3, 1, 1 },
	{ 0, 1, 1, 1, 0 },
	{ 0, 0, 1, 0, 0 },
})

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_CARNIPHILA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_EARTHARROW)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
combat:setFormula(COMBAT_FORMULA_SKILL, 0, 0, 1, 0)
combat:setArea(area)

local terrastormArrow = Weapon(WEAPON_AMMO)

terrastormArrow.onUseWeapon = function(player, variant)
	if player:getSkull() == SKULL_BLACK then
		return false
	end

	return combat:execute(player, variant)
end

terrastormArrow:id(ITEM_ID)
terrastormArrow:attack(35)
terrastormArrow:level(125)
terrastormArrow:action("removecount")
terrastormArrow:ammoType("arrow")
terrastormArrow:shootType(CONST_ANI_EARTHARROW)
terrastormArrow:maxHitChance(91)
terrastormArrow:register()