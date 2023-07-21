local BitBuffer = require(game:GetService("ReplicatedStorage").Vendor.BitBuffer)
local transformStruct = require(script.Parent.transform)
local statusStruct = require(script.Parent.status)

local ID_INCREMENT = 0

local entity = {}
local all_entities = {} :: { [any]: TEntity }
entity.all_entities = all_entities

export type TEntity = {
  statusId: number,
  transformId: number,
}

entity.createStruct = function()
  ID_INCREMENT += 1
  
  local entityId = tostring(ID_INCREMENT)
  local entity: TEntity = {
    statusId = statusStruct.createStruct(),
    transformId = transformStruct.createStruct(),
  }

  all_entities[entityId] = entity
  return entityId, entity
end

entity.serialize = function(id: string, struct: TEntity?)
  local entity = struct or all_entities[id]
  local buffer = BitBuffer()

  buffer.writeUInt32(tonumber(id))
  buffer.writeUInt32(tonumber(entity.statusId))
  buffer.writeUInt32(tonumber(entity.transformId))
  
  return buffer.dumpString()
end

entity.deserialize = function(stream: string)
  local buffer = BitBuffer(stream)
  
  local entityId = buffer:readUInt32()
  local statusId = buffer:readUInt32()
  local transformId = buffer:readUInt32()

  local entity: TEntity = {
    statusId = statusId,
    transformId = transformId
  }

  all_entities[entityId] = entity
end

return entity