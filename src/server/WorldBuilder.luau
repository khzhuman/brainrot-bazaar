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

-- Added scenery never participates in movement, touches, raycasts, or interaction checks.
local function buildDressingPart(parent: Instance, name: string, size: Vector3, position: Vector3, colour: Color3, material: Enum.Material?, shape: Enum.PartType?): Part
	local part = buildPart(parent, name, size, position, colour, material, shape)
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	return part
end

local function buildDressingCylinder(parent: Instance, name: string, diameter: number, height: number, position: Vector3, colour: Color3, material: Enum.Material?): Part
	local part = buildDressingPart(parent, name, Vector3.new(height, diameter, diameter), position, colour, material, Enum.PartType.Cylinder)
	part.Orientation = Vector3.new(0, 0, 90)
	return part
end

local function buildDressingWedge(parent: Instance, name: string, size: Vector3, frame: CFrame, colour: Color3): WedgePart
	local part = Instance.new("WedgePart")
	part.Name = name
	part.Size = size
	part.CFrame = frame
	part.Color = colour
	part.Material = Enum.Material.Fabric
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function buildCrate(parent: Instance, position: Vector3, size: Vector3, yaw: number)
	local frame = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw), 0)
	local crate = buildDressingPart(parent, "BoardwalkSupplyCrate", size, position, WOOD, Enum.Material.WoodPlanks)
	crate.CFrame = frame
	for side = -1, 1, 2 do
		for edge = -1, 1, 2 do
			local upright = buildDressingPart(parent, "CrateUpright", Vector3.new(0.18, size.Y, 0.13), position, CREAM, Enum.Material.Wood)
			upright.CFrame = frame * CFrame.new(edge * (size.X / 2 - 0.16), 0, side * (size.Z / 2 + 0.04))
			local rail = buildDressingPart(parent, "CrateRail", Vector3.new(size.X, 0.18, 0.13), position, CREAM, Enum.Material.Wood)
			rail.CFrame = frame * CFrame.new(0, edge * (size.Y / 2 - 0.16), side * (size.Z / 2 + 0.04))
		end
		local brace = buildDressingPart(parent, "CrateDiagonalBrace", Vector3.new(0.16, math.sqrt(size.X ^ 2 + size.Y ^ 2) * 0.83, 0.12), position, Color3.fromRGB(139, 89, 58), Enum.Material.Wood)
		brace.CFrame = frame * CFrame.new(0, 0, side * (size.Z / 2 + 0.12)) * CFrame.Angles(0, 0, math.atan2(size.X, size.Y))
	end
end

local function buildBarrel(parent: Instance, position: Vector3)
	buildDressingCylinder(parent, "SeasideBarrel", 2.35, 3, position, Color3.fromRGB(146, 94, 58), Enum.Material.WoodPlanks)
	for _, height in { -1.05, 1.05 } do
		buildDressingCylinder(parent, "BarrelIronHoop", 2.43, 0.18, position + Vector3.new(0, height, 0), INK, Enum.Material.Metal)
	end
	buildDressingCylinder(parent, "BarrelLid", 2.16, 0.12, position + Vector3.new(0, 1.53, 0), WOOD, Enum.Material.WoodPlanks)
end

