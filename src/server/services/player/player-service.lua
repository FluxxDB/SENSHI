local Services = script.Parent.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CharacterService = require(Services["character-service"])
local SpawnParamsTypes = require(ReplicatedStorage.types["spawn-params"])
local Structs = require(ReplicatedStorage.Shared.structs)
local PlayerService = {}

local entity = Structs.entity
local transform = Structs.transform
local spawnLocation = Workspace:WaitForChild("Map"):WaitForChild("Spawn Locations"):GetChildren()
local defaultSpawnParams: SpawnParamsTypes.TSpawnParams = {
    rigType = "Default",
    position = spawnLocation[1].Position + Vector3.new(0, 5, 0)
}
local entityIds = {} -- ( playerObject: EntityID )
local profiles = {} -- ( EntityID: Profile )

local function initPlayer(player)
    -- TODO: Create folders and load profiles
    local playerEntityId, playerEntity = entity.CreateStruct()
    entityIds[player] = playerEntityId

    -- local character = CharacterService:spawnCharacter(player, nil, defaultSpawnParams) -- Fix nil and "Default" to corresponding data values
    -- local humanoid = character:WaitForChild("Humanoid")
    -- humanoid.Died:Connect(function()
    --     task.delay(5, function()
    --         initPlayer(player) -- Temporary respawn solution
    --     end) 
    -- end)
end

local function clearPlayer(player)
    local profile = table.find(profiles, player)
    if not profile then return end

    table.remove(profiles, profile)
end

function PlayerService:onInit()
    print("Ayo")
end

function PlayerService:onStart()
    Players.PlayerAdded:Connect(initPlayer)
    Players.PlayerRemoving:Connect(clearPlayer)
end

return PlayerService