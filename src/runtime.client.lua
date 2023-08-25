local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gizmos = require(ReplicatedStorage.Vendor.ImGizmo)
local start = require(ReplicatedStorage.Shared.start)
local reactInitialize = require(ReplicatedStorage.Client.reactInitialize)
local receiveReplication = require(ReplicatedStorage.Client.receiveReplication)

local world, state = start({
	ReplicatedStorage.Client.systems,
	ReplicatedStorage.Shared.systems,
})

Gizmos.Init()
receiveReplication(world, state)
reactInitialize(world, state)
