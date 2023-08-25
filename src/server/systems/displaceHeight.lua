--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

local Components = require(ReplicatedStorage.Shared.components)

local HipHeight = Components.HipHeight
local TravelHeight = Components.TravelHeight
local GamePlacement = Components.GamePlacement

function displaceHeight(world: Matter.World)
	for id, record in world:queryChanged(HipHeight) do
		local placement = world:get(id, GamePlacement)
		if not placement then
			continue
		end

		local height = 0
		if record.new then
			height = height + record.new.height
		end

		if not world:contains(id) then
			continue
		end

		local travelHeight = world:get(id, TravelHeight)
		if travelHeight then
			height = height + travelHeight.height
		end

		world:insert(
			id,
			placement:patch({
				offsetHeight = height,
			})
		)
	end

	for id, record in world:queryChanged(TravelHeight) do
		local placement = world:get(id, GamePlacement)
		if not placement then
			continue
		end

		local height = 0
		if record.new then
			height = height + record.new.height
		end

		if not world:contains(id) then
			continue
		end

		local hipHeight = world:get(id, HipHeight)
		if hipHeight then
			height = height + hipHeight.height
		end

		world:insert(
			id,
			placement:patch({
				offsetHeight = height,
			})
		)
	end
end

return {
	system = displaceHeight,
}
