-- One job: build the sunny island, landmarks, shop lane, and six complete player bases at server startup.
local Lighting = game:GetService("Lighting")
local Catalog = require(game:GetService("ReplicatedStorage").Shared.CharacterCatalog)
local WorldBuilder = {}
local WOOD = Color3.fromRGB(185, 131, 82)
local CREAM = Color3.fromRGB(255, 245, 215)
local INK = Color3.fromRGB(38, 60, 72)
local GOLD = Color3.fromRGB(255, 203, 65)
local AQUA = Color3.fromRGB(83, 223, 212)

function WorldBuilder.AddPart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?, shape: Enum.PartType?): Part
	local part = Instance.new("Part")
	part.Name = name; part.Size = size; part.Position = position; part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic; part.Shape = shape or Enum.PartType.Block
	part.Anchored = true; part.TopSurface = Enum.SurfaceType.Smooth; part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

function WorldBuilder.AddCylinder(parent: Instance, name: string, diameter: number, height: number, position: Vector3, color: Color3, material: Enum.Material?): Part
	local part = WorldBuilder.AddPart(parent, name, Vector3.new(height, diameter, diameter), position, color, material, Enum.PartType.Cylinder)
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.pi / 2)
	return part
end

-- Dressing never supplies collision, touch targets, or raycast targets.
function WorldBuilder.AddDecoration(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?, shape: Enum.PartType?, rotation: CFrame?): Part
	local part = WorldBuilder.AddPart(parent, name, size, position, color, material, shape)
	part.CFrame = CFrame.new(position) * (rotation or CFrame.identity)
	part.CanCollide = false; part.CanTouch = false; part.CanQuery = false; part.CastShadow = false
	return part
end

function WorldBuilder.DressIncomePad(pad: Part, rim: Part, prompt: ProximityPrompt)
	rim.Material = Enum.Material.Metal; rim.Reflectance = 0.12; rim.CastShadow = false
	local glow = Instance.new("PointLight")
	glow.Name = "FreePadGlow"; glow.Range = 5; glow.Brightness = 0.35; glow.Shadows = false; glow.Parent = pad
	local function refreshAppearance()
		-- The existing prompt already says whether this pad is free and unlocked.
		glow.Enabled = prompt.Enabled; glow.Color = pad.Color
		rim.Color = pad.Color:Lerp(CREAM, 0.65)
	end
	prompt:GetPropertyChangedSignal("Enabled"):Connect(refreshAppearance)
	pad:GetPropertyChangedSignal("Color"):Connect(refreshAppearance)
	refreshAppearance()
end

function WorldBuilder.AddBillboard(part: BasePart, name: string, text: string, color: Color3, width: number, height: number, offset: number): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = name; gui.Adornee = part; gui.Size = UDim2.fromOffset(width, height)
	gui.StudsOffsetWorldSpace = Vector3.new(0, offset, 0); gui.AlwaysOnTop = true; gui.MaxDistance = 110; gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Name = "Text"; label.Size = UDim2.fromScale(1, 1); label.BackgroundColor3 = INK
	label.BackgroundTransparency = 0.15; label.TextColor3 = color; label.Font = Enum.Font.GothamBold
	label.TextSize = 18; label.TextWrapped = true; label.Text = text; label.Parent = gui
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 10); corner.Parent = label
	return label
end

function WorldBuilder.AddSurfaceText(part: BasePart, text: string, color: Color3, face: Enum.NormalId?): TextLabel
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignFace"; gui.Face = face or Enum.NormalId.Front; gui.CanvasSize = Vector2.new(1000, 300); gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Name = "Text"; label.Size = UDim2.fromScale(1, 1); label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack; label.TextColor3 = color; label.TextScaled = true
	label.TextWrapped = true; label.Text = text; label.Parent = gui
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 12); padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 18); padding.PaddingRight = UDim.new(0, 18); padding.Parent = label
	return label
end

function WorldBuilder.AddPrompt(part: BasePart, action: string, object: string): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = action; prompt.ObjectText = object; prompt.MaxActivationDistance = 9
	prompt.RequiresLineOfSight = false; prompt.HoldDuration = 0.15; prompt.Parent = part
	return prompt
end

