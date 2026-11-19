-- One job: send a masked raccoon after unshielded money printers and let players recover its stolen cargo.
--!strict

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterCatalog"))
local GameState = require(script.Parent:WaitForChild("GameState"))
local BaseService = require(script.Parent:WaitForChild("BaseService"))
local ShopService = require(script.Parent:WaitForChild("ShopService"))

local ThiefService = {}

local function buildRaccoonPart(model: Model, name: string, size: Vector3, position: Vector3, colour: Color3, shape: Enum.PartType?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = colour
	part.Shape = shape or Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.SmoothPlastic
	part.Parent = model
	return part
end

function ThiefService.BuildSneakyRaccoon(): Model
	local model = Instance.new("Model")
	model.Name = "Sneaky Raccoon"
	local grey = Color3.fromRGB(136, 144, 151)
	local dark = Color3.fromRGB(33, 35, 46)
	local white = Color3.fromRGB(245, 243, 228)
	local root = buildRaccoonPart(model, "ThiefInteractionRoot", Vector3.new(4.2, 6, 4.2), Vector3.zero, grey, Enum.PartType.Block)
	root.Transparency = 1
	root.CanTouch = true
	root.CanQuery = true
	model.PrimaryPart = root
	buildRaccoonPart(model, "RaccoonBody", Vector3.new(2.5, 2.25, 2.5), Vector3.new(0, 1.6, 0), grey)
	buildRaccoonPart(model, "RaccoonHead", Vector3.new(2.25, 1.65, 1.7), Vector3.new(0, 3.0, -0.45), grey)
	buildRaccoonPart(model, "ThiefMask", Vector3.new(2.0, 0.68, 0.25), Vector3.new(0, 3.13, -1.26), dark, Enum.PartType.Block)
	for side = -1, 1, 2 do
		buildRaccoonPart(model, "RaccoonEar", Vector3.new(0.72, 0.85, 0.4), Vector3.new(side * 0.8, 3.94, -0.35), dark)
		buildRaccoonPart(model, "MaskedEye", Vector3.new(0.44, 0.39, 0.15), Vector3.new(side * 0.52, 3.18, -1.45), white)
		buildRaccoonPart(model, "SneakyPupil", Vector3.new(0.19, 0.25, 0.12), Vector3.new(side * 0.52, 3.18, -1.54), dark)
		buildRaccoonPart(model, "RaccoonFoot", Vector3.new(0.8, 0.5, 1.1), Vector3.new(side * 0.7, 0.25, -0.35), dark)
	end
	for index = 1, 3 do
		buildRaccoonPart(model, "StripedTail", Vector3.new(0.8, 0.8, 0.9), Vector3.new(0, 1.3 + index * 0.17, 1.0 + index * 0.6), if index % 2 == 0 then grey else dark)
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ThiefLabel"
	billboard.Size = UDim2.fromOffset(220, 65)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 5.7, 0)
	billboard.MaxDistance = 120
	billboard.Adornee = root
	billboard.Parent = root
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "SNEAKY RACCOON\nTOUCH TO STOP THE THIEF!"
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.fromRGB(255, 135, 135)
	label.TextStrokeTransparency = 0.2
	label.Parent = billboard
	return model
end

function ThiefService.FindLowestRatePad(player: Player): number?
	local state = GameState.GetPlayerState(player)
	if not state then
		return nil
	end
	local lowestPad: number? = nil
	local lowestRate = math.huge
	for padIndex, character in state.placed do
		local rate = Catalog.GetCharacterRate(character.id, character.mutation)
		if rate < lowestRate then
			lowestRate = rate
			lowestPad = padIndex
		end
	end
	return lowestPad
end

