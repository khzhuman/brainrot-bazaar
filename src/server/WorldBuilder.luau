-- One job: build the sunny seaside bazaar, readable landmarks, and six eight-pad safe bases at server startup.
--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterCatalog"))

local WorldBuilder = {}
local WOOD = Color3.fromRGB(184, 126, 81)
local CREAM = Color3.fromRGB(255, 241, 202)
local CORAL = Color3.fromRGB(242, 111, 108)
local TEAL = Color3.fromRGB(50, 177, 176)
local GOLD = Color3.fromRGB(255, 205, 71)
local INK = Color3.fromRGB(30, 56, 73)

local function buildPart(parent: Instance, name: string, size: Vector3, position: Vector3, colour: Color3, material: Enum.Material?, shape: Enum.PartType?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = colour
	part.Material = material or Enum.Material.SmoothPlastic
	part.Shape = shape or Enum.PartType.Block
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function buildCylinder(parent: Instance, name: string, diameter: number, height: number, position: Vector3, colour: Color3, material: Enum.Material?): Part
	local part = buildPart(parent, name, Vector3.new(height, diameter, diameter), position, colour, material, Enum.PartType.Cylinder)
	part.Orientation = Vector3.new(0, 0, 90)
	return part
end

local function buildSign(parent: Instance, name: string, text: string, size: Vector3, position: Vector3, colour: Color3, textColour: Color3): (Part, { TextLabel })
	local sign = buildPart(parent, name, size, position, colour, Enum.Material.WoodPlanks)
	local labels = {}
	for _, face in { Enum.NormalId.Front, Enum.NormalId.Back } do
		local surface = Instance.new("SurfaceGui")
		surface.Name = "SignFace"
		surface.Face = face
		surface.CanvasSize = Vector2.new(1000, 300)
		surface.Parent = sign
		local label = Instance.new("TextLabel")
		label.Name = "SignText"
		label.Position = UDim2.fromScale(0.035, 0.06)
		label.Size = UDim2.fromScale(0.93, 0.88)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextScaled = true
		label.TextWrapped = true
		label.Font = Enum.Font.GothamBlack
		label.TextColor3 = textColour
		label.Parent = surface
		table.insert(labels, label)
	end
	return sign, labels
end

local function buildFloatingLabel(part: BasePart, text: string, colour: Color3, offset: number): TextLabel
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Instruction"
	billboard.Adornee = part
	billboard.Size = UDim2.fromOffset(170, 58)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, offset, 0)
	billboard.MaxDistance = 60
	billboard.AlwaysOnTop = false
	billboard.Parent = part
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.TextWrapped = true
	label.TextColor3 = colour
	label.TextStrokeTransparency = 0.25
	label.TextStrokeColor3 = INK
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard
	return label
end

local function buildPrompt(part: BasePart, action: string, object: string): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Interact"
	prompt.ActionText = action
	prompt.ObjectText = object
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 9
	prompt.RequiresLineOfSight = false
	prompt.Parent = part
	return prompt
end

function WorldBuilder.BuildGoldenHourLighting()
	Lighting.ClockTime = 16.6
	Lighting.Brightness = 2.6
	Lighting.Ambient = Color3.fromRGB(143, 133, 153)
	Lighting.OutdoorAmbient = Color3.fromRGB(182, 172, 149)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 224, 179)
	Lighting.GlobalShadows = true
	Lighting.FogColor = Color3.fromRGB(191, 227, 243)
	Lighting.FogStart = 260
	Lighting.FogEnd = 850
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.22
	atmosphere.Color = Color3.fromRGB(217, 231, 244)
	atmosphere.Decay = Color3.fromRGB(255, 211, 157)
	atmosphere.Haze = 1.1
	atmosphere.Parent = Lighting
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.2
	bloom.Size = 20
	bloom.Threshold = 1.6
	bloom.Parent = Lighting
end

