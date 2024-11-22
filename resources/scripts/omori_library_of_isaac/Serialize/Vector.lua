local KEYS = {"X", "Y"}
local OBJECT_NAME = "Vector"

function TSIL.Serialize.DeserializeVector(vector)
    local numbers = TSIL.Utils.Tables.GetNumbersFromTable(vector, OBJECT_NAME, table.unpack(KEYS))

    if numbers[1] == nil then
        error("Failed to deserialize Vector as the provided object did not have a value for: X")
    elseif numbers[2] == nil then
        error("Failed to deserialize Vector as the provided object did not have a value for: Y")
    end

    return Vector(numbers[1], numbers[2])
end

function TSIL.Serialize.IsSerializedVector(object)
    if type(object) ~= "table" then
        return false
    end

    return TSIL.Utils.Tables.TableHasKeys(object, table.unpack(KEYS)) and object[TSIL.Enums.SerializationBrand.VECTOR] ~= nil
end

function TSIL.Serialize.SerializeVector(vector)
    if not TSIL.IsaacAPIClass.IsVector(vector) then
        error("Failed to serialize a " .. OBJECT_NAME .. " object since the provided object was not a userdata " .. OBJECT_NAME .. " class.")
    end

    local vectorTable = {}
    TSIL.Utils.Tables.CopyUserdataValuesToTable(vector, KEYS, vectorTable)
    vectorTable[TSIL.Enums.SerializationBrand.VECTOR] = ""
    return vectorTable
end