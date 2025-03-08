local mod = OmoriMod
local enums = OmoriMod.Enums
local sound = enums.SoundEffect
local utils = enums.Utils
local sfx = utils.SFX
local items = enums.CollectibleType

---@param player EntityPlayer
function mod:ReplaceCalmDown(player)
	if not OmoriMod.IsOmori(player, true) then return end
	
	local hasBirthright = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
	local calmDown = items.COLLECTIBLE_CALM_DOWN
	local overcome = items.COLLECTIBLE_OVERCOME
	local slot = ActiveSlot.SLOT_POCKET

	if hasBirthright then
		if player:HasCollectible(calmDown) then
			player:RemoveCollectible(calmDown, false, slot)
			player:AddCollectible(overcome, 2, true, slot)
		end
	else
		if player:HasCollectible(overcome) then
			player:RemoveCollectible(overcome, false, slot)
			player:AddCollectible(calmDown, 2, true, slot)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.ReplaceCalmDown)

---@param player EntityPlayer
function mod:GatherYourCorage(_, _, player)
	OmoriMod:ResetSunnyEmotion(player, 2, true)
	sfx:Play(sound.SOUND_OVERCOME)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.GatherYourCorage, OmoriMod.Enums.CollectibleType.COLLECTIBLE_OVERCOME)