function WorldBuilder.BuildGoldenHour()
	Lighting.ClockTime = 17.1; Lighting.Brightness = 2.6
	Lighting.Ambient = Color3.fromRGB(156, 127, 104); Lighting.OutdoorAmbient = Color3.fromRGB(195, 170, 143)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 208, 151)
	Lighting.FogColor = Color3.fromRGB(174, 221, 228); Lighting.FogStart = 350; Lighting.FogEnd = 1400
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.22; atmosphere.Offset = 0.15; atmosphere.Color = Color3.fromRGB(237, 219, 189)
	atmosphere.Decay = Color3.fromRGB(167, 199, 219); atmosphere.Glare = 0.25; atmosphere.Haze = 1; atmosphere.Parent = Lighting
	local bloom = Instance.new("BloomEffect"); bloom.Intensity = 0.22; bloom.Size = 20; bloom.Threshold = 1.4; bloom.Parent = Lighting
	local grading = Instance.new("ColorCorrectionEffect")
	grading.Saturation = 0.13; grading.Contrast = 0.06; grading.TintColor = Color3.fromRGB(255, 241, 222); grading.Parent = Lighting
end

function WorldBuilder.BuildBoardwalkAndPlaza(world)
	WorldBuilder.AddPart(world.Model, "SandIsland", Vector3.new(244, 3.8, 224), Vector3.new(0, 1.9, 0), Color3.fromRGB(244, 216, 165), Enum.Material.Sand)
	WorldBuilder.AddPart(world.Model, "StonePlaza", Vector3.new(100, 1, 176), Vector3.new(0, 4.3, 0), CREAM, Enum.Material.Slate)
	for _, z in { -98, 98 } do
		WorldBuilder.AddPart(world.Model, "BoardwalkRing", Vector3.new(220, 1, 12), Vector3.new(0, 4.3, z), WOOD, Enum.Material.WoodPlanks)
	end
	for _, x in { -104, 104 } do
		WorldBuilder.AddPart(world.Model, "BoardwalkRing", Vector3.new(12, 1, 184), Vector3.new(x, 4.3, 0), WOOD, Enum.Material.WoodPlanks)
	end
	for z = -90, 90, 10 do
		for _, x in { -110, 110 } do
			WorldBuilder.AddPart(world.Model, "SeasidePost", Vector3.new(0.8, 4, 0.8), Vector3.new(x, 6.3, z), CREAM, Enum.Material.Wood)
		end
	end
	for _, x in { -110, 110 } do
		WorldBuilder.AddPart(world.Model, "BoardwalkRailing", Vector3.new(0.45, 0.45, 182), Vector3.new(x, 7.8, 0), WOOD, Enum.Material.Wood)
	end
	for _, x in { -46, 46 } do
		for z = -72, 72, 24 do
			WorldBuilder.AddPart(world.Model, "PlazaInlay", Vector3.new(2, 0.04, 12), Vector3.new(x, 4.82, z), AQUA, Enum.Material.Neon).CanCollide = false
		end
	end
	world.Sea = WorldBuilder.AddPart(world.Model, "Sea", Vector3.new(1600, 1.2, 1600), Vector3.new(0, 1, 0), Color3.fromRGB(46, 178, 197), Enum.Material.Glass)
	world.Sea.Transparency = 0.32; world.Sea.Reflectance = 0.15; world.Sea.CanCollide = false; world.Sea.CanTouch = false
	world.PublicSpawn = Instance.new("SpawnLocation")
	world.PublicSpawn.Name = "PlazaSpawn"; world.PublicSpawn.Size = Vector3.new(6, 0.4, 6)
	world.PublicSpawn.Position = Vector3.new(16, 5, -78); world.PublicSpawn.Anchored = true
	world.PublicSpawn.Transparency = 1; world.PublicSpawn.CanCollide = false
	world.PublicSpawn.Neutral = true; world.PublicSpawn.Duration = 0; world.PublicSpawn.Parent = world.Model
end

