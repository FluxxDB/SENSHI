local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.components)

local object = {
	tag = "Resource",
	component = Components.Resource,
}

function object:instanceAdded(world: Matter.World, instance: BasePart)
	if instance:IsA("BasePart") ~= true or instance:IsDescendantOf(workspace) == false then
		return
	end

	local id = world:spawn(
		self.component(instance:GetAttributes()),
		Components.Transform({
			cframe = instance.CFrame,
		})
	)

	instance:SetAttribute("serverEntityId", id)
end

return object
