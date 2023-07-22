local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpawnParamsTypes = require(ReplicatedStorage.types["SpawnParams"])
local CharacterService = {}

local assets = ReplicatedStorage:WaitForChild("Assets")
local entityBases = assets:WaitForChild("EntityBases")
local charactersFolder = workspace:WaitForChild("Entities"):WaitForChild("Characters")

local Remotes = require(ReplicatedStorage.Shared["remotes"])
local Remote = Remotes.Server:GetNamespace("Character"):Get("Spawn")

--[=[
    Simply spawns the character; See PlayerService for more in-depth player setup
    @params { player, profile, spawnParams } - Player the character belongs to; Data of the player; Spawn Parameters
    @return { character }                    - Returns the character created
--]=]
function CharacterService:spawnCharacter(player, profile, spawnParams: SpawnParamsTypes.TSpawnParams)
	local character = entityBases:FindFirstChild(spawnParams.rigType):Clone()
	character.Name = player.DisplayName
	character.Parent = charactersFolder
	player.Character = character

	return character
end

function CharacterService:onInit()
	print("Character")
end

function CharacterService:onStart() end

return CharacterService
