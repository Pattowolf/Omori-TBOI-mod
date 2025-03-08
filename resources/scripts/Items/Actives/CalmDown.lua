local mod = OmoriMod
local enums = OmoriMod.Enums
local sound = enums.SoundEffect
local utils = enums.Utils
local sfx = utils.SFX

---@param player EntityPlayer
---@return boolean
function mod:ReliefSunny(_, _, player)
	OmoriMod:ResetSunnyEmotion(player, 1, false)
	sfx:Play(sound.SOUND_CALM_DOWN)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.ReliefSunny, OmoriMod.Enums.CollectibleType.COLLECTIBLE_CALM_DOWN)