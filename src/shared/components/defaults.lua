--!strict

local types = require(script.Parent.types)
local defaults = {}
local empty = nil :: any

defaults.Health = {
	hitPoints = 100,
	maxHitPoints = 100,
	block = 0,
	evade = 0,
	armor = {},
} :: types.Health

defaults.Effect = {
	buffs = {},
	debuffs = {},
} :: types.Effect

defaults.Transform = {
	cframe = CFrame.identity,
} :: types.Transform

defaults.Movement = {
	maxSpeed = 2.6,
	maxAngularSpeed = math.pi,
	velocity = Vector2.zero,
	angularVelocity = 0,
} :: types.Movement

defaults.GamePlacement = {
	position = Vector2.zero,
	orientation = 0,
} :: types.GamePlacement

defaults.Player = empty :: types.Player

defaults.Damage = empty :: types.Damage

defaults.Model = empty :: types.Model

defaults.Resource = empty :: types.Resource

defaults.ChunkRef = empty :: types.ChunkRef

defaults.ChunkLOD = empty :: types.ChunkLOD

return defaults
