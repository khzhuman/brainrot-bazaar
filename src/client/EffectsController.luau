-- One job: render server-announced feedback and local, noninteractive collection displays.
--!strict

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterCatalog"))
local HudController = require(script.Parent:WaitForChild("HudController"))

local EffectsController = {}

type DisplayPart = { part: BasePart, offset: CFrame }
type BaseDisplay = {
	root: BasePart,
	pad: BasePart,
	plinth: Model,
	parts: { DisplayPart },
	lift: number,
	phase: number,
}

local function buildDisplayCylinder(parent: Model, name: string, diameter: number, height: number, position: Vector3, colour: Color3, material: Enum.Material): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(height, diameter, diameter)
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.pi / 2)
	part.Color = colour
	part.Material = material
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function isStandingOnPad(root: BasePart, pad: BasePart): boolean
	-- Read the already-replicated placement pose. Parade and recovery roots can touch;
	-- carried characters sit several studs higher. No gameplay attributes are added.
	return not root.CanTouch and (root.Position - pad.Position - Vector3.new(0, 0.25, 0)).Magnitude < 0.12
end

local function buildBaseDisplay(model: Model, root: BasePart, pad: BasePart, parent: Folder, id: string): BaseDisplay?
	local parts: { DisplayPart } = {}
	local lowest = math.huge
	for _, child in model:GetChildren() do
		if child:IsA("BasePart") and child ~= root and not child.CanCollide and not child.CanTouch and not child.CanQuery then
			local offset = root.CFrame:ToObjectSpace(child.CFrame)
			local halfHeight = (math.abs(offset.RightVector.Y) * child.Size.X + math.abs(offset.UpVector.Y) * child.Size.Y + math.abs(offset.LookVector.Y) * child.Size.Z) / 2
			lowest = math.min(lowest, offset.Position.Y - halfHeight)
			table.insert(parts, { part = child, offset = offset })
		end
	end
	if #parts == 0 then
		return nil
	end
	local definition = Catalog.GetCharacter(id)
	local colour = Catalog.RarityColours[definition.rarity]
	local plinth = Instance.new("Model")
	plinth.Name = "LocalRarityPlinth"
	plinth.Parent = parent
	local padTop = pad.Position.Y + pad.Size.X / 2
	local centre = Vector3.new(pad.Position.X, padTop, pad.Position.Z)
	buildDisplayCylinder(plinth, "PlinthBody", 6.2, 0.4, centre + Vector3.new(0, 0.2, 0), Color3.fromRGB(24, 39, 48), Enum.Material.Slate)
	local trim = buildDisplayCylinder(plinth, "RarityTrimRing", 6.34, 0.11, centre + Vector3.new(0, 0.36, 0), colour, Enum.Material.Neon)
	buildDisplayCylinder(plinth, "PlinthInsetCap", 6, 0.12, centre + Vector3.new(0, 0.39, 0), Color3.fromRGB(39, 55, 64), Enum.Material.Marble)
	if Catalog.GetRarityIndex(definition.rarity) >= Catalog.GetRarityIndex("Epic") then
		local light = Instance.new("PointLight")
		light.Name = "RarityDisplayGlow"
		light.Color = colour
		light.Brightness = 0.8
		light.Range = 9
		light.Parent = trim
	end
	return {
		root = root,
		pad = pad,
		plinth = plinth,
		parts = parts,
		lift = padTop + 0.45 - root.Position.Y - lowest,
		phase = pad.Position.X * 0.13 + pad.Position.Z * 0.11,
	}
end

