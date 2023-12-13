local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.shared.components)

local ECS = script.Parent.Parent
local constants = require(ECS.farlands.constants)
local GRID_EDGE_LENGTH = constants.GRID_EDGE_LENGTH

local function updateOriginFromGrid(world: matter.World)
	local worldShift = workspace:GetAttribute("Origin")

	for id, _, gridCell in world:query(Components.OriginRef, Components.GridCell) do
		if gridCell.position ~= worldShift then
			Workspace:SetAttribute("Origin", gridCell.position)
			Workspace:PivotTo(CFrame.new(-gridCell.position * GRID_EDGE_LENGTH))
		end
	end
end

return {
	system = updateOriginFromGrid,
	priority = math.huge,
}
