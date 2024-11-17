local mod = OmoriMod
local enums = OmoriMod.Enums
local utils = enums.Utils
local sfx = utils.SFX

function mod:ReliefSunny(_, _, player)
	local playerData = OmoriMod:GetData(player)
	
	if not OmoriMod:IsOmori(player, true) then return end
	
	OmoriMod.SetEmotion(player, "Neutral")
				
	playerData.AfraidCounter = 90
	playerData.StressCounter = 150
	playerData.TriggerAfraid = false
	playerData.TriggerStress = false
	player:AddHearts(1)
		
	OmoriMod:SunnyChangeEmotionEffect(player, true)
		
	sfx:Play(OmoriMod.Enums.SoundEffect.SOUND_CALM_DOWN)
		
	return true 
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.ReliefSunny, OmoriMod.Enums.CollectibleType.COLLECTIBLE_CALM_DOWN)

