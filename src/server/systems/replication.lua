--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.components)

local constants = require(ReplicatedStorage.Shared.constants)
local playerEntity = require(script.Parent["spawnPlayer"])
local characterAdded = playerEntity.events.characterAdded

local useEvent = require(ReplicatedStorage.Packages.Matter).useEvent
local serverChunks = constants.CHUNKS

local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = "MatterRemote"
RemoteEvent.Parent = ReplicatedStorage

local REPLICATION_RADIUS = constants.REPLICATION_RADIUS
local REPLICATED_COMPONENTS = constants.REPLICATED_COMPONENTS

local replicatedComponents = {}

for _, name in REPLICATED_COMPONENTS do
	replicatedComponents[Components[name]] = true
end

local function replication(world: Matter.World)
	for _, player, playerId in useEvent(characterAdded, characterAdded.Connect) do
		local payload = {}

		local playerEntity = world:_getEntity(playerId)
		local playerChunkRef = playerEntity[Components.ChunkRef]

		serverChunks:ForEachObjectInRadius(playerChunkRef.voxelKey, constants.REPLICATION_RADIUS, function(_, entityId)
			-- Shouldn't be calling _getEntity... Too bad!
			local entityData = world:_getEntity(entityId)
			if entityData == nil then
				return
			end

			local entityChunkRef = entityData[Components.ChunkRef]
			if entityChunkRef == nil then
				return
			end

			local distance = (playerChunkRef.voxelKey - entityChunkRef.voxelKey).Magnitude
			if distance > REPLICATION_RADIUS then
				return
			end

			local entityPayload = {}

			for component, componentData in entityData do
				if replicatedComponents[component] then
					entityPayload[tostring(component)] = { data = componentData }
				end
			end

			payload[tostring(entityId)] = entityPayload
		end)

		local playerPayload = {}

		for component, componentData in playerEntity do
			if replicatedComponents[component] then
				playerPayload[tostring(component)] = { data = componentData }
			end
		end

		payload[tostring(playerId)] = playerPayload

		RemoteEvent:FireClient(player, payload)
	end

	local playerChanges = {}

	for component in replicatedComponents do
		local name = tostring(component)
		for entityId, record in world:queryChanged(component) do
			local key = tostring(entityId)

			for id, playerRef, chunkRef in world:query(Components.PlayerRef, Components.ChunkRef) do
				local changes = playerChanges[playerRef.instance]
				if changes == nil then
					playerChanges[playerRef.instance] = {}
					changes = playerChanges[playerRef.instance]
				end

				if changes[key] == nil then
					changes[key] = {}
				end

				if world:contains(entityId) then
					local entityChunkRef = world:get(entityId, chunkRef)
					if entityChunkRef == nil then
						continue
					end

					local distance = (chunkRef.voxelKey - entityChunkRef.voxelKey).Magnitude
					if distance < REPLICATION_RADIUS then
						changes[key][name] = { data = record.new }
					end
				end
			end
		end
	end

	if next(playerChanges) then
		for player, changes in playerChanges do
			RemoteEvent:FireClient(player, changes)
		end
	end
end

return {
	system = replication,
	priority = math.huge,
}
