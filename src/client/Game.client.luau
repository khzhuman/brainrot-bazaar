-- One job: build the display-only HUD and connect the two server display remotes to client effects.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HudController = require(script.Parent.HudController)
local EffectsController = require(script.Parent.EffectsController)
local player = Players.LocalPlayer
local hud = HudController.BuildHud(player)
local remotes = ReplicatedStorage:WaitForChild("BrainrotRemotes")

player.CameraMinZoomDistance = 8
player.CameraMaxZoomDistance = 65

remotes:WaitForChild("FloatingText").OnClientEvent:Connect(function(text, position, style)
	EffectsController.ShowFloatingText(hud, text, position, style)
end)
remotes:WaitForChild("ShowBanner").OnClientEvent:Connect(function(message, duration, style)
	EffectsController.ShowBanner(hud, message, duration, style)
end)
