local mod = OmoriMod
local game = Game()

function mod:OmoriInit(player)
	local playerData = OmoriMod:GetData(player)
	if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then
		player:AddNullCostume(OmoriMod.Enums.NullItemID.ID_OMORI)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.OmoriInit)

function mod:OmoUpdate(player)
	if not OmoriMod:IsKnifeUser(player) then return end
	
	local weapon = player:GetWeapon(1)
	
	if weapon == nil then return end
	
	if weapon:GetWeaponType() == WeaponType.WEAPON_LUDOVICO_TECHNIQUE or player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
		Isaac.DestroyWeapon(weapon)
	end
		
	if weapon:GetWeaponType() == WeaponType.WEAPON_KNIFE or weapon:GetWeaponType() == WeaponType.WEAPON_SPIRIT_SWORD then
		local overrideWeapon = Isaac.CreateWeapon(WeaponType.WEAPON_TEARS, player)
			
		player:EnableWeaponType(WeaponType.WEAPON_KNIFE, false)
		player:EnableWeaponType(WeaponType.WEAPON_SPIRIT_SWORD, false)
			
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
			overrideWeapon = Isaac.CreateWeapon(WeaponType.WEAPON_BRIMSTONE, player)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
			overrideWeapon = Isaac.CreateWeapon(WeaponType.WEAPON_LASER, player) 
		end
		player:SetWeapon(overrideWeapon, 1)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.OmoUpdate)

function mod:onRoomEnter()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local playerData = OmoriMod:GetData(player)
		
		if playerData.RenderEmotionGlow == true then
			playerData.RenderEmotionGlow = false
			OmoriMod:OmoriChangeEmotionEffect(player)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onRoomEnter)