local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VectorMap2D = require(ReplicatedStorage.Shared.classes.VectorMap2D)

local constants = {}

constants.VOXEL_SIZE = 2048
constants.CHUNKS = VectorMap2D.new(constants.VOXEL_SIZE)
constants.CHUNK_SPAWN_DISTANCE = 4

constants.REPLICATION_RADIUS = 5
constants.REPLICATED_COMPONENTS = {
	"PlayerRef",
	"Health",

	"Effect",
	"Model",
	"Transform",
	"GamePlacement",

	"Resource",
	"Movement",
	"GamePlacement",
	"Chunk",
	"ChunkRef",

	"Incantation",
}

return constants
