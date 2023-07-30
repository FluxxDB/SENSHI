--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local Matter = require(ReplicatedStorage.Packages.Matter)

local Components = require(ReplicatedStorage.Shared.components)
local constants = require(Shared.constants)

local GamePlacement = Components.GamePlacement
local ChunkRef = Components.ChunkRef

local serverChunks = constants.CHUNKS

function placementUpdatesChunkRef(world: Matter.World)
	for id, record in world:queryChanged(GamePlacement) do
		if record.new == nil then
			continue
		end

		local currentVoxel = Vector3.new(record.new.position.X, 0, record.new.position.Y)

		local chunkRef = world:get(id, ChunkRef)
		if chunkRef == nil then
			serverChunks:AddEntity(currentVoxel, id)

			world:insert(
				id,
				ChunkRef({
					voxelKey = currentVoxel,
				})
			)
			continue
		end

		if currentVoxel ~= chunkRef.voxelKey then
			serverChunks:RemoveEntity(chunkRef.voxelKey, id)
			serverChunks:AddEntity(currentVoxel, id)
			world:insert(
				id,
				ChunkRef({
					voxelKey = currentVoxel,
				})
			)
		end
	end
end

return placementUpdatesChunkRef
