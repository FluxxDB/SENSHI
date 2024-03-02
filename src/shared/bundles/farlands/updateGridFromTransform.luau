local matterTypes = require("@types/matter")
local component = require("@shared/components")

local constants = require(script.Parent.constants)
local helpers = require(script.Parent.helpers)

local Transform = component.Transform
local GridCell = component.GridCell

local function updateGridFromTransform(world: matterTypes.World)
	for id, record in world:queryChanged(Transform) do
		local transform = record.new

		if transform == nil or transform.doNotReconcile then
			continue
		end

		local translation = transform.value

		if helpers.isBeyondSwitchThreshold(translation.Position) then
			continue
		end

		local grid, delta = helpers.transformToGrid(
			translation.Position + workspace:GetAttribute("Origin") * constants.GRID_EDGE_LENGTH
		)

		world:insert(
			id,
			Transform({
				value = CFrame.new(delta) * CFrame.Angles(translation:ToEulerAnglesXYZ()),
				doNotReconcile = true,
			}),
			GridCell({
				value = grid,
			})
		)
	end
end

return {
	system = updateGridFromTransform,
	priority = 1e9,
}
