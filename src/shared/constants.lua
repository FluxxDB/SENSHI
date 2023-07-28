local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VectorMap2D = require(ReplicatedStorage.Shared.classes.VectorMap2D)

local constants = {}

constants.VOXEL_SIZE = 2048
constants.CHUNKS = VectorMap2D.new(constants.VOXEL_SIZE)

constants.REPLICATION_RADIUS = 4 -- 4x4 Chunks
constants.REPLICATED_COMPONENTS = {
	"Player",
	"Health",

	"Effect",
	"Target",

	"Model",
	"Transform",

	"Resource",
}

return constants
