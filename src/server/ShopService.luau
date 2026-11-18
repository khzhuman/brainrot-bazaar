-- One job: parade purchasable creatures, hatch tiered eggs, follow carriers, and let players claim dropped pickups.
local RunService = game:GetService("RunService")
local GameState = require(script.Parent.GameState)
local Factory = require(script.Parent.CharacterFactory)
local WorldBuilder = require(script.Parent.WorldBuilder)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.CharacterCatalog)
local ShopService = {}
local PARADE_COUNT = 12
local WALK_SPEED = 6

function ShopService.CheckAcquisition(player: Player, position: Vector3): boolean
	local data = GameState.Players[player]
	local root = GameState.GetPlayerRoot(player)
	if not data or not root or (root.Position - position).Magnitude > 11 then return false end
	if GameState.WaveActive then
		if GameState.CanInteract(player, "WaveShop", 2) then GameState.ShowText(player, "TSUNAMI! Dash to a base!", position, "Error") end
		return false
	end
	if not GameState.CanAcquire(player) then
		if GameState.CanInteract(player, "CarryFull", 2) then
			GameState.ShowText(player, if data.Carried then "Place your carried brainrot first!" else "Wait for a free base", position + Vector3.new(0, 4, 0), "Info")
		end
		return false
	end
	return GameState.CanInteract(player, "Acquire", 0.75)
end

function ShopService.GrantCharacter(player: Player, id: string, position: Vector3)
	local mutation = Catalog.RollMutation()
	local model = Factory.CreateCharacter(id, mutation, GameState.World.Characters)
	local brainrot = { CatalogId = id, Mutation = mutation, Model = model }
	if not GameState.SetCarried(player, brainrot) then model:Destroy(); return end
	local tag = Catalog.Mutations[mutation].tag
	GameState.ShowText(player, "GOT " .. Catalog.GetCharacter(id).name .. (if tag ~= "" then " • " .. tag else ""), position + Vector3.new(0, 5, 0), "Buy")
end

function ShopService.BuyParadingCharacter(player: Player, model: Model)
	local brainrot = GameState.Parade[model]
	if not brainrot or not model.PrimaryPart then return end
	local position = model.PrimaryPart.Position
	if not ShopService.CheckAcquisition(player, position) then return end
	local character = Catalog.GetCharacter(brainrot.CatalogId)
	if not GameState.TrySpend(player, character.price) then
		GameState.ShowText(player, "Need $" .. Catalog.FormatMoney(character.price), position + Vector3.new(0, 5, 0), "Error")
		return
	end
	GameState.Parade[model] = nil; model:Destroy()
	ShopService.GrantCharacter(player, character.id, position)
end

function ShopService.HatchEgg(player: Player, bandIndex: number)
	local button = GameState.World.EggButtons[bandIndex].Part
	if not ShopService.CheckAcquisition(player, button.Position) then return end
	local band = Catalog.EggBands[bandIndex]
	if not GameState.TrySpend(player, band.price) then
		GameState.ShowText(player, "Need $" .. Catalog.FormatMoney(band.price), button.Position + Vector3.new(0, 4, 0), "Error")
		return
	end
	ShopService.GrantCharacter(player, Catalog.RollEggCharacter(bandIndex).id, button.Position)
end

function ShopService.SpawnParadeCharacter(progress: number?)
	local character = Catalog.Characters[GameState.ParadeCursor]
	GameState.ParadeCursor = GameState.ParadeCursor % #Catalog.Characters + 1
	local model = Factory.CreateCharacter(character.id, "Normal", GameState.World.Characters)
	GameState.Parade[model] = { CatalogId = character.id, Mutation = "Normal", Model = model, Progress = progress or 0 }
	model:PivotTo(CFrame.lookAt(GameState.World.LaneStart:Lerp(GameState.World.LaneEnd, progress or 0), GameState.World.LaneStart:Lerp(GameState.World.LaneEnd, progress or 0) + GameState.World.LaneDirection))
	local price = WorldBuilder.AddBillboard(model.PrimaryPart, "Price", "TOUCH TO BUY • $" .. Catalog.FormatMoney(character.price), Color3.fromRGB(255, 236, 163), 220, 26, -0.7)
	price.Parent.Name = "PurchasePrice"; price.TextSize = 14; price.Parent.MaxDistance = 55
	local prompt = WorldBuilder.AddPrompt(model.PrimaryPart, "Buy $" .. Catalog.FormatMoney(character.price), character.name)
	model.PrimaryPart.Touched:Connect(function(hit)
		local player = GameState.GetPlayerFromHit(hit)
		if player then ShopService.BuyParadingCharacter(player, model) end
	end)
	prompt.Triggered:Connect(function(player) ShopService.BuyParadingCharacter(player, model) end)
