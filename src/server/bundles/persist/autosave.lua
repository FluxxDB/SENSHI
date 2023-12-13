local ReplicatedStorage = game:GetService("ReplicatedStorage")

local matterTypes = require(ReplicatedStorage.types.matter)
local Matter = require(ReplicatedStorage.Packages.Matter)

local components = require(script.Parent.components)
local datastore = require(script.Parent.datastore)
local documents = datastore.documents

local function autosave(world: matterTypes.World)
	if Matter.useThrottle(10) then
		for id, save in world:query(components.Save, components.Loaded) do
			local document = documents[save.userId]

			if document == nil or save.loaded == false then
				continue
			end

			world:insert(id, save:patch({}))
		end
	end
end

return autosave
