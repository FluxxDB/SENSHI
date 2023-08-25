local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)

local SpringModule = require(Packages.Spring)

local Components = require(Shared.components)
local Spring = Components.Spring
local Model = Components.Model
local Movement = Components.Movement
local GamePlacement = Components.GamePlacement

function createMissingSprings(world: Matter.World)
	for id, model, movement, gamePlacement in world:query(Model, Movement, GamePlacement):without(Spring) do
		local spring = SpringModule.new(gamePlacement.position)
		-- let me break this
		spring.Damper = 0.87
		spring.Speed = 20

		world:insert(
			id,
			Spring({
				spring = spring,
			})
		)

		if model.instance then
			local origin = workspace:GetAttribute("Origin")
			local xPosition, zPosition = gamePlacement.position.X - origin.X, gamePlacement.position.Z - origin.Z
			model.instance:PivotTo(CFrame.new(xPosition, gamePlacement.position.Y, zPosition))
		end
	end
end

return {
	system = createMissingSprings,
}
