local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Components = require(Shared.components)
local constants = require(Shared.constants)
local chunkManager = require(script.Parent.chunkManager)

local Player = Components.Player
local ChunkRef = Components.ChunkRef
local Transform = Components.Transform
local EntityType = Components.EntityType

local useThrottle = Matter.useThrottle
local voxelSize = constants.VOXEL_SIZE
local serverChunks = constants.CHUNKS

local function chunkUpdater(world: Matter.World)
	for id, transformRecord in world:queryChanged(Transform) do
		if world:contains(id) == false then
			continue
		end

		local entityType = world:get(id, EntityType)
		if entityType == nil or transformRecord.new == nil then
			continue
		end

		local currentVoxel = Vector3.new(
			math.floor(transformRecord.new.cframe.X / voxelSize),
			0,
			math.floor(transformRecord.new.cframe.Z / voxelSize)
		)

		local chunkRef = world:get(id, ChunkRef)
		if currentVoxel ~= chunkRef.voxelKey then
			serverChunks:RemoveFrom(chunkRef.voxelKey, entityType.typeId, id)
			serverChunks:AddTo(transformRecord.new.cframe.Position, entityType.typeId, id)

			world:insert(
				id,
				ChunkRef({
					voxelKey = currentVoxel,
				})
			)
		end
	end

	if useThrottle(1) then
		local voxels = serverChunks:GetVoxels()
		for id, player, chunkRef in world:query(Player, ChunkRef) do
			local voxelKey = chunkRef.voxelKey

			local chunkX = voxelKey.X
			local chunkY = voxelKey.Z

			for x = chunkX - 2, chunkX + 2 do
				for y = chunkY - 2, chunkY + 2 do
					if voxels[voxelKey] == nil then
						voxels[voxelKey] = {}
						voxels[voxelKey].entityId = world:spawn(ChunkRef({
							voxelKey = voxelKey,
						}))
					end
				end
			end
		end
	end

	for id, chunkRef in world:query(ChunkRef) do
		serverChunks:_debugDrawVoxel(chunkRef.voxelKey)
	end
end

return {
	system = chunkUpdater,
	after = { chunkManager },
}
