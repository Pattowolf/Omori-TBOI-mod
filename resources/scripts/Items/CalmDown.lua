local mod = OmoriMod
local game = Game()
local CalmDown = {}
local sfx = SFXManager()

function CalmDown:ReliefSunny(id, RNG, player, flags, slot, CustomData)
	local playerData = OmoriMod:GetData(player)
	
	if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
		if OmoriMod.GetEmotion(player) ~= "Neutral" then
			OmoriMod.SetEmotion(player, "Neutral")
		end
		
		-- local heartsToAdd = 
		
		playerData.AfraidCounter = 90
		playerData.StressCounter = 150
		playerData.TriggerAfraid = false
		playerData.TriggerStress = false
		player:AddHearts(1)
		
		OmoriMod:SunnyChangeEmotionEffect(player, true)
		
		sfx:Play(OmoriMod.Enums.SoundEffect.SOUND_CALM_DOWN)
		
		return true 
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, CalmDown.ReliefSunny, OmoriMod.Enums.CollectibleType.COLLECTIBLE_CALM_DOWN)

