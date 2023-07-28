local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events = ReplicatedStorage.Events
local characterMonitorEvent = events.Server["CharacterMonitor"]
local playerSpawner = require(script.Parent.playerSpawner)

local function characterMonitor() end

return {
	system = characterMonitor,
	after = { playerSpawner },
}
