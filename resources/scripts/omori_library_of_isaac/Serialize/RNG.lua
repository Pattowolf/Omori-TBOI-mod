local KEYS = {"seed"}
local OBJECT_NAME = "RNG"

function TSIL.Serialize.DeserializeRNG(rng)
    if type(rng) ~= "table" then
        error("Failed to deserialize a " .. OBJECT_NAME .. " object since the provided object was not a table")
    end

    local numbers = TSIL.Utils.Tables.GetNumbersFromTable(rng, OBJECT_NAME, table.unpack(KEYS))

    if numbers[1] == nil then
        error("Failed to deserialize a " .. OBJECT_NAME .. " as the provided object did not have a value for: seed")
    end

    return TSIL.RNG.NewRNG(numbers[1])
end


function TSIL.Serialize.IsSerializedRNG(object)
    if type(object) ~= "table" then
        return false
    end

    return TSIL.Utils.Tables.TableHasKeys(object, table.unpack(KEYS)) and object[TSIL.Enums.SerializationBrand.RNG] ~= nil
end


function TSIL.Serialize.SerializeRNG(rng)
    if not TSIL.IsaacAPIClass.IsRNG(rng) then
        error("Failed to serialize a " .. OBJECT_NAME .. " object since the provided object was not a userdata " .. OBJECT_NAME .. " class.")
    end

    local rngTable = {}
    TSIL.Utils.Tables.CopyUserdataValuesToTable(rng, KEYS, rngTable)
    rngTable[TSIL.Enums.SerializationBrand.RNG] = ""
    return rngTable
end