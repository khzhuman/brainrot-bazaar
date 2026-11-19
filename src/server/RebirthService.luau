-- One job: exchange a completed run for a permanent compounding income multiplier at the golden shrine.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterCatalog"))
local GameState = require(script.Parent:WaitForChild("GameState"))
local BaseService = require(script.Parent:WaitForChild("BaseService"))

local RebirthService = {}

function RebirthService.RebirthPlayerAtShrine(player: Player)
	local state = GameState.GetPlayerState(player)
	local shrine = GameState.World.shrine
	if not state or not state.baseId or not GameState.IsPlayerNear(player, shrine.part.Position, 10) or not GameState.CanInteract(player, "rebirth", 2.5) then
		return
	end
	local cost = Catalog.GetRebirthCost(state.rebirths)
	if state.cash < cost then
		GameState.Remotes.FloatingText:FireClient(player, shrine.part.Position + Vector3.new(0, 5, 0), "Need $" .. Catalog.FormatMoney(cost) .. " to rebirth", Color3.fromRGB(255, 203, 112), "warn")
		return
	end
	GameState.ClearCollection(player)
	state.cash = 100
	state.maxCash = 100
	state.rebirths += 1
	state.lockExpiresAt = 0
	GameState.PublishPlayer(player)
	BaseService.RefreshBase(state.baseId)
	local multiplier = Catalog.GetRebirthMultiplier(state.rebirths)
	GameState.Remotes.ShowBanner:FireClient(player, "REBORN! PERMANENT x" .. string.format("%g", multiplier) .. " INCOME - YOUR CROWN IS WAITING", 7)
	GameState.Remotes.FloatingText:FireClient(player, shrine.part.Position + Vector3.new(0, 5, 0), "♛ REBIRTH " .. state.rebirths .. "  /  x" .. string.format("%g", multiplier), Color3.fromRGB(255, 215, 88), "place")
end

function RebirthService.Start()
	GameState.World.shrine.part.Touched:Connect(function(hit: BasePart)
		local player = GameState.GetPlayerFromTouch(hit)
		if player then
			RebirthService.RebirthPlayerAtShrine(player)
		end
	end)
	GameState.World.shrine.prompt.Triggered:Connect(RebirthService.RebirthPlayerAtShrine)
end

return RebirthService