end

function ShopService.ClearParade()
	for model in GameState.Parade do model:Destroy() end
	table.clear(GameState.Parade)
end

function ShopService.RestartParade()
	ShopService.ClearParade()
	for index = 1, PARADE_COUNT do ShopService.SpawnParadeCharacter((index - 1) / PARADE_COUNT) end
	GameState.ParadeSpawnTime = os.clock() + 4
end

function ShopService.UpdateParade(delta: number)
	if GameState.WaveActive then return end
	local count = 0
	for model, brainrot in GameState.Parade do
		count += 1
		brainrot.Progress = ((brainrot.Progress or 0) + delta * WALK_SPEED / GameState.World.LaneLength) % 1
		local position = GameState.World.LaneStart:Lerp(GameState.World.LaneEnd, brainrot.Progress) + Vector3.new(0, math.sin(os.clock() * 5 + brainrot.Progress * 30) * 0.16, 0)
		model:PivotTo(CFrame.lookAt(position, position + GameState.World.LaneDirection))
	end
	if os.clock() >= GameState.ParadeSpawnTime and count < PARADE_COUNT then
		ShopService.SpawnParadeCharacter(0); GameState.ParadeSpawnTime = os.clock() + 4
	end
end

function ShopService.ClaimPickup(player: Player, model: Model)
	local pickup = GameState.Pickups[model]
	if not pickup or not model.PrimaryPart then return end
	local position = model.PrimaryPart.Position
	if not ShopService.CheckAcquisition(player, position) then return end
	if not GameState.SetCarried(player, pickup.Brainrot) then return end
	GameState.Pickups[model] = nil
	local label = model:FindFirstChild("PickupLabel")
	if label then label:Destroy() end
	GameState.ShowText(player, "RESCUED! Carry it to your base", position + Vector3.new(0, 5, 0), "Place")
end

function ShopService.CreateClaimablePickup(brainrot, position: Vector3)
	local model = brainrot.Model
	GameState.Pickups[model] = { Brainrot = brainrot, Expires = os.clock() + 60 }
	model:PivotTo(CFrame.new(position)); model.PrimaryPart.CanTouch = true
	local label = WorldBuilder.AddBillboard(model.PrimaryPart, "PickupLabel", "RESCUE ME! TOUCH TO CLAIM", Color3.fromRGB(140, 255, 180), 240, 30, -0.5)
	label.Parent.Parent = model
	local prompt = WorldBuilder.AddPrompt(model.PrimaryPart, "Claim rescued brainrot", Catalog.GetCharacter(brainrot.CatalogId).name)
	model.PrimaryPart.Touched:Connect(function(hit)
		local player = GameState.GetPlayerFromHit(hit)
		if player then ShopService.ClaimPickup(player, model) end
	end)
	prompt.Triggered:Connect(function(player) ShopService.ClaimPickup(player, model) end)
end

function ShopService.UpdatePickups()
	for model, pickup in GameState.Pickups do
		if os.clock() >= pickup.Expires then model:Destroy(); GameState.Pickups[model] = nil end
	end
end

function ShopService.Start()
	for bandIndex, button in GameState.World.EggButtons do
		GameState.TrackConnection(button.Part.Touched:Connect(function(hit)
			local player = GameState.GetPlayerFromHit(hit)
			if player then ShopService.HatchEgg(player, bandIndex) end
		end))
		GameState.TrackConnection(button.Prompt.Triggered:Connect(function(player) ShopService.HatchEgg(player, bandIndex) end))
	end
	ShopService.RestartParade()
	GameState.TrackConnection(RunService.Heartbeat:Connect(function(delta)
		ShopService.UpdateParade(delta); ShopService.UpdatePickups(); GameState.FollowCarriedCharacters()
	end))
end

return ShopService
