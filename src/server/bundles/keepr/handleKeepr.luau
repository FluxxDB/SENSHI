local Matter = require("@packages/Matter")
local registries = script.Parent.registries
local components = require("@shared/components")

local collection = require(registries.collection)
local documents = require(registries.documents)
local parsers = require(registries.parsers)

local useThrottle = Matter.useThrottle

local Keepr = components.Keepr
local KeeprStatus = components.KeeprStatus

local function saveComponents(id: number, world)
	local keepr: any, status = world:get(id, Keepr, KeeprStatus)

	for _, component in { world:get(id, unpack(keepr.components)) } do
		-- save components
	end

	status = status:patch({
		saved = true,
		_changed = true,
	})

	world:insert(id, status)

	return status
end

local function loadComponents(id: number, world)
	local keepr, status = world:get(id, Keepr, KeeprStatus)

	collection
		:load(keepr.document)
		:andThen(function(document)
			documents[keepr.document] = document

			if document[keepr.entity] then
				-- load components
			end

			document:beforeClose(function()
				if world:contains(id) then
					saveComponents(id, world)
				end

				documents[keepr.document] = nil
			end)
		end)
		:catch(function(msg)
			warn(`Document "{keepr.document}" failed to load: {msg}`)
		end)
end

local function unloadKeepr(id: number, world)
	local keepr, status = world:get(id, Keepr, KeeprStatus)
	local document = documents[keepr.document]

	if document then
		document:close()
	end
end

local function handleKeeprStatus(world: any)
	for id, keepr in world:query(Keepr):without(KeeprStatus) do
		world:insert(id, KeeprStatus())
		loadComponents(id, world)
	end

	for id, record in world:queryChanged(KeeprStatus) do
		local status = record.new
		if status and status.loaded and status.unloaded == false then
			if status.saved == false then
				saveComponents(id, world)
			end

			if status.unload then
				unloadKeepr(id, world)
			end
		end
	end

	if useThrottle(1, "Auto-Save") then
		for id, status in world:query(KeeprStatus) do
			if status.loaded and os.clock() - status.autosave >= 30 then
				saveComponents(id, world)
				world:insert(
					id,
					status:patch({
						autosave = os.clock(),
					})
				)
			end
		end
	end
end

return {
	system = handleKeeprStatus,
	priority = -math.huge,
}