function WorldBuilder.BuildShopStalls(world)
	local stalls = Instance.new("Model"); stalls.Name = "StripedShopStalls"; stalls.Parent = world.Model
	for _, side in { -1, 1 } do
		local stripeColor = if side < 0 then Color3.fromRGB(245, 113, 128) else AQUA
		for _, z in { -22, 0, 22 } do
			for _, offset in { -5, 5 } do
				WorldBuilder.AddDecoration(stalls, "StallPost", Vector3.new(0.45, 8, 0.45), Vector3.new(side * 26, 8.9, z + offset), WOOD, Enum.Material.Wood)
			end
			WorldBuilder.AddDecoration(stalls, "AwningBeam", Vector3.new(0.3, 0.3, 12), Vector3.new(side * 26, 12.8, z), WOOD, Enum.Material.Wood)
			WorldBuilder.AddDecoration(stalls, "StallCounter", Vector3.new(3.4, 2.7, 10), Vector3.new(side * 21, 6.5, z), stripeColor, Enum.Material.WoodPlanks)
			WorldBuilder.AddDecoration(stalls, "CounterTop", Vector3.new(3.7, 0.2, 10.4), Vector3.new(side * 21, 7.95, z), CREAM, Enum.Material.Wood)
			for index = 1, 6 do
				local color = if index % 2 == 0 then CREAM else stripeColor
				local stripeZ = z - 5 + (index - 1) * 2
				WorldBuilder.AddDecoration(stalls, "AwningStripe", Vector3.new(8, 0.22, 2), Vector3.new(side * 22, 12.3, stripeZ), color, Enum.Material.Fabric, nil, CFrame.Angles(0, 0, side * 0.12))
				WorldBuilder.AddDecoration(stalls, "StripedValance", Vector3.new(0.2, 0.75, 2), Vector3.new(side * 18.03, 11.6, stripeZ), color, Enum.Material.Fabric)
			end
		end
	end
end

function WorldBuilder.BuildLaneLamps(world)
	local lamps = Instance.new("Model"); lamps.Name = "BoardwalkLamps"; lamps.Parent = world.Model
	local upright = CFrame.Angles(0, 0, math.pi / 2)
	for _, x in { -12, 12 } do
		for _, z in { -63, -21, 21, 63 } do
			WorldBuilder.AddDecoration(lamps, "LampFoot", Vector3.new(0.25, 1.5, 1.5), Vector3.new(x, 5.1, z), INK, Enum.Material.Metal, Enum.PartType.Cylinder, upright)
			WorldBuilder.AddDecoration(lamps, "LampPole", Vector3.new(7.8, 0.28, 0.28), Vector3.new(x, 9, z), INK, Enum.Material.Metal, Enum.PartType.Cylinder, upright)
			local bulb = WorldBuilder.AddDecoration(lamps, "LampGlobe", Vector3.new(1.3, 1.3, 1.3), Vector3.new(x, 13.4, z), CREAM, Enum.Material.Neon, Enum.PartType.Ball)
			WorldBuilder.AddDecoration(lamps, "LampCap", Vector3.new(0.12, 1.65, 1.65), Vector3.new(x, 14.06, z), GOLD, Enum.Material.Metal, Enum.PartType.Cylinder, upright)
			local light = Instance.new("PointLight")
			light.Name = "WarmLaneLight"; light.Color = Color3.fromRGB(255, 222, 170)
			light.Brightness = 0.65; light.Range = 11; light.Shadows = false; light.Parent = bulb
		end
	end
end

function WorldBuilder.BuildShopLane(world)
	WorldBuilder.AddPart(world.Model, "ShopLane", Vector3.new(16, 0.3, 158), Vector3.new(0, 4.95, 0), Color3.fromRGB(244, 165, 129), Enum.Material.WoodPlanks)
	for _, x in { -8.2, 8.2 } do
		local strip = WorldBuilder.AddPart(world.Model, "ParadeLightStrip", Vector3.new(0.3, 0.18, 158), Vector3.new(x, 5.15, 0), GOLD, Enum.Material.Neon)
		strip.CanCollide = false
	end
	for z = -66, 66, 22 do
		local arrow = WorldBuilder.AddPart(world.Model, "ParadeArrow", Vector3.new(2, 0.05, 2), Vector3.new(0, 5.13, z), CREAM)
		arrow.CFrame *= CFrame.Angles(0, math.pi / 4, 0); arrow.CanCollide = false
	end
	local sign = WorldBuilder.AddPart(world.Model, "ShopLaneSign", Vector3.new(18, 3, 0.8), Vector3.new(0, 11, -81), INK)
	WorldBuilder.AddSurfaceText(sign, "THE BRAINROT PARADE\nTOUCH TO BUY", GOLD)
	WorldBuilder.AddSurfaceText(sign, "THE BRAINROT PARADE\nTOUCH TO BUY", GOLD, Enum.NormalId.Back)
	WorldBuilder.BuildShopStalls(world)
	WorldBuilder.BuildLaneLamps(world)
	world.LaneStart = Vector3.new(0, 5.3, -73); world.LaneEnd = Vector3.new(0, 5.3, 73)
	world.LaneDirection = (world.LaneEnd - world.LaneStart).Unit; world.LaneLength = (world.LaneEnd - world.LaneStart).Magnitude
	world.WaveStart = Vector3.new(0, 17, -104); world.WaveEnd = Vector3.new(0, 17, 104)
