-- One job: build recognizable part-built creatures and their rarity and mutation labels.
local Catalog = require(game:GetService("ReplicatedStorage").Shared.CharacterCatalog)
local Factory = {}
local BLACK = Color3.fromRGB(30, 35, 48)
local WHITE = Color3.fromRGB(255, 251, 232)
local GOLD = Color3.fromRGB(255, 204, 67)
local UPRIGHT = CFrame.Angles(0, 0, math.pi / 2)
local LOOK_COLORS = {
	frog = Color3.fromRGB(245, 54, 61), banana = Color3.fromRGB(255, 222, 62),
	pigeon = Color3.fromRGB(145, 156, 166), capybara = Color3.fromRGB(172, 116, 73),
	cactus = Color3.fromRGB(48, 171, 91), shark = Color3.fromRGB(53, 145, 218),
	waffle = Color3.fromRGB(222, 169, 96), goose = GOLD,
	alpaca = Color3.fromRGB(250, 248, 240), dragon = Color3.fromRGB(64, 176, 99),
	manatee = Color3.fromRGB(48, 179, 181), crab = Color3.fromRGB(237, 57, 64),
}
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
function Factory.AddWedge(model: Model, name: string, size: Vector3, position: Vector3, color: Color3, rotation: CFrame?): WedgePart
	local part = Instance.new("WedgePart")
	part.Name = name; part.Size = size; part.CFrame = CFrame.new(position) * (rotation or CFrame.identity)
	part.Color = color; part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth; part.BottomSurface = Enum.SurfaceType.Smooth; part.Parent = model
	return part
end

-- Thin, shrinking cylinders make pointed cones without uploaded mesh assets.
function Factory.AddCone(model: Model, name: string, diameter: number, height: number, base: Vector3, color: Color3, steps: number, rotation: CFrame?): { Part }
	local parts = {}
	local frame = CFrame.new(base) * (rotation or CFrame.identity)
	for index = 1, steps do
		local width = diameter * (1 - (index - 0.5) / steps)
		local position = frame:PointToWorldSpace(Vector3.new(0, (index - 0.5) * height / steps, 0))
		local part = Factory.AddPart(model, name, Vector3.new(height / steps, width, width), position, color, Enum.PartType.Cylinder, frame.Rotation * UPRIGHT)
		table.insert(parts, part)
	end
	return parts
end

