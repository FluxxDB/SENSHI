--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

local Components = require(ReplicatedStorage.Shared.components)

local Health = Components.Health
local Damage = Components.Damage

function damageHurts(world: Matter.World)
	for id, health, damage in world:query(Health, Damage) do
		health:patch({
			hitPoints = health.hitPoints - damage.damage,
		})
	end
end

return damageHurts
