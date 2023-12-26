local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages
local Matter = require(packages.Matter)

return {} :: { [any]: typeof(Matter.component()) }
