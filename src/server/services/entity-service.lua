local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Structs = require(ReplicatedStorage.Shared.modules.structs)

local entityStruct = Structs.entity

local EntityService = {}

function EntityService:onInit()
	-- local id, entity = entityStruct.createStruct()
	-- print(entityStruct.serialize(id), entity)
end

function EntityService:onStart() end

return EntityService
