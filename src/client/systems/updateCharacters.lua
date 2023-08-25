local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local useEvent = Matter.useEvent
local useThrottle = Matter.useThrottle

local Components = require(Shared.components)
local PlayerRef = Components.PlayerRef
local Model = Components.Model
local GamePlacement = Components.GamePlacement
local Spring = Components.Spring

local playerUpdatesWorldShift = require(script.Parent.playerUpdatesWorldShift)

local remotes = require(Shared.remotes)
local characterRemotes = remotes.Client:GetNamespace("Character")
local moveEvent = characterRemotes:Get("Move") :: { SendToServer: (...any) -> () } -- TODO: Add Rate Limit

local CHARACTER_REPORT_HERTZ = 20

-- Consider moving this function to '../shared/utils'
local function cframeToQuaternion(cframe: CFrame)
	local _, _, _, m00, m01, m02, _, _, m12, _, _, m22 = cframe:GetComponents()

	return math.atan2(-m12, m22), math.asin(m02), math.atan2(-m01, m00)
end

function updateCharacters(world: Matter.World)
	if useThrottle(1 / CHARACTER_REPORT_HERTZ) then
		for _, player, model, gamePlacement, spring in world:query(PlayerRef, Model, GamePlacement, Spring) do
			local character = model.instance
			if not character then
				continue
			end

			local rootPart = character.HumanoidRootPart
			if not rootPart then
				continue
			end

			local origin = Workspace:GetAttribute("Origin")
			if origin == nil then
				continue
			end

			if player.instance == Players.LocalPlayer then
				local _, yOrientation, _ = cframeToQuaternion(rootPart.CFrame)
				moveEvent:SendToServer(rootPart.Position + origin, yOrientation)
			else
				-- local xPosition, zPosition = gamePlacement.position.X - origin.X, gamePlacement.position.Z - origin.Z
				-- local springRepresentation = spring.spring
				-- springRepresentation.Target = CFrame.new(xPosition, rootPart.CFrame.Y, zPosition)
				-- rootPart.CFrame = springRepresentation.Position
			end
		end
	end
end

return {
	system = updateCharacters,
	after = { playerUpdatesWorldShift },
}
