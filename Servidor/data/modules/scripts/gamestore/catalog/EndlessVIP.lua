return {
	icons = { "Category_Items.png" },
	name = "EndlessVIP",
	rookgaard = true,
	state = GameStore.States.STATE_NONE,

		offers = {

		-- ==========================================
		-- ELEMENTAL RINGS
		-- Physical Protection: +10%
		-- Elemental Protection: +10%
		-- Price: 150 Tibia Coins
		-- ==========================================

		{
			icons = { "fire_kindle_ring.png" },
			name = "Fire Kindle Ring",
			price = 150,
			itemtype = 55675,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>Physical Protection +10%\nFire Protection +10%\nMagic Level +1\n\nA powerful ring infused with fire energy. Permanent equipment.</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},
		{
			icons = { "ice_ring.png" },
			name = "Ice Ring",
			price = 150,
			itemtype = 55676,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>Physical Protection +10%\nIce Protection +10%\nMax Mana +50\n\nA magical ring forged with frozen energy. Permanent equipment.</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},
		{
			icons = { "holy_halo_ring.png" },
			name = "Holy Halo Ring",
			price = 150,
			itemtype = 55677,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>Physical Protection +10%\nHoly Protection +10%\nShielding +2\n\nA sacred ring blessed with divine protection. Permanent equipment.</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},
		{
			icons = { "energy_ring.png" },
			name = "Energy Ring",
			price = 150,
			itemtype = 55678,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>Physical Protection +10%\nEnergy Protection +10%\nSpeed +10\n\nA charged ring that enhances movement and resistance. Permanent equipment.</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},
		{
			icons = { "earth_ring.png" },
			name = "Earth Ring",
			price = 150,
			itemtype = 55679,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>Physical Protection +10%\nEarth Protection +10%\nMax Health +50\n\nA ring empowered by the strength of nature. Permanent equipment.</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},
		{
			icons = { "death_ring.png" },
			name = "Death Ring",
			price = 150,
			itemtype = 55680,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>Physical Protection +10%\nDeath Protection +10%\nMagic Level +1\n\nA mysterious ring imbued with dark magic. Permanent equipment.</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},

		-- ==========================================
		-- ELEMENTAL AMULETS
		-- Physical Protection: +10%
		-- Elemental Protection: +10%
		-- Price: 200 Tibia Coins
		-- ==========================================

		{
			icons = { "death_amulet.png" },
			name = "Death Amulet",
			price = 200,
			itemtype = 55681,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>Physical Protection +10%\nDeath Protection +10%\nMax Mana +75\n\nAn ancient amulet that protects against dark forces. Permanent equipment.</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},
		{
			icons = { "earth_amulet.png" },
			name = "Earth Amulet",
			price = 200,
			itemtype = 55682,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>Physical Protection +10%\nEarth Protection +10%\nMax Health +80\n\nAn enchanted amulet blessed by nature. Permanent equipment.</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},
		{
			icons = { "energy_amulet.png" },
			name = "Energy Amulet",
			price = 200,
			itemtype = 55683,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>Physical Protection +10%\nEnergy Protection +10%\nSpeed +15\n\nAn amulet charged with powerful electrical energy. Permanent equipment.</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},
		{
			icons = { "fire_amulet.png" },
			name = "Fire Amulet",
			price = 200,
			itemtype = 55684,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>Physical Protection +10%\nFire Protection +10%\nMagic Level +2\n\nAn enchanted amulet forged in ancient flames. Permanent equipment.</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},
		{
			icons = { "holy_amulet.png" },
			name = "Holy Amulet",
			price = 200,
			itemtype = 55685,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>Physical Protection +10%\nHoly Protection +10%\nShielding +3\n\nA sacred amulet offering divine protection. Permanent equipment.</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},

		{
			icons = { "hunting_ticket.png" },
			name = "Hunting Ticket",
			price = 300,
			itemtype = 55045,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>Choose any monster and gain +30% bonus experience when killing it for 1 hour!\n\nOnly one Hunting Ticket can be active at a time.\n\nThe ticket is consumed upon activation. Your bonus remains active even after logout.</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},

		
		{
			icons = { "endless_boots.png" },
			name = "Endless Boots",
			price = 500,
			itemtype = 55015,
			count = 1,
			movable = true,
			setOwner = false,
			description = "{character}\n{storeinbox}\n\n<i>PERMANENT BOOTS - UNLIMITED DURATION!\n\nMana Regeneration: +15 every 6 seconds.\nHealth Regeneration: +5 every 6 seconds.\nDuration: Permanent (Never Expires).\n\nPowerful enchanted boots that provide continuous health and mana regeneration. No charges, no expiration, and no need to recharge!</i>",
			type = GameStore.OfferTypes.OFFER_TYPE_ITEM,
		},

	},


}