local ReplicatedStorage = game:GetService("ReplicatedStorage")

local defaultData = require(script.Parent["default-player-data"])

local Sift = require(ReplicatedStorage.Packages.Sift)
local Dictionary = Sift.Dictionary

local MockSaveSlot = Dictionary.joinDeep(defaultData.DefaultSaveSlot, {
	race = {
		id = 1,
	},
	inventory = {
		capacity = 100,
		items = {},
		slots = {},
	},
	appearance = {
		eyes = 1,
		nose = 1,
		mouth = 1,

		height = 1,
		width = 1,
	},
})

local MockPlayerData = {
	stash = {
		capacity = 100,
		items = {},
	},
	characters = {
		active = 1,
		capacity = 100,
		[1] = MockSaveSlot,
	},
	achievements = {},
	statistics = {},
	settings = {},
}

return MockPlayerData
