-- One job: exchange a run's cash and collection for a permanent, compounding rebirth income multiplier.
local GameState = require(script.Parent.GameState)
local BaseService = require(script.Parent.BaseService)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.CharacterCatalog)
local RebirthService = {}

function RebirthService.RebirthPlayer(player: Player)
	local data = GameState.Players[player]
	local root = GameState.GetPlayerRoot(player)
	local altar = GameState.World.RebirthAltar
	if not data or not data.BaseId or not root or (root.Position - altar.Position).Magnitude > 10 then return end
	if not GameState.CanInteract(player, "Rebirth", 3) then return end
	local cost = 10000 * 5 ^ data.Rebirths
	if data.Cash < cost then
		GameState.ShowText(player, "Rebirth needs $" .. Catalog.FormatMoney(cost), altar.Position + Vector3.new(0, 5, 0), "Error")
		return
	end
	GameState.ClearCollection(player)
	data.Rebirths += 1; data.LockExpiry = 0
	GameState.SetCash(player, 100); BaseService.RefreshBase(data.BaseId)
	GameState.ShowText(player, "REBORN! Income x" .. string.format("%.2f", GameState.GetIncomeMultiplier(player)), altar.Position + Vector3.new(0, 6, 0), "Rebirth")
	GameState.Remotes.ShowBanner:FireClient(player, "REBIRTH COMPLETE! $100 + A PERMANENT INCOME BOOST", 6, "Success")
end

function RebirthService.Start()
	GameState.TrackConnection(GameState.World.RebirthAltar.Touched:Connect(function(hit)
		local player = GameState.GetPlayerFromHit(hit)
		if player then RebirthService.RebirthPlayer(player) end
	end))
	GameState.TrackConnection(GameState.World.RebirthPrompt.Triggered:Connect(RebirthService.RebirthPlayer))
end

return RebirthService
