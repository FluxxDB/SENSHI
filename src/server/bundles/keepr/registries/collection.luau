local RunService = game:GetService("RunService")

local Lapis = require("@server-packages/Lapis")
local t = require("@packages/t")

local dataStoreService

if RunService:IsStudio() then
  local DataStoreServiceMock = require("@server-packages/DataStoreServiceMock")
  dataStoreService = DataStoreServiceMock.new()

  Lapis.setConfig({
    dataStoreService = dataStoreService :: any,
  })
end

local collection = Lapis.createCollection("KeeprStore", {
	defaultData = {},
	validate = t.map(
		t.string,
		t.union(t.number, t.string, t.map(t.any, t.any))
	)
})

return collection
