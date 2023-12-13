local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Components = require(ReplicatedStorage.shared.components)

local entityMap = {}
local gridEntered = Signal.new()

local function updateGridFromTransform(world: Matter.World)
	for id, record in world:queryChanged(Components.GridCell) do
		local key = tostring(id)
		local newGridCell = record.new
		local oldGridCell = record.old

		if oldGridCell then
			local mapCell = entityMap[oldGridCell.position]

			if mapCell == nil then
				continue
			end

			mapCell[key] = nil
		end

		if newGridCell then
			local mapCell = entityMap[newGridCell.position]

			if mapCell == nil then
				mapCell = {}
				entityMap[newGridCell.position] = mapCell
			end

			local entity = world:_getEntity(id)
			mapCell[key] = entity
			gridEntered:Fire(key, newGridCell.position, entity)
		end
	end
end

return {
	system = updateGridFromTransform,
	after = { require(script.Parent.updateGridFromTransform) },
	entityMap = entityMap,
	gridEntered = gridEntered,
}
