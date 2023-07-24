local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Matter = require(Packages.Matter)
local Signal = require(Packages.Signal)
local Components = require(ReplicatedStorage.Shared.components)

local useThrottle = Matter.useThrottle
local characterAdded = Signal.new()

local function resourceSpawners(world)
	if useThrottle(15) then
		for id, resource, transform, model in world:query(Components.Resource, Components.Transform, Components.Model) do
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
