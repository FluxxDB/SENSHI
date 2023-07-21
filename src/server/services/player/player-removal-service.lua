local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.types.enums)

local PlayerRemovalService = {}

function PlayerRemovalService:removeByCode(player: Player, code: Enums.KickCode)
	return player:Kick(
		`\n\nYou have been forcibly removed from the session\nReason: {Enums.KickReason[code]}\n\nError Code: {code}`
	)
end

return PlayerRemovalService
