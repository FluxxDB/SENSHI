local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local useEvent = Matter.useEvent

local inputBeganSignal, inputEndedSignal = unpack(require(script.Parent.signals))
local remotes = require(script.Parent.remotes)
local inputBeganRemote = remotes.Server:Get("InputBegan")
local inputEndedRemote = remotes.Server:Get("InputEnded")

local function invokeSignals(world: Matter.World)
	for _, action in useEvent(inputBeganRemote, inputBeganRemote.Connect) do
		inputBeganSignal:Fire(action)
	end

	for _, action in useEvent(inputEndedRemote, inputEndedRemote.Connect) do
		inputEndedSignal:Fire(action)
	end
end

return {
	system = invokeSignals,
}
