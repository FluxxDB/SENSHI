local Signal = require("@packages/Signal")

local matterTypes = require("@types/matter")
local components = require("@shared/components")

local entityMap = {}
local gridEntered = Signal.new()

local GridCell = components.GridCell

local function updateGridFromTransform(world: matterTypes.World)
	for id, record in world:queryChanged(GridCell) do
		local key = tostring(id)
		local newGridCell = record.new
		local oldGridCell = record.old

		if oldGridCell then
			local mapCell = entityMap[oldGridCell.value]

			if mapCell == nil then
				continue
			end

			mapCell[key] = nil
		end

		if newGridCell then
			local mapCell = entityMap[newGridCell.value]

			if mapCell == nil then
				mapCell = {}
				entityMap[newGridCell.value] = mapCell
			end

			local entity = world:_getEntity(id)
			mapCell[key] = entity
			gridEntered:Fire(key, newGridCell.value, entity)
		end
	end
end

return {
	system = updateGridFromTransform,
	after = { require(script.Parent.updateGridFromTransform) },
	entityMap = entityMap,
	gridEntered = gridEntered,
}
