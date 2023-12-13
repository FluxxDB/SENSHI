local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local ReactSpring = require(Packages.ReactSpring)
local React = require(Packages.React)
local e = React.createElement

local directions = { 0, 0, 180, 270, 90 }

type Props = {
	directionState: number,
	transparency: any,
}

local CardinalCursor: React.FC<Props> = function(props: Props, _)
	--! BRING THIS BACK IF YOU KNOW HOW TO MULTIPLY TWO GOD DAMN REACTBINDING VALUES
	-- local styles, api = ReactSpring.useSpring(function()
	-- 	return { transparency = 0 }
	-- end)

	-- React.useEffect(function()
	-- 	api.start({
	-- 		from = { transparency = 0.5 },
	-- 		to = { transparency = 0 },
	-- 		config = { frequency = 0.1, damping = 1 },
	-- 	})

	-- 	return function()
	-- 		api.start({
	-- 			from = { transparency = 0 },
	-- 			to = { transparency = 0.5 },
	-- 			config = { frequency = 0.1, damping = 1 },
	-- 		})
	-- 	end
	-- end, { props.directionState })

	return e("ImageLabel", {
		Name = "CardinalCursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.05, 0.05),
		Image = (props.directionState == 0) and "rbxassetid://14532089282" or "rbxassetid://14531874724",
		Rotation = directions[props.directionState + 1],
		BackgroundTransparency = 1,
		ImageTransparency = props.transparency,
	}, e("UIAspectRatioConstraint", { AspectRatio = 1 }))
end
return CardinalCursor
