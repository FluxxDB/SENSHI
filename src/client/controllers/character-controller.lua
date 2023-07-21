local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Shared["remotes"])

local player = Players.LocalPlayer
local SpawnRemote = Remotes.Client:GetNamespace("Character"):Get("Spawn")

local CharacterController = {}
CharacterController._loadOrder = 9e99
CharacterController.onCharacterAdded = Signal.new()
CharacterController.Position = Vector3.new(0, 0, 0)

function CharacterController:spawnIn()
	local assets = ReplicatedStorage:WaitForChild("Assets")
	local entityBases = assets:WaitForChild("EntityBases")
	local charactersFolder = workspace:WaitForChild("Entities"):WaitForChild("Characters")

	local character = entityBases:FindFirstChild("Default"):Clone()
	character.Name = player.DisplayName
	character.Parent = charactersFolder
	player.Character = character

	local positionUpdate
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	humanoid.Died:Connect(function()
		positionUpdate:Disconnect()
		CharacterController:spawnIn()
	end)

	positionUpdate = RunService.PreSimulation:Connect(function()
		CharacterController.Position = character.PrimaryPart.Position
	end)
end

function CharacterController:onInit()
	player.CharacterAdded:Connect(function(character)
		self:onCharacterAddedCallback(character)
	end)

	player.CharacterRemoving:Connect(function()
		self.currentCharacter = nil
		task.delay(5, SpawnRemote.SendToServer, SpawnRemote)
	end)

	CharacterController:spawnIn()
end

function CharacterController:onStart()
	-- TODO: REMOVE THIS LATER
	if player.Character then
		self:onCharacterAddedCallback(player.Character)
	end

	task.delay(5, SpawnRemote.SendToServer, SpawnRemote)
end

function CharacterController:getCurrentCharacter()
	return self.currentCharacter
end

function CharacterController:onCharacterAddedCallback(character)
	self.currentCharacter = character
	self.onCharacterAdded:Fire(character)
end

return CharacterController
