local function getSaveDataForMod(modPersistentData)
    local saveData = {}

    TSIL.Utils.Tables.IterateTableInOrder(modPersistentData.variables, function(variableName, variable)
        local conditionalFunc = variable.conditionalSave

        if conditionalFunc ~= nil then
            local shouldSave = conditionalFunc()
            if not shouldSave then
                return
            end
        end

        if variable.persistenceMode == TSIL.Enums.VariablePersistenceMode.REMOVE_ROOM or
        variable.persistenceMode == TSIL.Enums.VariablePersistenceMode.RESET_ROOM then
            return
        end

        saveData[variableName] = variable
    end)

    local safeCopy = TSIL.Utils.DeepCopy.DeepCopy(saveData, TSIL.Enums.SerializationType.SERIALIZE)
    return safeCopy
end


function TSIL.SaveManager.SaveToDisk()
    TSIL.Log.Log("Saving to disk")

    local PersistentData = TSIL.__VERSION_PERSISTENT_DATA.PersistentData

    local libraryPersistentData = PersistentData["TSIL_MOD"]
    local librarySaveData
    if libraryPersistentData then
        librarySaveData = getSaveDataForMod(libraryPersistentData)
    end

    TSIL.Utils.Tables.IterateTableInOrder(PersistentData, function (modName, modPersistentData)
        if modName == "TSIL_MOD" then
            return
        end

        local saveData = getSaveDataForMod(modPersistentData)

        local modAndLibraryData = {
            TSIL_DATA = librarySaveData,
            MOD_DATA = saveData
        }

        local jsonString = TSIL.JSON.Encode(modAndLibraryData)

        modPersistentData.mod:SaveData(jsonString)
    end)
end