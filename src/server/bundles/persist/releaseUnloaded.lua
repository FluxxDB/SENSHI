local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

local components = require(script.Parent.components)
local datastore = require(script.Parent.datastore)

local function releaseUnloaded(world: Matter.World)
	for id, save in world:query(components.Save, components.Unloaded) do
		local document = datastore.documents[save.userId]

		if document then
			document:close()
			datastore.documents[save.userId] = nil
		end
	end
end

return releaseUnloaded
