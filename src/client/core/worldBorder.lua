local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared
local Utils = Shared.utils

local Constants = require(Shared.constants)
local VOXEL_SIZE = Constants.VOXEL_SIZE
local BORDER_VOXEL = Workspace:GetAttribute("BorderVoxel") or 2 -- [TESTING] Should be 45

local Matter = require(Packages.Matter)

local Components = require(Shared.components)
local PlayerRef = Components.PlayerRef
local Model = Components.Model
local GamePlacement = Components.GamePlacement
local ChunkRef = Components.ChunkRef

local createWorldBorder = require(Utils.createWorldBorder)
local borderX = createWorldBorder()
local borderZ = createWorldBorder()

local function createBordersFolder()
	local bordersFolder = Instance.new("Folder")
	bordersFolder.Name = "World Borders"
	bordersFolder.Parent = Workspace

	return bordersFolder
end

local bordersFolder = createBordersFolder()

-- TODO: Make borders actually spawn where they're supposed to
local function setPhysicalBorder(bordersFolder, voxelKey)
	local voxelEdge = (VOXEL_SIZE * BORDER_VOXEL) + VOXEL_SIZE + 1
	local xEdge = math.abs(voxelKey.X) == BORDER_VOXEL
	local zEdge = math.abs(voxelKey.Z) == BORDER_VOXEL
	local onEdge = false

	if xEdge then
		onEdge = true
		borderX.CFrame = CFrame.new((voxelKey.X > 0) and voxelEdge or -voxelEdge, 1029, 0)
			* CFrame.Angles(0, math.rad(90), 0)
		borderX.Parent = bordersFolder
	end

	if zEdge then
		onEdge = true
		borderZ.CFrame = CFrame.new(0, 1029, (voxelKey.Z > 0) and voxelEdge or -voxelEdge)
		borderZ.Parent = bordersFolder
	end

	return onEdge
end

function worldBorder(world: Matter.World)
	-- for id, player, model, gamePlacement, chunkRef in world:query(PlayerRef, Model, GamePlacement, ChunkRef) do
	-- 	if player.instance ~= Players.LocalPlayer then
	-- 		continue
	-- 	end

	-- 	local character = model.instance
	-- 	local rootPart = character.PrimaryPart
	-- 	local humanoid = character.Humanoid

	-- 	if not humanoid or not rootPart then
	-- 		continue
	-- 	end

	-- 	local xDistance = (VOXEL_SIZE * BORDER_VOXEL) + VOXEL_SIZE - math.abs(gamePlacement.position.X)
	-- 	local zDistance = (VOXEL_SIZE * BORDER_VOXEL) + VOXEL_SIZE - math.abs(gamePlacement.position.Z)
	-- 	if xDistance <= 2000 or zDistance <= 2000 then
	-- 		local onEdge = setPhysicalBorder(bordersFolder, chunkRef.voxelKey)
	-- 		if not onEdge and bordersFolder.Parent ~= nil then
	-- 			bordersFolder.Parent = nil
	-- 		end

	-- 		if xDistance < zDistance then
	-- 			local adjustedVelocity = 0.0005 * xDistance * humanoid.WalkSpeed
	-- 			if adjustedVelocity < rootPart.AssemblyLinearVelocity.X then
	-- 				rootPart.AssemblyLinearVelocity = Vector3.new(
	-- 					math.max(adjustedVelocity, 1),
	-- 					rootPart.AssemblyLinearVelocity.Y,
	-- 					rootPart.AssemblyLinearVelocity.Z
	-- 				)
	-- 			end
	-- 		elseif zDistance < xDistance then
	-- 			local adjustedVelocity = 0.0005 * zDistance * humanoid.WalkSpeed
	-- 			if adjustedVelocity < rootPart.AssemblyLinearVelocity.Z then
	-- 				rootPart.AssemblyLinearVelocity = Vector3.new(
	-- 					rootPart.AssemblyLinearVelocity.X,
	-- 					rootPart.AssemblyLinearVelocity.Y,
	-- 					math.max(adjustedVelocity, 1)
	-- 				)
	-- 			end
	-- 		elseif xDistance == zDistance then
	-- 			local adjustedVelocity = 0.0005 * xDistance * humanoid.WalkSpeed
	-- 			if adjustedVelocity < rootPart.AssemblyLinearVelocity.X then
	-- 				rootPart.AssemblyLinearVelocity = Vector3.new(
	-- 					math.max(adjustedVelocity, 1),
	-- 					rootPart.AssemblyLinearVelocity.Y,
	-- 					rootPart.AssemblyLinearVelocity.Z
	-- 				)
	-- 			end

	-- 			if adjustedVelocity < rootPart.AssemblyLinearVelocity.Z then
	-- 				rootPart.AssemblyLinearVelocity = Vector3.new(
	-- 					rootPart.AssemblyLinearVelocity.X,
	-- 					rootPart.AssemblyLinearVelocity.Y,
	-- 					math.max(adjustedVelocity, 1)
	-- 				)
	-- 			end
	-- 		end
	-- 	end

	-- 	-- Temporary Wall
	-- 	if xDistance <= 0 or zDistance <= 0 then
	-- 		print("Past")
	-- 	end
	-- end
end

return {
	system = worldBorder,
}
