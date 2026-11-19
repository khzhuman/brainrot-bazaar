-- One job: define every brainrot, rarity, mutation, and acquisition price in one shared catalog.
--!strict

export type CharacterDefinition = {
	id: string,
	name: string,
	rarity: string,
	price: number,
	moneyPerSecond: number,
	bodyColour: Color3,
	accessoryKind: string,
}

local Catalog = {}

Catalog.RarityOrder = table.freeze({ "Common", "Rare", "Epic", "Legendary", "Mythic" })
Catalog.RarityColours = table.freeze({
	Common = Color3.fromRGB(231, 241, 233),
	Rare = Color3.fromRGB(65, 188, 255),
	Epic = Color3.fromRGB(194, 119, 255),
	Legendary = Color3.fromRGB(255, 202, 59),
	Mythic = Color3.fromRGB(255, 92, 149),
})
Catalog.Mutations = table.freeze({
	Normal = table.freeze({ tag = "", multiplier = 1, probability = 0.865 }),
	Golden = table.freeze({ tag = "GOLDEN x5", multiplier = 5, probability = 0.10 }),
	Diamond = table.freeze({ tag = "DIAMOND x10", multiplier = 10, probability = 0.03 }),
	Void = table.freeze({ tag = "VOID x25", multiplier = 25, probability = 0.005 }),
})
Catalog.Characters = table.freeze({
	table.freeze({ id = "sir_bouncealot", name = "Sir Bouncealot", rarity = "Common", price = 50, moneyPerSecond = 2, bodyColour = Color3.fromRGB(247, 70, 77), accessoryKind = "spring_top_hat" }),
	table.freeze({ id = "banana_cabana", name = "Banana Cabana", rarity = "Common", price = 90, moneyPerSecond = 3, bodyColour = Color3.fromRGB(255, 220, 61), accessoryKind = "beach_umbrella" }),
	table.freeze({ id = "pigeon_accountant", name = "Pigeon Accountant", rarity = "Common", price = 150, moneyPerSecond = 4, bodyColour = Color3.fromRGB(146, 156, 171), accessoryKind = "visor_briefcase" }),
	table.freeze({ id = "capybara_cappuccino", name = "Capybara Cappuccino", rarity = "Rare", price = 600, moneyPerSecond = 9, bodyColour = Color3.fromRGB(171, 117, 74), accessoryKind = "coffee_cup" }),
	table.freeze({ id = "disco_cactus", name = "Disco Cactus", rarity = "Rare", price = 950, moneyPerSecond = 12, bodyColour = Color3.fromRGB(69, 181, 107), accessoryKind = "disco_ball" }),
	table.freeze({ id = "sneaker_shark", name = "Sneaker Shark", rarity = "Epic", price = 4000, moneyPerSecond = 30, bodyColour = Color3.fromRGB(61, 150, 229), accessoryKind = "sneakers" }),
	table.freeze({ id = "wizard_waffle", name = "Wizard Waffle", rarity = "Epic", price = 6500, moneyPerSecond = 42, bodyColour = Color3.fromRGB(218, 168, 95), accessoryKind = "wizard_hat" }),
	table.freeze({ id = "golden_goose_mogul", name = "Golden Goose Mogul", rarity = "Legendary", price = 25000, moneyPerSecond = 110, bodyColour = Color3.fromRGB(247, 187, 49), accessoryKind = "monocle_top_hat" }),
	table.freeze({ id = "astro_alpaca", name = "Astro Alpaca", rarity = "Legendary", price = 40000, moneyPerSecond = 150, bodyColour = Color3.fromRGB(249, 247, 237), accessoryKind = "space_helmet" }),
	table.freeze({ id = "dragon_of_dividends", name = "Dragon of Dividends", rarity = "Mythic", price = 150000, moneyPerSecond = 400, bodyColour = Color3.fromRGB(64, 168, 115), accessoryKind = "wings_coins" }),
	table.freeze({ id = "moonlight_mermanatee", name = "Moonlight Mermanatee", rarity = "Mythic", price = 250000, moneyPerSecond = 550, bodyColour = Color3.fromRGB(53, 173, 187), accessoryKind = "moon_crown" }),
	table.freeze({ id = "king_crab_capitalist", name = "KING CRAB CAPITALIST", rarity = "Mythic", price = 500000, moneyPerSecond = 900, bodyColour = Color3.fromRGB(236, 64, 62), accessoryKind = "crown_money_bag" }),
})
Catalog.PadMilestones = table.freeze({ 0, 0, 0, 0, 1000, 10000, 100000, 1000000 })
Catalog.EggTiers = table.freeze({
	table.freeze({ rarity = "Common", price = 75 }),
	table.freeze({ rarity = "Rare", price = 750 }),
	table.freeze({ rarity = "Epic", price = 5000 }),
	table.freeze({ rarity = "Legendary", price = 30000 }),
	table.freeze({ rarity = "Mythic", price = 200000 }),
})

function Catalog.GetCharacter(id: string): CharacterDefinition
	for _, definition in Catalog.Characters do
		if definition.id == id then
			return definition
		end
	end
	error("Unknown brainrot id: " .. id)
end

function Catalog.GetRarityIndex(rarity: string): number
	return table.find(Catalog.RarityOrder, rarity) or 1
end

function Catalog.GetCharactersInBand(rarity: string): { CharacterDefinition }
	local band = {}
	for _, definition in Catalog.Characters do
		if definition.rarity == rarity then
			table.insert(band, definition)
		end
	end
	return band
end

function Catalog.GetCharacterRate(id: string, mutation: string): number
	local mutationDefinition = Catalog.Mutations[mutation] or Catalog.Mutations.Normal
	return Catalog.GetCharacter(id).moneyPerSecond * mutationDefinition.multiplier
end

function Catalog.GetRebirthMultiplier(rebirths: number): number
	return 1.5 ^ rebirths
end

function Catalog.GetRebirthCost(rebirths: number): number
	return 10000 * 5 ^ rebirths
end

function Catalog.FormatMoney(amount: number): string
	local digits = tostring(math.floor(amount))
	local formatted = string.reverse(digits):gsub("(%d%d%d)", "%1,")
	return (string.reverse(formatted):gsub("^,", ""))
end

return table.freeze(Catalog)
