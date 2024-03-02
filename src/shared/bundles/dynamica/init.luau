local RunService = game:GetService("RunService")
local Wisp = require("@shared/wisp")

local function main(wisp: Wisp.Wisp)
	wisp.addComponents(script.components)
		.addSetups(script.test)

  if RunService:IsClient() then
    wisp.addSystems(script.debugDynamoid)
  end
end

return main
