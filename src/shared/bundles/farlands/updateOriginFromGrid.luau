local Workspace = game:GetService("Workspace")

local matterTypes = require("@types/matter")
local components = require("@shared/components")

local constants = require(script.Parent.constants)
local GRID_EDGE_LENGTH = constants.GRID_EDGE_LENGTH

local GridCell = components.GridCell
local OriginRef = components.OriginRef

local function updateOriginFromGrid(world: matterTypes.World)
	for id, _, gridCell in world:query(OriginRef, GridCell) do
		if gridCell.value ~= workspace:GetAttribute("Origin") then
			Workspace:SetAttribute("Origin", gridCell.value)
			Workspace:PivotTo(CFrame.new(-gridCell.value * GRID_EDGE_LENGTH))
		end
	end
end

return {
	system = updateOriginFromGrid,
	priority = 1.1e9,
}
