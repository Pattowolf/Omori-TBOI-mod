
function TSIL.SaveManager.GetPersistentVariable(mod, variableName)
	local PersistentData = TSIL.__VERSION_PERSISTENT_DATA.PersistentData

	local modPersistentData = PersistentData[mod.Name]

	if modPersistentData == nil then
		return
	end

	local modVariables = modPersistentData.variables

	local foundVariable = modVariables[variableName]

	if foundVariable == nil then
		return
	end

	return foundVariable.value
end