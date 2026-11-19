-- One job: display a compact centred cash HUD, event banner, and contextual carrying hint from server attributes.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterCatalog"))

export type Hud = {
	gui: ScreenGui,
	cashPanel: Frame,
	cash: TextLabel,
	income: TextLabel,
	rebirth: TextLabel,
	base: TextLabel,
	banner: Frame,
	bannerText: TextLabel,
	hint: TextLabel,
	flash: Frame,
}

local HudController = {}
local CREAM = Color3.fromRGB(255, 243, 211)
local INK = Color3.fromRGB(24, 52, 69)

local function roundPanel(frame: Frame, radius: number, colour: Color3)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Color = colour
	stroke.Thickness = 1.5
	stroke.Transparency = 0.28
	stroke.Parent = frame
end

local function buildText(parent: Instance, name: string, text: string, position: UDim2, size: UDim2, colour: Color3, textSize: number): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = text
	label.Position = position
	label.Size = size
	label.TextColor3 = colour
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = textSize
	label.TextScaled = true
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = 10
	constraint.MaxTextSize = textSize
	constraint.Parent = label
	label.Parent = parent
	return label
end

local function readNumberAttribute(player: Player, name: string, fallback: number): number
	local value = player:GetAttribute(name)
	return if typeof(value) == "number" then value else fallback
end

function HudController.BuildHud(player: Player): Hud
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotBazaarHud"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.DisplayOrder = 10
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")
	local panel = Instance.new("Frame")
	panel.Name = "CashPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.new(0.5, 0, 0, 10)
	panel.Size = UDim2.new(0.8, 0, 0, 114)
	panel.BackgroundColor3 = INK
	panel.BackgroundTransparency = 0.08
	panel.BorderSizePixel = 0
	panel.Parent = gui
	roundPanel(panel, 15, Color3.fromRGB(255, 207, 82))
	local panelSize = Instance.new("UISizeConstraint")
	panelSize.MaxSize = Vector2.new(420, 114)
	panelSize.Parent = panel
	buildText(panel, "GameTitle", "BRAINROT BAZAAR", UDim2.fromScale(0.07, 0.06), UDim2.fromScale(0.86, 0.16), Color3.fromRGB(255, 208, 101), 13)
	local cash = buildText(panel, "Cash", "$ 100", UDim2.fromScale(0.04, 0.24), UDim2.fromScale(0.92, 0.36), CREAM, 34)
	local income = buildText(panel, "IncomePerSecond", "+$0/s", UDim2.fromScale(0.06, 0.66), UDim2.fromScale(0.4, 0.18), Color3.fromRGB(143, 245, 184), 18)
	local rebirth = buildText(panel, "RebirthMultiplier", "Rebirth x1", UDim2.fromScale(0.49, 0.66), UDim2.fromScale(0.46, 0.18), Color3.fromRGB(255, 214, 115), 16)
	local base = buildText(panel, "BaseAndShrine", "YOUR BASE IS GETTING READY", UDim2.fromScale(0.04, 0.86), UDim2.fromScale(0.92, 0.1), Color3.fromRGB(173, 216, 225), 11)
	local banner = Instance.new("Frame")
	banner.Name = "EventBanner"
	banner.AnchorPoint = Vector2.new(0.5, 0)
	banner.Position = UDim2.new(0.5, 0, 0, 133)
	banner.Size = UDim2.new(0.92, 0, 0, 58)
	banner.BackgroundColor3 = Color3.fromRGB(207, 88, 73)
	banner.BackgroundTransparency = 0.06
	banner.BorderSizePixel = 0
	banner.Visible = false
	banner.Parent = gui
	roundPanel(banner, 12, Color3.fromRGB(255, 222, 161))
	local bannerSize = Instance.new("UISizeConstraint")
	bannerSize.MaxSize = Vector2.new(740, 58)
	bannerSize.Parent = banner
	local bannerText = buildText(banner, "Announcement", "", UDim2.fromScale(0.03, 0.1), UDim2.fromScale(0.94, 0.8), CREAM, 23)
	bannerText.TextWrapped = true
	local hintPanel = Instance.new("Frame")
	hintPanel.Name = "HintPanel"
	hintPanel.AnchorPoint = Vector2.new(0.5, 1)
	hintPanel.Position = UDim2.new(0.5, 0, 1, -18)
	hintPanel.Size = UDim2.new(0.94, 0, 0, 56)
	hintPanel.BackgroundColor3 = INK
	hintPanel.BackgroundTransparency = 0.18
	hintPanel.BorderSizePixel = 0
	hintPanel.Parent = gui
	roundPanel(hintPanel, 12, Color3.fromRGB(99, 218, 206))
	local hintSize = Instance.new("UISizeConstraint")
	hintSize.MaxSize = Vector2.new(890, 56)
	hintSize.Parent = hintPanel
	local hint = buildText(hintPanel, "CarryHint", "Touch a brainrot to buy it - carry it to a glowing pad at your base", UDim2.fromScale(0.025, 0.12), UDim2.fromScale(0.95, 0.76), CREAM, 18)
	hint.TextWrapped = true
	local flash = Instance.new("Frame")
	flash.Name = "ScreenFeedback"
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundTransparency = 1
	flash.BorderSizePixel = 0
	flash.ZIndex = 30
	flash.Parent = gui
	local hud: Hud = { gui = gui, cashPanel = panel, cash = cash, income = income, rebirth = rebirth, base = base, banner = banner, bannerText = bannerText, hint = hint, flash = flash }
	HudController.UpdateHud(player, hud)
	return hud
end

function HudController.UpdateHud(player: Player, hud: Hud)
	local cash = readNumberAttribute(player, "Cash", 100)
	local income = readNumberAttribute(player, "IncomePerSecond", 0)
	local multiplier = readNumberAttribute(player, "RebirthMultiplier", 1)
	local baseId = readNumberAttribute(player, "BaseId", 0)
	local rebirthCost = readNumberAttribute(player, "RebirthCost", 10000)
	hud.cash.Text = "$ " .. Catalog.FormatMoney(cash)
	hud.income.Text = "+$" .. (if income % 1 == 0 then Catalog.FormatMoney(income) else string.format("%.2f", income)) .. "/s"
	hud.rebirth.Text = "Rebirth x" .. string.format("%g", multiplier)
	hud.base.Text = (if baseId > 0 then "YOUR BASE: " .. baseId else "WAITING FOR A BASE") .. "   /   NEXT REBIRTH: $" .. Catalog.FormatMoney(rebirthCost)
	local carriedName = player:GetAttribute("CarriedName")
	if typeof(carriedName) == "string" and carriedName ~= "" then
		hud.hint.Text = "Carrying " .. carriedName .. " - touch a glowing pad at BASE " .. baseId .. " to print money"
	else
		hud.hint.Text = "Touch a brainrot to buy it - carry it to a glowing pad at your base"
	end
end

function HudController.ConnectServerAttributes(player: Player, hud: Hud)
	for _, attribute in { "Cash", "IncomePerSecond", "RebirthMultiplier", "BaseId", "RebirthCost", "CarriedName" } do
		player:GetAttributeChangedSignal(attribute):Connect(function()
			HudController.UpdateHud(player, hud)
		end)
	end
end

return HudController
