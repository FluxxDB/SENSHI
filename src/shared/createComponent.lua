local ReplicatedStorage = game:GetService("ReplicatedStorage")

local matterTypes = require(ReplicatedStorage.types.matter)
local Matter = require(ReplicatedStorage.Packages.Matter)

local components = require(ReplicatedStorage.shared.componentRegistry)
local component = Matter.component

export type Component<T> = matterTypes.Component<T>

local function createComponent<T>(name: string, ...: T): Component<T>
	if components[name] then
		error(`Component '{name}' already exists`)
	end

	components[name] = component(name, ...)

	return components[name]
end

return createComponent
