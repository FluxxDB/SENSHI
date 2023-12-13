local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Packages = ReplicatedStorage:FindFirstChild("Packages")
local React = require(Packages.React)

local useWorld = require(script.Parent.useWorld)

return function(givenEntityId: string | number, componentType)
	assert(componentType, "needs valid component")
	local entityId = tonumber(givenEntityId)
	local world = useWorld()

	local value: any, setValue = React.useState(function()
		return world:contains(entityId) and world:get(entityId, componentType) or nil
	end)

	local oldValue = React.useRef(value)

	React.useEffect(function()
		local connection = RunService.Heartbeat:Connect(function()
			local newValue = nil
			if world:contains(entityId) then
				newValue = world:get(entityId, componentType)
			end

			if newValue ~= oldValue then
				oldValue.value = newValue
				setValue(newValue)
			end
		end)

		return function()
			if connection.Connected then
				connection:Disconnect()
			end
		end
	end, { world, entityId })

	return value
end
