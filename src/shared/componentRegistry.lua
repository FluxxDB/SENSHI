local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Matter = require(ReplicatedStorage.Packages.Matter)

local componentRegistry = {} :: { [any]: typeof(Matter.component()) }

local function gatherBundles(containers)
	for _, container in containers do
		for _, bundle in container:GetChildren() do
			local module

			if bundle:IsA("ModuleScript") and bundle.name == "components" then
				module = bundle
			else
				module = bundle:FindFirstChild("components")
			end

			if module and module:IsA("ModuleScript") then
				for name, component in require(module) do
					componentRegistry[name] = component
				end
			end
		end
	end
end

gatherBundles({
	ReplicatedStorage.shared.core,
	ReplicatedStorage.shared.bundles,

	if RunService:IsClient()
		then ReplicatedStorage.client.bundles
		else game:GetService("ServerScriptService").server.bundles,

	if RunService:IsClient() then ReplicatedStorage.client.core else game:GetService("ServerScriptService").server.core,
})

return componentRegistry
