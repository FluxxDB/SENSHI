local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.components)

local constants = require(ReplicatedStorage.Shared.constants)
local playerEntity = require(script.Parent["playerSpawner"])
local characterAdded = playerEntity.events.characterAdded

local useEvent = require(ReplicatedStorage.Packages.Matter).useEvent

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
	for _, player, characterId in useEvent(characterAdded, characterAdded.Connect) do
		if world:contains(characterId) == false then
			continue
		end

		local payload = {}
		local playerChunkRef = world:get(characterId, Components.ChunkRef)
		for entityId, entityData in world do
			local entityChunkRef = entityData[Components.ChunkRef]
			if entityChunkRef == nil then
				continue
			end

			local distance = (playerChunkRef.voxelKey - entityChunkRef.voxelKey).Magnitude
			if distance > REPLICATION_RADIUS then
				continue
			end

			local entityPayload = {}

			for component, componentData in entityData do
				if replicatedComponents[component] then
					entityPayload[tostring(component)] = { data = componentData }
				end
			end

			payload[tostring(entityId)] = entityPayload
		end

		RemoteEvent:FireClient(player, payload)
	end

	for component in replicatedComponents do
		for entityId, record in world:queryChanged(component) do
			for id, player, chunkRef in world:query(Components.Player, Components.ChunkRef) do
				local changes = {}

				local key = tostring(entityId)
				local name = tostring(component)

				if changes[key] == nil then
					changes[key] = {}
				end

				if world:contains(entityId) then
					local entityChunkRef = world:get(entityId, chunkRef)
					local distance = (chunkRef.voxelKey - entityChunkRef.voxelKey).Magnitude

					if distance > REPLICATION_RADIUS then
						continue
					end

					changes[key][name] = { data = record.new }
				end

				if next(changes) then
					RemoteEvent:FireClient(player.instance, changes)
				end
			end
		end
	end
end

return {
	system = replication,
	priority = math.huge,
}
