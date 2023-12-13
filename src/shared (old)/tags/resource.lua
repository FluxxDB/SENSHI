local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.components)

local constants = require(ReplicatedStorage.Shared.constants)
local voxelSize = constants.VOXEL_SIZE

local object = {
	tag = "Resource",
	component = Components.Resource,
}

function object:instanceAdded(world: Matter.World, instance: BasePart)
	if instance:IsA("BasePart") ~= true or instance:IsDescendantOf(workspace) == false then
		return
	end

	local position = instance.Position
	local attributes = instance:GetAttributes()
	attributes.resourceId = attributes.resourceId or -1
	attributes.capacity = attributes.capacity or 0
	attributes.spawnCount = 0

	world:spawn(
		self.component(attributes),
		Components.GamePlacement({
			position = Vector3.new(math.floor(position.X / voxelSize), 0, math.floor(position.Z / voxelSize)),
			orientation = 0,
		})
	)
end

return object
