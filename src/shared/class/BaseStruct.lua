local Sift = require(game:GetService("ReplicatedStorage").Packages.Sift)

local BaseStruct = {}
BaseStruct.__index = BaseStruct

export type BaseStruct<T> = {
	insert: (self: any, data: T) -> nil,
	patch: (self: any, id: string, data: T) -> nil,
	getById: (self: any, id: string) -> T,
	getRegistry: (self: any) -> { [string]: T },
	getUpdated: (self: any) -> { [number]: string },
	clearUpdated: (self: any) -> nil,
	serialize: (self: any, id: string, data: T?) -> string,
	deserialize: (self: any, stream: string) -> ...any,
}

function BaseStruct:new<T>(): BaseStruct<T>
	return setmetatable({
		_nextId = 0,
		_registry = {},
		_changed = {},
	}, BaseStruct) :: any
end

function BaseStruct:insert(data: any)
	self._nextId += 1
	local id = tostring(self._nextId)

	self._registry[id] = data

	if table.find(self._changed, id) == nil then
		table.insert(self._changed, id)
	end

	return id
end

function BaseStruct:patch(id: string, data: any)
	if self._registry[id] then
		self._registry[id] = Sift.Dictionary.join(self._registry[id], data)
		if table.find(self._changed, id) == nil then
			table.insert(self._changed, id)
		end
	else
		warn(`No entity found with 'ID-{id}'`)
	end
end

function BaseStruct:getById(id: string)
	return self._registry[id]
end

function BaseStruct:getRegistry()
	return table.clone(self._registry)
end

function BaseStruct:getUpdated()
	return table.clone(self._changed)
end

function BaseStruct:clearUpdated()
	table.clear(self._changed)
end

-- No Operation
function noop() end

BaseStruct.serialize = noop
BaseStruct.deserialize = noop

return BaseStruct
