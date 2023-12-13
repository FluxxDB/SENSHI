--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Packages = ReplicatedStorage:FindFirstChild("Packages")
local React = require(Packages.React)

local useWorld = require(script.Parent.useWorld)

local function hasDetectedAChange(snapshotA, snapshotB)
	if #snapshotA ~= #snapshotB then
		return true
	end

	-- we use ipairs since snapshots have a custom __iter metamethod
	for entityIndex, entityInfo in ipairs(snapshotA) do
		if entityInfo[1] ~= snapshotB[entityIndex][1] then
			return true
		end

		for componentIndex, component in ipairs(entityInfo) do
			if component ~= snapshotB[entityIndex][componentIndex] then
				return true
			end
		end
	end

	return false
end

return function(...)
	local world = useWorld()
	local givenComponents = { ... }

	local value: any, setValue = React.useState(function()
		return world:query(table.unpack(givenComponents)):snapshot()
	end)

	local previousSnapshot = React.useRef(value)
	React.useEffect(function()
		local connection = RunService.Heartbeat:Connect(function()
			local snapshot = world:query(table.unpack(givenComponents)):snapshot()
			if previousSnapshot.current == nil or hasDetectedAChange(snapshot, previousSnapshot.current) then
				previousSnapshot.current = snapshot
				setValue(snapshot)
			end
		end)

		return function()
			if connection.Connected then
				connection:Disconnect()
			end
		end
	end, { world, givenComponents })

	return value
end
