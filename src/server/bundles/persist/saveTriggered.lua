local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages

local Matter = require(packages.Matter)
local Sift = require(packages.Sift)

local components = require(script.Parent.components)
local datastore = require(script.Parent.datastore)
local dictionary = Sift.Dictionary

local function saveTriggered(world: Matter.World)
	for id, record in world:queryChanged(components.Save) do
		local save = record.new

		if save ~= nil and save.loaded then
			local document = datastore.documents[save.userId]
			if document == nil then
				warn(`Document of "{save.userId}" does not exist?`)
				continue
			end

			local old = document:read()

			local data = {}
			local entity = world:_getEntity(id)

			for _, component in save.components do
				data[component] = entity[components[component]]
			end

			document:write(dictionary.merge(old, {
				components = dictionary.merge(old.components, {
					[save.key] = Serializer.serializeTableDeep(data),
				}),
			}))
		end
	end
end

return saveTriggered
