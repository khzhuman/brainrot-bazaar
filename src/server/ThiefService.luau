-- One job: send a masked raccoon to steal the weakest unshielded creature and let touching players rescue it.
local RunService = game:GetService("RunService")
local GameState = require(script.Parent.GameState)
local BaseService = require(script.Parent.BaseService)
local ShopService = require(script.Parent.ShopService)
local Factory = require(script.Parent.CharacterFactory)
local WorldBuilder = require(script.Parent.WorldBuilder)
local ThiefService = {}
local GREY = Color3.fromRGB(137, 148, 159)
local DARK = Color3.fromRGB(37, 44, 56)
local WHITE = Color3.fromRGB(245, 241, 228)

function ThiefService.FindLowestRatePad(player: Player): number?
	local data = GameState.Players[player]
	if not data then return nil end
	local lowestPad: number? = nil
	local lowestRate = math.huge
	for padIndex, brainrot in data.Placed do
		local rate = GameState.GetBrainrotRate(brainrot)
		if rate < lowestRate then lowestRate = rate; lowestPad = padIndex end
	end
	return lowestPad
end

function ThiefService.ChooseUnshieldedOwner(): Player?
	local choices = {}
	for player, data in GameState.Players do
		if data.BaseId and data.LockExpiry <= os.clock() and next(data.Placed) ~= nil then table.insert(choices, player) end
	end
	return if #choices > 0 then choices[math.random(1, #choices)] else nil
end

function ThiefService.BuildSneakyRaccoon(): Model
	local model = Instance.new("Model"); model.Name = "Sneaky Raccoon"
	local root = Factory.AddPart(model, "Root", Vector3.new(4, 4, 4), Vector3.zero, GREY)
	root.Transparency = 1; root.CanTouch = true; root.CanQuery = true; model.PrimaryPart = root
	Factory.AddPart(model, "Body", Vector3.new(2.3, 2, 1.8), Vector3.new(0, 1.25, 0), GREY, Enum.PartType.Ball)
	Factory.AddPart(model, "Head", Vector3.new(2, 1.6, 1.7), Vector3.new(0, 2.7, -0.15), GREY, Enum.PartType.Ball)
	Factory.AddPart(model, "ThiefMask", Vector3.new(1.85, 0.65, 0.25), Vector3.new(0, 2.9, -0.96), DARK)
	for _, x in { -0.52, 0.52 } do
		Factory.AddPart(model, "Eye", Vector3.new(0.38, 0.4, 0.18), Vector3.new(x, 2.94, -1.12), WHITE, Enum.PartType.Ball)
		Factory.AddPart(model, "Pupil", Vector3.new(0.17, 0.25, 0.1), Vector3.new(x, 2.94, -1.22), DARK, Enum.PartType.Ball)
		Factory.AddPart(model, "Ear", Vector3.new(0.62, 0.75, 0.5), Vector3.new(x * 1.35, 3.45, 0), DARK, Enum.PartType.Ball)
		Factory.AddPart(model, "Paw", Vector3.new(0.8, 0.4, 1.1), Vector3.new(x * 1.5, 0.2, -0.2), DARK, Enum.PartType.Ball)
	end
	Factory.AddPart(model, "Muzzle", Vector3.new(1.1, 0.45, 0.45), Vector3.new(0, 2.4, -1), WHITE, Enum.PartType.Ball)
	Factory.AddPart(model, "Nose", Vector3.new(0.35, 0.3, 0.2), Vector3.new(0, 2.55, -1.25), DARK, Enum.PartType.Ball)
	for index = 1, 6 do
		Factory.AddPart(model, "StripedTail", Vector3.new(0.75, 0.7, 0.5), Vector3.new(0, 0.8 + index * 0.12, 0.7 + index * 0.4), if index % 2 == 0 then DARK else GREY, Enum.PartType.Ball)
	end
	model.Parent = GameState.World.Characters
	WorldBuilder.AddBillboard(root, "ThiefLabel", "SNEAKY RACCOON\nTOUCH TO STOP THE THIEF!", Color3.fromRGB(255, 148, 135), 250, 60, 5)
	return model
end

function ThiefService.DespawnThief()
	local thief = GameState.Thief
	if not thief then return end
	if thief.Carried then thief.Carried.Model:Destroy() end
	thief.Model:Destroy(); GameState.Thief = nil
end

function ThiefService.StopThiefAndDropPickup(player: Player)
	local thief = GameState.Thief
	local root = GameState.GetPlayerRoot(player)
	if not thief or thief.Stopped or not root or (root.Position - thief.Position).Magnitude > 10 then return end
	if not GameState.CanInteract(player, "Raccoon", 1) then return end
	thief.Stopped = true; thief.Stage = "Escape"
	if thief.Carried then
		ShopService.CreateClaimablePickup(thief.Carried, thief.Position + Vector3.new(0, 0, -4))
		thief.Carried = nil
		GameState.ShowText(player, "THIEF STOPPED! Claim the dropped brainrot", thief.Position + Vector3.new(0, 5, 0), "Steal")
	else
		GameState.ShowText(player, "RACCOON SCARED AWAY!", thief.Position + Vector3.new(0, 5, 0), "Steal")
	end
