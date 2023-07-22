local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseStruct = require(ReplicatedStorage.Shared.class.BaseStruct)
local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)

export type TEntity = {
	statusId: number,
	transformId: number,
}

export type EntityStruct = BaseStruct.BaseStruct<TEntity>
local entity: EntityStruct = BaseStruct.new()

function entity:serialize(id: string, struct: TEntity?)
	local data = struct or entity:getById(id)
	local buffer = BitBuffer()

	buffer.writeUInt32(tonumber(id))
	buffer.writeUInt32(tonumber(data.statusId))
	buffer.writeUInt32(tonumber(data.transformId))

	return buffer.dumpString()
end

function entity:deserialize(stream: string)
	local buffer = BitBuffer(stream)

	local entityId = buffer:readUInt32()
	local statusId = buffer:readUInt32()
	local transformId = buffer:readUInt32()

	local data = {
		statusId = statusId,
		transformId = transformId,
	}

	return entityId, data
end

return entity
