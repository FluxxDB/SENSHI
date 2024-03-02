local Wisp = require("@shared/wisp")

local function main()
	Wisp.new()
		.addBundles(require("@bundles/defaults"))
		.addBundles(require("@bundles/dynamica"))
		.addBundles(require("@bundles/farlands"))
		.addBundles(require("@server-bundles/keepr"))
    .run()
end

main()