end

function WorldBuilder.BuildEggMachine(world)
	local machine = Instance.new("Model"); machine.Name = "GumballEggMachine"; machine.Parent = world.Model
	WorldBuilder.AddCylinder(machine, "MachinePlinth", 12, 1, Vector3.new(30, 5.3, -48), INK)
	WorldBuilder.AddCylinder(machine, "MachineBody", 7, 6, Vector3.new(30, 8.6, -48), Color3.fromRGB(243, 104, 116), Enum.Material.Metal)
	local globe = WorldBuilder.AddPart(machine, "GumballGlobe", Vector3.new(10, 10, 10), Vector3.new(30, 15, -48), Color3.fromRGB(174, 232, 249), Enum.Material.Glass, Enum.PartType.Ball)
	globe.Transparency = 0.65; globe.CanCollide = false
	WorldBuilder.AddCylinder(machine, "GlobeLid", 8, 0.8, Vector3.new(30, 19.5, -48), GOLD, Enum.Material.Metal)
	WorldBuilder.AddPart(machine, "PrizeChute", Vector3.new(3, 2, 0.4), Vector3.new(30, 7, -51.6), INK)
	for index = 1, 18 do
		local angle = index * 2.4
		WorldBuilder.AddPart(machine, "GumballEgg", Vector3.new(1.8, 2.2, 1.8), Vector3.new(30 + math.sin(angle) * 2.7, 12.2 + (index % 4) * 1.2, -48 + math.cos(angle) * 2.7), Catalog.RarityColors[Catalog.RarityOrder[(index % 5) + 1]], nil, Enum.PartType.Ball).CanCollide = false
	end
	WorldBuilder.AddBillboard(globe, "MachineLabel", "GUMBALL BRAINROT EGGS\nPick a rarity below!", CREAM, 275, 55, 7)
	world.EggButtons = {}
	for index, band in Catalog.EggBands do
		local button = WorldBuilder.AddCylinder(machine, "EggButton" .. index, 4, 1, Vector3.new(19, 5.5, -70 + (index - 1) * 10), band.color, Enum.Material.Neon)
		local label = WorldBuilder.AddBillboard(button, "TierPrice", band.name .. "\n$" .. Catalog.FormatMoney(band.price), band.color, 150, 46, 2.5)
		label.TextSize = 14; label.Parent.MaxDistance = 50
		local prompt = WorldBuilder.AddPrompt(button, "Hatch $" .. Catalog.FormatMoney(band.price), band.name)
		world.EggButtons[index] = { Part = button, Prompt = prompt }
	end
end

