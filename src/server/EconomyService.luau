-- One job: pay placed brainrots every second and publish accurate cash, income, and pad income effects.
--!strict

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterCatalog"))
local GameState = require(script.Parent:WaitForChild("GameState"))
local BaseService = require(script.Parent:WaitForChild("BaseService"))

local EconomyService = {}

function EconomyService.PayOneSecondOfIncome()
	for player, state in GameState.Players do
		local multiplier = Catalog.GetRebirthMultiplier(state.rebirths)
		local total = GameState.ComputeIncomePerSecond(player)
		GameState.AddCash(player, total)
		for _, character in state.placed do
			local payout = Catalog.GetCharacterRate(character.id, character.mutation) * multiplier
			local text = if payout % 1 == 0 then Catalog.FormatMoney(payout) else string.format("%.2f", payout)
			GameState.Remotes.FloatingText:FireClient(player, character.model:GetPivot().Position + Vector3.new(0, 3, 0), "+$" .. text, Color3.fromRGB(156, 255, 179), "income")
		end
		if state.baseId then
			BaseService.RefreshBase(state.baseId)
		end
	end
end

function EconomyService.UpdateIncomeClock()
	if os.clock() >= GameState.NextIncomeAt then
		GameState.NextIncomeAt = os.clock() + 1
		EconomyService.PayOneSecondOfIncome()
	end
end

function EconomyService.Start()
	GameState.NextIncomeAt = os.clock() + 1
	RunService.Heartbeat:Connect(EconomyService.UpdateIncomeClock)
end

return EconomyService
