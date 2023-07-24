local ReplicatedStorage = game:GetService("ReplicatedStorage")
local start = require(ReplicatedStorage.Shared.start)
local setupTags = require(ReplicatedStorage.Shared.setupTags)

local world = start({
	script.Parent.systems,
	ReplicatedStorage.Shared.systems,
})

setupTags(world)
