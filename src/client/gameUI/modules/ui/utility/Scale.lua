local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement
local useWindowSize = require(script.Parent.Parent.hooks.useWindowSize)
local topInset, bottomInset = GuiService:GetGuiInset()

local Scale: React.FC<{}> = function(props)
	local viewportSize = useWindowSize()
	local scale, setScale = React.useBinding(props.Scale)

	React.useEffect(function()
		local currentSize = props.Size
		viewportSize = viewportSize - (topInset + bottomInset)
		setScale((1 / math.max(currentSize.X / viewportSize.X, currentSize.Y / viewportSize.Y)) * props.Scale)
	end, { viewportSize })

	return e("UIScale", {
		Scale = scale,
	})
end

return Scale
