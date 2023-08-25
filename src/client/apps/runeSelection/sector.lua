local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local ReactSpring = require(Packages.ReactSpring)
local React = require(Packages.React)
local e = React.createElement

local assets = ReplicatedStorage:WaitForChild("Assets")
local castingRunes = assets:WaitForChild("CastingRunes")

local cardinalClassToState = {
	["TopSector"] = 1,
	["BottomSector"] = 2,
	["LeftSector"] = 3,
	["RightSector"] = 4,
}

local sectorImages = {
	["TopSector"] = "rbxassetid://14532034765",
	["BottomSector"] = "rbxassetid://14532061813",
	["LeftSector"] = "rbxassetid://14532052298",
	["RightSector"] = "rbxassetid://14532069859",
}

local frameImages = {
	["TopSector"] = "rbxassetid://14532044484",
	["BottomSector"] = "rbxassetid://14532064149",
	["LeftSector"] = "rbxassetid://14532047048",
	["RightSector"] = "rbxassetid://14532067163",
}

local runePlacements = {
	["TopSector"] = UDim2.fromScale(0.5, 0.19),
	["BottomSector"] = UDim2.fromScale(0.5, 0.81),
	["LeftSector"] = UDim2.fromScale(0.195, 0.5),
	["RightSector"] = UDim2.fromScale(0.805, 0.5),
}

type Props = {
	directionState: number,
	mouseState: boolean,
	cardinalClass: string,
	rune: string,
	transparency: number,
}

local App: React.FC<Props> = function(props: Props, _)
	local wasSelected, setWasSelected = React.useState(false)
	local runeInfo = castingRunes:FindFirstChild(props.rune, true)
	local styles, api = ReactSpring.useSpring(function()
		return { xScale = 0.37 }
	end)

	React.useEffect(function()
		if cardinalClassToState[props.cardinalClass] ~= props.directionState then
			if wasSelected then
				setWasSelected(false)

				api.start({
					to = { xScale = 0.37 },
					config = { frequency = 0.1, damping = 1 },
				})
			end

			return
		else
			setWasSelected(true)

			api.start({
				to = { xScale = 0.385 },
				config = { frequency = 0.1, damping = 1 },
			})
		end

		if props.mouseState then
			api.pause()

			api.start({
				from = { xScale = 0.385 },
				to = { xScale = 0.385 * 1.04 },
				config = { frequency = 0.07, damping = 1 },
			})
			return
		end
	end, { props.directionState, props.mouseState })

	return e(
		"ImageLabel",
		{
			Name = props.cardinalClass,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = sectorImages[props.cardinalClass],
			ImageTransparency = props.transparency,
			Size = styles.xScale:map(function(xScale)
				return UDim2.fromScale(xScale, 0.3)
			end),
		},
		e("UIAspectRatioConstraint", {
			AspectRatio = 1,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Width,
		}),
		e("ImageLabel", {
			Name = "Frame",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = frameImages[props.cardinalClass],
			ImageColor3 = runeInfo.Value,
			ImageTransparency = props.transparency,
		}),
		e("ImageLabel", {
			Name = `Rune - {props.rune}`,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = runePlacements[props.cardinalClass],
			Size = UDim2.fromScale(0.2, 0.2),
			BackgroundTransparency = 1,
			Image = runeInfo:GetAttribute("Image"),
			ImageColor3 = runeInfo.Value,
			ImageTransparency = props.transparency,
		})
	)
end
return App
