function TSIL.Utils.Tables.IsIn(list, element)
	local found = TSIL.Utils.Tables.FindFirst(list, function (_, value)
		if type(value) == "table" and type(element) == "table" then
			return TSIL.Utils.Tables.Equals(value, element)
		else
			return element == value
		end
	end)

	return found ~= nil
end