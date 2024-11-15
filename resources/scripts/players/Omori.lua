local mod = OmoriMod

local enums = OmoriMod.Enums
local utils = enums.Utils


function mod:OmoriInit(player)
	local playerData = OmoriMod:GetData(player)
	if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then
		player:AddNullCostume(OmoriMod.Enums.NullItemID.ID_OMORI)
		player:AddNullCostume(OmoriMod.Enums.NullItemID.ID_OMORI_EMOTION)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.OmoriInit)

function mod:PreAddOmoriCostume(itemconfig, player)	
	local costume = itemconfig.Costume
	local ID = costume.ID
		
	if ID == OmoriMod.Enums.NullItemID.ID_OMORI or ID == OmoriMod.Enums.NullItemID.ID_OMORI_EMOTION then return end
	
	return true
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_COSTUME, mod.PreAddOmoriCostume)

function mod:AAAA(tear)
	local player = OmoriMod.GetPlayerFromAttack(tear)
	
	-- print(tear.Parent:ToFamiliar())
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.AAAA)

-- local weapon = player:GetWeapon(1)
		
	-- if weapon then	
		-- local override = tables.OverrideWeapons[weapon:GetWeaponType()] or false
		-- if override == true then
			-- local newWeapon = Isaac.CreateWeapon(WeaponType.WEAPON_TEARS, player)
			-- Isaac.DestroyWeapon(weapon)
			-- player:EnableWeaponType(WeaponType.WEAPON_TEARS, true)
			-- player:SetWeapon(newWeapon, 1)
		-- end
	-- end
	
local overrideWeapons = {
	[WeaponType.WEAPON_KNIFE] = true,
	[WeaponType.WEAPON_SPIRIT_SWORD] = true,
}

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

-- function mod:onRoomEnter()
	-- local players = PlayerManager.GetPlayers()
	-- for _, player in ipairs(players) do
		-- local playerData = OmoriMod:GetData(player)
		
		-- if playerData.RenderEmotionGlow == true then
			-- playerData.RenderEmotionGlow = false
		-- end
	-- end
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onRoomEnter)