local KEYS = {"l", "h"}
local OBJECT_NAME = "BitSet128"


function TSIL.Serialize.DeserializeBitSet128(bitSet128)
    local numbers = TSIL.Utils.Tables.GetNumbersFromTable(bitSet128, OBJECT_NAME, table.unpack(KEYS))

    if numbers[1] == nil then
        error("Failed to deserialize BitSet128 as the provided object did not have a value for: l")
    elseif numbers[2] == nil then
        error("Failed to deserialize BitSet128 as the provided object did not have a value for: h")
    end

    return BitSet128(numbers[1], numbers[2])
end


function TSIL.Serialize.IsSerializedBitSet128(object)
    if type(object) ~= "table" then
        return false
    end

    return TSIL.Utils.Tables.TableHasKeys(object, table.unpack(KEYS)) and object[TSIL.Enums.SerializationBrand.BIT_SET_128] ~= nil
end


function TSIL.Serialize.SerializeBitSet128(bitSet128)
    if not TSIL.IsaacAPIClass.IsBitSet128(bitSet128) then
        error("Failed to serialize a " .. OBJECT_NAME .. " object since the provided object was not a userdata " .. OBJECT_NAME .. " class.")
    end

    local bitSet128Table = {}
    TSIL.Utils.Tables.CopyUserdataValuesToTable(bitSet128, KEYS, bitSet128Table)
    bitSet128Table[TSIL.Enums.SerializationBrand.BIT_SET_128] = ""
    return bitSet128Table
end