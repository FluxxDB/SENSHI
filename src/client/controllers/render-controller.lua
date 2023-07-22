local Controllers = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CharacterController = require(Controllers["character-controller"])
local Gizmos = require(ReplicatedStorage.Vendor.ImGizmo)
local RenderController = {}

local utils = ReplicatedStorage.Shared.utils
local chunkUtils = require(utils["chunk-utils"])

local origin = Vector2int16.new(0, 0)
local currentOrigin = Vector2int16.new(0, 0)

local function getMagnitude(vectorA, vectorB): number
	local deltaX = vectorB.X - vectorA.X
	local deltaY = vectorB.Y - vectorA.Y
	return math.sqrt(deltaX ^ 2 + deltaY ^ 2)
end

local function preRenderCheck()
	local character = CharacterController:getCurrentCharacter()
	if not character then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	Gizmos.Arrow:Draw(Vector3.new(0, 0, 0), rootPart.Position, 0.5, 2.5, 10)

	local position = rootPart.Position * Vector3.new(1, 0, 1)
	origin = chunkUtils.getChunkPosition(position)

	--print(origin)
	--print(currentOrigin)
	--print(getMagnitude(origin, currentOrigin))

	if getMagnitude(origin, currentOrigin) > 1 then
		--print("Workspace Pivot:", Workspace:GetPivot())
		--print("RootPart Position:", rootPart.Position)

		-- Workspace:PivotTo(CFrame.new(-origin.X * 2048, 0, -origin.Y * 2048))
		-- ermm... idk...

		--print("Workspace Pivot:", Workspace:GetPivot())
		--print("RootPart Position:", rootPart.Position)

		local partList = {}
		local cframeList = {}
		-- local position = rootPart.Position * Vector3.new(1, 0, 1)

		for _, part in ipairs(Workspace:FindFirstChild("Map"):GetDescendants()) do
			if not part:IsA("Part") and not part:IsA("MeshPart") then
				continue
			end
			table.insert(partList, part)
			table.insert(cframeList, part.CFrame - position + Vector3.new(0, 0, 0))
		end

		for _, entitiesFolder in ipairs(Workspace:FindFirstChild("Entities"):GetChildren()) do
			for _, entity in ipairs(entitiesFolder:GetChildren()) do
				if not entity:IsA("Model") or not entity:FindFirstChildOfClass("Humanoid") then
					continue
				end
				local entityRoot = entity:FindFirstChild("HumanoidRootPart")

				table.insert(partList, entityRoot)
				table.insert(cframeList, entityRoot.CFrame - position)
			end
		end

		Workspace:BulkMoveTo(partList, cframeList)
	end
end

function RenderController:onInit() end

function RenderController:onStart()
	RunService.RenderStepped:Connect(preRenderCheck)
end

return RenderController
