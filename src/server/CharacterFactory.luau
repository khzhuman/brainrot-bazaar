-- One job: assemble twelve readable part-built brainrots, their signature accessories, and mutation labels.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterCatalog"))

local CharacterFactory = {}
local WHITE = Color3.fromRGB(255, 253, 241)
local BLACK = Color3.fromRGB(28, 32, 43)
local GOLD = Color3.fromRGB(255, 199, 48)

local function buildPart(model: Model, name: string, shape: string, size: Vector3, position: Vector3, colour: Color3, scale: number, rotation: CFrame?, material: Enum.Material?): BasePart
	local part: BasePart
	if shape == "Wedge" then
		part = Instance.new("WedgePart")
	else
		local primitive = Instance.new("Part")
		primitive.Shape = if shape == "Ball" then Enum.PartType.Ball elseif shape == "Cylinder" then Enum.PartType.Cylinder else Enum.PartType.Block
		part = primitive
	end
	part.Name = name
	part.Size = size * scale
	part.CFrame = CFrame.new(position * scale) * (rotation or CFrame.identity)
	part.Color = colour
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = model
	return part
end

local function buildVerticalCylinder(model: Model, name: string, diameter: number, height: number, position: Vector3, colour: Color3, scale: number, material: Enum.Material?): BasePart
	return buildPart(model, name, "Cylinder", Vector3.new(height, diameter, diameter), position, colour, scale, CFrame.Angles(0, 0, math.pi / 2), material)
end

local function buildConeFromWedges(model: Model, name: string, radius: number, height: number, position: Vector3, colour: Color3, scale: number)
	-- Two opposed wedges make a pointed silhouette without mesh assets.
	for side = -1, 1, 2 do
		buildPart(model, name, "Wedge", Vector3.new(radius, height, radius * 2), position + Vector3.new(side * radius / 2, 0, 0), colour, scale, CFrame.Angles(0, side * math.pi / 2, 0))
	end
end

local function buildEyes(model: Model, position: Vector3, spacing: number, scale: number)
	for side = -1, 1, 2 do
		local eyePosition = position + Vector3.new(side * spacing, 0, 0)
		buildPart(model, "BigWhiteEye", "Ball", Vector3.new(0.65, 0.75, 0.38), eyePosition, WHITE, scale)
		buildPart(model, "CuriousPupil", "Ball", Vector3.new(0.29, 0.39, 0.19), eyePosition + Vector3.new(0.04, -0.02, -0.2), BLACK, scale)
	end
end

local function buildTopHat(model: Model, position: Vector3, scale: number)
	buildVerticalCylinder(model, "TopHatBrim", 2.15, 0.17, position, BLACK, scale)
	buildVerticalCylinder(model, "TopHat", 1.45, 1.15, position + Vector3.new(0, 0.6, 0), BLACK, scale)
	buildVerticalCylinder(model, "HatRibbon", 1.48, 0.17, position + Vector3.new(0, 0.17, 0), GOLD, scale)
end

local function buildSirBouncealot(model: Model, colour: Color3, scale: number)
	for index = 1, 4 do
		buildVerticalCylinder(model, "VisibleSpring", 1.5, 0.13, Vector3.new(0, 0.2 + index * 0.22, 0), Color3.fromRGB(180, 194, 211), scale, Enum.Material.Metal)
	end
	buildPart(model, "Body", "Ball", Vector3.new(2.8, 2.8, 2.8), Vector3.new(0, 2.25, 0), colour, scale)
	buildPart(model, "Head", "Ball", Vector3.new(2.25, 1.65, 1.65), Vector3.new(0, 3.1, -0.45), colour, scale)
	buildEyes(model, Vector3.new(0, 3.28, -1.24), 0.6, scale)
	buildTopHat(model, Vector3.new(0, 3.88, 0), scale)
end

