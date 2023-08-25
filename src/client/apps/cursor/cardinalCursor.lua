local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local ReactSpring = require(Packages.ReactSpring)
local React = require(Packages.React)
local e = React.createElement

local directions = { 0, 0, 180, 270, 90 }

type Props = {
	directionState: number,
}

local CardinalCursor: React.FC<Props> = function(props: Props, _)
	local styles, api = ReactSpring.useSpring(function()
		return {}
	end)

	React.useEffect(function()
		api.start({
			from = { transparency = 0.5 },
			to = { transparency = 0 },
			config = { frequency = 0.1, damping = 1 },
		})
		-- api.start({
		-- 	from = {
		-- 		rotation = directions[props.previousDirectionState + 1],
		-- 		-- rotation = props.previousDirectionState,
		-- 	},
		-- 	to = {
		-- 		rotation = directions[props.directionState + 1],
		-- 		-- rotation = props.directionState,
		-- 	},
		-- 	config = { frequency = 0.05, damping = 1 },
		-- })
		return function()
			api.start({
				from = { transparency = 0 },
				to = { transparency = 0.5 },
				config = { frequency = 0.1, damping = 1 },
			})
		end
	end, { props.directionState })

	return e("ImageLabel", {
		Name = "CardinalCursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.05, 0.05),
		Image = (props.directionState == 0) and "rbxassetid://14532089282" or "rbxassetid://14531874724",
		ImageTransparency = styles.transparency,
		Rotation = directions[props.directionState + 1],
		BackgroundTransparency = 1,
	}, e("UIAspectRatioConstraint", { AspectRatio = 1 }))
end
return CardinalCursor
