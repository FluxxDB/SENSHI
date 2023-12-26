local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Matter = require(ReplicatedStorage.Packages.Matter)
local useEvent = Matter.useEvent

local inputBeganSignal, inputEndedSignal = unpack(require(script.Parent.signals))
local remotes = require(script.Parent.remotes)
local inputBeganRemote = remotes.Client:Get("InputBegan")
local inputEndedRemote = remotes.Client:Get("InputEnded")

local bindings = require(script.Parent.bindings)
local bindingsCollection = bindings.inputsCollection

function forwardInputs(world: Matter.World)
	for _, inputObject, gameProcessed in useEvent(UserInputService, "InputBegan") do
		print("Aaaaa")
		if gameProcessed then
			continue
		end

		local binding = bindingsCollection[inputObject.KeyCode]
		print(inputObject.KeyCode == Enum.KeyCode.E)
		if binding then
			inputBeganRemote:Fire(binding.Action)
			inputBeganSignal:Fire(binding.Action)
		end
	end

	for _, inputObject, gameProcessed in useEvent(UserInputService, "InputEnded") do
		if gameProcessed then
			continue
		end

		local binding = bindingsCollection[inputObject.KeyCode]
		if binding then
			inputEndedRemote:Fire(binding.Action)
			inputEndedSignal:Fire(binding.Action)
		end
	end
end

return {
	system = forwardInputs,
}
