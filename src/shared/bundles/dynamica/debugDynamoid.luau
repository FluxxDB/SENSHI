local components = require("@shared/components")
local gizmo = require("@shared/utils/gizmo")
local matterTypes = require("@types/matter")

local Position = components.Position
local Orientation = components.Orientation
local Velocity = components.Velocity

local Dynamoid = components.Dynamoid
local BumperSphere = components.BumperSphere
local LifterSphere = components.LifterSphere

-- local style = gizmo.style
-- local sphere = gizmo.wiresphere
-- local arrow = gizmo.arrow

local function debugDynamoid(world: matterTypes.World, state, ui)
	if state.debugEnabled == false then
		return
	end

	-- for id, position, dynamoid, bumperSphere, lifterSphere in
	-- 	world:query(Position, Dynamoid, BumperSphere, LifterSphere)
	-- do
	-- 	style.color = Color3.fromRGB(55, 255, 55)
	-- 	sphere.draw(position.value + bumperSphere.offset, bumperSphere.size.X)
	--
	-- 	style.color = Color3.fromRGB(255, 255, 255)
	-- 	sphere.draw(position.value + lifterSphere.offset, lifterSphere.size.X)
	-- end
end

return {
  debug = true,
	system = debugDynamoid,
	event = "PostSimulation",
}
