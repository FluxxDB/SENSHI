local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)

export type TProfile = {
	transformId: number,
	statusId: number,
	inventoryId: number,
	characterTraitsId: number,
}

local Profile = {}

function Profile:serialize(id: string, struct: TProfile)
	local data = struct
	local buffer = BitBuffer()

	buffer.writeUInt32(tonumber(id))
	buffer.writeUInt32(tonumber(data.transformId))
	buffer.writeUInt32(tonumber(data.statusId))
	buffer.writeUInt32(tonumber(data.inventoryId))
	buffer.writeUInt32(tonumber(data.characterTraitsId))

	return buffer.dumpString()
end

function Profile:deserialize(stream: string)
	local buffer = BitBuffer(stream)

	local profileId = buffer:readUInt32()
	local transformId = buffer:readUInt32()
	local statusId = buffer:readUInt32()
	local inventoryId = buffer:readUInt32()
	local characterTraitsId = buffer:readUInt32()

	local data = {
		transformId = transformId,
		statusId = statusId,
		inventoryId = inventoryId,
		characterTraitsId = characterTraitsId,
	}

	return profileId, data
end

return Profile
