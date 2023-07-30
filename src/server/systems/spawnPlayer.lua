--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local useEvent = Matter.useEvent

local Signal = require(Packages.Signal)
local characterAdded = Signal.new()

local Components = require(Shared.components)
local PlayerRef = Components.PlayerRef
local Model = Components.Model
local Health = Components.Health
local GamePlacement = Components.GamePlacement

local remotes = require(Shared.remotes)
local characterRemotes = remotes.Server:GetNamespace("Character")
local spawnEvent = characterRemotes:Get("Spawn") :: { Connect: any }

local function spawnPlayer(world: Matter.World)
	local random = Random.new()
	for _, player in useEvent(spawnEvent.Connect, spawnEvent) do
		print("hi")
		local playerId
		for id, playerRef in world:query(PlayerRef) do
			if playerRef.instance == player then
				playerId = id
				break
			end
		end

		if playerId then
			break
		end

		local characterId = world:spawn(
			PlayerRef({
				instance = player,
			}),
			Model({
				modelId = 0,
			}),
			Health({
				hitPoints = 5,
				maxHitPoints = 10,
			}),
			GamePlacement({
				position = Vector2.new(random:NextNumber(-50, 50) * 2048, random:NextNumber(-50, 50) * 2048),
				-- position = Vector2.new(0, 0),
				orientation = 0,
			})
		)

		task.defer(characterAdded.Fire, characterAdded, player, characterId)
	end
end

return {
	system = spawnPlayer,
	events = {
		characterAdded = characterAdded,
	},
}
