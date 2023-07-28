--!strict

local Signal = require(game:GetService("ReplicatedStorage").Packages.Signal)

local VectorMap2D = {}
VectorMap2D.__index = VectorMap2D

function VectorMap2D.new(voxelSize: number?)
	return setmetatable({
		voxelAdded = Signal.new() :: Signal.Signal<Vector3, { any }>,
		voxelRemoving = Signal.new() :: Signal.Signal<Vector3, { any }>,
		_voxelSize = voxelSize or 50,
		_voxels = {},
	}, VectorMap2D)
end

function VectorMap2D:_debugDrawVoxel(voxelKey: Vector3)
	local box = Instance.new("Part")
	box.Name = tostring(voxelKey)
	box.Anchored = true
	box.CanCollide = false
	box.Transparency = 1
	box.Size = Vector3.new(self._voxelSize, 2048, self._voxelSize)
	box.Position = Vector3.new(voxelKey.X, 0, voxelKey.Z) * self._voxelSize
		+ Vector3.new(self._voxelSize / 2, 1024, self._voxelSize / 2)
	box.Parent = workspace:FindFirstChildOfClass("Terrain")

	local selection = Instance.new("SelectionBox")
	selection.Color3 = Color3.new(0, 0, 1)
	selection.Adornee = box
	selection.Parent = box

	task.delay(1 / 30, box.Destroy, box)
end

function VectorMap2D:AddTo(position: Vector3, typeOfData: string, object: any)
	local voxelSize = self._voxelSize
	local voxelKey = Vector3.new(math.floor(position.X / voxelSize), 0, math.floor(position.Z / voxelSize))

	local voxel = self._voxels[voxelKey]
	if voxel == nil then
		self._voxels[voxelKey] = {
			[typeOfData] = { object },
		}
		self.voxelAdded:Fire(voxelKey, self._voxels[voxelKey])
	elseif voxel[typeOfData] == nil then
		voxel[typeOfData] = { object }
	else
		table.insert(voxel[typeOfData], object)
	end

	return voxelKey
end

function VectorMap2D:RemoveFrom(position: Vector3, typeOfData: string, object: any)
	local voxel = self._voxels[position]

	if voxel == nil then
		return
	end

	if voxel[typeOfData] == nil then
		return
	end

	local classBucket = voxel[typeOfData]
	for index, storedObject in ipairs(classBucket) do
		if storedObject == object then
			local n = #classBucket
			classBucket[index] = classBucket[n]
			classBucket[n] = nil
			break
		end
	end

	-- Remove empty class bucket
	if #classBucket == 0 then
		voxel[typeOfData] = nil :: any

		-- Remove empty voxel
		if next(voxel) == nil then
			self.voxelRemoving:Fire(position, self._voxels[position])
			self._voxels[position] = nil
		end
	end
end

function VectorMap2D:AddEntity(entityType: string, position: Vector3, entity: any)
	return self:AddTo(position, entityType, entity)
end

function VectorMap2D:RemoveEntity(entityType: string, position: Vector3, entity: any)
	return self:RemoveFrom(position, entityType, entity)
end

function VectorMap2D:AddInstance(position: Vector3, instance: Instance)
	return self:AddTo(position, instance.ClassName, instance)
end

function VectorMap2D:RemoveObject(position: Vector3, instance: Instance)
	return self:RemoveFrom(position, instance.ClassName, instance)
end

function VectorMap2D:GetVoxels()
	return self._voxels
end

function VectorMap2D:GetVoxel(voxelKey: Vector3)
	return self._voxels[voxelKey]
end

function VectorMap2D:ClearVoxel(voxelKey: Vector3)
	self.voxelRemoving:Fire(voxelKey, self._voxels[voxelKey])
	self._voxels[voxelKey] = nil
end

function VectorMap2D:ForEachObjectInRadius(voxelKey: Vector3, voxelRadius: number, callback: (string, any) -> ())
	local xMin, xMax = voxelKey.X - voxelRadius, voxelKey.X + voxelRadius
	local yMin, yMax = voxelKey.Z - voxelRadius, voxelKey.Z + voxelRadius

	for x = xMin, xMax do
		for y = yMin, yMax do
			local voxelPos = Vector3.new(x, 0, y)
			local voxel = self._voxels[voxelPos]
			if voxel then
				local distanceSquared = (voxelPos - voxelKey).Magnitude
				if distanceSquared <= voxelRadius then
					for entityType, objects in pairs(voxel) do
						for _, object in ipairs(objects) do
							callback(entityType, object)
						end
					end
				end
			end
		end
	end
end

