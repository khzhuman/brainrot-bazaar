-- One job: pay every placed creature each second and refresh replicated cash, income, and base displays.
local GameState = require(script.Parent.GameState)
local BaseService = require(script.Parent.BaseService)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.CharacterCatalog)
local EconomyService = {}

function EconomyService.PayIncomeTick()
	for player, data in GameState.Players do
		local income = GameState.GetIncomePerSecond(player)
		GameState.SetCash(player, data.Cash + income)
		for _, brainrot in data.Placed do
			local amount = GameState.GetBrainrotRate(brainrot) * GameState.GetIncomeMultiplier(player)
			local text = if amount % 1 == 0 then Catalog.FormatMoney(amount) else string.format("%.2f", amount):gsub("0+$", ""):gsub("%.$", "")
			GameState.ShowText(player, "+$" .. text, brainrot.Model:GetPivot().Position + Vector3.new(0, 3, 0), "Income")
		end
	end
	BaseService.RefreshAllBases()
end

function EconomyService.Start()
	task.spawn(function()
		while task.wait(1) do EconomyService.PayIncomeTick() end
	end)
end

return EconomyService
