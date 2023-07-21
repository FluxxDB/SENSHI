local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Net = require(Packages.Net)

return  Net.CreateDefinitions({
	ReplicatedAction = Net.Definitions.ServerToClientEvent(),
	RequestData = Net.Definitions.ClientToServerEvent({
		Net.Middleware.RateLimit({
			MaxRequestsPerMinute = 1,
		}),
	}),

	Character = Net.Definitions.Namespace({
		Spawn = Net.Definitions.ClientToServerEvent(),
		Move = Net.Definitions.ClientToServerEvent(),
		
		CreateCharacter = Net.Definitions.ClientToServerEvent(),
		UpdateCharacter = Net.Definitions.ClientToServerEvent(),
		SelectCharacter = Net.Definitions.ClientToServerEvent(),
		DeleteCharacter = Net.Definitions.ClientToServerEvent(),
	}),
})
