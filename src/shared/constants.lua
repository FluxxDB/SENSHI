local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vector2Map = require(ReplicatedStorage.Shared.classes.Vector2Map)

local constants = {}

constants.VOXEL_SIZE = 2048
constants.CHUNKS = Vector2Map.new(constants.VOXEL_SIZE)

return constants
