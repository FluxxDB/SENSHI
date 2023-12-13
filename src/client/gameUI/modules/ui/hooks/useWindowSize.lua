local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local function useWindowSize()
	local viewportSize, setViewportSize = React.useState(Workspace.CurrentCamera.ViewportSize)

	local handleResize = function()
		setViewportSize(Workspace.CurrentCamera.ViewportSize)
	end

	React.useEffect(function()
		local viewportChanged = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(handleResize)

		return function()
			viewportChanged:Disconnect()
		end
	end, {})

	return viewportSize
end

return useWindowSize
