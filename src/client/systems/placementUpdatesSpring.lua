local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)

local Components = require(Shared.components)
local GamePlacement = Components.GamePlacement
local Spring = Components.Spring

function placementUpdatesSpring(world: Matter.World)
	for id, record in world:queryChanged(GamePlacement) do
		if record.new == nil then
			continue
		end

		local spring = world:get(id, Spring)
		if spring == nil then
			continue
		end

		spring.spring.Target = record.new.position

		-- REAL MEN DO THIS BELLOW
		-- world:insert(
		-- 	id,
		-- 	spring:patch({
		-- 		spring = spring.spring,
		-- 	})
		-- )
	end
end

return {
	system = placementUpdatesSpring,
}
