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
local voxelSize = constants.VOXEL_SIZE

local chunkSpawnDistance = constants.CHUNK_SPAWN_DISTANCE
local voxelAdded, voxelRemoving = serverChunks.voxelAdded, serverChunks.voxelRemoving

function spawnChunk(world: Matter.World)
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

		serverChunks:AddEntity(position * voxelSize, voxelId)
		voxel.entityId = voxelId
	end

	for _, position, voxel in useEvent(voxelRemoving, voxelRemoving.Connect) do
		-- things might be going bad here
		-- TODO: Figure out a way to keep simulations spawned in
		--! This will probably despawn ANYTHING further than 65024 studs
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

	-- Spawn chunks around player
	for id, _, chunkRef in world:query(PlayerRef, ChunkRef) do
		if useThrottle(1, id) then
			local voxelKey = chunkRef.voxelKey

			local chunkX = voxelKey.X
			local chunkZ = voxelKey.Z

			for x = chunkX - chunkSpawnDistance, chunkX + chunkSpawnDistance do
				for z = chunkZ - chunkSpawnDistance, chunkZ + chunkSpawnDistance do
					-- TODO: Find prettier way to do this
					local position = Vector3.new(x, 0, z)
					if serverChunks:GetVoxel(position) == nil then
						serverChunks:AddEntity(position * voxelSize, -1) -- Don't ask me why
					end
				end
			end
		end
	end

	-- for position, voxel in serverChunks:GetVoxels() do
	-- 	serverChunks:_debugDrawVoxel(position)
	-- end
end

return {
	system = spawnChunk,
}
