-- One job: display replicated cash, income, rebirth progress, event banners, and carrying hints clear of Roblox's menu.
local Catalog = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("CharacterCatalog"))
local HudController = {}
local INK = Color3.fromRGB(31, 52, 66)
local CREAM = Color3.fromRGB(255, 244, 214)
local AQUA = Color3.fromRGB(111, 243, 216)
local GOLD = Color3.fromRGB(255, 211, 90)

function HudController.AddLabel(parent: Instance, name: string, position: UDim2, size: UDim2, textSize: number, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name; label.Position = position; label.Size = size; label.BackgroundTransparency = 1
	label.TextColor3 = color; label.Font = Enum.Font.GothamBold; label.TextSize = textSize
	label.Text = ""; label.Parent = parent
	return label
end

function HudController.AddRoundedPanel(parent: Instance, name: string, position: UDim2, size: UDim2, anchor: Vector2): Frame
	local panel = Instance.new("Frame")
	panel.Name = name; panel.Position = position; panel.Size = size; panel.AnchorPoint = anchor
	panel.BackgroundColor3 = INK; panel.BackgroundTransparency = 0.12; panel.BorderSizePixel = 0; panel.Parent = parent
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 14); corner.Parent = panel
	local stroke = Instance.new("UIStroke"); stroke.Color = GOLD; stroke.Transparency = 0.5; stroke.Thickness = 1.5; stroke.Parent = panel
	return panel
end

function HudController.FormatMultiplier(multiplier: number): string
	return string.format("%.2f", multiplier):gsub("0+$", ""):gsub("%.$", "")
end

function HudController.Refresh(hud, player: Player)
	local cash = player:GetAttribute("Cash") or 100
	local income = player:GetAttribute("IncomePerSecond") or 0
	local multiplier = player:GetAttribute("IncomeMultiplier") or 1
	local cost = player:GetAttribute("RebirthCost") or 10000
	local carrying = player:GetAttribute("Carrying") or ""
	local baseId = player:GetAttribute("BaseId") or 0
	hud.CashLabel.Text = "$ " .. Catalog.FormatMoney(cash)
	hud.IncomeLabel.Text = "+$" .. Catalog.FormatMoney(income) .. "/s"
	hud.MultiplierLabel.Text = "Rebirth x" .. HudController.FormatMultiplier(multiplier)
	hud.CostLabel.Text = "Next rebirth $" .. Catalog.FormatMoney(cost) .. (if baseId > 0 then "  •  BASE " .. baseId else "")
	hud.HintLabel.Text = if baseId == 0 then "Explore the bazaar - a base will be assigned when one is free" elseif carrying ~= "" then "Carrying " .. carrying .. " - touch a glowing pad at your base" else "Touch a brainrot to buy it - carry it to a glowing pad at your base"
end

function HudController.BuildHud(player: Player)
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotBazaarHud"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = false
	gui.DisplayOrder = 20; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = player:WaitForChild("PlayerGui")
	local cashPanel = HudController.AddRoundedPanel(gui, "CashPanel", UDim2.new(0.5, 0, 0, 10), UDim2.new(0.5, 0, 0, 110), Vector2.new(0.5, 0))
	local cashSize = Instance.new("UISizeConstraint"); cashSize.MinSize = Vector2.new(280, 110); cashSize.MaxSize = Vector2.new(440, 110); cashSize.Parent = cashPanel
	local title = HudController.AddLabel(cashPanel, "GameTitle", UDim2.fromOffset(10, 8), UDim2.new(1, -20, 0, 18), 12, GOLD)
	title.Text = "B R A I N R O T   B A Z A A R"
	local cash = HudController.AddLabel(cashPanel, "Cash", UDim2.fromOffset(8, 25), UDim2.new(1, -16, 0, 38), 30, CREAM)
	cash.TextScaled = true
	local cashTextSize = Instance.new("UITextSizeConstraint"); cashTextSize.MaxTextSize = 32; cashTextSize.MinTextSize = 18; cashTextSize.Parent = cash
	local income = HudController.AddLabel(cashPanel, "IncomePerSecond", UDim2.new(0, 12, 0, 66), UDim2.new(0.5, -12, 0, 20), 16, AQUA)
	local multiplier = HudController.AddLabel(cashPanel, "RebirthMultiplier", UDim2.new(0.5, 0, 0, 66), UDim2.new(0.5, -12, 0, 20), 15, GOLD)
	local cost = HudController.AddLabel(cashPanel, "RebirthCost", UDim2.fromOffset(8, 88), UDim2.new(1, -16, 0, 17), 11, Color3.fromRGB(191, 211, 211))
	local banner = HudController.AddRoundedPanel(gui, "EventBanner", UDim2.new(0.5, 0, 0, 131), UDim2.new(0.82, 0, 0, 64), Vector2.new(0.5, 0))
	local bannerSize = Instance.new("UISizeConstraint"); bannerSize.MinSize = Vector2.new(280, 64); bannerSize.MaxSize = Vector2.new(830, 64); bannerSize.Parent = banner
	local bannerLabel = HudController.AddLabel(banner, "Message", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 1, -16), 20, CREAM)
	bannerLabel.TextWrapped = true; bannerLabel.TextScaled = true; banner.Visible = false
	local bannerTextSize = Instance.new("UITextSizeConstraint"); bannerTextSize.MaxTextSize = 21; bannerTextSize.MinTextSize = 12; bannerTextSize.Parent = bannerLabel
	local hintPanel = HudController.AddRoundedPanel(gui, "HintPanel", UDim2.new(0.5, 0, 1, -16), UDim2.new(0.85, 0, 0, 52), Vector2.new(0.5, 1))
	local hintSize = Instance.new("UISizeConstraint"); hintSize.MinSize = Vector2.new(280, 52); hintSize.MaxSize = Vector2.new(920, 52); hintSize.Parent = hintPanel
	local hint = HudController.AddLabel(hintPanel, "Hint", UDim2.fromOffset(12, 6), UDim2.new(1, -24, 1, -12), 15, CREAM)
	hint.TextWrapped = true
	local hud = { Gui = gui, CashLabel = cash, IncomeLabel = income, MultiplierLabel = multiplier, CostLabel = cost, HintLabel = hint, Banner = banner, BannerLabel = bannerLabel, BannerVersion = 0 }
	for _, attribute in { "Cash", "IncomePerSecond", "IncomeMultiplier", "RebirthCost", "Rebirths", "Carrying", "BaseId" } do
		player:GetAttributeChangedSignal(attribute):Connect(function() HudController.Refresh(hud, player) end)
	end
	HudController.Refresh(hud, player)
	return hud
end

return HudController
