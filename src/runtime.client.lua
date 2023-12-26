local ReplicatedStorage = game:GetService("ReplicatedStorage")

local start = require(ReplicatedStorage.shared.start)
start({
	ReplicatedStorage.client.core,
	ReplicatedStorage.client.bundles,
	ReplicatedStorage.shared.core,
	ReplicatedStorage.shared.bundles,
})

-- require(ReplicatedStorage.vendor.CeiveImGizmo).Init()
