-- One job: build recognizable part-built creatures and their rarity and mutation labels.
local Catalog = require(game:GetService("ReplicatedStorage").Shared.CharacterCatalog)
local Factory = {}
local BLACK = Color3.fromRGB(30, 35, 48)
local WHITE = Color3.fromRGB(255, 251, 232)
local GOLD = Color3.fromRGB(255, 204, 67)
function Factory.AddPart(model: Model, name: string, size: Vector3, position: Vector3, color: Color3, shape: Enum.PartType?, rotation: CFrame?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = CFrame.new(position) * (rotation or CFrame.identity)
	part.Color = color
	part.Shape = shape or Enum.PartType.Block
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = model
	return part
end
function Factory.BuildSignatureAccessory(model: Model, kind: string)
	local function part(name, size, position, color, shape, rotation)
		return Factory.AddPart(model, name, size, position, color, shape, rotation)
	end
	if kind == "TopHat" then
		part("HatBrim", Vector3.new(2.1, 0.18, 1.7), Vector3.new(0, 3.35, 0), BLACK)
		part("TopHat", Vector3.new(1.4, 0.95, 1.25), Vector3.new(0, 3.9, 0), BLACK)
		part("HatRibbon", Vector3.new(1.43, 0.18, 1.28), Vector3.new(0, 3.55, 0), GOLD)
	elseif kind == "Sunglasses" then
		for _, x in { -0.43, 0.43 } do
			part("ShadeLens", Vector3.new(0.7, 0.42, 0.2), Vector3.new(x, 2.85, -0.84), BLACK)
		end
		part("ShadeBridge", Vector3.new(0.3, 0.1, 0.2), Vector3.new(0, 2.85, -0.87), BLACK)
		part("BananaStem", Vector3.new(0.35, 0.55, 0.4), Vector3.new(0, 3.7, 0), Color3.fromRGB(104, 77, 39))
	elseif kind == "Briefcase" then
		part("Briefcase", Vector3.new(1.3, 1, 0.4), Vector3.new(1.5, 0.85, -0.45), Color3.fromRGB(104, 64, 41))
		part("CaseHandle", Vector3.new(0.6, 0.18, 0.25), Vector3.new(1.5, 1.5, -0.45), BLACK)
		part("CaseLatch", Vector3.new(0.2, 0.25, 0.1), Vector3.new(1.5, 1, -0.7), GOLD)
	elseif kind == "CoffeeCup" then
		part("CoffeeCup", Vector3.new(1.7, 2.65, 2.65), Vector3.new(0, 0.95, 0), WHITE, Enum.PartType.Cylinder, CFrame.Angles(0, 0, math.pi / 2))
		part("Coffee", Vector3.new(0.13, 2.3, 2.3), Vector3.new(0, 1.84, 0), Color3.fromRGB(102, 62, 37), Enum.PartType.Cylinder, CFrame.Angles(0, 0, math.pi / 2))
		part("CupHandle", Vector3.new(0.65, 1, 0.8), Vector3.new(1.5, 1, 0), WHITE)
		for i = 1, 3 do
			local steam = part("Steam", Vector3.new(0.13, 0.6, 0.13), Vector3.new(-0.9 + i * 0.45, 3.6 + i * 0.15, 0.35), WHITE, Enum.PartType.Ball)
			steam.Transparency = 0.45
		end
	elseif kind == "MirrorBall" then
		part("DiscoPole", Vector3.new(0.15, 1, 0.15), Vector3.new(0, 3.5, 0), BLACK)
		local ball = part("MirrorBall", Vector3.new(1.4, 1.4, 1.4), Vector3.new(0, 4.1, 0), Color3.fromRGB(194, 236, 255), Enum.PartType.Ball)
		ball.Material = Enum.Material.Metal
		for i = 1, 8 do
			local angle = i * math.pi / 4
			local tile = part("MirrorTile", Vector3.new(0.33, 0.33, 0.1), Vector3.new(math.sin(angle) * 0.69, 4.1, math.cos(angle) * 0.69), if i % 2 == 0 then GOLD else WHITE, nil, CFrame.Angles(0, angle, 0))
			tile.Material = Enum.Material.Neon
		end
	elseif kind == "Sneakers" then
		for _, x in { -0.85, 0.85 } do
			part("Sneaker", Vector3.new(1.05, 0.55, 1.6), Vector3.new(x, 0.3, -0.4), Color3.fromRGB(255, 93, 114))
			part("Sole", Vector3.new(1.1, 0.16, 1.65), Vector3.new(x, 0.1, -0.4), WHITE)
			for i = 1, 3 do part("Lace", Vector3.new(0.7, 0.07, 0.08), Vector3.new(x, 0.6, -0.85 + i * 0.2), WHITE) end
		end
	elseif kind == "WizardHat" then
		part("WizardBrim", Vector3.new(2.5, 0.2, 2.2), Vector3.new(0, 3.4, 0), Color3.fromRGB(97, 62, 180))
		for i = 1, 5 do
			part("WizardHatTier", Vector3.new(1.7 - i * 0.23, 0.35, 1.7 - i * 0.23), Vector3.new(i * 0.07, 3.5 + i * 0.3, 0), Color3.fromRGB(114, 75, 203))
		end
		part("HatStar", Vector3.new(0.38, 0.38, 0.12), Vector3.new(0, 3.85, -0.65), GOLD, nil, CFrame.Angles(0, 0, math.pi / 4))
	elseif kind == "MoneyBags" then
		for _, x in { -1.4, 1.4 } do
			part("MoneyBag", Vector3.new(1.15, 1.4, 1.05), Vector3.new(x, 0.9, 0), Color3.fromRGB(198, 167, 106), Enum.PartType.Ball)
			part("BagTie", Vector3.new(0.5, 0.2, 0.55), Vector3.new(x, 1.55, 0), GOLD)
			part("DollarStroke", Vector3.new(0.12, 0.65, 0.1), Vector3.new(x, 0.95, -0.56), Color3.fromRGB(59, 120, 81))
		end
	elseif kind == "Helmet" then
		local helmet = part("AstronautHelmet", Vector3.new(2.5, 2.5, 2.5), Vector3.new(0, 2.8, 0), Color3.fromRGB(151, 229, 255), Enum.PartType.Ball)
		helmet.Material = Enum.Material.Glass
		helmet.Transparency = 0.65
		part("HelmetCollar", Vector3.new(2, 0.28, 1.85), Vector3.new(0, 1.8, 0), WHITE)
		part("SpacePack", Vector3.new(1.2, 1.4, 0.7), Vector3.new(0, 1.5, 1), WHITE)
	elseif kind == "CoinPile" then
		for i = 1, 12 do
			local angle = i * 2.4
			local coin = part("DividendCoin", Vector3.new(0.2, 0.75, 0.75), Vector3.new(math.sin(angle) * 1.4, 0.1 + (i % 3) * 0.16, math.cos(angle) * 1.2), GOLD, Enum.PartType.Cylinder, CFrame.Angles(0, 0, math.pi / 2))
			coin.Material = Enum.Material.Metal
		end
	elseif kind == "MoonCrown" or kind == "CrownAndCane" then
		part("CrownBand", Vector3.new(1.9, 0.3, 1.5), Vector3.new(0, 3.4, 0), GOLD)
		for i = -1, 1 do
			part("CrownPoint", Vector3.new(0.32, 0.65, 0.32), Vector3.new(i * 0.65, 3.8, -0.5), GOLD, nil, CFrame.Angles(0, 0, i * 0.15))
		end
		if kind == "MoonCrown" then
			part("Moon", Vector3.new(0.85, 0.85, 0.25), Vector3.new(0, 4.15, -0.55), Color3.fromRGB(204, 249, 255), Enum.PartType.Ball)
			part("MoonInset", Vector3.new(0.65, 0.65, 0.3), Vector3.new(0.22, 4.3, -0.62), Catalog.GetCharacter("manatee").bodyColor, Enum.PartType.Ball)
		else
			part("CapitalistCane", Vector3.new(0.18, 2.7, 0.18), Vector3.new(2.5, 1.35, -0.2), BLACK)
			part("CaneKnob", Vector3.new(0.5, 0.5, 0.5), Vector3.new(2.5, 2.75, -0.2), GOLD, Enum.PartType.Ball)
		end
	end
end
function Factory.BuildBody(model: Model, character)
	local color = character.bodyColor
	local function part(name, size, position, tint, shape, rotation)
		return Factory.AddPart(model, name, size, position, tint or color, shape or Enum.PartType.Ball, rotation)
	end
	part("Body", Vector3.new(2.15, 1.9, 1.7), Vector3.new(0, 1.3, 0))
	part("Head", Vector3.new(1.8, 1.5, 1.5), Vector3.new(0, 2.6, -0.1))
	for _, x in { -0.46, 0.46 } do
		part("Eye", Vector3.new(0.45, 0.5, 0.22), Vector3.new(x, 2.85, -0.84), WHITE)
		part("Pupil", Vector3.new(0.22, 0.28, 0.13), Vector3.new(x, 2.83, -0.97), BLACK)
	end
	part("Smile", Vector3.new(0.58, 0.1, 0.09), Vector3.new(0, 2.35, -0.89), BLACK, Enum.PartType.Block)
	for _, x in { -0.7, 0.7 } do part("Foot", Vector3.new(0.95, 0.45, 1.1), Vector3.new(x, 0.3, -0.2)) end
	if character.id == "frog" then
		for _, x in { -0.68, 0.68 } do part("FrogEyeBump", Vector3.new(0.8, 0.7, 0.7), Vector3.new(x, 3, 0.05)) end
	elseif character.id == "banana" then
		model.Body.Size = Vector3.new(1.25, 2.5, 1.2)
		part("BananaPeelLeft", Vector3.new(0.6, 1.7, 0.8), Vector3.new(-0.9, 1.4, 0), Color3.fromRGB(255, 233, 132), nil, CFrame.Angles(0, 0, -0.45))
		part("BananaPeelRight", Vector3.new(0.6, 1.7, 0.8), Vector3.new(0.9, 1.4, 0), nil, nil, CFrame.Angles(0, 0, 0.45))
	elseif character.id == "pigeon" or character.id == "goose" then
		part("Beak", Vector3.new(0.75, 0.38, 0.7), Vector3.new(0, 2.4, -1), Color3.fromRGB(255, 173, 66))
		for _, x in { -1.05, 1.05 } do part("Wing", Vector3.new(0.55, 1.3, 1.25), Vector3.new(x, 1.5, 0.2)) end
		if character.id == "goose" then part("GooseNeck", Vector3.new(0.85, 1.65, 0.9), Vector3.new(0, 2, 0)) end
	elseif character.id == "capybara" or character.id == "alpaca" then
		part("Muzzle", Vector3.new(1.4, 0.65, 0.7), Vector3.new(0, 2.4, -0.85), Color3.fromRGB(214, 171, 133))
		for _, x in { -0.7, 0.7 } do part("Ear", Vector3.new(0.4, if character.id == "alpaca" then 1.15 else 0.5, 0.45), Vector3.new(x, 3.35, 0)) end
	elseif character.id == "cactus" then
		for _, x in { -1.35, 1.35 } do
			part("CactusArm", Vector3.new(0.65, 1.6, 0.65), Vector3.new(x, 1.9, 0))
			part("CactusElbow", Vector3.new(0.95, 0.5, 0.55), Vector3.new(x * 0.8, 1.3, 0))
		end
		for i = 1, 5 do part("CactusSpine", Vector3.new(0.09, 0.24, 0.12), Vector3.new(-0.7 + (i % 3) * 0.55, 0.8 + i * 0.25, -0.85), WHITE, Enum.PartType.Block) end
	elseif character.id == "shark" then
		part("SharkBelly", Vector3.new(1.4, 1.35, 0.35), Vector3.new(0, 1.3, -0.77), WHITE)
		local fin = Instance.new("WedgePart")
		fin.Name = "DorsalFin"; fin.Size = Vector3.new(0.4, 1.6, 1.5); fin.Position = Vector3.new(0, 2.2, 1.1)
		fin.Color = color; fin.Anchored = true; fin.CanCollide = false; fin.CanTouch = false; fin.Parent = model
		for i = -1, 1 do part("SharkTooth", Vector3.new(0.15, 0.22, 0.13), Vector3.new(i * 0.25, 2.3, -0.94), WHITE, Enum.PartType.Block) end
	elseif character.id == "waffle" then
		model.Body.Shape = Enum.PartType.Block; model.Body.Size = Vector3.new(2.1, 2.3, 0.85)
		for x = -1, 1 do for y = 0, 2 do part("WafflePocket", Vector3.new(0.43, 0.43, 0.12), Vector3.new(x * 0.6, 0.65 + y * 0.6, -0.48), Color3.fromRGB(151, 99, 44), Enum.PartType.Block) end end
	elseif character.id == "dragon" then
		for _, x in { -1.6, 1.6 } do
			part("DragonWing", Vector3.new(1.6, 1.5, 0.3), Vector3.new(x, 2.1, 0.45), Color3.fromRGB(184, 127, 239), Enum.PartType.Block, CFrame.Angles(0, 0, x * 0.25))
			part("DragonHorn", Vector3.new(0.35, 0.85, 0.35), Vector3.new(x * 0.42, 3.55, 0), GOLD)
		end
		part("DragonTail", Vector3.new(0.7, 0.7, 2.5), Vector3.new(0, 0.9, 1.4))
	elseif character.id == "manatee" then
		model.Body.Size = Vector3.new(2.8, 1.8, 2.1)
		for _, x in { -1.5, 1.5 } do part("ManateeFlipper", Vector3.new(1.2, 0.4, 1.15), Vector3.new(x, 1, 0.1)) end
		part("MermaidTail", Vector3.new(2.3, 0.4, 1.4), Vector3.new(0, 0.7, 1.6), Color3.fromRGB(129, 225, 217))
	elseif character.id == "crab" then
		model.Body.Size = Vector3.new(3.3, 1.7, 2)
		for _, side in { -1, 1 } do
			part("CrabClaw", Vector3.new(1.15, 1.2, 1.15), Vector3.new(side * 2, 2.05, -0.2))
			part("ClawNotch", Vector3.new(0.3, 0.65, 0.2), Vector3.new(side * 2, 2.45, -0.78), WHITE, Enum.PartType.Block)
			for i = 1, 3 do part("CrabLeg", Vector3.new(1.5, 0.22, 0.3), Vector3.new(side * 1.7, 0.45, -0.5 + i * 0.55), nil, Enum.PartType.Block, CFrame.Angles(0, side * 0.35, side * -0.2)) end
		end
	end
end
function Factory.BuildLabel(model: Model, character, mutation: string)
	local gui = Instance.new("BillboardGui")
	gui.Name = "BrainrotLabel"; gui.Adornee = model.PrimaryPart; gui.Size = UDim2.fromOffset(230, 78)
	gui.StudsOffset = Vector3.new(0, 5.2 * model:GetScale(), 0); gui.AlwaysOnTop = true; gui.MaxDistance = 95; gui.Parent = model
	local lines = { character.name, character.rarity:upper() .. " - $" .. character.moneyPerSecond .. "/s", Catalog.Mutations[mutation].tag }
	for index, text in lines do
		local label = Instance.new("TextLabel")
		label.Name = "Line" .. index; label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, 0, 0, 26); label.Position = UDim2.fromOffset(0, (index - 1) * 26)
		label.Font = Enum.Font.GothamBold; label.TextSize = if index == 1 then 17 else 14
		label.TextColor3 = if index == 1 then Catalog.RarityColors[character.rarity] elseif index == 3 then Catalog.Mutations[mutation].color else WHITE
		label.TextStrokeTransparency = 0.25; label.Text = text; label.Parent = gui
	end
