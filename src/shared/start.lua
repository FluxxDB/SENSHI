local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local packages = ReplicatedStorage.Packages
local Matter = require(packages.Matter)
local Plasma = require(packages.Plasma)
local hotReloader = require(packages.Rewire).HotReloader

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

	local function runSetups()
		if firstRunSystems == nil then
			return
		end

		for path, data in moduleSetups do
			if type(data) == "function" then
				local ok, result = pcall(data, world, state)
				if not ok then
					warn("Error when hot-reloading setup", path.name, result)
					continue
				end
			elseif type(data) == "table" and data.setup then
				local ok, result = pcall(data.setup, world, state)
				if not ok then
					warn("Error when hot-reloading setup", path.name, result)
					continue
				end
			end
		end
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

		local ok, result = pcall(require, module)

		if not ok then
			warn("Error when hot-reloading system", module.name, result)
			return
		end

		if type(result) == "table" then
			if result.setups then
				for _, path in result.setups do
					local success, setup = pcall(require, path)

					if not success then
						warn("Error when hot-reloading setup", path.name, result)
						continue
					end

					moduleSetups[path] = setup
				end
			end

			if result.systems then
				for _, path in result.systems do
					ok, result = pcall(require, module)

					if not ok then
						warn("Error when hot-reloading system", module.name, result)
						continue
					end

					if systemsByModule[path] == nil then
						systemsByModule[path] = true
						hotReloader:listen(path, loadModule, unloadModule)
					end
				end
			end
		else
			if firstRunSystems then
				table.insert(firstRunSystems, result)
			elseif systemsByModule[originalModule] then
				loop:replaceSystem(systemsByModule[originalModule], result)
				debugger:replaceSystem(systemsByModule[originalModule], result)
			else
				loop:scheduleSystem(result)
			end

			systemsByModule[originalModule] = result
		end
	end

	for _, container in containers do
		for _, module in ipairs(container:GetChildren()) do
			if module:IsA("ModuleScript") then
				hotReloader:listen(module, loadModule, unloadModule)
			end
		end
	end

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
