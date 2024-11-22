local KEYS = {"Red", "Green", "Blue", "Alpha"}
local OBJECT_NAME = "KColor"

function TSIL.Serialize.DeserializeKColor(kColor)
    if type(kColor) ~= "table" then
        error("Failed to deserialize a " .. OBJECT_NAME .. " object since the provided object was not a table")
    end

    local numbers = TSIL.Utils.Tables.GetNumbersFromTable(kColor, OBJECT_NAME, table.unpack(KEYS))

    if numbers[1] == nil then
        error("Failed to deserialize a " .. OBJECT_NAME .. " as the provided object did not have a value for: Red")
    elseif numbers[2] == nil then
        error("Failed to deserialize a " .. OBJECT_NAME .. " as the provided object did not have a value for: Green")
    elseif numbers[3] == nil then
        error("Failed to deserialize a " .. OBJECT_NAME .. " as the provided object did not have a value for: Blue")
    elseif numbers[4] == nil then
        error("Failed to deserialize a " .. OBJECT_NAME .. " as the provided object did not have a value for: Alpha")
    end

    return KColor(numbers[1], numbers[2], numbers[3], numbers[4])
end


function TSIL.Serialize.IsSerializedKColor(object)
    if type(object) ~= "table" then
        return false
    end

    return TSIL.Utils.Tables.TableHasKeys(object, table.unpack(KEYS)) and object[TSIL.Enums.SerializationBrand.K_COLOR] ~= nil
end


function TSIL.Serialize.SerializeKColor(kColor)
    if not TSIL.IsaacAPIClass.IsKColor(kColor) then
        error("Failed to serialize a " .. OBJECT_NAME .. " object since the provided object was not a userdata " .. OBJECT_NAME .. " class.")
    end

    local kColorTable = {}
    TSIL.Utils.Tables.CopyUserdataValuesToTable(kColor, KEYS, kColorTable)
    kColorTable[TSIL.Enums.SerializationBrand.K_COLOR] = ""
    return kColorTable
end