function WorldBuilder.BuildIslandAndBoardwalk(world: Model)
	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then
		baseplate.Transparency = 1
		baseplate.CanCollide = false
		baseplate.CanTouch = false
	end
	buildPart(world, "SandyIsland", Vector3.new(190, 4, 180), Vector3.new(0, -0.5, 0), Color3.fromRGB(237, 213, 164), Enum.Material.Sand)
	local sea = buildPart(world, "Sea", Vector3.new(900, 2, 900), Vector3.new(0, -3, 0), Color3.fromRGB(40, 157, 196), Enum.Material.Glass)
	sea.Transparency = 0.32
	sea.CanCollide = false
	sea.CanTouch = false
	buildPart(world, "NorthBoardwalk", Vector3.new(178, 1, 13), Vector3.new(0, 2, -83), WOOD, Enum.Material.WoodPlanks)
	buildPart(world, "SouthBoardwalk", Vector3.new(178, 1, 13), Vector3.new(0, 2, 83), WOOD, Enum.Material.WoodPlanks)
	for side = -1, 1, 2 do
		buildPart(world, "SideBoardwalk", Vector3.new(13, 1, 154), Vector3.new(side * 83, 2, 0), WOOD, Enum.Material.WoodPlanks)
		buildPart(world, "SeasideRail", Vector3.new(0.4, 2, 168), Vector3.new(side * 92, 3.3, 0), CREAM, Enum.Material.Wood)
	end
	buildPart(world, "StonePlaza", Vector3.new(145, 0.8, 58), Vector3.new(0, 2.15, 2), Color3.fromRGB(232, 219, 196), Enum.Material.Slate)
	buildPart(world, "ShopLane", Vector3.new(142, 0.75, 18), Vector3.new(0, 2.5, -25), WOOD, Enum.Material.WoodPlanks)
	for _, z in { -34.3, -15.7 } do
		buildPart(world, "LaneGoldTrim", Vector3.new(142, 0.14, 0.45), Vector3.new(0, 2.98, z), GOLD, Enum.Material.Metal)
	end
	buildSign(world, "LaneWelcome", "TOUCH TO BUY  >  CARRY HOME  >  PRINT CASH", Vector3.new(38, 3.2, 0.5), Vector3.new(0, 8, -12.8), TEAL, CREAM)
end

function WorldBuilder.BuildEntranceArch(world: Model)
	for side = -1, 1, 2 do
		buildPart(world, "EntrancePillar", Vector3.new(2.2, 15, 2.2), Vector3.new(side * 18, 9.5, 28), CORAL, Enum.Material.WoodPlanks)
	end
	buildSign(world, "BrainrotBazaarEntrance", "BRAINROT BAZAAR", Vector3.new(40, 5.5, 1.2), Vector3.new(0, 16, 28), TEAL, CREAM)
	buildSign(world, "EntranceSubtitle", "SEASIDE SILLINESS  /  SERIOUS DIVIDENDS", Vector3.new(32, 1.7, 0.5), Vector3.new(0, 11.9, 28), CREAM, INK)
end

function WorldBuilder.BuildPalmsAndLampPosts(world: Model)
	for index = 1, 10 do
		local side = if index % 2 == 0 then 1 else -1
		local z = -73 + math.floor((index - 1) / 2) * 35
		local position = Vector3.new(side * 73, 7.8, z)
		local trunk = buildCylinder(world, "TiltedPalmTrunk", 1.4, 11, position, Color3.fromRGB(130, 91, 57), Enum.Material.Wood)
		trunk.Orientation = Vector3.new(0, 0, 90 + side * 9)
		for frond = 1, 3 do
			local angle = frond * math.pi * 2 / 3
			local leaf = buildPart(world, "PalmFrond", Vector3.new(10, 0.65, 3), position + Vector3.new(math.cos(angle) * 2.4, 5, math.sin(angle) * 2.4), Color3.fromRGB(68, 155, 98), Enum.Material.Grass, Enum.PartType.Ball)
			leaf.Orientation = Vector3.new(0, math.deg(-angle), side * 8)
		end
	end
	for index = 1, 6 do
		local x = -65 + (index - 1) * 26
		buildCylinder(world, "BoardwalkLampPole", 0.35, 8, Vector3.new(x, 6.5, -15), INK, Enum.Material.Metal)
		local lamp = buildPart(world, "WarmLampGlobe", Vector3.new(1.15, 1.15, 1.15), Vector3.new(x, 10.65, -15), CREAM, Enum.Material.Neon, Enum.PartType.Ball)
		local light = Instance.new("PointLight")
		light.Color = CREAM
		light.Range = 13
		light.Brightness = 0.6
		light.Parent = lamp
	end
