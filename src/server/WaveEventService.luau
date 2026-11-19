-- One job: warn every three minutes, sweep a tsunami through the market, and remove unsafe carried brainrots.
--!strict

local RunService = game:GetService("RunService")
local GameState = require(script.Parent:WaitForChild("GameState"))
local ShopService = require(script.Parent:WaitForChild("ShopService"))

local WaveEventService = {}

function WaveEventService.WarnAboutIncomingTsunami()
	GameState.Wave.phase = "warning"
	GameState.Wave.startsAt = os.clock() + 10
	GameState.Wave.nextAt += 180
	GameState.Remotes.ShowBanner:FireAllClients("TSUNAMI INCOMING - DASH TO YOUR BASE!", 10)
end

function WaveEventService.RemoveUnsafeCarriedCharacters()
	for player, state in GameState.Players do
		local root = GameState.GetPlayerRoot(player)
		if state.carried and (not root or not GameState.IsPositionInSafeZone(root.Position)) then
			GameState.DestroyCharacter(state.carried)
			state.carried = nil
			GameState.PublishPlayer(player)
			if root then
				GameState.Remotes.FloatingText:FireClient(player, root.Position + Vector3.new(0, 4, 0), "WASHED AWAY! Your base is the safe zone", Color3.fromRGB(116, 214, 255), "steal")
			end
		end
	end
end

function WaveEventService.StartTsunamiSweep()
	GameState.Wave.phase = "sweeping"
	GameState.Wave.startsAt = os.clock()
	GameState.Wave.endsAt = os.clock() + 9
	ShopService.ClearParade()
	local wave = Instance.new("Part")
	wave.Name = "MarketTsunami"
	wave.Size = Vector3.new(17, 25, 72)
	wave.Position = GameState.World.waveStart
	wave.Anchored = true
	wave.CanCollide = false
	wave.CanTouch = false
	wave.CanQuery = false
	wave.Material = Enum.Material.Glass
	wave.Color = Color3.fromRGB(75, 202, 227)
	wave.Transparency = 0.38
	wave.Parent = GameState.World.events
	GameState.Wave.part = wave
	GameState.Remotes.ShowBanner:FireAllClients("TSUNAMI! STAY INSIDE A BASE SAFE ZONE", 9)
	WaveEventService.RemoveUnsafeCarriedCharacters()
end

function WaveEventService.FinishTsunamiSweep()
	if GameState.Wave.part then
		GameState.Wave.part:Destroy()
		GameState.Wave.part = nil
	end
	GameState.Wave.phase = "calm"
	ShopService.SpawnParade()
	GameState.Remotes.ShowBanner:FireAllClients("COAST CLEAR - THE BAZAAR IS OPEN AGAIN!", 4)
end

function WaveEventService.UpdateTsunamiClock()
	local now = os.clock()
	if GameState.Wave.phase == "calm" and now >= GameState.Wave.nextAt then
		WaveEventService.WarnAboutIncomingTsunami()
	elseif GameState.Wave.phase == "warning" and now >= GameState.Wave.startsAt then
		WaveEventService.StartTsunamiSweep()
	elseif GameState.Wave.phase == "sweeping" then
		local progress = math.clamp((now - GameState.Wave.startsAt) / 9, 0, 1)
		if GameState.Wave.part then
			GameState.Wave.part.Position = GameState.World.waveStart:Lerp(GameState.World.waveEnd, progress)
		end
		WaveEventService.RemoveUnsafeCarriedCharacters()
		if now >= GameState.Wave.endsAt then
			WaveEventService.FinishTsunamiSweep()
		end
	end
end

function WaveEventService.Start()
	GameState.Wave.nextAt = os.clock() + 180
	RunService.Heartbeat:Connect(WaveEventService.UpdateTsunamiClock)
end

return WaveEventService
