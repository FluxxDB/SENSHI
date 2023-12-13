local ReplicatedStorage = game:GetService("ReplicatedStorage")
local createComponent = require(ReplicatedStorage.shared.createComponent)

type Component<T> = createComponent.Component<T>

local components = {}

export type Health = {
	current: number,
	max: number,
}

export type Position = {
	value: Vector3,
}

export type Model = {
	value: Model,
}

export type Orientation = {
	pitch: number,
	yaw: number,
	roll: number,
}

export type Incantation = {
	runeSequence: string,
}

export type ManaPool = {
	mana: number,
	capacity: number,
}

components.Health = createComponent("Health", {
	current = 100,
	max = 100,
}) :: Component<Health>

components.Model = createComponent("Model") :: Component<Model>

components.Position = createComponent("Position", {
	value = Vector3.new(0, 0, 0),
}) :: Component<Position>

components.Incantation = createComponent("Incantation", {
	runeSequence = "",
}) :: Component<Incantation>

components.ManaPool = createComponent("ManaPool", {
	mana = 0,
	capacity = 0,
}) :: Component<ManaPool>

return components
