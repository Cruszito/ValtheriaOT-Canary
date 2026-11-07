local SELLER_ITEM_ID = 55111 -- Loot Seller / bag of oriental spices
local LOOT_POUCH_ID = 23721 -- loot pouch

-- El script toma precios de venta desde estos NPCs.
-- Agrega aquí más NPCs si quieres que el Loot Seller venda más items.
local SELL_PRICE_FILES = {
	"data-otservbr-global/npc/yasir.lua",
	"data-otservbr-global/npc/rashid.lua",
	"data-otservbr-global/npc/maria.lua",
	"data-otservbr-global/npc/rashid_custom.lua",
}

-- Precios manuales opcionales.
-- Úsalo si algún item no se vende aunque exista en tu servidor.
-- Formato: [clientId] = precio,
local EXTRA_SELL_PRICES = {
	-- [5954] = 1000, -- demon horn, ejemplo
}

local BLOCKED_SELL_ITEMS = {
	[LOOT_POUCH_ID] = true,
	[SELLER_ITEM_ID] = true,
}

local loadedSellPrices = nil

local function formatGold(amount)
	if FormatNumber then
		return FormatNumber(amount)
	end

	return tostring(amount)
end

local function loadSellPrices()
	if loadedSellPrices then
		return loadedSellPrices
	end

	loadedSellPrices = {}

	-- Carga primero los precios manuales.
	for itemId, price in pairs(EXTRA_SELL_PRICES) do
		if itemId and price and price > 0 then
			loadedSellPrices[itemId] = price
		end
	end

	if not io or not io.open then
		print("[Loot Seller] io.open no está disponible. Solo se usarán precios manuales.")
		return loadedSellPrices
	end

	for _, filePath in ipairs(SELL_PRICE_FILES) do
		local file = io.open(filePath, "r")

		if file then
			local content = file:read("*a")
			file:close()

			-- Lee línea por línea para evitar que la tabla completa
			-- npcConfig.shop rompa el parser.
			--
			-- Formato esperado:
			-- { itemName = "demon horn", clientId = 5954, sell = 1000 },
			for line in content:gmatch("[^\r\n]+") do
				if line:find("clientId") and line:find("sell") then
					local clientId = tonumber(line:match("clientId%s*=%s*(%d+)"))
					local sellPrice = tonumber(line:match("sell%s*=%s*(%d+)"))

					if clientId and sellPrice and sellPrice > 0 then
						local currentPrice = loadedSellPrices[clientId] or 0

						-- Conserva el precio más alto cuando el mismo
						-- objeto aparece en varios NPCs.
						if sellPrice > currentPrice then
							loadedSellPrices[clientId] = sellPrice
						end
					end
				end
			end

			-- Log informativo desactivado:
			-- print("[Loot Seller] Loaded prices from: " .. filePath)
		else
			-- Este log se conserva porque indica un problema real.
			print("[Loot Seller] No se pudo abrir: " .. filePath)
		end
	end

	-- Log informativo desactivado:
	-- print("[Loot Seller] Total sell prices loaded: " .. countTable(loadedSellPrices))

	return loadedSellPrices
end

local function getSellPriceForItem(item, sellPrices)
	if not item then
		return nil
	end

	local itemId = item:getId()

	if BLOCKED_SELL_ITEMS[itemId] then
		return nil
	end

	-- Primero intenta encontrar el precio usando el ID interno.
	local sellPrice = sellPrices[itemId]

	if sellPrice and sellPrice > 0 then
		return sellPrice
	end

	-- Si no existe, intenta encontrarlo usando el clientId.
	local itemType = ItemType(itemId)

	if itemType and itemType.getClientId then
		local clientId = itemType:getClientId()

		if clientId and not BLOCKED_SELL_ITEMS[clientId] then
			sellPrice = sellPrices[clientId]

			if sellPrice and sellPrice > 0 then
				return sellPrice
			end
		end
	end

	return nil
end

local function sellContainerLoot(player, container, sellPrices, result)
	if not container then
		return
	end

	-- Recorre en reversa porque los objetos se eliminan durante el proceso.
	for i = container:getSize() - 1, 0, -1 do
		local lootItem = container:getItem(i)

		if lootItem then
			if lootItem:isContainer() then
				-- Revisa también backpacks y bags dentro de la loot pouch.
				sellContainerLoot(
					player,
					Container(lootItem.uid),
					sellPrices,
					result
				)
			else
				local itemId = lootItem:getId()

				if not BLOCKED_SELL_ITEMS[itemId] then
					local sellPrice = getSellPriceForItem(lootItem, sellPrices)

					if sellPrice and sellPrice > 0 then
						-- Protección: no vende items con actionId.
						-- Esto evita vender accidentalmente objetos
						-- especiales o de quest.
						local actionId = lootItem:getActionId()

						if actionId and actionId > 0 then
							result.skipped = result.skipped + 1
						else
							local itemType = ItemType(itemId)
							local count = 1

							if itemType and itemType:isStackable() then
								count = lootItem:getCount()
							end

							if count < 1 then
								count = 1
							end

							local total = sellPrice * count

							lootItem:remove(count)

							result.items = result.items + count
							result.gold = result.gold + total
						end
					end
				end
			end
		end
	end
end

local orientalSpicesSellLoot = Action()

function orientalSpicesSellLoot.onUse(
	player,
	item,
	fromPosition,
	target,
	toPosition,
	isHotkey
)
	local lootPouchItem = player:getItemById(LOOT_POUCH_ID, true)

	if not lootPouchItem then
		player:sendCancelMessage(
			"You need to have a loot pouch to sell your loot."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	if not lootPouchItem:isContainer() then
		player:sendCancelMessage(
			"Your loot pouch is not a valid container."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local sellPrices = loadSellPrices()

	if not sellPrices or not next(sellPrices) then
		player:sendCancelMessage(
			"No sell prices were loaded. Check the NPC shop files configured in the script."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local result = {
		items = 0,
		gold = 0,
		skipped = 0,
	}

	sellContainerLoot(
		player,
		Container(lootPouchItem.uid),
		sellPrices,
		result
	)

	if result.gold <= 0 then
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			"There are no sellable loot items in your loot pouch."
		)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	-- Se deposita directo al banco para evitar problemas de
	-- capacidad o espacios disponibles al entregar muchas monedas.
	player:setBankBalance(
		player:getBankBalance() + result.gold
	)

	local message = string.format(
		"Sold %d loot item%s from your loot pouch for %s gold. The money has been deposited into your bank account.",
		result.items,
		result.items == 1 and "" or "s",
		formatGold(result.gold)
	)

	if result.skipped > 0 then
		message = message .. string.format(
			" %d special item%s were skipped.",
			result.skipped,
			result.skipped == 1 and "" or "s"
		)
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)

	return true
end

orientalSpicesSellLoot:id(SELLER_ITEM_ID)
orientalSpicesSellLoot:register()