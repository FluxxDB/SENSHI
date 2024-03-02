local constants = {}

constants.GRID_EDGE_LENGTH = 2000
constants.SWITCH_THRESHOLD = 100
constants.MAXIMUM_DISTANCE_FROM_ORIGIN = constants.GRID_EDGE_LENGTH / 2.0 + constants.SWITCH_THRESHOLD
constants.PRIORITIES = {
  FIRST = -math.huge,
  FINAL = math.huge, 
}

return constants
