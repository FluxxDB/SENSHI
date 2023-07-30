--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.components)
local constants = require(Shared.constants)

local PlayerRef = Components.PlayerRef
local Chunk = Components.Chunk
local ChunkRef = Components.ChunkRef

local useEvent = Matter.useEvent
local useThrottle = Matter.useThrottle
local serverChunks = constants.CHUNKS
local chunkSpawnDistance = constants.CHUNK_SPAWN_DISTANCE
local voxelAdded, voxelRemoving = serverChunks.voxelAdded, serverChunks.voxelRemoving

function spawnChunk(world: Matter.World)
	-- Spawn chunks around player
	for id, _, chunkRef in world:query(PlayerRef, ChunkRef) do
		if useThrottle(1, id) then
			local voxelKey = chunkRef.voxelKey

			local chunkX = voxelKey.X
			local chunkY = voxelKey.Z

			for x = chunkX - chunkSpawnDistance, chunkX + chunkSpawnDistance do
				for y = chunkY - chunkSpawnDistance, chunkY + chunkSpawnDistance do
					-- TODO: Find prettier way to do this
					local position = Vector3.new(x, 0, y)
					if serverChunks:GetVoxel(position) == nil then
						serverChunks:AddEntity(position, -1) -- Don't ask me why
					end
				end
			end
		end
	end

	-- Check whenever a voxel was added or deleted to assing/remove its according entity
	for _, position, voxel in useEvent(voxelAdded, voxelAdded.Connect) do
		local voxelId = world:spawn(
			Chunk({
				priority = -1,
			}),
			ChunkRef({
				voxelKey = position,
			})
		)
		voxel.entityId = voxelId
	end

	for _, position, voxel in useEvent(voxelRemoving, voxelRemoving.Connect) do
		if voxel.entityId and world:contains(voxel.entityId) then
			world:despawn(voxel.entityId)
			voxel.entityId = nil
		end

		for _, objects in voxel do
			if type(objects) ~= "table" then
				continue
			end

			for _, entityId in objects do
				if world:contains(entityId) then
					world:despawn(entityId)
				end
			end
		end
	end
end

return {
	system = spawnChunk,
	priority = -1,
}
