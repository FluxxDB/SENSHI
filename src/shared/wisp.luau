local RunService = game:GetService("RunService")

local Matter = require("@packages/Matter")
local Plasma = require("@packages/Plasma")
local Rewire = require("@packages/Rewire")

local components = require("@shared/components")

local function processArguments(argument, action)
	local data

	if typeof(argument) == "Instance" and argument:IsA("ModuleScript") then
		local success, result = pcall(require, argument)
		if success == false then
			warn(
				"Failed to index system or incorrect type for module:",
				argument:GetFullName()
			)
			return
		end
		data = result
	else
		data = argument
	end

	if type(data) ~= "function" and type(data) ~= "table" then
		return
	end

	if type(data) == "table" and (data.system or data.main) then
		data = if data.main then data.main else data
	end

	if data then
		action(data)
	end
end

-- NOTE:
-- Yes, this is OOP in an ECS project. Sorry,
-- but the builder pattern is very useful.

local WispBuilder = {}

function WispBuilder.new()
	local state = require("@shared/registries/state") :: any
	local world = require("@shared/registries/world") :: any
	local debugger = Matter.Debugger.new(Plasma) :: any
	local hotreloader = Rewire.HotReloader.new()

	local self = {
		loop = Matter.Loop.new(world, state, debugger:getWidgets()) :: any,
		systemsByModule = {} :: any,
		systems = {} :: any,
		setups = {} :: any,
	}

	debugger.findInstanceFromEntity = function(id)
		if not world:contains(id) then
			return
		end

		local model = world:get(id, components.Model)
		return model and model.model or nil
	end

	debugger.authorize = function(player)
		if player:GetRankInGroup(372) > 250 then
			return true
		end

		return false
	end

	local function loadModule(module, context)
		local originalModule = context.originalModule
		local systemsByModule = self.systemsByModule

		local success, result = pcall(require, module)
		if success == false then
			warn("Error when hot-reloading system", module.name, result)
			return
		end

		if systemsByModule[originalModule] then
			self.loop:replaceSystem(systemsByModule[originalModule], result)
			debugger:replaceSystem(systemsByModule[originalModule], result)
		else
			if type(result) == "table" and result.debug then
			else
				self.loop:scheduleSystem(result)
			end
		end

		systemsByModule[originalModule] = result
	end

	local function unloadModule(module, context)
		if context.isReloading then
			return
		end

		local originalModule = context.originalModule
		local systemsByModule = self.systemsByModule

		if systemsByModule[originalModule] then
			self.loop:evictSystem(systemsByModule[originalModule])
			systemsByModule[originalModule] = nil
		end
	end

	function self.toggleDebugger()
		debugger:toggle()
		state.debugEnabled = debugger.enabled
		workspace:SetAttribute("EnableGizmos", state.debugEnabled)

		for module, system in self.systemsByModule do
			if type(system) == "table" and system.debug then
				if state.debugEnabled then
					self.loop:scheduleSystem(system)
				else
					self.loop:evictSystem(system)
				end
			end
		end
	end

	function self.addComponents(...)
		for _, data in { ... } do
			processArguments(data, function(result)
				for name, component in result do
					components[name] = component
				end
			end)
		end

		return self
	end

	function self.addBundles(...)
		for _, data in { ... } do
			processArguments(data, function(bundle)
				local success, result =
					pcall(bundle, self, world, state, debugger)
				if not success then
					local name

					if type(data) == "function" then
						name =
							`{debug.info(data, "s")} -> {debug.info(data, "n")}`
					elseif typeof(data) == "Instance" then
						name = data.Name
					end

					warn("Failed to load bundle:", name, "Error:", result)
				end
			end)
		end

		return self
	end

	function self.addSystems(...)
		for _, data in { ... } do
			table.insert(self.systems, data)
		end

		return self
	end

	function self.addSetups(...)
		for _, data in { ... } do
			processArguments(data, function(result)
				table.insert(self.setups, result)
			end)
		end

		return self
	end

	function self.run()
		for _, setup in self.setups do
			local success, result = pcall(setup, world, state, debugger)
			if success == false then
				warn(`Failed to run setup {debug.info(setup, "n")}: "{result}"`)
			end
		end

		table.clear(self.setups)

		for _, module in self.systems do
			processArguments(module, function()
				hotreloader:listen(module, loadModule, unloadModule)
			end)
		end

		table.clear(self.systems)

		debugger:autoInitialize(self.loop)
		self.loop:begin({
			default = RunService.Heartbeat,
			Stepped = RunService.Stepped,
			PostSimulation = RunService.PostSimulation,
		})
	end

	return self
end

export type Wisp = typeof(WispBuilder.new())

return WispBuilder
