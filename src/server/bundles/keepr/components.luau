local Matter = require("@packages/Matter")
local matterTypes = require("@types/matter")

type Component<T> = matterTypes.Component<T>
local component = Matter.component :: any

local components = {}

export type Keepr = {
  components: { [any]: Component<any> },
	document: string,	
	entity: string,
}

export type KeeprStatus = {
  autosave: number,
  saved: boolean,
  loaded: boolean,
  unload: boolean,
  unloaded: boolean,
}

components.Keepr = component("Keepr") :: Component<Keepr>
components.KeeprStatus = component("KeeprStatus") :: Component<KeeprStatus>

return components