function Factory.BuildSignatureAccessory(model: Model, id: string)
	local function part(name, size, position, color, shape, rotation)
		return Factory.AddPart(model, name, size, position, color, shape, rotation)
	end
	local function cylinder(name, diameter, height, position, color, material)
		local result = part(name, Vector3.new(height, diameter, diameter), position, color, Enum.PartType.Cylinder, UPRIGHT)
		result.Material = material or Enum.Material.SmoothPlastic
		return result
	end
	if id == "frog" then
		cylinder("SpringFoot", 1.65, 0.16, Vector3.new(0, 0.1, 0), BLACK, Enum.Material.Metal)
		cylinder("SpringCore", 0.16, 0.9, Vector3.new(0, 0.6, 0), WHITE, Enum.Material.Metal)
		for index = 1, 5 do
			cylinder("SpringCoil", 1.1, 0.08, Vector3.new(0, 0.2 + index * 0.17, 0), Color3.fromRGB(192, 206, 221), Enum.Material.Metal)
		end
	elseif id == "banana" then
		part("BananaStem", Vector3.new(0.25, 0.4, 0.3), Vector3.new(-0.2, 3.45, 0), Color3.fromRGB(107, 77, 34), nil, CFrame.Angles(0, 0, 0.3))
		part("UmbrellaPole", Vector3.new(0.09, 0.95, 0.09), Vector3.new(0.45, 3.85, 0.08), WHITE)
		part("UmbrellaCanopy", Vector3.new(1.85, 0.45, 1.85), Vector3.new(0.45, 4.25, 0.08), WHITE, Enum.PartType.Ball)
		for index = 1, 6 do
			local angle = index * math.pi / 3
			local panel = Factory.AddWedge(model, "UmbrellaPanel", Vector3.new(0.72, 0.28, 0.8), Vector3.new(0.45 + math.sin(angle) * 0.44, 4.22, 0.08 + math.cos(angle) * 0.44), if index % 2 == 0 then Color3.fromRGB(255, 94, 112) else WHITE, CFrame.Angles(0, angle, 0))
			panel.Material = Enum.Material.Fabric
		end
		part("UmbrellaTip", Vector3.new(0.16, 0.22, 0.16), Vector3.new(0.45, 4.52, 0.08), GOLD, Enum.PartType.Ball)
	elseif id == "pigeon" then
		local green = Color3.fromRGB(38, 148, 80)
		part("VisorCap", Vector3.new(1.55, 0.48, 1.4), Vector3.new(0, 3.48, -0.12), green, Enum.PartType.Ball)
		part("VisorBrim", Vector3.new(1.85, 0.14, 1), Vector3.new(0, 3.34, -0.65), green)
		part("Briefcase", Vector3.new(1, 1, 0.4), Vector3.new(1.55, 1.25, -0.15), Color3.fromRGB(105, 65, 39))
		part("CaseHandle", Vector3.new(0.55, 0.15, 0.25), Vector3.new(1.55, 1.85, -0.15), BLACK)
		part("CaseLatch", Vector3.new(0.18, 0.25, 0.08), Vector3.new(1.55, 1.3, -0.39), GOLD)
	elseif id == "capybara" then
		cylinder("CoffeeCup", 1.15, 0.8, Vector3.new(0, 3.72, -0.1), WHITE)
		cylinder("Coffee", 0.98, 0.08, Vector3.new(0, 4.14, -0.1), Color3.fromRGB(91, 53, 30))
		part("CupHandle", Vector3.new(0.12, 0.6, 0.14), Vector3.new(0.86, 3.75, -0.1), WHITE)
		for _, y in { 3.5, 4 } do part("HandleJoin", Vector3.new(0.35, 0.12, 0.14), Vector3.new(0.7, y, -0.1), WHITE) end
		for index = 1, 2 do
			local steam = part("Steam", Vector3.new(0.16, 0.45, 0.16), Vector3.new(-0.35 + index * 0.3, 4.45 + index * 0.12, -0.1), WHITE, Enum.PartType.Ball)
			steam.Transparency = 0.45
		end
	elseif id == "cactus" then
		part("DiscoPole", Vector3.new(0.12, 0.75, 0.12), Vector3.new(0, 3.45, 0), BLACK)
		local ball = part("MirrorBall", Vector3.new(1.4, 1.4, 1.4), Vector3.new(0, 4.1, 0), Color3.fromRGB(194, 236, 255), Enum.PartType.Ball)
		ball.Material = Enum.Material.Metal; ball.Reflectance = 0.35
		for i = 1, 8 do
			local angle = i * math.pi / 4
			local tile = part("MirrorTile", Vector3.new(0.33, 0.33, 0.1), Vector3.new(math.sin(angle) * 0.69, 4.1, math.cos(angle) * 0.69), if i % 2 == 0 then GOLD else WHITE, nil, CFrame.Angles(0, angle, 0))
			tile.Material = Enum.Material.Neon
		end
		for _, x in { -0.95, 0.95 } do
			part("Sparkle", Vector3.new(0.1, 0.45, 0.1), Vector3.new(x, 4.4, 0), WHITE).Material = Enum.Material.Neon
			part("Sparkle", Vector3.new(0.45, 0.1, 0.1), Vector3.new(x, 4.4, 0), WHITE).Material = Enum.Material.Neon
		end
	elseif id == "shark" then
		for _, x in { -0.75, 0.75 } do
			part("Sneaker", Vector3.new(1.15, 0.55, 1.65), Vector3.new(x, 0.35, -0.35), Color3.fromRGB(238, 49, 65))
			part("Sole", Vector3.new(1.18, 0.17, 1.72), Vector3.new(x, 0.1, -0.35), WHITE)
			part("ToeCap", Vector3.new(1.17, 0.22, 0.35), Vector3.new(x, 0.35, -1.02), WHITE)
			for index = 1, 3 do part("Lace", Vector3.new(0.75, 0.07, 0.09), Vector3.new(x, 0.65, -0.9 + index * 0.22), WHITE) end
		end
	elseif id == "waffle" then
		cylinder("WizardBrim", 3, 0.14, Vector3.new(0, 3.17, 0), GOLD)
		Factory.AddCone(model, "WizardHat", 2.1, 1.62, Vector3.new(0, 3.24, 0), Color3.fromRGB(105, 52, 192), 10)
		for _, angle in { 0, math.pi / 4 } do
			part("HatStar", Vector3.new(0.35, 0.35, 0.09), Vector3.new(0, 3.65, -0.86), GOLD, nil, CFrame.Angles(0, 0, angle))
		end
	elseif id == "goose" then
		cylinder("HatBrim", 2.05, 0.16, Vector3.new(0, 3.64, -0.25), BLACK)
		cylinder("TopHat", 1.5, 0.9, Vector3.new(0, 4.05, -0.25), BLACK)
		cylinder("HatRibbon", 1.53, 0.13, Vector3.new(0, 3.75, -0.25), GOLD, Enum.Material.Metal)
		for index = 1, 8 do
			local angle = index * math.pi / 4
			part("MonocleRing", Vector3.new(0.24, 0.08, 0.07), Vector3.new(0.32 + math.sin(angle) * 0.29, 3.17 + math.cos(angle) * 0.29, -1.16), GOLD, nil, CFrame.Angles(0, 0, -angle)).Material = Enum.Material.Metal
		end
		for index = 1, 3 do part("MonocleChain", Vector3.new(0.05, 0.2, 0.05), Vector3.new(0.65, 2.93 - index * 0.16, -1.05), GOLD).Material = Enum.Material.Metal end
	elseif id == "alpaca" then
		local helmet = part("AstronautHelmet", Vector3.new(2.8, 2.8, 2.8), Vector3.new(0, 3.3, -0.05), Color3.fromRGB(210, 247, 255), Enum.PartType.Ball)
		helmet.Material = Enum.Material.Glass
		helmet.Transparency = 0.5; helmet.Reflectance = 0.07; helmet.CastShadow = false
		cylinder("HelmetCollar", 2, 0.22, Vector3.new(0, 2.2, 0), WHITE, Enum.Material.Metal)
		part("SpacePack", Vector3.new(1.1, 1.3, 0.5), Vector3.new(0, 1.7, 1.1), WHITE)
	elseif id == "dragon" then
		for index = 1, 6 do
			cylinder("DividendCoin", 0.78, 0.14, Vector3.new(1.9, 0.09 + (index - 1) * 0.15, -1.05), GOLD, Enum.Material.Metal)
		end
		cylinder("LooseCoin", 0.78, 0.14, Vector3.new(2.55, 0.1, -0.65), GOLD, Enum.Material.Metal)
	elseif id == "manatee" then
		part("MoonPole", Vector3.new(0.09, 2.8, 0.09), Vector3.new(0.8, 2.6, 1.1), Color3.fromRGB(161, 215, 223))
		part("Moon", Vector3.new(1.25, 1.25, 1.25), Vector3.new(0.8, 4.2, 1.1), Color3.fromRGB(255, 250, 202), Enum.PartType.Ball).Material = Enum.Material.Neon
		local glow = Instance.new("PointLight")
		glow.Name = "Moonlight"; glow.Color = Color3.fromRGB(128, 202, 255)
		glow.Range = 5; glow.Brightness = 0.6; glow.Shadows = false; glow.Parent = model.Body
	elseif id == "crab" then
		cylinder("CrownBand", 2.3, 0.24, Vector3.new(0, 2.91, -0.15), GOLD, Enum.Material.Metal)
		for index = 1, 6 do
			local angle = index * math.pi / 3
			for _, spike in Factory.AddCone(model, "CrownSpike", 0.4, 0.8, Vector3.new(math.sin(angle) * 0.84, 3.03, -0.15 + math.cos(angle) * 0.84), GOLD, 5) do spike.Material = Enum.Material.Metal end
		end
		local bag = part("MoneyBag", Vector3.new(1.05, 1.4, 0.65), Vector3.new(1.7, 0.85, -1.3), Color3.fromRGB(42, 155, 78))
		part("BagKnot", Vector3.new(0.45, 0.3, 0.45), Vector3.new(1.7, 1.65, -1.3), Color3.fromRGB(42, 155, 78))
		part("BagTie", Vector3.new(0.65, 0.12, 0.68), Vector3.new(1.7, 1.55, -1.3), GOLD)
		local gui = Instance.new("SurfaceGui")
		gui.Name = "PaintedDollar"; gui.Face = Enum.NormalId.Front; gui.CanvasSize = Vector2.new(128, 160); gui.Parent = bag
		local symbol = Instance.new("TextLabel")
		symbol.Name = "Dollar"; symbol.Size = UDim2.fromScale(1, 1); symbol.BackgroundTransparency = 1
		symbol.Font = Enum.Font.GothamBlack; symbol.Text = "$"; symbol.TextScaled = true; symbol.TextColor3 = GOLD; symbol.Parent = gui
	end
