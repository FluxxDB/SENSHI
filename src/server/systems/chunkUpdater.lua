local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Components = require(Shared.components)
local constants = require(Shared.constants)

local Transform = Components.Transform
local ChunkRef = Components.ChunkRef

local voxelSize = constants.VOXEL_SIZE
local serverChunks = constants.CHUNKS

local function chunkUpdater(world: Matter.World)
	for id, transform in world:query(Transform):without(ChunkRef) do
		if world:contains(id) == false then
			continue
		end

		local chunkX = math.floor(transform.cframe.X / voxelSize)
		local chunkY = math.floor(transform.cframe.Z / voxelSize)

		serverChunks:AddEntity(Vector2.new(chunkX, chunkY), id)
		world:insert(
			id,
			ChunkRef({
				x = chunkX,
				y = chunkY,
			})
		)
	end

	for id, transformRecord in world:queryChanged(Transform) do
		local chunkX = math.floor(transformRecord.new.cframe.X / voxelSize)
		local chunkY = math.floor(transformRecord.new.cframe.Z / voxelSize)

		local chunkRef = world:get(id, ChunkRef)
		if chunkX ~= chunkRef.x or chunkY ~= chunkRef.y then
			serverChunks:RemoveEntity(Vector2.new(chunkRef.x, chunkRef.y), id)
			serverChunks:AddEntity(Vector2.new(chunkX, chunkY), id)

			world:insert(
				id,
				ChunkRef({
					x = chunkX,
					y = chunkY,
				})
			)
		end
	end
end

return {
	system = chunkUpdater,
	serverChunks = serverChunks,
}
