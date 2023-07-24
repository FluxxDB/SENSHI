local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gizmos = require(ReplicatedStorage.Vendor.ImGizmo)
local start = require(ReplicatedStorage.Shared.start)
local setupTags = require(ReplicatedStorage.Shared.setupTags)

local world = start({
	script.Parent.systems,
	ReplicatedStorage.Shared.systems,
})

setupTags(world)
Gizmos.Init()
