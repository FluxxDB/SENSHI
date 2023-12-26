local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages

local matter = require(packages.Matter)
local Serializer = require(packages.Serializer)

local components = require(script.Parent.components)
local datastore = require(script.Parent.datastore)

local function loadSave(world: matter.World)
	for id, save in world:query(components.Save):without(components.Loaded) do
		local document = datastore.documents[save.userId]

		if document == nil then
			continue
		end

		local playerData = document:read()
		local componentData = playerData.components[save.key]

		if componentData then
			componentData = Serializer.deserializeTableDeep(componentData)
		else
			world:insert(
				id,
				save:patch({
					loaded = true,
				}),
				components.Loaded()
			)
			continue
		end

		for name, data in componentData do
			world:insert(id, components[name](data))
		end

		world:insert(
			id,
			save:patch({
				loaded = true,
			}),
			components.Loaded()
		)
	end
end

return loadSave
