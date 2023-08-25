--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

local defaults = require(script.defaults)

local component = Matter.component :: <T>(name: string, defaultValue: T?) -> (value: T) -> ()
local components = {}

-- Server Components
components.Health = component("Health", defaults.Health)
components.Effect = component("Effect", defaults.Effect)
components.Transform = component("Transform", defaults.Transform)
components.Movement = component("Movement", defaults.Movement)
components.GamePlacement = component("GamePlacement", defaults.GamePlacement)
components.PlayerRef = component("PlayerRef", defaults.PlayerRef)
components.Damage = component("Damage", defaults.Damage)
components.Model = component("Model", defaults.Model)
components.Resource = component("Resource", defaults.Resource)
components.Chunk = component("Chunk", defaults.Chunk)
components.ChunkRef = component("ChunkRef", defaults.ChunkRef)
components.HipHeight = component("HipHeight", defaults.HipHeight)
components.TravelHeight = component("TravelHeight", defaults.TravelHeight)

-- Client Components
components.Spring = component("Spring", defaults.Spring)
-- components.LocalPlayer = component("LocalPlayer", defaults.LocalPlayer)

return components