function WorldBuilder.BuildRebirthShrine(world)
	local shrine = Instance.new("Model"); shrine.Name = "RebirthShrine"; shrine.Parent = world.Model
	WorldBuilder.AddCylinder(shrine, "ShrinePlatform", 16, 0.8, Vector3.new(-28, 5.2, 40), Color3.fromRGB(233, 215, 179), Enum.Material.Marble)
	for _, x in { -34, -22 } do
		WorldBuilder.AddPart(shrine, "GoldenArchPillar", Vector3.new(2, 13, 2), Vector3.new(x, 11.7, 40), GOLD, Enum.Material.Metal)
		WorldBuilder.AddPart(shrine, "ArchCapital", Vector3.new(3, 1, 3), Vector3.new(x, 17.8, 40), CREAM, Enum.Material.Marble)
	end
	WorldBuilder.AddPart(shrine, "GoldenArchTop", Vector3.new(15, 2, 2.5), Vector3.new(-28, 18.5, 40), GOLD, Enum.Material.Metal)
	for index = -2, 2 do
		WorldBuilder.AddPart(shrine, "ArchCrownPoint", Vector3.new(1, 2, 1), Vector3.new(-28 + index * 2, 20.3, 40), GOLD, Enum.Material.Neon)
	end
	world.RebirthAltar = WorldBuilder.AddCylinder(shrine, "RebirthTouchAltar", 5, 0.7, Vector3.new(-28, 5.95, 39), GOLD, Enum.Material.Neon)
	world.RebirthPrompt = WorldBuilder.AddPrompt(world.RebirthAltar, "Rebirth", "Reset collection • permanent x1.5")
	WorldBuilder.AddBillboard(world.RebirthAltar, "ShrineLabel", "REBIRTH SHRINE\nStarts at $10,000 • cost x5 each time\nReset your run. Income x1.5 forever.", GOLD, 285, 76, 6)
end

function WorldBuilder.BuildPhotoSpotAndEntrance(world)
	local photo = WorldBuilder.AddPart(world.Model, "PhotoSpotPlatform", Vector3.new(24, 1, 10), Vector3.new(0, 5.3, 98), Color3.fromRGB(243, 146, 153), Enum.Material.WoodPlanks)
	local photoSign = WorldBuilder.AddPart(world.Model, "PhotoSpotSign", Vector3.new(22, 4, 0.6), Vector3.new(0, 12, 103), INK)
	WorldBuilder.AddSurfaceText(photoSign, "PHOTO SPOT\nSHOW OFF YOUR BRAINROT!", CREAM)
	for _, x in { -10, 10 } do
		WorldBuilder.AddPart(world.Model, "PhotoFramePost", Vector3.new(1, 8, 1), Vector3.new(x, 9.5, 103), GOLD)
	end
	WorldBuilder.AddBillboard(photo, "PhotoHint", "PHOTO SPOT", CREAM, 170, 30, 1)
	for _, x in { -27, 27 } do
		WorldBuilder.AddPart(world.Model, "EntrancePost", Vector3.new(2, 20, 2), Vector3.new(x, 13.3, -98), WOOD, Enum.Material.Wood)
	end
	local entrance = WorldBuilder.AddPart(world.Model, "BrainrotBazaarEntranceSign", Vector3.new(58, 8, 1.2), Vector3.new(0, 22, -98), INK)
	WorldBuilder.AddSurfaceText(entrance, "BRAINROT BAZAAR\nBUY • CARRY • CASH IN", GOLD)
	WorldBuilder.AddSurfaceText(entrance, "BRAINROT BAZAAR\nSUNSHINE & PASSIVE INCOME", GOLD, Enum.NormalId.Back)
	WorldBuilder.AddDecoration(world.Model, "EntranceArchTopTrim", Vector3.new(59, 0.45, 1.8), Vector3.new(0, 26.2, -98), GOLD, Enum.Material.Metal)
	WorldBuilder.AddDecoration(world.Model, "EntranceArchBottomTrim", Vector3.new(59, 0.4, 1.8), Vector3.new(0, 18, -98), GOLD, Enum.Material.Metal)
	for _, side in { -1, 1 } do
		WorldBuilder.AddDecoration(world.Model, "EntranceArchSideTrim", Vector3.new(0.45, 8, 1.8), Vector3.new(side * 29.2, 22, -98), GOLD, Enum.Material.Metal)
		WorldBuilder.AddDecoration(world.Model, "EntrancePostCap", Vector3.new(2.8, 0.35, 2.8), Vector3.new(side * 27, 23.45, -98), CREAM, Enum.Material.Marble)
		WorldBuilder.AddDecoration(world.Model, "EntranceArchBrace", Vector3.new(6, 0.5, 0.6), Vector3.new(side * 24.8, 17.7, -98), GOLD, Enum.Material.Metal, nil, CFrame.Angles(0, 0, side * math.pi / 4))
	end
	local ladder = WorldBuilder.AddPart(world.Model, "RarityLadderBillboard", Vector3.new(16, 17, 1), Vector3.new(-29, 13.3, -52), INK)
	local gui = Instance.new("SurfaceGui"); gui.Name = "RarityLadder"; gui.CanvasSize = Vector2.new(540, 650); gui.Parent = ladder
	for index = 0, 5 do
		local label = Instance.new("TextLabel")
		label.Name = if index == 0 then "Title" else Catalog.RarityOrder[index]
		label.Position = UDim2.fromOffset(12, 14 + index * 102); label.Size = UDim2.new(1, -24, 0, 95)
		label.BackgroundTransparency = 1; label.Font = Enum.Font.GothamBlack; label.TextSize = if index == 0 then 32 else 35
		label.TextColor3 = if index == 0 then CREAM else Catalog.RarityColors[Catalog.RarityOrder[index]]
		label.Text = if index == 0 then "THE RARITY LADDER" else tostring(index) .. "  " .. Catalog.RarityOrder[index]:upper()
		label.Parent = gui
	end
	ladder.CFrame *= CFrame.Angles(0, math.pi / 2, 0)
	WorldBuilder.AddBillboard(ladder, "MutationGuide", "MUTATIONS\nGOLDEN x5 • DIAMOND x10 • VOID x25", GOLD, 270, 58, 11)
