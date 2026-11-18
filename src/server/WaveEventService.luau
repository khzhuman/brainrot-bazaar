-- One job: warn every three minutes, sweep the central plaza with a tsunami, and remove unsafe carried creatures.
local RunService = game:GetService("RunService")
local GameState = require(script.Parent.GameState)
local ShopService = require(script.Parent.ShopService)
local WaveEventService = {}

function WaveEventService.RemoveUnsafeCarriedCharacters()
	for player, data in GameState.Players do
		local root = GameState.GetPlayerRoot(player)
		if data.Carried and root and not GameState.IsInsideAnyBase(root.Position) then
			GameState.ClearCarried(player)
			GameState.ShowText(player, "WASHED AWAY! Stay in a base safe zone", root.Position + Vector3.new(0, 4, 0), "Error")
		end
	end
end

function WaveEventService.SweepWave()
	GameState.WaveActive = true; GameState.WaveStarted = os.clock()
	ShopService.ClearParade()
	local wave = Instance.new("Part")
	wave.Name = "TsunamiWave"; wave.Size = Vector3.new(102, 28, 12)
	wave.Position = GameState.World.WaveStart; wave.Color = Color3.fromRGB(72, 205, 236)
	wave.Material = Enum.Material.Glass; wave.Transparency = 0.35; wave.Reflectance = 0.15
	wave.Anchored = true; wave.CanCollide = false; wave.CanTouch = false; wave.CanQuery = false
	wave.Parent = GameState.World.Model; GameState.WavePart = wave
	GameState.Remotes.ShowBanner:FireAllClients("TSUNAMI! STAY IN A BASE SAFE ZONE", 9, "Wave")
	while os.clock() - GameState.WaveStarted < 9 do
		local alpha = math.clamp((os.clock() - GameState.WaveStarted) / 9, 0, 1)
		GameState.WavePart.Position = GameState.World.WaveStart:Lerp(GameState.World.WaveEnd, alpha)
		WaveEventService.RemoveUnsafeCarriedCharacters()
		RunService.Heartbeat:Wait()
	end
	GameState.WavePart:Destroy(); GameState.WavePart = nil; GameState.WaveActive = false
	ShopService.RestartParade()
	GameState.Remotes.ShowBanner:FireAllClients("THE COAST IS CLEAR - PARADE IS BACK!", 4, "Success")
end

function WaveEventService.AnnounceAndRunWave()
	GameState.Remotes.ShowBanner:FireAllClients("TSUNAMI INCOMING - DASH TO YOUR BASE!", 10, "Wave")
	task.wait(10)
	WaveEventService.SweepWave()
end

function WaveEventService.Start()
	GameState.NextWave = os.clock() + 180
	task.spawn(function()
		while task.wait(0.5) do
			if os.clock() >= GameState.NextWave then
				GameState.NextWave += 180
				WaveEventService.AnnounceAndRunWave()
			end
		end
	end)
end

return WaveEventService
