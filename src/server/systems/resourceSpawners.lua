local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Matter = require(Packages.Matter)
local Signal = require(Packages.Signal)
local Components = require(ReplicatedStorage.Shared.components)

local useThrottle = Matter.useThrottle

local RESOURCE_RESPAWN_TIME = 60 * 30
local characterAdded = Signal.new()

local function resourceSpawners(world)
	for id, resource, transform, model in world:query(Components.Resource, Components.Transform, Components.Model) do
		if resource.capacity < resource.avalible then
		end
		if useThrottle(RESOURCE_RESPAWN_TIME, id) then
			print(id, resource, transform, model)
		end
	end
end

return {
	system = resourceSpawners,
	events = {
		characterAdded = characterAdded,
	},
}
