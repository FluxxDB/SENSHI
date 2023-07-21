local BitBuffer = require(game:GetService("ReplicatedStorage").Vendor.BitBuffer)

local ID_INCREMENT = 0

local status = {}
local all_statuses = {} :: { [any]: TStatus }
status.all_statuses = all_statuses

export type TStatus = {
  hitPoints: number,
  maxHitPoints: number,
  hunger: number,
}

status.createStruct = function()
  ID_INCREMENT += 1

  local statusId = tostring(ID_INCREMENT)
  local status: TStatus = {
    hunger = 0,
    hitPoints = 0,
    maxHitPoints = 0,
  }

  all_statuses[statusId] = status
  return statusId, status
end

status.serialize = function(id: string, struct: TStatus?)
  local status: TStatus = struct or all_statuses[id]
  local buffer = BitBuffer()

  buffer.writeUInt32(tonumber(id))
  buffer.writeUInt8(tonumber(status.hunger))
  buffer.writeUInt16(tonumber(status.hitPoints))
  buffer.writeUInt16(tonumber(status.maxHitPoints))
  
  return buffer.dumpString()
end

status.deserialize = function(stream: string)
  local buffer = BitBuffer(stream)
  
  local statusId = buffer:readUInt32()
  local hunger = buffer:readUInt8()
  local hitPoints = buffer:readUInt16()
  local maxHitPoints = buffer:readUInt16()

  local status: TStatus = {
    hunger = hunger,
    hitPoints = hitPoints,
    maxHitPoints = maxHitPoints
  }

  all_statuses[statusId] = status
end

return status