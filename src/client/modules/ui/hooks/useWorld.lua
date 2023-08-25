local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:FindFirstChild("Packages")
local React = require(Packages.React)
local Matter = require(Packages.Matter)

local MatterWorldContext = require(script.Parent.Parent.MatterWorldContext)

return function()
	local world: Matter.World = React.useContext(MatterWorldContext())
	return world
end
