local mod = OmoriMod
local Overcome = {}
local sfx = SFXManager()

function Overcome:ReplaceCalmDown(player)
	if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			if player:HasCollectible(OmoriMod.Enums.CollectibleType.COLLECTIBLE_CALM_DOWN) then
				player:RemoveCollectible(OmoriMod.Enums.CollectibleType.COLLECTIBLE_CALM_DOWN, false, ActiveSlot.SLOT_POCKET)
				player:AddCollectible(OmoriMod.Enums.CollectibleType.COLLECTIBLE_OVERCOME, 2, true, ActiveSlot.SLOT_POCKET)
			end
		else
			if player:HasCollectible(OmoriMod.Enums.CollectibleType.COLLECTIBLE_OVERCOME) then
				player:RemoveCollectible(OmoriMod.Enums.CollectibleType.COLLECTIBLE_OVERCOME, false, ActiveSlot.SLOT_POCKET)
				player:AddCollectible(OmoriMod.Enums.CollectibleType.COLLECTIBLE_CALM_DOWN, 2, true, ActiveSlot.SLOT_POCKET)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Overcome.ReplaceCalmDown)

function Overcome:GatherYourCorage(id, RNG, player, flags, slot, CustomData)
	local playerData = OmoriMod:GetData(player)
	
	if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
		if OmoriMod.GetEmotion(player) ~= "Neutral" then
			OmoriMod.SetEmotion(player, "Neutral")
		end
		
		playerData.AfraidCounter = 60
		playerData.StressCounter = 90
		
		player:AddHearts(2)
		
		if not playerData.IncreasedBowDamage then
			playerData.IncreasedBowDamage = true
		end
		
		OmoriMod:SunnyChangeEmotionEffect(player, true)
		sfx:Play(OmoriMod.Enums.SoundEffect.SOUND_OVERCOME)
		
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, Overcome.GatherYourCorage, OmoriMod.Enums.CollectibleType.COLLECTIBLE_OVERCOME)




