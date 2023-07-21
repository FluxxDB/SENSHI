local Controllers = script.Parent
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CharacterController = require(Controllers["character-controller"])
local CameraController = {}

local X_SENSITIVITY, Y_SENSITIVITY = 1, 1
local MOUNT_OFFSET = Vector3.new(0, 2.5, 0)
local MIN_CAMERA_DISTANCE = 4
local MAX_CAMERA_DISTANCE = 17
local CAMERA_RADIUS = 1.3
local SPHERECAST_PARAMS = RaycastParams.new()

local camera = workspace.CurrentCamera
local mousePosition =  Vector2.new(0, 0)
local cameraDistanceGoal = 7
local cameraDistance = 7
local characterRotator

local function initCharacter(character)
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local centerAttachment = Instance.new("Attachment")
    centerAttachment.Name = "CenterAttachment"
    centerAttachment.Parent = rootPart

    local alignorientation = Instance.new("AlignOrientation")
    alignorientation.Attachment0 = centerAttachment
    alignorientation.Attachment1 = characterRotator
    alignorientation.Responsiveness = 100
    alignorientation.Parent = rootPart

    SPHERECAST_PARAMS:AddToFilter(character)
end

local function setCameraType()
    camera.CameraType = Enum.CameraType.Scriptable
end

local function cameraUpdate(delta)
    local character = CharacterController:getCurrentCharacter()
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local mouseDelta = UserInputService:GetMouseDelta()
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    mousePosition -= Vector2.new(mouseDelta.X * X_SENSITIVITY, mouseDelta.Y * Y_SENSITIVITY)
    mousePosition = Vector2.new(
        (mousePosition.X < -180) and 180 or (mousePosition.X > 180) and -180 or mousePosition.X, 
        math.clamp(mousePosition.Y, -90, 90)
    )

    local xControl = Vector2.new(math.sin(math.rad(mousePosition.X)), math.cos(math.rad(mousePosition.X))) * cameraDistance
    local yControl = math.sin(math.rad(-mousePosition.Y)) * math.sqrt((xControl.X ^ 2) + (xControl.Y ^ 2))
    local _, yOrientation, _ = camera.CFrame:ToOrientation()
    
    local cameraSubject = rootPart.Position + MOUNT_OFFSET
    local cameraMount = rootPart.Position + Vector3.new(xControl.X, yControl, xControl.Y) + MOUNT_OFFSET

    local cameraObstructor = workspace:Spherecast(cameraSubject, CAMERA_RADIUS, CFrame.new(cameraSubject, cameraMount).LookVector * cameraDistance, SPHERECAST_PARAMS)

    if cameraObstructor then
        cameraDistanceGoal = math.clamp((cameraObstructor.Distance < cameraDistance) and cameraObstructor.Distance or cameraDistance, 0.1, MAX_CAMERA_DISTANCE)
    end
    
    cameraDistance = cameraDistance + (cameraDistanceGoal - cameraDistance) * 0.4
    characterRotator.WorldOrientation = Vector3.new(0, math.deg(yOrientation), 0)
    camera.CFrame = CFrame.lookAt(cameraMount, cameraSubject) 
    -- local signRestore = (mousePosition.X < -90) and -1 or (mousePosition.X > 90) and -1 or 1
    -- camera.CFrame = CFrame.lookAt((rootPart.CFrame * CFrame.new(xControl.X, yControl.X, signRestore * math.sqrt(yControl.Y ^ 2 + xControl.Y ^ 2)) * mountCFrame).Position, (rootPart.CFrame * mountCFrame).Position)
    
    -- TODO: Add settings to profile (X and Y Sensitivity)

    -- TODO: Fix character not having a rotator at random times
    
    -- TODO: Raycast for camera collisions 
    --  (Raycast length of max distance after updating CFrame 
    --  & if hit then change zoom to distance between hit and
    --  camera then round down to keep whole number)
end

local function cameraScroll(inputObject, gameProcessed)
    if inputObject.UserInputType ~= Enum.UserInputType.MouseWheel then return end
    if gameProcessed then return end

    cameraDistanceGoal = math.clamp((inputObject.Position.Z == 1) and cameraDistance - 2 or cameraDistance + 2, MIN_CAMERA_DISTANCE, MAX_CAMERA_DISTANCE)
end

function CameraController:onInit()
    --[[
        camera.CameraType = Enum.CameraType.Scriptable
    camera:GetPropertyChangedSignal("CameraType"):Connect(setCameraType)

    SPHERECAST_PARAMS.FilterType = Enum.RaycastFilterType.Exclude
    SPHERECAST_PARAMS.IgnoreWater = true

    RunService:BindToRenderStep("CameraUpdate", Enum.RenderPriority.Camera.Value, cameraUpdate)
    UserInputService.InputChanged:Connect(cameraScroll)

    characterRotator = Instance.new("Attachment")
    characterRotator.Name = "CharacterRotator"
    characterRotator.Parent = game:GetService("Workspace"):WaitForChild("Terrain")
    --]]
end

function CameraController:onStart()
    CharacterController.onCharacterAdded:Connect(initCharacter)
end

return CameraController