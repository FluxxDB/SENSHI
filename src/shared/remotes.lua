local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages

local Net = require(packages.Net)

return Net.CreateDefinitions({
	Replicate = Net.Definitions.ServerToClientEvent(),

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
	SpellCast = Net.Definitions.Namespace({
		Begin = Net.Definitions.ClientToServerEvent(),
		End = Net.Definitions.ClientToServerEvent(),
		Cancel = Net.Definitions.ClientToServerEvent(),
		SelectRune = Net.Definitions.ClientToServerEvent(),
	}),
})
