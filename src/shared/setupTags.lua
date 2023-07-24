local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Shared.components)

local boundTags = {
	River = Components.Resource,
	Resource = Components.Resource,
	Doors = Components.Resource,
	-- TODO: Collection Service tags handler
}

local function setupTags(world)
	local function spawnBound(instance, component)
		local id = world:spawn(
			component(instance:GetAttributes()),
			Components.Model({
				model = instance,
			}),
			Components.Transform({
				cframe = if instance:IsA("Model") then instance.PrimaryPart.CFrame else instance.CFrame,
			})
		)

		instance:SetAttribute("serverEntityId", id)
	end

	for tagName, component in pairs(boundTags) do
		for _, instance in ipairs(CollectionService:GetTagged(tagName)) do
			spawnBound(instance, component)
		end

		CollectionService:GetInstanceAddedSignal(tagName):Connect(function(instance)
			spawnBound(instance, component)
		end)

		CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(instance)
			local id = instance:GetAttribute("serverEntityId")
			if id then
				world:despawn(id)
			end
		end)
	end
end

return setupTags
