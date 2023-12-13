local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local React = require(Packages.React)
local e = React.createElement

type Props = {
	runes: any, -- Move this to a variable later
	transparency: number,
}

local selectorHistory: React.FC<Props> = function(props: Props, _)
	return e(
		"ScrollingFrame",
		{
			Size = UDim2.fromScale(0.05, 1),
			BackgroundTransparency = 1,
			ScrollBarImageTransparency = 1,
			ScrollBarThickness = 0,
		},
		e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),
		table.unpack(props.runes)
	)
end

return selectorHistory
