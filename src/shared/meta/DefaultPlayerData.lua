local ReplicatedStorage = game:GetService("ReplicatedStorage")
local saveTypes = require(ReplicatedStorage.types["SaveTypes"])

local DefaultSaveSlot: saveTypes.TDefaultCharacterSlot = {
	hardcore = nil,
	world = {
		id = nil,
		position = nil,
	},
	race = {},
	stats = {},
	vitals = {},
	mastery = {},
	inventory = {
		capacity = 16,
		items = {},
		slots = {},
	},
	appearance = {},
	statistics = {},
	achievements = {},
	createdAt = nil,
	deletedAt = nil,
} :: any

local DefaultPlayerData: saveTypes.TDefaultPlayerData = {
	stash = {
		capacity = 8,
		items = {},
	},
	characters = {
		active = -1,
		capacity = 2,
	},
	achievements = {},
	statistics = {},
	settings = {},
} :: any

return {
	DefaultPlayerData = DefaultPlayerData,
	DefaultSaveSlot = DefaultSaveSlot,
	PurchaseLogLength = 50,
}
