local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RuntimeLoader = require(ReplicatedStorage.Shared["runtime-loader"])
local Gizmos = require(ReplicatedStorage.Vendor.ImGizmo)

local Framework = script.Parent

Gizmos.Init()
RuntimeLoader.loadModules(
    Framework:WaitForChild("controllers")
)