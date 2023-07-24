local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Packages = ReplicatedStorage.Packages
local Matter = require(Packages.Matter)
local Signal = require(Packages.Signal)
local Components = require(ReplicatedStorage.Shared.components)

local useEvent = Matter.useEvent
local characterAdded = Signal.new()

local function playerEntitySystem(world)
	for _, player: Player in useEvent(Players, "PlayerAdded") do
		local characterId =
			world:spawn(Components.Model(), Components.Health(), Components.Transform({ cFrame = CFrame.new(0, 0, 0) }))
		task.defer(characterAdded.Fire, characterAdded, player, characterId)
	end
end

return {
	system = playerEntitySystem,
	events = {
		characterAdded = characterAdded,
	},
}
