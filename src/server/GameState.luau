-- One job: own all mutable server gameplay state and expose atomic player, money, and collection operations.
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterCatalog"))

export type CharacterRecord = { id: string, mutation: string, model: Model }
export type PlayerState = {
	cash: number,
	maxCash: number,
	rebirths: number,
	carried: CharacterRecord?,
	placed: { [number]: CharacterRecord },
	baseId: number?,
	lockExpiresAt: number,
	cooldowns: { [string]: number },
}
export type ParadeRecord = { character: CharacterRecord, distance: number }
export type ThiefRecord = {
	model: Model,
	targetPlayer: Player,
	phase: string,
	carried: CharacterRecord?,
	expiresAt: number,
}

local GameState = {
	Players = {} :: { [Player]: PlayerState },
	Parade = {} :: { [Model]: ParadeRecord },
	Pickups = {} :: { [Model]: { character: CharacterRecord, expiresAt: number } },
	Thief = nil :: ThiefRecord?,
	World = nil :: any,
	Remotes = nil :: any,
	Random = Random.new(),
	Wave = { phase = "calm", nextAt = 0, startsAt = 0, endsAt = 0, part = nil :: Part? },
	NextThiefAt = 0,
	NextIncomeAt = 0,
}

function GameState.GetPlayerState(player: Player): PlayerState?
	return GameState.Players[player]
end

function GameState.RegisterPlayer(player: Player): PlayerState
	local state: PlayerState = {
		cash = 100,
		maxCash = 100,
		rebirths = 0,
		carried = nil,
		placed = {},
		baseId = nil,
		lockExpiresAt = 0,
		cooldowns = {},
	}
	GameState.Players[player] = state
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100
	cash.Parent = leaderstats
	local income = Instance.new("NumberValue")
	income.Name = "IncomePerSecond"
	income.Parent = leaderstats
	GameState.PublishPlayer(player)
	return state
end

function GameState.ComputeIncomePerSecond(player: Player): number
	local state = GameState.Players[player]
	if not state then
		return 0
	end
	local income = 0
	for _, character in state.placed do
		income += Catalog.GetCharacterRate(character.id, character.mutation)
	end
	return income * Catalog.GetRebirthMultiplier(state.rebirths)
end

function GameState.PublishPlayer(player: Player)
	local state = GameState.Players[player]
	if not state then
		return
	end
	local income = GameState.ComputeIncomePerSecond(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cashValue = leaderstats:FindFirstChild("Cash") :: IntValue
		local incomeValue = leaderstats:FindFirstChild("IncomePerSecond") :: NumberValue
		cashValue.Value = math.floor(state.cash)
		incomeValue.Value = math.round(income * 100) / 100
	end
	player:SetAttribute("Cash", state.cash)
	player:SetAttribute("MaxCash", state.maxCash)
	player:SetAttribute("IncomePerSecond", income)
	player:SetAttribute("Rebirths", state.rebirths)
	player:SetAttribute("RebirthMultiplier", Catalog.GetRebirthMultiplier(state.rebirths))
	player:SetAttribute("RebirthCost", Catalog.GetRebirthCost(state.rebirths))
	player:SetAttribute("BaseId", state.baseId or 0)
	player:SetAttribute("ShieldExpiresAt", state.lockExpiresAt)
	player:SetAttribute("CarriedName", if state.carried then Catalog.GetCharacter(state.carried.id).name else "")
end

function GameState.AddCash(player: Player, amount: number)
	local state = GameState.Players[player]
	if state then
		state.cash += amount
		state.maxCash = math.max(state.maxCash, state.cash)
		GameState.PublishPlayer(player)
	end
end

function GameState.SpendCash(player: Player, amount: number): boolean
	local state = GameState.Players[player]
	if not state or state.cash < amount then
		return false
	end
	state.cash -= amount
	GameState.PublishPlayer(player)
	return true
end

function GameState.CanInteract(player: Player, action: string, delaySeconds: number): boolean
	local state = GameState.Players[player]
	if not state or (state.cooldowns[action] or 0) > os.clock() then
		return false
	end
	state.cooldowns[action] = os.clock() + delaySeconds
	return true
end

function GameState.GetPlayerFromTouch(hit: BasePart): Player?
	local ancestor: Instance? = hit
	while ancestor and ancestor ~= workspace do
		if ancestor:IsA("Model") then
			local player = Players:GetPlayerFromCharacter(ancestor)
			if player then
				return player
			end
		end
		ancestor = ancestor.Parent
	end
	return nil
end

function GameState.GetPlayerRoot(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
		return root
	end
	return nil
end

function GameState.IsPlayerNear(player: Player, position: Vector3, distance: number): boolean
	local root = GameState.GetPlayerRoot(player)
	return root ~= nil and (root.Position - position).Magnitude <= distance
end

function GameState.IsShieldActive(player: Player): boolean
	local state = GameState.Players[player]
	return state ~= nil and state.lockExpiresAt > workspace:GetServerTimeNow()
end

function GameState.IsPositionInSafeZone(position: Vector3): boolean
	for _, base in GameState.World.bases do
		local point = base.safeBounds.CFrame:PointToObjectSpace(position)
		local half = base.safeBounds.Size / 2
		if math.abs(point.X) <= half.X and math.abs(point.Y) <= half.Y and math.abs(point.Z) <= half.Z then
			return true
		end
	end
	return false
end

function GameState.FindBaseOwner(baseId: number): Player?
	for player, state in GameState.Players do
		if state.baseId == baseId then
			return player
		end
	end
	return nil
end

function GameState.RollMutation(): string
	local roll = GameState.Random:NextNumber()
	if roll < Catalog.Mutations.Void.probability then
		return "Void"
	elseif roll < Catalog.Mutations.Void.probability + Catalog.Mutations.Diamond.probability then
		return "Diamond"
	elseif roll < Catalog.Mutations.Void.probability + Catalog.Mutations.Diamond.probability + Catalog.Mutations.Golden.probability then
		return "Golden"
	end
	return "Normal"
end

function GameState.DestroyCharacter(character: CharacterRecord?)
	if character then
		character.model:Destroy()
	end
end

function GameState.ClearCollection(player: Player)
	local state = GameState.Players[player]
	if not state then
		return
	end
	GameState.DestroyCharacter(state.carried)
	state.carried = nil
	for padIndex, character in state.placed do
		GameState.DestroyCharacter(character)
		state.placed[padIndex] = nil
	end
	GameState.PublishPlayer(player)
end

function GameState.UnregisterPlayer(player: Player)
	GameState.ClearCollection(player)
	GameState.Players[player] = nil
end

return GameState
