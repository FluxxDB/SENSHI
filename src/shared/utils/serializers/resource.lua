local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)

export type TResource = {
	modelId: number,
	dropId: number,
	quantity: number,
	transformId: number,
}

local resource = {}

function resource:serialize(id: string, struct: TResource)
	local buffer = BitBuffer.new()

	buffer:WriteUInt32(tonumber(id))
	buffer:WriteUInt16(tonumber(struct.dropId))
	buffer:WriteUInt16(tonumber(struct.modelId))
	buffer:WriteUInt16(tonumber(struct.quantity))
	buffer:WriteUInt32(tonumber(struct.transformId))

	return buffer.dumpString()
end

function resource:deserialize(stream: string)
	local buffer = BitBuffer.FromString(stream)

	local entityId = buffer:readUInt32()
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

	return entityId, resource
end

return resource
