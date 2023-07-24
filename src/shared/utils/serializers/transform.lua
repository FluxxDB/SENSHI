--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)

export type TTransform = {
	position: Vector3,
	orientation: Vector3,
}

local transform = {}

function transform:serialize(id: string, data: TTransform)
	local buffer = BitBuffer.new()

	buffer:WriteUInt32(tonumber(id))
	buffer:WriteUInt32(data.position.X)
	buffer:WriteUInt32(data.position.Y)
	buffer:WriteUInt32(data.position.Z)
	buffer:WriteUInt32(data.orientation.X)
	buffer:WriteUInt32(data.orientation.Y)
	buffer:WriteUInt32(data.orientation.Z)

	return buffer.dumpString()
end

function transform:deserialize(stream: string)
	local buffer = BitBuffer.FromString(stream)

	local id = buffer:ReadUInt32()
	local position = Vector3.new(buffer:ReadUInt32(), buffer:ReadUInt32(), buffer:ReadUInt32())
	local orientation = Vector3.new(buffer:ReadUInt32(), buffer:ReadUInt32(), buffer:ReadUInt32())

	local data = {
		position = position,
		orientation = orientation,
	}

	return id, data
end

return transform
