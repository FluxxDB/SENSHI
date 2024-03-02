local Matter = require("@packages/Matter")
local matterTypes = require("@types/matter")

type Component<T> = matterTypes.Component<T>
local component = Matter.component :: any

local components = {}

export type Player = {
  value: Player,
}

export type Health = {
	current: number,
	max: number,
}

export type Transform = {
	value: CFrame,
}

export type Position = {
	value: Vector3,
}

export type Orientation = {
	value: Vector3,
}

export type Velocity = {
  value: Vector3,
}

export type Acceleration = {
  value: Vector3,
}

export type Model = {
	value: Model,
}

components.Player = component("Player") :: Component<Player>
components.Health = component("Health", {
	current = 100,
	max = 100,
}) :: Component<Health>

components.Transform = component("Transform") :: Component<Transform>
components.Position = component("Position", {
	value = Vector3.new(0, 0, 0),
}) :: Component<Position>

components.Orientation = component("Orientation") :: Component<Orientation>
components.Acceleration = component("Acceleration") :: Component<Acceleration>
components.Velocity = component("Velocity") :: Component<Velocity>
components.Model = component("Model") :: Component<Model>

return components
