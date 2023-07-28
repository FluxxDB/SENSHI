local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Components = require(Shared.components)

--[[
	local playerId = ...
	local entity = world:_getEntity(playerId)

	local parsed = {}
	for component, data in entity do
		parsed[tostring(component)] = data(//ω//)
	end
--]]

local Model = Components.Model
local useEvent = Matter.useEvent

local function modelRemover(world: Matter.World)
	for id, model in world.query(Model) do
		if model.instance then
			for _ in useEvent(model.instance, "AncestryChanged") do
				if model.instance.IsDescendantOf(game) == false then
					world.remove(id, Model)
					break
				end
			end
		end
	end

	for id, model in world:queryChanged(Model) do
		if model.new == nil then
			if model.old and model.old.instance then
				model.old.instance:Destroy()
			end
		end
	end
end

return modelRemover
