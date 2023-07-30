--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local useEvent = Matter.useEvent

local remotes = require(Shared.remotes)
local characterRemotes = remotes.Server:GetNamespace("Character")

local moveEvent = characterRemotes:Get("Move") :: { Connect: any }

local function playerUpdatesPlacement()
	for _, player in useEvent(moveEvent.Connect, moveEvent) do
		-- he he he-ha
	end
end

return {
	system = playerUpdatesPlacement,
}
