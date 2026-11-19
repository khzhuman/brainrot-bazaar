-- One job: create display remotes, build the bazaar, assign joining players, and start every server service.
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameState = require(script:WaitForChild("GameState"))
local WorldBuilder = require(script:WaitForChild("WorldBuilder"))
local BaseService = require(script:WaitForChild("BaseService"))
local ShopService = require(script:WaitForChild("ShopService"))
local EconomyService = require(script:WaitForChild("EconomyService"))
local WaveEventService = require(script:WaitForChild("WaveEventService"))
local ThiefService = require(script:WaitForChild("ThiefService"))
local RebirthService = require(script:WaitForChild("RebirthService"))

local function buildBrainrotRemotes(): { ShowBanner: RemoteEvent, FloatingText: RemoteEvent }
	local folder = Instance.new("Folder")
	folder.Name = "BrainrotRemotes"
	folder.Parent = ReplicatedStorage
	local showBanner = Instance.new("RemoteEvent")
	showBanner.Name = "ShowBanner"
	showBanner.Parent = folder
	local floatingText = Instance.new("RemoteEvent")
	floatingText.Name = "FloatingText"
	floatingText.Parent = folder
	return { ShowBanner = showBanner, FloatingText = floatingText }
end

local function registerPlayerAndAssignBase(player: Player)
	if GameState.GetPlayerState(player) then
		return
	end
	GameState.RegisterPlayer(player)
	BaseService.AssignBase(player)
	player.CharacterAdded:Connect(function(character: Model)
		BaseService.SendCharacterToBase(player, character)
	end)
	if player.Character then
		task.spawn(BaseService.SendCharacterToBase, player, player.Character)
	end
end

local function releaseLeavingPlayer(player: Player)
	local state = GameState.GetPlayerState(player)
	local baseId = if state then state.baseId else nil
	GameState.UnregisterPlayer(player)
	BaseService.ReleaseBaseAndAssignWaitingPlayers(baseId)
end

local function startBrainrotBazaar()
	GameState.Remotes = buildBrainrotRemotes()
	GameState.World = WorldBuilder.BuildWorld()
	BaseService.Start()
	ShopService.Start()
	EconomyService.Start()
	WaveEventService.Start()
	ThiefService.Start()
	RebirthService.Start()
	Players.PlayerAdded:Connect(registerPlayerAndAssignBase)
	Players.PlayerRemoving:Connect(releaseLeavingPlayer)
	Players.CharacterAutoLoads = true
	for _, player in Players:GetPlayers() do
		registerPlayerAndAssignBase(player)
	end
	print("BRAINROT BAZAAR is open: 12 brainrots, 6 safe bases, and an extremely suspicious raccoon.")
end

startBrainrotBazaar()
