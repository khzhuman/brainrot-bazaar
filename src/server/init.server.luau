-- One job: create display remotes, build the island, assign joining players, and start every authoritative service.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameState = require(script.GameState)
local WorldBuilder = require(script.WorldBuilder)
local BaseService = require(script.BaseService)
local EconomyService = require(script.EconomyService)
local ShopService = require(script.ShopService)
local WaveEventService = require(script.WaveEventService)
local ThiefService = require(script.ThiefService)
local RebirthService = require(script.RebirthService)

local function BuildDisplayRemotes()
	local folder = Instance.new("Folder"); folder.Name = "BrainrotRemotes"
	for _, name in { "ShowBanner", "FloatingText" } do
		local remote = Instance.new("RemoteEvent"); remote.Name = name; remote.Parent = folder
	end
	folder.Parent = ReplicatedStorage
	GameState.Remotes = { ShowBanner = folder.ShowBanner, FloatingText = folder.FloatingText }
end

local function AddPlayerAndAssignBase(player: Player)
	if GameState.Players[player] then return end
	local data = GameState.AddPlayer(player)
	BaseService.AssignAvailableBase(player)
	data.CharacterConnection = player.CharacterAdded:Connect(function(character) BaseService.HandleCharacterSpawn(player, character) end)
	if player.Character then
		task.spawn(BaseService.HandleCharacterSpawn, player, player.Character)
	else
		task.spawn(BaseService.RespawnPlayer, player)
	end
end

local function RemovePlayerAndReleaseBase(player: Player)
	BaseService.ReleaseBase(player); GameState.RemovePlayer(player)
end

Players.CharacterAutoLoads = false
BuildDisplayRemotes()
GameState.World = WorldBuilder.BuildWorld()
BaseService.Start()
ShopService.Start()
RebirthService.Start()
EconomyService.Start()
WaveEventService.Start()
ThiefService.Start()
GameState.TrackConnection(Players.PlayerAdded:Connect(AddPlayerAndAssignBase))
GameState.TrackConnection(Players.PlayerRemoving:Connect(RemovePlayerAndReleaseBase))
for _, player in Players:GetPlayers() do AddPlayerAndAssignBase(player) end
print("BRAINROT BAZAAR is open: twelve brainrots, six bases, and a very suspicious raccoon.")
