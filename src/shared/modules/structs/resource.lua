local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseStruct = require(ReplicatedStorage.Shared.class.BaseStruct)
local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)

export type TResource = {
	modelId: number,
	dropId: number,
	quantity: number,
	transformId: number,
}

type ResourceStruct = BaseStruct.BaseStruct<TResource>
local resource: ResourceStruct = BaseStruct.new()

function resource:serialize(id: string, struct: TResource?)
	local data = struct or resource:getById(id)
	local buffer = BitBuffer()

	buffer.writeUInt32(tonumber(id))
	buffer.writeUInt16(tonumber(data.dropId))
	buffer.writeUInt16(tonumber(data.modelId))
	buffer.writeUInt16(tonumber(data.quantity))
	buffer.writeUInt32(tonumber(data.transformId))

	return buffer.dumpString()
end

function resource:deserialize(stream: string)
	local buffer = BitBuffer(stream)

	local resourceId = buffer:readUInt32()
	local dropId = buffer:readUInt16()
	local modelId = buffer:readUInt16()
	local quantity = buffer:readUInt32()
	local transformId = buffer:readUInt32()

	local resource = {
		dropId = dropId,
		modelId = modelId,
		quantity = quantity,
		transformId = transformId,
	}

	return resourceId, resource
end

return resource
