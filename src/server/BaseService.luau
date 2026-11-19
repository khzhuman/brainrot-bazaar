-- One job: assign safe bases, place carried brainrots, unlock milestone pads, and sell timed shield domes.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterCatalog"))
local GameState = require(script.Parent:WaitForChild("GameState"))

local BaseService = {}
local FREE = Color3.fromRGB(153, 255, 215)
local LOCKED = Color3.fromRGB(121, 119, 116)

function BaseService.RefreshBase(baseId: number)
	local base = GameState.World.bases[baseId]
	local owner = GameState.FindBaseOwner(baseId)
	local state = if owner then GameState.GetPlayerState(owner) else nil
	for _, label in base.ownerLabels do
		label.Text = if owner and state then owner.DisplayName .. "'S BASE " .. baseId .. (if state.rebirths > 0 then "\n♛ " .. state.rebirths .. " REBIRTHS  /  x" .. string.format("%.2f", Catalog.GetRebirthMultiplier(state.rebirths)) else "\nSAFE ZONE") else "AVAILABLE BASE " .. baseId
	end
	local shieldActive = owner ~= nil and GameState.IsShieldActive(owner)
	base.dome.Transparency = if shieldActive then 0.55 else 1
	base.lockButton.Color = if shieldActive then Color3.fromRGB(91, 224, 255) else Color3.fromRGB(50, 177, 176)
	base.lockLabel.Text = if shieldActive and state then "SHIELD ON\n" .. math.max(0, math.ceil(state.lockExpiresAt - workspace:GetServerTimeNow())) .. "s remaining" else "SHIELD $250\n60 seconds"
	for padIndex, pad in base.pads do
		local unlocked = state ~= nil and state.maxCash >= pad.milestone
		local character = if state then state.placed[padIndex] else nil
		pad.light.Enabled = unlocked and character == nil
		pad.part.Material = if unlocked then Enum.Material.Neon else Enum.Material.Slate
		pad.rim.Material = if unlocked then Enum.Material.Neon else Enum.Material.Metal
		pad.part.Color = if character then Color3.fromRGB(236, 210, 146) elseif unlocked then FREE else LOCKED
		pad.label.TextColor3 = if unlocked then FREE else Color3.fromRGB(189, 180, 164)
		if character and state then
			local rate = Catalog.GetCharacterRate(character.id, character.mutation) * Catalog.GetRebirthMultiplier(state.rebirths)
			pad.label.Text = "PAD " .. padIndex .. "\nPRINTING +$" .. string.format("%g", rate) .. "/s"
		elseif unlocked then
			pad.label.Text = "PAD " .. padIndex .. "\nPLACE HERE"
		elseif pad.milestone > 0 then
			pad.label.Text = "LOCKED - reach $" .. Catalog.FormatMoney(pad.milestone)
		else
			pad.label.Text = "PAD " .. padIndex .. "\nWAITING FOR OWNER"
		end
	end
end

function BaseService.AssignBase(player: Player): boolean
	local state = GameState.GetPlayerState(player)
	if not state then
		return false
	end
	if state.baseId then
		return true
	end
	for baseId, base in GameState.World.bases do
		if not GameState.FindBaseOwner(baseId) then
			state.baseId = baseId
			base.spawn.Enabled = true
			player.RespawnLocation = base.spawn
			GameState.PublishPlayer(player)
			BaseService.RefreshBase(baseId)
			return true
		end
	end
	GameState.Remotes.ShowBanner:FireClient(player, "ALL SIX BASES ARE FULL - a base opens when an owner leaves", 7)
	return false
end

function BaseService.SendCharacterToBase(player: Player, character: Model)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local state = GameState.GetPlayerState(player)
	if not root or not root:IsA("BasePart") or not state then
		return
	end
	if state.baseId then
		local base = GameState.World.bases[state.baseId]
		local position = base.spawn.Position + Vector3.new(0, 4, 0)
		local direction = if base.position.Z < 0 then Vector3.new(0, 0, 1) else Vector3.new(0, 0, -1)
		character:PivotTo(CFrame.lookAt(position, position + direction))
	else
		character:PivotTo(CFrame.new(0, 7, 23))
	end
	if humanoid then
		humanoid.WalkSpeed = 23
		humanoid.Died:Connect(function()
			local currentState = GameState.GetPlayerState(player)
			if currentState then
				GameState.DestroyCharacter(currentState.carried)
				currentState.carried = nil
				GameState.PublishPlayer(player)
			end
		end)
	end
