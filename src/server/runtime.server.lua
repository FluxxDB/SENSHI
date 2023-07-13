local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RuntimeLoader = require(ReplicatedStorage.shared["runtime-loader"])

local Framework = script.Parent

RuntimeLoader.loadModules(
    Framework:WaitForChild("services")
)