end

function WorldBuilder.BuildPalmTree(parent: Instance, position: Vector3, index: number)
	local tree = Instance.new("Model"); tree.Name = "PalmTree" .. index; tree.Parent = parent
	WorldBuilder.AddDecoration(tree, "PalmTrunk", Vector3.new(12, 1.35, 1.35), position + Vector3.new(0.9, 6, 0), Color3.fromRGB(139, 89, 52), Enum.Material.Wood, Enum.PartType.Cylinder, CFrame.Angles(0, 0, math.pi / 2 - 0.14))
	local crown = position + Vector3.new(1.8, 12, 0)
	for leafIndex = 1, 6 do
		local angle = leafIndex * math.pi / 3
		WorldBuilder.AddDecoration(tree, "PalmFrond", Vector3.new(2.4, 0.48, 8.5), crown + Vector3.new(math.sin(angle) * 3, -0.4, math.cos(angle) * 3), if leafIndex % 2 == 0 then Color3.fromRGB(51, 158, 93) else Color3.fromRGB(81, 181, 107), Enum.Material.Grass, Enum.PartType.Ball, CFrame.Angles(0, angle, 0) * CFrame.Angles(0.22, 0, 0))
	end
	for nut = 1, 2 do
		WorldBuilder.AddDecoration(tree, "Coconut", Vector3.new(1.1, 1.1, 1.1), crown + Vector3.new(nut * 0.65 - 1, -0.65, 0), Color3.fromRGB(109, 78, 48), nil, Enum.PartType.Ball)
	end
end

