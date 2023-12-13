local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local React = require(Packages.React)
local Matter = require(Packages.Matter)

local matterContext

return function(world)
	if matterContext == nil then
		matterContext = React.createContext(world)
	end

	return matterContext
end
