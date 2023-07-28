--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Components = require(Shared.components)
local constants = require(Shared.constants)
local chunkManager = require(script.Parent.chunkManager)

local Player = Components.Player
local ChunkRef = Components.ChunkRef
local ChunkLOD = Components.ChunkLOD
local Model = Components.Model

local collisionMaps = ServerStorage["ServerChunks"]
local useThrottle = Matter.useThrottle
local serverChunks = constants.CHUNKS

local function chunkSpawner(world: Matter.World)
	if useThrottle(1) then
		local voxels = serverChunks:GetVoxels()
		for id, player, chunkRef in world:query(Player, ChunkRef) do
			local voxelKey = chunkRef.voxelKey

			local chunkX = voxelKey.X
			local chunkY = voxelKey.Z

			for x = chunkX - 2, chunkX + 2 do
				for y = chunkY - 2, chunkY + 2 do
					local position = Vector3.new(x, 0, y)
					if voxels[position] == nil then
						voxels[position] = {}
						voxels[position].entityId = world:spawn(ChunkRef({
							voxelKey = position,
						}))
					end
				end
			end
		end

		for id, chunkRef, chunkLOD in world:query(ChunkRef, ChunkLOD):without(Model) do
			if not chunkRef.voxelKey then
				continue
			end

			local voxelKey = chunkRef.voxelKey
			local collisionChunk = collisionMaps:FindFirstChild(`{voxelKey.X},{voxelKey.Z}`):Clone()
			collisionChunk.Parent = nil

			world:insert(
				id,
				Model({
					instance = collisionChunk,
				})
			)
		end
	end
end

return {
	system = chunkSpawner,
	after = { chunkManager },
}
