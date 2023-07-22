local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseStruct = require(ReplicatedStorage.Shared.class.BaseStruct)
local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)

export type TTransform = {
	position: Vector3,
	orientation: Vector3,
}

export type TransformStruct = BaseStruct.BaseStruct<TTransform>
local transform = BaseStruct.new() :: TransformStruct

function transform:serialize(id: string, struct: TTransform)
	local data = struct or transform:getById(id)
	local buffer = BitBuffer()

	buffer.writeUInt32(tonumber(id))
	buffer.writeVector3(data.position)
	buffer.writeVector3(data.orientation)

	return buffer.dumpString()
end

function transform:deserialize(stream: string)
	local buffer = BitBuffer(stream)

	local id = buffer:readUInt32()
	local position = buffer:readVector3()
	local orientation = buffer:readVector3()

	local data = {
		position = position,
		orientation = orientation,
	}

	return id, data
end

return transform