end

function BaseService.PlaceCarriedCharacter(player: Player, baseId: number, padIndex: number)
	local state = GameState.GetPlayerState(player)
	local base = GameState.World.bases[baseId]
	local pad = base.pads[padIndex]
	if not state or state.baseId ~= baseId or not state.carried or state.placed[padIndex] or not GameState.IsPlayerNear(player, pad.part.Position, 8) then
		return
	end
	if not GameState.CanInteract(player, "place", 0.4) then
		return
	end
	if state.maxCash < pad.milestone then
		GameState.Remotes.FloatingText:FireClient(player, pad.part.Position, "LOCKED - reach $" .. Catalog.FormatMoney(pad.milestone), Color3.fromRGB(255, 176, 111), "warn")
		return
	end
	local character = state.carried
	state.carried = nil
	state.placed[padIndex] = character
	character.model.PrimaryPart.CanTouch = false
	local rotation = if base.position.Z < 0 then CFrame.Angles(0, math.pi, 0) else CFrame.identity
	character.model:PivotTo(CFrame.new(pad.part.Position + Vector3.new(0, 0.25, 0)) * rotation)
	GameState.PublishPlayer(player)
	BaseService.RefreshBase(baseId)
	GameState.Remotes.FloatingText:FireClient(player, pad.part.Position + Vector3.new(0, 3, 0), "PLACED! MONEY PRINTER ONLINE", FREE, "place")
end

function BaseService.ActivateShield(player: Player, baseId: number)
	local state = GameState.GetPlayerState(player)
	local base = GameState.World.bases[baseId]
	if not state or state.baseId ~= baseId or not GameState.IsPlayerNear(player, base.lockButton.Position, 10) or not GameState.CanInteract(player, "shield", 1) then
		return
	end
	if GameState.IsShieldActive(player) then
		GameState.Remotes.FloatingText:FireClient(player, base.lockButton.Position, "SHIELD ALREADY ACTIVE", FREE, "warn")
		return
	end
	if not GameState.SpendCash(player, 250) then
		GameState.Remotes.FloatingText:FireClient(player, base.lockButton.Position, "Need $250", Color3.fromRGB(255, 160, 126), "warn")
		return
	end
	state.lockExpiresAt = workspace:GetServerTimeNow() + 60
	GameState.PublishPlayer(player)
	BaseService.RefreshBase(baseId)
	GameState.Remotes.FloatingText:FireClient(player, base.lockButton.Position + Vector3.new(0, 3, 0), "SHIELD UP - 60s", Color3.fromRGB(118, 227, 255), "place")
end

function BaseService.ReleaseBaseAndAssignWaitingPlayers(baseId: number?)
	if baseId then
		GameState.World.bases[baseId].spawn.Enabled = false
		BaseService.RefreshBase(baseId)
	end
	for player, state in GameState.Players do
		if not state.baseId and BaseService.AssignBase(player) and player.Character then
			BaseService.SendCharacterToBase(player, player.Character)
		end
	end
end

function BaseService.Start()
	for baseId, base in GameState.World.bases do
		for padIndex, pad in base.pads do
			pad.part.Touched:Connect(function(hit: BasePart)
				local player = GameState.GetPlayerFromTouch(hit)
				if player then
					BaseService.PlaceCarriedCharacter(player, baseId, padIndex)
				end
			end)
		end
		base.lockButton.Touched:Connect(function(hit: BasePart)
			local player = GameState.GetPlayerFromTouch(hit)
			if player then
				BaseService.ActivateShield(player, baseId)
			end
		end)
		base.lockPrompt.Triggered:Connect(function(player: Player)
			BaseService.ActivateShield(player, baseId)
		end)
		BaseService.RefreshBase(baseId)
	end
end

return BaseService
