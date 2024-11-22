function TSIL.Utils.Tables.Equals(table1, table2)
	if #table1 ~= #table2 then
		return false
	end

	for i, v in pairs(table1) do
		local table2Element = table2[i]

		if type(table2Element) == "table" and type(v) == "table" then
			local isTableMatching = TSIL.Utils.Tables.Equals(table2Element, v)
			if not isTableMatching then
				return false
			end
		elseif table2Element ~= v then
			return false
		end
	end

	return true
end

