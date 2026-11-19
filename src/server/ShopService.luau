-- One job: run the shop parade, server-priced egg rolls, overhead carrying, and recoverable stolen pickups.
--!strict

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterCatalog"))
local GameState = require(script.Parent:WaitForChild("GameState"))
local CharacterFactory = require(script.Parent:WaitForChild("CharacterFactory"))

local ShopService = {}
local GOLD = Color3.fromRGB(255, 214, 100)

local function buildPurchasePrompt(root: BasePart, action: string, object: string): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = action
	prompt.ObjectText = object
	prompt.HoldDuration = 0.15
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = root
	return prompt
end

function ShopService.CanAcquireCharacter(player: Player, position: Vector3): boolean
	local state = GameState.GetPlayerState(player)
	if not state or not state.baseId or not GameState.IsPlayerNear(player, position, 12) then
		return false
	end
	if not GameState.CanInteract(player, "acquire", 0.9) then
		return false
	end
	if state.carried then
		GameState.Remotes.FloatingText:FireClient(player, position + Vector3.new(0, 3, 0), "Place your carried brainrot first!", GOLD, "warn")
		return false
	end
	return true
end

function ShopService.AttachCharacterToPlayer(player: Player, character: GameState.CharacterRecord)
	local state = GameState.GetPlayerState(player)
	if not state then
		GameState.DestroyCharacter(character)
		return
	end
	state.carried = character
	character.model.PrimaryPart.CanTouch = false
	for _, child in character.model.PrimaryPart:GetChildren() do
		if child:IsA("ProximityPrompt") then
			child:Destroy()
		end
	end
	local recoveryGlow = character.model:FindFirstChild("RecoveryGlow")
	if recoveryGlow then
		recoveryGlow:Destroy()
	end
	local root = GameState.GetPlayerRoot(player)
	if root then
		character.model:PivotTo(root.CFrame * CFrame.new(0, 3.8, 0))
	end
	GameState.PublishPlayer(player)
end

function ShopService.BuildAcquiredCharacter(id: string): GameState.CharacterRecord
	local mutation = GameState.RollMutation()
	local model = CharacterFactory.BuildCharacter(id, mutation)
	model.Parent = GameState.World.characters
	return { id = id, mutation = mutation, model = model }
end

function ShopService.BuyParadingCharacter(player: Player, model: Model)
	local parade = GameState.Parade[model]
	if not parade or GameState.Wave.phase ~= "calm" or not ShopService.CanAcquireCharacter(player, model:GetPivot().Position) then
		return
	end
	local definition = Catalog.GetCharacter(parade.character.id)
	if not GameState.SpendCash(player, definition.price) then
		GameState.Remotes.FloatingText:FireClient(player, model:GetPivot().Position + Vector3.new(0, 3, 0), "Need $" .. Catalog.FormatMoney(definition.price), Color3.fromRGB(255, 158, 122), "warn")
		return
	end
	GameState.Parade[model] = nil
	local acquired = ShopService.BuildAcquiredCharacter(definition.id)
	model:Destroy()
	ShopService.AttachCharacterToPlayer(player, acquired)
	local root = GameState.GetPlayerRoot(player)
	if root then
		GameState.Remotes.FloatingText:FireClient(player, root.Position + Vector3.new(0, 4, 0), "BOUGHT " .. definition.name .. (if acquired.mutation ~= "Normal" then " - " .. Catalog.Mutations[acquired.mutation].tag else ""), GOLD, "buy")
	end
	ShopService.SpawnParadingCharacter(definition.id, 0)
end

function ShopService.SpawnParadingCharacter(id: string, distance: number)
	local model = CharacterFactory.BuildCharacter(id, "Normal")
	local definition = Catalog.GetCharacter(id)
	model.Parent = GameState.World.characters
	model:PivotTo(CFrame.new(GameState.World.laneStart + Vector3.new(distance, 0, 0)) * CFrame.Angles(0, -math.pi / 2, 0))
	GameState.Parade[model] = { character = { id = id, mutation = "Normal", model = model }, distance = distance }
	model.PrimaryPart.Touched:Connect(function(hit: BasePart)
		local player = GameState.GetPlayerFromTouch(hit)
		if player then
			ShopService.BuyParadingCharacter(player, model)
		end
	end)
	buildPurchasePrompt(model.PrimaryPart, "Buy $" .. Catalog.FormatMoney(definition.price), definition.name).Triggered:Connect(function(player: Player)
		ShopService.BuyParadingCharacter(player, model)
	end)
end

