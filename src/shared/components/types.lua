--!strict

export type LocalPlayer = {
	instance: Player,
}

export type PlayerRef = {
	instance: Player,
}

export type Health = {
	hitPoints: number?,
	maxHitPoints: number?,
	block: number?,
	evade: number?,
	armor: { [string]: number }?,
}

export type Damage = {
	damage: number,
	type: "Blade" | "Blunt" | "Soul" | "Ranged",
}

export type Transform = {
	cframe: CFrame,
}

export type Model = {
	modelId: number?,
	instance: Model?,
}

export type Movement = {
	maxSpeed: number?,
	maxAngularSpeed: number?,
	velocity: Vector3?,
	angularVelocity: number?,
}

export type Effect = {
	buffs: { [string]: number },
	debuffs: { [string]: number },
}

export type Resource = {
	capacity: number,
	resourceId: number,
}

export type GamePlacement = {
	position: Vector3,
	orientation: number,
}

export type Chunk = {
	priority: number,
}

export type ChunkRef = {
	voxelKey: Vector3,
}

export type HipHeight = {
	height: number,
}

export type TravelHeight = {
	height: number,
}

export type Spring = {
	spring: any,
}

export type Incantation = {
	runeSequence: number,
}

return {}
