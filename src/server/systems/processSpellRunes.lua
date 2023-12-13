local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared
local Factories = ReplicatedStorage.Factories

local SpellFactory = require(Factories.Spells :: ModuleScript)

local Matter = require(Packages.Matter)
local useEvent = Matter.useEvent

local Components = require(Shared.components)
local PlayerRef = Components.PlayerRef
local Incantation = Components.Incantation
local ManaPool = Components.ManaPool

local assets = ReplicatedStorage:WaitForChild("Assets")
local castingRunes = assets:WaitForChild("CastingRunes")

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
			if SpellFactory[incantation.runeSequence] == nil then
				continue
			end

			local castSpell = SpellFactory[incantation.runeSequence]
			castSpell(world)
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
	for id, player, runeId, runeName in useEvent(spellCastSelectRuneEvent, spellCastSelectRuneEvent.Connect) do
		for _, playerRef, incantation, manaPool in world:query(PlayerRef, Incantation, ManaPool) do
			if playerRef.instance ~= player then
				continue
			end

			local runeInfo = castingRunes:FindFirstChild(runeName, true)
			if not runeInfo then
				continue
			end

			local formattedRuneId = tostring(runeId)
			if runeId / 10 < 1 then
				formattedRuneId = "0" .. tostring(runeId)
			end

			local manaCost = runeInfo:GetAttribute("ManaCost")
			if manaPool.mana < manaCost then
				continue
			end

			world:insert(
				id,
				Incantation({
					runeSequence = incantation.runeSequence .. formattedRuneId,
				}),
				manaPool:patch({
					mana = manaPool.mana - manaCost,
				})
			)
		end
	end
end

return {
	system = processSpellRunes,
}
