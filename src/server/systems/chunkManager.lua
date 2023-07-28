local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Components = require(Shared.components)
local constants = require(Shared.constants)

local Transform = Components.Transform
local ChunkRef = Components.ChunkRef

local useEvent = Matter.useEvent
local serverChunks = constants.CHUNKS
local voxelAdded, voxelRemoving = serverChunks.voxelAdded, serverChunks.voxelRemoving

local function chunkManager(world: Matter.World)
	for _, position, voxel in useEvent(voxelAdded, voxelAdded.Connect) do
		print("Adding", position, voxel)
		local voxelId = world:spawn(ChunkRef({
			voxelKey = position,
		}))
		voxel.entityId = voxelId
	end

	for _, position, voxel in useEvent(voxelRemoving, voxelRemoving.Connect) do
		print("Removing", position, voxel)
		if voxel.entityId and world:contains(voxel.entityId) then
			world:despawn(voxel.entityId)
			voxel.entityId = nil
		end

		for entityType, entityIds in voxel do
			for _, entityId in entityIds do
				if world:contains(entityId) then
					world:despawn(entityId)
				end
			end
		end
	end

	for id, transform in world:query(Transform):without(ChunkRef) do
		if world:contains(id) == false then
			continue
		end

		world:insert(
			id,
			ChunkRef({
				voxelKey = serverChunks:AddTo(transform.cframe.Position, id, id),
			})
		)
	end
end

return {
	system = chunkManager,
	priority = 0,
}
