local ORIGIN_LIMIT = 2048
local chunkUtils = {}

function chunkUtils.getChunkPosition(position: Vector3)
    return Vector2.new(position.X / ORIGIN_LIMIT, position.Z / ORIGIN_LIMIT)
end

function chunkUtils.getChunkCoordinate(position: Vector3)
    local chunkPosition = chunkUtils.getChunkPosition(position)
    return Vector2int16.new(chunkPosition.X, chunkPosition.Y)
end

function chunkUtils.getChunkOrigin(coordinate)
    if typeof(coordinate) == "Vector3" then
        coordinate = chunkUtils.getChunkCoordinate(coordinate)
    end

    return Vector2.new(
        (coordinate.X == 0) and 0 or ((coordinate.X * ORIGIN_LIMIT)), 
        (coordinate.Y == 0) and 0 or ((coordinate.Y * ORIGIN_LIMIT))
    )
end

return chunkUtils