local function buildBananaCabana(model: Model, colour: Color3, scale: number)
	buildPart(model, "Body", "Cylinder", Vector3.new(2.9, 1.25, 1.25), Vector3.new(0, 1.85, 0), colour, scale, CFrame.Angles(0, 0, math.rad(65)))
	for side = -1, 1, 2 do
		buildPart(model, "CurvedBananaEnd", "Wedge", Vector3.new(1.2, 1.8, 1.1), Vector3.new(side * 0.83, 2.7, 0), colour, scale, CFrame.Angles(0, 0, side * math.rad(28)))
	end
	buildPart(model, "Head", "Ball", Vector3.new(1.5, 1.4, 1.0), Vector3.new(0, 2.7, -0.35), colour, scale)
	buildEyes(model, Vector3.new(0, 2.85, -0.88), 0.37, scale)
	buildPart(model, "Sunglasses", "Block", Vector3.new(1.5, 0.32, 0.12), Vector3.new(0, 2.78, -1.06), BLACK, scale)
	buildVerticalCylinder(model, "UmbrellaPole", 0.1, 2.0, Vector3.new(0.55, 3.8, 0.1), WHITE, scale)
	buildPart(model, "BeachUmbrella", "Ball", Vector3.new(3.1, 0.55, 2.6), Vector3.new(0.55, 4.8, 0.1), Color3.fromRGB(255, 107, 144), scale)
	buildPart(model, "UmbrellaStripe", "Block", Vector3.new(0.4, 0.12, 2.3), Vector3.new(0.55, 5.03, 0.1), WHITE, scale)
end

local function buildPigeonAccountant(model: Model, colour: Color3, scale: number)
	buildPart(model, "Body", "Ball", Vector3.new(2.6, 2.8, 2.1), Vector3.new(0, 1.75, 0), colour, scale)
	buildPart(model, "WhiteChest", "Ball", Vector3.new(1.7, 1.7, 0.4), Vector3.new(0, 1.5, -1.0), WHITE, scale)
	buildPart(model, "Head", "Ball", Vector3.new(1.9, 1.6, 1.7), Vector3.new(0, 3.2, -0.15), colour, scale)
	buildEyes(model, Vector3.new(0, 3.36, -0.94), 0.47, scale)
	buildPart(model, "Beak", "Wedge", Vector3.new(0.5, 0.4, 0.65), Vector3.new(0, 2.94, -1.15), GOLD, scale)
	buildVerticalCylinder(model, "GreenVisorCap", 2.0, 0.35, Vector3.new(0, 4.02, -0.1), Color3.fromRGB(49, 148, 98), scale)
	buildPart(model, "VisorPeak", "Block", Vector3.new(1.9, 0.13, 0.8), Vector3.new(0, 3.94, -1.12), Color3.fromRGB(49, 148, 98), scale)
	buildPart(model, "Briefcase", "Block", Vector3.new(1.05, 1.1, 0.6), Vector3.new(1.6, 1.18, -0.1), Color3.fromRGB(118, 75, 46), scale)
	buildPart(model, "BriefcaseHandle", "Block", Vector3.new(0.55, 0.17, 0.3), Vector3.new(1.6, 1.84, -0.1), GOLD, scale)
end

local function buildCapybaraCappuccino(model: Model, colour: Color3, scale: number)
	buildPart(model, "Body", "Ball", Vector3.new(3.0, 2.35, 2.7), Vector3.new(0, 1.35, 0), colour, scale)
	buildPart(model, "Head", "Block", Vector3.new(2.3, 1.65, 1.7), Vector3.new(0, 2.6, -0.55), colour, scale)
	buildPart(model, "RoundedMuzzle", "Ball", Vector3.new(2.15, 0.95, 1.1), Vector3.new(0, 2.27, -1.32), Color3.fromRGB(202, 149, 102), scale)
	buildEyes(model, Vector3.new(0, 2.98, -1.44), 0.65, scale)
	buildVerticalCylinder(model, "CoffeeCup", 1.6, 1.08, Vector3.new(0, 3.98, -0.1), WHITE, scale)
	buildVerticalCylinder(model, "CoffeeDisc", 1.43, 0.08, Vector3.new(0, 4.54, -0.1), Color3.fromRGB(90, 51, 31), scale)
	buildPart(model, "CupHandle", "Ball", Vector3.new(0.7, 0.75, 0.35), Vector3.new(1.04, 4.0, -0.1), WHITE, scale)
end