end

function ThiefService.SpawnThief()
	if GameState.Thief then return end
	local owner = ThiefService.ChooseUnshieldedOwner()
	if not owner then return end
	local model = ThiefService.BuildSneakyRaccoon()
	local position = Vector3.new(0, 5.3, -100)
	GameState.Thief = { Model = model, TargetPlayer = owner, TargetBaseId = GameState.Players[owner].BaseId, Stage = "Approach", Carried = nil, Position = position, ExitPosition = Vector3.new(0, 5.3, -127), SpawnedAt = os.clock(), Stopped = false }
	model:PivotTo(CFrame.new(position))
	model.PrimaryPart.Touched:Connect(function(hit)
		local player = GameState.GetPlayerFromHit(hit)
		if player and GameState.Thief and GameState.Thief.Model == model then ThiefService.StopThiefAndDropPickup(player) end
	end)
	local prompt = WorldBuilder.AddPrompt(model.PrimaryPart, "Stop thief", "Sneaky Raccoon")
	prompt.Triggered:Connect(function(player)
		if GameState.Thief and GameState.Thief.Model == model then ThiefService.StopThiefAndDropPickup(player) end
	end)
	GameState.Remotes.ShowBanner:FireClient(owner, "SNEAKY RACCOON! LOCK YOUR BASE OR TOUCH THE THIEF!", 6, "Thief")
end

function ThiefService.StealLowestRateCharacter()
	local thief = GameState.Thief
	if not thief then return end
	local data = GameState.Players[thief.TargetPlayer]
	if not data or data.BaseId ~= thief.TargetBaseId or data.LockExpiry > os.clock() then thief.Stage = "Escape"; return end
	local padIndex = ThiefService.FindLowestRatePad(thief.TargetPlayer)
	if not padIndex then thief.Stage = "Escape"; return end
	thief.Carried = data.Placed[padIndex]; data.Placed[padIndex] = nil; thief.Stage = "Escape"
	GameState.UpdatePlayerStats(thief.TargetPlayer); BaseService.RefreshBase(data.BaseId)
	GameState.ShowText(thief.TargetPlayer, "STOLEN! Touch the raccoon to rescue it!", thief.Position + Vector3.new(0, 5, 0), "Steal")
end

function ThiefService.WalkThiefTo(destination: Vector3, delta: number): boolean
	local thief = GameState.Thief
	local offset = destination - thief.Position
	if offset.Magnitude < 0.3 then return true end
	local step = math.min(offset.Magnitude, delta * 8)
	thief.Position += offset.Unit * step
	thief.Model:PivotTo(CFrame.lookAt(thief.Position, thief.Position + offset.Unit))
	return step >= offset.Magnitude
end

function ThiefService.UpdateThief(delta: number)
	local thief = GameState.Thief
	if not thief then return end
	if os.clock() - thief.SpawnedAt > 90 then ThiefService.DespawnThief(); return end
	if thief.Stage == "Approach" then
		local data = GameState.Players[thief.TargetPlayer]
		local padIndex = ThiefService.FindLowestRatePad(thief.TargetPlayer)
		if not data or data.BaseId ~= thief.TargetBaseId or not padIndex then
			thief.Stage = "Escape"
		elseif data.LockExpiry > os.clock() then
			thief.Stage = "Escape"
			GameState.ShowText(thief.TargetPlayer, "SHIELD BLOCKED THE THIEF!", thief.Position + Vector3.new(0, 5, 0), "Shield")
		else
			local pad = GameState.World.Bases[data.BaseId].Pads[padIndex].Part
			if ThiefService.WalkThiefTo(Vector3.new(pad.Position.X, 5.3, pad.Position.Z), delta) then ThiefService.StealLowestRateCharacter() end
		end
	elseif thief.Stage == "Escape" then
		if ThiefService.WalkThiefTo(thief.ExitPosition, delta) then ThiefService.DespawnThief(); return end
	end
	if thief.Carried then thief.Carried.Model:PivotTo(thief.Model:GetPivot() * CFrame.new(0, 4, 0)) end
end

function ThiefService.Start()
	GameState.NextThief = os.clock() + math.random(140, 160)
	GameState.TrackConnection(RunService.Heartbeat:Connect(function(delta)
		if os.clock() >= GameState.NextThief then
			GameState.NextThief = os.clock() + math.random(140, 160)
			ThiefService.SpawnThief()
		end
		ThiefService.UpdateThief(delta)
	end))
end

return ThiefService
