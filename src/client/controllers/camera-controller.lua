local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CameraMountPreference = require(ReplicatedStorage.types.enums["camera-mount-preference"])
local CameraController = {}

local CAMERA_OFFSET = Vector3.new(1.5, 0, 5)
local SMOOTH_FACTOR = 0.4

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local cameraEasing = TweenInfo.new(
    1/60,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.In
)
local xRotation = 0
local yRotation = 0

local function setCameraType()
    camera.CameraType = Enum.CameraType.Scriptable
end

local function mouseUpdate(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
        xRotation -= inputObject.Delta.X * SMOOTH_FACTOR
        yRotation = math.clamp(yRotation -  inputObject.Delta.Y * SMOOTH_FACTOR, -70, 80)
    end
end

local function cameraUpdate()
    if not player.Character then return end
    
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    local cameraOffset = CFrame.new(0, 0, 0)
    local cameraSubject = CFrame.new(0, 0, 0)
    local rotationalOffset = CFrame.new((rootPart.CFrame.Position + Vector3.new(0, 2.5, 0))) * CFrame.Angles(0, math.rad(xRotation), 0) * CFrame.Angles(math.rad(yRotation), 0, 0)
    cameraOffset = rotationalOffset + rotationalOffset:VectorToWorldSpace(CAMERA_OFFSET)
    cameraSubject = rotationalOffset + rotationalOffset:VectorToWorldSpace(Vector3.new(CAMERA_OFFSET.X, CAMERA_OFFSET.Y, -50000))
    camera.CFrame = CFrame.new(cameraOffset.Position, cameraSubject.Position)
end

function CameraController:onInit()
    camera.CameraType = Enum.CameraType.Scriptable
    camera:GetPropertyChangedSignal("CameraType"):Connect(setCameraType)

    UserInputService.InputChanged:Connect(mouseUpdate)
    RunService:BindToRenderStep("CameraUpdate", Enum.RenderPriority.Camera.Value, cameraUpdate)
end

function CameraController:onStart()

    -- RunService.PreRender:Connect(function()
    --     if not player.Character then return end
        
    --     local rootPart = player.Character:FindFirstChild("rootPart")
    --     if not rootPart then return end

    --     local mountCFrame = CFrame.new(rootPart.Position)
    --     local cameraTween = TweenService:Create(camera, cameraEasing, { CFrame = mountCFrame })
    --     cameraTween:Play()
    -- end)
end

return CameraController