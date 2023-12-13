local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

local components = require(ReplicatedStorage.shared.componentRegistry)
local ECS = script.Parent.Parent
local helpers = require(ECS.farlands.helpers)
local constants = require(ECS.farlands.constants)

local function updateGridFromTransform(world: matter.World)
	for id, record in world:queryChanged(components.Transform) do
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
			components.Transform({
				translation = CFrame.new(delta) * CFrame.Angles(translation:ToEulerAnglesXYZ()),
				doNotReconcile = true,
			}),
			components.GridCell({
				position = grid,
			})
		)
	end
end

return {
	system = updateGridFromTransform,
	priority = 1e9,
}
