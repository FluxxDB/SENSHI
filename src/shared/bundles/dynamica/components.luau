local Matter = require("@packages/Matter")
local matterTypes = require("@types/matter")

type Component<T> = matterTypes.Component<T>
local component = Matter.component :: any

local components = {}

export type Dynamoid = {
  gravity: Vector3,
  humanoid: Humanoid,
}

export type BumperSphere = {
  size: Vector3,
  offset: Vector3,
}

export type LifterSphere = {
  size: Vector3,
  offset: Vector3,
}

components.Dynamoid = component("Dynamoid") :: Component<Dynamoid>
components.BumperSphere = component("BumperSphere") :: Component<BumperSphere>
components.LifterSphere = component("LifterSphere") :: Component<LifterSphere>

return components
