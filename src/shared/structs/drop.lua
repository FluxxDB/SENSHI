local BitBuffer = require(game:GetService("ReplicatedStorage").Vendor.BitBuffer)
local transformStruct = require(script.Parent.transform)

local ID_INCREMENT = 0

local drop = {}
local all_drops = {} :: { [any]: TDrop }
drop.all_drops = all_drops

export type TDrop = {
  seed: number?,
  itemId: number,
  modelId: number,
  quantity: number?,
  transformId: number,
}

type TDropOptions = {
  seed: number?,
  itemId: number,
  modelId: number,
  quantity: number?,
}

function drop.createStruct(options: TDropOptions)
  ID_INCREMENT += 1
  
  local dropId = tostring(ID_INCREMENT)
  local items: TDrop = {
    seed = options.seed,
    itemId = options.itemId,
    modelId = options.modelId,
    quantity = options.quantity,
    transformId = transformStruct.createStruct(),
  }

  all_drops[dropId] = items
  return dropId, items
end

function drop.serialize(id: string, struct: TDrop?)
  local drop = struct or all_drops[id]
  local buffer = BitBuffer()

  buffer.writeUInt32(tonumber(id))
  buffer.writeUInt32(tonumber(drop.seed))
  buffer.writeUInt16(tonumber(drop.itemId))
  buffer.writeUInt16(tonumber(drop.modelId))
  buffer.writeUInt16(tonumber(drop.quantity))
  buffer.writeUInt32(tonumber(drop.transformId))
  
  return buffer.dumpString()
end

function drop.deserialize(stream: string)
  local buffer = BitBuffer(stream)
  
  local dropId = buffer:readUInt32()
  local seed = buffer:writeUInt16()
  local itemId = buffer:writeUInt16()
  local modelId = buffer:writeUInt16()
  local quantity = buffer:readUInt32()
  local transformId = buffer:readUInt32()

  local entity: TDrop = {
    statusId = dropId,
    seed = seed,
    itemId = itemId,
    modelId = modelId,
    quantity = quantity,
    transformId = transformId,
  }

  all_drops[dropId] = entity
end

return drop