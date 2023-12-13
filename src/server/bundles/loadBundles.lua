local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bundles = ReplicatedStorage.shared.bundles

return {
	setups = {},
	systems = {
		bundles.farlands.updateGridFromTransform,
		bundles.farlands.updateEntityMapFromGridCell,
	},
}
