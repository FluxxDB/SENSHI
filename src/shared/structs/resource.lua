local BitBuffer = require(game:GetService("ReplicatedStorage").Vendor.BitBuffer)
local transformStruct = require(script.Parent.transform)

local ID_INCREMENT = 0

local resource = {}
local all_resources = {} :: { [any]: TResource }
resource.all_resources = all_resources

export type TResource = {
  modelId: number,
  dropId: number,
  quantity: number,
  transformId: number
}

type TResourceOptions = {
  modelId: number,
  dropId: number,
  quantity: number
}

resource.createStruct = function(options: TResourceOptions)
  ID_INCREMENT += 1

  local resourceId = tostring(ID_INCREMENT)
  local resource: TResource = {
    dropId = options.dropId,
    modelId = options.modelId,
    quantity = options.quantity,
    transformId = transformStruct.createStruct(),
  }

  all_resources[resourceId] = resource
  return resourceId, resource
end

resource.serialize = function(id: string, struct: TResource?)
  local resource: TResource = struct or all_resources[id]
  local buffer = BitBuffer()

  buffer.writeUInt32(tonumber(id))
  buffer.writeUInt16(tonumber(resource.dropId))
  buffer.writeUInt16(tonumber(resource.modelId))
  buffer.writeUInt16(tonumber(resource.quantity))
  buffer.writeUInt32(tonumber(resource.transformId))
  
  return buffer.dumpString()
end

resource.deserialize = function(stream: string)
  local buffer = BitBuffer(stream)
  
  local resourceId = buffer:readUInt32()
  local dropId = buffer:readUInt16()
  local modelId = buffer:readUInt16()
  local quantity = buffer:readUInt32()
  local transformId = buffer:readUInt32()
  
  local resource: TResource = {
    dropId = dropId,
    modelId = modelId,
    quantity = quantity,
    transformId = transformId
  }

  all_resources[resourceId] = resource
end

return resource