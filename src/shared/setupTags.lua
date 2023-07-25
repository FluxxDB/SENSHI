local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local boundTags = {}

for _, module in Shared.tags:GetChildren() do
	table.insert(boundTags, require(module))
end

local function setupTags(world)
	for _, component in boundTags do
		for _, instance in CollectionService:GetTagged(component.tag) do
			component:instanceAdded(world, instance)
		end

		CollectionService:GetInstanceAddedSignal(component.tag):Connect(function(instance)
			component:instanceAdded(world, instance)
		end)

		CollectionService:GetInstanceRemovedSignal(component.tag):Connect(function(instance)
			local id = instance:GetAttribute("serverEntityId")
			if id then
				world:despawn(id)
			end
		end)
	end
end

return setupTags
