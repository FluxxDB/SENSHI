--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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
local Movement = Components.Movement
local GamePlacement = Components.GamePlacement

local remotes = require(Shared.remotes)

local characterRemotes = remotes.Server:GetNamespace("Character")
local spawnEvent = characterRemotes:Get("Spawn") :: { Connect: any }

local random = Random.new()
local position = Vector3.new(25 * 2048, 150, 25 * 2048)
print(position)

function spawnPlayer(world: Matter.World)
	for _, player in useEvent(Players, "PlayerRemoving") do
		for id, playerRef in world:query(PlayerRef) do
			if playerRef.instance == player or playerRef.instance == nil then
				world:despawn(id)
			end
		end
	end

	for _, player in useEvent(spawnEvent.Connect, spawnEvent) do
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

		-- local position = Vector3.new(0, 150, 0)

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
			Movement({}),
			GamePlacement({
				position = position,
				orientation = 0,
			})
		)

		task.delay(5 / 30, characterAdded.Fire, characterAdded, player, characterId)
	end
end

return {
	system = spawnPlayer,
	events = {
		characterAdded = characterAdded,
	},
}
