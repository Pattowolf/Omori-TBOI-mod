---@diagnostic disable: missing-return-value
local mod = OmoriMod

local enums = OmoriMod.Enums
local costumes = enums.NullItemID

---comment
---@param player EntityPlayer
function mod:OmoriInit(player)
	if OmoriMod:IsOmori(player, false) then
		player:AddNullCostume(costumes.ID_OMORI)
		player:AddNullCostume(costumes.ID_OMORI_EMOTION)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.OmoriInit)

---comment
---@param itemconfig ItemConfigItem
---@param player EntityPlayer
---@return boolean
function mod:PreAddOmoriCostume(itemconfig, player)	
	if not OmoriMod:IsOmori(player, false) then return end

	local costume = itemconfig.Costume
	local ID = costume.ID
		
	if ID == costumes.ID_OMORI or ID == costumes.ID_OMORI_EMOTION then return end
	
	return true
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_COSTUME, mod.PreAddOmoriCostume)
	
local overrideWeapons = {
	[WeaponType.WEAPON_KNIFE] = true,
	[WeaponType.WEAPON_SPIRIT_SWORD] = true,
}

--- comment
--- @param player EntityPlayer
function mod:OmoUpdate(player)
	if not OmoriMod:IsKnifeUser(player) then return end		
	local weapon = player:GetWeapon(1)
	
	if weapon == nil then return end

	local override = overrideWeapons[weapon:GetWeaponType()] or false

	if override == true then
		local newWeapon = Isaac.CreateWeapon(WeaponType.WEAPON_TEARS, player)
		Isaac.DestroyWeapon(weapon)
		player:EnableWeaponType(WeaponType.WEAPON_TEARS, true)
		player:SetWeapon(newWeapon, 1)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.OmoUpdate)