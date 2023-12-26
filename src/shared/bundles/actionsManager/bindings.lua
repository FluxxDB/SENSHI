local Binds = {
	["Interact"] = {
		["PC"] = { ["Primary"] = Enum.KeyCode.E, ["Secondary"] = nil },
		["Controller"] = { ["Primary"] = nil, ["Secondary"] = nil },
	},
	["Hotbar1"] = {
		["PC"] = { ["Primary"] = Enum.KeyCode.One, ["Secondary"] = nil },
		["Controller"] = { ["Primary"] = nil, ["Secondary"] = nil },
	},
}

local collection = {}
for _, action in Binds do
	for device, binds in action do
		for priority, bind in binds do
			collection[bind] = {
				["Action"] = action,
				["Device"] = device,
				["Priority"] = priority,
			}
		end
	end
end

Binds.inputsCollection = collection

return Binds