local function buildBeachUmbrella(parent: Instance, position: Vector3, colour: Color3)
	buildDressingCylinder(parent, "BeachUmbrellaFoot", 1.3, 0.2, position + Vector3.new(0, 0.1, 0), CREAM, Enum.Material.Marble)
	buildDressingCylinder(parent, "BeachUmbrellaPole", 0.18, 6.6, position + Vector3.new(0, 3.3, 0), CREAM, Enum.Material.Wood)
	buildDressingPart(parent, "BeachUmbrellaCanopy", Vector3.new(7.5, 1.25, 7.5), position + Vector3.new(0, 6.6, 0), colour, Enum.Material.Fabric, Enum.PartType.Ball)
	buildDressingPart(parent, "BeachUmbrellaFinial", Vector3.new(0.35, 0.5, 0.35), position + Vector3.new(0, 7.35, 0), CREAM, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
end

local function buildBaseFence(parent: Instance, position: Vector3, accent: Color3, back: number)
	local posts = {
		Vector3.new(-23, 0, -16), Vector3.new(23, 0, -16),
		Vector3.new(-23, 0, 16), Vector3.new(23, 0, 16),
		Vector3.new(-12, 0, back * 16), Vector3.new(0, 0, back * 16), Vector3.new(12, 0, back * 16),
		Vector3.new(-6, 0, -back * 16), Vector3.new(6, 0, -back * 16),
	}
	for _, z in { -8, 0, 8 } do
		table.insert(posts, Vector3.new(-23, 0, z))
		table.insert(posts, Vector3.new(23, 0, z))
	end
	for _, offset in posts do
		buildDressingPart(parent, "PlotFencePost", Vector3.new(0.48, 2.4, 0.48), position + offset + Vector3.new(0, 1.65, 0), CREAM, Enum.Material.Wood)
		buildDressingPart(parent, "PlotFenceCap", Vector3.new(0.62, 0.18, 0.62), position + offset + Vector3.new(0, 2.94, 0), accent, Enum.Material.Wood)
	end
	for _, height in { 1.15, 2.1 } do
		buildDressingPart(parent, "PlotBackFenceRail", Vector3.new(46, 0.22, 0.22), position + Vector3.new(0, height, back * 16), CREAM, Enum.Material.Wood)
		for side = -1, 1, 2 do
			buildDressingPart(parent, "PlotSideFenceRail", Vector3.new(0.22, 0.22, 32), position + Vector3.new(side * 23, height, 0), CREAM, Enum.Material.Wood)
			-- A twelve-stud opening frames the existing spawn and approach to the pads.
			buildDressingPart(parent, "PlotFrontFenceRail", Vector3.new(17, 0.22, 0.22), position + Vector3.new(side * 14.5, height, -back * 16), CREAM, Enum.Material.Wood)
		end
	end
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
	Lighting.ClockTime = 17.5
	Lighting.Brightness = 3.1
	Lighting.Ambient = Color3.fromRGB(167, 135, 119)
	Lighting.OutdoorAmbient = Color3.fromRGB(191, 158, 133)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 206, 149)
	Lighting.GlobalShadows = true
	Lighting.FogColor = Color3.fromRGB(244, 206, 169)
	Lighting.FogStart = 300
	Lighting.FogEnd = 1000
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "SeasideGoldenHour"
	atmosphere.Density = 0.18
	atmosphere.Color = Color3.fromRGB(255, 221, 186)
	atmosphere.Decay = Color3.fromRGB(255, 183, 139)
	atmosphere.Haze = 1.25
	atmosphere.Glare = 0.18
	atmosphere.Parent = Lighting
	local bloom = Instance.new("BloomEffect")
	bloom.Name = "LanternBloom"
	bloom.Intensity = 0.25
	bloom.Size = 24
	bloom.Threshold = 1.5
	bloom.Parent = Lighting
	local grade = Instance.new("ColorCorrectionEffect")
	grade.Name = "WarmBoardwalkGrade"
	grade.TintColor = Color3.fromRGB(255, 240, 220)
	grade.Brightness = 0.035
	grade.Contrast = 0.09
	grade.Saturation = 0.1
	grade.Parent = Lighting
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
	for index = 0, 70 do
		local x = -70 + index * 2
		local colour = if index % 2 == 0 then WOOD:Lerp(CREAM, 0.06) else WOOD:Lerp(INK, 0.07)
		buildDressingPart(world, "ParadeBoardwalkPlank", Vector3.new(1.93, 0.055, 17.5), Vector3.new(x, 2.91, -25), colour, Enum.Material.WoodPlanks)
		if index % 2 == 0 then
			for _, edge in { -8.15, 8.15 } do
				buildDressingCylinder(world, "BoardwalkPlankNail", 0.085, 0.025, Vector3.new(x, 2.952, -25 + edge), INK, Enum.Material.Metal)
			end
		end
	end
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
		light.Color = Color3.fromRGB(255, 221, 166)
		light.Range = 16
		light.Brightness = 0.9
		light.Parent = lamp
	end
	for index = 1, 6 do
		local position = Vector3.new(-65 + (index - 1) * 26, 2.95, -35.4)
		buildDressingCylinder(world, "ParadeLanternFoot", 1.1, 0.25, position, INK, Enum.Material.Metal)
		buildDressingCylinder(world, "ParadeLanternPole", 0.34, 8.4, position + Vector3.new(0, 4.2, 0), INK, Enum.Material.Metal)
		local lantern = buildDressingPart(world, "ParadeWarmLantern", Vector3.new(0.9, 1.15, 0.9), position + Vector3.new(0, 8.6, 0), Color3.fromRGB(255, 221, 166), Enum.Material.Neon)
		buildDressingPart(world, "ParadeLanternHood", Vector3.new(1.3, 0.22, 1.3), position + Vector3.new(0, 9.3, 0), INK, Enum.Material.Metal)
		for side = -1, 1, 2 do
			buildDressingPart(world, "ParadeLanternFrame", Vector3.new(0.08, 1.2, 1), position + Vector3.new(side * 0.47, 8.6, 0), INK, Enum.Material.Metal)
		end
		local light = Instance.new("PointLight")
		light.Color = lantern.Color
		light.Range = 18
		light.Brightness = 1.2
		light.Parent = lantern
	end
end

