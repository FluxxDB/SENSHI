local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gizmos = require(ReplicatedStorage.Vendor.ImGizmo)
local start = require(ReplicatedStorage.Shared.start)
local receiveReplication = require(script.Parent.receiveReplication)

local world, state = start({
	script.Parent.systems,
	ReplicatedStorage.Shared.systems,
})

Gizmos.Init()
receiveReplication(world, state)
