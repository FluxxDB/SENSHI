local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages

local Matter = require(packages.Matter)

local components = require(script.Parent.components)
local datastore = require(script.Parent.datastore)

local function unloadSaves(world: Matter.World)
	for id, save in world:query(components.Save, components.Unload):without(components.Unloaded) do
		local document = datastore.documents[save.userId]
		if document == nil or save.loaded == nil then
			continue
		end

		world:insert(id, save:patch({}), components.Unloaded({}))
	end
end

return {
	system = unloadSaves,
	before = { require(script.Parent.saveTriggered) },
}
