local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local useEvent = Matter.useEvent

local Components = require(Shared.components)
local PlayerRef = Components.PlayerRef
local GamePlacement = Components.GamePlacement

local remotes = require(Shared.remotes)
local characterRemotes = remotes.Server:GetNamespace("Character")
local moveEvent = characterRemotes:Get("Move") :: { Connect: any }

function playerUpdatesPlacement(world: Matter.World)
	for _, player, position, orientation in useEvent(moveEvent, moveEvent.Connect) do
		for id, playerRef, gamePlacement in world:query(PlayerRef, GamePlacement) do
			if playerRef.instance ~= player then
				continue
			end

			world:insert(
				id,
				GamePlacement({
					position = Vector3.new(position.X, position.Y, position.Z),
					orientation = orientation,
				})
			)
		end
	end
end

return {
	system = playerUpdatesPlacement,
}