end
function Factory.CreateCharacter(id: string, mutation: string, parent: Instance): Model
	local character = Catalog.GetCharacter(id)
	local model = Instance.new("Model")
	model.Name = character.name
	local root = Factory.AddPart(model, "Root", Vector3.new(3.8, 4, 3.8), Vector3.zero, character.bodyColor)
	root.Transparency = 1; root.CanTouch = true; root.CanQuery = true; model.PrimaryPart = root
	Factory.BuildBody(model, character)
	Factory.BuildSignatureAccessory(model, character.accessoryKind)
	model:ScaleTo(0.85 + Catalog.GetRarityIndex(character.rarity) * 0.12)
	if mutation ~= "Normal" then
		local highlight = Instance.new("Highlight")
		highlight.Name = "MutationGlow"; highlight.FillColor = Catalog.Mutations[mutation].color
		highlight.FillTransparency = 0.63; highlight.OutlineColor = Catalog.Mutations[mutation].color
		highlight.OutlineTransparency = 0.15; highlight.Parent = model
		for _, name in { "Body", "Head" } do
			model[name].Color = model[name].Color:Lerp(Catalog.Mutations[mutation].color, 0.55)
			model[name].Material = if mutation == "Void" then Enum.Material.Neon else Enum.Material.Metal
		end
	end
	Factory.BuildLabel(model, character, mutation)
	model:SetAttribute("CatalogId", id); model:SetAttribute("Mutation", mutation)
	model:PivotTo(CFrame.identity); model.Parent = parent
	return model
end
return Factory
