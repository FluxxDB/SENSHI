local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local useEvent = Matter.useEvent

local Components = require(Shared.components)
local PlayerRef = Components.PlayerRef
local Incantation = Components.Incantation

local remotes = require(Shared.remotes)
local spellCastRemotes = remotes.Server:GetNamespace("SpellCast")
local spellCastBeginEvent = spellCastRemotes:Get("Begin") :: { SendToServer: (...any) -> () }
local spellCastEndEvent = spellCastRemotes:Get("End") :: { SendToServer: (...any) -> () }
local spellCastCancelEvent = spellCastRemotes:Get("Cancel") :: { SendToServer: (...any) -> () }
local spellCastSelectRuneEvent = spellCastRemotes:Get("SelectRune") :: { SendToServer: (...any) -> () }

function processSpellRunes(world: Matter.World)
	-- Spell Cast State: Begin
	for id, player in useEvent(spellCastBeginEvent, spellCastBeginEvent.Connect) do
		for _, playerRef in world:query(PlayerRef) do
			if playerRef.instance ~= player then
				continue
			end

			world:insert(id, Incantation({}))
		end
	end

	-- Spell Cast State: End
	for id, player in useEvent(spellCastEndEvent, spellCastEndEvent.Connect) do
		for _, playerRef, incantation in world:query(PlayerRef, Incantation) do
			if playerRef.instance ~= player then
				continue
			end

			-- TODO: Start casting spell
			print(incantation.runeSequence)
			world:remove(id, Incantation)
		end
	end

	-- Spell Cast State: Cancel
	for id, player in useEvent(spellCastCancelEvent, spellCastCancelEvent.Connect) do
		for _, playerRef, incantation in world:query(PlayerRef, Incantation) do
			if playerRef.instance ~= player then
				continue
			end

			world:remove(id, Incantation)
		end
	end

	-- Spell Cast State: Rune Select
	for id, player, rune in useEvent(spellCastSelectRuneEvent, spellCastSelectRuneEvent.Connect) do
		for _, playerRef, incantation in world:query(PlayerRef, Incantation) do
			if playerRef.instance ~= player then
				continue
			end

			-- TODO: Check if mana pool is sufficiently full and subtract from it

			world:insert(
				id,
				incantation:patch({
					runeSequence = table.insert(incantation.runeSequence, rune),
				})
			)
		end
	end
end

return {
	system = processSpellRunes,
}
