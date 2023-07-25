local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local Signal = require(Packages.Signal)

local Components = require(ReplicatedStorage.Shared.components)
local entityGroup = require(Shared.meta.entities).entityGroup

local random = Random.new()
local creature = entityGroup.creature
local useEvent = Matter.useEvent
local characterAdded = Signal.new()

local function playerSpawner(world)
	for _, player: Player in useEvent(Players, "PlayerAdded") do
		local characterId = world:spawn(
			Components.Player({ instance = player }),
			creature:createComponents({
				Model = {},
				Health = {},
				Transform = {
					-- Testing Random Spawn
					cframe = CFrame.new(0, 0, 0),
					-- cframe = CFrame.new(random:NextNumber(-50, 50) * 2048, 0, random:NextNumber(-50, 50) * 2048),
				},
			})
		)

		print(world:get(characterId, Components.Transform).cframe)
		characterAdded:Fire(player, characterId)
	end
end

return {
	system = playerSpawner,
	events = {
		characterAdded = characterAdded,
	},
}
