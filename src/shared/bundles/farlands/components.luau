local Matter = require("@packages/Matter")
local matterTypes = require("@types/matter")

type Component<T> = matterTypes.Component<T>
local component = Matter.component :: any

local components = {}

export type OriginRef = {
	target: BasePart | Camera,
}

export type GridCell = {
	value: Vector3,
}

components.OriginRef = component("OriginRef") :: Component<OriginRef>
components.GridCell = component("GridCell", {
	value = Vector3.zero,
}) :: Component<GridCell>

return components
