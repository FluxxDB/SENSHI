local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local useWorld = require(script.Parent.Parent.Parent.modules.ui.hooks.useWorld)

local ReactSpring = require(Packages.ReactSpring)
local React = require(Packages.React)
local e = React.createElement

local Components = require(Shared.components)
local PlayerRef = Components.PlayerRef
local ManaPool = Components.ManaPool

local assets = ReplicatedStorage:WaitForChild("Assets")
local castingRunes = assets:WaitForChild("CastingRunes")
local keyTypes = require(ReplicatedStorage.types["KeyTypes"])

local cardinalCursor = require(script.Parent.Parent.cursor.cardinalCursor)
local selectorHistory = require(script.Parent.selectorHistory)
local sector = require(script.Parent.sector)

local remotes = require(Shared.remotes)
local spellCastRemotes = remotes.Client:GetNamespace("SpellCast")
local spellCastBeginEvent = spellCastRemotes:Get("Begin") :: { SendToServer: (...any) -> () }
local spellCastEndEvent = spellCastRemotes:Get("End") :: { SendToServer: (...any) -> () }
local spellCastCancelEvent = spellCastRemotes:Get("Cancel") :: { SendToServer: (...any) -> () }
local spellCastSelectRuneEvent = spellCastRemotes:Get("SelectRune") :: { SendToServer: (...any) -> () }

local runes: { keyTypes.TRuneKey } = {
	{ id = 3, runeName = "Xi" },
	{ id = 4, runeName = "Zeta" },
	{ id = 2, runeName = "Theta" },
	{ id = 1, runeName = "Sigma" },
}

type Props = {}

local RuneSelectionApp: React.FC<Props> = function(props: Props, _)
	local world = useWorld()
	local directionState, setDirectionState = React.useState(0)
	local mouseState, setMouseState = React.useState(false)
	local runesState, setRunesState = React.useState({})
	local localDirectionState = 0
	local lastSwitch = 0
	local castingState = false

	local styles, api = ReactSpring.useSpring(function()
		return { from = { transparency = 1 } }
	end)

	React.useEffect(function()
		-- TODO: Add in background blur with the motors
		-- TODO: Play sound effects

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

		ContextActionService:BindAction("Casting", function(_, inputState, inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton2 and castingState then
				castingState = false

				spellCastCancelEvent:SendToServer()
				UserInputService.MouseIconEnabled = true
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				ContextActionService:UnbindAction("MouseMoved")
				ContextActionService:UnbindAction("ConfirmSelection")

				api.start({
					from = { transparency = 0 },
					to = { transparency = 1 },
					config = { frequency = 0.15, damping = 1 },
				})
			elseif inputObject.KeyCode == Enum.KeyCode.R then
				if inputState == Enum.UserInputState.Begin then
					castingState = true

					spellCastBeginEvent:SendToServer()
					UserInputService.MouseIconEnabled = false
					UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
					setRunesState({})

					ContextActionService:BindAction("MouseMoved", function(_, _, inputObject)
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
						if not castingState then
							return
						end

						if localDirectionState <= 0 then
							return
						end

						if inputState == Enum.UserInputState.Begin then
							setMouseState(true)
						elseif inputState == Enum.UserInputState.End then
							local runeKey = runes[localDirectionState]
							local runeInfo = castingRunes:FindFirstChild(runeKey.runeName, true)
							if not runeInfo then
								return
							end

							local hasSufficentMana = true
							for _, playerRef, manaPool in world:query(PlayerRef, ManaPool) do
								if playerRef.instance ~= Players.LocalPlayer then
									continue
								end

								local manaCost = runeInfo:GetAttribute("ManaCost")
								if manaPool.mana < manaCost then
									hasSufficentMana = false
								end
							end

							if hasSufficentMana then
								spellCastSelectRuneEvent:SendToServer(runeKey.id, runeKey.runeName)

								setRunesState(function(oldRunes)
									local newRunes = {}
									if #oldRunes > 0 then
										newRunes = { table.unpack(oldRunes) }
									end
									table.insert(
										newRunes,
										e(
											"ImageLabel",
											{
												Name = runeKey.runeName,
												Size = UDim2.fromScale(1, 1),
												BackgroundTransparency = 1,
												Image = runeInfo:GetAttribute("Image"),
												ImageTransparency = styles.transparency,
												ImageColor3 = runeInfo.Value,
												LayoutOrder = -(#oldRunes + 1),
											},
											e("UIAspectRatioConstraint", {
												AspectRatio = 1,
												AspectType = Enum.AspectType.ScaleWithParentSize,
												DominantAxis = Enum.DominantAxis.Width,
											})
										)
									)

									return newRunes
								end)
							else
								-- TODO: Don't add rune to history, don't play usual selection effect (shake red instead)
								print("Insufficent Mana")
							end

							setMouseState(false)
						end
					end, false, Enum.UserInputType.MouseButton1)

					api.start({
						from = { transparency = 1 },
						to = { transparency = 0 },
						config = { frequency = 0.15, damping = 1 },
					})
				elseif inputState == Enum.UserInputState.End and castingState then
					castingState = false

					spellCastEndEvent:SendToServer()
					UserInputService.MouseIconEnabled = true
					UserInputService.MouseBehavior = Enum.MouseBehavior.Default
					ContextActionService:UnbindAction("MouseMoved")
					ContextActionService:UnbindAction("ConfirmSelection")

					api.start({
						from = { transparency = 0 },
						to = { transparency = 1 },
						config = { frequency = 0.15, damping = 1 },
					})
				end
			end
		end, false, Enum.KeyCode.R, Enum.UserInputType.MouseButton2)

		return function()
			ContextActionService:UnbindAction("Casting")
		end
	end, {})

	return e(
		"Frame",
		{ Name = "RuneSelectionContainer", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 },
		e(cardinalCursor, { directionState = directionState, transparency = styles.transparency }),
		e(selectorHistory, { runes = runesState, transparency = styles.transparency }),
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