function WorldBuilder.BuildPlayerBase(world, baseId: number, position: Vector3)
	local model = Instance.new("Model"); model.Name = "PlayerBase" .. baseId; model.Parent = world.Model
	local floor = WorldBuilder.AddPart(model, "BaseFloor", Vector3.new(44, 1, 40), position, Color3.fromRGB(196, 226, 210), Enum.Material.WoodPlanks)
	local side = if position.X < 0 then -1 else 1
	local sign = WorldBuilder.AddPart(model, "OwnerSign", Vector3.new(0.8, 5, 27), position + Vector3.new(side * 20, 5, 0), INK)
	local ownerLabel = WorldBuilder.AddBillboard(sign, "OwnerLabel", "BASE " .. baseId .. "\nAVAILABLE", CREAM, 250, 65, 4)
	local safe = WorldBuilder.AddPart(model, "SafeZoneBounds", Vector3.new(44, 36, 40), position + Vector3.new(0, 17, 0), AQUA)
	safe.Transparency = 1; safe.CanCollide = false; safe.CanTouch = false; safe.CanQuery = false
	local dome = WorldBuilder.AddPart(model, "ShieldDome", Vector3.new(47, 44, 43), position + Vector3.new(0, 0.5, 0), AQUA, Enum.Material.ForceField, Enum.PartType.Ball)
	dome.Transparency = 1; dome.CanCollide = false; dome.CanTouch = false; dome.CanQuery = false
	local lock = WorldBuilder.AddCylinder(model, "LockButton", 4, 1.1, position + Vector3.new(-side * 17, 1, -15), GOLD, Enum.Material.Neon)
	local lockLabel = WorldBuilder.AddBillboard(lock, "LockLabel", "SHIELD\n$250 • 60 sec", GOLD, 160, 48, 3)
	lockLabel.TextSize = 15
	local lockPrompt = WorldBuilder.AddPrompt(lock, "Lock for $250", "Shield dome • 60 seconds")
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "OwnerSpawn"; spawn.Size = Vector3.new(6, 0.3, 6); spawn.Anchored = true
	spawn.CFrame = CFrame.lookAt(position + Vector3.new(-side * 15, 0.7, 2), Vector3.new(0, position.Y + 0.7, position.Z + 2))
	spawn.Transparency = 1; spawn.CanCollide = false; spawn.Neutral = true; spawn.Duration = 0; spawn.Parent = model
	local crown = Instance.new("Model"); crown.Name = "RebirthCrown"; crown.Parent = model
	local crownCenter = position + Vector3.new(side * 20, 9, 0)
	WorldBuilder.AddPart(crown, "CrownBand", Vector3.new(1, 0.8, 6), crownCenter, GOLD, Enum.Material.Metal).Transparency = 1
	for point = -1, 1 do
		WorldBuilder.AddPart(crown, "CrownPoint", Vector3.new(1, 2, 0.8), crownCenter + Vector3.new(0, 1, point * 2), GOLD, Enum.Material.Neon).Transparency = 1
	end
	local base = { Id = baseId, Model = model, Floor = floor, SafeBounds = safe, Dome = dome, OwnerLabel = ownerLabel, Crown = crown, LockButton = lock, LockLabel = lockLabel, LockPrompt = lockPrompt, Spawn = spawn, Pads = {} }
	for index = 1, 8 do
		local row = math.floor((index - 1) / 4)
		local column = (index - 1) % 4
		local padPosition = position + Vector3.new((row * 2 - 1) * 7, 0.9, -13.5 + column * 9)
		local rim = WorldBuilder.AddCylinder(model, "PadRim" .. index, 7.2, 0.14, padPosition - Vector3.new(0, 0.2, 0), CREAM)
		local pad = WorldBuilder.AddCylinder(model, "IncomePad" .. index, 6.4, 0.5, padPosition, AQUA, Enum.Material.Neon)
		local label = WorldBuilder.AddBillboard(pad, "PadLabel", "PAD " .. index, CREAM, 190, 40, 0.5)
		label.TextSize = 13; label.Parent.MaxDistance = 55
		local prompt = WorldBuilder.AddPrompt(pad, "Place carried brainrot", "Income pad " .. index)
		WorldBuilder.DressIncomePad(pad, rim, prompt)
		base.Pads[index] = { Part = pad, Label = label, Prompt = prompt }
	end
	world.Bases[baseId] = base
end

function WorldBuilder.BuildWorld()
	WorldBuilder.BuildGoldenHour()
	local model = Instance.new("Model"); model.Name = "BrainrotBazaar"; model.Parent = workspace
	local characters = Instance.new("Folder"); characters.Name = "Characters"; characters.Parent = model
	local world = { Model = model, Characters = characters, Bases = {} }
	WorldBuilder.BuildBoardwalkAndPlaza(world)
	WorldBuilder.BuildShopLane(world)
	WorldBuilder.BuildEggMachine(world)
	WorldBuilder.BuildRebirthShrine(world)
	WorldBuilder.BuildPhotoSpotAndEntrance(world)
	for index = 1, 6 do
		local x = if index <= 3 then -76 else 76
		local z = -56 + ((index - 1) % 3) * 56
		WorldBuilder.BuildPlayerBase(world, index, Vector3.new(x, 4.3, z))
	end
	for index, position in {
		Vector3.new(-118, 3.8, -86), Vector3.new(118, 3.8, -86), Vector3.new(-118, 3.8, 82), Vector3.new(118, 3.8, 82),
		Vector3.new(-118, 3.8, 0), Vector3.new(118, 3.8, 0), Vector3.new(-43, 3.8, 89), Vector3.new(43, 3.8, 89),
		Vector3.new(-43, 3.8, -89), Vector3.new(43, 3.8, -89),
	} do
		WorldBuilder.BuildPalmTree(model, position, index)
	end
	return world
end

return WorldBuilder
