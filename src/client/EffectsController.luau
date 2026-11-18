-- One job: turn server display events into floating world text, timed banners, and brief buy/place/steal screen feedback.
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local EffectsController = {}
local COLORS = table.freeze({
	Income = Color3.fromRGB(130, 255, 168), Buy = Color3.fromRGB(255, 211, 82),
	Place = Color3.fromRGB(116, 255, 211), Steal = Color3.fromRGB(255, 137, 112),
	Shield = Color3.fromRGB(110, 231, 255), Rebirth = Color3.fromRGB(255, 224, 121),
	Error = Color3.fromRGB(255, 117, 112), Info = Color3.fromRGB(255, 247, 221),
	Wave = Color3.fromRGB(100, 227, 255), Thief = Color3.fromRGB(255, 143, 115), Success = Color3.fromRGB(147, 255, 199),
})

function EffectsController.ShowScreenFeedback(hud, style: string)
	if style ~= "Buy" and style ~= "Place" and style ~= "Steal" and style ~= "Rebirth" and style ~= "Shield" and style ~= "Error" then return end
	local flash = Instance.new("Frame")
	flash.Name = "InteractionFlash"; flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = COLORS[style]; flash.BackgroundTransparency = 0.87; flash.BorderSizePixel = 0
	flash.ZIndex = 0; flash.Active = false; flash.Parent = hud.Gui
	TweenService:Create(flash, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
	Debris:AddItem(flash, 0.4)
end

function EffectsController.ShowFloatingText(hud, text: string, position: Vector3, style: string?)
	local kind = style or "Info"
	local anchor = Instance.new("Part")
	anchor.Name = "LocalFloatingTextAnchor"; anchor.Size = Vector3.new(0.1, 0.1, 0.1); anchor.Position = position
	anchor.Anchored = true; anchor.Transparency = 1; anchor.CanCollide = false; anchor.CanTouch = false; anchor.CanQuery = false
	anchor.Parent = workspace
	local gui = Instance.new("BillboardGui")
	gui.Name = "FloatingText"; gui.Adornee = anchor; gui.Size = UDim2.fromOffset(330, 60)
	gui.AlwaysOnTop = true; gui.LightInfluence = 0; gui.MaxDistance = 140; gui.Parent = anchor
	local label = Instance.new("TextLabel")
	label.Name = "Message"; label.Size = UDim2.fromScale(1, 1); label.BackgroundTransparency = 1
	label.Text = text; label.TextColor3 = COLORS[kind] or COLORS.Info
	label.Font = Enum.Font.GothamBold; label.TextSize = if #text > 35 then 16 else 23
	label.TextWrapped = true; label.TextStrokeColor3 = Color3.fromRGB(30, 50, 61); label.TextStrokeTransparency = 0.2; label.Parent = gui
	TweenService:Create(gui, TweenInfo.new(1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0) }):Play()
	TweenService:Create(label, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.65), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(anchor, 1.3)
	EffectsController.ShowScreenFeedback(hud, kind)
end

function EffectsController.ShowBanner(hud, message: string, duration: number?, style: string?)
	hud.BannerVersion += 1
	local version = hud.BannerVersion
	hud.BannerLabel.Text = message; hud.BannerLabel.TextColor3 = COLORS[style or "Info"] or COLORS.Info
	hud.Banner.Visible = true
	task.delay(math.clamp(duration or 5, 1, 30), function()
		if hud.BannerVersion == version then hud.Banner.Visible = false end
	end)
end

return EffectsController
