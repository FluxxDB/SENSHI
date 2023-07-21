local BodyParts = {
  [1] = "Head",
  [2] = "Chest",
  [3] = "Abdomen",
  [4] = "Right Arm",
  [5] = "Left Arm",
  [6] = "Right Leg",
  [7] = "Left Leg",
}

for _, part in ipairs(BodyParts) do
  BodyParts[part] = part
end

table.freeze(BodyParts)

return BodyParts