--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

local Components = require(ReplicatedStorage.Shared.components)

local Movement = Components.Movement
local GamePlacement = Components.GamePlacement

-- TODO: Take LOD into account
function movementUpdatesPlacement(world: Matter.World)
	-- for id, record in world:queryChanged(Movement) do
	-- 	if record.new == nil then
	-- 		continue
	-- 	end

	-- 	local currentSpeed = record.new.velocity.Magnitude
	-- 	local adjustedSpeed = math.min(currentSpeed, record.new.maxSpeed)
	-- 	local speedReductionRatio = adjustedSpeed / currentSpeed

	-- 	local expectedVelocity = record.new.velocity * speedReductionRatio
	-- 	local expectedAngularVelocity =
	-- 		math.clamp(record.new.angularVelocity, -record.new.maxAngularSpeed, record.new.maxAngularSpeed)

	-- 	if expectedVelocity == record.new.velocity and expectedAngularVelocity == record.new.angularVelocity then
	-- 		continue
	-- 	end

	-- 	world:insert(
	-- 		id,
	-- 		record.new:patch({
	-- 			velocity = expectedVelocity,
	-- 			angularVelocity = expectedAngularVelocity,
	-- 		})
	-- 	)
	-- end

	-- for id, movement, placement in world:query(Movement, GamePlacement) do
	-- 	world:insert(
	-- 		id,
	-- 		placement:patch({
	-- 			position = placement.position + movement.velocity,
	-- 			orientation = placement.orientation + movement.angularVelocity,
	-- 		})
	-- 	)
	-- end
end

return {
	system = movementUpdatesPlacement,
}
