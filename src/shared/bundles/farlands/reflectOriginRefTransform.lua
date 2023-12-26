local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local componentRegistry = require(ReplicatedStorage.shared.componentRegistry)

local OriginRef = componentRegistry.OriginRef
local Transform = componentRegistry.Transform

local oldCFrame

local function reflectOriginRefTransform(world: Matter.World)
	for id, originRef in world:query(OriginRef) do
		local camera = originRef.camera

		if oldCFrame ~= camera.CFrame then
			oldCFrame = camera.CFrame
			world:insert(
				id,
				Transform({
					translation = oldCFrame,
				})
			)
		end
	end
end

return {
	system = reflectOriginRefTransform,
	priority = 0,
}
