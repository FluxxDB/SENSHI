local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Packages = ReplicatedStorage.Packages
local Matter = require(Packages.Matter)
local Signal = require(Packages.Signal)
local Components = require(ReplicatedStorage.Shared.components)

local random = Random.new()
local useEvent = Matter.useEvent
local characterAdded = Signal.new()

local function playerSpawner(world)
	for _, player: Player in useEvent(Players, "PlayerAdded") do
		local characterId = world:spawn(
			Components.Player({ instance = player }),
			Components.Model(),
			Components.Health(),
			Components.Transform({
				-- Testing Random Spawn
				cframe = CFrame.new(random:NextNumber(-50, 50) * 2048, 0, random:NextNumber(-50, 50) * 2048),
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
