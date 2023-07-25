local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Components = require(Shared.components)
local constants = require(Shared.constants)
local removeDistantChunks = require(script.Parent.removeDistantChunks)

local EntityType = Components.EntityType
local Transform = Components.Transform
local ChunkRef = Components.ChunkRef

local voxelSize = constants.VOXEL_SIZE
local serverChunks = constants.CHUNKS

local function chunkUpdater(world: Matter.World)
	for id, entityType, transform in world:query(EntityType, Transform):without(ChunkRef) do
		if world:contains(id) == false then
			continue
		end

		local chunkX = math.floor(transform.cframe.X / voxelSize)
		local chunkY = math.floor(transform.cframe.Z / voxelSize)

		serverChunks:AddEntity(entityType.typeId, Vector3.new(chunkX, 0, chunkY), id)
		world:insert(
			id,
			ChunkRef({
				x = chunkX,
				y = chunkY,
			})
		)
	end

	for id, transformRecord in world:queryChanged(Transform) do
		local entityType = world:get(id, EntityType)
		if not entityType then
			continue
		end

		local chunkX = math.floor(transformRecord.new.cframe.X / voxelSize)
		local chunkY = math.floor(transformRecord.new.cframe.Z / voxelSize)

		local chunkRef = world:get(id, ChunkRef)
		if chunkX ~= chunkRef.x or chunkY ~= chunkRef.y then
			serverChunks:RemoveEntity(entityType.typeId, Vector3.new(chunkRef.x, 0, chunkRef.y), id)
			serverChunks:AddEntity(entityType.typeId, Vector3.new(chunkX, 0, chunkY), id)

			world:insert(
				id,
				ChunkRef({
					x = chunkX,
					y = chunkY,
				})
			)
		end
	end

	for id, chunkRef in world:query(ChunkRef) do
		serverChunks:_debugDrawVoxel(Vector2.new(chunkRef.x, chunkRef.y))
	end
end

return {
	system = chunkUpdater,
	after = { removeDistantChunks },
}
