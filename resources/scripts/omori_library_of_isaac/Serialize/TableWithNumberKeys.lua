local OBJECT_NAME = "Table with number keys"

function TSIL.Serialize.DeserializeTableWithNumberKeys(tableWithNumberKeys)
    if type(tableWithNumberKeys) ~= "table" then
        error("Failed to deserialize a " .. OBJECT_NAME .. " object since the provided object was not a table")
    end

    local deserializedTable = {}

    for index, value in pairs(tableWithNumberKeys) do
        if index ~= TSIL.Enums.SerializationBrand.TABLE_WITH_NUMBER_KEYS then
            local numberIndex = tonumber(index)

            if numberIndex == nil then
                error("Failed to deserialize a " .. OBJECT_NAME .. " object since not all keys are integers")
            end

            deserializedTable[numberIndex] = value
        end
    end

    return deserializedTable
end


function TSIL.Serialize.IsSerializedTableWithNumberKeys(object)
    if type(object) ~= "table" then
        return false
    end

    return object[TSIL.Enums.SerializationBrand.TABLE_WITH_NUMBER_KEYS] ~= nil
end


function TSIL.Serialize.SerializeTableWithNumberKeys(tableWithNumberKeys)
    if not type(tableWithNumberKeys) == "table" then
        error("Failed to serialize a " .. OBJECT_NAME .. " object since the provided object was not a table")
    end

    local serializedTable = {}
    for index, value in pairs(tableWithNumberKeys) do
        serializedTable[tostring(index)] = value
    end
    serializedTable[TSIL.Enums.SerializationBrand.TABLE_WITH_NUMBER_KEYS] = ""
    return serializedTable
end