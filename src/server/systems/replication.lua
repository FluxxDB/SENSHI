local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Shared.components)

local playerEntity = require(script.Parent["playerSpawner"])
local characterAdded = playerEntity.events.characterAdded

local useEvent = require(ReplicatedStorage.Packages.Matter).useEvent

local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = "MatterRemote"
RemoteEvent.Parent = ReplicatedStorage

local REPLICATED_COMPONENTS = {
	-- ...
}

local replicatedComponents = {}

for _, name in REPLICATED_COMPONENTS do
	replicatedComponents[Components[name]] = true
end

local function replication(world)
	for _, player, characterId in useEvent(characterAdded, characterAdded.Connect) do
		if world:contains(characterId) == false then
			continue
		end
		print(player, characterId, "Player Joined", world:contains(characterId))
		-- local payload = {}

		-- local characterTransform = world:get(characterId, Components.Transform)
		-- for entityId, entityData in world do
		-- 	local transform = entityData[Components.Transform]
		-- 	if transform == nil then
		-- 		continue
		-- 	end

		-- 	-- should be in a different system...
		-- 	local distance = (
		-- 		(transform.cFrame.Position * Vector3.new(1, 0, 1))
		-- 		- characterTransform.cFrame.Position * Vector3.new(1, 0, 1)
		-- 	).Magnitude
		-- 	local entityLOD = entityData[Components.LOD] or Components.LOD({ players = {} })

		-- 	local playerLOD
		-- 	if distance <= 8192 then
		-- 		playerLOD = 1
		-- 	elseif distance > 8192 and distance <= 16384 then
		-- 		playerLOD = 2
		-- 	elseif distance > 16384 and distance <= 32768 then
		-- 		playerLOD = 3
		-- 	end

		-- 	local playerList = {
		-- 		[player] = playerLOD,
		-- 	}

		-- 	for player, level in entityLOD.players do
		-- 		playerList[player] = level
		-- 	end

		-- 	world:insert(
		-- 		entityId,
		-- 		Components.LOD:patch({
		-- 			players = playerList,
		-- 		})
		-- 	)

		-- 	local entityPayload = {}
		-- 	payload[tostring(entityId)] = entityPayload

		-- 	for component, componentData in entityData do
		-- 		if replicatedComponents[component] then
		-- 			entityPayload[tostring(component)] = { data = componentData }
		-- 		end
		-- 	end
		-- end

		-- print("Sending initial payload to", player, payload)
		-- RemoteEvent:FireClient(player, payload)
	end

	local changes = {}

	for component in replicatedComponents do
		for entityId, record in world:queryChanged(component) do
			local key = tostring(entityId)
			local name = tostring(component)

			if changes[key] == nil then
				changes[key] = {}
			end

			if world:contains(entityId) then
				changes[key][name] = { data = record.new }
			end
		end
	end

	if next(changes) then
		RemoteEvent:FireAllClients(changes)
	end
end

return {
	system = replication,
	priority = math.huge,
}
