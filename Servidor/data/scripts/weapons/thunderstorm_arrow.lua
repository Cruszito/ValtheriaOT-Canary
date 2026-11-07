local ITEM_ID = 56249 -- Server ID de Thunderstorm Arrow

local area = createCombatArea({
	{ 0, 0, 1, 0, 0 },
	{ 0, 1, 1, 1, 0 },
	{ 1, 1, 3, 1, 1 },
	{ 0, 1, 1, 1, 0 },
	{ 0, 0, 1, 0, 0 },
})

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FLASHARROW)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
combat:setFormula(COMBAT_FORMULA_SKILL, 0, 0, 1, 0)
combat:setArea(area)

local thunderstormArrow = Weapon(WEAPON_AMMO)

thunderstormArrow.onUseWeapon = function(player, variant)
	if player:getSkull() == SKULL_BLACK then
		return false
	end

	return combat:execute(player, variant)
end

thunderstormArrow:id(ITEM_ID)
thunderstormArrow:attack(35)
thunderstormArrow:level(125)
thunderstormArrow:action("removecount")
thunderstormArrow:ammoType("arrow")
thunderstormArrow:shootType(CONST_ANI_FLASHARROW)
thunderstormArrow:maxHitChance(91)
thunderstormArrow:register()