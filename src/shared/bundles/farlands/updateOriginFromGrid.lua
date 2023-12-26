local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Matter = require(ReplicatedStorage.Packages.Matter)
local componentRegistry = require(ReplicatedStorage.shared.componentRegistry)

local constants = require(script.Parent.constants)
local GRID_EDGE_LENGTH = constants.GRID_EDGE_LENGTH

local GridCell = componentRegistry.GridCell
local OriginRef = componentRegistry.OriginRef

local function updateOriginFromGrid(world: Matter.World)
	local worldShift = workspace:GetAttribute("Origin")

	for id, _, gridCell in world:query(OriginRef, GridCell) do
		if gridCell.position ~= worldShift then
			Workspace:SetAttribute("Origin", gridCell.position)
			Workspace:PivotTo(CFrame.new(-gridCell.position * GRID_EDGE_LENGTH))
		end
	end
end

return {
	system = updateOriginFromGrid,
	priority = 1.1e9,
}
