local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Net = require(Packages.Net)

return Net.CreateDefinitions({
	RequestData = Net.Definitions.ClientToServerEvent({
		Net.Middleware.RateLimit({
			MaxRequestsPerMinute = 1,
		}),
	}),

	Character = Net.Definitions.Namespace({
		Spawn = Net.Definitions.ClientToServerEvent({
			Net.Middleware.RateLimit({
				MaxRequestsPerMinute = 1,
			}),
		}),
		Move = Net.Definitions.ClientToServerEvent(),

		Create = Net.Definitions.ClientToServerEvent(),
		Update = Net.Definitions.ClientToServerEvent(),
		Select = Net.Definitions.ClientToServerEvent(),
		Delete = Net.Definitions.ClientToServerEvent(),
	}),
})
