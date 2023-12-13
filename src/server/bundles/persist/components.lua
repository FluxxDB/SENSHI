local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = {}
local createComponent = require(ReplicatedStorage.shared.createComponent)

type Component<T> = createComponent.Component<T>

export type Save = {
	key: string,
	userId: string,
	components: { [any]: any },
	loaded: boolean?,
}

export type Loaded = {}
export type Unload = {}
export type Unloaded = {}

components.Save = createComponent("Save") :: Component<Save>
components.Loaded = createComponent("Loaded") :: Component<Loaded>
components.Unload = createComponent("Unload") :: Component<Unload>
components.Unloaded = createComponent("Unloaded") :: Component<Unloaded>

return components
