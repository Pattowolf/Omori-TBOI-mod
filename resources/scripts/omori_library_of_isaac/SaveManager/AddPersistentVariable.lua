
function TSIL.SaveManager.AddPersistentVariable(mod, variableName, value, persistenceMode, ignoreGlowingHourglass, conditionalSave)
	if ignoreGlowingHourglass == nil then
		ignoreGlowingHourglass = false
	end

	local PersistentData = TSIL.__VERSION_PERSISTENT_DATA.PersistentData

	local modPersistentData = PersistentData[mod.Name]

	if modPersistentData == nil then
		modPersistentData = {
			mod = mod,
			variables = {}
		}
		PersistentData[mod.Name] = modPersistentData
	end

	local modVariables = modPersistentData.variables

	local foundVariable = modVariables[variableName]

	if foundVariable ~= nil then
		return
	end

	local newVariable = {
		default = TSIL.Utils.DeepCopy.DeepCopy(value, TSIL.Enums.SerializationType.NONE),
		value = value,
		persistenceMode = persistenceMode,
		ignoreGlowingHourglass = ignoreGlowingHourglass,
		conditionalSave = conditionalSave
	}
	modVariables[variableName] = newVariable
end