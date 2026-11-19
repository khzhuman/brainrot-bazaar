-- One job: render server-announced floating money, timed banners, and brief buy/place/steal screen feedback.
--!strict

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local HudController = require(script.Parent:WaitForChild("HudController"))

local EffectsController = {}

function EffectsController.ShowFloatingText(position: Vector3, text: string, colour: Color3, kind: string)
	local anchor = Instance.new("Part")
	anchor.Name = "LocalFloatingText"
	anchor.Size = Vector3.new(0.1, 0.1, 0.1)
	anchor.Position = position
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.Parent = workspace
	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = anchor
	billboard.Size = if kind == "income" then UDim2.fromOffset(145, 40) else UDim2.fromOffset(330, 70)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 150
	billboard.Parent = anchor
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = colour
	label.TextStrokeColor3 = Color3.fromRGB(24, 42, 57)
	label.TextStrokeTransparency = 0.2
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = billboard
	local duration = if kind == "income" then 1.15 else 2.2
	TweenService:Create(anchor, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = position + Vector3.new(0, 3.5, 0) }):Play()
	TweenService:Create(label, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(anchor, duration + 0.1)
end

function EffectsController.ShowEventBanner(hud: HudController.Hud, text: string, duration: number)
	local generation = (hud.banner:GetAttribute("DisplayGeneration") or 0) + 1
	hud.banner:SetAttribute("DisplayGeneration", generation)
	hud.bannerText.Text = text
	hud.banner.Visible = true
	hud.banner.BackgroundColor3 = if string.find(text, "TSUNAMI", 1, true) then Color3.fromRGB(33, 126, 167) elseif string.find(text, "RACCOON", 1, true) then Color3.fromRGB(173, 73, 78) else Color3.fromRGB(41, 132, 120)
	task.delay(duration, function()
		if hud.banner.Parent and hud.banner:GetAttribute("DisplayGeneration") == generation then
			hud.banner.Visible = false
		end
	end)
end

function EffectsController.ShowScreenFeedback(hud: HudController.Hud, kind: string)
	if kind == "income" then
		return
	end
	local generation = (hud.flash:GetAttribute("DisplayGeneration") or 0) + 1
	hud.flash:SetAttribute("DisplayGeneration", generation)
	hud.flash.BackgroundColor3 = if kind == "buy" then Color3.fromRGB(255, 206, 92) elseif kind == "place" then Color3.fromRGB(99, 235, 165) elseif kind == "steal" then Color3.fromRGB(255, 127, 141) else Color3.fromRGB(255, 181, 114)
	hud.flash.BackgroundTransparency = 0.88
	task.delay(0.12, function()
		if hud.flash.Parent and hud.flash:GetAttribute("DisplayGeneration") == generation then
			TweenService:Create(hud.flash, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		end
	end)
end

function EffectsController.HandleFloatingText(hud: HudController.Hud, position: Vector3, text: string, colour: Color3, kind: string?)
	local effectKind = kind or "income"
	EffectsController.ShowFloatingText(position, text, colour, effectKind)
	EffectsController.ShowScreenFeedback(hud, effectKind)
end

return EffectsController