function VectorMap2D:ForEachObjectInRegion(top: Vector3, bottom: Vector3, callback: (string, any) -> ())
	local voxelSize = self._voxelSize
	local xMin, yMin = math.min(bottom.X, top.X), math.min(bottom.Z, top.Z)
	local xMax, yMax = math.max(bottom.X, top.X), math.max(bottom.Z, top.Z)

	for x = math.floor(xMin / voxelSize), math.floor(xMax / voxelSize) do
		for y = math.floor(yMin / voxelSize), math.floor(yMax / voxelSize) do
			local voxel = self._voxels[Vector3.new(x, 0, y)]
			if voxel then
				for entityType, objects in pairs(voxel) do
					for _, object in ipairs(objects) do
						callback(entityType, object)
					end
				end
			end
		end
	end
end

function VectorMap2D:ForEachObjectInView(camera: Camera, distance: number, callback: (string, any) -> ())
	local voxelSize = self._voxelSize
	local cameraCFrame = camera.CFrame
	local cameraPos = cameraCFrame.Position
	local rightVec, upVec = cameraCFrame.RightVector, cameraCFrame.UpVector

	local distance2 = distance / 2
	local farPlaneHeight2 = math.tan(math.rad((camera.FieldOfView + 5) / 2)) * distance
	local farPlaneWidth2 = farPlaneHeight2 * (camera.ViewportSize.X / camera.ViewportSize.Y)
	local farPlaneCFrame = cameraCFrame * CFrame.new(0, 0, -distance)
	local farPlaneTopLeft = farPlaneCFrame * Vector3.new(-farPlaneWidth2, farPlaneHeight2, 0)
	local farPlaneTopRight = farPlaneCFrame * Vector3.new(farPlaneWidth2, farPlaneHeight2, 0)
	local farPlaneBottomLeft = farPlaneCFrame * Vector3.new(-farPlaneWidth2, -farPlaneHeight2, 0)
	local farPlaneBottomRight = farPlaneCFrame * Vector3.new(farPlaneWidth2, -farPlaneHeight2, 0)

	local frustumCFrameInverse = (cameraCFrame * CFrame.new(0, 0, -distance2)):Inverse()

	local rightNormal = upVec:Cross(farPlaneBottomRight - cameraPos).Unit
	local leftNormal = upVec:Cross(farPlaneBottomLeft - cameraPos).Unit
	local topNormal = rightVec:Cross(cameraPos - farPlaneTopRight).Unit
	local bottomNormal = rightVec:Cross(cameraPos - farPlaneBottomRight).Unit

	local minBound =
		cameraPos:Min(farPlaneTopLeft):Min(farPlaneTopRight):Min(farPlaneBottomLeft):Min(farPlaneBottomRight)
	local maxBound =
		cameraPos:Max(farPlaneTopLeft):Max(farPlaneTopRight):Max(farPlaneBottomLeft):Max(farPlaneBottomRight)

	minBound = Vector3.new(math.floor(minBound.X / voxelSize), 0, math.floor(minBound.Z / voxelSize))
	maxBound = Vector3.new(math.floor(maxBound.X / voxelSize), 0, math.floor(maxBound.Z / voxelSize))

	local function isPointInView(point: Vector3): boolean
		-- Check if point lies outside frustum OBB
		local relativeToOBB = frustumCFrameInverse * Vector3.new(point.X, 0, point.Y)
		if
			relativeToOBB.X > farPlaneWidth2
			or relativeToOBB.X < -farPlaneWidth2
			or relativeToOBB.Y > farPlaneHeight2
			or relativeToOBB.Y < -farPlaneHeight2
			or relativeToOBB.Z > distance2
			or relativeToOBB.Z < -distance2
		then
			return false
		end

		-- Check if point lies outside a frustum plane
		local lookToCell = Vector3.new(point.X, 0, point.Y) - cameraPos
		if
			rightNormal:Dot(lookToCell) < 0
			or leftNormal:Dot(lookToCell) > 0
			or topNormal:Dot(lookToCell) < 0
			or bottomNormal:Dot(lookToCell) > 0
		then
			return false
		end

		return true
	end

	for x = minBound.X, maxBound.X do
		for y = minBound.Y, maxBound.Y do
			local voxel = self._voxels[Vector3.new(x, 0, y)]
			if voxel then
				local voxelPos = Vector3.new(x * voxelSize, 0, y * voxelSize)
				if isPointInView(voxelPos) then
					for className, objects in pairs(voxel) do
						for _, object in ipairs(objects) do
							callback(className, object)
						end
					end
				end
			end
		end
	end
end

function VectorMap2D:ClearAll()
	self._voxels = {}
end

return VectorMap2D
