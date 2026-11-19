-- One job: bootstrap the display-only HUD and connect the two server-created brainrot effect remotes.
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HudController = require(script.Parent:WaitForChild("HudController"))
local EffectsController = require(script.Parent:WaitForChild("EffectsController"))

local function startBrainrotHud()
	local player = Players.LocalPlayer
	local hud = HudController.BuildHud(player)
	HudController.ConnectServerAttributes(player, hud)
	local remotes = ReplicatedStorage:WaitForChild("BrainrotRemotes")
	local showBanner = remotes:WaitForChild("ShowBanner") :: RemoteEvent
	local floatingText = remotes:WaitForChild("FloatingText") :: RemoteEvent
	showBanner.OnClientEvent:Connect(function(text: string, duration: number?)
		EffectsController.ShowEventBanner(hud, text, duration or 6)
	end)
	floatingText.OnClientEvent:Connect(function(position: Vector3, text: string, colour: Color3, kind: string?)
		EffectsController.HandleFloatingText(hud, position, text, colour, kind)
	end)
end

startBrainrotHud()
