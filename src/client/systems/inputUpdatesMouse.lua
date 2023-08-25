local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local useEvent = Matter.useEvent

local Components = require(Shared.components)

local lastMousePosition = Vector2.new(0, 0)

function inputUpdatesMouse(world: Matter.World)
	-- for _, inputObject, gameProcessed in useEvent(UserInputService, "InputChanged") do
	-- 	if gameProcessed then
	-- 		continue
	-- 	end

	-- 	if inputObject.UserInputType ~= Enum.UserInputType.MouseMovement then
	-- 		continue
	-- 	end

	-- 	local mousePosition = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
	-- 	local deltaPosition = lastMousePosition - mousePosition
	-- 	if math.abs(deltaPosition.X) > math.abs(deltaPosition.Y) then
	-- 		if deltaPosition.X < 0 then
	-- 			print("Right")
	-- 		else
	-- 			print("Left")
	-- 		end
	-- 	elseif math.abs(deltaPosition.X) < math.abs(deltaPosition.Y) then
	-- 		if deltaPosition.Y < 0 then
	-- 			print("Down")
	-- 		else
	-- 			print("Up")
	-- 		end
	-- 	end

	-- 	lastMousePosition = mousePosition
	-- end
end

return {
	system = inputUpdatesMouse,
}
