--!native

local constants = require(script.Parent.constants)

local GRID_EDGE_LENGTH = constants.GRID_EDGE_LENGTH
local MAXIMUM_DISTANCE_FROM_ORIGIN = constants.MAXIMUM_DISTANCE_FROM_ORIGIN

local helpers = {}

helpers.getGridEdgeLength = function()
	return GRID_EDGE_LENGTH
end

helpers.getMaximumDistanceFromOrigin = function()
	return MAXIMUM_DISTANCE_FROM_ORIGIN
end

helpers.isBeyondSwitchThreshold = function(input: Vector3 | CFrame)
	return math.max(math.abs(input.X), math.abs(input.Y), math.abs(input.Z)) < GRID_EDGE_LENGTH
end

helpers.transformToGrid = function(input: Vector3)
	local x, y, z = input.X, input.Y, input.Z

	if math.max(math.abs(x), math.abs(y), math.abs(z)) < GRID_EDGE_LENGTH then
		return Vector3.zero, input
	end

	local x_r = math.round(x / GRID_EDGE_LENGTH)
	local y_r = math.round(y / GRID_EDGE_LENGTH)
	local z_r = math.round(z / GRID_EDGE_LENGTH)
	local t_x = x - x_r * GRID_EDGE_LENGTH
	local t_y = y - y_r * GRID_EDGE_LENGTH
	local t_z = z - z_r * GRID_EDGE_LENGTH

	return Vector3.new(x_r, y_r, z_r), Vector3.new(t_x, t_y, t_z)
end

helpers.gridPosition = function(pos: Vector3, translation: Vector3)
	return Vector3.new(
		pos.X * GRID_EDGE_LENGTH + translation.X,
		pos.Y * GRID_EDGE_LENGTH + translation.Y,
		pos.Z * GRID_EDGE_LENGTH + translation.Z
	)
end

return helpers
