local HttpService = game:GetService("HttpService")
local uuidUtils = {}

function uuidUtils.generate()
	return string.gsub(HttpService:GenerateGUID(false), "-", "")
end

function uuidUtils.pack(uuid: string)
	return (string.gsub(uuid, "%x%x", function(c)
		return string.char(tonumber(c, 16) :: number)
	end))
end

function uuidUtils.unpack(packed: string)
	return (string.gsub(packed, ".", function(char)
		return string.format("%2x", string.byte(char))
	end))
end

return uuidUtils