function WorldBuilder.BuildParadeBunting(world: Model)
	local colours = { CORAL, TEAL, GOLD, CREAM }
	for span, x in { -48, -16, 16, 48 } do
		for _, z in { -35.4, -14.6 } do
			buildDressingCylinder(world, "BuntingMast", 0.24, 16.3, Vector3.new(x, 11.05, z), WOOD, Enum.Material.Wood)
			buildDressingPart(world, "BuntingMastCap", Vector3.new(0.48, 0.48, 0.48), Vector3.new(x, 19.2, z), GOLD, Enum.Material.Metal, Enum.PartType.Ball)
		end
		local function ropePosition(fraction: number): Vector3
			return Vector3.new(x, 19.2 - math.sin(fraction * math.pi) * 1.45, -35.4 + fraction * 20.8)
		end
		for segment = 0, 11 do
			local a = ropePosition(segment / 12)
			local b = ropePosition((segment + 1) / 12)
			local cord = buildDressingPart(world, "BuntingCord", Vector3.new(0.065, 0.065, (b - a).Magnitude), (a + b) / 2, CREAM, Enum.Material.Fabric)
			cord.CFrame = CFrame.lookAt((a + b) / 2, b)
		end
		for flag = 1, 9 do
			local position = ropePosition(flag / 10) - Vector3.new(0, 0.65, 0)
			local colour = colours[(flag + span - 2) % #colours + 1]
			-- Opposed flat wedges meet at a downward tip to form each triangular pennant.
			buildDressingWedge(world, "TriangularBuntingFlag", Vector3.new(0.07, 1.3, 0.72), CFrame.new(position + Vector3.new(0, 0, -0.36)) * CFrame.Angles(0, 0, math.pi), colour)
			buildDressingWedge(world, "TriangularBuntingFlag", Vector3.new(0.07, 1.3, 0.72), CFrame.new(position + Vector3.new(0, 0, 0.36)) * CFrame.Angles(math.pi, 0, 0), colour)
		end
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
		buildCrate(world, Vector3.new(x + 10.3, 2.55, -41.4), Vector3.new(2.1, 2.1, 2.1), -8)
		buildCrate(world, Vector3.new(x + 10.3, 4.425, -41.4), Vector3.new(1.65, 1.65, 1.65), 7)
		buildCrate(world, Vector3.new(x + 12.8, 2.3, -42), Vector3.new(1.6, 1.6, 1.6), 12)
		buildBarrel(world, Vector3.new(x - 10.6, 3, -42.6))
		if index % 2 == 1 then
			buildBeachUmbrella(world, Vector3.new(x - 11.5, 1.5, -44.3), if index == 3 then TEAL else CORAL)
		end
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
	local header = buildSign(world, "EggMachineHeader", "EGG MACHINE", Vector3.new(27.5, 3.7, 0.45), Vector3.new(-48, 22.35, 7), INK, GOLD)
	header.CanCollide = false
	header.CanTouch = false
	header.CanQuery = false
	for _, face in header:GetChildren() do
		if face:IsA("SurfaceGui") then
			face.LightInfluence = 0
		end
	end
	for side = -1, 1, 2 do
		buildDressingPart(world, "EggMarqueeHorizontalTrim", Vector3.new(28.3, 0.2, 0.65), Vector3.new(-48, 22.35 + side * 2.05, 7), GOLD, Enum.Material.Metal)
		buildDressingPart(world, "EggMarqueeVerticalTrim", Vector3.new(0.2, 4.1, 0.65), Vector3.new(-48 + side * 14.05, 22.35, 7), GOLD, Enum.Material.Metal)
	end
	for index = 0, 10 do
		for _, height in { 20.3, 24.4 } do
			local bulb = buildDressingPart(world, "EggMarqueeBulb", Vector3.new(0.36, 0.36, 0.36), Vector3.new(-60.6 + index * 2.52, height, 6.6), CREAM, Enum.Material.Neon, Enum.PartType.Ball)
			if index % 5 == 0 then
				local light = Instance.new("PointLight")
				light.Color = Color3.fromRGB(255, 220, 150)
				light.Brightness = 0.65
				light.Range = 8
				light.Parent = bulb
			end
		end
	end
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
	local outerGlow = buildDressingCylinder(shrine, "ShrineSoftHalo", 13, 0.06, Vector3.new(48, 3.01, 7), GOLD, Enum.Material.Neon)
	outerGlow.Transparency = 0.78
	local innerGlow = buildDressingCylinder(shrine, "ShrineInnerHalo", 10.8, 0.07, Vector3.new(48, 3.06, 7), GOLD, Enum.Material.Neon)
	innerGlow.Transparency = 0.55
	local shrineLight = Instance.new("PointLight")
	shrineLight.Name = "ShrineWarmGlow"
	shrineLight.Color = Color3.fromRGB(255, 211, 121)
	shrineLight.Brightness = 0.9
	shrineLight.Range = 16
	shrineLight.Parent = button
	for side = -1, 1, 2 do
		buildCylinder(shrine, "GoldenArchPillar", 1.5, 11, Vector3.new(48 + side * 5, 8.5, 7), GOLD, Enum.Material.Metal)
	end
	local crown = buildPart(shrine, "GoldenArchCrown", Vector3.new(12, 1.8, 2), Vector3.new(48, 14.2, 7), GOLD, Enum.Material.Metal)
	local crownLight = Instance.new("PointLight")
	crownLight.Color = Color3.fromRGB(255, 221, 166)
	crownLight.Brightness = 0.65
	crownLight.Range = 12
	crownLight.Parent = crown
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
	buildBaseFence(base, position, accent, back)
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
	WorldBuilder.BuildParadeBunting(world)
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
