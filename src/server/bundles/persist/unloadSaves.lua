local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages

local Matter = require(packages.Matter)

local components = require(script.Parent.components)
local datastore = require(script.Parent.datastore)

local Save = components.Save
local Unload = components.Unload
local Unloaded = components.Unloaded

local function unloadSaves(world: Matter.World)
	for id, save in world:query(Save, Unload):without(Unloaded) do
		local document = datastore.documents[save.userId]
		if document == nil or save.loaded == nil then
			continue
		end

		world:insert(id, save:patch({}), Unloaded({}))
	end
end

return unloadSaves
