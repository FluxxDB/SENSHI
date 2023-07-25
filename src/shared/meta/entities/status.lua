local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)

export type TStatus = {
	hitPoints: number,
	maxHitPoints: number,
	hunger: number,
}

local status = {}

function status:serialize(id: string, struct: TStatus)
	local data = struct
	local buffer = BitBuffer.new()

	buffer:WriteUInt32(tonumber(id))
	buffer:WriteUInt8(tonumber(data.hunger))
	buffer:WriteUInt16(tonumber(data.hitPoints))
	buffer:WriteUInt16(tonumber(data.maxHitPoints))

	return buffer.dumpString()
end

function status:deserialize(stream: string)
	local buffer = BitBuffer.FromBase91(stream)

	local entityId = buffer:ReadUInt32()
	local hunger = buffer:ReadUInt8()
	local hitPoints = buffer:ReadUInt16()
	local maxHitPoints = buffer:ReadUInt16()

	local data = {
		hunger = hunger,
		hitPoints = hitPoints,
		maxHitPoints = maxHitPoints,
	}

	return entityId, data
end

return status
