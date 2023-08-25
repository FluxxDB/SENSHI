local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Client = ReplicatedStorage:WaitForChild("Client")

local React = require(Packages.React)
local e = React.createElement

local runeSelection = require(script.Parent.runeSelection.selectorFrame)
local Scale = require(Client.modules.ui.utility.Scale)

type Props = {}

local App: React.FC<Props> = function(props: Props, _)
	return e(
		"ScreenGui",
		{ IgnoreGuiInset = true },
		e(
			runeSelection,
			{},
			e(Scale, {
				Size = Vector2.new(150, 150),
				Scale = 0.2,
			})
		)
	)
end
return App
