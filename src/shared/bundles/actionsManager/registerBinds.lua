local bindings = require(script.Parent.bindings)
local bindingsCollection = bindings.inputsCollection

local function registerBinds(changedBinds)
	for _, action in changedBinds do
		for device, priorities in action do
			for priority, bind in priorities do
				if bind == nil then
					local existingBind = bindings[action][device][priority]
					table.remove(bindingsCollection, table.find(bindingsCollection, existingBind))
				elseif bindingsCollection[bind] then
					local overwrittenBind = bindingsCollection[bind]
					bindings[overwrittenBind.Action][overwrittenBind.Device][overwrittenBind.Priority] = nil
				end

				bindings[action][device][priority] = bind
			end
		end
	end
end

return registerBinds
