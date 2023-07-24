local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

local COMPONENTS = {
	"DebugLabel",
	"Resource",
	"Health",
	"Effect",
	"Target",
	"Model",
	"Transform",

	"LOD",
}

local components = {}

for _, name in COMPONENTS do
	components[name] = Matter.component(name)
end

return components
