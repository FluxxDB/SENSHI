local RunService = game:GetService("RunService")
local Wisp = require("@shared/wisp")

local function setupClientCamera() end

local function main(wisp: Wisp.Wisp)
	if RunService:IsClient() then
		wisp.addSetups(setupClientCamera)
			.addSystems(script.updateOriginFromGrid)
			.addSystems(script.reflectOriginRefTransform)
	end

	wisp.addComponents(script.components)
		.addSystems(script.updateGridFromTransform)
end

return main
