local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Packages = ReplicatedStorage.Packages
local Client = ReplicatedStorage.Client

local Matter = require(Packages.Matter)
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)

local MatterWorldContext = require(Client.modules.ui.MatterWorldContext)
local App = require(Client.apps.App)
local e = React.createElement

function reactInitialize(world: Matter.World, state)
	local context = MatterWorldContext(world)
	print(context)
	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	root:render(ReactRoblox.createPortal(e(App), Players.LocalPlayer.PlayerGui))
end

return reactInitialize
