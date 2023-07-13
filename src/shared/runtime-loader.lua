local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("packages")
local Loader = require(Packages.Loader)

local modulesMatch = if RunService:IsClient() then "controller$" else "service$"

local function sortByLoadOrder(a, b)
    return (a._loadOrder or 0) < (b._loadOrder or 0)
end

local function executeCallback(callback: string, mod: any)
    local method = mod[callback]
    if type(method) == "function" then
        if callback == "onInit" then
            method(mod)
        else
            task.defer(method, mod)
        end
    end
end

local function loadModules(...: { [number]: Instance })
    local folders = { ... }

    for _, folder in folders do
        local sortedModules, nameByModule = {}, {}
        for name, module in Loader.LoadDescendants(folder, Loader.MatchesName(modulesMatch)) do
            table.insert(sortedModules, module)
            nameByModule[module] = name
        end

        table.sort(sortedModules, sortByLoadOrder)

        for _, module in sortedModules do
            debug.setmemorycategory(nameByModule[module])
            for _, callbackName in { "onInit", "onStart" } do
                executeCallback(callbackName, module)
            end
        end
    end
end

return {
    loadModules = loadModules,
}