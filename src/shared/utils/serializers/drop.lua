local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)
local uuidUtils = require(ReplicatedStorage.Shared.utils["uuid-utils"])

export type TDrop = {
	uuid: number,
	itemId: number,
	modelId: number,
	quantity: number?,
	transformId: number,
}

local Drop = {}

function Drop:Serialize(id: string, struct: TDrop)
	local data = struct
	local buffer = BitBuffer.new()

	buffer:WriteUInt32(tonumber(id))
	buffer:WriteBytes(uuidUtils.pack(data.uuid))
	buffer:WriteUInt16(tonumber(data.itemId))
	buffer:WriteUInt16(tonumber(data.modelId))
	buffer:WriteUInt16(tonumber(data.quantity))
	buffer:WriteUInt32(tonumber(data.transformId))

	return buffer.ToBase91()
end

function Drop:Deserialize(stream: string)
	local buffer = BitBuffer.FromBase91(stream)

	local dropId = buffer:ReadUInt32()
	local uuid = uuidUtils.unpack(buffer:ReadBytes(16))
	local itemId = buffer:ReadUInt16()
	local modelId = buffer:ReadUInt16()
	local quantity = buffer:ReadUInt32()
	local transformId = buffer:ReadUInt32()

	local data: TDrop = {
		uuid = uuid,
		itemId = itemId,
		modelId = modelId,
		quantity = quantity,
		transformId = transformId,
	}

	return dropId, data
end

return Drop
