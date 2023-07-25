local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)

export type TResource = {
	quantity: number,
	modelId: number,
	resourceId: number,
	transformId: number,
}

local resource = {}

function resource:serialize(id: string, struct: TResource)
	local buffer = BitBuffer.new()

	buffer:WriteUInt32(tonumber(id))
	buffer:WriteUInt16(tonumber(struct.quantity))

	return buffer.dumpString()
end

function resource:deserialize(stream: string)
	local buffer = BitBuffer.FromString(stream)

	local serverEntityId = buffer:readUInt32()
	local quantity = buffer:readUInt16()

	local resource = {
		quantity = quantity,
	}

	return serverEntityId, resource
end

return resource
