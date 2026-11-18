-- One job: assign bases, place carried creatures, unlock pads, and operate the paid shield dome.
local Players = game:GetService("Players")
local GameState = require(script.Parent.GameState)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.CharacterCatalog)
local BaseService = {}
local PAD_MILESTONES = table.freeze({ 0, 0, 0, 0, 1000, 10000, 100000, 1000000 })
local AQUA = Color3.fromRGB(83, 223, 212)
local INK = Color3.fromRGB(69, 89, 100)

function BaseService.IsPadUnlocked(player: Player, padIndex: number): boolean
	local data = GameState.Players[player]
	return data ~= nil and data.MaxCash >= PAD_MILESTONES[padIndex]
end

function BaseService.RefreshBase(baseId: number)
	local base = GameState.World.Bases[baseId]
	local owner = GameState.GetBaseOwner(baseId)
	local data = if owner then GameState.Players[owner] else nil
	local remaining = if data then math.max(0, math.ceil(data.LockExpiry - os.clock())) else 0
	base.Dome.Transparency = if remaining > 0 then 0.72 else 1
	base.LockLabel.Text = if remaining > 0 then "SHIELD ACTIVE\n" .. remaining .. " sec" else "SHIELD\n$250 • 60 sec"
	base.LockPrompt.Enabled = data ~= nil and remaining == 0
	base.OwnerLabel.Text = if data then owner.DisplayName .. "'s BAZAAR\n" .. (if data.Rebirths > 0 then "♛ " .. data.Rebirths .. " REBIRTHS" else "YOUR SAFE ZONE") else "BASE " .. baseId .. "\nAVAILABLE"
	for _, part in base.Crown:GetChildren() do part.Transparency = if data and data.Rebirths > 0 then 0 else 1 end
	for index, pad in base.Pads do
		local unlocked = data ~= nil and BaseService.IsPadUnlocked(owner, index)
		local placed = if data then data.Placed[index] else nil
		pad.Part.Color = if placed then Catalog.RarityColors[Catalog.GetCharacter(placed.CatalogId).rarity] elseif unlocked then AQUA else INK
		pad.Prompt.Enabled = unlocked and placed == nil
		pad.Label.Text = if placed then "PRINTING +$" .. Catalog.FormatMoney(GameState.GetBrainrotRate(placed) * GameState.GetIncomeMultiplier(owner)) .. "/s" elseif PAD_MILESTONES[index] > 0 and not unlocked then "LOCKED - reach $" .. Catalog.FormatMoney(PAD_MILESTONES[index]) else "PAD " .. index .. " • PLACE HERE"
	end
end

function BaseService.RefreshAllBases()
	for baseId in GameState.World.Bases do BaseService.RefreshBase(baseId) end
end

function BaseService.AssignAvailableBase(player: Player): boolean
	local data = GameState.Players[player]
	if not data then return false end
	if data.BaseId then return true end
	for baseId, base in GameState.World.Bases do
		if not GameState.GetBaseOwner(baseId) then
			data.BaseId = baseId; player.RespawnLocation = base.Spawn
			GameState.UpdatePlayerStats(player); BaseService.RefreshBase(baseId)
			local root = GameState.GetPlayerRoot(player)
			if root then player.Character:PivotTo(base.Spawn.CFrame + Vector3.new(0, 3, 0)) end
			return true
		end
	end
	player.RespawnLocation = GameState.World.PublicSpawn
	GameState.UpdatePlayerStats(player)
	return false
end

function BaseService.ReleaseBase(player: Player)
	local data = GameState.Players[player]
	if not data then return end
	local baseId = data.BaseId
	GameState.ClearCollection(player); data.BaseId = nil; data.LockExpiry = 0
	if baseId then BaseService.RefreshBase(baseId) end
	for waitingPlayer, waitingData in GameState.Players do
		if waitingPlayer ~= player and waitingData.BaseId == nil then BaseService.AssignAvailableBase(waitingPlayer) end
	end
end

