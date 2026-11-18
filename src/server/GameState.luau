-- One job: own all mutable session state and the authoritative player accounting operations.
local Players = game:GetService("Players")
local Catalog = require(game:GetService("ReplicatedStorage").Shared.CharacterCatalog)
export type Brainrot = { CatalogId: string, Mutation: string, Model: Model, Progress: number? }
export type PlayerState = {
	Cash: number, MaxCash: number, Rebirths: number, Carried: Brainrot?, Placed: { [number]: Brainrot },
	BaseId: number?, LockExpiry: number, Cooldowns: { [string]: number },
	CharacterConnection: RBXScriptConnection?, DeathConnection: RBXScriptConnection?,
}
local GameState = {
	Players = {} :: { [Player]: PlayerState }, World = nil :: any, Remotes = nil :: any,
	Parade = {} :: { [Model]: Brainrot }, Pickups = {} :: { [Model]: { Brainrot: Brainrot, Expires: number } },
	Thief = nil :: any, WaveActive = false, WavePart = nil :: Part?,
	ParadeCursor = 1, ParadeSpawnTime = 0, NextWave = 0, NextThief = 0,
	WaveStarted = 0,
	Connections = {} :: { RBXScriptConnection },
}
function GameState.AddPlayer(player: Player): PlayerState
	local data: PlayerState = { Cash = 100, MaxCash = 100, Rebirths = 0, Carried = nil, Placed = {}, BaseId = nil, LockExpiry = 0, Cooldowns = {} }
	GameState.Players[player] = data
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	for _, name in { "Cash", "IncomePerSecond" } do
		local value = Instance.new("NumberValue")
		value.Name = name
		value.Parent = leaderstats
	end
	GameState.UpdatePlayerStats(player)
	return data
end
function GameState.GetIncomeMultiplier(player: Player): number
	local data = GameState.Players[player]
	return if data then 1.5 ^ data.Rebirths else 1
end
function GameState.GetBrainrotRate(brainrot: Brainrot): number
	return Catalog.GetCharacter(brainrot.CatalogId).moneyPerSecond * Catalog.Mutations[brainrot.Mutation].multiplier
end
function GameState.GetIncomePerSecond(player: Player): number
	local data = GameState.Players[player]
	if not data then return 0 end
	local income = 0
	for _, brainrot in data.Placed do income += GameState.GetBrainrotRate(brainrot) end
	return income * GameState.GetIncomeMultiplier(player)
end
function GameState.UpdatePlayerStats(player: Player)
	local data = GameState.Players[player]
	if not data then return end
	local income = GameState.GetIncomePerSecond(player)
	player:SetAttribute("Cash", data.Cash)
	player:SetAttribute("MaxCash", data.MaxCash)
	player:SetAttribute("IncomePerSecond", income)
	player:SetAttribute("Rebirths", data.Rebirths)
	player:SetAttribute("IncomeMultiplier", GameState.GetIncomeMultiplier(player))
	player:SetAttribute("RebirthCost", 10000 * 5 ^ data.Rebirths)
	player:SetAttribute("Carrying", if data.Carried then Catalog.GetCharacter(data.Carried.CatalogId).name else "")
	player:SetAttribute("BaseId", data.BaseId or 0)
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		stats.Cash.Value = math.floor(data.Cash)
		stats.IncomePerSecond.Value = income
	end
end
function GameState.SetCash(player: Player, cash: number)
	local data = GameState.Players[player]
	if not data then return end
	data.Cash = math.max(0, cash)
	data.MaxCash = math.max(data.MaxCash, data.Cash)
	GameState.UpdatePlayerStats(player)
end
function GameState.TrySpend(player: Player, cost: number): boolean
	local data = GameState.Players[player]
	if not data or data.Cash < cost then return false end
	GameState.SetCash(player, data.Cash - cost)
	return true
end
function GameState.ClearCarried(player: Player)
	local data = GameState.Players[player]
	if data and data.Carried then
		data.Carried.Model:Destroy()
		data.Carried = nil
		GameState.UpdatePlayerStats(player)
	end
end
function GameState.ClearCollection(player: Player)
	local data = GameState.Players[player]
	if not data then return end
	GameState.ClearCarried(player)
	for _, brainrot in data.Placed do brainrot.Model:Destroy() end
	table.clear(data.Placed)
	GameState.UpdatePlayerStats(player)
end
function GameState.RemovePlayer(player: Player)
	local data = GameState.Players[player]
	if data then
		if data.CharacterConnection then data.CharacterConnection:Disconnect() end
		if data.DeathConnection then data.DeathConnection:Disconnect() end
	end
	GameState.ClearCollection(player)
	GameState.Players[player] = nil
end
function GameState.GetBaseOwner(baseId: number): Player?
	for player, data in GameState.Players do
		if data.BaseId == baseId then return player end
	end
	return nil
end
function GameState.IsInsideAnyBase(position: Vector3): boolean
	for _, base in GameState.World.Bases do
		local point = base.SafeBounds.CFrame:PointToObjectSpace(position)
		local half = base.SafeBounds.Size / 2
		if math.abs(point.X) <= half.X and math.abs(point.Y) <= half.Y and math.abs(point.Z) <= half.Z then return true end
	end
	return false
end
function GameState.CanAcquire(player: Player): boolean
	local data = GameState.Players[player]
	local root = GameState.GetPlayerRoot(player)
	local humanoid = if player.Character then player.Character:FindFirstChildOfClass("Humanoid") else nil
	return data ~= nil and data.BaseId ~= nil and data.Carried == nil and root ~= nil and humanoid ~= nil and humanoid.Health > 0
end
function GameState.SetCarried(player: Player, brainrot: Brainrot): boolean
	if not GameState.CanAcquire(player) then return false end
	local data = GameState.Players[player]
	data.Carried = brainrot
	brainrot.Progress = nil
	brainrot.Model.PrimaryPart.CanTouch = false
	for _, child in brainrot.Model:GetDescendants() do
		if child:IsA("ProximityPrompt") then child:Destroy() end
	end
	local price = brainrot.Model:FindFirstChild("PurchasePrice")
	if price then price:Destroy() end
	GameState.UpdatePlayerStats(player)
	GameState.FollowCarriedCharacters()
	return true
end
function GameState.FollowCarriedCharacters()
	for player, data in GameState.Players do
		local root = GameState.GetPlayerRoot(player)
		if data.Carried and root then data.Carried.Model:PivotTo(root.CFrame * CFrame.new(0, 4.2, 0)) end
	end
end
function GameState.GetPlayerFromHit(hit: BasePart): Player?
	local ancestor: Instance? = hit
	while ancestor and ancestor ~= workspace do
		if ancestor:IsA("Model") then
			local player = Players:GetPlayerFromCharacter(ancestor)
			if player then
				local humanoid = ancestor:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then return player end
				return nil
			end
		end
		ancestor = ancestor.Parent
	end
	return nil
end
function GameState.GetPlayerRoot(player: Player): BasePart?
	local character = player.Character
	return if character then character:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
end
function GameState.CanInteract(player: Player, key: string, seconds: number): boolean
	local data = GameState.Players[player]
	if not data then return false end
	local now = os.clock()
	if (data.Cooldowns[key] or 0) > now then return false end
	data.Cooldowns[key] = now + seconds
	return true
end
function GameState.ShowText(player: Player, text: string, position: Vector3, style: string?)
	GameState.Remotes.FloatingText:FireClient(player, text, position, style or "Info")
end
function GameState.TrackConnection(connection: RBXScriptConnection)
	table.insert(GameState.Connections, connection)
end
return GameState
