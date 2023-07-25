--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local Components = require(Shared.components)

-- local BitBuffer = require(ReplicatedStorage.Vendor.BitBuffer)
-- local uuidUtils = require(Shared.utils["uuid-utils"])

local creature = {}
creature.components = {
	Components.Health,
	Components.Model,
	Components.Transform,
}

export type TCreature = {}
export type TCreatureOptions = {
	Health: { any },
	Model: { any },
	Transform: { any },
}

function creature:createComponents(options: TCreatureOptions)
	local entityComponents = {
		Components.EntityType({
			typeId = self.sharedId,
		}),
	}

	for component, data in options do
		table.insert(entityComponents, Components[component](data))
	end

	return unpack(entityComponents)
end

function creature:serialize(serverId: string, struct: TCreature)
	-- local data = struct
	-- local buffer = BitBuffer.new()

	-- buffer:WriteUInt32(tonumber(serverId))
	-- buffer:WriteBytes(uuidUtils.pack(data.uuid))
	-- buffer:WriteUInt16(tonumber(data.itemId))
	-- buffer:WriteUInt16(tonumber(data.modelId))
	-- buffer:WriteUInt16(tonumber(data.quantity))
	-- buffer:WriteUInt32(tonumber(data.transformId))

	-- return buffer.ToBase91()
end

function creature:deserialize(stream: string)
	-- local buffer = BitBuffer.FromBase91(stream)

	-- local serverId = buffer:ReadUInt32()
	-- local uuid = uuidUtils.unpack(buffer:ReadBytes(16))
	-- local itemId = buffer:ReadUInt16()
	-- local modelId = buffer:ReadUInt16()
	-- local quantity = buffer:ReadUInt32()
	-- local transformId = buffer:ReadUInt32()

	-- local data: TCreature = {
	-- 	uuid = uuid,
	-- 	itemId = itemId,
	-- 	modelId = modelId,
	-- 	quantity = quantity,
	-- 	transformId = transformId,
	-- }

	-- return serverId, data
end

return creature