function BaseService.PlaceOnPad(player: Player, baseId: number, padIndex: number)
	local data = GameState.Players[player]
	if not data or data.BaseId ~= baseId or not data.Carried or data.Placed[padIndex] then return end
	local pad = GameState.World.Bases[baseId].Pads[padIndex]
	local root = GameState.GetPlayerRoot(player)
	if not root or (root.Position - pad.Part.Position).Magnitude > 10 then return end
	if not GameState.CanInteract(player, "Pad" .. padIndex, 0.75) then return end
	if not BaseService.IsPadUnlocked(player, padIndex) then
		GameState.ShowText(player, "LOCKED - reach $" .. Catalog.FormatMoney(PAD_MILESTONES[padIndex]), pad.Part.Position + Vector3.new(0, 3, 0), "Error")
		return
	end
	data.Placed[padIndex] = data.Carried; data.Carried = nil
	local brainrot = data.Placed[padIndex]
	local facing = if GameState.World.Bases[baseId].Floor.Position.X < 0 then -math.pi / 2 else math.pi / 2
	brainrot.Model:PivotTo(CFrame.new(pad.Part.Position + Vector3.new(0, 0.45, 0)) * CFrame.Angles(0, facing, 0))
	GameState.UpdatePlayerStats(player); BaseService.RefreshBase(baseId)
	GameState.ShowText(player, "PLACED! +$" .. Catalog.FormatMoney(GameState.GetBrainrotRate(brainrot) * GameState.GetIncomeMultiplier(player)) .. "/s", pad.Part.Position + Vector3.new(0, 4, 0), "Place")
end

function BaseService.LockBase(player: Player, baseId: number)
	local data = GameState.Players[player]
	if not data or data.BaseId ~= baseId then return end
	local base = GameState.World.Bases[baseId]
	local root = GameState.GetPlayerRoot(player)
	if not root or (root.Position - base.LockButton.Position).Magnitude > 10 then return end
	if not GameState.CanInteract(player, "Lock", 1) then return end
	if data.LockExpiry > os.clock() then
		GameState.ShowText(player, "Shield: " .. math.ceil(data.LockExpiry - os.clock()) .. "s left", base.LockButton.Position, "Shield")
		return
	end
	if not GameState.TrySpend(player, 250) then
		GameState.ShowText(player, "Need $250", base.LockButton.Position + Vector3.new(0, 3, 0), "Error")
		return
	end
	data.LockExpiry = os.clock() + 60; BaseService.RefreshBase(baseId)
	GameState.ShowText(player, "SHIELD UP! 60 seconds", base.LockButton.Position + Vector3.new(0, 5, 0), "Shield")
end

function BaseService.RespawnPlayer(player: Player)
	if player.Parent ~= Players or not GameState.Players[player] then return end
	local ok, reason = pcall(function() player:LoadCharacterAsync() end)
	if not ok then warn("BRAINROT BAZAAR spawn failed: " .. tostring(reason)) end
end

function BaseService.HandleCharacterSpawn(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	local data = GameState.Players[player]
	if not data or not humanoid or not root or player.Character ~= character then return end
	GameState.ClearCarried(player)
	humanoid.WalkSpeed = 22
	local spawn = if data.BaseId then GameState.World.Bases[data.BaseId].Spawn else GameState.World.PublicSpawn
	character:PivotTo(spawn.CFrame + Vector3.new(0, 3, 0))
	if data.DeathConnection then data.DeathConnection:Disconnect() end
	data.DeathConnection = humanoid.Died:Connect(function()
		GameState.ClearCarried(player)
		task.delay(3, function() BaseService.RespawnPlayer(player) end)
	end)
end

function BaseService.Start()
	for baseId, base in GameState.World.Bases do
		for padIndex, pad in base.Pads do
			GameState.TrackConnection(pad.Part.Touched:Connect(function(hit)
				local player = GameState.GetPlayerFromHit(hit)
				if player then BaseService.PlaceOnPad(player, baseId, padIndex) end
			end))
			GameState.TrackConnection(pad.Prompt.Triggered:Connect(function(player) BaseService.PlaceOnPad(player, baseId, padIndex) end))
		end
		GameState.TrackConnection(base.LockButton.Touched:Connect(function(hit)
			local player = GameState.GetPlayerFromHit(hit)
			if player then BaseService.LockBase(player, baseId) end
		end))
		GameState.TrackConnection(base.LockPrompt.Triggered:Connect(function(player) BaseService.LockBase(player, baseId) end))
	end
	BaseService.RefreshAllBases()
end

return BaseService
