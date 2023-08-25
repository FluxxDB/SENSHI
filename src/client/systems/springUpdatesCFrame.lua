local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)

local Components = require(Shared.components)
local PlayerRef = Components.PlayerRef
local Spring = Components.Spring
local Model = Components.Model

-- now we change the loop priority of this system to heartbeat
function springUpdatesCFrame(world: Matter.World)
	-- TODO: Add rotation
	for id, model, spring in world:query(Model, Spring) do
		local playerRef = world:get(id, PlayerRef)
		if playerRef and playerRef.instance == Players.LocalPlayer then
			continue
		end

		local origin = workspace:GetAttribute("Origin")
		local currentPosition = spring.spring.Position

		local xPosition, zPosition = currentPosition.X - origin.X, currentPosition.Z - origin.Z
		if model.instance then
			model.instance:PivotTo(CFrame.new(xPosition, currentPosition.Y, zPosition))
		end
	end
end

return {
	system = springUpdatesCFrame,
	event = "Stepped",
}