local function startBaseDisplays()
	local world = workspace:WaitForChild("BrainrotBazaar")
	local characters = world:WaitForChild("Brainrots")
	local folder = Instance.new("Folder")
	folder.Name = "LocalBaseDisplays"
	folder.Parent = workspace
	local pads: { BasePart } = {}
	local displays: { [Model]: BaseDisplay } = {}
	local candidates: { [Model]: BasePart } = {}
	local function rememberPad(instance: Instance)
		local base = instance.Parent
		if instance:IsA("BasePart") and string.match(instance.Name, "^Pad[1-8]$") and base and string.match(base.Name, "^PlayerBase%d+$") then
			table.insert(pads, instance)
		end
	end
	for _, descendant in world:GetDescendants() do
		rememberPad(descendant)
	end
	world.DescendantAdded:Connect(rememberPad)
	local function removeDisplay(model: Model)
		local display = displays[model]
		candidates[model] = nil
		if not display then
			return
		end
		displays[model] = nil
		display.plinth:Destroy()
		if model.Parent and display.root.Parent == model then
			for _, entry in display.parts do
				if entry.part.Parent == model then
					entry.part.CFrame = display.root.CFrame * entry.offset
				end
			end
		end
	end
	characters.ChildRemoved:Connect(function(instance: Instance)
		if instance:IsA("Model") then
			removeDisplay(instance)
		end
	end)
	local scanElapsed = 0
	RunService.RenderStepped:Connect(function(deltaTime: number)
		scanElapsed += deltaTime
		if scanElapsed >= 0.2 then
			scanElapsed = 0
			for _, model in characters:GetChildren() do
				if not model:IsA("Model") or displays[model] then
					continue
				end
				local root = model.PrimaryPart
				local id = model:GetAttribute("CatalogId")
				local matchedPad: BasePart? = nil
				if root and not root.CanTouch and typeof(id) == "string" then
					for _, pad in pads do
						if pad:IsDescendantOf(world) and isStandingOnPad(root, pad) then
							matchedPad = pad
							break
						end
					end
				end
				if matchedPad and root and typeof(id) == "string" and candidates[model] == matchedPad then
					-- Two observations let the server's root and accessory poses arrive together.
					displays[model] = buildBaseDisplay(model, root, matchedPad, folder, id)
					candidates[model] = nil
				else
					candidates[model] = matchedPad
				end
			end
		end
		local now = os.clock()
		for model, display in displays do
			if model.Parent ~= characters or display.root ~= model.PrimaryPart or not display.pad:IsDescendantOf(world) or not isStandingOnPad(display.root, display.pad) then
				removeDisplay(model)
				continue
			end
			local bob = (math.sin(now * 1.55 + display.phase) + 1) * 0.045
			local frame = display.root.CFrame + Vector3.new(0, display.lift + bob, 0)
			-- Only noninteractive visual parts move locally. The server pivot, hitbox,
			-- pad, labels, and every interaction position remain exactly where they were.
			for _, entry in display.parts do
				if entry.part.Parent == model then
					entry.part.CFrame = frame * entry.offset
				end
			end
		end
	end)
end

function EffectsController.ShowFloatingText(position: Vector3, text: string, colour: Color3, kind: string)
	local anchor = Instance.new("Part")
	anchor.Name = "LocalFloatingText"
	anchor.Size = Vector3.new(0.1, 0.1, 0.1)
	anchor.Position = position
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.Parent = workspace
	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = anchor
	billboard.Size = if kind == "income" then UDim2.fromOffset(145, 40) else UDim2.fromOffset(330, 70)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 150
	billboard.Parent = anchor
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = colour
	label.TextStrokeColor3 = Color3.fromRGB(24, 42, 57)
	label.TextStrokeTransparency = 0.2
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = billboard
	local duration = if kind == "income" then 1.15 else 2.2
	TweenService:Create(anchor, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = position + Vector3.new(0, 3.5, 0) }):Play()
	TweenService:Create(label, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(anchor, duration + 0.1)
end

function EffectsController.ShowEventBanner(hud: HudController.Hud, text: string, duration: number)
	local generation = (hud.banner:GetAttribute("DisplayGeneration") or 0) + 1
	hud.banner:SetAttribute("DisplayGeneration", generation)
	hud.bannerText.Text = text
	hud.banner.Visible = true
	hud.banner.BackgroundColor3 = if string.find(text, "TSUNAMI", 1, true) then Color3.fromRGB(45, 140, 180) elseif string.find(text, "RACCOON", 1, true) then Color3.fromRGB(193, 81, 99) else Color3.fromRGB(39, 145, 126)
	task.delay(duration, function()
		if hud.banner.Parent and hud.banner:GetAttribute("DisplayGeneration") == generation then
			hud.banner.Visible = false
		end
	end)
end

function EffectsController.ShowScreenFeedback(hud: HudController.Hud, kind: string)
	if kind == "income" then
		return
	end
	local generation = (hud.flash:GetAttribute("DisplayGeneration") or 0) + 1
	hud.flash:SetAttribute("DisplayGeneration", generation)
	hud.flash.BackgroundColor3 = if kind == "buy" then Color3.fromRGB(255, 206, 92) elseif kind == "place" then Color3.fromRGB(99, 235, 165) elseif kind == "steal" then Color3.fromRGB(255, 127, 141) else Color3.fromRGB(255, 181, 114)
	hud.flash.BackgroundTransparency = 0.88
	task.delay(0.12, function()
		if hud.flash.Parent and hud.flash:GetAttribute("DisplayGeneration") == generation then
			TweenService:Create(hud.flash, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		end
	end)
end

function EffectsController.HandleFloatingText(hud: HudController.Hud, position: Vector3, text: string, colour: Color3, kind: string?)
	local effectKind = kind or "income"
	EffectsController.ShowFloatingText(position, text, colour, effectKind)
	EffectsController.ShowScreenFeedback(hud, effectKind)
end

if RunService:IsClient() then
	task.defer(startBaseDisplays)
end

return EffectsController
