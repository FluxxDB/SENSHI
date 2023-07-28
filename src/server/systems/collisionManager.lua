local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared
local Matter = require(Packages.Matter)

local Components = require(Shared.components)
local chunkUpdater = require(script.Parent.chunkUpdater)

local ChunkLOD = Components.ChunkLOD
local ChunkRef = Components.ChunkRef
local Model = Components.Model

local camera = Workspace.CurrentCamera
local constants = require(Shared.constants)

local VOXEL_SIZE = constants.VOXEL_SIZE
local HALF_VOXEL = VOXEL_SIZE / 2

local function collisionManager(world: Matter.World)
	for id, chunkLOD in world:queryChanged(ChunkLOD) do
		-- chunk updated
		if chunkLOD.new ~= nil then
			local level = chunkLOD.new.level
			local chunkRef = world:get(id, ChunkRef)
			if not chunkRef or not chunkRef.voxelKey then
				continue
			end

			local collisionMap = world:get(id, Model)
			if not collisionMap or not collisionMap.instance then
				continue
			end

			local voxelKey = chunkRef.voxelKey
			if level <= 2 then
				local collisionChunk = collisionMap.instance :: Model
				local modelSize = collisionChunk:GetExtentsSize()
				collisionChunk:PivotTo(
					CFrame.new(
						voxelKey.X * VOXEL_SIZE + HALF_VOXEL,
						modelSize.Y / 2,
						voxelKey.Z * VOXEL_SIZE + HALF_VOXEL
					)
				)
				collisionChunk.Parent = camera
			end
		elseif chunkLOD.new == nil and chunkLOD.old ~= nil then
			-- TODO: idk
		end
	end
end

return {
	system = collisionManager,
	after = { chunkUpdater },
}
