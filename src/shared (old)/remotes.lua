local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Net = require(Packages.Net)

return Net.CreateDefinitions({
	RequestData = Net.Definitions.ClientToServerEvent({
		Net.Middleware.RateLimit({
			MaxRequestsPerMinute = 1,
		}),
	}),

	SpellCast = Net.Definitions.Namespace({
		Begin = Net.Definitions.ClientToServerEvent(),
		End = Net.Definitions.ClientToServerEvent(),
		Cancel = Net.Definitions.ClientToServerEvent(),
		SelectRune = Net.Definitions.ClientToServerEvent(),
	}),

	Character = Net.Definitions.Namespace({
		Spawn = Net.Definitions.ClientToServerEvent({
			Net.Middleware.RateLimit({
				MaxRequestsPerMinute = 1,
			}),
		}),
		Move = Net.Definitions.ClientToServerEvent({
			Net.Middleware.RateLimit({
				MaxRequestsPerMinute = 2000,
			}),
		}),

		Create = Net.Definitions.ClientToServerEvent(),
		Update = Net.Definitions.ClientToServerEvent(),
		Select = Net.Definitions.ClientToServerEvent(),
		Delete = Net.Definitions.ClientToServerEvent(),
	}),
})
