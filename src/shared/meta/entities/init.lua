local entityGroup = {
	drop = require(script.drop),
	creature = require(script.creature),
	profile = require(script.profile),
	resource = require(script.resource),
	status = require(script.status),
}

local function mapEntitiesToIds(entityGroup: { any })
	local array = {}

	for key, value in entityGroup do
		array[#array + 1] = { key = key, value = value }
	end

	table.sort(array, function(a, b)
		return a.key < b.key
	end)

	local mappedTable = {}

	for index, data in array do
		mappedTable[tostring(index)] = data.value
		mappedTable[data.value] = tostring(index)
		data.value.sharedId = tostring(index)
	end

	return mappedTable
end

return {
	entityGroup = entityGroup,
	mappedGroups = mapEntitiesToIds(entityGroup),
}