local function buildDiscoCactus(model: Model, colour: Color3, scale: number)
	buildVerticalCylinder(model, "Body", 2.1, 3.3, Vector3.new(0, 1.9, 0), colour, scale)
	for side = -1, 1, 2 do
		buildPart(model, "CactusArm", "Cylinder", Vector3.new(1.6, 0.65, 0.65), Vector3.new(side * 1.3, 2.1, 0), colour, scale, CFrame.Angles(0, 0, side * math.rad(38)))
	end
	buildPart(model, "Head", "Ball", Vector3.new(2.0, 1.3, 1.7), Vector3.new(0, 3.3, 0), colour, scale)
	buildEyes(model, Vector3.new(0, 2.91, -1.03), 0.5, scale)
	buildVerticalCylinder(model, "DiscoPole", 0.13, 0.7, Vector3.new(0, 4.1, 0), BLACK, scale)
	local ball = buildPart(model, "MirrorBall", "Ball", Vector3.new(1.6, 1.6, 1.6), Vector3.new(0, 5.05, 0), Color3.fromRGB(197, 222, 255), scale, nil, Enum.Material.Metal)
	ball.Reflectance = 0.5
	local sparkle = Instance.new("Sparkles")
	sparkle.SparkleColor = Color3.fromRGB(235, 143, 255)
	sparkle.Parent = ball
end

local function buildSneakerShark(model: Model, colour: Color3, scale: number)
	buildPart(model, "Body", "Ball", Vector3.new(2.9, 3.1, 2.45), Vector3.new(0, 2.2, 0), colour, scale)
	buildPart(model, "WhiteBelly", "Ball", Vector3.new(1.8, 2.3, 0.4), Vector3.new(0, 2.0, -1.13), WHITE, scale)
	buildPart(model, "Head", "Ball", Vector3.new(2.65, 1.6, 2.0), Vector3.new(0, 3.35, -0.25), colour, scale)
	buildPart(model, "DorsalFin", "Wedge", Vector3.new(0.45, 2.05, 1.55), Vector3.new(0, 3.0, 1.24), colour, scale)
	buildEyes(model, Vector3.new(0, 3.55, -1.18), 0.7, scale)
	for side = -1, 1, 2 do
		buildPart(model, "RedSneaker", "Block", Vector3.new(1.2, 0.72, 1.95), Vector3.new(side * 0.85, 0.5, -0.55), Color3.fromRGB(238, 65, 74), scale)
		buildPart(model, "WhiteSneakerSole", "Block", Vector3.new(1.28, 0.19, 2.03), Vector3.new(side * 0.85, 0.15, -0.55), WHITE, scale)
		buildPart(model, "SneakerLace", "Block", Vector3.new(0.8, 0.1, 0.38), Vector3.new(side * 0.85, 0.88, -0.82), WHITE, scale)
	end
end

local function buildWizardWaffle(model: Model, colour: Color3, scale: number)
	buildPart(model, "Body", "Block", Vector3.new(3.0, 3.05, 0.92), Vector3.new(0, 1.9, 0), colour, scale)
	for index = -1, 1 do
		buildPart(model, "WaffleGroove", "Block", Vector3.new(0.12, 2.9, 0.07), Vector3.new(index * 0.75, 1.9, -0.49), Color3.fromRGB(168, 113, 60), scale)
		buildPart(model, "WaffleGroove", "Block", Vector3.new(2.9, 0.12, 0.07), Vector3.new(0, 1.9 + index * 0.75, -0.49), Color3.fromRGB(168, 113, 60), scale)
	end
	buildPart(model, "Head", "Ball", Vector3.new(1.7, 0.8, 0.7), Vector3.new(0, 3.25, -0.1), colour, scale)
	buildEyes(model, Vector3.new(0, 2.4, -0.64), 0.62, scale)
	buildVerticalCylinder(model, "StarYellowBrim", 3.05, 0.18, Vector3.new(0, 3.7, 0), GOLD, scale)
	buildConeFromWedges(model, "PurpleWizardCone", 1.1, 2.5, Vector3.new(0, 4.92, 0), Color3.fromRGB(127, 69, 208), scale)
	buildPart(model, "HatStar", "Block", Vector3.new(0.45, 0.45, 0.08), Vector3.new(0, 4.25, -0.94), GOLD, scale, CFrame.Angles(0, 0, math.pi / 4), Enum.Material.Neon)
end

