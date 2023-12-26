local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local packages = ReplicatedStorage.Packages
local Matter = require(packages.Matter)
local Plasma = require(packages.Plasma)
local hotReloader = require(packages.Rewire).HotReloader
local componentRegistry = require(script.Parent.componentRegistry)

local function start(containers)
	local world = require(script.Parent.worldRegistry)
	local state = require(script.Parent.worldState)

	local debugger = Matter.Debugger.new(Plasma)
	local loop = Matter.Loop.new(world, state, debugger:getWidgets())

	-- Set up hot reloading
	local hotReloader = hotReloader.new()

	local firstRunSystems = {}
	local systemsByModule = {}
	local moduleSetups = {}

	for _, container in
		{
			ReplicatedStorage.shared.core,
			ReplicatedStorage.shared.bundles,

			if RunService:IsClient()
				then ReplicatedStorage.client.bundles
				else game:GetService("ServerScriptService").server.bundles,

			if RunService:IsClient()
				then ReplicatedStorage.client.core
				else game:GetService("ServerScriptService").server.core,
		}
	do
		for _, bundle in container:GetChildren() do
			local module

			if bundle:IsA("ModuleScript") and bundle.name == "components" then
				module = bundle
			else
				module = bundle:FindFirstChild("components")
			end

			if module and module:IsA("ModuleScript") then
				require(module)
			end
		end
	end

	local function safeCall(path, ...)
		local ok, result = pcall(...)
		if not ok then
			warn("Error when hot-reloading", path.name, result)
		end
		return ok, result
	end

	local function runSetups()
		if firstRunSystems == nil then
			return
		end

		for path, data in moduleSetups do
			if type(data) == "function" then
				safeCall(path, data, world, state)
			elseif type(data) == "table" and data.setup then
				safeCall(path, data.setup, world, state)
			end
		end
	end

	local function scheduleSystem(path, system)
		if firstRunSystems then
			if type(system) == "table" and system.systems == nil then
				table.insert(firstRunSystems, system)
			elseif type(system) == "function" then
				table.insert(firstRunSystems, system)
			end
		elseif systemsByModule[path] then
			loop:replaceSystem(systemsByModule[path], system)
			debugger:replaceSystem(systemsByModule[path], system)
		else
			loop:scheduleSystem(system)
		end

		systemsByModule[path] = system
	end

	local function unloadModule(_, context)
		if context.isReloading then
			return
		end

		local originalModule = context.originalModule
		if systemsByModule[originalModule] then
			loop:evictSystem(systemsByModule[originalModule])
			systemsByModule[originalModule] = nil
		end
	end

	local function loadModule(module, context)
		local originalModule = context.originalModule
		local ok, result = safeCall(module, require, module)

		if ok == false then
			return
		end

		if type(result) == "function" then
			scheduleSystem(originalModule, result)
		end
	end

	for _, container in containers do
		for _, module in container:GetChildren() do
			if module:IsA("ModuleScript") then
				local ok, result = safeCall(module, require, module)

				if ok and type(result) == "table" then
					if result.systems then
						for _, path in result.systems do
							local success, system = safeCall(path, require, path)

							if success then
								scheduleSystem(path, system)
							end
						end
					end

					if result.setups then
						for _, path in result.setups do
							local success, setup = safeCall(path, require, path)

							if success then
								moduleSetups[path] = setup
							end
						end
					end
				end

				hotReloader:listen(module, loadModule, unloadModule)
			end
		end
	end

	print(firstRunSystems, componentRegistry)
	runSetups()
	loop:scheduleSystems(firstRunSystems)
	firstRunSystems = nil :: any

	debugger:autoInitialize(loop)

	-- Begin running our systems

	loop:begin({
		default = RunService.Heartbeat,
		Stepped = RunService.Stepped,
	})

	if RunService:IsClient() then
		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.F4 then
				debugger:toggle()
				state.debugEnabled = debugger.enabled
			end
		end)
	else
		debugger.authorize = function(player)
			return true
		end
	end

	return world, state
end

return start
