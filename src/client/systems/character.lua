local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.Shared.components)

local localPlayer = Players.LocalPlayer
local entityBases = ReplicatedStorage.Assets.EntityBases
local characters = Workspace.Entities.Characters
local useEvent = Matter.useEvent

local function assignCharacter(player: Player, characterRigName: string)
	if player.Character then
		player.Character:Destroy()
	end

	local character = entityBases[characterRigName]:Clone()
	character.Parent = characters
	player.Character = character

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	humanoid.Died:Connect(function()
		task.delay(5, assignCharacter, player, characterRigName)
	end)

	return character
end

local function CharacterSystem()
	if not localPlayer.Character then
		assignCharacter(localPlayer, "Default")
	end

	for _, player: Player in useEvent(Players, "PlayerAdded") do
		assignCharacter(player, "Default")
	end
end

return CharacterSystem
