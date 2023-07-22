--!strict

local Vector2Map = {}
Vector2Map.__index = Vector2Map

function Vector2Map.new(voxelSize: number?)
	return setmetatable({
		_voxelSize = voxelSize or 50,
		_voxels = {},
	}, Vector2Map)
end

function Vector2Map:_debugDrawVoxel(voxelKey: Vector2)
	local box = Instance.new("Part")
	box.Name = tostring(voxelKey)
	box.Anchored = true
	box.CanCollide = false
	box.Transparency = 1
	box.Size = Vector3.new(self._voxelSize, 0, self._voxelSize)
	box.Position = Vector3.new(voxelKey.X, 0, voxelKey.Y) * self._voxelSize
		+ Vector3.new(self._voxelSize / 2, 0, self._voxelSize / 2)
	box.Parent = workspace

	local selection = Instance.new("SelectionBox")
	selection.Color3 = Color3.new(0, 0, 1)
	selection.Adornee = box
	selection.Parent = box

	task.delay(1 / 30, box.Destroy, box)
end

function Vector2Map:AddObject(position: Vector2, object: any)
	local className = object.ClassName

	local voxelSize = self._voxelSize
	local voxelKey = Vector2.new(math.floor(position.X / voxelSize), math.floor(position.Y / voxelSize))

	local voxel = self._voxels[voxelKey]

	if voxel == nil then
		self._voxels[voxelKey] = {
			[className] = { object },
		}
	elseif voxel[className] == nil then
		voxel[className] = { object }
	else
		table.insert(voxel[className], object)
	end

	return voxelKey
end

function Vector2Map:RemoveObject(voxelKey: Vector2, object: any)
	local voxel = self._voxels[voxelKey]

	if voxel == nil then
		return
	end

	local className = object.ClassName
	if voxel[className] == nil then
		return
	end

	local classBucket = voxel[className]
	for index, storedObject in ipairs(classBucket) do
		if storedObject == object then
			-- Swap remove to avoid shifting
			local n = #classBucket
			classBucket[index] = classBucket[n]
			classBucket[n] = nil
			break
		end
	end

	-- Remove empty class bucket
	if #classBucket == 0 then
		voxel[className] = nil

		-- Remove empty voxel
		if next(voxel) == nil then
			self._voxels[voxelKey] = nil
		end
	end
end

function Vector2Map:GetVoxel(voxelKey: Vector2)
	return self._voxels[voxelKey]
end

function Vector2Map:ForEachObjectInRadius(point: Vector2, radius: number, callback: (string, any) -> ())
	local voxelSize = self._voxelSize
	local voxelKey = Vector2.new(math.floor(point.X / voxelSize), math.floor(point.Y / voxelSize))

	local voxelRadius = math.ceil(radius / voxelSize)

	local xMin, xMax = voxelKey.X - voxelRadius, voxelKey.X + voxelRadius
	local yMin, yMax = voxelKey.Y - voxelRadius, voxelKey.Y + voxelRadius

	for x = xMin, xMax do
		for y = yMin, yMax do
			local voxel = self._voxels[Vector2.new(x, y)]
			if voxel then
				local voxelPos = Vector2.new(x * voxelSize, y * voxelSize)
				local distanceSquared = (voxelPos - point).magnitude
				if distanceSquared <= radius then
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

function Vector2Map:ForEachObjectInRegion(top: Vector2, bottom: Vector2, callback: (string, any) -> ())
	local voxelSize = self._voxelSize
	local xMin, yMin = math.min(bottom.X, top.X), math.min(bottom.Y, top.Y)
	local xMax, yMax = math.max(bottom.X, top.X), math.max(bottom.Y, top.Y)

	for x = math.floor(xMin / voxelSize), math.floor(xMax / voxelSize) do
		for y = math.floor(yMin / voxelSize), math.floor(yMax / voxelSize) do
			local voxel = self._voxels[Vector2.new(x, y)]
			if voxel then
				for className, objects in pairs(voxel) do
					for _, object in ipairs(objects) do
						callback(className, object)
					end
				end
			end
		end
	end
end

function Vector2Map:ForEachObjectInView(camera: Camera, distance: number, callback: (string, any) -> ())
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

	minBound = Vector2.new(math.floor(minBound.X / voxelSize), math.floor(minBound.Z / voxelSize))
	maxBound = Vector2.new(math.floor(maxBound.X / voxelSize), math.floor(maxBound.Z / voxelSize))

	local function isPointInView(point: Vector2): boolean
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
			local voxel = self._voxels[Vector2.new(x, y)]
			if voxel then
				local voxelPos = Vector2.new(x * voxelSize, y * voxelSize)
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

function Vector2Map:ClearAll()
	self._voxels = {}
end

return Vector2Map
