local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CharacterService = require(script.Parent["character-service"])
local SpawnParamsTypes = require(ReplicatedStorage.types["spawn-params"])
local PlayerService = {}

local defaultSpawnParams: SpawnParamsTypes.TSpawnParams = {
    rigType = "Default",
    position = Vector3.new(0, 10, 0)
}
local profiles = {} -- Temporarily empty; Setup for ProfileService integration

local function initPlayer(player)
    -- TODO: Create folders and load profiles
    CharacterService:spawnCharacter(player, nil, defaultSpawnParams) -- Fix nil and "Default" to corresponding data values
    print(`Spawning { player.DisplayName } at { defaultSpawnParams.position }`)
end

local function clearPlayer(player)
    local profile = table.find(profiles, player)
    if not profile then return end

    table.remove(profiles, profile)
end

function PlayerService:onInit()
end

function PlayerService:onStart()
    Players.PlayerAdded:Connect(initPlayer)
    Players.PlayerRemoving:Connect(clearPlayer)
end

return PlayerService