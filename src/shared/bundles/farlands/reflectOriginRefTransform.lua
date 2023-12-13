local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.shared.components)

local oldCFrame

local function reflectOriginRefTransform(world: matter.World)
	for id, originRef in world:query(Components.OriginRef) do
		local camera = originRef.camera

		if oldCFrame ~= camera.CFrame then
			oldCFrame = camera.CFrame
			world:insert(
				id,
				Components.Transform({
					translation = oldCFrame,
				})
			)
		end
	end
end

return {
	system = reflectOriginRefTransform,
	priority = -10,
}
