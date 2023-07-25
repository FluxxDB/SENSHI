local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Components = require(Shared.components)
local constants = require(Shared.constants)

local ChunkRef = Components.ChunkRef
local Player = Components.Player

local voxelSize = constants.VOXEL_SIZE
local serverChunks = constants.CHUNKS

local function chunkUpdater(world: Matter.World)
	local players = {}
	for id, player, chunkRef in world:query(Player, ChunkRef) do
		if world:contains(id) == false then
			continue
		end

		players[player.instance] = {
			chunkRef = chunkRef,
		}
	end
end

return {
	system = chunkUpdater,
}
