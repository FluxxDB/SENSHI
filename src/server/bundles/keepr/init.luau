local Wisp = require("@shared/wisp")

local function main(wisp: Wisp.Wisp)
	wisp.addComponents(script.components)
		.addSystems(script.handleKeepr)
end

return main
