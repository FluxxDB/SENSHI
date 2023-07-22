local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RuntimeLoader = require(ReplicatedStorage.Shared["runtime-loader"])

local Framework = script.Parent

RuntimeLoader.loadModules(Framework:WaitForChild("services"))
