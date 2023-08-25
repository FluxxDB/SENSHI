local function createWorldBorder()
	local border = Instance.new("Part")
	border.Size = Vector3.new(2048, 2048, 4)
	border.Material = Enum.Material.ForceField
	border.Anchored = true
	border.CastShadow = false

	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Brick
	specialMesh.Scale = Vector3.new(10, 1.5, 10)
	specialMesh.Parent = border

	return border
end

return createWorldBorder
