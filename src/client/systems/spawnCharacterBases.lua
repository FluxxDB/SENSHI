--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Signal = require(Packages.Signal)
local characterAdded = Signal.new()

local Components = require(Shared.components)
local PlayerRef = Components.PlayerRef
local Model = Components.Model
local GamePlacement = Components.GamePlacement

local remotes = require(Shared.remotes)
local characterRemotes = remotes.Client:GetNamespace("Character")
local spawnEvent = characterRemotes:Get("Spawn") :: { SendToServer: (...any) -> () }

local localPlayer = Players.LocalPlayer
local useThrottle = Matter.useThrottle
local characterBases = Assets.CharacterBases
local charactersFolder = Workspace.Entities.Characters

function assignCharacter(player: Player, characterRigName: string, position: Vector2)
	if player.Character ~= nil then
		warn("Attempted to create new character base when one already exists... wtf?")
		return player.Character
	end

	local character = characterBases[characterRigName]:Clone()
	character.Name = player.Name
	character.Parent = charactersFolder

	-- [TESTING]
	local rootPart = character.HumanoidRootPart
	player.Character = character

	if player ~= localPlayer then
		rootPart.Anchored = true
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	humanoid.Died:Connect(function()
		character:Destroy()
	end)

	task.defer(characterAdded.Fire, characterAdded, player, character)

	return character
end

local function spawnCharacterBases(world: Matter.World)
	if not localPlayer.Character and useThrottle(60) then
		spawnEvent:SendToServer()
	end

	for id, player, model, placement in world:query(PlayerRef, Model, Components.GamePlacement) do
		if model.instance ~= nil then
			continue
		end

		if player == nil then
			continue
		end

		local character = assignCharacter(player.instance, "Default", placement.position) -- "Default" for testing
		if character then
			world:insert(
				id,
				model:patch({
					instance = character,
				})
			)
		end
	end
end

return {
	system = spawnCharacterBases,
	events = {
		characterAdded = characterAdded,
	},
}