function ShopService.SpawnParade()
	local length = (GameState.World.laneEnd - GameState.World.laneStart).Magnitude
	for index, definition in Catalog.Characters do
		ShopService.SpawnParadingCharacter(definition.id, (index - 1) * length / #Catalog.Characters)
	end
end

function ShopService.ClearParade()
	for model in GameState.Parade do
		GameState.Parade[model] = nil
		model:Destroy()
	end
end

function ShopService.OpenEgg(player: Player, button: any)
	if not ShopService.CanAcquireCharacter(player, button.part.Position) then
		return
	end
	if not GameState.SpendCash(player, button.price) then
		GameState.Remotes.FloatingText:FireClient(player, button.part.Position + Vector3.new(0, 3, 0), "Need $" .. Catalog.FormatMoney(button.price), Color3.fromRGB(255, 158, 122), "warn")
		return
	end
	local band = Catalog.GetCharactersInBand(button.rarity)
	local definition = band[GameState.Random:NextInteger(1, #band)]
	local acquired = ShopService.BuildAcquiredCharacter(definition.id)
	ShopService.AttachCharacterToPlayer(player, acquired)
	GameState.Remotes.FloatingText:FireClient(player, button.part.Position + Vector3.new(0, 5, 0), "HATCHED " .. definition.name .. (if acquired.mutation ~= "Normal" then " - " .. Catalog.Mutations[acquired.mutation].tag else ""), Catalog.RarityColours[definition.rarity], "buy")
end

function ShopService.ClaimDroppedCharacter(player: Player, model: Model)
	local pickup = GameState.Pickups[model]
	if not pickup or not ShopService.CanAcquireCharacter(player, model:GetPivot().Position) then
		return
	end
	GameState.Pickups[model] = nil
	ShopService.AttachCharacterToPlayer(player, pickup.character)
	GameState.Remotes.FloatingText:FireClient(player, model:GetPivot().Position + Vector3.new(0, 3, 0), "RECOVERED! CARRY IT HOME", Color3.fromRGB(157, 255, 194), "steal")
end

function ShopService.CreateClaimablePickup(character: GameState.CharacterRecord, position: Vector3)
	local model = character.model
	model:PivotTo(CFrame.new(Vector3.new(math.clamp(position.X, -87, 87), 3.1, math.clamp(position.Z, -82, 82))))
	model.PrimaryPart.CanTouch = true
	GameState.Pickups[model] = { character = character, expiresAt = os.clock() + 90 }
	model.PrimaryPart.Touched:Connect(function(hit: BasePart)
		local player = GameState.GetPlayerFromTouch(hit)
		if player then
			ShopService.ClaimDroppedCharacter(player, model)
		end
	end)
	buildPurchasePrompt(model.PrimaryPart, "Recover for free", Catalog.GetCharacter(character.id).name).Triggered:Connect(function(player: Player)
		ShopService.ClaimDroppedCharacter(player, model)
	end)
	local highlight = Instance.new("Highlight")
	highlight.Name = "RecoveryGlow"
	highlight.FillColor = Color3.fromRGB(140, 255, 189)
	highlight.FillTransparency = 0.65
	highlight.OutlineColor = Color3.fromRGB(207, 255, 229)
	highlight.Parent = model
end

function ShopService.UpdateParadeAndCarrying(deltaTime: number)
	local length = (GameState.World.laneEnd - GameState.World.laneStart).Magnitude
	for model, parade in GameState.Parade do
		parade.distance = (parade.distance + deltaTime * 4.5) % length
		local position = GameState.World.laneStart + Vector3.new(parade.distance, math.sin(os.clock() * 3.8 + parade.distance) * 0.12, 0)
		model:PivotTo(CFrame.new(position) * CFrame.Angles(0, -math.pi / 2, 0))
	end
	for player, state in GameState.Players do
		local root = GameState.GetPlayerRoot(player)
		if state.carried and root then
			state.carried.model:PivotTo(root.CFrame * CFrame.new(0, 3.8, 0))
		elseif root and state.baseId and GameState.Wave.phase == "calm" then
			-- PivotTo does not itself fire Touched; this server overlap check also catches a brainrot walking into a still player.
			for model in GameState.Parade do
				local offset = root.Position - model:GetPivot().Position
				if math.abs(offset.Y) < 6 and Vector2.new(offset.X, offset.Z).Magnitude < 3.4 then
					ShopService.BuyParadingCharacter(player, model)
					break
				end
			end
		end
	end
	for model, pickup in GameState.Pickups do
		if pickup.expiresAt <= os.clock() then
			GameState.Pickups[model] = nil
			model:Destroy()
		end
	end
end

function ShopService.Start()
	ShopService.SpawnParade()
	for _, button in GameState.World.eggButtons do
		button.part.Touched:Connect(function(hit: BasePart)
			local player = GameState.GetPlayerFromTouch(hit)
			if player then
				ShopService.OpenEgg(player, button)
			end
		end)
		button.prompt.Triggered:Connect(function(player: Player)
			ShopService.OpenEgg(player, button)
		end)
	end
	RunService.Heartbeat:Connect(ShopService.UpdateParadeAndCarrying)
end

return ShopService