end
function Factory.BuildBody(model: Model, character)
	local color = LOOK_COLORS[character.id] or character.bodyColor
	local bodyParts = {}
	local function body(name, size, position, tint, shape, rotation)
		local part = Factory.AddPart(model, name, size, position, tint or color, shape or Enum.PartType.Ball, rotation)
		if character.id == "goose" then part.Material = Enum.Material.Metal; part.Reflectance = 0.18 end
		table.insert(bodyParts, part)
		return part
	end
	local function cylinder(name, diameter, height, position, tint, rotation)
		return body(name, Vector3.new(height, diameter, diameter), position, tint, Enum.PartType.Cylinder, (rotation or CFrame.identity) * UPRIGHT)
	end
	local function wedge(name, size, position, tint, rotation)
		local part = Factory.AddWedge(model, name, size, position, tint or color, rotation)
		if character.id == "goose" then part.Material = Enum.Material.Metal end
		table.insert(bodyParts, part)
		return part
	end
	local face, spacing, eyeSize = Vector3.new(0, 2.8, -1), 0.46, 0.5
	if character.id == "frog" then
		body("Body", Vector3.new(2.6, 2.6, 2.6), Vector3.new(0, 2.2, 0))
		face, spacing, eyeSize = Vector3.new(0, 2.6, -1.12), 0.57, 0.85
	elseif character.id == "banana" then
		cylinder("Body", 1.05, 1.8, Vector3.new(-0.2, 1.15, 0), nil, CFrame.Angles(0, 0, -0.25))
		wedge("BananaCurve", Vector3.new(0.95, 1.6, 0.9), Vector3.new(0.2, 2.15, 0), nil, CFrame.Angles(0, 0, -0.35) * CFrame.Angles(0, math.pi / 2, 0))
		wedge("BananaTip", Vector3.new(0.75, 1.1, 0.8), Vector3.new(0.05, 2.95, 0), nil, CFrame.Angles(0, 0, 0.45) * CFrame.Angles(0, math.pi / 2, 0))
		face, spacing, eyeSize = Vector3.new(0.15, 2.2, -0.5), 0.26, 0.4
	elseif character.id == "pigeon" then
		body("Body", Vector3.new(2.2, 2.4, 1.8), Vector3.new(0, 1.5, 0))
		body("Head", Vector3.new(1.55, 1.4, 1.45), Vector3.new(0, 2.8, -0.12))
		body("WhiteChest", Vector3.new(1.4, 1.45, 0.25), Vector3.new(0, 1.4, -0.84), WHITE)
		wedge("Beak", Vector3.new(0.6, 0.32, 0.65), Vector3.new(0, 2.57, -1), Color3.fromRGB(246, 170, 65))
		for _, side in { -1, 1 } do
			body("Wing", Vector3.new(0.5, 1.6, 1.3), Vector3.new(side * 1.05, 1.4, 0.1), nil, nil, CFrame.Angles(0, 0, side * 0.2))
			body("Foot", Vector3.new(0.6, 0.2, 0.9), Vector3.new(side * 0.52, 0.16, -0.35), GOLD, Enum.PartType.Block)
		end
		face, spacing, eyeSize = Vector3.new(0, 2.95, -0.8), 0.36, 0.44
	elseif character.id == "capybara" then
		body("Body", Vector3.new(1.8, 1.5, 1.7), Vector3.new(0, 1.25, 0), nil, Enum.PartType.Block)
		for _, side in { -1, 1 } do
			body("RoundedHaunch", Vector3.new(1, 1.5, 1.7), Vector3.new(side * 0.85, 1.25, 0))
			body("Ear", Vector3.new(0.45, 0.5, 0.35), Vector3.new(side * 0.72, 3.12, -0.12))
			for _, z in { -0.55, 0.55 } do body("Foot", Vector3.new(0.65, 0.7, 0.8), Vector3.new(side * 0.72, 0.38, z)) end
		end
		body("Head", Vector3.new(1.9, 1.4, 1.5), Vector3.new(0, 2.55, -0.2))
		body("Muzzle", Vector3.new(1.45, 0.75, 0.8), Vector3.new(0, 2.32, -1), Color3.fromRGB(206, 152, 102))
		for _, x in { -0.27, 0.27 } do Factory.AddPart(model, "Nostril", Vector3.new(0.14, 0.12, 0.08), Vector3.new(x, 2.38, -1.42), BLACK, Enum.PartType.Ball) end
		face, spacing, eyeSize = Vector3.new(0, 2.8, -0.91), 0.49, 0.48
	elseif character.id == "cactus" then
		cylinder("Body", 1.6, 2.8, Vector3.new(0, 1.6, 0))
		body("Head", Vector3.new(1.6, 0.7, 1.6), Vector3.new(0, 2.98, 0))
		for _, side in { -1, 1 } do
			cylinder("CactusElbow", 0.6, 1.2, Vector3.new(side * 1.05, 1.3, 0), nil, CFrame.Angles(0, 0, math.pi / 2))
			cylinder("CactusArm", 0.65, 1.8, Vector3.new(side * 1.45, 2, 0))
		end
		for index = 1, 6 do Factory.AddPart(model, "CactusSpine", Vector3.new(0.08, 0.25, 0.14), Vector3.new(-0.45 + ((index - 1) % 3) * 0.45, 0.9 + math.floor((index - 1) / 3) * 0.65, -0.8), WHITE) end
		face, spacing, eyeSize = Vector3.new(0, 2.55, -0.78), 0.37, 0.5
	elseif character.id == "shark" then
		body("Body", Vector3.new(2.6, 2.1, 1.9), Vector3.new(0, 1.75, 0))
		body("Head", Vector3.new(2.2, 1.6, 1.8), Vector3.new(0, 2.75, -0.25))
		body("SharkBelly", Vector3.new(1.8, 1.7, 0.3), Vector3.new(0, 1.75, -0.88), WHITE)
		wedge("DorsalFin", Vector3.new(0.35, 1.6, 1.3), Vector3.new(0, 3, 0.85))
		for _, side in { -1, 1 } do
			wedge("SideFin", Vector3.new(0.4, 0.65, 1.1), Vector3.new(side * 1.35, 1.7, 0.15), nil, CFrame.Angles(0, 0, side * math.pi / 3))
			body("Ankle", Vector3.new(0.6, 0.45, 0.6), Vector3.new(side * 0.75, 0.68, -0.25))
		end
		Factory.AddPart(model, "Mouth", Vector3.new(1, 0.3, 0.12), Vector3.new(0, 2.44, -1.14), BLACK)
		for index = -1, 1 do Factory.AddWedge(model, "SharkTooth", Vector3.new(0.18, 0.23, 0.13), Vector3.new(index * 0.28, 2.46, -1.23), WHITE, CFrame.Angles(0, 0, math.pi)) end
		face, spacing, eyeSize = Vector3.new(0, 2.96, -1.08), 0.53, 0.5
	elseif character.id == "waffle" then
		body("Body", Vector3.new(2.5, 2.5, 0.8), Vector3.new(0, 1.75, 0), nil, Enum.PartType.Block)
		for index = 0, 3 do
			body("WaffleGroove", Vector3.new(0.075, 2.34, 0.08), Vector3.new(-0.85 + index * 0.57, 1.75, -0.44), Color3.fromRGB(176, 120, 59), Enum.PartType.Block)
			body("WaffleGroove", Vector3.new(2.34, 0.075, 0.08), Vector3.new(0, 0.9 + index * 0.57, -0.44), Color3.fromRGB(176, 120, 59), Enum.PartType.Block)
		end
		for _, side in { -1, 1 } do
			body("Arm", Vector3.new(0.4, 1.2, 0.55), Vector3.new(side * 1.4, 1.6, 0), nil, Enum.PartType.Block, CFrame.Angles(0, 0, side * 0.15))
			body("Foot", Vector3.new(0.7, 0.45, 0.85), Vector3.new(side * 0.7, 0.28, -0.1), nil, Enum.PartType.Block)
		end
		face, spacing, eyeSize = Vector3.new(0, 2.2, -0.57), 0.52, 0.48
	elseif character.id == "goose" then
		body("Body", Vector3.new(2.35, 1.95, 1.8), Vector3.new(0, 1.2, 0))
		cylinder("GooseNeck", 0.9, 1.45, Vector3.new(0, 2.25, -0.2))
		body("Head", Vector3.new(1.4, 1.2, 1.4), Vector3.new(0, 3.05, -0.35))
		wedge("Beak", Vector3.new(0.62, 0.35, 0.65), Vector3.new(0, 2.9, -1.15), Color3.fromRGB(255, 177, 48))
		for _, side in { -1, 1 } do
			body("Wing", Vector3.new(0.65, 1.45, 1.4), Vector3.new(side * 1.08, 1.35, 0.2))
			wedge("Foot", Vector3.new(0.7, 0.2, 0.9), Vector3.new(side * 0.62, 0.13, -0.4))
		end
		face, spacing, eyeSize = Vector3.new(0, 3.17, -0.99), 0.32, 0.38
	elseif character.id == "alpaca" then
		body("Body", Vector3.new(2.4, 1.7, 1.8), Vector3.new(0, 1.3, 0))
		for index = 1, 6 do
			local angle = index * math.pi / 3
			body("Fluff", Vector3.new(0.95, 1.15, 0.95), Vector3.new(math.sin(angle) * 0.9, 1.4 + (index % 2) * 0.15, math.cos(angle) * 0.65))
		end
		cylinder("AlpacaNeck", 0.85, 1.7, Vector3.new(0, 2.3, 0.03))
		body("Head", Vector3.new(1.35, 1.2, 1.2), Vector3.new(0, 3.1, -0.2))
		body("Muzzle", Vector3.new(0.9, 0.55, 0.55), Vector3.new(0, 2.92, -0.75), Color3.fromRGB(230, 212, 190))
		for _, side in { -1, 1 } do
			body("Ear", Vector3.new(0.3, 0.75, 0.3), Vector3.new(side * 0.44, 3.94, 0))
			for _, z in { -0.5, 0.5 } do body("Foot", Vector3.new(0.55, 0.65, 0.55), Vector3.new(side * 0.6, 0.35, z)) end
		end
		face, spacing, eyeSize = Vector3.new(0, 3.22, -0.78), 0.33, 0.38
	elseif character.id == "dragon" then
		body("Body", Vector3.new(2.5, 2, 1.95), Vector3.new(0, 1.45, 0))
		body("Head", Vector3.new(1.9, 1.5, 1.8), Vector3.new(0, 2.7, -0.35))
		body("Muzzle", Vector3.new(1.8, 0.65, 1.1), Vector3.new(0, 2.4, -1), Color3.fromRGB(95, 196, 113))
		body("DragonBelly", Vector3.new(1.45, 1.5, 0.3), Vector3.new(0, 1.3, -0.89), Color3.fromRGB(178, 224, 129))
		for _, side in { -1, 1 } do
			wedge("DragonWing", Vector3.new(0.25, 2.1, 2.5), Vector3.new(side * 1.75, 2.1, 0.65), Color3.fromRGB(44, 144, 83), CFrame.Angles(0, 0, -side * 0.25) * CFrame.Angles(0, side * math.pi / 2, 0))
			for _, horn in Factory.AddCone(model, "DragonHorn", 0.42, 0.72, Vector3.new(side * 0.6, 3.26, -0.15), WHITE, 6, CFrame.Angles(0, 0, -side * 0.2)) do table.insert(bodyParts, horn) end
			body("Foot", Vector3.new(0.9, 0.55, 1.25), Vector3.new(side * 0.78, 0.3, -0.25))
		end
		cylinder("DragonTail", 0.65, 2.4, Vector3.new(0, 1, 1.5), nil, CFrame.Angles(math.pi / 2, 0, 0))
		wedge("TailFin", Vector3.new(0.55, 0.75, 0.9), Vector3.new(0, 1.35, 2.5))
		face, spacing, eyeSize = Vector3.new(0, 2.97, -1.04), 0.54, 0.52
	elseif character.id == "manatee" then
		body("Body", Vector3.new(3.1, 2.1, 2.3), Vector3.new(0, 1.4, 0))
		body("Head", Vector3.new(2, 1.5, 1.65), Vector3.new(0, 2.3, -0.45))
		body("Muzzle", Vector3.new(1.4, 0.6, 0.4), Vector3.new(0, 2.08, -1.2), Color3.fromRGB(116, 219, 211))
		for _, side in { -1, 1 } do body("ManateeFlipper", Vector3.new(1.25, 0.4, 1.1), Vector3.new(side * 1.6, 1.1, 0.15), nil, nil, CFrame.Angles(0, 0, -side * 0.2)) end
		cylinder("TailStem", 0.65, 1.2, Vector3.new(0, 0.9, 1.2), nil, CFrame.Angles(math.pi / 2, 0, 0))
		wedge("MermaidTail", Vector3.new(2.3, 0.4, 1.4), Vector3.new(0, 0.75, 1.7), Color3.fromRGB(111, 222, 211))
		face, spacing, eyeSize = Vector3.new(0, 2.53, -1.15), 0.54, 0.55
	elseif character.id == "crab" then
		body("Body", Vector3.new(4, 1.8, 2.4), Vector3.new(0, 1.35, 0))
		body("Head", Vector3.new(2.4, 0.95, 1.9), Vector3.new(0, 2.35, -0.15))
		body("ShellPatch", Vector3.new(3.2, 1.05, 0.3), Vector3.new(0, 1.45, -1.15), Color3.fromRGB(255, 103, 76))
		for _, side in { -1, 1 } do
			cylinder("EyeStalk", 0.22, 0.6, Vector3.new(side * 0.67, 2.54, -0.65))
			cylinder("ClawArm", 0.55, 1.65, Vector3.new(side * 2, 1.9, -0.05), nil, CFrame.Angles(0, 0, -side * 0.75))
			body("CrabClaw", Vector3.new(1.65, 1.55, 1.6), Vector3.new(side * 2.65, 2.9, -0.2))
			wedge("ClawTip", Vector3.new(0.58, 1, 0.65), Vector3.new(side * 2.3, 3.6, -0.7), nil, CFrame.Angles(0, 0, -side * 0.25))
			wedge("ClawTip", Vector3.new(0.58, 1, 0.65), Vector3.new(side * 3.03, 3.6, -0.7), nil, CFrame.Angles(0, 0, side * 0.25))
			for index = 1, 3 do body("CrabLeg", Vector3.new(1.5, 0.22, 0.3), Vector3.new(side * 2, 0.42, -0.6 + index * 0.6), nil, Enum.PartType.Block, CFrame.Angles(0, side * 0.2, -side * 0.16)) end
		end
		face, spacing, eyeSize = Vector3.new(0, 2.82, -1.05), 0.67, 0.65
	end
	for _, side in { -1, 1 } do
		local eye = face + Vector3.new(side * spacing, 0, 0)
		Factory.AddPart(model, "Eye", Vector3.new(eyeSize, eyeSize * 1.1, 0.25), eye, WHITE, Enum.PartType.Ball)
		Factory.AddPart(model, "Pupil", Vector3.new(eyeSize * 0.43, eyeSize * 0.55, 0.13), eye + Vector3.new(0, -0.02, -0.17), BLACK, Enum.PartType.Ball)
	end
	if character.id ~= "shark" then Factory.AddPart(model, "Smile", Vector3.new(spacing * 1.1, 0.1, 0.1), face + Vector3.new(0, -0.45, -0.06), BLACK) end
	return bodyParts
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
	local bodyParts = Factory.BuildBody(model, character)
	Factory.BuildSignatureAccessory(model, character.id)
	model:ScaleTo(0.85 + Catalog.GetRarityIndex(character.rarity) * 0.12)
	if mutation ~= "Normal" then
		local highlight = Instance.new("Highlight")
		highlight.Name = "MutationGlow"; highlight.FillColor = Catalog.Mutations[mutation].color
		highlight.FillTransparency = 0.63; highlight.OutlineColor = Catalog.Mutations[mutation].color
		highlight.OutlineTransparency = 0.15; highlight.Parent = model
		for _, part in bodyParts do
			part.Color = if mutation == "Golden" then GOLD elseif mutation == "Diamond" then Color3.fromRGB(183, 244, 255) else Color3.fromRGB(31, 18, 45)
			part.Material = if mutation == "Golden" then Enum.Material.Metal elseif mutation == "Diamond" then Enum.Material.Glass else Enum.Material.SmoothPlastic
			part.Transparency = if mutation == "Diamond" then 0.25 else 0
		end
		if mutation == "Void" then
			local scale = model:GetScale()
			for _, side in { -1, 1 } do
				local accent = Factory.AddPart(model, "VoidAccent", Vector3.new(0.13, 0.7, 0.12) * scale, model.Body.Position + Vector3.new(side * model.Body.Size.X * 0.33, -0.1 * scale, -model.Body.Size.Z * 0.47), Catalog.Mutations.Void.color, nil, CFrame.Angles(0, 0, side * 0.3))
				accent.Material = Enum.Material.Neon
			end
		end
	end
	Factory.BuildLabel(model, character, mutation)
	model:SetAttribute("CatalogId", id); model:SetAttribute("Mutation", mutation)
	model:PivotTo(CFrame.identity); model.Parent = parent
	return model
end
return Factory
