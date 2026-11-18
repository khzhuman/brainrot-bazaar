-- One job: define every brainrot, rarity, mutation, and egg band in one immutable catalog.
local Catalog = {}
Catalog.RarityOrder = { "Common", "Rare", "Epic", "Legendary", "Mythic" }
Catalog.RarityColors = {
	Common = Color3.fromRGB(171, 233, 186), Rare = Color3.fromRGB(80, 184, 255),
	Epic = Color3.fromRGB(192, 118, 255), Legendary = Color3.fromRGB(255, 199, 63),
	Mythic = Color3.fromRGB(255, 96, 146),
}
Catalog.Mutations = {
	Normal = { multiplier = 1, chance = 0.865, tag = "", color = Color3.new(1, 1, 1) },
	Golden = { multiplier = 5, chance = 0.10, tag = "GOLDEN x5", color = Color3.fromRGB(255, 211, 74) },
	Diamond = { multiplier = 10, chance = 0.03, tag = "DIAMOND x10", color = Color3.fromRGB(114, 239, 255) },
	Void = { multiplier = 25, chance = 0.005, tag = "VOID x25", color = Color3.fromRGB(161, 88, 255) },
}
export type Character = { id: string, name: string, rarity: string, price: number, moneyPerSecond: number, bodyColor: Color3, accessoryKind: string }
Catalog.Characters = {
	{ id = "frog", name = "Sir Bouncealot", rarity = "Common", price = 50, moneyPerSecond = 2, bodyColor = Color3.fromRGB(100, 206, 120), accessoryKind = "TopHat" },
	{ id = "banana", name = "Banana Cabana", rarity = "Common", price = 90, moneyPerSecond = 3, bodyColor = Color3.fromRGB(255, 222, 86), accessoryKind = "Sunglasses" },
	{ id = "pigeon", name = "Pigeon Accountant", rarity = "Common", price = 150, moneyPerSecond = 4, bodyColor = Color3.fromRGB(152, 166, 184), accessoryKind = "Briefcase" },
	{ id = "capybara", name = "Capybara Cappuccino", rarity = "Rare", price = 600, moneyPerSecond = 9, bodyColor = Color3.fromRGB(186, 134, 89), accessoryKind = "CoffeeCup" },
	{ id = "cactus", name = "Disco Cactus", rarity = "Rare", price = 950, moneyPerSecond = 12, bodyColor = Color3.fromRGB(66, 174, 125), accessoryKind = "MirrorBall" },
	{ id = "shark", name = "Sneaker Shark", rarity = "Epic", price = 4000, moneyPerSecond = 30, bodyColor = Color3.fromRGB(94, 158, 198), accessoryKind = "Sneakers" },
	{ id = "waffle", name = "Wizard Waffle", rarity = "Epic", price = 6500, moneyPerSecond = 42, bodyColor = Color3.fromRGB(213, 156, 80), accessoryKind = "WizardHat" },
	{ id = "goose", name = "Golden Goose Mogul", rarity = "Legendary", price = 25000, moneyPerSecond = 110, bodyColor = Color3.fromRGB(255, 239, 171), accessoryKind = "MoneyBags" },
	{ id = "alpaca", name = "Astro Alpaca", rarity = "Legendary", price = 40000, moneyPerSecond = 150, bodyColor = Color3.fromRGB(246, 231, 215), accessoryKind = "Helmet" },
	{ id = "dragon", name = "Dragon of Dividends", rarity = "Mythic", price = 150000, moneyPerSecond = 400, bodyColor = Color3.fromRGB(130, 100, 219), accessoryKind = "CoinPile" },
	{ id = "manatee", name = "Moonlight Mermanatee", rarity = "Mythic", price = 250000, moneyPerSecond = 550, bodyColor = Color3.fromRGB(113, 179, 203), accessoryKind = "MoonCrown" },
	{ id = "crab", name = "KING CRAB CAPITALIST", rarity = "Mythic", price = 500000, moneyPerSecond = 900, bodyColor = Color3.fromRGB(244, 102, 88), accessoryKind = "CrownAndCane" },
}
Catalog.EggBands = {
	{ name = "BEACH EGG", price = 125, rarities = { "Common" }, color = Catalog.RarityColors.Common },
	{ name = "DISCO EGG", price = 1100, rarities = { "Rare" }, color = Catalog.RarityColors.Rare },
	{ name = "MAGIC EGG", price = 7500, rarities = { "Epic" }, color = Catalog.RarityColors.Epic },
	{ name = "MOGUL EGG", price = 45000, rarities = { "Legendary" }, color = Catalog.RarityColors.Legendary },
	{ name = "ROYAL EGG", price = 550000, rarities = { "Mythic" }, color = Catalog.RarityColors.Mythic },
}
function Catalog.GetCharacter(id: string): Character
	for _, character in Catalog.Characters do
		if character.id == id then return character end
	end
	error("Unknown brainrot: " .. id)
end
function Catalog.GetRarityIndex(rarity: string): number
	return table.find(Catalog.RarityOrder, rarity) or 1
end
function Catalog.RollMutation(): string
	local roll = math.random()
	if roll < Catalog.Mutations.Void.chance then return "Void" end
	if roll < Catalog.Mutations.Void.chance + Catalog.Mutations.Diamond.chance then return "Diamond" end
	if roll < Catalog.Mutations.Void.chance + Catalog.Mutations.Diamond.chance + Catalog.Mutations.Golden.chance then return "Golden" end
	return "Normal"
end
function Catalog.RollEggCharacter(bandIndex: number): Character
	local band = Catalog.EggBands[bandIndex]
	local choices = {}
	for _, character in Catalog.Characters do
		if table.find(band.rarities, character.rarity) then table.insert(choices, character) end
	end
	return choices[math.random(1, #choices)]
end
function Catalog.FormatMoney(amount: number): string
	local integer = tostring(math.floor(amount))
	local formatted = integer:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	return formatted
end
local function freezeData(value)
	if type(value) == "table" then
		for _, child in value do freezeData(child) end
		table.freeze(value)
	end
end
freezeData(Catalog)
return Catalog
