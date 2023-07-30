--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Components = require(Shared.components)
local constants = require(Shared.constants)

local Chunk = Components.Chunk
local ChunkRef = Components.ChunkRef
local Model = Components.Model

local collisionMaps = ServerStorage["ServerChunks"]
local currentCamera = Workspace.CurrentCamera
local voxelSize = constants.VOXEL_SIZE
local halfVoxel = voxelSize / 2

local function chunkModelCreator(world: Matter.World)
	for id, chunk in world:queryChanged(Chunk) do
		if chunk.new == nil then
			continue
		end

		if chunk.new.priority < 1 or chunk.new.priority > 2 then
			local model = world:get(id, Model)
			if model == nil then
				continue
			end

			if model.instance then
				model.instance:Destroy()
			end

			world:remove(id, model)
		end
	end

	for id, chunk, chunkRef in world:query(Chunk, ChunkRef):without(Model) do
		if chunk.priority < 1 and chunk.priority > 2 then
			continue
		end

		local voxelKey = chunkRef.voxelKey
		local collisionChunk = collisionMaps:FindFirstChild(`{voxelKey.X},{voxelKey.Z}`):Clone()
		local modelSize = collisionChunk:GetExtentsSize()
		collisionChunk:PivotTo(
			CFrame.new(voxelKey.X * voxelSize + halfVoxel, modelSize.Y / 2, voxelKey.Z * voxelSize + halfVoxel)
		)
		collisionChunk.Parent = currentCamera

		world:insert(
			id,
			Model({
				instance = collisionChunk,
			})
		)
	end
end

return chunkModelCreator
