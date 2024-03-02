--!nocheck
-- Services
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Constants
local GLOBAL_ATTRIBUTE = "ENABLE_GIZMOS"
local DEFAULTS = {
  THICKNESS = 0.05,
  COLOR = Color3.fromRGB(255, 255, 0)
}

-- Variables
local terrain = workspace:WaitForChild("Terrain")
local wireframeHandle: WireframeHandleAdornment = terrain:FindFirstChild("WireframeAdornment")

if wireframeHandle == nil then
	wireframeHandle = Instance.new("WireframeHandleAdornment")
	wireframeHandle.Adornee = terrain
	wireframeHandle.ZIndex = 1
	wireframeHandle.AlwaysOnTop = true
	wireframeHandle.Name = "WireframeAdornment"
	wireframeHandle.Parent = terrain
end

-- Functions
local function cleanUp()
  task.defer(function()
    wireframeHandle:Clear()
  end)
end

local function line(transform: CFrame, length: number)
  local from = transform.Position + (transform.LookVector * (-length / 2))
  local to = transform.Position + (transform.LookVector * (length / 2))
  wireframeHandle:AddLine(from, to)
end

local function cone(transform: CFrame, radius: number, length: number, subdivisions: number)
  transform *= CFrame.Angles(-math.rad(90), 0, 0)

	local top = transform.Position + transform.UpVector * (length / 2)
	local bottom = transform.Position + -transform.UpVector * (length / 2)

	top = CFrame.lookAt(top, top + transform.UpVector)
	bottom = CFrame.lookAt(bottom, bottom - transform.UpVector)

	local from, to
	local anglePerChunk = math.floor(360 / subdivisions)

	for i = 0, 360, anglePerChunk do
		local magnitudeX = math.sin(math.rad(i)) * radius
		local magnitudeY = math.cos(math.rad(i)) * radius

		local vertexOffset = (transform.LookVector * magnitudeY) + (transform.RightVector * magnitudeX)
		local vertexPosition = bottom.Position + vertexOffset

		if not from then
			from = vertexPosition
			to = vertexPosition

			wireframeHandle:AddLine(vertexPosition, top.Position)
			continue
		end

		wireframeHandle:AddLine(vertexPosition, top.Position)
		wireframeHandle:AddLine(from, vertexPosition)

		from = vertexPosition
	end

	wireframeHandle:AddLine(from, to)
end

local function circle()
end

-- Module
local module = {}

return module
