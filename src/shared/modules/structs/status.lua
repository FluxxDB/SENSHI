local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseStruct = require(ReplicatedStorage.Shared.class.BaseStruct)
local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)

export type TStatus = {
	hitPoints: number,
	maxHitPoints: number,
	hunger: number,
}

export type StatusStruct = BaseStruct.BaseStruct<TStatus>
local status = BaseStruct.new() :: StatusStruct

function status:serialize(id: string, struct: TStatus?)
	local data = struct or status:getById(id)
	local buffer = BitBuffer()

	buffer.writeUInt32(tonumber(id))
	buffer.writeUInt8(tonumber(data.hunger))
	buffer.writeUInt16(tonumber(data.hitPoints))
	buffer.writeUInt16(tonumber(data.maxHitPoints))

	return buffer.dumpString()
end

function status.deserialize(stream: string)
	local buffer = BitBuffer(stream)

	local id = buffer:readUInt32()
	local hunger = buffer:readUInt8()
	local hitPoints = buffer:readUInt16()
	local maxHitPoints = buffer:readUInt16()

	local data = {
		hunger = hunger,
		hitPoints = hitPoints,
		maxHitPoints = maxHitPoints,
	}

	return id, data
end

return status
