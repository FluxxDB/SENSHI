local ReplicatedStorage = game:GetService("ReplicatedStorage")
local matterTypes = require(ReplicatedStorage.types.matter)
local Matter = require(ReplicatedStorage.Packages.Matter)

type Component<T> = matterTypes.Component<T>

local component = Matter.component
local components = {}

export type OriginRef = {
	camera: Camera,
}

export type GridCell = {
	position: Vector3,
}

components.OriginRef = component("OriginRef") :: Component<OriginRef>
components.GridCell = component("GridCell", {
	position = Vector3.zero,
}) :: Component<GridCell>

return components
