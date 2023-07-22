local TableTypes = require(script.Parent["TableTypes"])

type Array<T> = TableTypes.Array<T>
type Dictionary<T> = TableTypes.Dictionary<T>

export type TCustomization = {
	eyes: number,
	nose: number,
	mouth: number,

	height: number,
	width: number,

	colors: Dictionary<Array<number>>,
}

export type TItem = {
	uid: string,
	id: string,
	seed: number,
	quantity: number,
}

export type TWorld = {
	id: number,
	pos: Array<number>,
}

export type TStash = {
	items: { [number]: TItem },
}

export type TInventory = {
	items: Array<TItem>,
	slots: Dictionary<TItem>,
}

export type TRace = {
	id: number,
	[string]: any,
}

export type TDefaultCharacterSlot = {
	race: TRace,
	world: TWorld,
	stats: Dictionary<number>,
	vitals: Dictionary<number>,
	mastery: Dictionary<number>,
	inventory: TInventory,
	appearance: TCustomization,
	statistics: Dictionary<any>,
	achievements: Array<number>,
	createdAt: number,
	deletedAt: number,
}

export type TDefaultPlayerData = {
	stash: TStash,
	achievements: Array<number>,
	capacities: Dictionary<any>,
	statistics: Dictionary<any>,
	characters: Array<TDefaultCharacterSlot>,
	settings: Dictionary<any>,
}

return {}
