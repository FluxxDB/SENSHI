local matterTypes = require("@types/matter")
local components = require("@shared/components")

local OriginRef = components.OriginRef
local Transform = components.Transform

local oldCFrame: CFrame

local function reflectOriginRefTransform(world: matterTypes.World)
	for id, originRef in world:query(OriginRef) do
		local target = originRef.target

		if oldCFrame ~= target.CFrame then
			oldCFrame = target.CFrame
			world:insert(
				id,
				Transform({
					value = oldCFrame,
				})
			)
		end
	end
end

return {
	system = reflectOriginRefTransform,
	priority = 0,
}
