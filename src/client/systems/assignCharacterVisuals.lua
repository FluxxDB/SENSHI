local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.Matter)
local useEvent = Matter.useEvent

local Components = require(Shared.components)

local characterEntity = require(script.Parent.spawnCharacterBases)
local characterAdded = characterEntity.events.characterAdded

local characterVisuals = Assets.CharacterVisuals

-- maybe add this to utils although its kinda pointless lol
local function reParentChildren(parent: Instance)
	local rootParent = parent.Parent

	for _, child in ipairs(parent:GetChildren()) do
		child.Parent = rootParent
	end

	parent:Destroy()
end

function assignCharacterVisuals(world: Matter.World)
	for _, player, character in useEvent(characterAdded, characterAdded.Connect) do
		local characterVisual = characterVisuals["Default"]:Clone()
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then
			continue
		end

		-- Create a function for this you stinky loser
		local rootJoint = Instance.new("Motor6D")
		rootJoint.Name = "RootJoint"
		rootJoint.Part0 = rootPart
		rootJoint.Part1 = characterVisual.PrimaryPart
		rootJoint.MaxVelocity = 0.1
		rootJoint.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(-180), 0)
		rootJoint.C1 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(-180), 0)
		rootJoint.Parent = rootPart
		characterVisual.Parent = character
		reParentChildren(characterVisual)
	end
end

return {
	system = assignCharacterVisuals,
}