function ThiefService.FindUnshieldedTarget(): Player?
	local candidates = {}
	for player, state in GameState.Players do
		if state.baseId and not GameState.IsShieldActive(player) and ThiefService.FindLowestRatePad(player) then
			table.insert(candidates, player)
		end
	end
	if #candidates == 0 then
		return nil
	end
	return candidates[GameState.Random:NextInteger(1, #candidates)]
end

function ThiefService.SpawnThief()
	local target = ThiefService.FindUnshieldedTarget()
	if not target then
		return
	end
	local model = ThiefService.BuildSneakyRaccoon()
	model.Parent = GameState.World.events
	model:PivotTo(CFrame.new(-92, 3.1, 4))
	GameState.Thief = { model = model, targetPlayer = target, phase = "approaching", carried = nil, expiresAt = os.clock() + 100 }
	model.PrimaryPart.Touched:Connect(function(hit: BasePart)
		local player = GameState.GetPlayerFromTouch(hit)
		if player then
			ThiefService.MakeThiefDropCargo(player)
		end
	end)
	GameState.Remotes.ShowBanner:FireAllClients("SNEAKY RACCOON ON THE BOARDWALK - SHIELD YOUR BASE!", 6)
end

function ThiefService.StealLowestRateCharacter()
	local thief = GameState.Thief
	if not thief then
		return
	end
	local state = GameState.GetPlayerState(thief.targetPlayer)
	local padIndex = ThiefService.FindLowestRatePad(thief.targetPlayer)
	if not state or not state.baseId or not padIndex or GameState.IsShieldActive(thief.targetPlayer) then
		thief.phase = "escaping"
		return
	end
	local character = state.placed[padIndex]
	state.placed[padIndex] = nil
	thief.carried = character
	thief.phase = "escaping"
	GameState.PublishPlayer(thief.targetPlayer)
	BaseService.RefreshBase(state.baseId)
	GameState.Remotes.ShowBanner:FireClient(thief.targetPlayer, "RACCOON STOLE " .. Catalog.GetCharacter(character.id).name .. " - TOUCH IT TO RECOVER!", 8)
	GameState.Remotes.FloatingText:FireClient(thief.targetPlayer, thief.model:GetPivot().Position + Vector3.new(0, 4, 0), "STOLEN! CHASE THE RACCOON", Color3.fromRGB(255, 130, 139), "steal")
end

function ThiefService.MakeThiefDropCargo(player: Player)
	local thief = GameState.Thief
	if not thief or (thief.phase == "escaping" and not thief.carried) or not GameState.IsPlayerNear(player, thief.model:GetPivot().Position, 9) or not GameState.CanInteract(player, "stop_thief", 0.8) then
		return
	end
	if thief.carried then
		local stolen = thief.carried
		thief.carried = nil
		ShopService.CreateClaimablePickup(stolen, thief.model:GetPivot().Position + Vector3.new(3, 0, 0))
		GameState.Remotes.FloatingText:FireClient(player, stolen.model:GetPivot().Position + Vector3.new(0, 4, 0), "DROPPED! TOUCH THE BRAINROT TO CLAIM", Color3.fromRGB(161, 255, 195), "steal")
	else
		GameState.Remotes.FloatingText:FireClient(player, thief.model:GetPivot().Position + Vector3.new(0, 4, 0), "THIEF SCARED AWAY!", Color3.fromRGB(161, 255, 195), "place")
	end
	thief.phase = "escaping"
end

function ThiefService.DespawnThief()
	local thief = GameState.Thief
	if thief then
		GameState.DestroyCharacter(thief.carried)
		thief.model:Destroy()
		GameState.Thief = nil
	end
end

function ThiefService.UpdateThief(deltaTime: number)
	if not GameState.Thief and os.clock() >= GameState.NextThiefAt then
		GameState.NextThiefAt = os.clock() + GameState.Random:NextNumber(140, 160)
		ThiefService.SpawnThief()
	end
	local thief = GameState.Thief
	if not thief then
		return
	end
	if os.clock() >= thief.expiresAt then
		ThiefService.DespawnThief()
		return
	end
	local destination = GameState.World.seaEscape
	if thief.phase == "approaching" then
		local targetState = GameState.GetPlayerState(thief.targetPlayer)
		local padIndex = ThiefService.FindLowestRatePad(thief.targetPlayer)
		if not targetState or not targetState.baseId or not padIndex or GameState.IsShieldActive(thief.targetPlayer) then
			thief.phase = "escaping"
		else
			destination = GameState.World.bases[targetState.baseId].pads[padIndex].part.Position
		end
	end
	local pivot = thief.model:GetPivot()
	local current = Vector3.new(pivot.Position.X, 3.1, pivot.Position.Z)
	local goal = Vector3.new(destination.X, 3.1, destination.Z)
	local offset = goal - current
	if offset.Magnitude <= 1.3 then
		if thief.phase == "approaching" then
			ThiefService.StealLowestRateCharacter()
		else
			ThiefService.DespawnThief()
			return
		end
	else
		local nextPosition = current + offset.Unit * math.min(offset.Magnitude, deltaTime * 9)
		thief.model:PivotTo(CFrame.lookAt(nextPosition + Vector3.new(0, math.sin(os.clock() * 10) * 0.12, 0), nextPosition + offset.Unit))
	end
	if thief.carried then
		thief.carried.model:PivotTo(thief.model:GetPivot() * CFrame.new(0, 4.3, 0))
	end
	-- A server overlap catches a still player intercepting the moving anchored raccoon.
	for player in GameState.Players do
		local root = GameState.GetPlayerRoot(player)
		if root then
			local offsetToPlayer = root.Position - thief.model:GetPivot().Position
			if math.abs(offsetToPlayer.Y) < 6 and Vector2.new(offsetToPlayer.X, offsetToPlayer.Z).Magnitude < 3 then
				ThiefService.MakeThiefDropCargo(player)
			end
		end
	end
end

function ThiefService.Start()
	GameState.NextThiefAt = os.clock() + 150
	RunService.Heartbeat:Connect(ThiefService.UpdateThief)
end

return ThiefService
