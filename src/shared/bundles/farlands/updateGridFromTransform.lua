local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

local componentRegistry = require(ReplicatedStorage.shared.componentRegistry)

local constants = require(script.Parent.constants)
local helpers = require(script.Parent.helpers)

local Transform = componentRegistry.Transform
local GridCell = componentRegistry.GridCell

local function updateGridFromTransform(world: Matter.World)
	for id, record in world:queryChanged(Transform) do
		local transform = record.new

		if transform == nil or transform.doNotReconcile then
			continue
		end

		local translation = transform.translation :: CFrame

		if helpers.isBeyondSwitchThreshold(translation.Position) then
			continue
		end

		local grid, delta = helpers.transformToGrid(
			translation.Position + workspace:GetAttribute("Origin") * constants.GRID_EDGE_LENGTH
		)

		world:insert(
			id,
			Transform({
				translation = CFrame.new(delta) * CFrame.Angles(translation:ToEulerAnglesXYZ()),
				doNotReconcile = true,
			}),
			GridCell({
				position = grid,
			})
		)
	end
end

return {
	system = updateGridFromTransform,
	priority = 1e9,
}
