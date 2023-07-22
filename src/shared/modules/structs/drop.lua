local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseStruct = require(ReplicatedStorage.Shared.classes.BaseStruct)
local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)

export type TDrop = {
	seed: number?,
	itemId: number,
	modelId: number,
	quantity: number?,
	transformId: number,
}

export type DropStruct = BaseStruct.BaseStruct<TDrop>
local drop: DropStruct = BaseStruct.new()

function drop:serialize(id: string, struct: TDrop?)
	local data = struct or drop:getById(id)
	local buffer = BitBuffer()

	buffer.writeUInt32(tonumber(id))
	buffer.writeUInt32(tonumber(data.seed))
	buffer.writeUInt16(tonumber(data.itemId))
	buffer.writeUInt16(tonumber(data.modelId))
	buffer.writeUInt16(tonumber(data.quantity))
	buffer.writeUInt32(tonumber(data.transformId))

	return buffer.dumpString()
end

function drop:deserialize(stream: string)
	local buffer = BitBuffer(stream)

	local dropId = buffer:readUInt32()
	local seed = buffer:writeUInt16()
	local itemId = buffer:writeUInt16()
	local modelId = buffer:writeUInt16()
	local quantity = buffer:readUInt32()
	local transformId = buffer:readUInt32()

	local data: TDrop = {
		seed = seed,
		itemId = itemId,
		modelId = modelId,
		quantity = quantity,
		transformId = transformId,
	}

	return dropId, data
end

return drop