end

function WorldBuilder.BuildStripedShopStalls(world: Model)
	for index, rarity in Catalog.RarityOrder do
		local x = -54 + (index - 1) * 27
		local colour = Catalog.RarityColours[rarity]
		buildPart(world, "StallCounter", Vector3.new(18, 2, 3), Vector3.new(x, 3.5, -39), colour, Enum.Material.WoodPlanks)
		for side = -1, 1, 2 do
			buildPart(world, "AwningPost", Vector3.new(0.4, 7, 0.4), Vector3.new(x + side * 8.4, 6, -42), WOOD, Enum.Material.Wood)
		end
		for stripe = -1, 1 do
			buildPart(world, "StripedAwning", Vector3.new(6, 0.45, 7), Vector3.new(x + stripe * 6, 9.7, -40), if stripe == 0 then CREAM else colour, Enum.Material.Fabric)
		end
		buildSign(world, "StallRarity", string.upper(rarity), Vector3.new(12, 1.8, 0.4), Vector3.new(x, 7.7, -36.9), INK, colour)
	end
end

function WorldBuilder.BuildEggMachine(world: Model): { any }
	local machine = Instance.new("Model")
	machine.Name = "BrainrotEggMachine"
	machine.Parent = world
	buildCylinder(machine, "GumballPedestal", 8, 1, Vector3.new(-48, 3, 7), CREAM, Enum.Material.Marble)
	buildCylinder(machine, "GumballMachineBody", 5.2, 4, Vector3.new(-48, 5.4, 7), CORAL, Enum.Material.Metal)
	local globe = buildPart(machine, "ClearGumballGlobe", Vector3.new(8.5, 8.5, 8.5), Vector3.new(-48, 11.2, 7), Color3.fromRGB(177, 235, 255), Enum.Material.Glass, Enum.PartType.Ball)
	globe.Transparency = 0.55
	globe.CanCollide = false
	for index, rarity in Catalog.RarityOrder do
		local angle = index * math.pi * 2 / 5
		buildPart(machine, "RarityGumball", Vector3.new(2.8, 2.8, 2.8), Vector3.new(-48 + math.cos(angle) * 2, 10.5 + index % 2, 7 + math.sin(angle) * 2), Catalog.RarityColours[rarity], Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	end
	buildCylinder(machine, "MachineGoldLid", 6, 0.5, Vector3.new(-48, 15.4, 7), GOLD, Enum.Material.Metal)
	buildSign(world, "EggMachineSign", "BRAINROT EGGS\n10% GOLDEN  /  3% DIAMOND  /  0.5% VOID", Vector3.new(22, 4, 0.5), Vector3.new(-48, 18.4, 7), TEAL, CREAM)
	local buttons = {}
	for index, tier in Catalog.EggTiers do
		local x = -62 + (index - 1) * 7
		local button = buildCylinder(machine, "EggButton" .. tier.rarity, 4.2, 0.7, Vector3.new(x, 3.05, 17.5), Catalog.RarityColours[tier.rarity], Enum.Material.Neon)
		local label = buildFloatingLabel(button, string.upper(tier.rarity) .. "\n$" .. Catalog.FormatMoney(tier.price), Catalog.RarityColours[tier.rarity], 2.3)
		local prompt = buildPrompt(button, "Open $" .. Catalog.FormatMoney(tier.price), tier.rarity .. " egg")
		table.insert(buttons, { part = button, prompt = prompt, label = label, rarity = tier.rarity, price = tier.price })
	end
	return buttons
end

function WorldBuilder.BuildRebirthShrine(world: Model): any
	local shrine = Instance.new("Model")
	shrine.Name = "RebirthShrine"
	shrine.Parent = world
	local button = buildCylinder(shrine, "RebirthTouchPad", 9, 0.6, Vector3.new(48, 3.05, 7), GOLD, Enum.Material.Neon)
	for side = -1, 1, 2 do
		buildCylinder(shrine, "GoldenArchPillar", 1.5, 11, Vector3.new(48 + side * 5, 8.5, 7), GOLD, Enum.Material.Metal)
	end
	buildPart(shrine, "GoldenArchCrown", Vector3.new(12, 1.8, 2), Vector3.new(48, 14.2, 7), GOLD, Enum.Material.Metal)
	buildSign(world, "RebirthSign", "REBIRTH SHRINE\n$10,000 FIRST RUN  /  PERMANENT x1.5 INCOME", Vector3.new(26, 4, 0.5), Vector3.new(48, 18.2, 7), INK, GOLD)
	buildFloatingLabel(button, "REBIRTH\nResets cash + collection", GOLD, 3.1)
	return { part = button, prompt = buildPrompt(button, "Rebirth", "Permanent x1.5 income") }
end

function WorldBuilder.BuildPhotoSpotAndRarityLadder(world: Model)
	buildCylinder(world, "PhotoSpotPlatform", 14, 0.65, Vector3.new(0, 2.9, 5), CORAL, Enum.Material.Marble)
	buildSign(world, "PhotoSpotSign", "PHOTO SPOT\nFLEX YOUR WEIRDEST INVESTMENT", Vector3.new(21, 4, 0.5), Vector3.new(0, 10, 8.5), TEAL, CREAM)
	local board = buildPart(world, "RarityLadderBillboard", Vector3.new(18, 14, 0.7), Vector3.new(68, 11, -2), INK, Enum.Material.WoodPlanks)
	for _, face in { Enum.NormalId.Front, Enum.NormalId.Back } do
		local surface = Instance.new("SurfaceGui")
		surface.Face = face
		surface.CanvasSize = Vector2.new(600, 600)
		surface.Parent = board
		for index = 0, 5 do
			local label = Instance.new("TextLabel")
			label.Position = UDim2.new(0.04, 0, index / 6, 0)
			label.Size = UDim2.fromScale(0.92, 1 / 6)
			label.BackgroundTransparency = 1
			label.TextScaled = true
			label.Font = Enum.Font.GothamBlack
			if index == 0 then
				label.Text = "THE RARITY LADDER"
				label.TextColor3 = CREAM
			else
				local rarity = Catalog.RarityOrder[index]
				local band = Catalog.GetCharactersInBand(rarity)
				label.Text = string.upper(rarity) .. "  $" .. band[1].moneyPerSecond .. "-" .. band[#band].moneyPerSecond .. "/s"
				label.TextColor3 = Catalog.RarityColours[rarity]
			end
			label.Parent = surface
		end
	end
end

function WorldBuilder.BuildPlayerBase(world: Model, baseId: number, position: Vector3): any
	local base = Instance.new("Model")
	base.Name = "PlayerBase" .. baseId
	base.Parent = world
	local accent = if baseId % 2 == 0 then TEAL else CORAL
	buildPart(base, "BaseFloor", Vector3.new(46, 0.9, 32), position, Color3.fromRGB(218, 198, 158), Enum.Material.WoodPlanks)
	local safeBounds = buildPart(base, "SafeZoneBounds", Vector3.new(46, 40, 32), position + Vector3.new(0, 16, 0), accent)
	safeBounds.Transparency = 1
	safeBounds.CanCollide = false
	safeBounds.CanTouch = false
	safeBounds.CanQuery = false
	local dome = buildPart(base, "ShieldDome", Vector3.new(49, 37, 35), position, Color3.fromRGB(91, 224, 255), Enum.Material.ForceField, Enum.PartType.Ball)
	dome.Transparency = 1
	dome.CanCollide = false
	dome.CanTouch = false
	dome.CanQuery = false
	local back = if position.Z < 0 then -1 else 1
	local _, ownerLabels = buildSign(base, "OwnerSign", "AVAILABLE BASE " .. baseId, Vector3.new(29, 4.5, 0.6), position + Vector3.new(0, 5.7, back * 14.2), accent, CREAM)
	local lock = buildCylinder(base, "ShieldLockButton", 3.5, 0.65, position + Vector3.new(20, 0.8, -back * 12), TEAL, Enum.Material.Neon)
	local lockLabel = buildFloatingLabel(lock, "SHIELD $250\n60 seconds", CREAM, 2.5)
	local pads = {}
	for padIndex = 1, 8 do
		local column = (padIndex - 1) % 4
		local row = math.floor((padIndex - 1) / 4)
		local padPosition = position + Vector3.new(-16 + column * (32 / 3), 0.65, -6 + row * 12)
		local rim = buildCylinder(base, "PadRim" .. padIndex, 7, 0.24, padPosition, accent, Enum.Material.Neon)
		local pad = buildCylinder(base, "Pad" .. padIndex, 6.45, 0.3, padPosition + Vector3.new(0, 0.13, 0), CREAM, Enum.Material.Neon)
		local milestone = Catalog.PadMilestones[padIndex]
		local label = buildFloatingLabel(pad, if milestone == 0 then "PAD " .. padIndex .. "\nPLACE HERE" else "LOCKED - reach $" .. Catalog.FormatMoney(milestone), if milestone == 0 then CREAM else Color3.fromRGB(172, 169, 160), 1.8)
		local light = Instance.new("PointLight")
		light.Name = "FreePadGlow"
		light.Color = accent
		light.Brightness = 0.35
		light.Range = 6
		light.Enabled = milestone == 0
		light.Parent = pad
		table.insert(pads, { part = pad, rim = rim, label = label, light = light, milestone = milestone })
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "BaseSpawn"
	spawn.Size = Vector3.new(5, 0.2, 3)
	spawn.Position = position + Vector3.new(0, 0.65, -back * 13)
	spawn.Transparency = 1
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Enabled = false
	spawn.Parent = base
	return {
		id = baseId,
		model = base,
		position = position,
		safeBounds = safeBounds,
		dome = dome,
		ownerLabels = ownerLabels,
		lockButton = lock,
		lockLabel = lockLabel,
		lockPrompt = buildPrompt(lock, "Shield $250", "Protect this base for 60 seconds"),
		pads = pads,
		spawn = spawn,
	}
end

function WorldBuilder.BuildWorld(): any
	WorldBuilder.BuildGoldenHourLighting()
	local world = Instance.new("Model")
	world.Name = "BrainrotBazaar"
	world.Parent = workspace
	WorldBuilder.BuildIslandAndBoardwalk(world)
	WorldBuilder.BuildEntranceArch(world)
	WorldBuilder.BuildPalmsAndLampPosts(world)
	WorldBuilder.BuildStripedShopStalls(world)
	local eggButtons = WorldBuilder.BuildEggMachine(world)
	local shrine = WorldBuilder.BuildRebirthShrine(world)
	WorldBuilder.BuildPhotoSpotAndRarityLadder(world)
	local bases = {}
	for baseId = 1, 6 do
		local column = (baseId - 1) % 3
		local z = if baseId <= 3 then -64 else 57
		table.insert(bases, WorldBuilder.BuildPlayerBase(world, baseId, Vector3.new(-56 + column * 56, 2.2, z)))
	end
	local characters = Instance.new("Folder")
	characters.Name = "Brainrots"
	characters.Parent = world
	local events = Instance.new("Folder")
	events.Name = "Events"
	events.Parent = world
	return {
		model = world,
		characters = characters,
		events = events,
		bases = bases,
		eggButtons = eggButtons,
		shrine = shrine,
		laneStart = Vector3.new(-65, 3, -25),
		laneEnd = Vector3.new(65, 3, -25),
		waveStart = Vector3.new(-100, 12, -3),
		waveEnd = Vector3.new(100, 12, -3),
		seaEscape = Vector3.new(110, -0.5, 5),
	}
end

return WorldBuilder
