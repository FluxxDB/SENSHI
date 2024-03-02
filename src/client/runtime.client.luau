local UserInputService = game:GetService("UserInputService")
local Wisp = require("@shared/wisp")

local function main()
  local wisp = Wisp.new()
  
  UserInputService.InputBegan:Connect(function(input)
      if input.KeyCode == Enum.KeyCode.F4 then
          wisp.toggleDebugger()
      end
  end)
  
  wisp.addBundles(require("@bundles/defaults"))
		.addBundles(require("@bundles/farlands"))
    .addBundles(require("@bundles/dynamica"))
		.run()
end

main()
