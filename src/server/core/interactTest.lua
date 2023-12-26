local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Matter = require(Packages.Matter)
local useEvent = Matter.useEvent

local bundles = ReplicatedStorage.shared.bundles
local actionsManager = bundles.actionsManager

local onInputBeganSignal, onInputEndedSignal = unpack(require(actionsManager.signals))

function interactTest(world: Matter.World)
	for _, action in useEvent(onInputBeganSignal, onInputBeganSignal.Connect) do
		if action ~= "Interact" then
			continue
		end

		print("Interact Began")
	end

	for _, action in useEvent(onInputEndedSignal, onInputEndedSignal.Connect) do
		if action ~= "Interact" then
			continue
		end

		print("Interact Ended")
	end
end

return {
	system = interactTest,
}
