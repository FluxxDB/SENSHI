local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local Framework = script.Parent.Parent.Parent
local Packages = ReplicatedStorage.Packages
-- local Shared = ReplicatedStorage.Shared

-- local Sift = require(Packages.Sift)
local Rodux = require(Packages.Rodux)
local Store = Rodux.Store

local reducers = {}

-- local module = modules:FindFirstChild("reducers", true)
-- reducers = Sift.Dictionary.join(reducers, require(module))

local ClientStore = Store.new(Rodux.combineReducers(reducers), {}, {})

return ClientStore
