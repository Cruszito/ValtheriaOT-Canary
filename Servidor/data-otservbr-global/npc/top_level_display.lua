local displays = {
	"Top Level Display 1",
	"Top Level Display 2",
	"Top Level Display 3",
}

for _, internalNpcName in ipairs(displays) do
	local npcType = Game.createNpcType(internalNpcName)
	local npcConfig = {}

	npcConfig.name = internalNpcName
	npcConfig.description = internalNpcName

	npcConfig.health = 100
	npcConfig.maxHealth = 100
	npcConfig.walkInterval = 0
	npcConfig.walkRadius = 0

	npcConfig.outfit = {
		lookType = 128,
		lookHead = 78,
		lookBody = 106,
		lookLegs = 58,
		lookFeet = 76,
		lookAddons = 3,
	}

	npcConfig.flags = {
		floorchange = false,
	}

	npcType:register(npcConfig)
end