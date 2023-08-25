local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local useThrottle = Matter.useThrottle

local Components = require(Shared.components)
local PlayerRef = Components.PlayerRef
local Model = Components.Model
local GamePlacement = Components.GamePlacement

local constants = require(Shared.constants)
local voxelSize = constants.VOXEL_SIZE

local shiftOrigin = voxelSize * 10
local worldOrigin = Vector3.new(0, 0, 0)
Workspace:SetAttribute("Origin", worldOrigin)

function playerUpdatesWorldShift(world: Matter.World)
	for id, player, placement in world:query(PlayerRef, GamePlacement) do
		if player.instance ~= Players.LocalPlayer then
			continue
		end

		if (worldOrigin - placement.position).Magnitude >= shiftOrigin then
			worldOrigin = placement.position
			Workspace:PivotTo(CFrame.new(-worldOrigin.X, 0, 0))
			Workspace:SetAttribute("Origin", worldOrigin)
		end
	end
end

return {
	system = playerUpdatesWorldShift,
}
