local ReplicatedStorage = game:GetService("ReplicatedStorage")
local createComponent = require(ReplicatedStorage.shared.createComponent)

type Component<T> = createComponent.Component<T>

local components = {}

export type OriginRef = {
	camera: Camera,
}

export type GridCell = {
	position: Vector3,
}

components.OriginRef = createComponent("OriginRef") :: Component<OriginRef>
components.GridCell = createComponent("GridCell", {
	position = Vector3.zero,
}) :: Component<GridCell>

return components
