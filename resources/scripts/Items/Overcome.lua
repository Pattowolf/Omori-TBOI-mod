local mod = OmoriMod
local enums = OmoriMod.Enums
local utils = enums.Utils
local sfx = utils.SFX
local items = enums.CollectibleType

function mod:ReplaceCalmDown(player)
	if not OmoriMod:IsOmori(player, true) then return end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		if player:HasCollectible(items.COLLECTIBLE_CALM_DOWN) then
			player:RemoveCollectible(items.COLLECTIBLE_CALM_DOWN, false, ActiveSlot.SLOT_POCKET)
			player:AddCollectible(items.COLLECTIBLE_OVERCOME, 2, true, ActiveSlot.SLOT_POCKET)
		end
	else
		if player:HasCollectible(items.COLLECTIBLE_OVERCOME) then
			player:RemoveCollectible(items.COLLECTIBLE_OVERCOME, false, ActiveSlot.SLOT_POCKET)
			player:AddCollectible(items.COLLECTIBLE_CALM_DOWN, 2, true, ActiveSlot.SLOT_POCKET)
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.ReplaceCalmDown)

function mod:GatherYourCorage(_, _, player)
	local playerData = OmoriMod:GetData(player)
	
	if not OmoriMod:IsOmori(player, true) then return end
	
	OmoriMod.SetEmotion(player, "Neutral")
		
	playerData.AfraidCounter = 60
	playerData.StressCounter = 90
		
	player:AddHearts(2)
		
	if not playerData.IncreasedBowDamage then
		playerData.IncreasedBowDamage = true
	end
		
	OmoriMod:SunnyChangeEmotionEffect(player)
	sfx:Play(OmoriMod.Enums.SoundEffect.SOUND_OVERCOME)
		
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.GatherYourCorage, OmoriMod.Enums.CollectibleType.COLLECTIBLE_OVERCOME)