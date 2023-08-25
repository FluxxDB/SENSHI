--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local Matter = require(ReplicatedStorage.Packages.Matter)

local Components = require(ReplicatedStorage.Shared.components)
local constants = require(Shared.constants)

local playerUpdatesPlacement = require(script.Parent.playerUpdatesPlacement)
local movementUpdatesPlacement = require(script.Parent.movementUpdatesPlacement)
local GamePlacement = Components.GamePlacement
local ChunkRef = Components.ChunkRef

local serverChunks = constants.CHUNKS
local voxelSize = constants.VOXEL_SIZE

function placementUpdatesChunkRef(world: Matter.World)
	for id, record in world:queryChanged(GamePlacement) do
		if record.new == nil then
			continue
		end

		local currentVoxel = Vector3.new(
			math.clamp(math.floor(record.new.position.X / voxelSize), -50, 50),
			0,
			math.clamp(math.floor(record.new.position.Z / voxelSize), -50, 50)
		)

		local chunkRef = world:get(id, ChunkRef)
		if chunkRef == nil then
			serverChunks:AddEntity(record.new.position, id)
			print(record.new.position, id)

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
			serverChunks:AddEntity(record.new.position, id)
			print(record.new.position, id)

			world:insert(
				id,
				ChunkRef({
					voxelKey = currentVoxel,
				})
			)
		end
	end
end

return {
	system = placementUpdatesChunkRef,
	after = { playerUpdatesPlacement, movementUpdatesPlacement },
}