local function buildGoldenGooseMogul(model: Model, colour: Color3, scale: number)
	buildPart(model, "Body", "Ball", Vector3.new(2.8, 2.55, 2.3), Vector3.new(0, 1.65, 0), colour, scale, nil, Enum.Material.Metal)
	buildVerticalCylinder(model, "Neck", 0.9, 1.45, Vector3.new(0, 3.0, -0.4), colour, scale, Enum.Material.Metal)
	buildPart(model, "Head", "Ball", Vector3.new(1.8, 1.65, 1.65), Vector3.new(0, 4.0, -0.45), colour, scale, nil, Enum.Material.Metal)
	buildEyes(model, Vector3.new(0, 4.12, -1.2), 0.44, scale)
	buildPart(model, "GooseBill", "Block", Vector3.new(0.95, 0.35, 0.9), Vector3.new(0, 3.75, -1.46), Color3.fromRGB(255, 134, 44), scale)
	buildTopHat(model, Vector3.new(0, 4.84, -0.4), scale)
	buildPart(model, "GoldMonocleRing", "Cylinder", Vector3.new(0.12, 0.84, 0.84), Vector3.new(0.44, 4.12, -1.43), GOLD, scale, CFrame.Angles(0, math.pi / 2, 0), Enum.Material.Metal)
	buildPart(model, "MonocleGlass", "Ball", Vector3.new(0.58, 0.64, 0.12), Vector3.new(0.44, 4.12, -1.51), Color3.fromRGB(169, 226, 240), scale, nil, Enum.Material.Glass).Transparency = 0.45
	buildPart(model, "MoneyBag", "Ball", Vector3.new(1.1, 1.4, 1.1), Vector3.new(1.55, 0.85, 0), GOLD, scale)
end

local function buildAstroAlpaca(model: Model, colour: Color3, scale: number)
	buildPart(model, "Body", "Ball", Vector3.new(2.9, 2.7, 2.7), Vector3.new(0, 1.8, 0), colour, scale)
	for index = 1, 4 do
		local angle = index * math.pi / 2
		buildPart(model, "FluffyWool", "Ball", Vector3.new(1.5, 1.5, 1.5), Vector3.new(math.cos(angle), 1.85, math.sin(angle)), colour, scale)
	end
	buildVerticalCylinder(model, "LongNeck", 1.0, 1.8, Vector3.new(0, 3.3, -0.25), colour, scale)
	buildPart(model, "Head", "Ball", Vector3.new(1.75, 1.8, 1.45), Vector3.new(0, 4.25, -0.3), colour, scale)
	buildEyes(model, Vector3.new(0, 4.35, -1.01), 0.43, scale)
	local helmet = buildPart(model, "ClearAstronautHelmet", "Ball", Vector3.new(2.75, 2.8, 2.6), Vector3.new(0, 4.25, -0.3), Color3.fromRGB(167, 229, 250), scale, nil, Enum.Material.Glass)
	helmet.Transparency = 0.52
	buildVerticalCylinder(model, "HelmetSeal", 2.25, 0.2, Vector3.new(0, 3.18, -0.3), Color3.fromRGB(71, 116, 170), scale, Enum.Material.Metal)
end

local function buildDragonOfDividends(model: Model, colour: Color3, scale: number)
	buildPart(model, "Body", "Ball", Vector3.new(3.1, 3.0, 2.6), Vector3.new(0, 1.9, 0), colour, scale)
	buildPart(model, "Head", "Ball", Vector3.new(2.35, 1.8, 2.1), Vector3.new(0, 3.55, -0.55), colour, scale)
	buildEyes(model, Vector3.new(0, 3.7, -1.54), 0.62, scale)
	for side = -1, 1, 2 do
		buildPart(model, "DragonWing", "Wedge", Vector3.new(2.8, 2.7, 0.35), Vector3.new(side * 2.2, 3.0, 0.85), Color3.fromRGB(122, 91, 207), scale, CFrame.Angles(0, side * math.rad(28), side * math.rad(-24)))
		buildConeFromWedges(model, "HornCone", 0.24, 1.0, Vector3.new(side * 0.75, 4.64, -0.4), GOLD, scale)
	end
	for index = 1, 3 do
		buildVerticalCylinder(model, "DividendCoin", 1.35, 0.21, Vector3.new(2.05, 0.16 + index * 0.23, -0.55), GOLD, scale, Enum.Material.Metal)
	end
end

