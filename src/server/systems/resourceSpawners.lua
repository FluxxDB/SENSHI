local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Matter = require(Packages.Matter)
local Components = require(ReplicatedStorage.Shared.components)

local function resourceSpawners(world: Matter.World)
	for id, resource, transform in world:query(Components.Resource, Components.Transform) do
		if resource.capacity < resource.spawnCount then
		end
	end
end

return {
	system = resourceSpawners,
}
