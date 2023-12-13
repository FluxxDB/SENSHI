local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Squash = require(ReplicatedStorage.Packages.Squash)

local components = require(script.Parent.components)
local ser, des = {}, {}

ser[components.GridCell] = function(gridCell: components.GridCell)
	return squash.Vector3.ser(gridCell.position)
end

des[components.GridCell] = function(value: string)
	return components.GridCell({ position = squash.Vector3.des(value) })
end

return {
	ser = ser,
	des = des,
}