local function buildMoonlightMermanatee(model: Model, colour: Color3, scale: number)
	buildPart(model, "Body", "Ball", Vector3.new(3.5, 2.6, 2.9), Vector3.new(0, 1.6, 0), colour, scale)
	buildPart(model, "Head", "Ball", Vector3.new(2.5, 1.9, 2.05), Vector3.new(0, 2.85, -0.7), colour, scale)
	buildEyes(model, Vector3.new(0, 3.0, -1.69), 0.68, scale)
	buildPart(model, "TailFin", "Wedge", Vector3.new(3.0, 0.55, 2.0), Vector3.new(0, 0.75, 2.0), colour, scale, CFrame.Angles(0, math.pi, 0))
	buildVerticalCylinder(model, "MoonPole", 0.12, 3.7, Vector3.new(0, 3.0, 1.5), Color3.fromRGB(116, 175, 216), scale)
	local moon = buildPart(model, "GlowingMoon", "Ball", Vector3.new(1.85, 1.85, 1.85), Vector3.new(0, 5.1, 1.5), Color3.fromRGB(172, 221, 255), scale, nil, Enum.Material.Neon)
	buildVerticalCylinder(model, "MoonCrown", 1.7, 0.2, Vector3.new(0, 3.87, -0.5), Color3.fromRGB(178, 228, 255), scale, Enum.Material.Neon)
	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(100, 177, 255)
	glow.Brightness = 0.7
	glow.Range = 9
	glow.Parent = moon
end

local function buildKingCrabCapitalist(model: Model, colour: Color3, scale: number)
	buildPart(model, "Body", "Ball", Vector3.new(4.4, 2.2, 2.8), Vector3.new(0, 1.6, 0), colour, scale)
	buildPart(model, "Head", "Ball", Vector3.new(2.8, 1.3, 1.6), Vector3.new(0, 2.55, -0.35), colour, scale)
	buildEyes(model, Vector3.new(0, 2.98, -0.95), 0.86, scale)
	for side = -1, 1, 2 do
		buildPart(model, "RaisedClawArm", "Cylinder", Vector3.new(2.65, 0.6, 0.6), Vector3.new(side * 2.65, 2.3, 0), colour, scale, CFrame.Angles(0, 0, side * math.rad(50)))
		buildPart(model, "HugeCrabClaw", "Ball", Vector3.new(1.8, 2.0, 1.4), Vector3.new(side * 3.5, 3.48, -0.2), colour, scale)
		buildPart(model, "ClawPincer", "Wedge", Vector3.new(0.8, 1.0, 1.2), Vector3.new(side * 3.5, 4.2, -0.35), colour, scale, CFrame.Angles(0, side * math.pi / 2, 0))
		buildPart(model, "CrabLegs", "Block", Vector3.new(2.1, 0.28, 1.5), Vector3.new(side * 1.85, 0.4, 0.15), colour, scale, CFrame.Angles(0, side * math.rad(24), 0))
	end
	buildVerticalCylinder(model, "GoldenCrownBand", 2.15, 0.45, Vector3.new(0, 3.52, -0.15), GOLD, scale, Enum.Material.Metal)
	for index = -1, 1 do
		buildConeFromWedges(model, "CrownConeSpike", 0.23, 0.95, Vector3.new(index * 0.67, 4.17, -0.15), GOLD, scale)
	end
	buildVerticalCylinder(model, "CapitalistCane", 0.14, 2.4, Vector3.new(2.5, 1.3, -1.25), BLACK, scale)
	local bag = buildPart(model, "GreenMoneyBag", "Block", Vector3.new(1.4, 1.6, 1.0), Vector3.new(-2.1, 1.0, -1.15), Color3.fromRGB(52, 161, 93), scale)
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Front
	surface.CanvasSize = Vector2.new(120, 120)
	surface.Parent = bag
	local dollar = Instance.new("TextLabel")
	dollar.Size = UDim2.fromScale(1, 1)
	dollar.BackgroundTransparency = 1
	dollar.Text = "$"
	dollar.TextScaled = true
	dollar.Font = Enum.Font.GothamBlack
	dollar.TextColor3 = GOLD
	dollar.Parent = surface
end

