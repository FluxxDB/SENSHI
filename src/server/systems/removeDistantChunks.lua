local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Components = require(Shared.components)
local constants = require(Shared.constants)

local mappedGroups = require(Shared.meta.entities).mappedGroups

local ChunkRef = Components.ChunkRef
local Player = Components.Player

local useThrottle = Matter.useThrottle
local serverChunks = constants.CHUNKS

local function removeDistantChunks(world: Matter.World)
	if useThrottle(1) then
		local players = {}

		for id, player, chunkRef in world:query(Player, ChunkRef) do
			table.insert(players, {
				chunkRef = chunkRef,
			})
		end

		for id, chunkRef in serverChunks:GetVoxels() do
			local average = 0
			for _, playerChunkRef in players do
				-- TODO: Get funny average of distance!
				-- TODO: Remove chunk and its entities if its greater than a certain value!
			end
		end

		-- for _, player in players do
		-- 	local currentChunk = player.chunkRef
		-- 	serverChunks:ForEachObjectInRadius(
		-- 		Vector3.new(currentChunk.x, 0, currentChunk.y),
		-- 		2,
		-- 		function(entityType, entityId)
		-- 		end
		-- 	)
		-- end
	end
end

return removeDistantChunks
