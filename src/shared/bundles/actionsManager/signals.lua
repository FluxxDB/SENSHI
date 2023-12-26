local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local onInputBegan = Signal.new() :: Signal.Signal<string>
local onInputEnded = Signal.new() :: Signal.Signal<string>

return { onInputBegan, onInputEnded }
