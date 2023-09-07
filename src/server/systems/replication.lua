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
	replicatedComponents[Components[name]] = name
end

function replication(world: Matter.World)
	for _, player, playerId in useEvent(characterAdded, characterAdded.Connect) do
		local payload = {}
		local playerEntity = world:_getEntity(playerId)

		local playerChunkRef = playerEntity[Components.ChunkRef]
		if not playerChunkRef then
			continue
		end

		serverChunks:ForEachObjectInRadius(playerChunkRef.voxelKey, constants.REPLICATION_RADIUS, function(_, entityId)
			if entityId == -1 or world == nil then
				return
			end

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

	for component, name in replicatedComponents do
		for entityId, record in world:queryChanged(component) do
			local key = tostring(entityId)
			for id, playerRef, chunkRef in world:query(Components.PlayerRef, Components.ChunkRef) do
				local changes = playerChanges[playerRef.instance]
				if changes == nil then
					changes = {}
					playerChanges[playerRef.instance] = changes
				end

				if changes[key] == nil then
					changes[key] = {}
				end

				if world:contains(entityId) then
					local entityChunkRef = world:get(entityId, Components.ChunkRef)
					if entityChunkRef == nil then
						continue
					end

					local distance = (chunkRef.voxelKey - entityChunkRef.voxelKey).Magnitude
					if distance <= REPLICATION_RADIUS then
						changes[key][name] = { data = record.new }
					end
				end
			end
		end
	end

	for player, changes in playerChanges do
		if next(changes) then
			RemoteEvent:FireClient(player, changes)
		end
	end
end

return {
	system = replication,
	priority = math.huge,
}
