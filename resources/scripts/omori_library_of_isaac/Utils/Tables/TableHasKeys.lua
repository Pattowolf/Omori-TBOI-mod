function TSIL.Utils.Tables.TableHasKeys(map, ...)
    local keys = {...}
    for _, v in pairs(keys) do
        if map[v] == nil then
            return false
        end
    end

    return true
end