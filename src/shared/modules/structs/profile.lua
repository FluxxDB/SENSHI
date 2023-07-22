local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseStruct = require(ReplicatedStorage.Shared.class.BaseStruct)
local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)

export type TProfile = {
	transformId: number,
	statusId: number,
	inventoryId: number,
}
--[[
	AttributesId: 
	{
		strenght = 3.5
		speed...

	}

	Attributes: ->
	{
		type = Enum.Strength
		value = 3.5
	}
--]]

export type ProfileStruct = BaseStruct.BaseStruct<TProfile>
local profile: ProfileStruct = BaseStruct.new()

function profile:serialize(id: string, struct: TProfile?)
	local data = struct or profile:getById(id)
	local buffer = BitBuffer()

	return buffer.dumpString()
end

function profile:deserialize(stream: string)
	local buffer = BitBuffer(stream)

	local profileId = buffer:readUInt32()

	local data = {}

	return profileId, data
end

return profile
