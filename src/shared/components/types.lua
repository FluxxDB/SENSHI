--!strict

export type Player = {
	instance: Player,
}

export type Health = {
	hitPoints: number,
	maxHitPoints: number,
	block: number,
	evade: number,
	armor: { [string]: number },
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
	maxSpeed: number,
	maxAngularSpeed: number,
	velocity: Vector2,
	angularVelocity: number,
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
	position: Vector2,
	orientation: number,
}

export type ChunkRef = {
	voxelKey: Vector3,
}

export type ChunkLOD = {
	level: number,
}

return {}
