local components = require("@shared/components")
local matterTypes = require("@types/matter")

local Position = components.Position
local Velocity = components.Velocity
local Orientation = components.Orientation

local Dynamoid = components.Dynamoid
local BumperSphere = components.BumperSphere
local LifterSphere = components.LifterSphere

return function(world: matterTypes.World)
	local humanoid = Instance.new("Humanoid")
	humanoid.EvaluateStateMachine = false

	print(`Spawning Dynamoid`)

	world:spawn(
		Dynamoid({
			humanoid = humanoid,
		}),

		Position({
			value = Vector3.new(0, 3, 0),
		}),

		Orientation({
			value = Vector3.zero,
		}),

		Velocity({
			value = Vector3.zero,
		}),

		BumperSphere({
			size = Vector3.new(2, 4, 2),
			offset = Vector3.new(0, 0, 0),
		}),

		LifterSphere({
			size = Vector3.new(1.5, 1.5, 1.5),
			offset = Vector3.new(0, -1.5, 0),
		})
	)
end
