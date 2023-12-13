--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local useThrottle = Matter.useThrottle

local Components = require(Shared.components)
local constants = require(Shared.constants)

local Chunk = Components.Chunk
local ChunkRef = Components.ChunkRef
local Model = Components.Model

local currentCamera = Workspace.CurrentCamera
local terrain

do
	terrain = Instance.new("Folder")
	terrain.Name = "World"
	terrain.Parent = workspace
end

local voxelSize = constants.VOXEL_SIZE
local halfVoxel = voxelSize / 2
local chunkFolder

if RunService:IsServer() then
	chunkFolder = ServerStorage["ServerChunks"]
else
	chunkFolder = ReplicatedStorage["ClientChunks"]
end

function chunkModelCreator(world: Matter.World)
	for id, chunk in world:queryChanged(Chunk) do
		if chunk.new == nil then
			continue
		end

		if chunk.new.priority < 1 and chunk.new.priority > 2 then
			local model = world:get(id, Model)
			if model == nil then
				continue
			end

			print("Removing chunk model")

			world:remove(id, Model)
		end
	end

	if useThrottle(1) then
		for id, chunk, chunkRef in world:query(Chunk, ChunkRef):without(Model) do
			if chunk.priority < 1 and chunk.priority > 2 then
				continue
			end

			local voxelKey = chunkRef.voxelKey
			local chunkModel = chunkFolder:FindFirstChild(`{voxelKey.X},{voxelKey.Z}`)

			if chunkModel then
				chunkModel:Clone()
			else
				print(`{voxelKey.X},{voxelKey.Z}`)
				continue
			end

			local modelSize = chunkModel:GetExtentsSize()
			local cframe =
				CFrame.new(voxelKey.X * voxelSize + halfVoxel, modelSize.Y / 2, voxelKey.Z * voxelSize + halfVoxel)

			if RunService:IsServer() then
				chunkModel:PivotTo(cframe)
				chunkModel.Parent = currentCamera
			else
				local origin = Workspace:GetAttribute("Origin")

				if origin == nil then
					continue
				end

				chunkModel:PivotTo(cframe - origin)
				chunkModel.Parent = terrain
			end

			world:insert(
				id,
				Model({
					instance = chunkModel,
				})
			)
		end
	end
end

return chunkModelCreator
