local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages

local Net = require(packages.Net)

return Net.CreateDefinitions({
	InputBegan = Net.Definitions.ClientToServerEvent(),
	InputEnded = Net.Definitions.ClientToServerEvent(),
})
