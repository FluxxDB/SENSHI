local ReplicatedStorage = game:GetService("ReplicatedStorage")
local start = require(ReplicatedStorage.shared.start)

start({
	script.Parent.bundles,
	script.Parent.core,
})
