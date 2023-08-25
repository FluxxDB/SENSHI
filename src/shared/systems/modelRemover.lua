--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Components = require(Shared.components)

local Model = Components.Model

function modelRemover(world: Matter.World)
	for id, model in world:queryChanged(Model) do
		if model.new == nil then
			if model.old and model.old.instance then
				model.old.instance:Destroy()
			end
		end
	end
end

return modelRemover
