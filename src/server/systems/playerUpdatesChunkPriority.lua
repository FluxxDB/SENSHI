--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local Matter = require(ReplicatedStorage.Packages.Matter)

local Components = require(Shared.components)
local constants = require(Shared.constants)

local placementUpdatesChunkRef = require(script.Parent.placementUpdatesChunkRef)
local PlayerRef = Components.PlayerRef
local Chunk = Components.Chunk
local ChunkRef = Components.ChunkRef

local useThrottle = Matter.useThrottle
local voxelSize = constants.VOXEL_SIZE
local serverChunks = constants.CHUNKS

function playerUpdatesChunkPriority(world: Matter.World)
	if useThrottle(1) then
		local players = {}

		for id, playerRef, chunkRef in world:query(PlayerRef, ChunkRef) do
			table.insert(players, chunkRef.voxelKey)
		end

		if next(players) == nil then
			return
		end

		for position, voxel in serverChunks:GetVoxels() do
			if voxel.entityId == nil then
				continue
			end

			local closestDistance = math.huge
			for _, playerVoxelKey in players do
				local playerMagnitude = (position - playerVoxelKey).Magnitude

				if playerMagnitude >= closestDistance then
					continue
				end

				closestDistance = playerMagnitude
			end

			local chunkPriority = -1
			if closestDistance <= 8192 / voxelSize then
				chunkPriority = 1
			elseif closestDistance > 8192 / voxelSize and closestDistance <= 16384 / voxelSize then
				chunkPriority = 2
			elseif closestDistance > 16384 / voxelSize and closestDistance <= 32768 / voxelSize then
				chunkPriority = 3
			elseif closestDistance > 32768 / voxelSize and closestDistance <= 65536 / voxelSize then
				chunkPriority = 4
			else
				serverChunks:ClearVoxel(position)
				return
			end

			if world:contains(voxel.entityId) then
				voxel.priority = chunkPriority
				world:insert(
					voxel.entityId,
					Chunk({
						priority = chunkPriority,
					})
				)
			end
		end
	end
end

return {
	system = playerUpdatesChunkPriority,
	after = { placementUpdatesChunkRef },
}
