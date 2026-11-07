local config = {
	[55364] = { -- Lion box
		34253, -- lion axe
		34254, -- lion hammer
		50162, -- lion claws
		34151, -- lion rod
		34150, -- lion longbow
		34152, -- lion wand
		34153, -- lion spellbook
		34154, -- lion shield
		34157, -- lion plate
		34158, -- lion amulet
	},
	[55737] = { -- Stag Box
		52353, -- stag boots
		52354, -- stag footwraps
		52348, -- stag helmet
		52351, -- stag legs
		52350, -- stag plate
		52349, -- stag robe
		52356, -- stag scrolls
		52357, -- stag shield
		52352, -- stag shinguards
		52355, -- stag spellbook
	},
	[55894] = { -- Primal box
		39149, -- alicorn headguard
		39150, -- alicorn quiver
		39182, -- alicorn ring
		39153, -- arboreal crown
		39188, -- arboreal ring
		39154, -- arboreal tome
		39152, -- arcanomancer folio
		39151, -- arcanomancer regalia
		39185, -- arcanomancer sigil
		39147, -- spiritthorn armor
		39148, -- spiritthorn helmet
		39179, -- spiritthorn ring
	},
	[55608] = { -- Grand Sanguine Box
		43875, -- grand sanguine battleaxe
		43865, -- grand sanguine blade
		43873, -- grand sanguine bludgeon
		43878, -- grand sanguine bow
		50158, -- grand sanguine claws
		43883, -- grand sanguine coil
		43880, -- grand sanguine crossbow
		43867, -- grand sanguine cudgel
		43869, -- grand sanguine hatchet
		43871, -- grand sanguine razor
		43886, -- grand sanguine rod
	},
	[55609] = { -- Sanguine Box
		43874, -- sanguine battleaxe
		43864, -- sanguine blade
		43872, -- sanguine bludgeon
		43884, -- sanguine boots
		43877, -- sanguine bow
		50157, -- sanguine claws
		43882, -- sanguine coil
		43879, -- sanguine crossbow
		43866, -- sanguine cudgel
		43887, -- sanguine galoshes
		43881, -- sanguine greaves
		43868, -- sanguine hatchet
		43876, -- sanguine legs
		43870, -- sanguine razor
		43885, -- sanguine rod
		50146, -- sanguine trousers
	},
	[55171] = { -- Cobra Box
		30396, -- cobra axe
		50167, -- cobra bo
		30394, -- cobra boots
		30395, -- cobra club
		30393, -- cobra crossbow
		30397, -- cobra hood
		30400, -- cobra rod
		30398, -- cobra sword
		30399, -- cobra wand
		31631, -- cobra amulet
	},
	[55270] = { -- Timira the Many-Headed Box
		39158, -- frostflower boots
		39233, -- enchanted turtle amulet
		39164, -- dawnfire sherwani
		39159, -- naga crossbow
		39161, -- feverbloom boots
		39157, -- naga club
		39165, -- midnight tunic
		39166, -- dawnfire pantaloons
		39167, -- midnight sarong
		39160, -- naga quiver
		39163, -- naga rod
		39155, -- naga sword
		39162, -- naga wand
		39156, -- naga axe
		50160, -- naga katar
		50262, -- naga tanko
	},
	[55388] = { -- Falcon Box
		28724, -- falcon battleaxe
		28718, -- falcon bow
		28714, -- falcon circlet
		28715, -- falcon coif
		28722, -- falcon escutcheon
		28720, -- falcon greaves
		28723, -- falcon longsword
		28725, -- falcon mace
		28719, -- falcon plate
		28716, -- falcon rod
		50161, -- falcon sai
		28721, -- falcon shield
		28717, -- falcon wand
	},
	[55609] = { -- Soulwar Box
		34098, -- pair of soulstalkers
		34097, -- pair of soulwalkers
		34099, -- soulbastion
		34084, -- soulbiter
		34088, -- soulbleeder
		34086, -- soulcrusher
		34082, -- soulcutter
		34085, -- souleater
		50254, -- soulgarb
		34091, -- soulhexer
		50159, -- soulkamas
		34087, -- soulmaimer
		34095, -- soulmantle
		34089, -- soulpiercer
		34092, -- soulshanks
		34094, -- soulshell
		34083, -- soulshredder
		34096, -- soulshroud
		50240, -- soulsoles
		34093, -- soulstrider
		34090, -- soultainter
	},
	[37614] = { -- box full of decoration
		37463,
		37466,
		37496,
		37717,
	},
}

local specialBox = Action()

function specialBox.onUse(player, item, fromPosition, itemEx, toPosition)
	local box = config[item.itemid]
	if not box or not player then
		return false
	end
	local gift = box[math.random(1, #box)]
	for index, value in pairs(config) do
		Item(item.uid):remove(1)
		if fromPosition.x == CONTAINER_POSITION then
			player:getPosition():sendMagicEffect(CONST_ME_PRISMATIC_SPARK)
			player:addItem(gift)
		else
			fromPosition:sendMagicEffect(CONST_ME_PRISMATIC_SPARK)
			fromPosition:getTile():addItem(gift)
		end
		return true
	end
end

for index, value in pairs(config) do
	specialBox:id(index)
end
specialBox:register()
