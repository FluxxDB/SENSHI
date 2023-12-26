local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local packages = ReplicatedStorage.Packages
local serverPackages = ServerScriptService.ServerPackages

local Matter = require(packages.Matter)
local Signal = require(packages.Signal)
local Lapis = require(serverPackages.Lapis)

local t = require(packages.t)
local playerLoaded = Signal.new()

local documents = {} :: { [string]: Lapis.Document<any> }
local collection = Lapis.createCollection("PlayerData", {
	defaultData = {
		components = {},
	},
	validate = t.interface({
		components = t.optional(t.table),
	}),
})

local function playerAdded(player: Player)
	local ok, document = collection:load(`P{player.UserId}`):await()

	if player.Parent == nil then
		if ok then
			document:close()
		end

		return
	end

	if ok then
		documents[`{player.UserId}`] = document
		playerLoaded:Fire(player, document)
	else
		player:Kick(`{player.Name}'s data failed to load`)
	end
end

local function setupDatastore(_: Matter.World)
	Players.PlayerAdded:Connect(playerAdded)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(playerAdded, player)
	end
end

return {
	setup = setupDatastore,
	documents = documents,
	playerLoaded = playerLoaded,
}
