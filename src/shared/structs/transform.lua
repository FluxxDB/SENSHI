local BitBuffer = require(game:GetService("ReplicatedStorage").Vendor.BitBuffer)

local ID_INCREMENT = 0

local transform = {}
local all_transforms = {} :: { [any]: TTransform }
transform.all_transforms = all_transforms

export type TTransform = {
  position: Vector3,
  orientation: Vector3
}

transform.createStruct = function()
  ID_INCREMENT += 1

  local transformId = tostring(ID_INCREMENT)
  local transform: TTransform = {
    position = Vector3.new(0, 0, 0),
    orientation = Vector3.new(0, 0, 0)
  }

  all_transforms[transformId] = transform
  return transformId, transform
end

transform.update = function(id: string, newTransform: TTransform)
  all_transforms[id] = newTransform
end

transform.serialize = function(id: string, struct: TTransform)
  local transform: TTransform = struct or all_transforms[id]
  local buffer = BitBuffer()

  buffer.writeUInt32(tonumber(id))
  buffer.writeUInt32(transform.position.X)
  buffer.writeUInt32(transform.position.Y)
  buffer.writeUInt32(transform.position.Z)
  buffer.writeUInt32(transform.orientation.X)
  buffer.writeUInt32(transform.orientation.Y)
  buffer.writeUInt32(transform.orientation.Z)
  
  return buffer.dumpString()
end

transform.deserialize = function(stream: string)
  local buffer = BitBuffer(stream)

  local transformId = buffer:readUInt32()
  local position = Vector3.new(buffer:readUInt32(), buffer:readUInt32(), buffer:readUInt32())
  local orientation = Vector3.new(buffer:readUInt32(), buffer:readUInt32(), buffer:readUInt32())
  
  local transform = {
    position = position,
    orientation = orientation
  }

  all_transforms[transformId] = transform
end

return transform