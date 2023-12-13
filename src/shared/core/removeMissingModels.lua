local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

local Components = require(ReplicatedStorage.shared.components)

local function removeMissingModels(world: Matter.World)
	for _id, modelRecord in world:queryChanged(Components.Model) do
		if modelRecord.old and modelRecord.old.instance then
			modelRecord.old.instance:Destroy()
		end
	end
end

return removeMissingModels
