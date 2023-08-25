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
	velocity = Vector3.zero,
	angularVelocity = 0,
} :: types.Movement

defaults.GamePlacement = {
	position = Vector3.zero,
	orientation = 0,
} :: types.GamePlacement

defaults.LocalPlayer = empty :: types.LocalPlayer

defaults.PlayerRef = empty :: types.PlayerRef

defaults.Damage = empty :: types.Damage

defaults.Model = {} :: types.Model

defaults.Resource = empty :: types.Resource

defaults.ChunkRef = empty :: types.ChunkRef

defaults.Chunk = empty :: types.Chunk

defaults.HipHeight = empty :: types.HipHeight

defaults.TravelHeight = empty :: types.TravelHeight

defaults.Spring = empty :: types.Spring

return defaults
