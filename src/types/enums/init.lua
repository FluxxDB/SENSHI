local enums = {
	BodyPart = require(script["BodyPart"]),
	KickCode = require(script["KickCode"]),
	KickReason = require(script["KickReason"]),
}

export type Scenes = typeof(enums.BodyPart)
export type KickCode = typeof(enums.KickCode)
export type KickReason = typeof(enums.KickReason)

return enums
