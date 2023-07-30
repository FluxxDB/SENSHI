--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared

local Matter = require(ReplicatedStorage.Packages.Matter)

local Components = require(Shared.components)
local PlayerRef = Components.PlayerRef
local Model = Components.Model

local remotes = require(Shared.remotes)
local characterRemotes = remotes.Client:GetNamespace("Character")
local spawnEvent = characterRemotes:Get("Spawn") :: { SendToServer: (...any) -> () }

local localPlayer = Players.LocalPlayer
local useThrottle = Matter.useThrottle
local characterBases = ReplicatedStorage.Assets.CharacterBases
local charactersFolder = Workspace.Entities.Characters

local function assignCharacter(player: Player, characterRigName: string)
	if player.Character then
		warn("Attempted to spawn new character while one already exists? wtf?")
		return player.Character
	end

	local character = characterBases[characterRigName]:Clone()
	character.Parent = charactersFolder

	localPlayer.Character = character

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	humanoid.Died:Connect(function()
		character:Destroy()
	end)

	return character
end

local function spawnCharacters(world: Matter.World)
	if not localPlayer.Character and useThrottle(60) then
		spawnEvent:SendToServer()
	end

	for id, player, model in world:query(PlayerRef, Model) do
		if model.instance then
			continue
		end

		local character = assignCharacter(player.instance, "Default") -- "Default" for testing
		world:insert(
			id,
			model:patch({
				instance = character,
			})
		)
	end
end

return spawnCharacters
