local KickCode = require(script.Parent["KickCode"])

local KickReason = {
	[KickCode.LoadFailed] = `Data retrieval from the server was unsuccessful`,
	[KickCode.LoadedElsewhere] = `Your data is being processed on a separate server`,
}

table.freeze(KickReason)
return KickReason
