local matterTypes = require("@types/matter")

type Component<T> = matterTypes.Component<T>

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

export type OriginRef = {
	target: BasePart | Camera,
}

export type GridCell = {
	value: Vector3,
}

export type Keepr = {
  components: { [any]: Component<any> },
	document: string,	
	entity: string,
}

export type KeeprStatus = {
  autosave: number,
  saved: boolean,
  loaded: boolean,
  unload: boolean,
  unloaded: boolean,
}

export type Components = {
  [any]: any,
  
	Player: Component<Player>,

	Health: Component<Health>,

	Transform: Component<Transform>,

	Position: Component<Position>,

	Orientation: Component<Orientation>,

	Acceleration: Component<Acceleration>,

	Velocity: Component<Velocity>,

	Model: Component<Model>,

	Dynamoid: Component<Dynamoid>,

	BumperSphere: Component<BumperSphere>,

	LifterSphere: Component<LifterSphere>,

	OriginRef: Component<OriginRef>,

	GridCell: Component<GridCell>,

	Keepr: Component<Keepr>,

	KeeprStatus: Component<KeeprStatus>,
}

return {} :: Components
