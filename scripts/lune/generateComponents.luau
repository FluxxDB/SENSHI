local start = os.clock()
local fs = require("@lune/fs")

local TEMPLATE = [[
local matterTypes = require("@types/matter")

type Component<T> = matterTypes.Component<T>
%s
export type Components = {
  [any]: any,
  %s}

return {} :: Components
]]

local function formatTime(elapsed)
  if elapsed < 1 then
    return string.format("%.6fms", elapsed * 1000)
  else
    return string.format("%.6fs", elapsed)
  end
end

local function gatherModules(dir: string, modules: any?)
	local data: any = modules or {}

	for _, entry in fs.readDir(dir) do
    if entry == "types" then
      continue
    end

		local fullpath = dir .. "/" .. entry

		if fs.isDir(fullpath) then
			gatherModules(fullpath, data)
		elseif entry:match("components") then
			local realm = fullpath:match("src/([^/]+)/")

			if realm == nil then
				continue
			end

			if data[realm] == nil then
				data[realm] = {}
			end

			table.insert(data[realm], fs.readFile(fullpath))
		end
	end

	return data
end

local function processModules(realms: any)
	local sources = {
		types = "",
		components = "",
	}

	for realm, modules in realms do
		for _, module in modules do
			for definition in module:gmatch("(export type [%w_]+.-{.-})[\r\n]") do
				sources.types ..= `\n{definition}\n`
			end

			for name, definition in
				module:gmatch("components%.([%w_]+).-Component%<(.-)%>")
			do
				sources.components ..= `\n\t{name}: Component<{definition}>,\n`
			end
		end
	end
  
	return sources
end

local modules = gatherModules("src")
local result = processModules(modules)

if not fs.isDir("src/types") then
  fs.writeDir("src/types")
end

if not fs.isDir("src/types/generated") then
  fs.writeDir("src/types/generated")
end

fs.writeFile("src/types/generated/components.luau", string.format(TEMPLATE, result.types, result.components))
print(`successfully generated components (in {formatTime(os.clock()-start)})`)
