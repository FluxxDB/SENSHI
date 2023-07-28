--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

local defaults = require(script.defaults)

local component = Matter.component :: <T>(name: string, defaultValue: T?) -> (value: T) -> ()
local components = {}

components.Health = component("Health", defaults.Health)
components.Effect = component("Effect", defaults.Effect)
components.Transform = component("Transform", defaults.Transform)
components.Movement = component("Movement", defaults.Movement)
components.GamePlacement = component("GamePlacement", defaults.GamePlacement)
components.Player = component("Player", defaults.Player)
components.Damage = component("Damage", defaults.Damage)
components.Model = component("Model", defaults.Model)
components.Resource = component("Resource", defaults.Resource)
components.ChunkRef = component("ChunkRef", defaults.ChunkRef)
components.ChunkLOD = component("ChunkLOD", defaults.ChunkLOD)

return components
