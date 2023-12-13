local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bundles = ReplicatedStorage.shared.bundles

return {
	setups = {},
	systems = {
		bundles.farlands.reflectOriginRefTransform,
		bundles.farlands.updateGridFromTransform,
		bundles.farlands.updateOriginFromGrid,
	},
}
