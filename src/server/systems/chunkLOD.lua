local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Components = require(Shared.components)
local chunkManager = require(script.Parent.chunkManager)
local constants = require(Shared.constants)

local ChunkLOD = Components.ChunkLOD
local ChunkRef = Components.ChunkRef
local Player = Components.Player

local useThrottle = Matter.useThrottle
local serverChunks = constants.CHUNKS

local function chunkLOD(world: Matter.World)
	if useThrottle(1) then
		local players = {}

		for id, player, chunkRef in world:query(Player, ChunkRef) do
			table.insert(players, chunkRef.voxelKey)
		end

		if next(players) == nil then
			return
		end

		for position, voxel in serverChunks:GetVoxels() do
			local closestDistance = math.huge

			for _, playerVoxelKey in players do
				local playerMagnitude = (position - playerVoxelKey).Magnitude
				if playerMagnitude >= closestDistance then
					continue
				end

				closestDistance = playerMagnitude
			end

			local chunkLOD
			if closestDistance <= 8192 / 2048 then
				chunkLOD = 1
			elseif closestDistance > 8192 / 2048 and closestDistance <= 16384 / 2048 then
				chunkLOD = 2
			elseif closestDistance > 16384 / 2048 and closestDistance <= 32768 / 2048 then
				chunkLOD = 3
			else
				serverChunks:ClearVoxel(position)
			end

			world:insert(
				voxel.entityId,
				ChunkLOD({
					level = chunkLOD,
				})
			)
		end
	end
end

return {
	system = chunkLOD,
	after = { chunkManager },
}
