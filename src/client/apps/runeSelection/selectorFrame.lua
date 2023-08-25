local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local ReactSpring = require(Packages.ReactSpring)
local React = require(Packages.React)
local e = React.createElement

local cardinalCursor = require(script.Parent.Parent.cursor.cardinalCursor)
local sector = require(script.Parent.sector)

local runes = { "Xi", "Zeta", "Theta", "Sigma" }

type Props = {}

local RuneSelectionApp: React.FC<Props> = function(props: Props, _)
	local directionState, setDirectionState = React.useState(0)
	local mouseState, setMouseState = React.useState(false)
	local localDirectionState = 0
	local lastSwitch = 0

	local styles, api = ReactSpring.useSpring(function()
		return { from = { transparency = 1 } }
	end)

	React.useEffect(function()
		-- TODO: Add in background blur with the motors

		api.start({
			from = { transparency = 1 },
			to = { transparency = 0 },
			config = { frequency = 0.3, damping = 1 },
		})

		-- "Smooth" Cursor
		-- local lastMousePosition = 0
		-- ContextActionService:BindAction("MouseMoved", function(actionName, inputState, inputObject)
		-- 	UserInputService.MouseIconEnabled = false
		-- 	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

		-- 	local x = math.atan2(inputObject.Delta.Y, inputObject.Delta.X)
		-- 	setPreviousDirectionState(lastMousePosition)
		-- 	setDirectionState(math.floor((math.deg(x) + 90) / 10) * 10)
		-- 	lastMousePosition = math.floor((math.deg(x) + 90) / 10) * 10
		-- end, false, Enum.UserInputType.MouseMovement)

		-- "Snappy" Cursor

		ContextActionService:BindAction("MouseMoved", function(_, _, inputObject)
			UserInputService.MouseIconEnabled = false
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

			if os.clock() - lastSwitch < 0.05 then
				return
			end

			local deltaPosition = inputObject.Delta
			local newDirection
			if math.abs(deltaPosition.X) > math.abs(deltaPosition.Y) then
				if deltaPosition.X < 0 then
					newDirection = 3
				else
					newDirection = 4
				end

				lastSwitch = os.clock()
			elseif math.abs(deltaPosition.X) < math.abs(deltaPosition.Y) then
				if deltaPosition.Y < 0 then
					newDirection = 1
				else
					newDirection = 2
				end

				lastSwitch = os.clock()
			end

			if not newDirection then
				return
			end

			setDirectionState(newDirection)
			localDirectionState = newDirection
		end, false, Enum.UserInputType.MouseMovement)

		ContextActionService:BindAction("ConfirmSelection", function(_, inputState, inputObject)
			if localDirectionState <= 0 then
				return
			end

			if inputState == Enum.UserInputState.Begin then
				setMouseState(true)
			elseif inputState == Enum.UserInputState.End then
				setMouseState(false)
				print(`Confirmed: {runes[localDirectionState]}`)
				-- TODO: Fire to server runes[directionState]
			end
		end, false, Enum.UserInputType.MouseButton1)

		return function()
			ContextActionService:UnbindAction("MouseMoved")
			ContextActionService:UnbindAction("ConfirmSelection")
		end
	end, {})

	return e(
		"Frame",
		{ Name = "RuneSelectionContainer", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 },
		e(cardinalCursor, { directionState = directionState }),
		e(
			"ImageLabel",
			{
				Name = "RuneSelectionDividers",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.37, 0.3),
				Position = UDim2.fromScale(0.5, 0.5),
				Image = "rbxassetid://14531966500",
				BackgroundTransparency = 1,
				ImageTransparency = styles.transparency,
				ZIndex = 5,
			},
			e("UIAspectRatioConstraint", {
				AspectRatio = 1,
				AspectType = Enum.AspectType.ScaleWithParentSize,
				DominantAxis = Enum.DominantAxis.Width,
			})
		),
		e(sector, {
			directionState = directionState,
			mouseState = mouseState,
			cardinalClass = "TopSector",
			rune = runes[1],
			transparency = styles.transparency,
		}),
		e(sector, {
			directionState = directionState,
			mouseState = mouseState,
			cardinalClass = "BottomSector",
			rune = runes[2],
			transparency = styles.transparency,
		}),
		e(sector, {
			directionState = directionState,
			mouseState = mouseState,
			cardinalClass = "LeftSector",
			rune = runes[3],
			transparency = styles.transparency,
		}),
		e(sector, {
			directionState = directionState,
			mouseState = mouseState,
			cardinalClass = "RightSector",
			rune = runes[4],
			transparency = styles.transparency,
		})
	)
end
return RuneSelectionApp