local BUILDERS = table.freeze({
	sir_bouncealot = buildSirBouncealot,
	banana_cabana = buildBananaCabana,
	pigeon_accountant = buildPigeonAccountant,
	capybara_cappuccino = buildCapybaraCappuccino,
	disco_cactus = buildDiscoCactus,
	sneaker_shark = buildSneakerShark,
	wizard_waffle = buildWizardWaffle,
	golden_goose_mogul = buildGoldenGooseMogul,
	astro_alpaca = buildAstroAlpaca,
	dragon_of_dividends = buildDragonOfDividends,
	moonlight_mermanatee = buildMoonlightMermanatee,
	king_crab_capitalist = buildKingCrabCapitalist,
})

function CharacterFactory.ApplyMutation(model: Model, mutation: string)
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") and (part.Name == "Body" or part.Name == "Head" or part.Name == "CactusArm" or part.Name == "HugeCrabClaw" or part.Name == "FluffyWool" or part.Name == "CurvedBananaEnd") then
			if mutation == "Golden" then
				part.Color = GOLD
				part.Material = Enum.Material.Metal
				part.Reflectance = 0.2
			elseif mutation == "Diamond" then
				part.Color = Color3.fromRGB(177, 242, 255)
				part.Material = Enum.Material.Glass
				part.Transparency = 0.25
			elseif mutation == "Void" then
				part.Color = Color3.fromRGB(29, 13, 48)
				part.Material = Enum.Material.Neon
			end
		end
	end
	if mutation == "Void" then
		local accent = buildPart(model, "VoidNeonAccent", "Ball", Vector3.new(0.7, 0.7, 0.7), Vector3.new(0, 1.3, -1.5), Color3.fromRGB(201, 75, 255), 1, nil, Enum.Material.Neon)
		local glow = Instance.new("PointLight")
		glow.Color = accent.Color
		glow.Brightness = 0.8
		glow.Range = 6
		glow.Parent = accent
	end
end

function CharacterFactory.BuildBillboard(model: Model, id: string, mutation: string, scale: number)
	local definition = Catalog.GetCharacter(id)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BrainrotLabel"
	billboard.Adornee = model.PrimaryPart
	billboard.Size = UDim2.fromOffset(255, 90)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 7.0 * scale, 0)
	billboard.MaxDistance = 95
	billboard.AlwaysOnTop = false
	billboard.Parent = model.PrimaryPart
	local lines = {
		{ text = definition.name, colour = Catalog.RarityColours[definition.rarity] },
		{ text = string.upper(definition.rarity) .. " - $" .. Catalog.FormatMoney(definition.moneyPerSecond) .. "/s", colour = WHITE },
		{ text = Catalog.Mutations[mutation].tag, colour = if mutation == "Void" then Color3.fromRGB(209, 126, 255) elseif mutation == "Diamond" then Color3.fromRGB(172, 242, 255) else GOLD },
	}
	for index, line in lines do
		local label = Instance.new("TextLabel")
		label.Name = if index == 1 then "Name" elseif index == 2 then "RarityAndRate" else "Mutation"
		label.Position = UDim2.fromScale(0, (index - 1) / 3)
		label.Size = UDim2.fromScale(1, 1 / 3)
		label.BackgroundTransparency = 1
		label.Text = line.text
		label.TextColor3 = line.colour
		label.TextStrokeColor3 = Color3.fromRGB(24, 34, 50)
		label.TextStrokeTransparency = 0.15
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = billboard
	end
end

function CharacterFactory.BuildCharacter(id: string, mutation: string): Model
	local definition = Catalog.GetCharacter(id)
	local scale = 1 + (Catalog.GetRarityIndex(definition.rarity) - 1) * 0.085
	if id == "king_crab_capitalist" then
		scale *= 1.08
	end
	local model = Instance.new("Model")
	model.Name = definition.name
	model:SetAttribute("CatalogId", id)
	model:SetAttribute("Mutation", mutation)
	local root = buildPart(model, "InteractionRoot", "Block", Vector3.new(4.3, 7.0, 4.3), Vector3.zero, WHITE, scale)
	root.Transparency = 1
	root.CanTouch = true
	root.CanQuery = true
	model.PrimaryPart = root
	BUILDERS[id](model, definition.bodyColour, scale)
	CharacterFactory.ApplyMutation(model, mutation)
	CharacterFactory.BuildBillboard(model, id, mutation, scale)
	return model
end

return CharacterFactory
