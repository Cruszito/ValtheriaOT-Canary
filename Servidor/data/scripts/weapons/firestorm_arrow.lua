local ITEM_ID = 56246 -- Server ID de Firestorm Arrow

local area = createCombatArea({
	{ 0, 0, 1, 0, 0 },
	{ 0, 1, 1, 1, 0 },
	{ 1, 1, 3, 1, 1 },
	{ 0, 1, 1, 1, 0 },
	{ 0, 0, 1, 0, 0 },
})

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FLAMMINGARROW)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
combat:setFormula(COMBAT_FORMULA_SKILL, 0, 0, 1, 0)
combat:setArea(area)

local firestormArrow = Weapon(WEAPON_AMMO)

firestormArrow.onUseWeapon = function(player, variant)
	if player:getSkull() == SKULL_BLACK then
		return false
	end

	return combat:execute(player, variant)
end

firestormArrow:id(ITEM_ID)
firestormArrow:attack(35)
firestormArrow:level(125)
firestormArrow:action("removecount")
firestormArrow:ammoType("arrow")
firestormArrow:shootType(CONST_ANI_FLAMMINGARROW)
firestormArrow:maxHitChance(91)
firestormArrow:register()